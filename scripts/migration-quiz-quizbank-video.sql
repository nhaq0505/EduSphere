-- ==============================================================================
-- TỔNG HỢP MIGRATION DATABASE: QUIZ + NGÂN HÀNG CÂU HỎI + TIẾN ĐỘ VIDEO (BUNNY STREAM)
-- Dành cho nhánh: quiz-quizbank-video
-- Hướng dẫn: Mở SSMS (SQL Server Management Studio), kết nối database EduSphere và nhấn F5 (Execute)
-- Script an toàn (idempotent), có thể chạy nhiều lần mà không bị lỗi trùng lặp.
-- ==============================================================================

USE [EduSphere];
GO

PRINT N'----------------------------------------------------------------------';
PRINT N'BẮT ĐẦU CẬP NHẬT DATABASE CHO TÍNH NĂNG QUIZ - QUIZBANK - VIDEO';
PRINT N'----------------------------------------------------------------------';
GO

-- ==============================================================================
-- PHẦN 1: TIẾN ĐỘ VIDEO & TÍCH HỢP BUNNY STREAM CHO BÀI HỌC (LESSONS)
-- ==============================================================================

-- 1.1 Thêm các cột vào dbo.lessons
IF COL_LENGTH('dbo.lessons', 'bunny_video_id') IS NULL
BEGIN
    ALTER TABLE dbo.lessons ADD bunny_video_id NVARCHAR(100) NULL;
    PRINT N'-> Đã thêm cột bunny_video_id vào bảng dbo.lessons';
END;
GO

IF COL_LENGTH('dbo.lessons', 'video_status') IS NULL
BEGIN
    ALTER TABLE dbo.lessons ADD video_status NVARCHAR(20) NULL;
    PRINT N'-> Đã thêm cột video_status vào bảng dbo.lessons';
END;
GO

IF COL_LENGTH('dbo.lessons', 'quiz_requires_video') IS NULL
BEGIN
    ALTER TABLE dbo.lessons ADD quiz_requires_video BIT NOT NULL CONSTRAINT DF_lessons_quiz_requires_video DEFAULT 0;
    PRINT N'-> Đã thêm cột quiz_requires_video vào bảng dbo.lessons';
END;
GO

IF COL_LENGTH('dbo.lessons', 'min_watch_percent') IS NULL
BEGIN
    ALTER TABLE dbo.lessons ADD min_watch_percent INT NOT NULL CONSTRAINT DF_lessons_min_watch_percent DEFAULT 0;
    PRINT N'-> Đã thêm cột min_watch_percent vào bảng dbo.lessons';
END;
GO

-- 1.2 Tạo bảng theo dõi tiến độ xem video (dbo.lesson_watch_progress)
IF OBJECT_ID(N'dbo.lesson_watch_progress', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.lesson_watch_progress (
        watch_id          INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_lesson_watch_progress PRIMARY KEY,
        student_id        INT NOT NULL,
        course_id         INT NOT NULL,
        lesson_id         INT NOT NULL,
        watch_percent     INT NOT NULL CONSTRAINT DF_lwp_percent DEFAULT 0,
        last_position     INT NOT NULL CONSTRAINT DF_lwp_position DEFAULT 0,
        watched_segments  NVARCHAR(MAX) NULL,
        quiz_unlocked     BIT NOT NULL CONSTRAINT DF_lwp_quiz_unlocked DEFAULT 0,
        updated_at        DATETIME2 NOT NULL CONSTRAINT DF_lwp_updated DEFAULT SYSDATETIME(),
        CONSTRAINT UQ_lesson_watch_progress UNIQUE (student_id, lesson_id),
        CONSTRAINT CK_lwp_percent CHECK (watch_percent >= 0 AND watch_percent <= 100),
        CONSTRAINT CK_lwp_position CHECK (last_position >= 0),
        CONSTRAINT FK_lwp_student FOREIGN KEY (student_id) REFERENCES dbo.users(user_id),
        CONSTRAINT FK_lwp_course FOREIGN KEY (course_id) REFERENCES dbo.courses(course_id),
        CONSTRAINT FK_lwp_lesson FOREIGN KEY (lesson_id) REFERENCES dbo.lessons(lesson_id)
    );
    PRINT N'-> Đã tạo mới bảng dbo.lesson_watch_progress';
END
ELSE
BEGIN
    PRINT N'-> Bảng dbo.lesson_watch_progress đã tồn tại. Đang kiểm tra bổ sung cột...';
    IF COL_LENGTH('dbo.lesson_watch_progress', 'watched_segments') IS NULL
    BEGIN
        ALTER TABLE dbo.lesson_watch_progress ADD watched_segments NVARCHAR(MAX) NULL;
        PRINT N'   + Đã thêm cột watched_segments';
    END;

    IF COL_LENGTH('dbo.lesson_watch_progress', 'quiz_unlocked') IS NULL
    BEGIN
        ALTER TABLE dbo.lesson_watch_progress ADD quiz_unlocked BIT NOT NULL CONSTRAINT DF_lwp_quiz_unlocked DEFAULT 0;
        PRINT N'   + Đã thêm cột quiz_unlocked';
    END;

    -- Đồng bộ quiz_unlocked cho các dòng đã xem >= 80%
    UPDATE dbo.lesson_watch_progress
    SET quiz_unlocked = 1
    WHERE watch_percent >= 80 AND (quiz_unlocked IS NULL OR quiz_unlocked = 0);
END;
GO


-- ==============================================================================
-- PHẦN 2: NGÂN HÀNG CÂU HỎI (QUESTION BANK)
-- ==============================================================================

-- 2.1 Bảng question_banks (Ngân hàng câu hỏi)
IF OBJECT_ID(N'dbo.question_banks', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.question_banks (
        bank_id       INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_question_banks PRIMARY KEY,
        instructor_id INT NOT NULL,
        course_id     INT NULL,
        name          NVARCHAR(255) NOT NULL,
        description   NVARCHAR(MAX) NULL,
        status        NVARCHAR(20) NOT NULL CONSTRAINT DF_question_banks_status DEFAULT N'ACTIVE',
        created_at    DATETIME2 NOT NULL CONSTRAINT DF_question_banks_created DEFAULT SYSDATETIME(),
        updated_at    DATETIME2 NULL,
        CONSTRAINT FK_question_banks_instructor FOREIGN KEY (instructor_id) REFERENCES dbo.users(user_id),
        CONSTRAINT FK_question_banks_course FOREIGN KEY (course_id) REFERENCES dbo.courses(course_id)
    );
    CREATE INDEX IX_question_banks_instructor ON dbo.question_banks(instructor_id);
    PRINT N'-> Đã tạo bảng dbo.question_banks';
END;
GO

-- 2.2 Bảng bank_categories (Chuyên đề / Danh mục câu hỏi trong ngân hàng)
IF OBJECT_ID(N'dbo.bank_categories', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.bank_categories (
        category_id INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_bank_categories PRIMARY KEY,
        bank_id     INT NOT NULL,
        name        NVARCHAR(255) NOT NULL,
        description NVARCHAR(500) NULL,
        order_index INT NOT NULL CONSTRAINT DF_bank_categories_order DEFAULT 1,
        CONSTRAINT FK_bank_categories_bank FOREIGN KEY (bank_id) REFERENCES dbo.question_banks(bank_id) ON DELETE CASCADE
    );
    CREATE INDEX IX_bank_categories_bank ON dbo.bank_categories(bank_id);
    PRINT N'-> Đã tạo bảng dbo.bank_categories';
END;
GO

-- 2.3 Bảng bank_questions (Câu hỏi trong ngân hàng)
IF OBJECT_ID(N'dbo.bank_questions', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.bank_questions (
        bank_question_id    INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_bank_questions PRIMARY KEY,
        bank_id             INT NOT NULL,
        category_id         INT NULL,
        content             NVARCHAR(MAX) NOT NULL,
        image_url           NVARCHAR(500) NULL,
        video_url           NVARCHAR(500) NULL,
        type                NVARCHAR(30) NOT NULL CONSTRAINT DF_bank_questions_type DEFAULT N'SINGLE_CHOICE',
        difficulty_level    NVARCHAR(20) NOT NULL CONSTRAINT DF_bank_questions_diff DEFAULT N'MEDIUM',
        default_score       DECIMAL(5,2) NOT NULL CONSTRAINT DF_bank_questions_score DEFAULT 1.0,
        correct_answer      NVARCHAR(MAX) NULL,
        explanation         NVARCHAR(MAX) NULL,
        sample_essay_answer NVARCHAR(MAX) NULL,
        tags                NVARCHAR(500) NULL,
        created_by          INT NOT NULL,
        created_at          DATETIME2 NOT NULL CONSTRAINT DF_bank_questions_created DEFAULT SYSDATETIME(),
        CONSTRAINT CK_bank_questions_type CHECK (type IN (N'SINGLE_CHOICE', N'MULTIPLE_CHOICE', N'TRUE_FALSE', N'SHORT_ANSWER', N'ESSAY')),
        CONSTRAINT CK_bank_questions_diff CHECK (difficulty_level IN (N'EASY', N'MEDIUM', N'HARD')),
        CONSTRAINT FK_bank_questions_bank FOREIGN KEY (bank_id) REFERENCES dbo.question_banks(bank_id) ON DELETE CASCADE,
        CONSTRAINT FK_bank_questions_category FOREIGN KEY (category_id) REFERENCES dbo.bank_categories(category_id),
        CONSTRAINT FK_bank_questions_author FOREIGN KEY (created_by) REFERENCES dbo.users(user_id)
    );
    CREATE INDEX IX_bank_questions_bank ON dbo.bank_questions(bank_id);
    CREATE INDEX IX_bank_questions_category ON dbo.bank_questions(category_id);
    PRINT N'-> Đã tạo bảng dbo.bank_questions';
END;
GO

-- 2.4 Bảng bank_answer_options (Các phương án lựa chọn trong ngân hàng)
IF OBJECT_ID(N'dbo.bank_answer_options', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.bank_answer_options (
        option_id        INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_bank_answer_options PRIMARY KEY,
        bank_question_id INT NOT NULL,
        content          NVARCHAR(MAX) NOT NULL,
        is_correct       BIT NOT NULL CONSTRAINT DF_bank_options_correct DEFAULT 0,
        order_index      INT NOT NULL CONSTRAINT DF_bank_options_order DEFAULT 1,
        CONSTRAINT FK_bank_options_question FOREIGN KEY (bank_question_id) REFERENCES dbo.bank_questions(bank_question_id) ON DELETE CASCADE
    );
    CREATE INDEX IX_bank_options_question ON dbo.bank_answer_options(bank_question_id);
    PRINT N'-> Đã tạo bảng dbo.bank_answer_options';
END;
GO

-- ==============================================================================
-- PHẦN 3: LIÊN KẾT QUIZ VỚI NGÂN HÀNG CÂU HỎI & CÁC TRƯỜNG MỞ RỘNG
-- ==============================================================================

-- 3.1 Bổ sung bank_id vào dbo.quizzes
IF COL_LENGTH('dbo.quizzes', 'bank_id') IS NULL
BEGIN
    ALTER TABLE dbo.quizzes ADD bank_id INT NULL;
    PRINT N'-> Đã thêm cột bank_id vào bảng dbo.quizzes';
END;
GO

-- 3.2 Bổ sung các cột mở rộng vào dbo.questions
IF COL_LENGTH('dbo.questions', 'image_url') IS NULL
BEGIN
    ALTER TABLE dbo.questions ADD image_url NVARCHAR(500) NULL;
    PRINT N'-> Đã thêm cột image_url vào dbo.questions';
END;
GO

IF COL_LENGTH('dbo.questions', 'video_url') IS NULL
BEGIN
    ALTER TABLE dbo.questions ADD video_url NVARCHAR(500) NULL;
    PRINT N'-> Đã thêm cột video_url vào dbo.questions';
END;
GO

IF COL_LENGTH('dbo.questions', 'bank_question_id') IS NULL
BEGIN
    ALTER TABLE dbo.questions ADD bank_question_id INT NULL;
    PRINT N'-> Đã thêm cột bank_question_id vào dbo.questions';
END;
GO

IF COL_LENGTH('dbo.questions', 'sample_essay_answer') IS NULL
BEGIN
    ALTER TABLE dbo.questions ADD sample_essay_answer NVARCHAR(MAX) NULL;
    PRINT N'-> Đã thêm cột sample_essay_answer vào dbo.questions';
END;
GO

-- 3.3 Thiết lập khóa ngoại với hành động ON DELETE SET NULL an toàn
IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_questions_bank_question')
BEGIN
    ALTER TABLE dbo.questions DROP CONSTRAINT FK_questions_bank_question;
END;
GO
ALTER TABLE dbo.questions ADD CONSTRAINT FK_questions_bank_question 
    FOREIGN KEY (bank_question_id) REFERENCES dbo.bank_questions(bank_question_id) ON DELETE SET NULL;
PRINT N'-> Đã cấu hình FK_questions_bank_question (ON DELETE SET NULL)';
GO

IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_quizzes_bank')
BEGIN
    ALTER TABLE dbo.quizzes DROP CONSTRAINT FK_quizzes_bank;
END;
GO
ALTER TABLE dbo.quizzes ADD CONSTRAINT FK_quizzes_bank 
    FOREIGN KEY (bank_id) REFERENCES dbo.question_banks(bank_id) ON DELETE SET NULL;
PRINT N'-> Đã cấu hình FK_quizzes_bank (ON DELETE SET NULL)';
GO

PRINT N'----------------------------------------------------------------------';
PRINT N'===> CHÚC MỪNG: CƠ SỞ DỮ LIỆU ĐÃ ĐƯỢC CẬP NHẬT HOÀN TOÀN THÀNH CÔNG! <===';
PRINT N'----------------------------------------------------------------------';
GO
