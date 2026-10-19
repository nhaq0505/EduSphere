# Tài liệu endpoint backend EduSphere

Cập nhật ngày **18/10/2026**, đối chiếu trực tiếp mã nguồn trong `src/main/java/com/edusphere`. Tài liệu mô tả endpoint đã triển khai trong controller và Spring Security; không suy ra chức năng từ các bảng database hoặc kế hoạch use case.

## 1. Quy ước gọi endpoint

- Backend dùng **Spring MVC + JSP**. Kết quả là trang HTML hoặc chuyển hướng, chưa có hợp đồng REST JSON cho các chức năng bên dưới.
- URL trong tài liệu là đường dẫn tương đối với context path. Ví dụ local theo README: `http://localhost:8080/EduSphere`; `GET /courses` tương ứng `http://localhost:8080/EduSphere/courses`. Điều chỉnh base URL theo cấu hình triển khai.
- `GET`: nhận query parameter. `POST`: nhận form `application/x-www-form-urlencoded`, riêng avatar dùng `multipart/form-data`. Không gửi JSON cho các form này.
- Xác thực bằng session, cookie `JSESSIONID`; không dùng Bearer/JWT. Các bước OTP phải giữ cùng session.
- CSRF đang bật. Mọi POST cần token của session, thường gửi bằng trường `_csrf` lấy từ form HTML. Token có thể thay đổi sau đăng nhập; lấy lại từ trang sau khi đăng nhập.
- `{id}`, `{courseId}`, `{lessonId}` là số nguyên. Danh sách phân trang dùng `page` bắt đầu từ **0**.
- Tên view như `courses/list` tương ứng JSP `/WEB-INF/views/courses/list.jsp`. Các thuộc tính model mô tả dữ liệu server đưa vào JSP, **không phải JSON response**.
- “Chuyển hướng” bên dưới thường là HTTP **302**; render trang thành công/lỗi validation thường là **200** nếu controller không đặt mã khác.

### Quyền truy cập

| Ký hiệu | Điều kiện |
| --- | --- |
| Công khai | Không cần đăng nhập; POST vẫn cần CSRF |
| Đăng nhập | Có session xác thực hợp lệ |
| STUDENT | Có authority `ROLE_STUDENT` |
| INSTRUCTOR | Có authority `ROLE_INSTRUCTOR` |
| ADMINISTRATOR | Có authority `ROLE_ADMINISTRATOR` |

Một tài khoản có thể có nhiều vai trò. Quyền ADMINISTRATOR không tự động bao gồm INSTRUCTOR hoặc STUDENT. Các endpoint quản lý khóa học/bài học của giảng viên còn kiểm tra quyền sở hữu khóa học.

## 2. Trang chung và xác thực

Nguồn: `HomeController`, `AuthController`, `SecurityConfig`, `RoleAwareAuthenticationSuccessHandler`, `RoleLandingPage`.

| Method | Endpoint | Quyền | Đầu vào | Kết quả |
| --- | --- | --- | --- | --- |
| GET | `/` | Công khai | Không | Khách: view `index`. Đã đăng nhập: chuyển đến trang theo vai trò |
| GET | `/dashboard` | Đăng nhập | Không | View `dashboard` |
| GET | `/login` | Công khai | Query tùy chọn: `error`, `logout`, `oauth2Error`, `courseId` | View `auth/login`; nếu đã đăng nhập và không có `error`/`logout`, chuyển `/` |
| POST | `/login` | Công khai | `username` = email, `password` | Spring Security xử lý đăng nhập; thành công chuyển trang, thất bại chuyển `/login?error=...` |
| POST | `/logout` | Công khai | CSRF | Hủy session, xóa cookie `JSESSIONID`, chuyển `/login?logout` |
| GET | `/register` | Công khai | Không | View `auth/register`, model `registerRequest`; đã đăng nhập thì chuyển `/` |
| POST | `/register` | Công khai | Form đăng ký bên dưới | Tạo/cập nhật tài khoản PENDING, gửi OTP, chuyển `/verify-otp`; lỗi trả `auth/register` |
| GET | `/verify-otp` | Công khai + session đăng ký | Không | View `auth/verify-otp`, model `maskedEmail`; thiếu email trong session thì chuyển `/register` |
| POST | `/verify-otp` | Công khai + session đăng ký | `otp` bắt buộc | Kích hoạt tài khoản, xóa email chờ xác minh, chuyển `/login`; sai OTP trả lại trang OTP |
| POST | `/resend-otp` | Công khai + session đăng ký | CSRF | Xóa OTP cũ, gửi OTP mới, chuyển `/verify-otp`; thiếu session chuyển `/register` |
| GET | `/oauth2/authorization/google` | Luồng OAuth2 | Không | Spring Security khởi tạo đăng nhập Google nếu client Google được cấu hình |
| GET | `/login/oauth2/code/google` | Luồng OAuth2 | Callback do Google gửi, gồm `code`/`state` hoặc lỗi | Spring Security xử lý callback; lỗi chuyển `/login?oauth2Error=true` |

Hai đường dẫn Google do filter OAuth2 của Spring Security cung cấp, không có phương thức controller riêng. Callback URL thực tế phụ thuộc cấu hình OAuth2/deployment; không gọi thủ công thay cho luồng Google.

### Form đăng ký

| Trường | Bắt buộc | Kiểm tra |
| --- | --- | --- |
| `fullName` | Có | Không trắng, tối đa 100 ký tự; trim khi lưu |
| `email` | Có | Đúng định dạng email, tối đa 255 ký tự; chuyển chữ thường và trim |
| `password` | Có | 8–100 ký tự, không trắng |
| `confirmPassword` | Có | Không trắng và trùng `password` |
| `phone` | Không | Để trống hoặc 9–15 chữ số, có thể bắt đầu bằng `+` |

Tài khoản mới được gán STUDENT, trạng thái PENDING; xác minh OTP thành công chuyển ACTIVE. Email đã tồn tại ở trạng thái PENDING được cập nhật thông tin đăng ký và thay OTP; email ở trạng thái khác bị từ chối. OTP gồm 6 chữ số, hết hạn sau **10 phút**, kiểm tra thuộc đúng tài khoản và chưa dùng. Session lưu email bằng khóa `pendingRegisterEmail`; không truyền email tùy ý vào endpoint xác minh/gửi lại OTP.

### Chuyển hướng sau đăng nhập

Spring Security ưu tiên request được lưu trước đó nếu có. Khi xác định trang đích mặc định, handler ưu tiên `postLoginCourseId` đã lưu từ `GET /login?courseId=...`, sau đó chọn ADMINISTRATOR → `/admin/courses/review`, INSTRUCTOR → `/instructor/courses`, STUDENT → `/courses`; mặc định `/courses`. `postLoginCourseId` được xóa sau khi xử lý thành công. `courseId` không tự động ghi danh.

Các giá trị `error` hiện dùng: `notVerified`, `locked`, `permissionsChanged`, `badCredentials`; các giá trị khác hiển thị lỗi đăng nhập chung. `logout` và `oauth2Error` được xét theo sự hiện diện của query parameter.

## 3. Quên mật khẩu và đổi mật khẩu

Nguồn: `PasswordController`, `PasswordResetService`, `ProfileService`.

| Method | Endpoint | Quyền | Đầu vào | Kết quả |
| --- | --- | --- | --- | --- |
| GET | `/forgot-password` | Công khai | Không | View `auth/forgot-password`, model `forgotPasswordRequest` |
| POST | `/forgot-password` | Công khai | `email`: bắt buộc, không trắng, đúng định dạng | Lưu email vào session, chuyển `/forgot-password/verify-otp`; validation lỗi trả trang nhập email |
| GET | `/forgot-password/verify-otp` | Công khai + session reset | Không | View `auth/forgot-password-otp`, model `maskedEmail`; thiếu email chuyển `/forgot-password` |
| POST | `/forgot-password/verify-otp` | Công khai + session reset | `otp` bắt buộc | Đúng OTP: đánh dấu session đã xác minh, chuyển `/reset-password`; lỗi trả trang OTP |
| POST | `/forgot-password/resend-otp` | Công khai + session reset | CSRF | Gửi lại OTP, chuyển trang OTP; thiếu email chuyển `/forgot-password` |
| GET | `/reset-password` | Công khai + session đã xác minh OTP | Không | View `auth/reset-password`; chưa xác minh chuyển `/forgot-password` |
| POST | `/reset-password` | Công khai + session đã xác minh OTP | `newPassword`, `confirmPassword` bắt buộc | Đổi mật khẩu, đánh dấu token đã dùng, xóa dữ liệu reset trong session, chuyển `/login`; lỗi trả trang reset |
| GET | `/change-password` | Đăng nhập | Không | View `auth/change-password`, model `changePasswordRequest` |
| POST | `/change-password` | Đăng nhập | `currentPassword`, `newPassword`, `confirmPassword` | Thành công chuyển `/profile`; lỗi trả `auth/change-password` |

- Chỉ gửi OTP reset cho tài khoản ACTIVE; bước gửi email vẫn chuyển sang trang OTP nếu email không tồn tại hoặc tài khoản không ACTIVE.
- OTP reset gồm 6 chữ số, hiệu lực 10 phút. Gửi lại xóa token cũ. Xác minh kiểm tra OTP đúng tài khoản, chưa dùng và chưa hết hạn.
- Các khóa session là `resetPasswordEmail`, `resetOtpVerified`. Bước lưu mật khẩu yêu cầu còn token chưa dùng/chưa hết hạn của tài khoản.
- `POST /reset-password` thực tế nhận hai `@RequestParam`: chỉ kiểm tra độ dài tối thiểu 8 và xác nhận trùng nhau; **không áp dụng** giới hạn 100 ký tự hoặc trường `token` của DTO `ResetPasswordRequest`.
- Đổi mật khẩu khi đăng nhập: cả ba trường không trắng, mật khẩu mới 8–100 ký tự, mật khẩu hiện tại phải đúng, xác nhận phải khớp. Tài khoản Google chưa có `passwordHash` bị từ chối ở chức năng đổi mật khẩu này.

Luồng reset: nhập email → xác minh OTP → đặt mật khẩu → đăng nhập lại. Giữ cookie session xuyên suốt luồng.

## 4. Hồ sơ cá nhân

Nguồn: `ProfileController`, `ProfileService`.

| Method | Endpoint | Quyền | Đầu vào | Kết quả |
| --- | --- | --- | --- | --- |
| GET | `/profile` | Đăng nhập | Không | View `profile/profile`; model `user`, `roleNames` |
| GET | `/profile/edit` | Đăng nhập | Không | View `profile/edit`; model `updateProfileRequest`, `user` |
| POST | `/profile/edit` | Đăng nhập | `fullName`, `phone` | Thành công chuyển `/profile`; validation/nghiệp vụ lỗi trả trang chỉnh sửa |
| POST | `/profile/avatar` | Đăng nhập | Multipart `avatarFile` bắt buộc | Thành công hoặc lỗi nghiệp vụ đều chuyển `/profile`, kèm flash message |

`fullName` không trắng, tối đa 100 ký tự. `phone` dùng cùng quy tắc với đăng ký. Endpoint chỉnh sửa chỉ cập nhật tên và điện thoại của người đang đăng nhập.

Avatar phải có dữ liệu, dung lượng tối đa **2 MiB (2 × 1024 × 1024 byte)**. Service kiểm tra MIME khai báo thuộc `image/jpeg`, `image/jpg`, `image/png`, `image/gif`, `image/webp`. File lưu ở `app.upload.dir`, URL trong hồ sơ có dạng `{contextPath}/uploads/avatars/{filename}`. Giới hạn multipart cấp server có thể từ chối request trước khi vào service.

## 5. Quản trị tài khoản

Nguồn: `AdminAccountController`, `AdminAccountService`. Tất cả endpoint yêu cầu ADMINISTRATOR.

| Method | Endpoint | Đầu vào | Kết quả |
| --- | --- | --- | --- |
| GET | `/admin/users` | Query `q` mặc định rỗng; `page` mặc định 0 | View `admin/users`; model `usersPage`, `q`; 20 tài khoản/trang, mới tạo trước, page âm được đổi về 0 |
| POST | `/admin/users/{id}/roles` | Danh sách `roles`, ví dụ `roles=STUDENT&roles=INSTRUCTOR` | Thay toàn bộ tập vai trò, ghi sự kiện cấp/thu hồi; chuyển `/admin/users` kèm flash `success` hoặc `error` |
| POST | `/admin/users/{id}/status` | `action` bắt buộc; `reason` tùy điều kiện | Khóa/khôi phục tài khoản, ghi sự kiện; chuyển `/admin/users` kèm flash `success` hoặc `error` |

- `roles` chỉ nhận STUDENT, INSTRUCTOR, ADMINISTRATOR, phải có ít nhất một vai trò. Không gửi trường này vẫn vào controller nhưng bị service từ chối.
- `action=LOCK`: chỉ từ ACTIVE → LOCKED, phải có `reason` sau trim.
- `action=RESTORE`: chỉ từ LOCKED → ACTIVE, lý do có thể để trống.
- `reason` tối đa 1000 ký tự. Không cho sửa vai trò hoặc khóa/khôi phục chính mình. ID không tồn tại trả thông báo lỗi qua redirect.
- `AccountStateFilter` kiểm tra lại trạng thái và tập vai trò trên các request có principal `CustomUserDetails`. Khi tài khoản không còn ACTIVE hoặc vai trò thay đổi, session bị hủy, chuyển `/login?error=locked` hoặc `/login?error=permissionsChanged`.

## 6. Khám phá khóa học

Nguồn: `CourseDiscoveryController`, `CourseDiscoveryService`. Hai endpoint công khai.

| Method | Endpoint | Đầu vào | Kết quả |
| --- | --- | --- | --- |
| GET | `/courses` | Các query bên dưới | View `courses/list`; model `coursePage`, `categories`, `q`, `categoryId`, `level`, `priceFilter` |
| GET | `/courses/{courseId}` | ID khóa học | View `courses/detail`; model `course`, `lessonTitles`, `student`, `enrolled`; không tìm thấy khóa PUBLISHED trả **404**, view `courses/not-found` |

| Query của `/courses` | Mặc định | Xử lý |
| --- | --- | --- |
| `q` | Rỗng | Tìm theo tên khóa học, bỏ khoảng trắng đầu/cuối, tìm không phân biệt hoa thường |
| `categoryId` | Không có | Lọc ID danh mục |
| `level` | Rỗng | Lọc giá trị trình độ sau trim/chuyển hoa; giá trị lạ không được báo validation riêng |
| `priceFilter` | Rỗng | FREE = giá 0; PAID = giá > 0; giá trị khác không áp dụng lọc giá |
| `page` | 0 | Page âm đổi thành 0; 12 khóa/trang |

Chỉ tìm khóa PUBLISHED; sắp xếp `publishedAt` giảm dần, sau đó `courseId` giảm dần. Danh mục hiển thị là danh mục ACTIVE, tên tăng dần. Chi tiết công khai chỉ liệt kê tên bài PUBLISHED. `enrolled=true` khi người xem có STUDENT và đã ghi danh với trạng thái khác DROPPED.

## 7. Ghi danh và khóa học của học viên

Nguồn: `CourseManagementController`, `CourseManagementService`. Yêu cầu STUDENT.

| Method | Endpoint | Đầu vào | Kết quả |
| --- | --- | --- | --- |
| POST | `/courses/{courseId}/enroll` | ID khóa học; CSRF | Tạo ghi danh ACTIVE hoặc kích hoạt lại bản ghi DROPPED; chuyển `/my-courses`, flash `success` |
| GET | `/my-courses` | Không | View `courses/my-courses`, model `courses`; sắp xếp theo thời điểm ghi danh giảm dần |

Khóa học phải PUBLISHED, nếu không trả 404. Ghi danh đã tồn tại với trạng thái khác DROPPED trả 409. Danh sách `/my-courses` hiện lấy mọi trạng thái ghi danh của học viên, không có phân trang.

**Hành vi hiện tại:** ghi danh được cả khóa miễn phí và khóa có học phí; service chưa kiểm tra thanh toán. Chưa có endpoint hủy ghi danh dù service có xử lý trường hợp bản ghi DROPPED sẵn có.

## 8. Giảng viên quản lý khóa học

Nguồn: `CourseManagementController`, `CourseManagementService`. Yêu cầu INSTRUCTOR; mọi thao tác trên khóa đã có đều kiểm tra khóa thuộc giảng viên hiện tại.

| Method | Endpoint | Đầu vào | Kết quả thành công |
| --- | --- | --- | --- |
| GET | `/instructor/courses` | Không | View `courses/instructor-list`, model `courses`, mới tạo trước |
| GET | `/instructor/courses/new` | Không | View `courses/form`; model `courseForm`, `categories`, `formAction` |
| POST | `/instructor/courses` | CourseForm | Tạo khóa DRAFT, phiên bản 1, tiền tệ mặc định VND; chuyển `/instructor/courses/{id}` |
| GET | `/instructor/courses/{id}` | ID khóa | View `courses/instructor-detail`, model `course` |
| GET | `/instructor/courses/{id}/edit` | ID khóa | View `courses/form`, dữ liệu form hiện tại; chỉ DRAFT/REJECTED |
| POST | `/instructor/courses/{id}` | CourseForm | Lưu, tăng phiên bản, đưa về DRAFT, xóa mốc gửi/phê duyệt; chuyển trang chi tiết |
| POST | `/instructor/courses/{id}/submit` | CSRF | DRAFT/REJECTED → SUBMITTED; cần mô tả không trắng; chuyển trang chi tiết |
| POST | `/instructor/courses/{id}/publish` | CSRF | APPROVED và có `approvedAt` → PUBLISHED; đồng thời công bố các bài DRAFT; chuyển trang chi tiết |
| POST | `/instructor/courses/{id}/archive` | CSRF | PUBLISHED → ARCHIVED; chuyển trang chi tiết |

### CourseForm

| Trường | Bắt buộc/giá trị mặc định | Kiểm tra |
| --- | --- | --- |
| `title` | Bắt buộc | Không trắng, tối đa 255 ký tự; trim khi lưu |
| `description` | Tùy chọn lúc tạo/sửa | Trim; phải có nội dung khi gửi duyệt |
| `categoryId` | Tùy chọn | Nếu gửi phải là ID danh mục ACTIVE |
| `level` | Mặc định ALL_LEVELS nếu bỏ trường | Chỉ ALL_LEVELS, BEGINNER, INTERMEDIATE, ADVANCED; có phân biệt hoa thường |
| `price` | Mặc định 0 nếu bỏ trường | Không null/âm, tối đa 2 chữ số thập phân, precision không quá 18 |

Lỗi Bean Validation khi tạo/sửa trả lại `courses/form` cùng danh mục và action. Lỗi kiểm tra service như sai trạng thái, danh mục, trình độ, giá trả 409 qua `courses/action-error`. Không có quyền sở hữu hoặc ID không tồn tại trả 404.

Luồng trạng thái khóa học:

```text
DRAFT → submit → SUBMITTED → review APPROVED → APPROVED → publish → PUBLISHED → archive → ARCHIVED
                         └→ review REJECTED → REJECTED → edit → DRAFT
                                                     └→ submit → SUBMITTED
```

Chỉnh thông tin khóa học chỉ được ở DRAFT/REJECTED. Quy tắc chỉnh bài học ở mục 10 cho phép thêm một số trạng thái khác.

## 9. Quản trị viên duyệt khóa học

Nguồn: `CourseManagementController`, `CourseManagementService`. Yêu cầu ADMINISTRATOR.

| Method | Endpoint | Đầu vào | Kết quả |
| --- | --- | --- | --- |
| GET | `/admin/courses/review` | Không | View `admin/course-review`, model `courses`: khóa SUBMITTED, gửi duyệt trước đứng trước |
| POST | `/admin/courses/{id}/review` | `decision` bắt buộc; `comment` tùy điều kiện | Ghi quyết định gắn với phiên bản khóa, chuyển `/admin/courses/review`, flash `success` |

`decision` chỉ nhận APPROVED hoặc REJECTED. REJECTED bắt buộc nhận xét sau trim; nhận xét tối đa 2000 ký tự. Khóa phải SUBMITTED; sai quyết định, thiếu lý do hoặc sai trạng thái trả 409; khóa không tồn tại trả 404. Phê duyệt chỉ đưa về APPROVED, giảng viên cần gọi publish để công bố.

## 10. Giảng viên quản lý bài học và tài liệu

Nguồn: `LessonManagementController`, `LessonManagementService`. Yêu cầu INSTRUCTOR và sở hữu khóa. Trong bảng, tiền tố **L = `/instructor/courses/{courseId}/lessons`**.

| Method | Endpoint | Đầu vào | Kết quả thành công |
| --- | --- | --- | --- |
| GET | `L` | ID khóa | View `courses/instructor-lessons`; model `course`, `lessons`, `editable` |
| GET | `L/new` | ID khóa | View `courses/lesson-form`; model `lessonForm`, `courseId`, `formAction` |
| POST | `L` | LessonForm | Tạo bài, chuyển `L/{lessonId}` |
| GET | `L/{lessonId}` | ID khóa/bài | View `courses/instructor-lesson-detail`; model `course`, `lesson`, `materials`, `materialForm`, `editable` |
| GET | `L/{lessonId}/edit` | ID khóa/bài | View `courses/lesson-form`; thêm `lessonId`, `maxOrder` và form hiện tại |
| POST | `L/{lessonId}/edit` | LessonForm | Lưu tên/nội dung/thứ tự, chuyển `L/{lessonId}` |
| POST | `L/{lessonId}/materials` | MaterialForm | Thêm đường dẫn tài liệu cuối danh sách, chuyển `L/{lessonId}` |

`L` là ký hiệu rút gọn trong tài liệu, không phải URL thực tế. Ví dụ POST tạo bài: `/instructor/courses/10/lessons`.

### LessonForm

| Trường | Bắt buộc | Kiểm tra/hành vi |
| --- | --- | --- |
| `title` | Có | Không trắng, tối đa 255 ký tự; trim |
| `content` | Không | Chuỗi trắng chuyển thành null; trim nội dung |
| `orderIndex` | Không | Nếu gửi phải ≥ 1. Tạo mới luôn nối cuối, không dùng thứ tự gửi lên; sửa cho phép 1…tổng số bài, bỏ trường thì giữ thứ tự cũ |

Cho tạo/sửa bài và thêm tài liệu khi khóa DRAFT, REJECTED, APPROVED hoặc PUBLISHED; SUBMITTED/ARCHIVED trả 409. Bài được tạo/sửa trong khóa PUBLISHED mang trạng thái PUBLISHED; ở các trạng thái được phép khác mang DRAFT. Thêm bài vào khóa PUBLISHED chuyển các ghi danh COMPLETED về ACTIVE và xóa `completedAt`. Đổi vị trí bài sẽ sắp xếp lại các bài liên quan.

### MaterialForm

| Trường | Bắt buộc | Kiểm tra |
| --- | --- | --- |
| `title` | Có | Không trắng, tối đa 255 ký tự |
| `type` | Có | DOCUMENT, LINK hoặc VIDEO |
| `fileUrl` | Có | Tối đa 2048 ký tự; URL HTTP/HTTPS hợp lệ, có host, không chứa user info, không có khoảng trắng theo validation form |

Tài liệu được thêm bằng URL; endpoint này không nhận file upload. Lỗi validation trả lại trang form bài học hoặc trang chi tiết tài liệu; lỗi service trả 404/409 qua `courses/action-error`. Bài không thuộc khóa trong URL trả 404. Chưa có endpoint xóa bài, sửa/xóa tài liệu hoặc công bố riêng từng bài.

## 11. Học bài và hoàn thành bài

Nguồn: `LessonStudyController`, `LearningService`. Yêu cầu STUDENT ở cả URL security và `@PreAuthorize`; phải có ghi danh khác DROPPED.

| Method | Endpoint | Đầu vào | Kết quả |
| --- | --- | --- | --- |
| GET | `/courses/{courseId}/learn` | ID khóa | Chuyển đến bài PUBLISHED đầu tiên chưa hoàn thành; nếu đã hoàn thành hết thì bài đầu tiên. Không có bài PUBLISHED: render `courses/study` với danh sách rỗng |
| GET | `/courses/{courseId}/lessons/{lessonId}` | ID khóa/bài | View `courses/study`; model `study` và `studyContext` cùng chứa StudyCourseView |
| POST | `/courses/{courseId}/lessons/{lessonId}/complete` | ID khóa/bài; CSRF | Lưu hoàn thành nếu chưa có; chuyển bài kế tiếp theo thứ tự; ở cuối danh sách chuyển lại bài hiện tại và thêm flash `courseCompleted=true` |

- Chưa ghi danh hoặc ghi danh DROPPED: 403. Bài không tồn tại/không PUBLISHED/không thuộc khóa: 404 ở thao tác hoàn thành và khi chọn bài trong danh sách không rỗng. Hiện GET chọn bài khi khóa không có bài PUBLISHED trả trang học rỗng trước khi kiểm tra `lessonId`.
- Service hiện kiểm tra trạng thái ghi danh và trạng thái bài; không kiểm tra khóa phải còn PUBLISHED. Học viên đã ghi danh vẫn có thể học bài PUBLISHED của khóa ARCHIVED.
- Không bắt buộc hoàn thành bài trước mới được xem bài sau. Gọi complete nhiều lần không tạo lại bản ghi đã tồn tại.
- Khi số bản ghi hoàn thành đạt số bài PUBLISHED, enrollment chuyển COMPLETED và ghi thời điểm hoàn thành.
- Flash `courseCompleted=true` được controller đặt khi không có bài kế tiếp; giá trị này không phải phép kiểm tra độc lập rằng mọi bài đã hoàn thành.
- Link tài liệu hiển thị cho học viên được kiểm tra scheme HTTP/HTTPS, host và user info; URL không hợp lệ được đưa về null.

## 12. Dữ liệu phản hồi cho JSP

Các đối tượng dưới đây dùng làm model để render HTML, không có endpoint JSON riêng.

| Đối tượng | Trường chính |
| --- | --- |
| CourseView | `courseId`, `title`, `description`, `summary` (rút gọn quá 160 ký tự), `categoryName`, `instructorName`, `levelLabel`, `price`, `currency`, thuộc tính tính toán `free` |
| ManagedCourseView | `courseId`, `title`, `description`, `categoryName`, `instructorName`, `level`, `price`, `status`, `versionNo`, `latestReviewComment` |
| EnrolledCourseView | `courseId`, `title`, `instructorName`, `enrollmentStatus`, `courseStatus` |
| AdminUserView | `userId`, `fullName`, `email`, `status`, `roles`, `student`, `instructor`, `administrator`, `self` |
| StudyCourseView | `courseId`, `courseTitle`, `instructorName`, `lessons`, `currentLesson`, `lessonContent`, `materials`, `prevLessonId`, `nextLessonId`, `completedCount`, `totalCount`, `progressPercent` |
| LessonItemView | `lessonId`, `title`, `orderIndex`, `completed`, `current` |
| MaterialView | `materialId`, `title`, `type`, `fileUrl`, `originalFileName`, `sizeBytes` |

`progressPercent` là phần trăm làm tròn từ số bài PUBLISHED đã hoàn thành / tổng số bài PUBLISHED; bằng 0 khi chưa có bài. `originalFileName`, `sizeBytes` có thể null với tài liệu thêm bằng URL.

## 13. Lỗi và thông báo

| Tình huống | Hành vi hiện tại |
| --- | --- |
| Chưa đăng nhập vào URL cần xác thực | Spring Security thường chuyển `/login`, có thể lưu request đích |
| Sai vai trò hoặc CSRF thiếu/sai | Spring Security từ chối, thông thường 403 |
| Validation form | Render lại JSP, hiển thị lỗi binding/validation, thường 200 |
| Nghiệp vụ tài khoản/OTP/profile được controller bắt | Render lại form hoặc redirect kèm thông báo, không có JSON error chuẩn |
| CourseActionException trong quản lý khóa/bài/học | Đặt HTTP status từ exception, view `courses/action-error`, model `errorMessage`; các mã có trong service: 401, 403, 404, 409 |
| Chi tiết khóa công khai không tồn tại | 404, view `courses/not-found` |
| Exception đến GlobalExceptionHandler | Render `error/403`, model `errorMessage`; handler không đặt HTTP status |

Không suy ra HTTP 403 chỉ từ tên JSP `error/403`. `GlobalExceptionHandler` hiện bắt cả Exception chung mà không có `@ResponseStatus`/`setStatus`, nên lỗi binding/tham số hoặc lỗi không được controller xử lý chưa có hợp đồng HTTP 400/500 nhất quán. Khi kiểm tra bằng Postman/cURL, xem cả status, `Location` và HTML, tránh chỉ nhìn status 200 sau khi tự động theo redirect.

Tên thông báo: auth/profile/password dùng `errorMessage`, `successMessage`; quản trị tài khoản/khóa học/bài học thường dùng flash `error`, `success`. Flash chỉ được chuyển sang request kế tiếp.

## 14. Ví dụ gọi bằng cURL/Postman

Ví dụ dùng base URL local trong README. Các ID và nội dung mẫu cần thay theo dữ liệu môi trường. Token CSRF lấy thủ công từ hidden input của HTML, dùng đúng cookie session của trang đó.

```bash
# 1. Lấy trang login và lưu cookie.
curl -sS -c cookies.txt \
  'http://localhost:8080/EduSphere/login' -o login.html

# 2. Đọc token _csrf trong login.html, thay CSRF_FROM_LOGIN bên dưới.
# username là tên field thực tế dù giá trị là email.
curl -i -b cookies.txt -c cookies.txt \
  --data-urlencode '_csrf=CSRF_FROM_LOGIN' \
  --data-urlencode 'username=student@example.com' \
  --data-urlencode 'password=ExamplePassword123' \
  'http://localhost:8080/EduSphere/login'

# 3. Lấy lại token sau đăng nhập từ form ghi danh trên trang khóa học.
curl -sS -b cookies.txt -c cookies.txt \
  'http://localhost:8080/EduSphere/courses/10' -o course.html

# 4. Ghi danh bằng tài khoản có STUDENT.
curl -i -b cookies.txt -c cookies.txt \
  --data-urlencode '_csrf=CSRF_FROM_COURSE_PAGE' \
  'http://localhost:8080/EduSphere/courses/10/enroll'

# 5. Tìm khóa công khai (không cần session).
curl -i --get 'http://localhost:8080/EduSphere/courses' \
  --data-urlencode 'q=Java' \
  --data-urlencode 'level=BEGINNER' \
  --data-urlencode 'priceFilter=FREE' \
  --data-urlencode 'page=0'
```

Ví dụ tạo khóa học bằng session INSTRUCTOR và token lấy từ form `/instructor/courses/new`:

```bash
curl -i -b instructor-cookies.txt -c instructor-cookies.txt \
  --data-urlencode '_csrf=CSRF_FROM_COURSE_FORM' \
  --data-urlencode 'title=Java căn bản' \
  --data-urlencode 'description=Khóa học nhập môn Java.' \
  --data-urlencode 'level=BEGINNER' \
  --data-urlencode 'price=0' \
  'http://localhost:8080/EduSphere/instructor/courses'
```

Trong Postman: dùng cookie jar, mở GET form trước, sao chép `_csrf`, gửi POST bằng Body → `x-www-form-urlencoded`; avatar dùng `form-data` với `avatarFile` kiểu File và `_csrf` kiểu Text. Tắt tự động theo redirect khi cần kiểm tra phản hồi 302 gốc.

## 15. Phạm vi chưa triển khai và đường dẫn hạ tầng

- Chưa có controller REST `/api/**`, JWT, thanh toán, quiz/bài kiểm tra, nộp bài, diễn đàn, chứng chỉ hay báo cáo theo những bảng mở rộng trong schema.
- `/verify-email` có trong danh sách `permitAll` nhưng **không có mapping controller** hiện tại; luồng đăng ký sử dụng `/verify-otp`.
- `ResetPasswordRequest` có trường `token` nhưng không được PasswordController dùng; không có endpoint reset qua token URL trong mã hiện tại.
- Không có endpoint CRUD danh mục, xóa khóa, hủy ghi danh, xóa bài hoặc sửa/xóa tài liệu trong các controller đã rà soát.
- `/assets/**` là tài nguyên tĩnh công khai. `/uploads/avatars/**` được WebMvcConfig map tới thư mục upload nhưng không nằm trong `permitAll`, nên theo SecurityConfig hiện tại cần đăng nhập.
- `/error`, `/WEB-INF/**`, `/favicon.ico` xuất hiện trong cấu hình bảo mật/tài nguyên, không được xem là API nghiệp vụ. Khả năng truy cập tài nguyên còn tùy servlet container.

## 16. Nguồn đối chiếu và cách cập nhật

| Nội dung | Mã nguồn |
| --- | --- |
| Route và model | [Controllers](../src/main/java/com/edusphere/controller/) |
| Quyền, form login, logout, OAuth2, CSRF | [SecurityConfig](../src/main/java/com/edusphere/config/SecurityConfig.java) |
| Kiểm tra trạng thái/đổi quyền trong session | [AccountStateFilter](../src/main/java/com/edusphere/security/AccountStateFilter.java) |
| Validation đầu vào | [DTO](../src/main/java/com/edusphere/dto/) |
| Luồng và điều kiện nghiệp vụ | [Services](../src/main/java/com/edusphere/service/) |
| Xử lý lỗi chung | [GlobalExceptionHandler](../src/main/java/com/edusphere/config/GlobalExceptionHandler.java) |
| Tài nguyên avatar | [WebMvcConfig](../src/main/java/com/edusphere/config/WebMvcConfig.java) |

Khi thêm/sửa route, cập nhật đồng thời method/path, quyền trong SecurityConfig, form DTO, điều kiện service và view/redirect. Tài liệu được kiểm tra bằng đối chiếu mã nguồn; không phải biên bản kiểm thử HTTP trên môi trường đang chạy.
