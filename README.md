# EduSphere

## Thanh toán khóa học bằng PayOS

Khóa học miễn phí vẫn ghi danh trực tiếp. Với khóa học có phí, học viên được chuyển sang trang thanh toán PayOS. Quyền học chỉ được cấp sau khi hệ thống xác minh webhook PayOS hoặc kiểm tra trạng thái đơn hàng trực tiếp từ PayOS khi học viên quay lại. Tham số trên URL quay lại không tự cấp quyền học.

1. Với cơ sở dữ liệu SQL Server đã tồn tại, chạy `payos-migration.sql` để thêm cột lưu link thanh toán. Cơ sở dữ liệu mới tạo bằng `SQLQuery1.sql` đã có cột này.
2. Đặt các biến môi trường `PAYOS_CLIENT_ID`, `PAYOS_API_KEY`, `PAYOS_CHECKSUM_KEY` từ kênh thanh toán PayOS. Không đưa các khóa này vào Git.
3. Đặt `app.base-url` thành URL HTTPS công khai của ứng dụng (bao gồm context path `/EduSphere`). Cấu hình webhook của kênh PayOS tới `<app.base-url>/payments/payos/webhook`.
4. Khởi động ứng dụng và thử thanh toán trên môi trường PayOS phù hợp. `localhost` không thể nhận webhook từ PayOS; để thử webhook cần một URL công khai.

Ứng dụng sẽ báo chưa cấu hình PayOS nếu thiếu khóa. Nút thanh toán không cấp quyền học khi link thanh toán lỗi, bị hủy hoặc chưa được xác nhận. Tài liệu tích hợp: [payOS Java SDK](https://payos.vn/docs/sdks/back-end/java/) và [webhook](https://payos.vn/docs/du-lieu-tra-ve/webhook/).

## Backend endpoint documentation

Tài liệu các endpoint đã triển khai, quyền truy cập, form đầu vào, view/redirect,
luồng OTP và ví dụ cURL/Postman: [docs/BACKEND_ENDPOINTS.md](docs/BACKEND_ENDPOINTS.md).

## Local SQL Server on macOS

This project uses Java 17 and SQL Server. Run `./scripts/init-db.sh` to start
the Docker database and apply the complete `SQLQuery1.sql` schema (44 tables).
Docker maps SQL Server to `127.0.0.1:1435` and stores data in a named volume.

```sh
./scripts/init-db.sh
```

`SQLQuery1.sql` is the single canonical SQL Server setup file for UC01–UC50.
It creates the database and missing tables/indexes, and inserts missing roles.
It can be run again without dropping tables, duplicating roles or clearing data.
The original six authentication tables are supported, including existing accounts.
An incompatible existing schema causes an error and rolls back the schema batch;
it is not silently overwritten. Back up a shared database before applying changes.

On another SQL Server instance, open and execute the **entire** `SQLQuery1.sql`
file in SSMS, or use `sqlcmd -b -i SQLQuery1.sql` with your connection options.
The file targets the database named `EduSphere`. The account needs schema-change
permissions, and database-creation permissions if the database does not exist.

Table/use-case mapping, design decisions and remaining application rules are in
[docs/DATABASE.md](docs/DATABASE.md). Creating tables does not implement the
corresponding Java controllers/services/JSPs; the current code maps the six
authentication tables only.

The local `.env` and `src/main/resources/application.properties` files are
gitignored. Keep the same strong database password in both files. In IntelliJ,
run `EduSphereApplication` with Java 17, then open
`http://localhost:8080/EduSphere/`.

On Apple Silicon, the official SQL Server image runs via amd64 emulation.
