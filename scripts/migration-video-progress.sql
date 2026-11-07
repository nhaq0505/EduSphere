-- ============================================================
-- Migration: Tạo bảng lesson_watch_progress và bổ sung theo dõi video & mở khóa Quiz
-- Chạy script này trên SQL Server database EduSphere
-- ============================================================
USE EduSphere;
GO

-- 1. Nếu bảng chưa tồn tại thì tạo mới bảng với đầy đủ các cột
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

    -- 2. Nếu bảng đã có sẵn từ trước thì thêm các cột còn thiếu
    IF COL_LENGTH('dbo.lesson_watch_progress', 'watched_segments') IS NULL
    BEGIN
        ALTER TABLE dbo.lesson_watch_progress ADD watched_segments NVARCHAR(MAX) NULL;
        PRINT N'Đã thêm cột watched_segments vào bảng lesson_watch_progress.';
    END
    ELSE
    BEGIN
        PRINT N'Cột watched_segments đã tồn tại.';
    END

    IF COL_LENGTH('dbo.lesson_watch_progress', 'quiz_unlocked') IS NULL
    BEGIN
        ALTER TABLE dbo.lesson_watch_progress ADD quiz_unlocked BIT NOT NULL CONSTRAINT DF_lwp_quiz_unlocked DEFAULT 0;
        PRINT N'Đã thêm cột quiz_unlocked vào bảng lesson_watch_progress.';
    END
    ELSE
    BEGIN
        PRINT N'Cột quiz_unlocked đã tồn tại.';
    END

    -- Cập nhật quiz_unlocked = 1 cho các bản ghi đã đạt watch_percent >= 80 từ trước
    UPDATE dbo.lesson_watch_progress
    SET quiz_unlocked = 1
    WHERE watch_percent >= 80 AND (quiz_unlocked IS NULL OR quiz_unlocked = 0);
END
GO
