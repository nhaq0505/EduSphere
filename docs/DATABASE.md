# Cơ sở dữ liệu EduSphere

Cập nhật 05/10/2026. Nguồn đối chiếu: báo cáo
`Du_An_Ho_Tro_Hoc_Tap_Truc_Tuyen_Bao_Cao_Team2.docx`, UC01–UC50,
và sáu entity Authentication hiện có. Script chuẩn duy nhất: `SQLQuery1.sql`.
Đã kiểm thử bằng SQL Server 2022 trong Docker.

Sơ đồ ERD tĩnh kiểu bảng SSMS nằm tại `docs/database-diagram/`: bản tổng thể
44 bảng có SVG/PNG và bản `.drawio` chỉnh sửa được, kèm sơ đồ chi tiết UC09–UC19.
Các sơ đồ lấy từ file SQL, không tự áp dụng schema lên database đang chạy.

## Phạm vi và bảng

Schema gồm **44 bảng: 33 bảng cốt lõi và 11 bảng mở rộng**. Đây là thiết kế
dữ liệu phục vụ các UC, không có nghĩa là toàn bộ chức năng Java đã hoàn thành.

| Phạm vi | Bảng |
| --- | --- |
| UC01–UC08: tài khoản, quyền, nhật ký quản trị | `roles`, `users`, `user_roles`, `email_verification_tokens`, `password_reset_tokens`, `oauth_accounts`, `account_events` |
| UC09–UC19: danh mục, khóa học, duyệt, ghi danh | `categories`, `courses`, `course_reviews`, `enrollments` |
| UC20–UC23: bài học, tài liệu, hoàn thành bài | `lessons`, `materials`, `lesson_completions` |
| UC24–UC28: bài tập, phiên bản nộp, chấm điểm | `assignments`, `submissions`, `grades` |
| UC29–UC33: quiz, câu hỏi, đáp án, lượt làm, công bố | `quizzes`, `questions`, `answer_options`, `quiz_attempts`, `quiz_answers`, `quiz_answer_options` |
| UC34–UC39: kế hoạch, lịch riêng, tiến độ, lịch sử | `study_plans`, `personal_tasks`, `learning_progress`, `learning_history` |
| UC40–UC44: hỏi đáp, thảo luận, kiểm duyệt, thông báo | `course_questions`, `course_answers`, `discussions`, `discussion_replies`, `announcements`, `notifications` |
| UC45: thanh toán, callback, hoàn tiền — mở rộng | `payments`, `payment_events`, `refunds` |
| UC46–UC47: cấp/xác minh chứng chỉ — mở rộng | `certificates` |
| UC48: nhóm học tập — mở rộng | `study_groups`, `group_members` |
| UC49: xử lý video — mở rộng | `videos` |
| UC50: nguồn được duyệt, hội thoại, trích nguồn AI — mở rộng | `ai_learning_resources`, `ai_chat_sessions`, `ai_chat_logs`, `ai_chat_sources` |

Guest là người chưa đăng nhập, không cần bản ghi role. Script chỉ bổ sung role
`STUDENT`, `INSTRUCTOR`, `ADMINISTRATOR` còn thiếu, không giả định role ID cố định
và không tạo tài khoản/mật khẩu Administrator mặc định.

## Cách chạy và hành vi khi chạy lại

Tại thư mục dự án, với Docker đang hoạt động và `.env` đã cấu hình:

```sh
./scripts/init-db.sh
```

Người dùng SQL Server trên máy khác chạy toàn bộ `SQLQuery1.sql` trong SSMS.
Không cần bật SQLCMD mode. Script có `GO`, nên không gửi cả file như một câu lệnh
JDBC đơn lẻ. Script dùng tên database `EduSphere`, không đổi cấu hình kết nối
của Spring hoặc tạo container trên máy người chạy bằng SSMS.

- Database trống: tạo database nếu chưa có, 44 bảng, khóa/ràng buộc/index và role.
- Schema sáu bảng tài khoản gốc: giữ nguyên bảng và bản ghi, bổ sung bảng còn thiếu.
- Chạy lại schema hoàn chỉnh: không tạo lại bảng đã có, không nhân đôi role.
- Sai kiểu/độ dài/nullability cột, khóa chính/unique hoặc khóa ngoại: báo lỗi;
  transaction của schema rollback, không tự xóa bảng để làm lại.
- Các CHECK phải tồn tại, bật và trusted; cột có DEFAULT phải có default.
  Script không so sánh tương đương ngữ nghĩa của mọi công thức CHECK/DEFAULT,
  hoặc tự sửa index đã tồn tại cùng tên. Không dùng nó thay cho công cụ migration.

Khóa transaction ngăn hai lần chạy script này cùng thay đổi schema. Database
mới được tạo trước transaction; nếu schema lỗi, database mới có thể vẫn tồn tại
nhưng phần thay đổi bảng trong transaction được rollback. Sao lưu database dùng
chung trước khi áp dụng. Không dùng `DROP DATABASE` hoặc xóa Docker volume để nâng cấp.

## Những điểm đã rà soát và bổ sung

- Giữ kiểu cột, nullable và khóa của sáu entity auth hiện tại; mật khẩu có thể
  NULL cho tài khoản Google. Không sửa Java để thích nghi một schema auth khác.
- Khóa học có trạng thái `DRAFT → SUBMITTED → APPROVED/REJECTED → PUBLISHED → ARCHIVED`
  và lịch sử quyết định theo `course_version`. CHECK yêu cầu thông tin phê duyệt
  khi ở trạng thái được duyệt/công bố; quyền chuyển trạng thái do service kiểm tra.
- Ghi danh unique theo học viên/khóa; khóa ngoại tổng hợp chặn liên kết bài học,
  bài tập, quiz, thanh toán hoặc thông báo sang nhầm khóa/người sở hữu.
- Nộp lại tạo dòng `submissions` mới với `attempt_number`, không ghi đè bài cũ.
  Điểm được giới hạn từ 0 đến `max_score` lưu tại thời điểm chấm.
- Quiz hỗ trợ nhiều lựa chọn qua `quiz_answer_options`; câu hỏi/đáp án gắn đúng
  quiz và lưu snapshot nội dung/điểm trong bài làm. Điểm chấm và công bố tách riêng.
- `personal_tasks.planned_start_at/planned_end_at` độc lập với ngày mở/hạn/khóa
  bài tập hoặc quiz; đổi lịch cá nhân không cập nhật deadline chính thức.
- Hỏi đáp riêng với thảo luận; lưu người/thời điểm kiểm duyệt. Thông báo có từng
  người nhận và thời điểm đọc, tránh gửi trùng cùng thông báo/người nhận.
- Thanh toán có request key, callback, trạng thái và hoàn tiền; mã giao dịch ngoài
  dùng filtered unique index để nhiều giao dịch đang chờ vẫn có thể để NULL.
- Các bảng mới không cascade delete để bảo toàn bài nộp, điểm, lịch sử và tài chính.
  Sáu bảng auth giữ hành vi cascade cũ để không đổi hợp đồng dữ liệu hiện tại.

## Quy tắc còn phải viết trong Java

Schema không thay thế kiểm tra quyền hoặc quy tắc nhiều bản ghi. Khi triển khai:

1. Kiểm tra role, chủ sở hữu khóa và trạng thái tài khoản; học viên chỉ truy cập
   khóa ghi danh hợp lệ, giảng viên chỉ quản lý khóa mình phụ trách.
2. Chặn sửa/công bố trái vòng đời khóa; lần duyệt phải khớp phiên bản hiện tại.
   Không sửa/xóa câu hỏi và đáp án gốc sau khi có lượt làm; nếu cần thay đổi,
   tạo quiz/bộ câu hỏi mới để không làm sai lịch sử đánh giá.
3. Kiểm tra hạn, số lượt, việc cho nộp lại/làm quiz; cấp `attempt_number` trong
   transaction để xử lý yêu cầu đồng thời. Chụp nội dung/đáp án/điểm khi làm bài.
4. Chỉ trả điểm/đáp án đúng sau công bố. `max_score` của grade phải lấy từ bài tập;
   tổng điểm, tiến độ và nhật ký phải được cập nhật nhất quán trong transaction.
5. Xác minh callback, số tiền, tiền tệ và thanh toán thành công trước ghi danh khóa
   trả phí; chặn tổng hoàn tiền vượt tiền đã thu. Không tin trạng thái từ trình duyệt.
6. Chỉ cấp chứng chỉ khi đủ điều kiện; xác nhận thành viên nhóm là học viên hợp lệ
   hoặc giảng viên phụ trách. Chặn chu trình danh mục hoặc chuỗi trả lời thảo luận.
7. AI chỉ dùng nguồn được duyệt và đúng quyền khóa, không phải chỉ có khóa ngoại
   là đã bảo đảm quyền truy cập. Kiểm tra loại tài liệu khi liên kết xử lý video.
8. Chọn một quy ước múi giờ cho `DATETIME2`/JDBC và lịch cá nhân. Giữ credential
   ngoài Git. Schema vẫn giữ token unique để tương thích `findByToken`; service
   cần gắn OTP với đúng tài khoản/mục đích, kiểm soát hết hạn và số lần thử.

Khi viết entity mới: dùng đúng tên cột, `BigDecimal` cho DECIMAL, kiểu thời gian
tương ứng DATETIME2, và khai báo đúng VARCHAR/CHAR/NVARCHAR. Giữ
`spring.jpa.hibernate.ddl-auto=validate`, không đổi sang `create`/`create-drop`.

## Kiểm thử thực tế

Đã chạy script trên database tạm trống và bản sao schema sáu bảng auth có dữ liệu,
sau đó chạy lại trên cả hai. Đã thử luồng hợp lệ xuyên phân hệ và 15 thao tác sai
để xác nhận unique/CHECK/FK chặn đúng lỗi (ghi danh trùng, liên kết sai khóa học,
điểm quá mức, lịch sai chủ sở hữu, đáp án sai câu hỏi, công bố thiếu thông tin...).
Bài nộp nhiều phiên bản và đáp án nhiều lựa chọn được lưu đúng; đổi lịch cá nhân
không sửa hạn chính thức. Schema sai độ dài cột bị từ chối và phần thêm bảng được
rollback, giữ lại bảng/bản ghi cũ. Đã so sánh hai chiều bằng `EXCEPT`: bản ghi của
cả sáu bảng auth không thay đổi sau nâng cấp và chạy lặp. Dữ liệu fixture được rollback.

Ứng dụng WAR hiện có khởi động bằng Java 17 với `ddl-auto=validate` trên database
bản sao có 44 bảng; trang chủ và trang đăng nhập trả HTTP 200. Database chính
`EduSphere` chưa được áp dụng script mới trong lần rà soát này (vẫn có sáu bảng).
