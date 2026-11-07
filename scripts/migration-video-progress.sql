-- ==============================================================================
-- Migration: Bổ sung các cột Bunny Stream cho bảng lessons và tạo bảng lesson_watch_progress
-- Chạy script này trên SQL Server Management Studio (SSMS) database EduSphere (cổng 1433)
-- ==============================================================================
USE EduSphere;
GO

-- 1. Bổ sung các cột mới vào bảng dbo.lessons (nếu chưa có)
IF COL_LENGTH('dbo.lessons', 'bunny_video_id') IS NULL
BEGIN
    ALTER TABLE dbo.lessons ADD bunny_video_id NVARCHAR(100) NULL;
    PRINT N'Đã thêm cột bunny_video_id vào bảng lessons.';
END;
GO

IF COL_LENGTH('dbo.lessons', 'video_status') IS NULL
BEGIN
    ALTER TABLE dbo.lessons ADD video_status NVARCHAR(20) NULL;
    PRINT N'Đã thêm cột video_status vào bảng lessons.';
END;
GO

IF COL_LENGTH('dbo.lessons', 'quiz_requires_video') IS NULL
BEGIN
    ALTER TABLE dbo.lessons ADD quiz_requires_video BIT NOT NULL CONSTRAINT DF_lessons_quiz_requires_video DEFAULT 0;
    PRINT N'Đã thêm cột quiz_requires_video vào bảng lessons.';
END;
GO

IF COL_LENGTH('dbo.lessons', 'min_watch_percent') IS NULL
BEGIN
    ALTER TABLE dbo.lessons ADD min_watch_percent INT NOT NULL CONSTRAINT DF_lessons_min_watch_percent DEFAULT 0;
    PRINT N'Đã thêm cột min_watch_percent vào bảng lessons.';
END;
GO

-- 2. Kiểm tra và tạo bảng dbo.lesson_watch_progress (nếu chưa có)
IF OBJECT_ID(N'dbo.lesson_watch_progress', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.lesson_watch_progress (
        watch_id          INT IDENTITY(1,1) NOT NULL
            CONSTRAINT PK_lesson_watch_progress PRIMARY KEY,
        student_id        INT NOT NULL,
        course_id         INT NOT NULL,
        lesson_id         INT NOT NULL,
        watch_percent     INT NOT NULL
            CONSTRAINT DF_lwp_percent DEFAULT 0,
        last_position     INT NOT NULL
            CONSTRAINT DF_lwp_position DEFAULT 0,
        watched_segments  NVARCHAR(MAX) NULL,
        quiz_unlocked     BIT NOT NULL
            CONSTRAINT DF_lwp_quiz_unlocked DEFAULT 0,
        updated_at        DATETIME2 NOT NULL
            CONSTRAINT DF_lwp_updated DEFAULT SYSDATETIME(),
        CONSTRAINT UQ_lesson_watch_progress UNIQUE (student_id, lesson_id),
        CONSTRAINT CK_lwp_percent CHECK (watch_percent >= 0 AND watch_percent <= 100),
        CONSTRAINT CK_lwp_position CHECK (last_position >= 0),
        CONSTRAINT FK_lwp_student FOREIGN KEY (student_id)
            REFERENCES dbo.users(user_id),
        CONSTRAINT FK_lwp_course FOREIGN KEY (course_id)
            REFERENCES dbo.courses(course_id),
        CONSTRAINT FK_lwp_lesson FOREIGN KEY (lesson_id)
            REFERENCES dbo.lessons(lesson_id)
    );
    PRINT N'Đã tạo bảng dbo.lesson_watch_progress thành công.';
END
ELSE
BEGIN
    PRINT N'Bảng dbo.lesson_watch_progress đã tồn tại. Đang kiểm tra bổ sung cột...';

    IF COL_LENGTH('dbo.lesson_watch_progress', 'watched_segments') IS NULL
    BEGIN
        ALTER TABLE dbo.lesson_watch_progress ADD watched_segments NVARCHAR(MAX) NULL;
        PRINT N'Đã thêm cột watched_segments vào bảng lesson_watch_progress.';
    END;

    IF COL_LENGTH('dbo.lesson_watch_progress', 'quiz_unlocked') IS NULL
    BEGIN
        ALTER TABLE dbo.lesson_watch_progress ADD quiz_unlocked BIT NOT NULL CONSTRAINT DF_lwp_quiz_unlocked DEFAULT 0;
        PRINT N'Đã thêm cột quiz_unlocked vào bảng lesson_watch_progress.';
    END;

    UPDATE dbo.lesson_watch_progress
    SET quiz_unlocked = 1
    WHERE watch_percent >= 80 AND (quiz_unlocked IS NULL OR quiz_unlocked = 0);
END;
GO

PRINT N'====> HOÀN TẤT CẬP NHẬT CƠ SỞ DỮ LIỆU THÀNH CÔNG! <====';
GO
