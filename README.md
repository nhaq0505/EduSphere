# EduSphere

## Thanh toán khóa học bằng PayOS

Khóa học miễn phí vẫn ghi danh trực tiếp. Với khóa học có phí, học viên được chuyển sang trang thanh toán PayOS. Quyền học chỉ được cấp sau khi hệ thống xác minh webhook PayOS hoặc kiểm tra trạng thái đơn hàng trực tiếp từ PayOS khi học viên quay lại. Tham số trên URL quay lại không tự cấp quyền học.

1. Với cơ sở dữ liệu SQL Server đã tồn tại, chạy `payos-migration.sql` để thêm cột lưu link thanh toán. Cơ sở dữ liệu mới tạo bằng `SQLQuery1.sql` đã có cột này.
2. Đặt các biến môi trường `PAYOS_CLIENT_ID`, `PAYOS_API_KEY`, `PAYOS_CHECKSUM_KEY` từ kênh thanh toán PayOS. Không đưa các khóa này vào Git.
3. Đặt `app.base-url` thành URL HTTPS công khai của ứng dụng (bao gồm context path `/EduSphere`). Cấu hình webhook của kênh PayOS tới `<app.base-url>/payments/payos/webhook`.
4. Khởi động ứng dụng và thử thanh toán trên môi trường PayOS phù hợp. `localhost` không thể nhận webhook từ PayOS; để thử webhook cần một URL công khai.

Ứng dụng sẽ báo chưa cấu hình PayOS nếu thiếu khóa. Nút thanh toán không cấp quyền học khi link thanh toán lỗi, bị hủy hoặc chưa được xác nhận. Tài liệu tích hợp: [payOS Java SDK](https://payos.vn/docs/sdks/back-end/java/) và [webhook](https://payos.vn/docs/du-lieu-tra-ve/webhook/).
