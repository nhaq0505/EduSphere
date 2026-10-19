# EDUSPHERE — NHẬT KÝ TIẾN ĐỘ & PHÁT TRIỂN (WORK LOG)

> **Quy tắc bắt buộc:** File này dùng để lưu lại toàn bộ tiến độ, các công việc đã hoàn thành và các quyết định kỹ thuật của dự án EduSphere. Mỗi khi thực hiện xong bất kỳ công việc nào, Agent phải cập nhật ngay vào tài liệu này.

---

## 1. THÔNG TIN DỰ ÁN
- **Tên dự án:** EduSphere (Nền tảng Quản lý Học tập Trực tuyến — Web-based LMS)
- **Cấu trúc quản lý Agent:**
  - **Lead:** Điều phối tổng thể, phân công nhiệm vụ, nghiệm thu và tổng hợp báo cáo.
  - **Builder:** (`f18a4ac8-2d5f-4e89-b42e-0df56bb3471f`) Chịu trách nhiệm scaffolding, lập trình backend/frontend, cấu hình hạ tầng Docker, database migrations và viết tests.
  - **Researcher:** (`5ae394d8-1765-486d-82a8-f87d8eb7dcf5`) Chịu trách nhiệm bóc tách đặc tả từ tài liệu, thiết kế schema cơ sở dữ liệu, viết API specifications và tài liệu kỹ thuật.
- **Tài liệu đặc tả gốc:** `docs/EduSphere_Bao_Cao_Hieu_Chinh.docx` (~1.7MB, gồm 50 Use Cases, 4 Roles nội bộ, 4 dịch vụ mở rộng).
- **Điểm cốt lõi khác biệt:** Tách biệt độc lập giữa **Official Deadline** (do Giảng viên ban hành) và **Personal Study Plan / Study Calendar** (do Học viên tự quản lý cá nhân).

---

## 2. NHẬT KÝ CÔNG VIỆC THEO NGÀY

### Ngày 19/10/2026: Tái cấu trúc luồng xét duyệt, ẩn/công bố và chỉnh sửa khóa học & bài học (Phương án 1)
- [x] **Luồng hoàn thiện & Gửi duyệt:** Khóa học bắt buộc có mô tả và ít nhất 1 bài học hoàn chỉnh (đầy đủ tiêu đề & nội dung) mới được gửi Admin phê duyệt. Giao diện JSP hiển thị số lượng bài học, nút bấm và cảnh báo điều kiện gửi duyệt.
- [x] **Luồng Ẩn / Công bố lại:** Giảng viên có quyền Tạm ẩn khóa học (`PUBLISHED` -> `APPROVED` kèm nhãn Tạm ẩn) và Công bố lại bất cứ lúc nào mà không cần Admin duyệt lại (nếu chưa chỉnh sửa nội dung).
- [x] **Chỉnh sửa khóa học & bài học (Phương án 1):** Giảng viên được phép sửa khóa học và bài học ở các trạng thái `DRAFT`, `REJECTED`, `APPROVED` và `PUBLISHED`. Khi lưu chỉnh sửa khóa học hoặc bài học (tạo mới/sửa/thêm tài liệu) trên khóa đã duyệt hoặc đã công bố:
  - Khóa học tự động tăng `versionNo` (v1 -> v2).
  - Trạng thái quay về `DRAFT` để chuẩn bị nội dung và xóa các mốc duyệt/công bố cũ (`approvedAt = null`, `publishedAt = null`, `submittedAt = null`).
  - Bài học mới/sửa được lưu ở trạng thái `DRAFT` cho đến khi khóa học được phê duyệt và công bố lại.
  - Sau khi Admin duyệt phiên bản mới và Giảng viên công bố, toàn bộ bài học bản nháp trở thành `PUBLISHED` và kích hoạt lại học viên đã hoàn thành trước đó.
- [x] **Tài khoản Demo chuẩn:** Cấu hình tự động khởi tạo 3 tài khoản demo với mật khẩu mặc định `123`: `admin@admin.com`, `instructor@instructor.com`, `student@student.com`.
- [x] **Kiểm thử tự động:** Bổ sung `CourseWorkflowTest` (9 tests) và cập nhật `LessonManagementServiceTest` (5 tests). Toàn bộ 36 unit tests đạt `BUILD SUCCESS`.

### Ngày 14/10/2026: Khôi phục giao diện theo commit 0bfd0e1
- [x] Sao lưu webapp trước khi sửa tại `/tmp/edusphere-fe-before-0bfd0e1-20261014-104831.tar.gz`.
- [x] Khôi phục JSP xác thực, hồ sơ, dashboard, trang chủ, lỗi 403, CSS main/auth và ảnh banner từ `0bfd0e128a1579e4569998393fb359aa991a6e5f`.
- [x] Các trang khóa học/bài học/quản trị chưa có trong commit gốc dùng CSS tương thích phong cách cũ; giữ form binding, CSRF và URL hiện tại. Chỉnh menu tới endpoint đang có, giữ cách đọc roleNames tránh lazy loading.
- [x] Đối chiếu checksum xác nhận Java, cấu hình, SQL và test không thay đổi; Maven test/package và Jasper biên dịch JSP không lỗi. Đã khởi động lại ở cổng 8080.
- [ ] Chưa kiểm tra trực quan bằng trình duyệt trong lần khôi phục này.

### Ngày 14/10/2026: Thêm khóa tự học có nội dung thực tế
- [x] Tạo và chạy `scripts/seed-learning.sql`: 3 khóa miễn phí đã công bố về Java nền tảng, Spring MVC/JSP và SQL Server; tổng cộng 12 bài tiếng Việt có mục tiêu, giải thích, ví dụ, bài thực hành và phần tự kiểm tra.
- [x] Thêm 14 liên kết tài liệu chính thức Java/Oracle, Spring và Microsoft Learn; ghi danh sẵn học viên demo. Không thay đổi tài khoản, nội dung khóa cũ hoặc tiến độ đã có.
- [x] Chạy lại script tạo thêm 0 khóa; kiểm tra LearningService với SQL Server xác nhận học viên đọc được cả 12 bài và 14 học liệu. Ứng dụng khởi động tại cổng 8080.
- [x] Giữ script trong máy theo quy tắc chưa đưa `scripts/` lên Git của nhóm.

### Ngày 10/10/2026: Hoàn thiện UC20–UC23
- [x] UC20–UC21: giảng viên tạo, chỉnh sửa và sắp xếp bài học trong khóa của mình; kiểm tra chủ sở hữu và trạng thái khóa. Khi công bố khóa, bài nháp được công bố cùng khóa.
- [x] UC22: thêm học liệu dạng liên kết tài liệu/video cho bài học, kiểm tra URL HTTP(S) và CSRF.
- [x] UC23: học viên đã ghi danh mở bài, xem học liệu, đánh dấu đã học và theo dõi tiến độ; khóa có phí đang ghi danh thử cũng vào học được.
- [x] Maven test, biên dịch JSP, thử giao dịch rollback trên SQL Server với luồng quản lý bài và luồng ghi danh khóa có phí → học bài → hoàn thành.
- [ ] Kiểm tra thao tác trực quan trên trình duyệt khi quyền truy cập localhost được mở lại.

### Ngày 10/10/2026: Chia lại thư mục theo tầng và phân hệ
- [x] Di chuyển controller, service, repository, entity, dto vào các thư mục con `account` và `course`; giữ cấu hình và security dùng chung tại chỗ.
- [x] Chuyển JSP duyệt khóa học sang `views/admin`, cập nhật view name mà giữ nguyên URL và nghiệp vụ.
- [x] Bỏ qua `.DS_Store`, `.worktrees/` và `src/out/` bằng `.gitignore`.
- [x] Maven test, biên dịch JSP và khởi động ứng dụng Spring Boot/SQL Server thành công sau khi đổi package.

### Ngày 10/10/2026: Cho ghi danh thử trước khi tích hợp thanh toán
- [x] Học viên được ghi danh mọi khóa `PUBLISHED`, kể cả khóa có học phí, mà không cần giao dịch thanh toán; `payment_id` có thể để trống theo schema hiện tại.
- [x] Trang chi tiết nêu rõ học phí chỉ là dự kiến và hiện chưa thu tiền; giữ kiểm tra vai trò học viên, trạng thái khóa và ghi danh trùng.
- [x] Maven test và biên dịch JSP đạt; ứng dụng đã khởi động lại ở cổng 8080.

### Ngày 10/10/2026: Hoàn thiện phạm vi UC01–UC19 trên giao diện mới
- [x] UC07–UC08: thêm quản lý tài khoản cho Administrator tại `/admin/users`; tìm kiếm, phân trang, gán/bỏ vai trò, khóa/khôi phục và ghi `account_events`.
- [x] Chặn tài khoản bị khóa và phiên có vai trò cũ ở mỗi request; sửa đăng ký OTP, Google OAuth và khôi phục mật khẩu để tài khoản bị khóa không tự kích hoạt hoặc đặt lại mật khẩu.
- [x] UC12: hiện thao tác ghi danh khóa học có phí khi học viên đã có giao dịch thành công; trường hợp chưa có quyền truy cập hiển thị rõ giới hạn thanh toán.
- [x] Biên dịch Maven, chạy kiểm thử nghiệp vụ quản trị tài khoản/phiên bị khóa, biên dịch tất cả JSP; ứng dụng khởi động kết nối SQL Server với bảng `account_events` có sẵn.
- [ ] Kiểm tra thao tác thủ công trên trình duyệt cho toàn bộ vai trò khi quyền truy cập localhost được mở lại.

### Ngày 09/10/2026: Hoàn tác giao diện desktop mới
- [x] Theo yêu cầu của nhóm, khôi phục các JSP/CSS/ảnh giao diện đã có trong Git về giao diện cũ; gỡ fragment và JavaScript của đợt viết lại.
- [x] Giữ UC12–UC19: các trang JSP chưa commit được đưa về kiểu giao diện cũ; trang chi tiết và dashboard vẫn có đường vào ghi danh, quản lý và duyệt khóa học.
- [x] Sửa lỗi hồ sơ cũ đọc lazy roles sau khi đóng JPA session; các trang hồ sơ của ba vai trò trả HTTP 200. Maven package và kiểm tra HTTP các trang Student, Instructor, Administrator trên cổng thử 18080 thành công. Không thay đổi database.

### Ngày 09/10/2026: Dữ liệu demo cho UC09–UC19
- [x] Tạo `scripts/seed-demo.sql` chạy lặp được: ba tài khoản demo theo role, ba danh mục, chín khóa học ở các trạng thái, bài học mẫu, ghi danh mẫu và quyền truy cập khóa có phí mẫu.
- [x] Áp dụng lên database `EduSphere`; chạy lại lần hai không tạo trùng. Đăng nhập và mở trang riêng của Student, Instructor, Administrator đều thành công; danh sách công khai hiện bốn khóa `PUBLISHED` và ẩn khóa nháp.

### Ngày 09/10/2026: Ghi danh và quản lý khóa học UC12–UC19
- [x] Student ghi danh khóa học công khai miễn phí hoặc khóa có giao dịch `SUCCEEDED` đúng học viên/khóa học, xem danh sách và trạng thái ghi danh.
- [x] Instructor tạo/sửa nháp, gửi duyệt, công bố sau phê duyệt và lưu trữ; Administrator phê duyệt/từ chối kèm lý do. Áp dụng kiểm tra vai trò, chủ sở hữu, trạng thái và CSRF.
- [x] Thêm giao diện JSP cho học viên, giảng viên và quản trị viên; khóa nháp/lưu trữ không xuất hiện trong danh sách công khai.
- [x] Kiểm tra HTTP theo vai trò trên database tạm: luồng tạo → từ chối → sửa → gửi lại → duyệt → công bố → ghi danh → lưu trữ; các trường hợp sai quyền, sai trạng thái và chưa thanh toán; database thử đã xóa, database chính giữ nguyên.

### Ngày 09/10/2026: Khám phá khóa học công khai UC09–UC11
- [x] Thêm `CourseDiscoveryService`, `CourseDiscoveryController`, DTO hiển thị, truy vấn lọc/phân trang, JSP danh sách/chi tiết/404 và CSS. Guest được phép GET `/courses` và `/courses/{courseId}`; chỉ khóa `PUBLISHED` xuất hiện.
- [x] Thêm mapping/repository bài học để hiển thị tiêu đề các bài `PUBLISHED` trong chi tiết khóa học; chưa triển khai nghiệp vụ học bài UC20–UC23.
- [x] Maven build thành công. Thử trên database tạm 44 bảng: tìm kiếm, lọc danh mục/trình độ/giá, ẩn khóa nháp, ẩn bài nháp, 404 cho khóa chưa công bố và phân trang đều đạt; trang danh sách rỗng trên database chính trả HTTP 200.
- [x] Đã dừng ứng dụng và xóa database thử; database `EduSphere` chính được giữ nguyên.
- [x] UC12–UC19 đã được triển khai trong bước tiếp theo; UC45 xử lý thanh toán vẫn là phần mở rộng riêng.


### Ngày 09/10/2026: Xác nhận schema đã có trên SQL Server
- [x] Kiểm tra `SQLQuery1.sql`, `docs/DATABASE.md` và ERD: đã thiết kế 44 bảng cho UC01–UC50.
- [x] Truy vấn database `EduSphere` đang chạy: hiện có 44 bảng, gồm `categories`, `courses`, `course_reviews`, `enrollments`.
- [x] Sửa kế hoạch phân công: Người 2–5 dùng bảng đã có để viết entity/repository và chức năng, không thiết kế bảng từ đầu.
- [ ] Java đã có entity/repository Authentication và bước đầu của khóa học; service/controller/JSP cho khóa học trở đi vẫn cần triển khai.
- [x] Bắt đầu phần Người 2: thêm `Category`, `Course`, `CourseReview`, `Enrollment` và bốn Spring Data JPA repository tương ứng, ánh xạ vào schema 44 bảng hiện có. Chưa làm service/controller/JSP.
- [x] Maven `package` thành công; Spring Boot khởi động trên SQL Server với `ddl-auto=validate` và nhận đủ 10 repository, sau đó đã dừng ứng dụng kiểm tra.
- [x] Commit `bd7fb40` và push nhánh `codex/course-data-mapping` lên `origin`; commit chỉ gồm `SQLQuery1.sql` và tám file Entity/Repository. `docs.md`, `docs/`, `compose.yaml`, `scripts/`, `.DS_Store`, README và `.gitignore` không được đưa vào commit.
- [x] Theo yêu cầu tiếp theo, fast-forward `origin/main` từ `0bfd0e1` lên `bd7fb40` và cập nhật nhánh `main` cục bộ tới cùng commit. Không push các file cục bộ ngoài commit.


### Ngày 05/10/2026: Hoàn thiện script SQL Server dùng chung

- [x] Xuất ERD tĩnh kiểu bảng SSMS tại `docs/database-diagram/`: toàn bộ 44 bảng/366 cột/88 FK, ảnh SVG/PNG và file draw.io chỉnh sửa được, kèm sơ đồ chi tiết khóa học. Đã đối chiếu số bảng/cột/quan hệ và kiểm tra ảnh; không thay đổi database.
- [x] Đối chiếu schema với báo cáo Team2 UC01–UC50 và sáu entity Authentication đang dùng.
- [x] Thay `SQLQuery1.sql` bằng một script khởi tạo hợp nhất: 44 bảng (33 cốt lõi, 11 mở rộng), khóa/ràng buộc/index, seed ba role theo tên, không xóa dữ liệu ứng dụng.
- [x] Script chạy lặp, tạo phần còn thiếu trên schema auth cũ; kiểm tra cấu trúc cột/khóa/FK và sự hiện diện của CHECK/DEFAULT, rollback khi không tương thích. Đây không phải engine migration cho mọi thay đổi tùy ý.
- [x] Sửa `scripts/init-db.sh` để luôn chạy script đầy đủ, không bỏ qua database đã có sáu bảng; cập nhật README, `docs/DATABASE.md` và quy tắc tích hợp schema trong kế hoạch năm người.
- [x] Kiểm thử trên database tạm mới và bản sao có dữ liệu của schema cũ, chạy lặp thành công; đối chiếu `EXCEPT` hai chiều xác nhận sáu bảng auth giữ nguyên dữ liệu. Kiểm thử luồng hợp lệ xuyên phân hệ và 15 thao tác sai bị ràng buộc chặn đúng; fixture rollback.
- [x] Schema sai độ dài cột bị từ chối, phần thêm bảng rollback và bản ghi cũ được giữ nguyên. WAR hiện có chạy Java 17 với `ddl-auto=validate` trên schema đầy đủ, trang chủ/đăng nhập trả HTTP 200.
- **Phạm vi:** Không sửa code Java chức năng và không áp dụng schema mới vào database chính; `EduSphere` vẫn có sáu bảng cho đến khi chạy `./scripts/init-db.sh`. Xóa các database tạm do lần kiểm thử tạo ra sau xác minh.

### Ngày 01/10/2026: Pull và rà soát mã nguồn từ remote
- [x] Fast-forward `main` từ `83c444f` lên `0bfd0e1` (2 commit: `a8fb027`, `0bfd0e1`), giữ nguyên các tài liệu cục bộ chưa track.
- [x] Remote đã thêm mã Authentication: đăng ký/xác minh OTP, đăng nhập/đăng xuất, Google OAuth2, quên/đổi mật khẩu, hồ sơ/avatar, cấu hình phân quyền cơ bản và SQL schema cho tài khoản.
- [ ] Chưa có UC07 gán role và UC08 khóa/mở tài khoản dạng luồng quản trị; chưa có test hoặc cấu hình mẫu `application.properties` trong repository.
- **Sai khác tech stack lúc pull:** Mã được pull dùng Spring Boot, Spring Security, Spring Data JPA/Hibernate, JSP và SQL Server, khác lựa chọn Java Servlet/JSP + JDBC ngày 30/09. Nhóm sau đó đã quyết định tiếp tục dùng Spring Boot (ghi bên dưới).
- **Giới hạn xác minh:** Chưa build/chạy được tại máy này vì chưa có Java Runtime và Maven.
- [x] Nhóm quyết định tiếp tục dùng Spring Boot hiện có. Đã cập nhật `docs/PHAN_CONG_5_NGUOI.md` theo Java 17, Spring Boot 3.3.4, Spring MVC/Security/Data JPA, JSP và SQL Server; ưu tiên hoàn thiện Authentication trước.
- [x] Viết lại toàn bộ `docs/PHAN_CONG_5_NGUOI.md`: phân biệt code auth đã có với phần chưa nghiệm thu, nêu mốc phụ thuộc, việc và tiêu chí bàn giao của từng người theo Spring MVC + JSP.


### Ngày 30/09/2026: Phân công triển khai cho 5 người
- [x] Đọc tài liệu hiện có `docs/Du_An_Ho_Tro_Hoc_Tap_Truc_Tuyen_Bao_Cao_Team2.docx` và lập `docs/PHAN_CONG_5_NGUOI.md`.
- [x] Chia 50 Use Case cho 5 người; chọn Authentication/RBAC (UC01–UC08) làm mốc triển khai đầu tiên, các phần mở rộng UC45–UC50 để sau phạm vi cốt lõi.
- [x] Ban đầu đề xuất stack TypeScript/Next.js/NestJS/PostgreSQL theo scaffold cũ, sau đó nhóm chọn lại: Java Servlet/JSP, HTML/CSS, JDBC và Microsoft SQL Server. Dùng Maven/Tomcat để build/chạy ứng dụng; không dùng Spring/Hibernate. Repository hiện chưa có ứng dụng chạy.
- [ ] Điền tên người phụ trách thực tế vào kế hoạch và bắt đầu bàn giao Authentication.
- **Lưu ý:** Tên file đặc tả cũ `docs/EduSphere_Bao_Cao_Hieu_Chinh.docx` trong nhật ký không còn khớp với file đang có trong `docs`.


### Ngày 21/09/2026: Khởi tạo dự án & Hoàn thành Scaffolding Phase 1

#### 2.1. Phân tích tài liệu & Lập kế hoạch (Lead & Researcher)
- [x] Đọc và giải mã toàn bộ tài liệu đặc tả `docs/EduSphere_Bao_Cao_Hieu_Chinh.docx`.
- [x] Chuẩn hóa danh mục 50 Use Cases (UC01 - UC50) thuộc 6 phân hệ cốt lõi và 1 phân hệ mở rộng.
- [x] Xây dựng bản **Kế hoạch triển khai tổng thể (Master Implementation Plan)** chia làm 5 giai đoạn:
  - Phase 1: Hạ tầng, Scaffolding & Phân hệ Account/Auth RBAC (UC01 - UC08).
  - Phase 2: Quản lý Khóa học, Bài học & Quy trình duyệt (UC09 - UC23).
  - Phase 3: Đánh giá (Assignment/Quiz) & Lập kế hoạch cá nhân (UC24 - UC39) [TRỌNG TÂM].
  - Phase 4: Diễn đàn Q&A, Thảo luận & Thông báo (UC40 - UC44).
  - Phase 5: Mở rộng dịch vụ (Thanh toán, Chứng chỉ, Nhóm, Video lớn, AI) (UC45 - UC50).

#### 2.2. Thiết kế Kỹ thuật chi tiết (Researcher)
- [x] **Prisma Schema (PostgreSQL):**
  - Hoàn thiện toàn bộ models cho Phase 1: `User`, `Profile`, `Role`, `UserRole`, `RefreshToken`, `PasswordResetToken`, `EmailVerificationToken`.
  - Thiết lập sẵn cấu trúc quan hệ cho Phase 2: `Category`, `Course`, `Lesson`, `Material`, `Enrollment`.
  - Đầy đủ Enums: `UserStatus`, `RoleName`, `CourseStatus`, `MaterialType`, `EnrollmentStatus`.
- [x] **Đặc tả RESTful API (UC01 - UC08):**
  - Chi tiết 8 endpoints phân hệ Account & Access (Register, Login, Logout, Profile, Change Password, Forgot/Reset Password, Assign Role, Suspend/Restore Account).
  - Đầy đủ HTTP method, Request DTO validations, Response format chuẩn, Error codes và RBAC Guards.

#### 2.3. Khởi tạo Khung dự án & Hạ tầng Docker (Builder)
- [x] **Cấu trúc Monorepo:**
  - `package.json` ở root quản lý npm workspaces (`apps/*`, `packages/*`).
  - `.gitignore` chuẩn cho Node, Docker, Next.js, NestJS, env files.
- [x] **Hạ tầng Docker (`docker-compose.yml`):**
  - Đã khởi chạy và cả 3 containers đều đạt trạng thái `healthy`:
    - `edusphere-postgres`: PostgreSQL 16 Alpine, port host `5433` (tránh xung đột 5432).
    - `edusphere-redis`: Redis 7 Alpine, port host `6380` (tránh xung đột 6379).
    - `edusphere-minio`: MinIO S3-compatible, API port `9000`, Console port `9001`.
  - Cấu hình file môi trường `.env` và `.env.example` hoàn chỉnh.
- [x] **Backend (`apps/api`):**
  - Khung ứng dụng NestJS + TypeScript.
  - Tích hợp Prisma ORM, đã kết nối và chạy `prisma db push` đồng bộ schema vào PostgreSQL thành công.
  - Cấu hình Swagger/OpenAPI (`/api/docs`), CORS, `cookie-parser`, `ValidationPipe`.
  - Build kiểm tra thành công.
- [x] **Frontend (`apps/web`):**
  - Khung ứng dụng Next.js 16 (App Router, TypeScript, Turbopack).
  - Tích hợp Tailwind CSS v4, Lucide Icons, Shadcn UI cơ bản (`cn()` utility, Button, Card).
  - Giao diện Landing page EduSphere preview giới thiệu hệ thống.
  - Build kiểm tra thành công 100%.

---

## 3. TRẠNG THÁI HIỆN TẠI & BƯỚC TIẾP THEO

- **Trạng thái:** Repository có ứng dụng Spring Boot 3.3.4/Java 17/JSP, code Authentication, cấu hình Docker SQL Server và script schema hợp nhất. Tài liệu báo cáo hiện có là `docs/Du_An_Ho_Tro_Hoc_Tap_Truc_Tuyen_Bao_Cao_Team2.docx`; các mục ngày 21/09 ghi lại scaffold lịch sử, không phải stack hiện tại.
- **Giai đoạn hiện tại:** Hoàn thiện Authentication và triển khai các phân hệ theo kế hoạch năm người.
- **Hạng mục đã hoàn thành:**
  - [x] Script SQL Server đủ các nhóm dữ liệu UC01–UC50, chạy lại trên schema sáu bảng auth không mất dữ liệu; xem `docs/DATABASE.md` để biết giới hạn và quy tắc service còn phải viết.
- **Hạng mục tiếp theo:**
  1. Chạy script schema lên database làm việc khi nhóm sẵn sàng, giữ `ddl-auto=validate`; thống nhất người tích hợp thay đổi file SQL chung.
  2. Hoàn thiện và kiểm thử các luồng auth/quyền còn thiếu, rồi viết entity/service/controller/JSP cho UC09–UC44. Các bảng mở rộng có sẵn không có nghĩa là UC45–UC50 đã được triển khai.
