
import json
import urllib.request
import urllib.error
import os

TRANSCRIPT_FILE = "transcript.txt"
OUTPUT_FILE = "lesson_material.md"
CORRECTED_FILE = "transcript_corrected.txt"

OLLAMA_URL = "http://localhost:11434/api/generate"
MODEL = "qwen2.5:3b"


def call_ollama(prompt):
    data = {
        "model": MODEL,
        "prompt": prompt,
        "stream": False,
        "options": {
            "temperature": 0.3
        }
    }

    request = urllib.request.Request(
        OLLAMA_URL,
        data=json.dumps(data).encode("utf-8"),
        headers={"Content-Type": "application/json"},
        method="POST"
    )

    with urllib.request.urlopen(request, timeout=600) as response:
        result = json.loads(response.read().decode("utf-8"))
        return result["response"]



def correct_transcript(transcript):
    prompt = f"""
Bạn là chuyên gia hiệu đính bản ghi âm bài giảng tiếng Việt,
đặc biệt là bài giảng lập trình công nghệ thông tin.

NHIỆM VỤ:
Kiểm tra và sửa các từ Whisper nhận diện sai do phát âm,
âm thanh không rõ hoặc nhầm từ đồng âm gần giống nhau.

NGUYÊN TẮC:

1. Đọc toàn bộ ngữ cảnh trước khi sửa từng từ.
2. Ưu tiên những từ có nghĩa phù hợp với câu đang nói.
3. Phân biệt các từ dễ bị Whisper nhận diện nhầm.
4. Sửa cả lỗi sai từ, không chỉ lỗi thiếu dấu hoặc chính tả.
5. Đặc biệt chú ý các thuật ngữ lập trình Java và tin học.
6. Ví dụ:
   - "Ghi chú 1 rồng" trong ngữ cảnh ghi chú
     có thể phải sửa thành "Ghi chú 1 dòng".
   - "hàm phương thức" cần kiểm tra theo ngữ cảnh,
     không tự ý thay đổi nếu chưa đủ căn cứ.
7. Không tự thêm kiến thức mới.
8. Không viết lại nội dung theo cách làm thay đổi ý giảng viên.
9. Giữ nguyên tất cả mốc thời gian.
10. Nếu không thể xác định từ đúng, đánh dấu [CẦN KIỂM TRA].
11. Chỉ trả về văn bản đã hiệu đính.

VĂN BẢN:

{transcript}
"""

    print("Dang hieu dinh van ban bang Qwen...")
    return call_ollama(prompt)


def generate_material():

    if not os.path.exists(TRANSCRIPT_FILE):
        print("Khong tim thay transcript.txt")
        return

    with open(TRANSCRIPT_FILE, "r", encoding="utf-8") as f:
        transcript = f.read()

    if not transcript.strip():
        print("Transcript dang rong!")
        return

    try:
        # Buoc 1: Hieu dinh transcript
        corrected_transcript = correct_transcript(transcript)

        # Buoc 2: Luu transcript da hieu dinh
        with open(CORRECTED_FILE, "w", encoding="utf-8") as f:
            f.write(corrected_transcript)

        print("Da hieu dinh van ban thanh cong!")

        # Buoc 3: Tao tai lieu hoc tap
        print("Dang gui bai giang cho Qwen...")

        prompt = f"""
Bạn là trợ lý giảng dạy của nền tảng EduSphere.

Hãy đọc nội dung bài giảng dưới đây và tạo tài liệu học tập
bằng tiếng Việt.

YÊU CẦU:

1. SUMMARY:
- Tóm tắt nội dung chính của bài học.
- Trình bày rõ ràng, dễ hiểu.
- Không tự bịa thêm kiến thức không có trong bài.

2. KEY POINTS:
- Liệt kê các kiến thức quan trọng.
- Giải thích ngắn gọn từng ý.
- Giữ nguyên thuật ngữ lập trình tiếng Anh cần thiết.

3. TERMS:
- Liệt kê các thuật ngữ chuyên ngành.
- Giải thích ý nghĩa bằng tiếng Việt.
- Đưa ví dụ nếu nội dung bài giảng có đề cập.

4. CONCLUSION:
- Tổng kết những kiến thức người học cần ghi nhớ.

Nếu nội dung không đề cập đến một phần nào đó,
hãy ghi rõ thay vì tự tạo thông tin.

NỘI DUNG BÀI GIẢNG:

{corrected_transcript}
"""

        result = call_ollama(prompt)

        with open(OUTPUT_FILE, "w", encoding="utf-8") as f:
            f.write("# TÀI LIỆU HỌC TẬP EDUSPHERE\n\n")
            f.write(result)

        print("\nDA TAO TAI LIEU THANH CONG!")
        print("File:", os.path.abspath(OUTPUT_FILE))
        print("Transcript da hieu dinh:", os.path.abspath(CORRECTED_FILE))

    except urllib.error.URLError as e:
        print("Khong ket noi duoc Ollama:", e)

    except Exception as e:
        print("Co loi xay ra:", e)


if __name__ == "__main__":
    generate_material()
