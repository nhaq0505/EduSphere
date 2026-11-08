# HƯỚNG DẪN CẬP NHẬT CƠ SỞ DỮ LIỆU (DATABASE MIGRATION)
**Nhánh:** `quiz-quizbank-video`  
**Dự án:** EduSphere  

Tài liệu này hướng dẫn cách chạy các script SQL để cập nhật cơ sở dữ liệu trên máy của các thành viên trong nhóm nhằm hỗ trợ đầy đủ các tính năng:
1. **Tiến độ xem video bài học & tích hợp Bunny Stream CDN** (Chống tua video chưa xem, đạt 80% mở khóa bài tập).
2. **Ngân hàng câu hỏi (Question Bank)** (Phân loại theo chuyên đề, mức độ, bốc câu hỏi ngẫu nhiên vào quiz).
3. **Làm Quiz & Chấm điểm tự động** (Đánh dấu câu hỏi màu vàng, nộp bài tự động công bố điểm trắc nghiệm, giải thích đáp án, lưu vết tiến độ).

---

## 🚀 HƯỚNG DẪN CHẠY SCRIPT

### Bước 1: Mở SQL Server Management Studio (SSMS)
- Kết nối tới SQL Server cục bộ của bạn (`localhost,1433` hoặc tên máy).
- Chọn Database: `EduSphere`.

### Bước 2: Chạy script cập nhật cấu trúc bảng (BẮT BUỘC)
- Mở file: `scripts/migration-quiz-quizbank-video.sql`
- Nhấn **F5** (hoặc nút **Execute**).
- *Lưu ý:* Script này được thiết kế theo dạng **Idempotent** (tự kiểm tra tồn tại), bạn có thể chạy nhiều lần mà không bị lỗi duplicate hay mất dữ liệu hiện tại.

### Bước 3: Nạp dữ liệu mẫu (TÙY CHỌN)
- Nếu bạn muốn có sẵn ngân hàng câu hỏi và các câu hỏi mẫu để test ngay tính năng bốc ngẫu nhiên và làm quiz:
- Mở file: `scripts/seed-quiz-quizbank-video-demo.sql`
- Nhấn **F5** (Execute).

---

## 📋 DANH SÁCH BẢNG & CỘT MỚI TRONG NHÁNH NÀY

### 1. Bảng `dbo.lessons` (bổ sung cột):
- `bunny_video_id` (NVARCHAR(100)): ID video trên Bunny Stream.
- `video_status` (NVARCHAR(20)): Trạng thái mã hóa video.
- `quiz_requires_video` (BIT): Cờ bắt buộc xem video trước khi làm bài tập.
- `min_watch_percent` (INT): Tỷ lệ % tối thiểu cần xem (mặc định 80%).

### 2. Bảng `dbo.lesson_watch_progress` (mới):
- Lưu trữ thời gian xem, các phân đoạn đã xem (anti-seeking), và cờ `quiz_unlocked` theo từng học viên và bài học.

### 3. Hệ thống Ngân hàng câu hỏi (mới):
- `dbo.question_banks`: Danh sách các ngân hàng câu hỏi theo giảng viên/khóa học.
- `dbo.bank_categories`: Các chuyên đề/chủ đề trong ngân hàng.
- `dbo.bank_questions`: Chi tiết câu hỏi trong ngân hàng (Trắc nghiệm đơn/nhiều lựa chọn, Đúng/Sai, Điền từ, Tự luận).
- `dbo.bank_answer_options`: Các phương án đáp án A, B, C, D của câu hỏi.
- `dbo.quizzes` (thêm cột `bank_id`): Liên kết bài quiz với ngân hàng câu hỏi để bốc tự động.
- `dbo.questions` (thêm các cột `image_url`, `video_url`, `bank_question_id`, `sample_essay_answer`).
