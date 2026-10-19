# Phân công triển khai EduSphere cho 5 người

Cập nhật ngày 05/10/2026. Căn cứ: báo cáo `Du_An_Ho_Tro_Hoc_Tap_Truc_Tuyen_Bao_Cao_Team2.docx` (UC01–UC50) và mã nguồn ở commit `0bfd0e1`. Điền tên thật vào các vị trí Người 1–5 khi nhóm chốt nhân sự.

## Công nghệ và cách làm chung

- **Backend:** Java 17, Spring Boot 3.3.4, Spring MVC, Spring Security, Spring Data JPA/Hibernate, Maven.
- **Giao diện:** JSP, HTML, CSS và JavaScript thuần khi cần. Controller trả về view hoặc chuyển trang; không đặt REST API/JSON làm cách triển khai mặc định.
- **Dữ liệu:** Microsoft SQL Server. `SQLQuery1.sql` là script chung gồm 44 bảng cho UC01–UC50, chạy lặp được và giữ dữ liệu schema tài khoản cũ. Dùng schema này để viết entity tương ứng; xem ánh xạ tại `docs/DATABASE.md`.
- **Cấu trúc code:** `controller` nhận request và điều hướng; `service` xử lý nghiệp vụ; `repository` truy cập dữ liệu; `entity` ánh xạ bảng; `dto` nhận/kiểm tra dữ liệu form; JSP nằm trong `src/main/webapp/WEB-INF/views`.
- **Mỗi người bàn giao đủ:** code Spring, JSP/CSS, entity khớp schema chung, kiểm thử phù hợp và hướng dẫn sử dụng chức năng mình phụ trách. Thay đổi schema phải thống nhất rồi cập nhật `SQLQuery1.sql`; không tạo nhiều script khởi tạo cạnh tranh. Không đưa mật khẩu, khóa email hay OAuth vào Git.

## Thứ tự và mốc phụ thuộc

| Mốc | Việc cần xong | Người chính | Điều kiện chuyển mốc |
| --- | --- | --- | --- |
| **0 — Làm đầu tiên** | Hoàn thiện Authentication và phân quyền UC01–UC08 | Người 1 | Chạy được dự án với SQL Server; đăng ký/đăng nhập/đăng xuất/khôi phục mật khẩu và quản trị role, trạng thái tài khoản được kiểm thử. Cả nhóm nhận quy tắc session, role và URL. |
| 1 | Khám phá, ghi danh, vòng đời khóa học UC09–UC19; bài học và tài liệu UC20–UC23 | Người 2 và 3 | Guest xem được khóa học công khai; Instructor tạo/gửi duyệt, Administrator duyệt, Instructor công bố; Student ghi danh và học bài. |
| 2 | Assignment UC24–UC28; Quiz và kết quả UC29–UC33; kế hoạch/tiến độ UC34–UC39 | Người 3 và 4 | Luồng nộp/chấm/công bố kết quả hoạt động; lịch cá nhân không sửa deadline chính thức. |
| 3 | Hỏi đáp, thảo luận, thông báo UC40–UC44; kiểm thử toàn hệ thống | Người 5 phối hợp cả nhóm | Các luồng Guest → Student → Instructor → Administrator chạy liên tục và quyền được kiểm tra. |
| 4 — Nếu còn thời gian | Mở rộng UC45–UC50 | Theo bảng phân công | Chỉ bắt đầu sau khi UC01–UC44 ổn định; mỗi tích hợp bên ngoài phải có cấu hình và cách thử rõ ràng. |

Trong mốc 0, Người 2–5 có thể đọc schema chung, chuẩn bị entity JPA, giao diện và thiết kế controller cho phần mình. Tích hợp tính năng có đăng nhập dùng quy tắc auth đã được Người 1 bàn giao.

## Phân công cụ thể

### Người 1 — Authentication, phân quyền và cấu hình chạy

**Use case:** UC01–UC08. **Làm đầu tiên.**

- Tiếp nhận code đã có: đăng ký/xác minh OTP, đăng nhập/đăng xuất, Google OAuth2, hồ sơ/avatar, đổi/khôi phục mật khẩu, entity/repository tài khoản và JSP auth. Đây là code cần kiểm thử và hoàn thiện, chưa coi là đã nghiệm thu.
- Hoàn thành phần còn thiếu: **UC07 gán/thay đổi role** và **UC08 khóa/mở tài khoản** qua giao diện quản trị; ràng buộc chỉ Administrator được thao tác.
- Sửa các luồng liên quan trạng thái tài khoản: đăng ký lại không được xóa tài khoản `LOCKED`; đăng nhập bằng Google và session đang tồn tại phải tuân thủ trạng thái bị khóa. Kiểm tra OTP, khôi phục mật khẩu và quyền truy cập sau đổi mật khẩu.
- Cung cấp cấu hình mẫu không chứa bí mật cho SQL Server, email, OAuth và thư mục upload; hướng dẫn chạy dự án, tạo bảng và tạo tài khoản Administrator thử nghiệm.
- **Bàn giao:** luồng auth chạy được, bảng quyền/URL, test cho Guest/Student/Instructor/Administrator và các trường hợp tài khoản `PENDING`, `ACTIVE`, `LOCKED`.

### Người 2 — Khám phá, ghi danh và vòng đời khóa học

**Use case cốt lõi:** UC09–UC19. **Mở rộng sau cùng:** UC45 thanh toán.

- Guest và Student tìm kiếm, lọc, xem chi tiết khóa học công khai; Student ghi danh và xem khóa đã ghi danh.
- Instructor tạo/chỉnh sửa khóa học, gửi duyệt, công bố sau khi được duyệt và lưu trữ; Administrator phê duyệt hoặc từ chối kèm lý do.
- Ánh xạ các bảng `categories`, `courses`, `course_reviews`, `enrollments` đã có thành entity/repository JPA; xây controller, service, JSP theo cấu trúc dự án.
- **Bàn giao:** test vòng đời `Draft → Submitted → Approved/Rejected → Published → Archived`; khóa chưa công bố không xuất hiện trong danh sách công khai; chỉ khóa đã duyệt mới được công bố.

### Người 3 — Bài học, tài liệu và assignment

**Use case cốt lõi:** UC20–UC28. **Mở rộng sau cùng:** UC49 xử lý video lớn.

- Instructor tạo/sửa bài học, gắn tài liệu; Student đã ghi danh truy cập bài học và tài liệu đúng quyền.
- Instructor tạo/cấu hình assignment; Student nộp hoặc nộp lại theo quy tắc; Instructor chấm điểm và nhận xét.
- Ánh xạ các bảng bài học, tài liệu, assignment, submission và grade đã có thành entity/repository JPA; thống nhất quyền truy cập tệp với Người 1 và khóa học với Người 2.
- **Bàn giao:** test hạn nộp, điều kiện nộp lại, quyền xem/chấm bài và việc không ghi đè mất bài nộp cũ.

### Người 4 — Quiz, kết quả và kế hoạch học tập

**Use case cốt lõi:** UC29–UC39. **Mở rộng sau cùng:** UC46–UC47 chứng chỉ.

- Instructor tạo/cấu hình quiz và câu hỏi; Student làm quiz theo số lần và thời gian được phép; Instructor công bố kết quả, Student chỉ xem kết quả đã công bố.
- Student tạo study plan, đặt nhiệm vụ cá nhân, xem lịch, tiến độ và lịch sử; Instructor xem tiến độ học viên trong khóa mình phụ trách.
- Ánh xạ các bảng quiz, câu hỏi, lượt làm, kế hoạch cá nhân và tiến độ đã có thành entity/repository JPA; liên kết bài học/assignment/quiz với Người 3.
- **Bàn giao:** test số lượt quiz, công bố điểm, quyền xem tiến độ và quy tắc **lịch cá nhân không sửa `due date`, `unlock` hoặc `lock` do Instructor đặt**.

### Người 5 — Trao đổi học tập và kiểm thử tích hợp

**Use case cốt lõi:** UC40–UC44. **Mở rộng sau cùng:** UC48 nhóm học tập, UC50 AI assistant.

- Student đặt câu hỏi trong khóa học; Instructor trả lời; Student/Instructor thảo luận; Instructor/Administrator kiểm duyệt; Instructor gửi thông báo cho người học trong khóa.
- Ánh xạ các bảng hỏi đáp, thảo luận và thông báo đã có thành entity/repository JPA; viết controller, service và JSP; kiểm tra chỉ thành viên/giảng viên hợp lệ được tương tác.
- Phối hợp Người 1–4 kiểm thử các luồng xuyên phân hệ, dữ liệu mẫu, trang lỗi và quyền truy cập. Người 5 điều phối kiểm thử tích hợp; từng người vẫn tự kiểm thử phần mình.
- **Bàn giao:** test quyền đặt/trả lời/kiểm duyệt, thông báo đúng học viên và checklist luồng end-to-end đã chạy.

## Quy tắc phối hợp và nghiệm thu

1. Mỗi người làm trên nhánh riêng, ghi rõ use case trong pull request; không sửa trực tiếp phần của người khác khi chưa trao đổi.
2. Chốt một người tích hợp thay đổi `SQLQuery1.sql` để giảm conflict ở file chung. Thành viên đề xuất thay đổi bảng/cột trong pull request, không tự sửa bảng của phân hệ khác. Entity JPA phải khớp schema; thay đổi cấu trúc đã triển khai cần migration được kiểm thử, không chỉ sửa `CREATE TABLE`. Các form dùng DTO và validation; service giữ quy tắc nghiệp vụ, controller không chứa truy vấn dữ liệu.
3. Người 2 và 3 thống nhất entity/quan hệ Course/Lesson trước khi viết code phụ thuộc. Người 3 và 4 thống nhất Assignment/Quiz/Result trước khi liên kết StudyTask.
4. Các dịch vụ Email, Payment, Video Processing và AI là dịch vụ bên ngoài; chỉ Email đang nằm trong mốc Authentication. Payment/Video/AI thuộc mốc mở rộng.
5. Chức năng chỉ được đánh dấu xong khi chạy được, có dữ liệu thử, kiểm tra quyền theo vai trò và có hướng dẫn ngắn để người khác chạy lại.
