-- =============================================================================
-- EduSphere Full Demo Seed Script (scripts/seed-full-demo.sql)
-- Seeds all 16+ tables for courses-and-exercises branch features:
-- Sections, 5-Step Course Builder, UPDATING/SUBMITTED workflows, Quizzes (all 5
-- question types), Quiz Attempts & Answers, Assignments, Submissions & Grades,
-- Lesson Completions, Learning Progress, Learning History, Study Plans,
-- Personal Tasks (UC34-UC39), and Account Events.
-- Safe & Idempotent: Can be re-run without duplicating data.
-- =============================================================================

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

-- -----------------------------------------------------------------------------
-- 0. Ensure Check Constraints match Java Service Enums (UC34, UC35, UC38)
-- -----------------------------------------------------------------------------
IF EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_study_plans_status')
    ALTER TABLE dbo.study_plans DROP CONSTRAINT CK_study_plans_status;
GO
ALTER TABLE dbo.study_plans ADD CONSTRAINT CK_study_plans_status
    CHECK ([status] IN (N'ACTIVE', N'COMPLETED', N'CANCELLED', N'ARCHIVED'));
GO

IF EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_personal_tasks_status')
    ALTER TABLE dbo.personal_tasks DROP CONSTRAINT CK_personal_tasks_status;
GO
ALTER TABLE dbo.personal_tasks ADD CONSTRAINT CK_personal_tasks_status
    CHECK ([status] IN (N'PENDING', N'DONE', N'SKIPPED', N'TODO', N'IN_PROGRESS', N'CANCELLED'));
GO

IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_personal_tasks_enrollment')
    ALTER TABLE dbo.personal_tasks DROP CONSTRAINT FK_personal_tasks_enrollment;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    DECLARE @now DATETIME2 = SYSDATETIME();
    DECLARE @password_hash NVARCHAR(255) = N'$2a$12$m6fgOREYUL7M252sCmllMO9s6oMPnnMeUoOHOD1joibkbuUGPTdfG'; -- '123'

    -- =========================================================================
    -- 1. USERS, ROLES & ACCOUNT EVENTS
    -- =========================================================================
    DECLARE @seed_users TABLE (email NVARCHAR(255), full_name NVARCHAR(100), phone NVARCHAR(20), role_name NVARCHAR(50));
    INSERT INTO @seed_users VALUES
        (N'admin@admin.com',           N'Quản Trị Viên Hệ Thống', N'0901000111', N'ADMINISTRATOR'),
        (N'instructor@instructor.com', N'ThS. Nguyễn Minh Khoa',  N'0902000222', N'INSTRUCTOR'),
        (N'student@student.com',       N'Nguyễn Hoàng Nam',       N'0903000333', N'STUDENT'),
        (N'student2@student.com',      N'Trần Minh Anh',          N'0904000444', N'STUDENT'),
        (N'student3@student.com',      N'Lê Hoàng Bảo',           N'0905000555', N'STUDENT');

    INSERT INTO dbo.users (full_name, email, phone, password_hash, status, created_at, updated_at)
    SELECT su.full_name, su.email, su.phone, @password_hash, N'ACTIVE', DATEADD(DAY, -30, @now), @now
    FROM @seed_users su
    WHERE NOT EXISTS (SELECT 1 FROM dbo.users u WHERE u.email = su.email);

    UPDATE u
    SET u.phone = COALESCE(u.phone, su.phone),
        u.status = N'ACTIVE',
        u.updated_at = @now
    FROM dbo.users u
    JOIN @seed_users su ON su.email = u.email;

    INSERT INTO dbo.user_roles (user_id, role_id, assigned_at)
    SELECT u.user_id, r.role_id, DATEADD(DAY, -30, @now)
    FROM @seed_users su
    JOIN dbo.users u ON u.email = su.email
    JOIN dbo.roles r ON r.role_name = su.role_name
    WHERE NOT EXISTS (
        SELECT 1 FROM dbo.user_roles ur WHERE ur.user_id = u.user_id AND ur.role_id = r.role_id
    );

    DECLARE @admin_id INT      = (SELECT user_id FROM dbo.users WHERE email = N'admin@admin.com');
    DECLARE @instructor_id INT = (SELECT user_id FROM dbo.users WHERE email = N'instructor@instructor.com');
    DECLARE @student_id INT    = (SELECT user_id FROM dbo.users WHERE email = N'student@student.com');
    DECLARE @student2_id INT   = (SELECT user_id FROM dbo.users WHERE email = N'student2@student.com');
    DECLARE @student3_id INT   = (SELECT user_id FROM dbo.users WHERE email = N'student3@student.com');
    DECLARE @personal_id INT   = (SELECT user_id FROM dbo.users WHERE email = N'anhquan050503@gmail.com');

    DECLARE @role_student_id INT    = (SELECT role_id FROM dbo.roles WHERE role_name = N'STUDENT');
    DECLARE @role_instructor_id INT = (SELECT role_id FROM dbo.roles WHERE role_name = N'INSTRUCTOR');

    -- Seed account_events if empty
    IF NOT EXISTS (SELECT 1 FROM dbo.account_events)
    BEGIN
        INSERT INTO dbo.account_events (user_id, actor_id, role_id, action, reason, created_at) VALUES
            (@instructor_id, @admin_id, @role_instructor_id, N'ROLE_GRANTED', N'Cấp quyền Giảng viên chính thức sau khi xét duyệt hồ sơ.', DATEADD(DAY, -25, @now)),
            (@student_id,    @admin_id, @role_student_id,    N'ROLE_GRANTED', N'Kích hoạt tài khoản học viên tiêu chuẩn.', DATEADD(DAY, -20, @now)),
            (@student2_id,   @admin_id, @role_student_id,    N'ROLE_GRANTED', N'Đăng ký học viên mới.', DATEADD(DAY, -15, @now)),
            (@student3_id,   @admin_id, NULL,                N'LOCKED',       N'Tạm khóa kiểm tra bảo mật đăng nhập nhiều lần.', DATEADD(DAY, -5, @now)),
            (@student3_id,   @admin_id, NULL,                N'RESTORED',     N'Đã xác minh chính chủ và mở khóa tài khoản.', DATEADD(DAY, -4, @now));
    END

    -- =========================================================================
    -- 2. CLEAN UP TEST JUNK COURSE ('123123') & ENRICH MAIN COURSES
    -- =========================================================================
    DELETE cr FROM dbo.course_reviews cr JOIN dbo.courses c ON cr.course_id = c.course_id WHERE c.title = N'123123';
    DELETE m FROM dbo.materials m JOIN dbo.lessons l ON m.lesson_id = l.lesson_id JOIN dbo.courses c ON l.course_id = c.course_id WHERE c.title = N'123123';
    DELETE l FROM dbo.lessons l JOIN dbo.courses c ON l.course_id = c.course_id WHERE c.title = N'123123';
    DELETE cs FROM dbo.course_sections cs JOIN dbo.courses c ON cs.course_id = c.course_id WHERE c.title = N'123123';
    DELETE FROM dbo.courses WHERE title = N'123123';

    -- Identify key courses
    DECLARE @c_spring INT = (SELECT TOP 1 course_id FROM dbo.courses WHERE title LIKE N'Spring MVC và JSP%' ORDER BY course_id);
    DECLARE @c_sql_lab INT = (SELECT TOP 1 course_id FROM dbo.courses WHERE title LIKE N'SQL Server thực hành%' ORDER BY course_id);
    DECLARE @c_java_basic INT = (SELECT TOP 1 course_id FROM dbo.courses WHERE title = N'[DEMO] Java căn bản' ORDER BY course_id);
    DECLARE @c_spring_boot INT = (SELECT TOP 1 course_id FROM dbo.courses WHERE title = N'[DEMO] Spring Boot thực hành' ORDER BY course_id);
    DECLARE @c_sql_paid INT = (SELECT TOP 1 course_id FROM dbo.courses WHERE title = N'[DEMO] SQL Server từ cơ bản' ORDER BY course_id);
    DECLARE @c_submitted INT = (SELECT TOP 1 course_id FROM dbo.courses WHERE course_id = 6 OR title = N'[DEMO] Khóa chờ duyệt' OR title LIKE N'%Thiết kế UI/UX%' ORDER BY course_id);
    DECLARE @c_java_core INT = (SELECT TOP 1 course_id FROM dbo.courses WHERE title LIKE N'Java nền tảng:%' ORDER BY course_id);

    -- Make sure Java nền tảng is PUBLISHED so students can study its rich 4 lessons
    IF @c_java_core IS NOT NULL
    BEGIN
        UPDATE dbo.courses
        SET status = N'PUBLISHED',
            archived_at = NULL,
            approved_at = COALESCE(approved_at, DATEADD(DAY, -14, @now)),
            published_at = COALESCE(published_at, DATEADD(DAY, -12, @now)),
            thumbnail_url = N'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?auto=format&fit=crop&w=900&q=80',
            promo_video_url = N'https://www.youtube.com/embed/eIrMbAQSU34',
            objectives = N'Nắm vững cú pháp Java 17 từ biến, kiểu dữ liệu, điều kiện, vòng lặp đến OOP.|Tự thiết kế class, constructor, đóng gói dữ liệu và quản lý danh sách với ArrayList.|Xây dựng được ứng dụng console quản lý khóa học hoàn chỉnh.',
            requirements = N'Máy tính cài đặt JDK 17 và IntelliJ IDEA hoặc VS Code.|Không yêu cầu kiến thức lập trình trước đó.',
            updated_at = @now
        WHERE course_id = @c_java_core;
    END

    -- Enrich Course 1: Spring MVC và JSP (PUBLISHED)
    IF @c_spring IS NOT NULL
    BEGIN
        UPDATE dbo.courses
        SET status = N'PUBLISHED',
            thumbnail_url = N'https://images.unsplash.com/photo-1555066931-4365d14bab8c?auto=format&fit=crop&w=900&q=80',
            promo_video_url = N'https://www.youtube.com/embed/9SGDpanrc8U',
            objectives = N'Hiểu rõ luồng xử lý request từ trình duyệt qua Spring Security, Controller, Service, JPA tới JSP.|Thực hành nhận và kiểm tra dữ liệu biểu mẫu với @ModelAttribute, @Valid và BindingResult.|Áp dụng @Transactional, Dependency Injection và @AuthenticationPrincipal an toàn trong dự án thực tế.',
            requirements = N'Đã nắm vững Java cơ bản và lập trình hướng đối tượng (OOP).|Biết cơ bản về HTML/HTTP và SQL.',
            updated_at = @now
        WHERE course_id = @c_spring;
    END

    -- Enrich Course 2: SQL Server thực hành (PUBLISHED)
    IF @c_sql_lab IS NOT NULL
    BEGIN
        UPDATE dbo.courses
        SET status = N'PUBLISHED',
            thumbnail_url = N'https://images.unsplash.com/photo-1544383835-bda2bc66a55d?auto=format&fit=crop&w=900&q=80',
            promo_video_url = N'https://www.youtube.com/embed/7S_tz1z_5bA',
            objectives = N'Thiết kế bảng chuẩn hóa với PRIMARY KEY, FOREIGN KEY và CHECK constraint trên SQL Server.|Thành thạo truy vấn SELECT, JOIN, GROUP BY, HAVING và thống kê dữ liệu thực tế.|Làm chủ Transaction (BEGIN TRAN, COMMIT, ROLLBACK) để bảo toàn dữ liệu.',
            requirements = N'Đã cài đặt SQL Server (hoặc Docker) và công cụ truy vấn SSMS / Azure Data Studio.',
            updated_at = @now
        WHERE course_id = @c_sql_lab;
    END

    -- Enrich Course 3: [DEMO] Java căn bản (PUBLISHED)
    IF @c_java_basic IS NOT NULL
    BEGIN
        UPDATE dbo.courses
        SET thumbnail_url = N'https://images.unsplash.com/photo-1515879218367-8466d910aaa4?auto=format&fit=crop&w=900&q=80',
            promo_video_url = N'https://www.youtube.com/embed/grEKMHGYyns',
            objectives = N'Làm quen nhanh với môi trường phát triển Java.|Hiểu cấu trúc chương trình và hướng đối tượng cơ bản.',
            requirements = N'Không yêu cầu kinh nghiệm lập trình.',
            updated_at = @now
        WHERE course_id = @c_java_basic;
    END

    -- Enrich Course 4: [DEMO] SQL Server từ cơ bản (PUBLISHED, Paid 199,000 VND)
    IF @c_sql_paid IS NOT NULL
    BEGIN
        UPDATE dbo.courses
        SET thumbnail_url = N'https://images.unsplash.com/photo-1460925895917-afdab827c52f?auto=format&fit=crop&w=900&q=80',
            promo_video_url = N'https://www.youtube.com/embed/HXV3zeQKqGY',
            objectives = N'Thiết kế cơ sở dữ liệu quan hệ chuẩn doanh nghiệp.|Tối ưu hóa truy vấn với Index, Execution Plan và Stored Procedure.|Bảo mật và phân quyền dữ liệu trên SQL Server.',
            requirements = N'Biết sử dụng máy tính cơ bản.',
            updated_at = @now
        WHERE course_id = @c_sql_paid;
    END

    -- Enrich Course 5: [DEMO] Spring Boot thực hành -> Set to UPDATING status (v2)
    IF @c_spring_boot IS NOT NULL
    BEGIN
        UPDATE dbo.courses
        SET status = N'UPDATING',
            version_no = 2,
            approved_at = COALESCE(approved_at, DATEADD(DAY, -10, @now)),
            published_at = COALESCE(published_at, DATEADD(DAY, -8, @now)),
            submitted_at = NULL,
            thumbnail_url = N'https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?auto=format&fit=crop&w=900&q=80',
            promo_video_url = N'https://www.youtube.com/embed/vtPkZShrvXQ',
            objectives = N'Xây dựng RESTful API và Web App với Spring Boot 3.3.|Tích hợp Spring Security 6, OAuth2 Google và phân quyền Role-based.|Triển khai ứng dụng với Docker và SQL Server.',
            requirements = N'Đã hoàn thành khóa Java nền tảng.',
            change_note = N'Đang cập nhật phiên bản v2: Bổ sung thêm chương Bảo mật OAuth2 và kiểm thử JUnit 5.',
            updated_at = @now
        WHERE course_id = @c_spring_boot;
    END

    -- Enrich Course 6: [DEMO] Khóa chờ duyệt -> Set to SUBMITTED with rich content & change_note for Admin Review
    IF @c_submitted IS NOT NULL
    BEGIN
        UPDATE dbo.courses
        SET title = N'[DEMO] Thiết kế UI/UX & Hệ thống Design System thực chiến',
            description = N'Khóa học toàn diện về thiết kế giao diện hiện đại, xây dựng Design System, Typography, Color Palette và chuyển giao thiết kế sang HTML/CSS chuẩn Accessibility.',
            status = N'SUBMITTED',
            version_no = 2,
            submitted_at = DATEADD(HOUR, -3, @now),
            approved_at = DATEADD(DAY, -15, @now),
            published_at = DATEADD(DAY, -14, @now),
            thumbnail_url = N'https://images.unsplash.com/photo-1561070791-2526d30994b5?auto=format&fit=crop&w=900&q=80',
            promo_video_url = N'https://www.youtube.com/embed/c9Wg6Cb_YlU',
            objectives = N'Nắm vững nguyên lý thị giác, bố cục Grid 8px và hệ thống phân cấp Typography.|Xây dựng bộ Component Library hoàn chỉnh có trạng thái Hover/Focus/Disabled.|Kiểm tra độ tương phản màu sắc chuẩn WCAG AA.',
            requirements = N'Có tài khoản Figma miễn phí và trình duyệt Chrome.',
            change_note = N'Cập nhật phiên bản v2: Bổ sung Chương 2 về Design System & Auto Layout, thêm 1 bài học Video mới và 1 bài Quiz kiểm tra cuối chương.',
            updated_at = @now
        WHERE course_id = @c_submitted;
    END

    -- =========================================================================
    -- 3. COURSE SECTIONS, LESSONS & MATERIALS
    -- =========================================================================
    -- 3.1 Sections for Spring MVC và JSP (@c_spring)
    IF @c_spring IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.course_sections WHERE course_id = @c_spring)
    BEGIN
        INSERT INTO dbo.course_sections (course_id, title, description, order_index, created_at) VALUES
            (@c_spring, N'Chương 1: Luồng Request, Controller, Model & Giao diện JSP', N'Làm chủ vòng đời HTTP GET/POST, cách truyền dữ liệu qua Model và xử lý biểu mẫu an toàn.', 1, @now),
            (@c_spring, N'Chương 2: Kiến trúc Service, Giao dịch JPA & Bảo mật Spring Security', N'Hiểu sâu về Dependency Injection, @Transactional và phân quyền người dùng thực tế.', 2, @now);

        DECLARE @sec_sp_1 INT = (SELECT section_id FROM dbo.course_sections WHERE course_id = @c_spring AND order_index = 1);
        DECLARE @sec_sp_2 INT = (SELECT section_id FROM dbo.course_sections WHERE course_id = @c_spring AND order_index = 2);

        UPDATE dbo.lessons
        SET section_id = CASE WHEN order_index IN (1, 2) THEN @sec_sp_1 ELSE @sec_sp_2 END,
            lesson_type = CASE WHEN order_index = 1 THEN N'VIDEO' ELSE N'ARTICLE' END,
            video_url = CASE WHEN order_index = 1 THEN N'https://www.youtube.com/embed/9SGDpanrc8U' ELSE NULL END,
            video_duration = CASE WHEN order_index = 1 THEN 780 ELSE NULL END,
            is_preview = CASE WHEN order_index = 1 THEN 1 ELSE 0 END,
            instructor_notes = N'Lưu ý học viên mở sẵn project EduSphere trên IntelliJ IDEA để đối chiếu từng file khi học.'
        WHERE course_id = @c_spring;

        -- Link prerequisite: Lesson 2 requires Lesson 1
        DECLARE @les_sp_1 INT = (SELECT TOP 1 lesson_id FROM dbo.lessons WHERE course_id = @c_spring AND order_index = 1);
        UPDATE dbo.lessons SET prerequisite_lesson_id = @les_sp_1 WHERE course_id = @c_spring AND order_index = 2;
    END

    -- 3.2 Sections for Java nền tảng (@c_java_core)
    IF @c_java_core IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.course_sections WHERE course_id = @c_java_core)
    BEGIN
        INSERT INTO dbo.course_sections (course_id, title, description, order_index, created_at) VALUES
            (@c_java_core, N'Chương 1: Nền tảng Cú pháp, Biến, Điều kiện & Phương thức', N'Viết và biên dịch chương trình Java 17 đầu tiên, tách hàm và xử lý ngoại lệ.', 1, @now),
            (@c_java_core, N'Chương 2: Lập trình Hướng đối tượng (OOP) & Cấu trúc dữ liệu List', N'Thiết kế lớp Course, đóng gói dữ liệu và xây dựng ứng dụng quản lý khóa học với ArrayList.', 2, @now);

        DECLARE @sec_jv_1 INT = (SELECT section_id FROM dbo.course_sections WHERE course_id = @c_java_core AND order_index = 1);
        DECLARE @sec_jv_2 INT = (SELECT section_id FROM dbo.course_sections WHERE course_id = @c_java_core AND order_index = 2);

        UPDATE dbo.lessons
        SET section_id = CASE WHEN order_index IN (1, 2) THEN @sec_jv_1 ELSE @sec_jv_2 END,
            lesson_type = CASE WHEN order_index = 1 THEN N'VIDEO' ELSE N'ARTICLE' END,
            video_url = CASE WHEN order_index = 1 THEN N'https://www.youtube.com/embed/eIrMbAQSU34' ELSE NULL END,
            video_duration = CASE WHEN order_index = 1 THEN 920 ELSE NULL END,
            is_preview = CASE WHEN order_index = 1 THEN 1 ELSE 0 END,
            instructor_notes = N'Học viên cần tự gõ lại toàn bộ code Main.java và Course.java trước khi làm Quiz.'
        WHERE course_id = @c_java_core;
    END

    -- 3.3 Sections for SQL Server thực hành (@c_sql_lab)
    IF @c_sql_lab IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.course_sections WHERE course_id = @c_sql_lab)
    BEGIN
        INSERT INTO dbo.course_sections (course_id, title, description, order_index, created_at) VALUES
            (@c_sql_lab, N'Chương 1: Thiết kế Bảng, Ràng buộc & Truy vấn SELECT', N'Tạo bảng chuẩn hóa, chèn dữ liệu mẫu và lọc/sắp xếp dữ liệu.', 1, @now),
            (@c_sql_lab, N'Chương 2: Kết nối bảng (JOIN), Thống kê GROUP BY & Giao dịch', N'Tổng hợp báo cáo với LEFT JOIN, GROUP BY và bảo vệ toàn vẹn dữ liệu với Transaction.', 2, @now);

        DECLARE @sec_sq_1 INT = (SELECT section_id FROM dbo.course_sections WHERE course_id = @c_sql_lab AND order_index = 1);
        DECLARE @sec_sq_2 INT = (SELECT section_id FROM dbo.course_sections WHERE course_id = @c_sql_lab AND order_index = 2);

        UPDATE dbo.lessons
        SET section_id = CASE WHEN order_index IN (1, 2) THEN @sec_sq_1 ELSE @sec_sq_2 END,
            lesson_type = CASE WHEN order_index = 1 THEN N'VIDEO' ELSE N'ARTICLE' END,
            video_url = CASE WHEN order_index = 1 THEN N'https://www.youtube.com/embed/7S_tz1z_5bA' ELSE NULL END,
            video_duration = CASE WHEN order_index = 1 THEN 840 ELSE NULL END,
            is_preview = CASE WHEN order_index = 1 THEN 1 ELSE 0 END
        WHERE course_id = @c_sql_lab;
    END

    -- 3.4 Sections & New Draft Lesson for UPDATING Course (@c_spring_boot)
    IF @c_spring_boot IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.course_sections WHERE course_id = @c_spring_boot)
    BEGIN
        INSERT INTO dbo.course_sections (course_id, title, description, order_index, created_at) VALUES
            (@c_spring_boot, N'Chương 1: Khởi tạo dự án Spring Boot & Cấu hình cốt lõi', N'Các bài học đã xuất bản cho học viên.', 1, @now),
            (@c_spring_boot, N'Chương 2: Bảo mật OAuth2 & Kiểm thử tự động (Bản cập nhật v2)', N'Nội dung mới đang được giảng viên biên soạn bổ sung.', 2, @now);

        DECLARE @sec_sb_1 INT = (SELECT section_id FROM dbo.course_sections WHERE course_id = @c_spring_boot AND order_index = 1);
        DECLARE @sec_sb_2 INT = (SELECT section_id FROM dbo.course_sections WHERE course_id = @c_spring_boot AND order_index = 2);

        UPDATE dbo.lessons
        SET section_id = @sec_sb_1,
            lesson_type = N'VIDEO',
            video_url = N'https://www.youtube.com/embed/vtPkZShrvXQ',
            video_duration = 600,
            is_preview = CASE WHEN order_index = 1 THEN 1 ELSE 0 END
        WHERE course_id = @c_spring_boot;

        IF NOT EXISTS (SELECT 1 FROM dbo.lessons WHERE course_id = @c_spring_boot AND order_index = 3)
        BEGIN
            INSERT INTO dbo.lessons (course_id, section_id, title, content, order_index, status, lesson_type, video_url, video_duration, allow_seek, is_preview, instructor_notes, created_at)
            VALUES
                (@c_spring_boot, @sec_sb_2, N'Bài 3 (Mới): Tích hợp Đăng nhập Google OAuth2 vào Spring Security',
                 N'Hướng dẫn cấu hình Google Cloud Console, Client ID, Client Secret và CustomOAuth2UserService để đồng bộ tài khoản người dùng vào bảng users và oauth_accounts.',
                 3, N'DRAFT', N'VIDEO', N'https://www.youtube.com/embed/9SGDpanrc8U', 950, 1, 0,
                 N'Bài học mới thêm trong đợt cập nhật v2.', @now),
                (@c_spring_boot, @sec_sb_2, N'Bài 4 (Mới): Viết Unit Test tầng Service với JUnit 5 & Mockito',
                 N'Cách sử dụng mock(), when().thenReturn(), ArgumentCaptor và assertThrows để kiểm thử toàn diện logic nghiệp vụ.',
                 4, N'DRAFT', N'ARTICLE', NULL, NULL, 1, 0,
                 N'Bài học thực hành viết test.', @now);
        END
    END

    -- 3.5 Sections & Lessons for SUBMITTED Course (@c_submitted — Admin Review Demo)
    IF @c_submitted IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.course_sections WHERE course_id = @c_submitted)
    BEGIN
        INSERT INTO dbo.course_sections (course_id, title, description, order_index, created_at) VALUES
            (@c_submitted, N'Chương 1: Nguyên lý Thiết kế Giao diện & Hệ thống Lưới (Grid System)', N'Nền tảng UI/UX hiện đại dành cho lập trình viên và Designer.', 1, @now),
            (@c_submitted, N'Chương 2: Xây dựng Design System, Component & Kiểm tra Accessibility', N'Chương mới bổ sung trong phiên bản v2 đang gửi Admin xét duyệt.', 2, @now);

        DECLARE @sec_ui_1 INT = (SELECT section_id FROM dbo.course_sections WHERE course_id = @c_submitted AND order_index = 1);
        DECLARE @sec_ui_2 INT = (SELECT section_id FROM dbo.course_sections WHERE course_id = @c_submitted AND order_index = 2);

        IF NOT EXISTS (SELECT 1 FROM dbo.lessons WHERE course_id = @c_submitted)
        BEGIN
            INSERT INTO dbo.lessons (course_id, section_id, title, content, order_index, status, lesson_type, video_url, video_duration, allow_seek, is_preview, created_at)
            VALUES
                (@c_submitted, @sec_ui_1, N'Bài 1: Quy tắc khoảng trắng (Whitespace) và Hệ thống Lưới 8px',
                 N'Tìm hiểu vì sao hệ thống lưới 8px giúp giao diện đồng nhất trên mọi kích thước màn hình Desktop, Tablet và Mobile.',
                 1, N'PUBLISHED', N'VIDEO', N'https://www.youtube.com/embed/c9Wg6Cb_YlU', 720, 1, 1, DATEADD(DAY, -14, @now)),
                (@c_submitted, @sec_ui_1, N'Bài 2: Phân cấp thị giác với Typography & Bảng màu ngữ nghĩa',
                 N'Cách chọn font chữ, tỷ lệ kích thước Heading/Body và thiết kế bảng màu Primary, Success, Warning, Danger đạt chuẩn độ tương phản WCAG AA.',
                 2, N'PUBLISHED', N'ARTICLE', NULL, NULL, 1, 0, DATEADD(DAY, -14, @now)),
                (@c_submitted, @sec_ui_2, N'Bài 3 (Bản cập nhật mới): Thiết kế Button, Input, Modal & Trạng thái tương tác',
                 N'Xây dựng bộ UI Component có đầy đủ trạng thái Default, Hover, Active, Focus Ring và Disabled để chuyển giao sang CSS Variables.',
                 3, N'DRAFT', N'VIDEO', N'https://www.youtube.com/embed/FTFaQWZBqQ8', 890, 1, 0, @now);
        END
    END

    -- =========================================================================
    -- 4. QUIZZES, QUESTIONS (ALL 5 TYPES) & ANSWER OPTIONS
    -- =========================================================================
    DECLARE @les_spring_1 INT = (SELECT TOP 1 lesson_id FROM dbo.lessons WHERE course_id = @c_spring AND order_index = 1);
    DECLARE @les_spring_2 INT = (SELECT TOP 1 lesson_id FROM dbo.lessons WHERE course_id = @c_spring AND order_index = 2);
    DECLARE @les_java_1   INT = (SELECT TOP 1 lesson_id FROM dbo.lessons WHERE course_id = @c_java_core AND order_index = 1);
    DECLARE @les_sql_1    INT = (SELECT TOP 1 lesson_id FROM dbo.lessons WHERE course_id = @c_sql_lab AND order_index = 1);
    DECLARE @les_ui_1     INT = (SELECT TOP 1 lesson_id FROM dbo.lessons WHERE course_id = @c_submitted AND order_index = 1);

    -- 4.1 Quiz 1: Attached to Lesson 1 of Spring MVC (@c_spring) — Has all 5 question types!
    IF @c_spring IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.quizzes WHERE course_id = @c_spring AND title LIKE N'Kiểm tra Bài 1:%')
    BEGIN
        INSERT INTO dbo.quizzes (course_id, lesson_id, title, description, time_limit_minutes, max_attempts, rules, status, created_by, created_at, passing_score, shuffle_questions, shuffle_options)
        VALUES (@c_spring, @les_spring_1, N'Kiểm tra Bài 1: Luồng Request, Controller, Model & JSP',
                N'Bài kiểm tra gồm đủ 5 dạng câu hỏi (Một đáp án, Nhiều đáp án, Đúng/Sai, Trả lời ngắn và Tự luận) giúp bạn nắm chắc luồng MVC trong EduSphere.',
                15, 3, N'Hoàn thành trong 15 phút. Đạt từ 70% trở lên để qua bài.', N'PUBLISHED', @instructor_id, DATEADD(DAY, -10, @now), 70, 0, 0);

        DECLARE @quiz_sp_1 INT = SCOPE_IDENTITY();

        -- Q1: SINGLE_CHOICE (2.0 pts)
        INSERT INTO dbo.questions (quiz_id, content, type, score, order_index, explanation)
        VALUES (@quiz_sp_1, N'Trong Spring MVC, thành phần nào chịu trách nhiệm tìm file JSP tương ứng với tên chuỗi mà Controller trả về?', N'SINGLE_CHOICE', 2.00, 1,
                N'InternalResourceViewResolver kết hợp prefix (/WEB-INF/views/) và suffix (.jsp) để định vị file JSP.');
        DECLARE @q1 INT = SCOPE_IDENTITY();
        INSERT INTO dbo.answer_options (question_id, content, is_correct, order_index) VALUES
            (@q1, N'ViewResolver (InternalResourceViewResolver)', 1, 1),
            (@q1, N'JdbcTemplate', 0, 2),
            (@q1, N'BCryptPasswordEncoder', 0, 3),
            (@q1, N'EntityManagerFactory', 0, 4);

        -- Q2: MULTIPLE_CHOICE (2.0 pts)
        INSERT INTO dbo.questions (quiz_id, content, type, score, order_index, explanation)
        VALUES (@quiz_sp_1, N'Những phát biểu nào sau đây là ĐÚNG khi làm việc với Model và JSP trong EduSphere? (Chọn nhiều đáp án)', N'MULTIPLE_CHOICE', 2.00, 2,
                N'model.addAttribute đưa dữ liệu xuống request scope cho JSP, và thẻ <c:out> giúp chống lỗi XSS.');
        DECLARE @q2 INT = SCOPE_IDENTITY();
        INSERT INTO dbo.answer_options (question_id, content, is_correct, order_index) VALUES
            (@q2, N'model.addAttribute("courses", list) giúp JSP truy cập dữ liệu qua biểu thức ${courses}', 1, 1),
            (@q2, N'Sử dụng <c:out value="${...}"/> giúp escape ký tự HTML đặc biệt và ngăn ngừa XSS', 1, 2),
            (@q2, N'Dữ liệu trong Model mặc định tự động giữ nguyên qua lệnh redirect:/... sang request mới', 0, 3),
            (@q2, N'JSP có thể gọi trực tiếp phương thức private của Controller mà không cần Model', 0, 4);

        -- Q3: TRUE_FALSE (2.0 pts)
        INSERT INTO dbo.questions (quiz_id, content, type, score, order_index, correct_answer, explanation)
        VALUES (@quiz_sp_1, N'Khi một đường dẫn chưa được mở công khai (permitAll) trong SecurityConfig, Spring Security sẽ tự động chuyển hướng người dùng chưa đăng nhập về trang /auth/login.', N'TRUE_FALSE', 2.00, 3, N'true',
                N'Đúng. Cấu hình formLogin trong SecurityConfig sẽ điều hướng người dùng chưa xác thực về /auth/login.');

        -- Q4: SHORT_ANSWER (2.0 pts)
        INSERT INTO dbo.questions (quiz_id, content, type, score, order_index, correct_answer, explanation)
        VALUES (@quiz_sp_1, N'Annotation nào dùng trên tham số phương thức Controller để lấy thông tin người dùng đang đăng nhập từ Spring Security (không viết dấu @)?', N'SHORT_ANSWER', 2.00, 4, N'AuthenticationPrincipal',
                N'@AuthenticationPrincipal CustomUserDetails user là cách chuẩn để lấy tài khoản hiện tại.');

        -- Q5: ESSAY (2.0 pts)
        INSERT INTO dbo.questions (quiz_id, content, type, score, order_index, explanation)
        VALUES (@quiz_sp_1, N'Hãy giải thích ngắn gọn sự khác biệt giữa dữ liệu truyền qua @RequestParam trên URL và dữ liệu truyền từ Controller xuống JSP qua Model.', N'ESSAY', 2.00, 5,
                N'@RequestParam đọc tham số do client gửi lên từ query string/form, còn Model là vùng chứa dữ liệu từ server truyền xuống View (JSP) để render HTML.');
    END

    -- 4.2 Quiz 2: Course-level Auto-Graded Final Quiz in Spring MVC (@c_spring)
    IF @c_spring IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.quizzes WHERE course_id = @c_spring AND title LIKE N'Đánh giá tổng kết:%')
    BEGIN
        INSERT INTO dbo.quizzes (course_id, lesson_id, title, description, time_limit_minutes, max_attempts, rules, status, created_by, created_at, passing_score, shuffle_questions, shuffle_options)
        VALUES (@c_spring, NULL, N'Đánh giá tổng kết: Spring MVC, Validation, JPA & Security',
                N'Bài trắc nghiệm chấm điểm tự động 100% kiểm tra kiến thức toàn khóa Spring MVC & JSP.',
                20, 5, N'Tất cả câu hỏi đều được hệ thống chấm tự động ngay sau khi nộp bài.', N'PUBLISHED', @instructor_id, DATEADD(DAY, -9, @now), 75, 1, 1);

        DECLARE @quiz_sp_2 INT = SCOPE_IDENTITY();

        INSERT INTO dbo.questions (quiz_id, content, type, score, order_index, explanation)
        VALUES (@quiz_sp_2, N'Trong phương thức Controller nhận form có @Valid @ModelAttribute, tham số BindingResult bắt buộc phải đặt ở vị trí nào?', N'SINGLE_CHOICE', 2.50, 1,
                N'BindingResult phải đặt ngay liền sau tham số @ModelAttribute được đánh dấu @Valid.');
        DECLARE @q2_1 INT = SCOPE_IDENTITY();
        INSERT INTO dbo.answer_options (question_id, content, is_correct, order_index) VALUES
            (@q2_1, N'Ngay liền sau tham số @Valid @ModelAttribute', 1, 1),
            (@q2_1, N'Ở vị trí đầu tiên của phương thức', 0, 2),
            (@q2_1, N'Ở vị trí cuối cùng sau RedirectAttributes', 0, 3),
            (@q2_1, N'Đặt ở bất kỳ vị trí nào cũng được', 0, 4);

        INSERT INTO dbo.questions (quiz_id, content, type, score, order_index, explanation)
        VALUES (@quiz_sp_2, N'Vì sao không nên nhận studentId từ hidden input trên form để quyết định học viên nào đang ghi danh khóa học?', N'SINGLE_CHOICE', 2.50, 2,
                N'Người dùng có thể sửa HTML/request để giả mạo studentId của người khác (lỗ hổng IDOR). Phải lấy từ @AuthenticationPrincipal.');
        DECLARE @q2_2 INT = SCOPE_IDENTITY();
        INSERT INTO dbo.answer_options (question_id, content, is_correct, order_index) VALUES
            (@q2_2, N'Vì người dùng có thể chỉnh sửa giá trị gửi lên trình duyệt gây lỗ hổng mạo danh (IDOR)', 1, 1),
            (@q2_2, N'Vì hidden input không gửi được số nguyên', 0, 2),
            (@q2_2, N'Vì JSP không hỗ trợ thẻ input type="hidden"', 0, 3);

        INSERT INTO dbo.questions (quiz_id, content, type, score, order_index, correct_answer, explanation)
        VALUES (@quiz_sp_2, N'Annotation @Transactional trên phương thức Service giúp tự động rollback giao dịch database khi xảy ra RuntimeException.', N'TRUE_FALSE', 2.50, 3, N'true',
                N'Mặc định Spring @Transactional sẽ rollback khi có Unchecked Exception (RuntimeException hoặc Error).');

        INSERT INTO dbo.questions (quiz_id, content, type, score, order_index, correct_answer, explanation)
        VALUES (@quiz_sp_2, N'Đối tượng nào trong Spring MVC dùng để truyền thông báo flash (ví dụ: flash.addFlashAttribute) qua một lệnh redirect?', N'SHORT_ANSWER', 2.50, 4, N'RedirectAttributes',
                N'RedirectAttributes lưu tạm thông báo vào FlashMap để hiển thị ở request GET tiếp theo sau redirect.');
    END

    -- 4.3 Quiz 3: Draft Quiz in Spring MVC (@c_spring) for Instructor Builder Demo
    IF @c_spring IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.quizzes WHERE course_id = @c_spring AND status = N'DRAFT')
    BEGIN
        INSERT INTO dbo.quizzes (course_id, lesson_id, title, description, time_limit_minutes, max_attempts, rules, status, created_by, created_at, passing_score, shuffle_questions, shuffle_options)
        VALUES (@c_spring, @les_spring_2, N'[Bản nháp] Quiz ôn tập Bài 2: Xử lý Form & CSRF Token',
                N'Quiz đang ở trạng thái DRAFT để giảng viên demo tính năng thêm câu hỏi mới và bấm Xuất bản trên Quiz Builder.',
                10, 2, N'Kiểm tra nhanh kiến thức CSRF và Validation.', N'DRAFT', @instructor_id, DATEADD(DAY, -2, @now), 70, 0, 0);

        DECLARE @quiz_sp_draft INT = SCOPE_IDENTITY();
        INSERT INTO dbo.questions (quiz_id, content, type, score, order_index, correct_answer, explanation)
        VALUES (@quiz_sp_draft, N'Mọi form POST trong EduSphere khi bật CSRF đều cần gửi kèm token bảo mật _csrf.', N'TRUE_FALSE', 5.00, 1, N'true',
                N'Nếu thiếu CSRF token trong POST request, Spring Security sẽ từ chối với mã lỗi 403 Forbidden.');
    END

    -- 4.4 Quiz 4: Published Quiz in Java nền tảng (@c_java_core)
    IF @c_java_core IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.quizzes WHERE course_id = @c_java_core)
    BEGIN
        INSERT INTO dbo.quizzes (course_id, lesson_id, title, description, time_limit_minutes, max_attempts, rules, status, created_by, created_at, passing_score, shuffle_questions, shuffle_options)
        VALUES (@c_java_core, @les_java_1, N'Kiểm tra Bài 1: Biến, Kiểu dữ liệu & Biên dịch Java 17',
                N'Kiểm tra kiến thức cơ bản về javac, java, int, double, boolean và String.',
                15, 3, N'Đạt tối thiểu 70% điểm số.', N'PUBLISHED', @instructor_id, DATEADD(DAY, -11, @now), 70, 0, 0);

        DECLARE @quiz_jv_1 INT = SCOPE_IDENTITY();

        INSERT INTO dbo.questions (quiz_id, content, type, score, order_index, explanation)
        VALUES (@quiz_jv_1, N'Lệnh nào dùng để biên dịch file mã nguồn Main.java thành bytecode Main.class?', N'SINGLE_CHOICE', 5.00, 1,
                N'javac là trình biên dịch Java (Java Compiler), còn java dùng để chạy chương trình.');
        DECLARE @qjv1 INT = SCOPE_IDENTITY();
        INSERT INTO dbo.answer_options (question_id, content, is_correct, order_index) VALUES
            (@qjv1, N'javac -encoding UTF-8 Main.java', 1, 1),
            (@qjv1, N'java Main.java --compile', 0, 2),
            (@qjv1, N'mvn run Main.class', 0, 3);

        INSERT INTO dbo.questions (quiz_id, content, type, score, order_index, correct_answer, explanation)
        VALUES (@quiz_jv_1, N'Tên phương thức bắt đầu chạy của một chương trình Java tiêu chuẩn là gì?', N'SHORT_ANSWER', 5.00, 2, N'main',
                N'public static void main(String[] args) là điểm bắt đầu thực thi của chương trình Java.');
    END

    -- 4.5 Quiz 5: Published Quiz in SQL Server thực hành (@c_sql_lab)
    IF @c_sql_lab IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.quizzes WHERE course_id = @c_sql_lab)
    BEGIN
        INSERT INTO dbo.quizzes (course_id, lesson_id, title, description, time_limit_minutes, max_attempts, rules, status, created_by, created_at, passing_score, shuffle_questions, shuffle_options)
        VALUES (@c_sql_lab, @les_sql_1, N'Kiểm tra SQL Server: Khóa chính, Ràng buộc & Giao dịch',
                N'Đánh giá kỹ năng thiết kế bảng, viết câu lệnh SELECT/JOIN và kiểm soát Transaction.',
                15, 3, N'Làm bài cá nhân trong 15 phút.', N'PUBLISHED', @instructor_id, DATEADD(DAY, -8, @now), 70, 0, 0);

        DECLARE @quiz_sq_1 INT = SCOPE_IDENTITY();

        INSERT INTO dbo.questions (quiz_id, content, type, score, order_index, explanation)
        VALUES (@quiz_sq_1, N'Lệnh nào trong SQL Server dùng để hoàn tác (hủy bỏ) toàn bộ các thay đổi trong một giao dịch khi phát hiện lỗi?', N'SINGLE_CHOICE', 5.00, 1,
                N'ROLLBACK TRANSACTION đưa dữ liệu về trạng thái trước khi BEGIN TRANSACTION.');
        DECLARE @qsq1 INT = SCOPE_IDENTITY();
        INSERT INTO dbo.answer_options (question_id, content, is_correct, order_index) VALUES
            (@qsq1, N'ROLLBACK TRANSACTION', 1, 1),
            (@qsq1, N'COMMIT TRANSACTION', 0, 2),
            (@qsq1, N'TRUNCATE TRANSACTION', 0, 3);

        INSERT INTO dbo.questions (quiz_id, content, type, score, order_index, correct_answer, explanation)
        VALUES (@quiz_sq_1, N'Trong SQL Server, phép kết nối LEFT JOIN vẫn giữ lại các dòng ở bảng bên trái ngay cả khi không có dòng khớp ở bảng bên phải.', N'TRUE_FALSE', 5.00, 2, N'true',
                N'Đúng. Các cột của bảng bên phải sẽ mang giá trị NULL nếu không có bản ghi khớp.');
    END

    -- 4.6 Quiz 6: Quiz in SUBMITTED Course (@c_submitted) for Admin Review Page
    IF @c_submitted IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.quizzes WHERE course_id = @c_submitted)
    BEGIN
        INSERT INTO dbo.quizzes (course_id, lesson_id, title, description, time_limit_minutes, max_attempts, rules, status, created_by, created_at, passing_score, shuffle_questions, shuffle_options)
        VALUES (@c_submitted, @les_ui_1, N'Kiểm tra Chương 1: Hệ thống Lưới 8px & Độ tương phản WCAG',
                N'Bài kiểm tra mẫu đính kèm khóa học đang chờ Admin xét duyệt.',
                10, 3, N'Hoàn thành 2 câu hỏi trắc nghiệm.', N'PUBLISHED', @instructor_id, DATEADD(HOUR, -4, @now), 70, 0, 0);

        DECLARE @quiz_ui_1 INT = SCOPE_IDENTITY();
        INSERT INTO dbo.questions (quiz_id, content, type, score, order_index, explanation)
        VALUES (@quiz_ui_1, N'Tỷ lệ tương phản tối thiểu theo chuẩn WCAG AA đối với văn bản kích thước thông thường là bao nhiêu?', N'SINGLE_CHOICE', 10.00, 1,
                N'Chuẩn WCAG 2.1 AA yêu cầu tỷ lệ tương phản tối thiểu 4.5:1 cho văn bản thường và 3:1 cho văn bản lớn.');
        DECLARE @qui1 INT = SCOPE_IDENTITY();
        INSERT INTO dbo.answer_options (question_id, content, is_correct, order_index) VALUES
            (@qui1, N'4.5 : 1', 1, 1),
            (@qui1, N'1.5 : 1', 0, 2),
            (@qui1, N'10 : 1', 0, 3);
    END

    -- =========================================================================
    -- 5. ASSIGNMENTS
    -- =========================================================================
    IF @c_spring IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.assignments WHERE course_id = @c_spring)
    BEGIN
        INSERT INTO dbo.assignments (course_id, lesson_id, title, description, unlock_at, due_date, lock_at, max_score, allow_resubmit, max_attempts, status, created_by, created_at, updated_at)
        VALUES
            (@c_spring, @les_spring_1, N'Bài tập thực hành 1: Phân tích luồng Controller - Service - JSP trong EduSphere',
             N'Hãy mở class CourseDiscoveryController và CourseManagementController, vẽ sơ đồ hoặc mô tả chi tiết luồng chạy của tính năng Xem danh sách khóa học và Ghi danh khóa học miễn phí. Đính kèm link tài liệu hoặc viết trực tiếp vào ô bài làm.',
             DATEADD(DAY, -14, @now), DATEADD(DAY, 14, @now), DATEADD(DAY, 21, @now), 100.00, 1, 3, N'PUBLISHED', @instructor_id, DATEADD(DAY, -10, @now), @now),
            (@c_spring, @les_spring_2, N'Bài tập thực hành 2: Xây dựng Form Validation với @Valid và BindingResult',
             N'Viết mã nguồn phương thức POST nhận biểu mẫu tạo mới đối tượng, kiểm tra lỗi với @Valid và BindingResult, đồng thời giải thích cơ chế hoạt động của CSRF Token trên form JSP.',
             DATEADD(DAY, -10, @now), DATEADD(DAY, 20, @now), DATEADD(DAY, 25, @now), 100.00, 1, 3, N'PUBLISHED', @instructor_id, DATEADD(DAY, -8, @now), @now);
    END

    IF @c_java_core IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.assignments WHERE course_id = @c_java_core)
    BEGIN
        INSERT INTO dbo.assignments (course_id, lesson_id, title, description, unlock_at, due_date, lock_at, max_score, allow_resubmit, max_attempts, status, created_by, created_at, updated_at)
        VALUES
            (@c_java_core, @les_java_1, N'Bài tập lớn cuối khóa: Ứng dụng Console Quản lý Danh sách Khóa học',
             N'Hoàn thiện hai lớp Course.java và Main.java có menu tìm kiếm khóa học theo từ khóa, thống kê tổng số bài học và xử lý ngoại lệ khi dữ liệu đầu vào không hợp lệ.',
             DATEADD(DAY, -14, @now), DATEADD(DAY, 15, @now), DATEADD(DAY, 30, @now), 100.00, 1, 3, N'PUBLISHED', @instructor_id, DATEADD(DAY, -11, @now), @now);
    END

    IF @c_sql_lab IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.assignments WHERE course_id = @c_sql_lab)
    BEGIN
        INSERT INTO dbo.assignments (course_id, lesson_id, title, description, unlock_at, due_date, lock_at, max_score, allow_resubmit, max_attempts, status, created_by, created_at, updated_at)
        VALUES
            (@c_sql_lab, @les_sql_1, N'Bài tập thực hành SQL: Truy vấn Thống kê Học viên & Giao dịch Ghi danh',
             N'Viết câu lệnh SELECT kết hợp LEFT JOIN, GROUP BY để thống kê số học viên theo từng khóa học và viết một khối BEGIN TRY ... BEGIN TRANSACTION ... COMMIT/ROLLBACK an toàn.',
             DATEADD(DAY, -12, @now), DATEADD(DAY, 18, @now), DATEADD(DAY, 25, @now), 100.00, 1, 3, N'PUBLISHED', @instructor_id, DATEADD(DAY, -8, @now), @now);
    END

    -- =========================================================================
    -- 6. ENROLLMENTS, LESSON COMPLETIONS, PROGRESS & LEARNING HISTORY
    -- =========================================================================
    DECLARE @target_students TABLE (student_id INT);
    INSERT INTO @target_students SELECT @student_id WHERE @student_id IS NOT NULL;
    INSERT INTO @target_students SELECT @personal_id WHERE @personal_id IS NOT NULL;
    INSERT INTO @target_students SELECT @student2_id WHERE @student2_id IS NOT NULL;
    INSERT INTO @target_students SELECT @student3_id WHERE @student3_id IS NOT NULL;

    DECLARE @target_courses TABLE (course_id INT);
    INSERT INTO @target_courses SELECT course_id FROM dbo.courses WHERE course_id IN (@c_spring, @c_java_core, @c_sql_lab, @c_spring_boot, @c_java_basic, @c_sql_paid);

    -- Enroll target students into target courses
    INSERT INTO dbo.enrollments (student_id, course_id, enrolled_at, status)
    SELECT ts.student_id, tc.course_id, DATEADD(DAY, -10, @now), N'ACTIVE'
    FROM @target_students ts
    CROSS JOIN @target_courses tc
    WHERE NOT EXISTS (
        SELECT 1 FROM dbo.enrollments e WHERE e.student_id = ts.student_id AND e.course_id = tc.course_id
    );

    -- Mark Lesson 1 & Lesson 2 completed in Spring MVC, Java Core, and SQL Lab for student@student.com and anhquan050503@gmail.com
    -- (This immediately unlocks the "Bài tập & Quiz" tab in study.jsp!)
    INSERT INTO dbo.lesson_completions (student_id, course_id, lesson_id, completed_at)
    SELECT s.student_id, l.course_id, l.lesson_id, DATEADD(DAY, -5 + l.order_index, @now)
    FROM (SELECT student_id FROM @target_students WHERE student_id IN (@student_id, @personal_id)) s
    JOIN dbo.lessons l ON l.course_id IN (@c_spring, @c_java_core, @c_sql_lab) AND l.order_index IN (1, 2) AND l.status = N'PUBLISHED'
    WHERE NOT EXISTS (
        SELECT 1 FROM dbo.lesson_completions lc WHERE lc.student_id = s.student_id AND lc.lesson_id = l.lesson_id
    );

    -- Mark Lesson 1 completed for student2@student.com
    INSERT INTO dbo.lesson_completions (student_id, course_id, lesson_id, completed_at)
    SELECT @student2_id, l.course_id, l.lesson_id, DATEADD(DAY, -3, @now)
    FROM dbo.lessons l
    WHERE @student2_id IS NOT NULL
      AND l.course_id IN (@c_spring, @c_java_core) AND l.order_index = 1 AND l.status = N'PUBLISHED'
      AND NOT EXISTS (
          SELECT 1 FROM dbo.lesson_completions lc WHERE lc.student_id = @student2_id AND lc.lesson_id = l.lesson_id
      );

    -- Sync learning_progress table for all enrollments
    MERGE dbo.learning_progress AS target
    USING (
        SELECT
            e.student_id,
            e.course_id,
            COUNT(DISTINCT lc.lesson_id) AS completed_cnt,
            (SELECT COUNT(*) FROM dbo.lessons l2 WHERE l2.course_id = e.course_id AND l2.status = N'PUBLISHED') AS total_cnt
        FROM dbo.enrollments e
        LEFT JOIN dbo.lesson_completions lc ON lc.student_id = e.student_id AND lc.course_id = e.course_id
        WHERE e.course_id IN (SELECT course_id FROM @target_courses)
        GROUP BY e.student_id, e.course_id
    ) AS src
    ON (target.student_id = src.student_id AND target.course_id = src.course_id)
    WHEN MATCHED THEN
        UPDATE SET
            completed_lessons = src.completed_cnt,
            total_lessons = CASE WHEN src.total_cnt >= src.completed_cnt THEN src.total_cnt ELSE src.completed_cnt END,
            percent_complete = CASE WHEN src.total_cnt > 0 THEN CAST(ROUND(src.completed_cnt * 100.0 / src.total_cnt, 2) AS DECIMAL(5,2)) ELSE 0 END,
            last_accessed_at = DATEADD(HOUR, -2, @now),
            updated_at = @now
    WHEN NOT MATCHED THEN
        INSERT (student_id, course_id, percent_complete, completed_lessons, total_lessons, last_accessed_at, updated_at)
        VALUES (
            src.student_id,
            src.course_id,
            CASE WHEN src.total_cnt > 0 THEN CAST(ROUND(src.completed_cnt * 100.0 / src.total_cnt, 2) AS DECIMAL(5,2)) ELSE 0 END,
            src.completed_cnt,
            CASE WHEN src.total_cnt >= src.completed_cnt THEN src.total_cnt ELSE src.completed_cnt END,
            DATEADD(HOUR, -2, @now),
            @now
        );

    -- =========================================================================
    -- 7. QUIZ ATTEMPTS, ANSWERS & ASSIGNMENT SUBMISSIONS / GRADES
    -- =========================================================================
    DECLARE @q_sp_final INT = (SELECT TOP 1 quiz_id FROM dbo.quizzes WHERE course_id = @c_spring AND title LIKE N'Đánh giá tổng kết:%');
    DECLARE @q_sp_les1  INT = (SELECT TOP 1 quiz_id FROM dbo.quizzes WHERE course_id = @c_spring AND title LIKE N'Kiểm tra Bài 1:%');
    DECLARE @q_jv_les1  INT = (SELECT TOP 1 quiz_id FROM dbo.quizzes WHERE course_id = @c_java_core);

    -- 7.1 Published & Scored Quiz Attempt for student@student.com & anhquan050503@gmail.com on Final Quiz (@q_sp_final)
    IF @q_sp_final IS NOT NULL
    BEGIN
        DECLARE @stu_cursor INT;
        DECLARE cur_stu CURSOR LOCAL FAST_FORWARD FOR
            SELECT student_id FROM @target_students WHERE student_id IN (@student_id, @personal_id);
        OPEN cur_stu;
        FETCH NEXT FROM cur_stu INTO @stu_cursor;
        WHILE @@FETCH_STATUS = 0
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM dbo.quiz_attempts WHERE quiz_id = @q_sp_final AND student_id = @stu_cursor)
            BEGIN
                INSERT INTO dbo.quiz_attempts (quiz_id, student_id, course_id, attempt_number, started_at, deadline_at, submitted_at, status, score, max_score, result_status, published_by, published_at)
                VALUES (@q_sp_final, @stu_cursor, @c_spring, 1, DATEADD(DAY, -3, @now), DATEADD(MINUTE, -4300, @now), DATEADD(MINUTE, -4310, @now),
                        N'SCORED', 10.00, 10.00, N'PUBLISHED', @instructor_id, DATEADD(DAY, -2, @now));

                DECLARE @att_final_id INT = SCOPE_IDENTITY();

                INSERT INTO dbo.quiz_answers (attempt_id, quiz_id, question_id, answer_text, question_content_snapshot, question_type_snapshot, max_score, awarded_score, graded_by, graded_at)
                SELECT @att_final_id, @q_sp_final, q.question_id,
                       CASE WHEN q.type IN (N'TRUE_FALSE', N'SHORT_ANSWER') THEN q.correct_answer ELSE NULL END,
                       q.content, q.type, q.score, q.score, @instructor_id, DATEADD(DAY, -2, @now)
                FROM dbo.questions q WHERE q.quiz_id = @q_sp_final;
            END
            FETCH NEXT FROM cur_stu INTO @stu_cursor;
        END
        CLOSE cur_stu;
        DEALLOCATE cur_stu;
    END

    -- 7.2 Quiz 1 Attempt with Essay waiting for Instructor Grading (`SUBMITTED` + `UNPUBLISHED`) from student2@student.com
    IF @q_sp_les1 IS NOT NULL AND @student2_id IS NOT NULL
       AND NOT EXISTS (SELECT 1 FROM dbo.quiz_attempts WHERE quiz_id = @q_sp_les1 AND student_id = @student2_id)
    BEGIN
        INSERT INTO dbo.quiz_attempts (quiz_id, student_id, course_id, attempt_number, started_at, deadline_at, submitted_at, status, score, max_score, result_status)
        VALUES (@q_sp_les1, @student2_id, @c_spring, 1, DATEADD(HOUR, -6, @now), DATEADD(MINUTE, -345, @now), DATEADD(MINUTE, -350, @now),
                N'SUBMITTED', 8.00, 10.00, N'UNPUBLISHED');

        DECLARE @att_essay_id INT = SCOPE_IDENTITY();

        INSERT INTO dbo.quiz_answers (attempt_id, quiz_id, question_id, answer_text, question_content_snapshot, question_type_snapshot, max_score, awarded_score)
        SELECT @att_essay_id, @q_sp_les1, q.question_id,
               CASE
                   WHEN q.type = N'ESSAY' THEN N'Theo em, @RequestParam dùng để lấy dữ liệu từ query string do trình duyệt gửi lên Controller, trong khi Model là đối tượng của Spring dùng để truyền các thuộc tính từ Controller xuống file JSP hiển thị.'
                   WHEN q.type IN (N'TRUE_FALSE', N'SHORT_ANSWER') THEN q.correct_answer
                   ELSE NULL
               END,
               q.content, q.type, q.score,
               CASE WHEN q.type = N'ESSAY' THEN NULL ELSE q.score END
        FROM dbo.questions q WHERE q.quiz_id = @q_sp_les1;
    END

    -- 7.3 Scored & READY (Unpublished) Quiz Attempt from student@student.com on Java Quiz (@q_jv_les1) so Instructor can test "Publish All Ready" (UC32)
    IF @q_jv_les1 IS NOT NULL AND @student_id IS NOT NULL
       AND NOT EXISTS (SELECT 1 FROM dbo.quiz_attempts WHERE quiz_id = @q_jv_les1 AND student_id = @student_id)
    BEGIN
        INSERT INTO dbo.quiz_attempts (quiz_id, student_id, course_id, attempt_number, started_at, deadline_at, submitted_at, status, score, max_score, result_status)
        VALUES (@q_jv_les1, @student_id, @c_java_core, 1, DATEADD(DAY, -2, @now), DATEADD(MINUTE, -2865, @now), DATEADD(MINUTE, -2870, @now),
                N'SCORED', 10.00, 10.00, N'UNPUBLISHED');

        DECLARE @att_jv_id INT = SCOPE_IDENTITY();
        INSERT INTO dbo.quiz_answers (attempt_id, quiz_id, question_id, answer_text, question_content_snapshot, question_type_snapshot, max_score, awarded_score, graded_by, graded_at)
        SELECT @att_jv_id, @q_jv_les1, q.question_id, q.correct_answer, q.content, q.type, q.score, q.score, @instructor_id, DATEADD(DAY, -2, @now)
        FROM dbo.questions q WHERE q.quiz_id = @q_jv_les1;
    END

    -- Populate quiz_answer_options for SINGLE_CHOICE & MULTIPLE_CHOICE answers in seeded attempts
    INSERT INTO dbo.quiz_answer_options (answer_id, question_id, option_id, option_content_snapshot)
    SELECT qa.answer_id, qa.question_id, ao.option_id, ao.content
    FROM dbo.quiz_answers qa
    JOIN dbo.answer_options ao ON ao.question_id = qa.question_id AND ao.is_correct = 1
    WHERE NOT EXISTS (
        SELECT 1 FROM dbo.quiz_answer_options qao WHERE qao.answer_id = qa.answer_id AND qao.option_id = ao.option_id
    );

    -- 7.4 Assignment Submissions & Grades
    DECLARE @asg_sp_1 INT = (SELECT TOP 1 assignment_id FROM dbo.assignments WHERE course_id = @c_spring ORDER BY assignment_id ASC);
    DECLARE @asg_sp_2 INT = (SELECT TOP 1 assignment_id FROM dbo.assignments WHERE course_id = @c_spring ORDER BY assignment_id DESC);
    DECLARE @asg_jv_1 INT = (SELECT TOP 1 assignment_id FROM dbo.assignments WHERE course_id = @c_java_core ORDER BY assignment_id ASC);

    -- Graded & PUBLISHED submission for student@student.com and anhquan050503@gmail.com on Assignment 1
    IF @asg_sp_1 IS NOT NULL
    BEGIN
        DECLARE @stu_sub INT;
        DECLARE cur_sub CURSOR LOCAL FAST_FORWARD FOR
            SELECT student_id FROM @target_students WHERE student_id IN (@student_id, @personal_id);
        OPEN cur_sub;
        FETCH NEXT FROM cur_sub INTO @stu_sub;
        WHILE @@FETCH_STATUS = 0
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM dbo.submissions WHERE assignment_id = @asg_sp_1 AND student_id = @stu_sub)
            BEGIN
                INSERT INTO dbo.submissions (assignment_id, student_id, course_id, file_url, answer_text, attempt_number, submitted_at, is_late, status)
                VALUES (@asg_sp_1, @stu_sub, @c_spring, N'https://github.com/edusphere-demo/spring-mvc-flow-report',
                        N'Em đã phân tích chi tiết luồng đi từ CourseDiscoveryController.list() -> CourseDiscoveryService.search() -> CourseRepository.searchCourses() và trả về view courses/list.jsp. Đối với luồng ghi danh: POST /courses/{courseId}/enroll kiểm tra CSRF token và gọi CourseManagementService.enroll().',
                        1, DATEADD(DAY, -4, @now), 0, N'GRADED');

                DECLARE @sub_pub_id INT = SCOPE_IDENTITY();
                INSERT INTO dbo.grades (submission_id, score, max_score, feedback, graded_by, graded_at, result_status, published_by, published_at)
                VALUES (@sub_pub_id, 92.50, 100.00,
                        N'Bài làm rất xuất sắc! Em nắm rất chắc luồng đi từ Controller xuống Service/Repository và giải thích chính xác vai trò của @AuthenticationPrincipal cũng như CSRF token.',
                        @instructor_id, DATEADD(DAY, -3, @now), N'PUBLISHED', @instructor_id, DATEADD(DAY, -3, @now));
            END
            FETCH NEXT FROM cur_sub INTO @stu_sub;
        END
        CLOSE cur_sub;
        DEALLOCATE cur_sub;
    END

    -- Graded but UNPUBLISHED (READY) submission on Assignment 2 for student@student.com (to demo UC32 Publish Results)
    IF @asg_sp_2 IS NOT NULL AND @asg_sp_2 <> @asg_sp_1 AND @student_id IS NOT NULL
       AND NOT EXISTS (SELECT 1 FROM dbo.submissions WHERE assignment_id = @asg_sp_2 AND student_id = @student_id)
    BEGIN
        INSERT INTO dbo.submissions (assignment_id, student_id, course_id, file_url, answer_text, attempt_number, submitted_at, is_late, status)
        VALUES (@asg_sp_2, @student_id, @c_spring, NULL,
                N'Em xin nộp đoạn code xử lý @Valid @ModelAttribute("lessonForm") LessonForm form, BindingResult errors kèm giải thích chi tiết về _csrf.token.',
                1, DATEADD(DAY, -1, @now), 0, N'GRADED');

        DECLARE @sub_ready_id INT = SCOPE_IDENTITY();
        INSERT INTO dbo.grades (submission_id, score, max_score, feedback, graded_by, graded_at, result_status)
        VALUES (@sub_ready_id, 88.00, 100.00,
                N'Code chuẩn xác, xử lý BindingResult đúng vị trí. Đang chờ công bố điểm cuối tuần.',
                @instructor_id, DATEADD(HOUR, -12, @now), N'UNPUBLISHED');
    END

    -- Ungraded (SUBMITTED) submission from student2@student.com on Assignment 1 (for Instructor Grading Demo)
    IF @asg_sp_1 IS NOT NULL AND @student2_id IS NOT NULL
       AND NOT EXISTS (SELECT 1 FROM dbo.submissions WHERE assignment_id = @asg_sp_1 AND student_id = @student2_id)
    BEGIN
        INSERT INTO dbo.submissions (assignment_id, student_id, course_id, file_url, answer_text, attempt_number, submitted_at, is_late, status)
        VALUES (@asg_sp_1, @student2_id, @c_spring, N'https://docs.google.com/document/d/demo-spring-mvc-flow',
                N'Thầy ơi em gửi bài phân tích sơ đồ tuần tự (Sequence Diagram) của luồng đăng ký khóa học và kiểm tra quyền truy cập trong LearningService ạ.',
                1, DATEADD(HOUR, -5, @now), 0, N'SUBMITTED');
    END

    -- =========================================================================
    -- 8. LEARNING HISTORY (UC38)
    -- =========================================================================
    IF NOT EXISTS (SELECT 1 FROM dbo.learning_history)
    BEGIN
        DECLARE @hist_stu INT;
        DECLARE cur_hist CURSOR LOCAL FAST_FORWARD FOR
            SELECT student_id FROM @target_students WHERE student_id IN (@student_id, @personal_id);
        OPEN cur_hist;
        FETCH NEXT FROM cur_hist INTO @hist_stu;
        WHILE @@FETCH_STATUS = 0
        BEGIN
            INSERT INTO dbo.learning_history (student_id, course_id, activity_type, lesson_id, assignment_id, quiz_id, details, occurred_at)
            VALUES
                (@hist_stu, @c_spring,    N'COURSE_ENROLLED',      NULL,          NULL,      NULL,        N'Ghi danh vào khóa học Spring MVC và JSP: hiểu luồng code qua EduSphere', DATEADD(DAY, -10, @now)),
                (@hist_stu, @c_java_core, N'COURSE_ENROLLED',      NULL,          NULL,      NULL,        N'Ghi danh vào khóa học Java nền tảng: từ biến đến ứng dụng quản lý khóa học', DATEADD(DAY, -9, @now)),
                (@hist_stu, @c_spring,    N'LESSON_COMPLETED',     @les_spring_1, NULL,      NULL,        N'Hoàn thành Bài 1: GET request, Controller, Model và JSP nối với nhau thế nào?', DATEADD(DAY, -5, @now)),
                (@hist_stu, @c_spring,    N'LESSON_COMPLETED',     @les_spring_2, NULL,      NULL,        N'Hoàn thành Bài 2: Nhận form với @ModelAttribute và hiển thị lỗi nhập liệu', DATEADD(DAY, -4, @now)),
                (@hist_stu, @c_spring,    N'ASSIGNMENT_SUBMITTED', NULL,          @asg_sp_1, NULL,        N'Nộp bài tập thực hành 1: Phân tích luồng Controller - Service - JSP (Điểm: 92.5/100)', DATEADD(DAY, -4, @now)),
                (@hist_stu, @c_spring,    N'QUIZ_SUBMITTED',       NULL,          NULL,      @q_sp_final, N'Hoàn thành Đánh giá tổng kết: Spring MVC, Validation, JPA & Security (Điểm: 10/10)', DATEADD(DAY, -3, @now)),
                (@hist_stu, @c_java_core, N'LESSON_COMPLETED',     @les_java_1,   NULL,      NULL,        N'Hoàn thành Bài 1: Chạy chương trình Java đầu tiên và hiểu biến, kiểu dữ liệu', DATEADD(DAY, -2, @now));

            FETCH NEXT FROM cur_hist INTO @hist_stu;
        END
        CLOSE cur_hist;
        DEALLOCATE cur_hist;
    END

    -- =========================================================================
    -- 9. STUDY PLANS & PERSONAL TASKS (UC34, UC35, UC36)
    -- =========================================================================
    DECLARE @today DATE = CAST(@now AS DATE);
    DECLARE @monday DATE = DATEADD(DAY, -(DATEPART(WEEKDAY, @today) + @@DATEFIRST - 2) % 7, @today);

    DECLARE @plan_stu INT;
    DECLARE cur_plan CURSOR LOCAL FAST_FORWARD FOR
        SELECT student_id FROM @target_students WHERE student_id IN (@student_id, @personal_id);
    OPEN cur_plan;
    FETCH NEXT FROM cur_plan INTO @plan_stu;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM dbo.study_plans WHERE student_id = @plan_stu)
        BEGIN
            -- Plan 1: Active Plan for current month
            INSERT INTO dbo.study_plans (student_id, title, description, start_date, end_date, timezone, status, created_at)
            VALUES (@plan_stu, N'Kế hoạch chinh phục Spring Boot, JSP & SQL Server (Tháng 11/2026)',
                    N'Lộ trình học tập 90 phút mỗi tối để hoàn thành trọn bộ khóa học Backend Java Web và thực hành làm dự án thực tế trên EduSphere.',
                    DATEADD(DAY, -7, @today), DATEADD(DAY, 25, @today), N'Asia/Ho_Chi_Minh', N'ACTIVE', DATEADD(DAY, -7, @now));

            DECLARE @active_plan_id INT = SCOPE_IDENTITY();

            -- Plan 2: Completed Plan from previous month
            INSERT INTO dbo.study_plans (student_id, title, description, start_date, end_date, timezone, status, created_at)
            VALUES (@plan_stu, N'Ôn tập nền tảng Lập trình Hướng đối tượng Java 17',
                    N'Hoàn thành 4 bài học cốt lõi về biến, phương thức, Class/Object và ArrayList.',
                    DATEADD(DAY, -35, @today), DATEADD(DAY, -8, @today), N'Asia/Ho_Chi_Minh', N'COMPLETED', DATEADD(DAY, -35, @now));

            -- 6 Personal Tasks spread across current week (@monday .. @monday + 6)
            INSERT INTO dbo.personal_tasks (plan_id, student_id, title, notes, course_id, related_lesson_id, related_assignment_id, related_quiz_id, planned_start_at, planned_end_at, status, completed_at)
            VALUES
                (@active_plan_id, @plan_stu,
                 N'Học & ghi chép Bài 1: Luồng GET Request, Controller và JSP',
                 N'Vẽ lại sơ đồ DispatcherServlet -> Controller -> ViewResolver ra sổ tay.',
                 @c_spring, @les_spring_1, NULL, NULL,
                 DATEADD(HOUR, 19, CAST(@monday AS DATETIME2)),
                 DATEADD(HOUR, 21, CAST(@monday AS DATETIME2)),
                 N'DONE', DATEADD(HOUR, 20, CAST(@monday AS DATETIME2))),

                (@active_plan_id, @plan_stu,
                 N'Làm Quiz Bài 1: Kiểm tra kiến thức Controller & Model',
                 N'Mục tiêu đạt tối thiểu 8/10 điểm.',
                 @c_spring, NULL, NULL, @q_sp_les1,
                 DATEADD(HOUR, 19, CAST(DATEADD(DAY, 1, @monday) AS DATETIME2)),
                 DATEADD(HOUR, 20, CAST(DATEADD(DAY, 1, @monday) AS DATETIME2)),
                 N'DONE', DATEADD(HOUR, 20, CAST(DATEADD(DAY, 1, @monday) AS DATETIME2))),

                (@active_plan_id, @plan_stu,
                 N'Hoàn thành Bài tập thực hành 2: Form Validation với @Valid',
                 N'Kiểm tra kỹ vị trí của tham số BindingResult và thẻ CSRF token.',
                 @c_spring, NULL, @asg_sp_2, NULL,
                 DATEADD(HOUR, 19, CAST(DATEADD(DAY, 2, @monday) AS DATETIME2)),
                 DATEADD(HOUR, 21, CAST(DATEADD(DAY, 2, @monday) AS DATETIME2)),
                 N'PENDING', NULL),

                (@active_plan_id, @plan_stu,
                 N'Thực hành truy vấn SQL Server trên SSMS / Docker',
                 N'Tạo bảng tạm #CourseLab và chạy thử khối lệnh BEGIN TRANSACTION / ROLLBACK.',
                 @c_sql_lab, @les_sql_1, NULL, NULL,
                 DATEADD(HOUR, 19, CAST(DATEADD(DAY, 3, @monday) AS DATETIME2)),
                 DATEADD(HOUR, 21, CAST(DATEADD(DAY, 3, @monday) AS DATETIME2)),
                 N'PENDING', NULL),

                (@active_plan_id, @plan_stu,
                 N'Làm bài Đánh giá tổng kết khóa Spring MVC & Security',
                 N'Ôn lại phần @AuthenticationPrincipal và @Transactional trước khi bấm bắt đầu.',
                 @c_spring, NULL, NULL, @q_sp_final,
                 DATEADD(HOUR, 14, CAST(DATEADD(DAY, 5, @monday) AS DATETIME2)),
                 DATEADD(HOUR, 16, CAST(DATEADD(DAY, 5, @monday) AS DATETIME2)),
                 N'PENDING', NULL),

                (@active_plan_id, @plan_stu,
                 N'Tổng kết tuần & Lập lịch học tuần tiếp theo',
                 N'Rà soát tiến độ các khóa đang học tại mục Tiến độ học tập.',
                 NULL, NULL, NULL, NULL,
                 DATEADD(HOUR, 20, CAST(DATEADD(DAY, 6, @monday) AS DATETIME2)),
                 DATEADD(HOUR, 21, CAST(DATEADD(DAY, 6, @monday) AS DATETIME2)),
                 N'PENDING', NULL);
        END
        FETCH NEXT FROM cur_plan INTO @plan_stu;
    END
    CLOSE cur_plan;
    DEALLOCATE cur_plan;

    COMMIT TRANSACTION;
    PRINT '=== Full Demo Seed Data applied successfully! ===';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @ErrLine INT = ERROR_LINE();
    RAISERROR(N'Seed failed at line %d: %s', 16, 1, @ErrLine, @ErrMsg);
END CATCH;
GO
