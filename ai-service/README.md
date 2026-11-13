# EDUSPHERE AI SERVICE (FastAPI + Faster-Whisper + Ollama)

Dịch vụ AI phân tích video bài giảng và tự động biên soạn tài liệu học tập cho nền tảng EduSphere.

## 1. Yêu cầu cài đặt môi trường
- **Python**: Python 3.10 hoặc 3.11 (khuyên dùng Python 3.11).
- **FFmpeg**: Đã cài đặt và có trong biến môi trường PATH (kiểm tra bằng lệnh `ffmpeg -version`).
- **Ollama**: Đã cài đặt Ollama trên máy và kéo model Qwen 2.5:3B:
  ```bash
  ollama run qwen2.5:3b
  ```

## 2. Cài đặt Python Virtual Environment
Mở CMD / PowerShell tại thư mục `ai-service`:
```bash
python -m venv venv
venv\Scripts\activate
pip install -r requirements.txt
```

## 3. Khởi chạy Dịch vụ AI (Port 8000)
Chỉ cần chạy file script:
```bash
run_server.bat
```
Hoặc bằng lệnh:
```bash
venv\Scripts\activate
uvicorn app:app --host 0.0.0.0 --port 8000
```

Kiểm tra trạng thái tại trình duyệt: `http://localhost:8000/health` (phải trả về `{"status":"UP", ...}`).

## 4. Cấu hình Spring Boot
Trong `src/main/resources/application.properties` của EduSphere:
```properties
ai.service.base-url=http://localhost:8000
```

## 5. Dùng chung AI cho cả nhóm (Không cần cài đặt nhiều máy)
Nếu chỉ 1 máy chạy AI, bạn có thể chia sẻ cổng AI cho cả nhóm dùng chung từ xa:
1. Chạy file `share_public_ai.bat`.
2. Màn hình sẽ hiện một đường link HTTPS công khai miễn phí dạng:
   `https://xxxxxxxxxxxx.trycloudflare.com`
3. Các thành viên khác chỉ cần đổi trong `application.properties` của họ:
   ```properties
   ai.service.base-url=https://xxxxxxxxxxxx.trycloudflare.com
   ```
   Cả nhóm sẽ dùng chung mô hình AI trên máy của bạn mà không cần cài đặt gì thêm!


