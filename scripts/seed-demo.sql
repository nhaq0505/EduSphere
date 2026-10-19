-- Demo data for the local EduSphere database only.
-- Accounts: admin@admin.com, instructor@instructor.com, student@student.com
-- Password for all three: 123 (stored below as BCrypt, not plaintext).
-- Run after SQLQuery1.sql. Safe to run again: existing demo courses are not reset.

USE [EduSphere];
GO
SET NOCOUNT ON;
SET XACT_ABORT ON;
SET ANSI_NULLS ON;
SET ANSI_PADDING ON;
SET ANSI_WARNINGS ON;
SET ARITHABORT ON;
SET CONCAT_NULL_YIELDS_NULL ON;
SET QUOTED_IDENTIFIER ON;
SET NUMERIC_ROUNDABORT OFF;

BEGIN TRY
    BEGIN TRANSACTION;

    IF (SELECT COUNT(*) FROM dbo.roles WHERE role_name IN (N'STUDENT', N'INSTRUCTOR', N'ADMINISTRATOR')) <> 3
        THROW 51000, 'Run SQLQuery1.sql before seeding demo data.', 1;

    DECLARE @password_hash NVARCHAR(255) = N'$2a$12$m6fgOREYUL7M252sCmllMO9s6oMPnnMeUoOHOD1joibkbuUGPTdfG';
    DECLARE @now DATETIME2 = SYSDATETIME();

    DECLARE @accounts TABLE (email NVARCHAR(255), full_name NVARCHAR(100), role_name NVARCHAR(50));
    INSERT INTO @accounts VALUES
        (N'admin@admin.com', N'Demo Administrator', N'ADMINISTRATOR'),
        (N'instructor@instructor.com', N'Demo Instructor', N'INSTRUCTOR'),
        (N'student@student.com', N'Demo Student', N'STUDENT');

    IF EXISTS (
        SELECT 1 FROM @accounts a JOIN dbo.users u ON u.email = a.email
        WHERE u.full_name <> a.full_name
    ) THROW 51001, 'A demo email already belongs to a different account; no data was changed.', 1;

    INSERT INTO dbo.users (full_name, email, password_hash, status, created_at)
    SELECT a.full_name, a.email, @password_hash, N'ACTIVE', @now
    FROM @accounts a WHERE NOT EXISTS (SELECT 1 FROM dbo.users u WHERE u.email = a.email);

    UPDATE u SET password_hash = @password_hash, status = N'ACTIVE', updated_at = @now
    FROM dbo.users u JOIN @accounts a ON a.email = u.email;

    INSERT INTO dbo.user_roles (user_id, role_id)
    SELECT u.user_id, r.role_id
    FROM @accounts a JOIN dbo.users u ON u.email = a.email JOIN dbo.roles r ON r.role_name = a.role_name
    WHERE NOT EXISTS (SELECT 1 FROM dbo.user_roles ur WHERE ur.user_id = u.user_id AND ur.role_id = r.role_id);

    DECLARE @categories TABLE (name NVARCHAR(100), description NVARCHAR(2000));
    INSERT INTO @categories VALUES
        (N'Lập trình', N'Các khóa học phát triển phần mềm.'),
        (N'Thiết kế', N'Thiết kế giao diện và trải nghiệm người dùng.'),
        (N'Dữ liệu', N'Cơ sở dữ liệu và phân tích dữ liệu.');
    INSERT INTO dbo.categories (name, description, status)
    SELECT c.name, c.description, N'ACTIVE' FROM @categories c
    WHERE NOT EXISTS (SELECT 1 FROM dbo.categories existing WHERE existing.name = c.name AND existing.parent_category_id IS NULL);

    DECLARE @instructor_id INT = (SELECT user_id FROM dbo.users WHERE email = N'instructor@instructor.com');
    DECLARE @student_id INT = (SELECT user_id FROM dbo.users WHERE email = N'student@student.com');
    DECLARE @admin_id INT = (SELECT user_id FROM dbo.users WHERE email = N'admin@admin.com');

    DECLARE @demo_courses TABLE (
        title NVARCHAR(255), description NVARCHAR(1000), category_name NVARCHAR(100),
        level NVARCHAR(20), price DECIMAL(18,2), status NVARCHAR(20)
    );
    INSERT INTO @demo_courses VALUES
        (N'[DEMO] Java căn bản', N'Học cú pháp Java, lập trình hướng đối tượng và cách viết ứng dụng đầu tiên.', N'Lập trình', N'BEGINNER', 0, N'PUBLISHED'),
        (N'[DEMO] Spring Boot thực hành', N'Xây dựng ứng dụng web với Spring MVC, Security và JPA.', N'Lập trình', N'INTERMEDIATE', 0, N'PUBLISHED'),
        (N'[DEMO] HTML CSS cho người mới', N'Tạo giao diện web rõ ràng, dễ đọc và nhất quán.', N'Thiết kế', N'BEGINNER', 0, N'PUBLISHED'),
        (N'[DEMO] SQL Server từ cơ bản', N'Luyện truy vấn, thiết kế bảng và quản lý dữ liệu với SQL Server.', N'Dữ liệu', N'BEGINNER', 199000, N'PUBLISHED'),
        (N'[DEMO] Khóa nháp', N'Khóa học để giảng viên thử chức năng chỉnh sửa và gửi duyệt.', N'Lập trình', N'ALL_LEVELS', 0, N'DRAFT'),
        (N'[DEMO] Khóa chờ duyệt', N'Khóa học để quản trị viên thử phê duyệt hoặc từ chối.', N'Dữ liệu', N'ALL_LEVELS', 0, N'SUBMITTED'),
        (N'[DEMO] Khóa đã phê duyệt', N'Khóa học để giảng viên thử chức năng công bố.', N'Lập trình', N'ALL_LEVELS', 0, N'APPROVED'),
        (N'[DEMO] Khóa bị từ chối', N'Khóa học để giảng viên xem lý do và sửa rồi gửi lại.', N'Thiết kế', N'ALL_LEVELS', 0, N'REJECTED'),
        (N'[DEMO] Khóa đã lưu trữ', N'Khóa học cũ giữ lại cho lịch sử nhưng không hiển thị công khai.', N'Lập trình', N'ALL_LEVELS', 0, N'ARCHIVED');

    INSERT INTO dbo.courses (title, description, category_id, instructor_id, level, price, currency,
                             status, version_no, created_at, updated_at, submitted_at, approved_at, published_at, archived_at)
    SELECT d.title, d.description, cat.category_id, @instructor_id, d.level, d.price, 'VND',
           d.status, 1, @now, @now,
           CASE WHEN d.status IN (N'SUBMITTED', N'APPROVED', N'REJECTED', N'PUBLISHED', N'ARCHIVED') THEN @now END,
           CASE WHEN d.status IN (N'APPROVED', N'PUBLISHED', N'ARCHIVED') THEN @now END,
           CASE WHEN d.status IN (N'PUBLISHED', N'ARCHIVED') THEN @now END,
           CASE WHEN d.status = N'ARCHIVED' THEN @now END
    FROM @demo_courses d JOIN dbo.categories cat ON cat.name = d.category_name AND cat.parent_category_id IS NULL
    WHERE NOT EXISTS (SELECT 1 FROM dbo.courses existing WHERE existing.instructor_id = @instructor_id AND existing.title = d.title);

    INSERT INTO dbo.course_reviews (course_id, course_version, admin_id, decision, comment, reviewed_at)
    SELECT c.course_id, 1, @admin_id,
           CASE WHEN d.status = N'REJECTED' THEN N'REJECTED' ELSE N'APPROVED' END,
           CASE WHEN d.status = N'REJECTED' THEN N'Bổ sung ví dụ và mô tả chi tiết hơn trước khi gửi lại.' ELSE N'Đủ điều kiện công bố bản demo.' END,
           @now
    FROM @demo_courses d JOIN dbo.courses c ON c.title = d.title AND c.instructor_id = @instructor_id
    WHERE d.status IN (N'APPROVED', N'REJECTED', N'PUBLISHED', N'ARCHIVED')
      AND NOT EXISTS (SELECT 1 FROM dbo.course_reviews r WHERE r.course_id = c.course_id AND r.course_version = 1);

    INSERT INTO dbo.lessons (course_id, title, content, order_index, status, created_at)
    SELECT c.course_id, N'Giới thiệu khóa học', N'Nội dung mẫu để kiểm tra cấu trúc khóa học.', 1, N'PUBLISHED', @now
    FROM dbo.courses c JOIN @demo_courses d ON d.title = c.title
    WHERE c.instructor_id = @instructor_id AND d.status = N'PUBLISHED'
      AND NOT EXISTS (SELECT 1 FROM dbo.lessons l WHERE l.course_id = c.course_id AND l.order_index = 1);
    INSERT INTO dbo.lessons (course_id, title, content, order_index, status, created_at)
    SELECT c.course_id, N'Bài học tiếp theo', N'Nội dung mẫu của bài học thứ hai.', 2, N'PUBLISHED', @now
    FROM dbo.courses c JOIN @demo_courses d ON d.title = c.title
    WHERE c.instructor_id = @instructor_id AND d.status = N'PUBLISHED'
      AND NOT EXISTS (SELECT 1 FROM dbo.lessons l WHERE l.course_id = c.course_id AND l.order_index = 2);

    INSERT INTO dbo.enrollments (student_id, course_id, enrolled_at, status)
    SELECT @student_id, c.course_id, @now, N'ACTIVE'
    FROM dbo.courses c WHERE c.instructor_id = @instructor_id AND c.title = N'[DEMO] Java căn bản'
      AND NOT EXISTS (SELECT 1 FROM dbo.enrollments e WHERE e.student_id = @student_id AND e.course_id = c.course_id);

    -- A sample successful payment lets the demo Student enroll in the paid course without UC45 UI.
    INSERT INTO dbo.payments (student_id, course_id, provider, request_key, amount, currency, status, created_at, completed_at)
    SELECT @student_id, c.course_id, N'DEMO', N'demo-sql-server-payment', 199000, 'VND', N'SUCCEEDED', @now, @now
    FROM dbo.courses c WHERE c.instructor_id = @instructor_id AND c.title = N'[DEMO] SQL Server từ cơ bản'
      AND NOT EXISTS (SELECT 1 FROM dbo.payments p WHERE p.request_key = N'demo-sql-server-payment');

    COMMIT TRANSACTION;
    SELECT N'Demo seed ready' AS result,
           (SELECT COUNT(*) FROM dbo.users WHERE email IN (N'admin@admin.com', N'instructor@instructor.com', N'student@student.com')) AS demo_accounts,
           (SELECT COUNT(*) FROM dbo.courses WHERE instructor_id = @instructor_id AND title LIKE N'[[]DEMO] %') AS demo_courses;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;
