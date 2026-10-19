# EduSphere — ERD dạng bảng

Xuất ngày 05/10/2026 từ `SQLQuery1.sql`. Sơ đồ tĩnh theo cách trình bày bảng
của SSMS: tên bảng, toàn bộ cột, kiểu dữ liệu, PK/FK, NULL và đường nối quan hệ.
Không thay đổi database đang chạy.

## Bản tổng thể

- `EduSphere-ERD.svg`: 44 bảng, 366 cột, 88 khóa ngoại. Dùng bản vector này để
  phóng to mà chữ không bị vỡ; mở bằng trình duyệt hoặc ứng dụng xem SVG.
- `EduSphere-ERD.png`: ảnh 6697 × 8618 pixel, dùng để xem hoặc chèn vào báo cáo.
- `EduSphere-ERD.drawio`: bản chỉnh sửa được, gồm trang tổng thể 44 bảng và trang
  chi tiết khóa học. Các bảng và từng cột là đối tượng riêng, có thể kéo bố cục.
- `EduSphere-ERD.dot`: nguồn đồ thị và các cổng nối theo cột.

## Bản chi tiết UC09–UC19

`EduSphere-Courses.svg` và `EduSphere-Courses.png` hiển thị Category, Course,
CourseReview, Enrollment, kèm User và Payment làm bảng liên kết. Mọi cột đều
hiện trực tiếp, không cần mở bảng chi tiết hoặc chọn tab.

## Ký hiệu

- `PK`: khóa chính; `FK`: cột thuộc khóa ngoại; `PK/FK`: thuộc cả hai.
- `NULL = Y`: cho phép NULL; `-`: bắt buộc có giá trị.
- Chân quạ: nhiều bản ghi; vòng tròn: quan hệ tùy chọn; vạch: một bản ghi.
- Một khóa ngoại tổng hợp được vẽ bằng một đường nối theo cặp cột đầu tiên.
  Các cột đầy đủ và tên constraint nằm trong tooltip của đường nối ở SVG/draw.io.

Đây là ERD xuất từ **schema mục tiêu trong file SQL**, không phải danh sách bảng
đã được áp dụng trên database chính. Bản `.drawio` không phải định dạng Database
Diagram gốc của SSMS; dùng công cụ tương thích draw.io để sửa hoặc xuất lại ảnh.
