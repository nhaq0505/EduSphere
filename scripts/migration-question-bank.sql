-- Migration: Question Bank & Auto Random Quiz
-- Date: 2026-11-05
-- Safe to run multiple times (idempotent)

USE [EduSphere];
GO

-- 1. Bảng question_banks (Ngân hàng câu hỏi riêng của từng giảng viên)
IF OBJECT_ID(N'dbo.question_banks', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.question_banks (
        bank_id INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_question_banks PRIMARY KEY,
        instructor_id INT NOT NULL,
        course_id INT NULL,
        name NVARCHAR(255) NOT NULL,
        description NVARCHAR(MAX) NULL,
        status NVARCHAR(20) NOT NULL CONSTRAINT DF_question_banks_status DEFAULT N'ACTIVE',
        created_at DATETIME2 NOT NULL CONSTRAINT DF_question_banks_created DEFAULT SYSDATETIME(),
        updated_at DATETIME2 NULL,
        CONSTRAINT FK_question_banks_instructor FOREIGN KEY (instructor_id) REFERENCES dbo.users(user_id),
        CONSTRAINT FK_question_banks_course FOREIGN KEY (course_id) REFERENCES dbo.courses(course_id)
    );
    CREATE INDEX IX_question_banks_instructor ON dbo.question_banks(instructor_id);
    PRINT 'Created table dbo.question_banks';
END;
GO

-- 2. Bảng bank_categories (Chuyên đề / Danh mục trong ngân hàng)
IF OBJECT_ID(N'dbo.bank_categories', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.bank_categories (
        category_id INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_bank_categories PRIMARY KEY,
        bank_id INT NOT NULL,
        name NVARCHAR(255) NOT NULL,
        description NVARCHAR(500) NULL,
        order_index INT NOT NULL CONSTRAINT DF_bank_categories_order DEFAULT 1,
        CONSTRAINT FK_bank_categories_bank FOREIGN KEY (bank_id) REFERENCES dbo.question_banks(bank_id) ON DELETE CASCADE
    );
    CREATE INDEX IX_bank_categories_bank ON dbo.bank_categories(bank_id);
    PRINT 'Created table dbo.bank_categories';
END;
GO

-- 3. Bảng bank_questions (Câu hỏi trong ngân hàng)
IF OBJECT_ID(N'dbo.bank_questions', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.bank_questions (
        bank_question_id INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_bank_questions PRIMARY KEY,
        bank_id INT NOT NULL,
        category_id INT NULL,
        content NVARCHAR(MAX) NOT NULL,
        image_url NVARCHAR(500) NULL,
        video_url NVARCHAR(500) NULL,
        type NVARCHAR(30) NOT NULL CONSTRAINT DF_bank_questions_type DEFAULT N'SINGLE_CHOICE',
        difficulty_level NVARCHAR(20) NOT NULL CONSTRAINT DF_bank_questions_diff DEFAULT N'MEDIUM',
        default_score DECIMAL(5,2) NOT NULL CONSTRAINT DF_bank_questions_score DEFAULT 1.0,
        correct_answer NVARCHAR(MAX) NULL,
        explanation NVARCHAR(MAX) NULL,
        sample_essay_answer NVARCHAR(MAX) NULL,
        tags NVARCHAR(500) NULL,
        created_by INT NOT NULL,
        created_at DATETIME2 NOT NULL CONSTRAINT DF_bank_questions_created DEFAULT SYSDATETIME(),
        CONSTRAINT CK_bank_questions_type CHECK (type IN (N'SINGLE_CHOICE', N'MULTIPLE_CHOICE', N'TRUE_FALSE', N'SHORT_ANSWER', N'ESSAY')),
        CONSTRAINT CK_bank_questions_diff CHECK (difficulty_level IN (N'EASY', N'MEDIUM', N'HARD')),
        CONSTRAINT FK_bank_questions_bank FOREIGN KEY (bank_id) REFERENCES dbo.question_banks(bank_id) ON DELETE CASCADE,
        CONSTRAINT FK_bank_questions_category FOREIGN KEY (category_id) REFERENCES dbo.bank_categories(category_id),
        CONSTRAINT FK_bank_questions_author FOREIGN KEY (created_by) REFERENCES dbo.users(user_id)
    );
    CREATE INDEX IX_bank_questions_bank ON dbo.bank_questions(bank_id);
    CREATE INDEX IX_bank_questions_category ON dbo.bank_questions(category_id);
    PRINT 'Created table dbo.bank_questions';
END;
GO

-- 4. Bảng bank_answer_options (Các phương án lựa chọn A, B, C, D)
IF OBJECT_ID(N'dbo.bank_answer_options', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.bank_answer_options (
        option_id INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_bank_answer_options PRIMARY KEY,
        bank_question_id INT NOT NULL,
        content NVARCHAR(MAX) NOT NULL,
        is_correct BIT NOT NULL CONSTRAINT DF_bank_options_correct DEFAULT 0,
        order_index INT NOT NULL CONSTRAINT DF_bank_options_order DEFAULT 1,
        CONSTRAINT FK_bank_options_question FOREIGN KEY (bank_question_id) REFERENCES dbo.bank_questions(bank_question_id) ON DELETE CASCADE
    );
    CREATE INDEX IX_bank_options_question ON dbo.bank_answer_options(bank_question_id);
    PRINT 'Created table dbo.bank_answer_options';
END;
GO

-- 5. Bổ sung trường cho bảng dbo.quizzes
IF COL_LENGTH('dbo.quizzes', 'bank_id') IS NULL
BEGIN
    ALTER TABLE dbo.quizzes ADD bank_id INT NULL;
    ALTER TABLE dbo.quizzes ADD CONSTRAINT FK_quizzes_bank FOREIGN KEY (bank_id) REFERENCES dbo.question_banks(bank_id);
    PRINT 'Added bank_id column to dbo.quizzes';
END;
GO

-- 6. Bổ sung trường cho bảng dbo.questions
IF COL_LENGTH('dbo.questions', 'image_url') IS NULL
BEGIN
    ALTER TABLE dbo.questions ADD image_url NVARCHAR(500) NULL;
    PRINT 'Added image_url to dbo.questions';
END;
GO

IF COL_LENGTH('dbo.questions', 'video_url') IS NULL
BEGIN
    ALTER TABLE dbo.questions ADD video_url NVARCHAR(500) NULL;
    PRINT 'Added video_url to dbo.questions';
END;
GO

IF COL_LENGTH('dbo.questions', 'bank_question_id') IS NULL
BEGIN
    ALTER TABLE dbo.questions ADD bank_question_id INT NULL;
    ALTER TABLE dbo.questions ADD CONSTRAINT FK_questions_bank_question FOREIGN KEY (bank_question_id) REFERENCES dbo.bank_questions(bank_question_id) ON DELETE SET NULL;
    PRINT 'Added bank_question_id to dbo.questions';
END;
GO

IF COL_LENGTH('dbo.questions', 'sample_essay_answer') IS NULL
BEGIN
    ALTER TABLE dbo.questions ADD sample_essay_answer NVARCHAR(MAX) NULL;
    PRINT 'Added sample_essay_answer to dbo.questions';
END;
GO

PRINT '=== Question Bank migration completed successfully ===';
GO

