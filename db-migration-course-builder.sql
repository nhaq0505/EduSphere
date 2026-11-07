-- Migration for Course Creation Flow (5 Steps Builder)
-- Sections, Promo Video, Objectives, Requirements, Rich Lessons, Drip Content, Preview

IF OBJECT_ID(N'dbo.course_sections', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.course_sections (
        section_id INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_course_sections PRIMARY KEY,
        course_id INT NOT NULL CONSTRAINT FK_course_sections_course FOREIGN KEY REFERENCES dbo.courses(course_id),
        title NVARCHAR(255) NOT NULL,
        description NVARCHAR(MAX) NULL,
        order_index INT NOT NULL,
        created_at DATETIME2 NOT NULL CONSTRAINT DF_course_sections_created DEFAULT SYSDATETIME(),
        updated_at DATETIME2 NULL
    );
END;

IF COL_LENGTH('dbo.courses', 'promo_video_url') IS NULL
    ALTER TABLE dbo.courses ADD promo_video_url NVARCHAR(2048) NULL;

IF COL_LENGTH('dbo.courses', 'objectives') IS NULL
    ALTER TABLE dbo.courses ADD objectives NVARCHAR(MAX) NULL;

IF COL_LENGTH('dbo.courses', 'requirements') IS NULL
    ALTER TABLE dbo.courses ADD requirements NVARCHAR(MAX) NULL;

IF COL_LENGTH('dbo.lessons', 'section_id') IS NULL
    ALTER TABLE dbo.lessons ADD section_id INT NULL CONSTRAINT FK_lessons_section FOREIGN KEY REFERENCES dbo.course_sections(section_id);

IF COL_LENGTH('dbo.lessons', 'lesson_type') IS NULL
    ALTER TABLE dbo.lessons ADD lesson_type NVARCHAR(20) NOT NULL CONSTRAINT DF_lessons_type DEFAULT N'ARTICLE';

IF COL_LENGTH('dbo.lessons', 'video_url') IS NULL
    ALTER TABLE dbo.lessons ADD video_url NVARCHAR(2048) NULL;

IF COL_LENGTH('dbo.lessons', 'video_duration') IS NULL
    ALTER TABLE dbo.lessons ADD video_duration INT NULL;

IF COL_LENGTH('dbo.lessons', 'allow_seek') IS NULL
    ALTER TABLE dbo.lessons ADD allow_seek BIT NOT NULL CONSTRAINT DF_lessons_seek DEFAULT 1;

IF COL_LENGTH('dbo.lessons', 'is_preview') IS NULL
    ALTER TABLE dbo.lessons ADD is_preview BIT NOT NULL CONSTRAINT DF_lessons_preview DEFAULT 0;

IF COL_LENGTH('dbo.lessons', 'unlock_days_after_enroll') IS NULL
    ALTER TABLE dbo.lessons ADD unlock_days_after_enroll INT NULL;

IF COL_LENGTH('dbo.lessons', 'prerequisite_lesson_id') IS NULL
    ALTER TABLE dbo.lessons ADD prerequisite_lesson_id INT NULL CONSTRAINT FK_lessons_prerequisite FOREIGN KEY REFERENCES dbo.lessons(lesson_id);

IF COL_LENGTH('dbo.lessons', 'instructor_notes') IS NULL
    ALTER TABLE dbo.lessons ADD instructor_notes NVARCHAR(MAX) NULL;


-- ═══════════════════════════════════════════════════
-- Migration: Tích hợp Bunny Stream
-- Thêm bunny_video_id và video_status vào bảng lessons
-- ═══════════════════════════════════════════════════
IF COL_LENGTH('dbo.lessons', 'bunny_video_id') IS NULL
    ALTER TABLE dbo.lessons ADD bunny_video_id NVARCHAR(100) NULL;
GO

IF COL_LENGTH('dbo.lessons', 'video_status') IS NULL
    ALTER TABLE dbo.lessons ADD video_status NVARCHAR(20) NULL;
GO

-- ═══════════════════════════════════════════════════════════════
-- Migration: Video Seek Control + Quiz Unlock + Watch Progress
-- ═══════════════════════════════════════════════════════════════

-- Thêm: Bắt buộc xem video trước khi làm Quiz (mặc định false)
IF COL_LENGTH('dbo.lessons', 'quiz_requires_video') IS NULL
    ALTER TABLE dbo.lessons ADD quiz_requires_video BIT NOT NULL
        CONSTRAINT DF_lessons_quiz_requires_video DEFAULT 0;
GO

-- Thêm: Ngưỡng % xem tối thiểu để video coi là "đã xem" (0 = không yêu cầu, 100 = xem hết)
IF COL_LENGTH('dbo.lessons', 'min_watch_percent') IS NULL
    ALTER TABLE dbo.lessons ADD min_watch_percent INT NOT NULL
        CONSTRAINT DF_lessons_min_watch_percent DEFAULT 0;
GO

-- Bảng lưu tiến độ xem video của từng học viên cho từng bài học
IF OBJECT_ID(N'dbo.lesson_watch_progress', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.lesson_watch_progress (
        watch_id       INT IDENTITY(1,1) NOT NULL
            CONSTRAINT PK_lesson_watch_progress PRIMARY KEY,
        student_id     INT NOT NULL,
        course_id      INT NOT NULL,
        lesson_id      INT NOT NULL,
        watch_percent  INT NOT NULL
            CONSTRAINT DF_lwp_percent DEFAULT 0,
        last_position  INT NOT NULL
            CONSTRAINT DF_lwp_position DEFAULT 0,
        watched_segments NVARCHAR(MAX) NULL,
        quiz_unlocked  BIT NOT NULL
            CONSTRAINT DF_lwp_quiz_unlocked DEFAULT 0,
        updated_at     DATETIME2 NOT NULL
            CONSTRAINT DF_lwp_updated DEFAULT SYSDATETIME(),
        CONSTRAINT UQ_lesson_watch_progress UNIQUE (student_id, lesson_id),
        CONSTRAINT CK_lwp_percent CHECK (watch_percent >= 0 AND watch_percent <= 100),
        CONSTRAINT CK_lwp_position CHECK (last_position >= 0),
        CONSTRAINT FK_lwp_enrollment FOREIGN KEY (student_id, course_id)
            REFERENCES dbo.enrollments(student_id, course_id),
        CONSTRAINT FK_lwp_lesson FOREIGN KEY (course_id, lesson_id)
            REFERENCES dbo.lessons(course_id, lesson_id)
    );
END;
GO

