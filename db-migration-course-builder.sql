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

