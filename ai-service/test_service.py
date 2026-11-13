import sys
import time
import os
from pathlib import Path

# Add D:\EduSphere-AI to sys.path
sys.path.insert(0, str(Path(__file__).resolve().parent))

from fastapi.testclient import TestClient
from app import app

client = TestClient(app)

def test_health():
    print("\n--- 1. Testing /health endpoint ---")
    response = client.get("/health")
    print("Health response:", response.status_code, response.json())
    assert response.status_code == 200
    data = response.json()
    assert data["status"] in ("UP", "DEGRADED")
    print("Health test PASSED!")

def test_invalid_input():
    print("\n--- 2. Testing validation errors ---")
    response = client.post("/api/ai/materials/generate", json={"lessonId": -1})
    print("Negative lessonId response:", response.status_code)
    assert response.status_code == 400

    response = client.get("/api/ai/materials/tasks/non_existent_task")
    print("Non-existent taskId response:", response.status_code)
    assert response.status_code == 404
    print("Validation test PASSED!")

def test_pipeline_execution():
    print("\n--- 3. Testing pipeline with test MP3 ---")
    test_mp3 = r"D:\3. Ghi chú trong java - tự học lập trình java cơ bản new tutorial - YouTube.mp3"
    if not os.path.exists(test_mp3):
        print("Skipping pipeline test: Test MP3 not found.")
        return

    payload = {
        "lessonId": 9999,
        "filePath": test_mp3,
        "forceRegenerate": True
    }
    response = client.post("/api/ai/materials/generate", json=payload)
    print("Generate request response:", response.status_code, response.json())
    assert response.status_code in (200, 202)
    task_id = response.json()["taskId"]
    print("Received taskId:", task_id)

    # Poll status
    print("Polling task status...")
    max_wait = 180  # 3 minutes max
    start = time.time()
    final_status = None

    while time.time() - start < max_wait:
        res = client.get(f"/api/ai/materials/tasks/{task_id}")
        assert res.status_code == 200
        data = res.json()
        current_status = data["status"]
        progress = data["progress"]
        msg = data["message"]
        print(f"[{int(time.time() - start)}s] Status: {current_status} ({progress}%) - {msg}")

        if current_status in ("COMPLETED", "FAILED"):
            final_status = current_status
            break
        time.sleep(4)

    assert final_status == "COMPLETED", f"Task failed or timed out: {final_status}"

    # Get results
    res_result = client.get(f"/api/ai/materials/tasks/{task_id}/result")
    print("Result HTTP status:", res_result.status_code)
    assert res_result.status_code == 200
    res_data = res_result.json()

    print("\n--- Summary ---")
    print(res_data.get("summary")[:300] if res_data.get("summary") else "Empty")
    print("\n--- Key Points ---")
    print(res_data.get("keyPoints")[:300] if res_data.get("keyPoints") else "Empty")
    print("\n--- Terms ---")
    print(res_data.get("terms")[:300] if res_data.get("terms") else "Empty")
    print("\n--- Conclusion ---")
    print(res_data.get("conclusion")[:300] if res_data.get("conclusion") else "Empty")

    assert res_data.get("originalTranscript"), "Original transcript should not be empty"
    assert res_data.get("correctedTranscript"), "Corrected transcript should not be empty"
    print("\nPipeline test PASSED SUCCESSFULLY!")

if __name__ == "__main__":
    test_health()
    test_invalid_input()
    test_pipeline_execution()

