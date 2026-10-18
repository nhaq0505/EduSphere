-- EduSphere complete SQL Server schema v1.0 | 05/10/2026
-- Scope: UC01-UC44 core and UC45-UC50 optional extensions.
-- Run this entire file in SSMS or sqlcmd. No SQLCMD-mode variables required.
-- Creates EduSphere if absent; creates only missing tables/indexes; seeds missing roles.
-- Supports fresh databases and the original six-table authentication schema.
-- Existing records are preserved. No DROP/TRUNCATE/DELETE of application data.
-- Validates column layouts, keys/FKs and enabled checks/defaults; errors roll back.
-- This is a schema bootstrap, not an automatic migration engine for arbitrary changes.
--
-- Application services must enforce actor roles, ownership, valid state transitions,
-- max attempts/deadlines, payment verification, certificate eligibility and AI access.
-- Dates use DATETIME2; configure one consistent timezone in JDBC and the application.
-- Archived/locked records retain history. New foreign keys use NO ACTION deliberately.
-- OTP uniqueness remains compatible with the existing findByToken repositories.
-- No default Administrator password/account or external-service secrets are included.
--
USE [master];
GO
IF DB_ID(N'EduSphere') IS NULL
    CREATE DATABASE [EduSphere];
GO
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
    DECLARE @lock_result INT;
    EXEC @lock_result = sys.sp_getapplock
        @Resource = N'EduSphere_schema_v1', @LockMode = N'Exclusive',
        @LockOwner = N'Transaction', @LockTimeout = 60000;
    IF @lock_result < 0
        THROW 50000, 'Could not acquire the EduSphere schema lock.', 1;


-- UC01-UC08: Existing authentication mappings are preserved.
IF OBJECT_ID(N'dbo.roles', N'U') IS NULL
BEGIN
CREATE TABLE dbo.roles (
    role_id INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_roles PRIMARY KEY,
    role_name NVARCHAR(50) NOT NULL CONSTRAINT UQ_roles_name UNIQUE
);
END;
IF OBJECT_ID(N'dbo.users', N'U') IS NULL
BEGIN
CREATE TABLE dbo.users (
    user_id INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_users PRIMARY KEY,
    full_name NVARCHAR(100) NOT NULL,
    email NVARCHAR(255) NOT NULL CONSTRAINT UQ_users_email UNIQUE,
    password_hash NVARCHAR(255) NULL,
    phone NVARCHAR(20) NULL,
    avatar_url NVARCHAR(500) NULL,
    status NVARCHAR(20) NOT NULL CONSTRAINT DF_users_status DEFAULT N'PENDING',
    created_at DATETIME2 NOT NULL CONSTRAINT DF_users_created DEFAULT SYSDATETIME(),
    updated_at DATETIME2 NULL,
    CONSTRAINT CK_users_status CHECK (status IN (N'PENDING', N'ACTIVE', N'LOCKED'))
);
END;
IF OBJECT_ID(N'dbo.user_roles', N'U') IS NULL
BEGIN
CREATE TABLE dbo.user_roles (
    user_id INT NOT NULL,
    role_id INT NOT NULL,
    assigned_at DATETIME2 NOT NULL CONSTRAINT DF_user_roles_assigned DEFAULT SYSDATETIME(),
    CONSTRAINT PK_user_roles PRIMARY KEY (user_id, role_id),
    CONSTRAINT FK_user_roles_user FOREIGN KEY (user_id) REFERENCES dbo.users(user_id) ON DELETE CASCADE,
    CONSTRAINT FK_user_roles_role FOREIGN KEY (role_id) REFERENCES dbo.roles(role_id) ON DELETE CASCADE
);
END;
IF OBJECT_ID(N'dbo.email_verification_tokens', N'U') IS NULL
BEGIN
CREATE TABLE dbo.email_verification_tokens (
    token_id INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_email_verification_tokens PRIMARY KEY,
    user_id INT NOT NULL,
    token NVARCHAR(255) NOT NULL CONSTRAINT UQ_email_verification_token UNIQUE,
    expires_at DATETIME2 NOT NULL,
    verified_at DATETIME2 NULL,
    CONSTRAINT FK_email_verification_user FOREIGN KEY (user_id) REFERENCES dbo.users(user_id) ON DELETE CASCADE
);
END;
IF OBJECT_ID(N'dbo.password_reset_tokens', N'U') IS NULL
BEGIN
CREATE TABLE dbo.password_reset_tokens (
    token_id INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_password_reset_tokens PRIMARY KEY,
    user_id INT NOT NULL,
    token NVARCHAR(255) NOT NULL CONSTRAINT UQ_password_reset_token UNIQUE,
    expires_at DATETIME2 NOT NULL,
    used_at DATETIME2 NULL,
    CONSTRAINT FK_password_reset_user FOREIGN KEY (user_id) REFERENCES dbo.users(user_id) ON DELETE CASCADE
);
END;
IF OBJECT_ID(N'dbo.oauth_accounts', N'U') IS NULL
BEGIN
CREATE TABLE dbo.oauth_accounts (
    oauth_id INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_oauth_accounts PRIMARY KEY,
    user_id INT NOT NULL,
    provider NVARCHAR(50) NOT NULL,
    provider_user_id NVARCHAR(255) NOT NULL,
    created_at DATETIME2 NOT NULL CONSTRAINT DF_oauth_created DEFAULT SYSDATETIME(),
    CONSTRAINT UQ_oauth_provider_user UNIQUE (provider, provider_user_id),
    CONSTRAINT FK_oauth_user FOREIGN KEY (user_id) REFERENCES dbo.users(user_id) ON DELETE CASCADE
);
END;
IF OBJECT_ID(N'dbo.account_events', N'U') IS NULL
BEGIN
CREATE TABLE dbo.account_events (
    event_id BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_account_events PRIMARY KEY,
    user_id INT NOT NULL,
    actor_id INT NOT NULL,
    role_id INT NULL,
    action NVARCHAR(30) NOT NULL,
    reason NVARCHAR(1000) NULL,
    created_at DATETIME2 NOT NULL CONSTRAINT DF_account_events_created DEFAULT SYSDATETIME(),
    CONSTRAINT CK_account_events_action CHECK (action IN (N'ROLE_GRANTED', N'ROLE_REVOKED', N'LOCKED', N'RESTORED')),
    CONSTRAINT CK_account_events_role CHECK ((action IN (N'ROLE_GRANTED', N'ROLE_REVOKED') AND role_id IS NOT NULL) OR (action IN (N'LOCKED', N'RESTORED') AND role_id IS NULL)),
    CONSTRAINT FK_account_events_user FOREIGN KEY (user_id) REFERENCES dbo.users(user_id),
    CONSTRAINT FK_account_events_actor FOREIGN KEY (actor_id) REFERENCES dbo.users(user_id),
    CONSTRAINT FK_account_events_role FOREIGN KEY (role_id) REFERENCES dbo.roles(role_id)
);
END;

-- UC09-UC19: Course discovery, review and enrollment.
IF OBJECT_ID(N'dbo.categories', N'U') IS NULL
BEGIN
CREATE TABLE dbo.categories (
    category_id INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_categories PRIMARY KEY,
    name NVARCHAR(100) NOT NULL,
    description NVARCHAR(2000) NULL,
    parent_category_id INT NULL,
    status NVARCHAR(20) NOT NULL CONSTRAINT DF_categories_status DEFAULT N'ACTIVE',
    CONSTRAINT UQ_categories_name UNIQUE (parent_category_id, name),
    CONSTRAINT CK_categories_status CHECK (status IN (N'ACTIVE', N'ARCHIVED')),
    CONSTRAINT CK_categories_parent CHECK (parent_category_id IS NULL OR parent_category_id <> category_id),
    CONSTRAINT FK_categories_parent FOREIGN KEY (parent_category_id) REFERENCES dbo.categories(category_id)
);
END;
IF OBJECT_ID(N'dbo.courses', N'U') IS NULL
BEGIN
CREATE TABLE dbo.courses (
    course_id INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_courses PRIMARY KEY,
    title NVARCHAR(255) NOT NULL,
    description NVARCHAR(MAX) NULL,
    category_id INT NULL,
    instructor_id INT NOT NULL,
    level NVARCHAR(20) NOT NULL CONSTRAINT DF_courses_level DEFAULT N'ALL_LEVELS',
    price DECIMAL(18,2) NOT NULL CONSTRAINT DF_courses_price DEFAULT 0,
    currency CHAR(3) NOT NULL CONSTRAINT DF_courses_currency DEFAULT 'VND',
    thumbnail_url NVARCHAR(2048) NULL,
    status NVARCHAR(20) NOT NULL CONSTRAINT DF_courses_status DEFAULT N'DRAFT',
    version_no INT NOT NULL CONSTRAINT DF_courses_version DEFAULT 1,
    created_at DATETIME2 NOT NULL CONSTRAINT DF_courses_created DEFAULT SYSDATETIME(),
    updated_at DATETIME2 NULL,
    submitted_at DATETIME2 NULL,
    approved_at DATETIME2 NULL,
    published_at DATETIME2 NULL,
    archived_at DATETIME2 NULL,
    CONSTRAINT CK_courses_status CHECK (status IN (N'DRAFT', N'SUBMITTED', N'APPROVED', N'REJECTED', N'PUBLISHED', N'ARCHIVED')),
    CONSTRAINT CK_courses_level CHECK (level IN (N'BEGINNER', N'INTERMEDIATE', N'ADVANCED', N'ALL_LEVELS')),
    CONSTRAINT CK_courses_price CHECK (price >= 0),
    CONSTRAINT CK_courses_version CHECK (version_no >= 1),
    CONSTRAINT CK_courses_approval CHECK (status NOT IN (N'APPROVED', N'PUBLISHED') OR approved_at IS NOT NULL),
    CONSTRAINT CK_courses_publication CHECK (status <> N'PUBLISHED' OR (published_at IS NOT NULL AND published_at >= approved_at)),
    CONSTRAINT CK_courses_archive CHECK (status <> N'ARCHIVED' OR archived_at IS NOT NULL),
    CONSTRAINT FK_courses_category FOREIGN KEY (category_id) REFERENCES dbo.categories(category_id),
    CONSTRAINT FK_courses_instructor FOREIGN KEY (instructor_id) REFERENCES dbo.users(user_id)
);
END;
IF OBJECT_ID(N'dbo.course_reviews', N'U') IS NULL
BEGIN
CREATE TABLE dbo.course_reviews (
    review_id INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_course_reviews PRIMARY KEY,
    course_id INT NOT NULL,
    course_version INT NOT NULL,
    admin_id INT NOT NULL,
    decision NVARCHAR(20) NOT NULL,
    comment NVARCHAR(2000) NULL,
    reviewed_at DATETIME2 NOT NULL CONSTRAINT DF_course_reviews_reviewed DEFAULT SYSDATETIME(),
    CONSTRAINT CK_course_reviews_decision CHECK (decision IN (N'APPROVED', N'REJECTED')),
    CONSTRAINT CK_course_reviews_version CHECK (course_version >= 1),
    CONSTRAINT CK_course_reviews_rejection CHECK (decision <> N'REJECTED' OR (comment IS NOT NULL AND LEN(LTRIM(RTRIM(comment))) > 0)),
    CONSTRAINT FK_course_reviews_course FOREIGN KEY (course_id) REFERENCES dbo.courses(course_id),
    CONSTRAINT FK_course_reviews_admin FOREIGN KEY (admin_id) REFERENCES dbo.users(user_id)
);
END;

-- UC45 extension: Created here because enrollments may reference a payment.
IF OBJECT_ID(N'dbo.payments', N'U') IS NULL
BEGIN
CREATE TABLE dbo.payments (
    payment_id INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_payments PRIMARY KEY,
    student_id INT NOT NULL,
    course_id INT NOT NULL,
    provider NVARCHAR(50) NOT NULL,
    provider_transaction_id NVARCHAR(255) NULL,
    request_key NVARCHAR(100) NOT NULL CONSTRAINT UQ_payments_request UNIQUE,
    checkout_url NVARCHAR(2048) NULL,
    amount DECIMAL(18,2) NOT NULL,
    currency CHAR(3) NOT NULL CONSTRAINT DF_payments_currency DEFAULT 'VND',
    status NVARCHAR(20) NOT NULL CONSTRAINT DF_payments_status DEFAULT N'INITIATED',
    created_at DATETIME2 NOT NULL CONSTRAINT DF_payments_created DEFAULT SYSDATETIME(),
    completed_at DATETIME2 NULL,
    CONSTRAINT UQ_payments_owner UNIQUE (student_id, course_id, payment_id),
    CONSTRAINT CK_payments_amount CHECK (amount > 0),
    CONSTRAINT CK_payments_status CHECK (status IN (N'INITIATED', N'PENDING', N'SUCCEEDED', N'FAILED', N'CANCELLED', N'REFUNDED')),
    CONSTRAINT CK_payments_completed CHECK (status NOT IN (N'SUCCEEDED', N'REFUNDED') OR completed_at IS NOT NULL),
    CONSTRAINT FK_payments_student FOREIGN KEY (student_id) REFERENCES dbo.users(user_id),
    CONSTRAINT FK_payments_course FOREIGN KEY (course_id) REFERENCES dbo.courses(course_id)
);
END;
IF COL_LENGTH(N'dbo.payments', N'checkout_url') IS NULL
    ALTER TABLE dbo.payments ADD checkout_url NVARCHAR(2048) NULL;
IF OBJECT_ID(N'dbo.payment_events', N'U') IS NULL
BEGIN
CREATE TABLE dbo.payment_events (
    event_id BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_payment_events PRIMARY KEY,
    payment_id INT NOT NULL,
    provider_event_id NVARCHAR(255) NOT NULL,
    event_type NVARCHAR(50) NOT NULL,
    payload NVARCHAR(MAX) NULL,
    signature_verified BIT NOT NULL CONSTRAINT DF_payment_events_verified DEFAULT 0,
    received_at DATETIME2 NOT NULL CONSTRAINT DF_payment_events_received DEFAULT SYSDATETIME(),
    processed_at DATETIME2 NULL,
    CONSTRAINT UQ_payment_events_provider UNIQUE (payment_id, provider_event_id),
    CONSTRAINT FK_payment_events_payment FOREIGN KEY (payment_id) REFERENCES dbo.payments(payment_id)
);
END;
IF OBJECT_ID(N'dbo.refunds', N'U') IS NULL
BEGIN
CREATE TABLE dbo.refunds (
    refund_id INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_refunds PRIMARY KEY,
    payment_id INT NOT NULL,
    request_key NVARCHAR(100) NOT NULL CONSTRAINT UQ_refunds_request UNIQUE,
    amount DECIMAL(18,2) NOT NULL,
    reason NVARCHAR(2000) NULL,
    status NVARCHAR(20) NOT NULL CONSTRAINT DF_refunds_status DEFAULT N'REQUESTED',
    processed_by INT NULL,
    created_at DATETIME2 NOT NULL CONSTRAINT DF_refunds_created DEFAULT SYSDATETIME(),
    processed_at DATETIME2 NULL,
    CONSTRAINT CK_refunds_amount CHECK (amount > 0),
    CONSTRAINT CK_refunds_status CHECK (status IN (N'REQUESTED', N'APPROVED', N'REJECTED', N'COMPLETED', N'FAILED')),
    CONSTRAINT FK_refunds_payment FOREIGN KEY (payment_id) REFERENCES dbo.payments(payment_id),
    CONSTRAINT FK_refunds_processor FOREIGN KEY (processed_by) REFERENCES dbo.users(user_id)
);
END;
IF OBJECT_ID(N'dbo.enrollments', N'U') IS NULL
BEGIN
CREATE TABLE dbo.enrollments (
    enrollment_id INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_enrollments PRIMARY KEY,
    student_id INT NOT NULL,
    course_id INT NOT NULL,
    payment_id INT NULL,
    enrolled_at DATETIME2 NOT NULL CONSTRAINT DF_enrollments_enrolled DEFAULT SYSDATETIME(),
    status NVARCHAR(20) NOT NULL CONSTRAINT DF_enrollments_status DEFAULT N'ACTIVE',
    completed_at DATETIME2 NULL,
    dropped_at DATETIME2 NULL,
    CONSTRAINT UQ_enrollments_student_course UNIQUE (student_id, course_id),
    CONSTRAINT CK_enrollments_status CHECK (status IN (N'ACTIVE', N'COMPLETED', N'DROPPED')),
    CONSTRAINT CK_enrollments_completed CHECK (status <> N'COMPLETED' OR completed_at IS NOT NULL),
    CONSTRAINT CK_enrollments_dropped CHECK (status <> N'DROPPED' OR dropped_at IS NOT NULL),
    CONSTRAINT FK_enrollments_student FOREIGN KEY (student_id) REFERENCES dbo.users(user_id),
    CONSTRAINT FK_enrollments_course FOREIGN KEY (course_id) REFERENCES dbo.courses(course_id),
    CONSTRAINT FK_enrollments_payment FOREIGN KEY (student_id, course_id, payment_id) REFERENCES dbo.payments(student_id, course_id, payment_id)
);
END;

-- UC20-UC23 and UC49: Lessons, materials and optional video processing.
IF OBJECT_ID(N'dbo.lessons', N'U') IS NULL
BEGIN
CREATE TABLE dbo.lessons (
    lesson_id INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_lessons PRIMARY KEY,
    course_id INT NOT NULL,
    title NVARCHAR(255) NOT NULL,
    content NVARCHAR(MAX) NULL,
    order_index INT NOT NULL,
    status NVARCHAR(20) NOT NULL CONSTRAINT DF_lessons_status DEFAULT N'DRAFT',
    created_at DATETIME2 NOT NULL CONSTRAINT DF_lessons_created DEFAULT SYSDATETIME(),
    updated_at DATETIME2 NULL,
    CONSTRAINT UQ_lessons_order UNIQUE (course_id, order_index),
    CONSTRAINT UQ_lessons_course UNIQUE (course_id, lesson_id),
    CONSTRAINT CK_lessons_order CHECK (order_index >= 1),
    CONSTRAINT CK_lessons_status CHECK (status IN (N'DRAFT', N'PUBLISHED', N'ARCHIVED')),
    CONSTRAINT FK_lessons_course FOREIGN KEY (course_id) REFERENCES dbo.courses(course_id)
);
END;
IF OBJECT_ID(N'dbo.materials', N'U') IS NULL
BEGIN
CREATE TABLE dbo.materials (
    material_id INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_materials PRIMARY KEY,
    lesson_id INT NOT NULL,
    title NVARCHAR(255) NOT NULL,
    type NVARCHAR(20) NOT NULL,
    file_url NVARCHAR(2048) NOT NULL,
    original_file_name NVARCHAR(255) NULL,
    content_type NVARCHAR(100) NULL,
    size_bytes BIGINT NULL,
    order_index INT NOT NULL,
    uploaded_by INT NOT NULL,
    uploaded_at DATETIME2 NOT NULL CONSTRAINT DF_materials_uploaded DEFAULT SYSDATETIME(),
    CONSTRAINT UQ_materials_order UNIQUE (lesson_id, order_index),
    CONSTRAINT CK_materials_type CHECK (type IN (N'DOCUMENT', N'LINK', N'VIDEO')),
    CONSTRAINT CK_materials_size CHECK (size_bytes IS NULL OR size_bytes >= 0),
    CONSTRAINT CK_materials_order CHECK (order_index >= 1),
    CONSTRAINT FK_materials_lesson FOREIGN KEY (lesson_id) REFERENCES dbo.lessons(lesson_id),
    CONSTRAINT FK_materials_uploader FOREIGN KEY (uploaded_by) REFERENCES dbo.users(user_id)
);
END;
IF OBJECT_ID(N'dbo.videos', N'U') IS NULL
BEGIN
CREATE TABLE dbo.videos (
    video_id INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_videos PRIMARY KEY,
    material_id INT NOT NULL CONSTRAINT UQ_videos_material UNIQUE,
    original_file_url NVARCHAR(2048) NOT NULL,
    processed_url NVARCHAR(2048) NULL,
    streaming_url NVARCHAR(2048) NULL,
    provider NVARCHAR(50) NULL,
    provider_job_id NVARCHAR(255) NULL,
    status NVARCHAR(20) NOT NULL CONSTRAINT DF_videos_status DEFAULT N'UPLOADING',
    duration_seconds INT NULL,
    error_message NVARCHAR(2000) NULL,
    uploaded_by INT NOT NULL,
    uploaded_at DATETIME2 NOT NULL CONSTRAINT DF_videos_uploaded DEFAULT SYSDATETIME(),
    processed_at DATETIME2 NULL,
    CONSTRAINT CK_videos_status CHECK (status IN (N'UPLOADING', N'PROCESSING', N'READY', N'FAILED')),
    CONSTRAINT CK_videos_duration CHECK (duration_seconds IS NULL OR duration_seconds >= 0),
    CONSTRAINT CK_videos_ready CHECK (status <> N'READY' OR (processed_at IS NOT NULL AND streaming_url IS NOT NULL)),
    CONSTRAINT FK_videos_material FOREIGN KEY (material_id) REFERENCES dbo.materials(material_id),
    CONSTRAINT FK_videos_uploader FOREIGN KEY (uploaded_by) REFERENCES dbo.users(user_id)
);
END;
IF OBJECT_ID(N'dbo.lesson_completions', N'U') IS NULL
BEGIN
CREATE TABLE dbo.lesson_completions (
    completion_id INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_lesson_completions PRIMARY KEY,
    student_id INT NOT NULL,
    course_id INT NOT NULL,
    lesson_id INT NOT NULL,
    completed_at DATETIME2 NOT NULL CONSTRAINT DF_lesson_completions_completed DEFAULT SYSDATETIME(),
    CONSTRAINT UQ_lesson_completions UNIQUE (student_id, lesson_id),
    CONSTRAINT FK_lesson_completions_enrollment FOREIGN KEY (student_id, course_id) REFERENCES dbo.enrollments(student_id, course_id),
    CONSTRAINT FK_lesson_completions_lesson FOREIGN KEY (course_id, lesson_id) REFERENCES dbo.lessons(course_id, lesson_id)
);
END;

-- UC24-UC28, UC32-UC33: Every resubmission is a new row.
IF OBJECT_ID(N'dbo.assignments', N'U') IS NULL
BEGIN
CREATE TABLE dbo.assignments (
    assignment_id INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_assignments PRIMARY KEY,
    course_id INT NOT NULL,
    lesson_id INT NULL,
    title NVARCHAR(255) NOT NULL,
    description NVARCHAR(MAX) NULL,
    unlock_at DATETIME2 NULL,
    due_date DATETIME2 NOT NULL,
    lock_at DATETIME2 NULL,
    max_score DECIMAL(8,2) NOT NULL,
    allow_resubmit BIT NOT NULL CONSTRAINT DF_assignments_resubmit DEFAULT 0,
    max_attempts INT NOT NULL CONSTRAINT DF_assignments_attempts DEFAULT 1,
    status NVARCHAR(20) NOT NULL CONSTRAINT DF_assignments_status DEFAULT N'DRAFT',
    created_by INT NOT NULL,
    created_at DATETIME2 NOT NULL CONSTRAINT DF_assignments_created DEFAULT SYSDATETIME(),
    updated_at DATETIME2 NULL,
    CONSTRAINT UQ_assignments_course UNIQUE (course_id, assignment_id),
    CONSTRAINT CK_assignments_score CHECK (max_score > 0),
    CONSTRAINT CK_assignments_attempts CHECK ((allow_resubmit = 0 AND max_attempts = 1) OR (allow_resubmit = 1 AND max_attempts >= 2)),
    CONSTRAINT CK_assignments_dates CHECK ((unlock_at IS NULL OR unlock_at <= due_date) AND (lock_at IS NULL OR lock_at >= due_date)),
    CONSTRAINT CK_assignments_status CHECK (status IN (N'DRAFT', N'PUBLISHED', N'ARCHIVED')),
    CONSTRAINT FK_assignments_course FOREIGN KEY (course_id) REFERENCES dbo.courses(course_id),
    CONSTRAINT FK_assignments_lesson FOREIGN KEY (course_id, lesson_id) REFERENCES dbo.lessons(course_id, lesson_id),
    CONSTRAINT FK_assignments_author FOREIGN KEY (created_by) REFERENCES dbo.users(user_id)
);
END;
IF OBJECT_ID(N'dbo.submissions', N'U') IS NULL
BEGIN
CREATE TABLE dbo.submissions (
    submission_id INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_submissions PRIMARY KEY,
    assignment_id INT NOT NULL,
    student_id INT NOT NULL,
    course_id INT NOT NULL,
    file_url NVARCHAR(2048) NULL,
    answer_text NVARCHAR(MAX) NULL,
    attempt_number INT NOT NULL,
    submitted_at DATETIME2 NOT NULL CONSTRAINT DF_submissions_submitted DEFAULT SYSDATETIME(),
    is_late BIT NOT NULL CONSTRAINT DF_submissions_late DEFAULT 0,
    status NVARCHAR(20) NOT NULL CONSTRAINT DF_submissions_status DEFAULT N'SUBMITTED',
    CONSTRAINT UQ_submissions_attempt UNIQUE (assignment_id, student_id, attempt_number),
    CONSTRAINT CK_submissions_attempt CHECK (attempt_number >= 1),
    CONSTRAINT CK_submissions_content CHECK (file_url IS NOT NULL OR answer_text IS NOT NULL),
    CONSTRAINT CK_submissions_status CHECK (status IN (N'SUBMITTED', N'GRADED')),
    CONSTRAINT FK_submissions_assignment FOREIGN KEY (course_id, assignment_id) REFERENCES dbo.assignments(course_id, assignment_id),
    CONSTRAINT FK_submissions_enrollment FOREIGN KEY (student_id, course_id) REFERENCES dbo.enrollments(student_id, course_id)
);
END;
IF OBJECT_ID(N'dbo.grades', N'U') IS NULL
BEGIN
CREATE TABLE dbo.grades (
    grade_id INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_grades PRIMARY KEY,
    submission_id INT NOT NULL CONSTRAINT UQ_grades_submission UNIQUE,
    score DECIMAL(8,2) NOT NULL,
    max_score DECIMAL(8,2) NOT NULL,
    feedback NVARCHAR(MAX) NULL,
    graded_by INT NOT NULL,
    graded_at DATETIME2 NOT NULL CONSTRAINT DF_grades_graded DEFAULT SYSDATETIME(),
    result_status NVARCHAR(20) NOT NULL CONSTRAINT DF_grades_status DEFAULT N'UNPUBLISHED',
    published_by INT NULL,
    published_at DATETIME2 NULL,
    CONSTRAINT CK_grades_score CHECK (max_score > 0 AND score >= 0 AND score <= max_score),
    CONSTRAINT CK_grades_status CHECK (result_status IN (N'UNPUBLISHED', N'PUBLISHED')),
    CONSTRAINT CK_grades_publication CHECK (result_status <> N'PUBLISHED' OR (published_at IS NOT NULL AND published_by IS NOT NULL AND published_at >= graded_at)),
    CONSTRAINT FK_grades_submission FOREIGN KEY (submission_id) REFERENCES dbo.submissions(submission_id),
    CONSTRAINT FK_grades_grader FOREIGN KEY (graded_by) REFERENCES dbo.users(user_id),
    CONSTRAINT FK_grades_publisher FOREIGN KEY (published_by) REFERENCES dbo.users(user_id)
);
END;

-- UC29-UC33: Multi-select answers use quiz_answer_options, not one selected_option_id.
IF OBJECT_ID(N'dbo.quizzes', N'U') IS NULL
BEGIN
CREATE TABLE dbo.quizzes (
    quiz_id INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_quizzes PRIMARY KEY,
    course_id INT NOT NULL,
    lesson_id INT NULL,
    title NVARCHAR(255) NOT NULL,
    description NVARCHAR(MAX) NULL,
    time_limit_minutes INT NULL,
    max_attempts INT NOT NULL CONSTRAINT DF_quizzes_attempts DEFAULT 1,
    start_time DATETIME2 NULL,
    due_date DATETIME2 NULL,
    end_time DATETIME2 NULL,
    rules NVARCHAR(MAX) NULL,
    status NVARCHAR(20) NOT NULL CONSTRAINT DF_quizzes_status DEFAULT N'DRAFT',
    created_by INT NOT NULL,
    created_at DATETIME2 NOT NULL CONSTRAINT DF_quizzes_created DEFAULT SYSDATETIME(),
    CONSTRAINT UQ_quizzes_course UNIQUE (course_id, quiz_id),
    CONSTRAINT CK_quizzes_time_limit CHECK (time_limit_minutes IS NULL OR time_limit_minutes > 0),
    CONSTRAINT CK_quizzes_attempts CHECK (max_attempts >= 1),
    CONSTRAINT CK_quizzes_dates CHECK ((start_time IS NULL OR due_date IS NULL OR start_time <= due_date) AND (due_date IS NULL OR end_time IS NULL OR due_date <= end_time) AND (start_time IS NULL OR end_time IS NULL OR start_time < end_time)),
    CONSTRAINT CK_quizzes_status CHECK (status IN (N'DRAFT', N'PUBLISHED', N'ARCHIVED')),
    CONSTRAINT FK_quizzes_course FOREIGN KEY (course_id) REFERENCES dbo.courses(course_id),
    CONSTRAINT FK_quizzes_lesson FOREIGN KEY (course_id, lesson_id) REFERENCES dbo.lessons(course_id, lesson_id),
    CONSTRAINT FK_quizzes_author FOREIGN KEY (created_by) REFERENCES dbo.users(user_id)
);
END;
IF OBJECT_ID(N'dbo.questions', N'U') IS NULL
BEGIN
CREATE TABLE dbo.questions (
    question_id INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_questions PRIMARY KEY,
    quiz_id INT NOT NULL,
    content NVARCHAR(MAX) NOT NULL,
    type NVARCHAR(30) NOT NULL,
    score DECIMAL(8,2) NOT NULL,
    order_index INT NOT NULL,
    correct_answer NVARCHAR(MAX) NULL,
    explanation NVARCHAR(MAX) NULL,
    CONSTRAINT UQ_questions_order UNIQUE (quiz_id, order_index),
    CONSTRAINT UQ_questions_quiz UNIQUE (quiz_id, question_id),
    CONSTRAINT CK_questions_type CHECK (type IN (N'SINGLE_CHOICE', N'MULTIPLE_CHOICE', N'TRUE_FALSE', N'SHORT_ANSWER', N'ESSAY')),
    CONSTRAINT CK_questions_score CHECK (score > 0),
    CONSTRAINT CK_questions_order CHECK (order_index >= 1),
    CONSTRAINT FK_questions_quiz FOREIGN KEY (quiz_id) REFERENCES dbo.quizzes(quiz_id)
);
END;
IF OBJECT_ID(N'dbo.answer_options', N'U') IS NULL
BEGIN
CREATE TABLE dbo.answer_options (
    option_id INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_answer_options PRIMARY KEY,
    question_id INT NOT NULL,
    content NVARCHAR(MAX) NOT NULL,
    is_correct BIT NOT NULL CONSTRAINT DF_answer_options_correct DEFAULT 0,
    order_index INT NOT NULL,
    CONSTRAINT UQ_answer_options_order UNIQUE (question_id, order_index),
    CONSTRAINT UQ_answer_options_question UNIQUE (question_id, option_id),
    CONSTRAINT CK_answer_options_order CHECK (order_index >= 1),
    CONSTRAINT FK_answer_options_question FOREIGN KEY (question_id) REFERENCES dbo.questions(question_id)
);
END;
IF OBJECT_ID(N'dbo.quiz_attempts', N'U') IS NULL
BEGIN
CREATE TABLE dbo.quiz_attempts (
    attempt_id INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_quiz_attempts PRIMARY KEY,
    quiz_id INT NOT NULL,
    student_id INT NOT NULL,
    course_id INT NOT NULL,
    attempt_number INT NOT NULL,
    started_at DATETIME2 NOT NULL CONSTRAINT DF_quiz_attempts_started DEFAULT SYSDATETIME(),
    deadline_at DATETIME2 NULL,
    submitted_at DATETIME2 NULL,
    status NVARCHAR(20) NOT NULL CONSTRAINT DF_quiz_attempts_status DEFAULT N'IN_PROGRESS',
    score DECIMAL(8,2) NULL,
    max_score DECIMAL(8,2) NOT NULL,
    result_status NVARCHAR(20) NOT NULL CONSTRAINT DF_quiz_attempts_result DEFAULT N'UNPUBLISHED',
    published_by INT NULL,
    published_at DATETIME2 NULL,
    CONSTRAINT UQ_quiz_attempts_number UNIQUE (quiz_id, student_id, attempt_number),
    CONSTRAINT UQ_quiz_attempts_quiz UNIQUE (attempt_id, quiz_id),
    CONSTRAINT CK_quiz_attempts_number CHECK (attempt_number >= 1),
    CONSTRAINT CK_quiz_attempts_status CHECK (status IN (N'IN_PROGRESS', N'SUBMITTED', N'SCORED', N'ABANDONED')),
    CONSTRAINT CK_quiz_attempts_dates CHECK ((deadline_at IS NULL OR deadline_at >= started_at) AND (submitted_at IS NULL OR submitted_at >= started_at)),
    CONSTRAINT CK_quiz_attempts_submitted CHECK (status NOT IN (N'SUBMITTED', N'SCORED') OR submitted_at IS NOT NULL),
    CONSTRAINT CK_quiz_attempts_score CHECK (max_score > 0 AND (score IS NULL OR (score >= 0 AND score <= max_score)) AND (status <> N'SCORED' OR score IS NOT NULL)),
    CONSTRAINT CK_quiz_attempts_result CHECK (result_status IN (N'UNPUBLISHED', N'PUBLISHED')),
    CONSTRAINT CK_quiz_attempts_publication CHECK (result_status <> N'PUBLISHED' OR (status = N'SCORED' AND published_at IS NOT NULL AND published_by IS NOT NULL AND published_at >= submitted_at)),
    CONSTRAINT FK_quiz_attempts_quiz FOREIGN KEY (course_id, quiz_id) REFERENCES dbo.quizzes(course_id, quiz_id),
    CONSTRAINT FK_quiz_attempts_enrollment FOREIGN KEY (student_id, course_id) REFERENCES dbo.enrollments(student_id, course_id),
    CONSTRAINT FK_quiz_attempts_publisher FOREIGN KEY (published_by) REFERENCES dbo.users(user_id)
);
END;
IF OBJECT_ID(N'dbo.quiz_answers', N'U') IS NULL
BEGIN
CREATE TABLE dbo.quiz_answers (
    answer_id INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_quiz_answers PRIMARY KEY,
    attempt_id INT NOT NULL,
    quiz_id INT NOT NULL,
    question_id INT NOT NULL,
    answer_text NVARCHAR(MAX) NULL,
    question_content_snapshot NVARCHAR(MAX) NOT NULL,
    question_type_snapshot NVARCHAR(30) NOT NULL,
    max_score DECIMAL(8,2) NOT NULL,
    awarded_score DECIMAL(8,2) NULL,
    graded_by INT NULL,
    graded_at DATETIME2 NULL,
    CONSTRAINT UQ_quiz_answers_attempt UNIQUE (attempt_id, question_id),
    CONSTRAINT UQ_quiz_answers_question UNIQUE (answer_id, question_id),
    CONSTRAINT CK_quiz_answers_score CHECK (max_score > 0 AND (awarded_score IS NULL OR (awarded_score >= 0 AND awarded_score <= max_score))),
    CONSTRAINT CK_quiz_answers_type CHECK (question_type_snapshot IN (N'SINGLE_CHOICE', N'MULTIPLE_CHOICE', N'TRUE_FALSE', N'SHORT_ANSWER', N'ESSAY')),
    CONSTRAINT FK_quiz_answers_attempt FOREIGN KEY (attempt_id, quiz_id) REFERENCES dbo.quiz_attempts(attempt_id, quiz_id),
    CONSTRAINT FK_quiz_answers_question FOREIGN KEY (quiz_id, question_id) REFERENCES dbo.questions(quiz_id, question_id),
    CONSTRAINT FK_quiz_answers_grader FOREIGN KEY (graded_by) REFERENCES dbo.users(user_id)
);
END;
IF OBJECT_ID(N'dbo.quiz_answer_options', N'U') IS NULL
BEGIN
CREATE TABLE dbo.quiz_answer_options (
    answer_id INT NOT NULL,
    question_id INT NOT NULL,
    option_id INT NOT NULL,
    option_content_snapshot NVARCHAR(MAX) NOT NULL,
    CONSTRAINT PK_quiz_answer_options PRIMARY KEY (answer_id, option_id),
    CONSTRAINT FK_quiz_answer_options_answer FOREIGN KEY (answer_id, question_id) REFERENCES dbo.quiz_answers(answer_id, question_id),
    CONSTRAINT FK_quiz_answer_options_option FOREIGN KEY (question_id, option_id) REFERENCES dbo.answer_options(question_id, option_id)
);
END;

-- UC34-UC39: Personal dates are independent of official assignment/quiz dates.
IF OBJECT_ID(N'dbo.study_plans', N'U') IS NULL
BEGIN
CREATE TABLE dbo.study_plans (
    plan_id INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_study_plans PRIMARY KEY,
    student_id INT NOT NULL,
    title NVARCHAR(255) NOT NULL,
    description NVARCHAR(2000) NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    timezone NVARCHAR(100) NOT NULL CONSTRAINT DF_study_plans_timezone DEFAULT N'Asia/Ho_Chi_Minh',
    status NVARCHAR(20) NOT NULL CONSTRAINT DF_study_plans_status DEFAULT N'ACTIVE',
    created_at DATETIME2 NOT NULL CONSTRAINT DF_study_plans_created DEFAULT SYSDATETIME(),
    CONSTRAINT UQ_study_plans_owner UNIQUE (plan_id, student_id),
    CONSTRAINT CK_study_plans_dates CHECK (end_date >= start_date),
    CONSTRAINT CK_study_plans_status CHECK (status IN (N'ACTIVE', N'ARCHIVED')),
    CONSTRAINT FK_study_plans_student FOREIGN KEY (student_id) REFERENCES dbo.users(user_id)
);
END;
IF OBJECT_ID(N'dbo.personal_tasks', N'U') IS NULL
BEGIN
CREATE TABLE dbo.personal_tasks (
    task_id INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_personal_tasks PRIMARY KEY,
    plan_id INT NOT NULL,
    student_id INT NOT NULL,
    title NVARCHAR(255) NOT NULL,
    notes NVARCHAR(MAX) NULL,
    course_id INT NULL,
    related_lesson_id INT NULL,
    related_assignment_id INT NULL,
    related_quiz_id INT NULL,
    planned_start_at DATETIME2 NOT NULL,
    planned_end_at DATETIME2 NOT NULL,
    status NVARCHAR(20) NOT NULL CONSTRAINT DF_personal_tasks_status DEFAULT N'TODO',
    completed_at DATETIME2 NULL,
    CONSTRAINT CK_personal_tasks_dates CHECK (planned_end_at >= planned_start_at),
    CONSTRAINT CK_personal_tasks_status CHECK (status IN (N'TODO', N'IN_PROGRESS', N'DONE', N'CANCELLED')),
    CONSTRAINT CK_personal_tasks_done CHECK (status <> N'DONE' OR completed_at IS NOT NULL),
    CONSTRAINT CK_personal_tasks_reference CHECK ((CASE WHEN related_lesson_id IS NULL THEN 0 ELSE 1 END + CASE WHEN related_assignment_id IS NULL THEN 0 ELSE 1 END + CASE WHEN related_quiz_id IS NULL THEN 0 ELSE 1 END) <= 1 AND ((related_lesson_id IS NULL AND related_assignment_id IS NULL AND related_quiz_id IS NULL) OR course_id IS NOT NULL)),
    CONSTRAINT FK_personal_tasks_plan FOREIGN KEY (plan_id, student_id) REFERENCES dbo.study_plans(plan_id, student_id),
    CONSTRAINT FK_personal_tasks_enrollment FOREIGN KEY (student_id, course_id) REFERENCES dbo.enrollments(student_id, course_id),
    CONSTRAINT FK_personal_tasks_lesson FOREIGN KEY (course_id, related_lesson_id) REFERENCES dbo.lessons(course_id, lesson_id),
    CONSTRAINT FK_personal_tasks_assignment FOREIGN KEY (course_id, related_assignment_id) REFERENCES dbo.assignments(course_id, assignment_id),
    CONSTRAINT FK_personal_tasks_quiz FOREIGN KEY (course_id, related_quiz_id) REFERENCES dbo.quizzes(course_id, quiz_id)
);
END;
IF OBJECT_ID(N'dbo.learning_progress', N'U') IS NULL
BEGIN
CREATE TABLE dbo.learning_progress (
    progress_id INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_learning_progress PRIMARY KEY,
    student_id INT NOT NULL,
    course_id INT NOT NULL,
    percent_complete DECIMAL(5,2) NOT NULL CONSTRAINT DF_learning_progress_percent DEFAULT 0,
    completed_lessons INT NOT NULL CONSTRAINT DF_learning_progress_completed DEFAULT 0,
    total_lessons INT NOT NULL CONSTRAINT DF_learning_progress_total DEFAULT 0,
    last_accessed_at DATETIME2 NULL,
    updated_at DATETIME2 NOT NULL CONSTRAINT DF_learning_progress_updated DEFAULT SYSDATETIME(),
    CONSTRAINT UQ_learning_progress UNIQUE (student_id, course_id),
    CONSTRAINT CK_learning_progress_percent CHECK (percent_complete >= 0 AND percent_complete <= 100),
    CONSTRAINT CK_learning_progress_counts CHECK (completed_lessons >= 0 AND total_lessons >= completed_lessons),
    CONSTRAINT FK_learning_progress_enrollment FOREIGN KEY (student_id, course_id) REFERENCES dbo.enrollments(student_id, course_id)
);
END;
IF OBJECT_ID(N'dbo.learning_history', N'U') IS NULL
BEGIN
CREATE TABLE dbo.learning_history (
    history_id BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_learning_history PRIMARY KEY,
    student_id INT NOT NULL,
    course_id INT NOT NULL,
    activity_type NVARCHAR(30) NOT NULL,
    lesson_id INT NULL,
    assignment_id INT NULL,
    quiz_id INT NULL,
    details NVARCHAR(2000) NULL,
    occurred_at DATETIME2 NOT NULL CONSTRAINT DF_learning_history_occurred DEFAULT SYSDATETIME(),
    CONSTRAINT CK_learning_history_type CHECK ((activity_type = N'LESSON' AND lesson_id IS NOT NULL AND assignment_id IS NULL AND quiz_id IS NULL) OR (activity_type = N'ASSIGNMENT' AND assignment_id IS NOT NULL AND lesson_id IS NULL AND quiz_id IS NULL) OR (activity_type = N'QUIZ' AND quiz_id IS NOT NULL AND lesson_id IS NULL AND assignment_id IS NULL)),
    CONSTRAINT FK_learning_history_enrollment FOREIGN KEY (student_id, course_id) REFERENCES dbo.enrollments(student_id, course_id),
    CONSTRAINT FK_learning_history_lesson FOREIGN KEY (course_id, lesson_id) REFERENCES dbo.lessons(course_id, lesson_id),
    CONSTRAINT FK_learning_history_assignment FOREIGN KEY (course_id, assignment_id) REFERENCES dbo.assignments(course_id, assignment_id),
    CONSTRAINT FK_learning_history_quiz FOREIGN KEY (course_id, quiz_id) REFERENCES dbo.quizzes(course_id, quiz_id)
);
END;

-- UC40-UC44: Q&A is separate from discussions; recipient state tracks announcements.
IF OBJECT_ID(N'dbo.course_questions', N'U') IS NULL
BEGIN
CREATE TABLE dbo.course_questions (
    question_id INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_course_questions PRIMARY KEY,
    course_id INT NOT NULL,
    lesson_id INT NULL,
    student_id INT NOT NULL,
    title NVARCHAR(255) NOT NULL,
    content NVARCHAR(MAX) NOT NULL,
    status NVARCHAR(20) NOT NULL CONSTRAINT DF_course_questions_status DEFAULT N'OPEN',
    created_at DATETIME2 NOT NULL CONSTRAINT DF_course_questions_created DEFAULT SYSDATETIME(),
    CONSTRAINT CK_course_questions_status CHECK (status IN (N'OPEN', N'ANSWERED', N'CLOSED')),
    CONSTRAINT FK_course_questions_enrollment FOREIGN KEY (student_id, course_id) REFERENCES dbo.enrollments(student_id, course_id),
    CONSTRAINT FK_course_questions_lesson FOREIGN KEY (course_id, lesson_id) REFERENCES dbo.lessons(course_id, lesson_id)
);
END;
IF OBJECT_ID(N'dbo.course_answers', N'U') IS NULL
BEGIN
CREATE TABLE dbo.course_answers (
    answer_id INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_course_answers PRIMARY KEY,
    question_id INT NOT NULL,
    instructor_id INT NOT NULL,
    content NVARCHAR(MAX) NOT NULL,
    created_at DATETIME2 NOT NULL CONSTRAINT DF_course_answers_created DEFAULT SYSDATETIME(),
    updated_at DATETIME2 NULL,
    CONSTRAINT FK_course_answers_question FOREIGN KEY (question_id) REFERENCES dbo.course_questions(question_id),
    CONSTRAINT FK_course_answers_instructor FOREIGN KEY (instructor_id) REFERENCES dbo.users(user_id)
);
END;
IF OBJECT_ID(N'dbo.discussions', N'U') IS NULL
BEGIN
CREATE TABLE dbo.discussions (
    discussion_id INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_discussions PRIMARY KEY,
    course_id INT NOT NULL,
    user_id INT NOT NULL,
    title NVARCHAR(255) NOT NULL,
    content NVARCHAR(MAX) NOT NULL,
    status NVARCHAR(20) NOT NULL CONSTRAINT DF_discussions_status DEFAULT N'ACTIVE',
    created_at DATETIME2 NOT NULL CONSTRAINT DF_discussions_created DEFAULT SYSDATETIME(),
    moderated_by INT NULL,
    moderated_at DATETIME2 NULL,
    moderation_reason NVARCHAR(2000) NULL,
    CONSTRAINT CK_discussions_status CHECK (status IN (N'ACTIVE', N'LOCKED', N'HIDDEN')),
    CONSTRAINT CK_discussions_moderation CHECK (status = N'ACTIVE' OR (moderated_by IS NOT NULL AND moderated_at IS NOT NULL)),
    CONSTRAINT FK_discussions_course FOREIGN KEY (course_id) REFERENCES dbo.courses(course_id),
    CONSTRAINT FK_discussions_user FOREIGN KEY (user_id) REFERENCES dbo.users(user_id),
    CONSTRAINT FK_discussions_moderator FOREIGN KEY (moderated_by) REFERENCES dbo.users(user_id)
);
END;
IF OBJECT_ID(N'dbo.discussion_replies', N'U') IS NULL
BEGIN
CREATE TABLE dbo.discussion_replies (
    reply_id INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_discussion_replies PRIMARY KEY,
    discussion_id INT NOT NULL,
    user_id INT NOT NULL,
    parent_reply_id INT NULL,
    content NVARCHAR(MAX) NOT NULL,
    status NVARCHAR(20) NOT NULL CONSTRAINT DF_discussion_replies_status DEFAULT N'ACTIVE',
    created_at DATETIME2 NOT NULL CONSTRAINT DF_discussion_replies_created DEFAULT SYSDATETIME(),
    moderated_by INT NULL,
    moderated_at DATETIME2 NULL,
    moderation_reason NVARCHAR(2000) NULL,
    CONSTRAINT UQ_discussion_replies_parent UNIQUE (discussion_id, reply_id),
    CONSTRAINT CK_discussion_replies_parent CHECK (parent_reply_id IS NULL OR parent_reply_id <> reply_id),
    CONSTRAINT CK_discussion_replies_status CHECK (status IN (N'ACTIVE', N'HIDDEN')),
    CONSTRAINT CK_discussion_replies_moderation CHECK (status = N'ACTIVE' OR (moderated_by IS NOT NULL AND moderated_at IS NOT NULL)),
    CONSTRAINT FK_discussion_replies_discussion FOREIGN KEY (discussion_id) REFERENCES dbo.discussions(discussion_id),
    CONSTRAINT FK_discussion_replies_user FOREIGN KEY (user_id) REFERENCES dbo.users(user_id),
    CONSTRAINT FK_discussion_replies_parent FOREIGN KEY (discussion_id, parent_reply_id) REFERENCES dbo.discussion_replies(discussion_id, reply_id),
    CONSTRAINT FK_discussion_replies_moderator FOREIGN KEY (moderated_by) REFERENCES dbo.users(user_id)
);
END;
IF OBJECT_ID(N'dbo.announcements', N'U') IS NULL
BEGIN
CREATE TABLE dbo.announcements (
    announcement_id INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_announcements PRIMARY KEY,
    course_id INT NOT NULL,
    instructor_id INT NOT NULL,
    title NVARCHAR(255) NOT NULL,
    content NVARCHAR(MAX) NOT NULL,
    status NVARCHAR(20) NOT NULL CONSTRAINT DF_announcements_status DEFAULT N'DRAFT',
    created_at DATETIME2 NOT NULL CONSTRAINT DF_announcements_created DEFAULT SYSDATETIME(),
    sent_at DATETIME2 NULL,
    CONSTRAINT UQ_announcements_course UNIQUE (course_id, announcement_id),
    CONSTRAINT CK_announcements_status CHECK (status IN (N'DRAFT', N'SENT')),
    CONSTRAINT CK_announcements_sent CHECK (status <> N'SENT' OR sent_at IS NOT NULL),
    CONSTRAINT FK_announcements_course FOREIGN KEY (course_id) REFERENCES dbo.courses(course_id),
    CONSTRAINT FK_announcements_instructor FOREIGN KEY (instructor_id) REFERENCES dbo.users(user_id)
);
END;
IF OBJECT_ID(N'dbo.notifications', N'U') IS NULL
BEGIN
CREATE TABLE dbo.notifications (
    notification_id BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_notifications PRIMARY KEY,
    user_id INT NOT NULL,
    course_id INT NOT NULL,
    announcement_id INT NOT NULL,
    created_at DATETIME2 NOT NULL CONSTRAINT DF_notifications_created DEFAULT SYSDATETIME(),
    read_at DATETIME2 NULL,
    CONSTRAINT UQ_notifications_recipient UNIQUE (user_id, announcement_id),
    CONSTRAINT FK_notifications_enrollment FOREIGN KEY (user_id, course_id) REFERENCES dbo.enrollments(student_id, course_id),
    CONSTRAINT FK_notifications_announcement FOREIGN KEY (course_id, announcement_id) REFERENCES dbo.announcements(course_id, announcement_id)
);
END;

-- UC46-UC48: Optional certificates and study groups.
IF OBJECT_ID(N'dbo.certificates', N'U') IS NULL
BEGIN
CREATE TABLE dbo.certificates (
    certificate_id INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_certificates PRIMARY KEY,
    student_id INT NOT NULL,
    course_id INT NOT NULL,
    verification_code NVARCHAR(100) NOT NULL CONSTRAINT UQ_certificates_code UNIQUE,
    file_url NVARCHAR(2048) NULL,
    issued_at DATETIME2 NOT NULL CONSTRAINT DF_certificates_issued DEFAULT SYSDATETIME(),
    status NVARCHAR(20) NOT NULL CONSTRAINT DF_certificates_status DEFAULT N'VALID',
    revoked_at DATETIME2 NULL,
    revocation_reason NVARCHAR(2000) NULL,
    CONSTRAINT UQ_certificates_student_course UNIQUE (student_id, course_id),
    CONSTRAINT CK_certificates_status CHECK (status IN (N'VALID', N'REVOKED')),
    CONSTRAINT CK_certificates_revoked CHECK (status <> N'REVOKED' OR revoked_at IS NOT NULL),
    CONSTRAINT FK_certificates_enrollment FOREIGN KEY (student_id, course_id) REFERENCES dbo.enrollments(student_id, course_id)
);
END;
IF OBJECT_ID(N'dbo.study_groups', N'U') IS NULL
BEGIN
CREATE TABLE dbo.study_groups (
    group_id INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_study_groups PRIMARY KEY,
    course_id INT NOT NULL,
    name NVARCHAR(100) NOT NULL,
    description NVARCHAR(2000) NULL,
    created_by INT NOT NULL,
    status NVARCHAR(20) NOT NULL CONSTRAINT DF_study_groups_status DEFAULT N'ACTIVE',
    created_at DATETIME2 NOT NULL CONSTRAINT DF_study_groups_created DEFAULT SYSDATETIME(),
    CONSTRAINT UQ_study_groups_name UNIQUE (course_id, name),
    CONSTRAINT UQ_study_groups_course UNIQUE (group_id, course_id),
    CONSTRAINT CK_study_groups_status CHECK (status IN (N'ACTIVE', N'ARCHIVED')),
    CONSTRAINT FK_study_groups_course FOREIGN KEY (course_id) REFERENCES dbo.courses(course_id),
    CONSTRAINT FK_study_groups_creator FOREIGN KEY (created_by) REFERENCES dbo.users(user_id)
);
END;
IF OBJECT_ID(N'dbo.group_members', N'U') IS NULL
BEGIN
CREATE TABLE dbo.group_members (
    group_id INT NOT NULL,
    user_id INT NOT NULL,
    course_id INT NOT NULL,
    role_in_group NVARCHAR(20) NOT NULL CONSTRAINT DF_group_members_role DEFAULT N'MEMBER',
    joined_at DATETIME2 NOT NULL CONSTRAINT DF_group_members_joined DEFAULT SYSDATETIME(),
    CONSTRAINT PK_group_members PRIMARY KEY (group_id, user_id),
    CONSTRAINT CK_group_members_role CHECK (role_in_group IN (N'LEADER', N'MEMBER')),
    CONSTRAINT FK_group_members_group FOREIGN KEY (group_id, course_id) REFERENCES dbo.study_groups(group_id, course_id),
    CONSTRAINT FK_group_members_user FOREIGN KEY (user_id) REFERENCES dbo.users(user_id)
);
END;

-- UC50: Approved sources and traceable AI conversations.
IF OBJECT_ID(N'dbo.ai_learning_resources', N'U') IS NULL
BEGIN
CREATE TABLE dbo.ai_learning_resources (
    resource_id INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_ai_learning_resources PRIMARY KEY,
    title NVARCHAR(255) NOT NULL,
    url NVARCHAR(2048) NOT NULL,
    source NVARCHAR(255) NULL,
    course_id INT NULL,
    visibility NVARCHAR(20) NOT NULL,
    status NVARCHAR(20) NOT NULL CONSTRAINT DF_ai_resources_status DEFAULT N'PENDING',
    submitted_by INT NOT NULL,
    reviewed_by INT NULL,
    reviewed_at DATETIME2 NULL,
    created_at DATETIME2 NOT NULL CONSTRAINT DF_ai_resources_created DEFAULT SYSDATETIME(),
    CONSTRAINT CK_ai_resources_visibility CHECK ((visibility = N'PUBLIC' AND course_id IS NULL) OR (visibility = N'COURSE' AND course_id IS NOT NULL)),
    CONSTRAINT CK_ai_resources_status CHECK (status IN (N'PENDING', N'APPROVED', N'REJECTED', N'ARCHIVED')),
    CONSTRAINT CK_ai_resources_approval CHECK (status NOT IN (N'APPROVED', N'REJECTED') OR (reviewed_by IS NOT NULL AND reviewed_at IS NOT NULL)),
    CONSTRAINT FK_ai_resources_course FOREIGN KEY (course_id) REFERENCES dbo.courses(course_id),
    CONSTRAINT FK_ai_resources_submitter FOREIGN KEY (submitted_by) REFERENCES dbo.users(user_id),
    CONSTRAINT FK_ai_resources_reviewer FOREIGN KEY (reviewed_by) REFERENCES dbo.users(user_id)
);
END;
IF OBJECT_ID(N'dbo.ai_chat_sessions', N'U') IS NULL
BEGIN
CREATE TABLE dbo.ai_chat_sessions (
    session_id INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_ai_chat_sessions PRIMARY KEY,
    student_id INT NOT NULL,
    course_id INT NULL,
    title NVARCHAR(255) NULL,
    created_at DATETIME2 NOT NULL CONSTRAINT DF_ai_sessions_created DEFAULT SYSDATETIME(),
    CONSTRAINT FK_ai_sessions_student FOREIGN KEY (student_id) REFERENCES dbo.users(user_id),
    CONSTRAINT FK_ai_sessions_enrollment FOREIGN KEY (student_id, course_id) REFERENCES dbo.enrollments(student_id, course_id)
);
END;
IF OBJECT_ID(N'dbo.ai_chat_logs', N'U') IS NULL
BEGIN
CREATE TABLE dbo.ai_chat_logs (
    chat_id BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_ai_chat_logs PRIMARY KEY,
    session_id INT NOT NULL,
    request_id UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_ai_logs_request DEFAULT NEWID() CONSTRAINT UQ_ai_logs_request UNIQUE,
    question NVARCHAR(MAX) NOT NULL,
    answer NVARCHAR(MAX) NULL,
    model NVARCHAR(100) NULL,
    status NVARCHAR(20) NOT NULL CONSTRAINT DF_ai_logs_status DEFAULT N'PENDING',
    created_at DATETIME2 NOT NULL CONSTRAINT DF_ai_logs_created DEFAULT SYSDATETIME(),
    completed_at DATETIME2 NULL,
    error_message NVARCHAR(2000) NULL,
    CONSTRAINT CK_ai_logs_status CHECK (status IN (N'PENDING', N'COMPLETED', N'FAILED')),
    CONSTRAINT CK_ai_logs_completed CHECK (status <> N'COMPLETED' OR (answer IS NOT NULL AND completed_at IS NOT NULL)),
    CONSTRAINT FK_ai_logs_session FOREIGN KEY (session_id) REFERENCES dbo.ai_chat_sessions(session_id)
);
END;
IF OBJECT_ID(N'dbo.ai_chat_sources', N'U') IS NULL
BEGIN
CREATE TABLE dbo.ai_chat_sources (
    chat_id BIGINT NOT NULL,
    resource_id INT NOT NULL,
    citation_text NVARCHAR(2000) NULL,
    CONSTRAINT PK_ai_chat_sources PRIMARY KEY (chat_id, resource_id),
    CONSTRAINT FK_ai_sources_chat FOREIGN KEY (chat_id) REFERENCES dbo.ai_chat_logs(chat_id),
    CONSTRAINT FK_ai_sources_resource FOREIGN KEY (resource_id) REFERENCES dbo.ai_learning_resources(resource_id)
);
END;

-- Verify existing schemas before adding indexes or seeds.
-- Constraint names from the old six-table script may differ; keys/FKs are compared by columns.
IF OBJECT_ID(N'tempdb..#EduSphereExpectedColumns') IS NOT NULL DROP TABLE #EduSphereExpectedColumns;
CREATE TABLE #EduSphereExpectedColumns (
    table_name SYSNAME COLLATE DATABASE_DEFAULT, column_name SYSNAME COLLATE DATABASE_DEFAULT,
    type_name SYSNAME COLLATE DATABASE_DEFAULT, max_length INT, is_nullable BIT,
    is_identity BIT, expected_precision INT, expected_scale INT
);
INSERT INTO #EduSphereExpectedColumns VALUES
    (N'roles', N'role_id', N'int', 4, 0, 1, 0, 0),
    (N'roles', N'role_name', N'nvarchar', 100, 0, 0, 0, 0),
    (N'users', N'user_id', N'int', 4, 0, 1, 0, 0),
    (N'users', N'full_name', N'nvarchar', 200, 0, 0, 0, 0),
    (N'users', N'email', N'nvarchar', 510, 0, 0, 0, 0),
    (N'users', N'password_hash', N'nvarchar', 510, 1, 0, 0, 0),
    (N'users', N'phone', N'nvarchar', 40, 1, 0, 0, 0),
    (N'users', N'avatar_url', N'nvarchar', 1000, 1, 0, 0, 0),
    (N'users', N'status', N'nvarchar', 40, 0, 0, 0, 0),
    (N'users', N'created_at', N'datetime2', 8, 0, 0, 0, 7),
    (N'users', N'updated_at', N'datetime2', 8, 1, 0, 0, 7),
    (N'user_roles', N'user_id', N'int', 4, 0, 0, 0, 0),
    (N'user_roles', N'role_id', N'int', 4, 0, 0, 0, 0),
    (N'user_roles', N'assigned_at', N'datetime2', 8, 0, 0, 0, 7),
    (N'email_verification_tokens', N'token_id', N'int', 4, 0, 1, 0, 0),
    (N'email_verification_tokens', N'user_id', N'int', 4, 0, 0, 0, 0),
    (N'email_verification_tokens', N'token', N'nvarchar', 510, 0, 0, 0, 0),
    (N'email_verification_tokens', N'expires_at', N'datetime2', 8, 0, 0, 0, 7),
    (N'email_verification_tokens', N'verified_at', N'datetime2', 8, 1, 0, 0, 7),
    (N'password_reset_tokens', N'token_id', N'int', 4, 0, 1, 0, 0),
    (N'password_reset_tokens', N'user_id', N'int', 4, 0, 0, 0, 0),
    (N'password_reset_tokens', N'token', N'nvarchar', 510, 0, 0, 0, 0),
    (N'password_reset_tokens', N'expires_at', N'datetime2', 8, 0, 0, 0, 7),
    (N'password_reset_tokens', N'used_at', N'datetime2', 8, 1, 0, 0, 7),
    (N'oauth_accounts', N'oauth_id', N'int', 4, 0, 1, 0, 0),
    (N'oauth_accounts', N'user_id', N'int', 4, 0, 0, 0, 0),
    (N'oauth_accounts', N'provider', N'nvarchar', 100, 0, 0, 0, 0),
    (N'oauth_accounts', N'provider_user_id', N'nvarchar', 510, 0, 0, 0, 0),
    (N'oauth_accounts', N'created_at', N'datetime2', 8, 0, 0, 0, 7),
    (N'account_events', N'event_id', N'bigint', 8, 0, 1, 0, 0),
    (N'account_events', N'user_id', N'int', 4, 0, 0, 0, 0),
    (N'account_events', N'actor_id', N'int', 4, 0, 0, 0, 0),
    (N'account_events', N'role_id', N'int', 4, 1, 0, 0, 0),
    (N'account_events', N'action', N'nvarchar', 60, 0, 0, 0, 0),
    (N'account_events', N'reason', N'nvarchar', 2000, 1, 0, 0, 0),
    (N'account_events', N'created_at', N'datetime2', 8, 0, 0, 0, 7),
    (N'categories', N'category_id', N'int', 4, 0, 1, 0, 0),
    (N'categories', N'name', N'nvarchar', 200, 0, 0, 0, 0),
    (N'categories', N'description', N'nvarchar', 4000, 1, 0, 0, 0),
    (N'categories', N'parent_category_id', N'int', 4, 1, 0, 0, 0),
    (N'categories', N'status', N'nvarchar', 40, 0, 0, 0, 0),
    (N'courses', N'course_id', N'int', 4, 0, 1, 0, 0),
    (N'courses', N'title', N'nvarchar', 510, 0, 0, 0, 0),
    (N'courses', N'description', N'nvarchar', -1, 1, 0, 0, 0),
    (N'courses', N'category_id', N'int', 4, 1, 0, 0, 0),
    (N'courses', N'instructor_id', N'int', 4, 0, 0, 0, 0),
    (N'courses', N'level', N'nvarchar', 40, 0, 0, 0, 0),
    (N'courses', N'price', N'decimal', 9, 0, 0, 18, 2),
    (N'courses', N'currency', N'char', 3, 0, 0, 0, 0),
    (N'courses', N'thumbnail_url', N'nvarchar', 4096, 1, 0, 0, 0),
    (N'courses', N'status', N'nvarchar', 40, 0, 0, 0, 0),
    (N'courses', N'version_no', N'int', 4, 0, 0, 0, 0),
    (N'courses', N'created_at', N'datetime2', 8, 0, 0, 0, 7),
    (N'courses', N'updated_at', N'datetime2', 8, 1, 0, 0, 7),
    (N'courses', N'submitted_at', N'datetime2', 8, 1, 0, 0, 7),
    (N'courses', N'approved_at', N'datetime2', 8, 1, 0, 0, 7),
    (N'courses', N'published_at', N'datetime2', 8, 1, 0, 0, 7),
    (N'courses', N'archived_at', N'datetime2', 8, 1, 0, 0, 7),
    (N'course_reviews', N'review_id', N'int', 4, 0, 1, 0, 0),
    (N'course_reviews', N'course_id', N'int', 4, 0, 0, 0, 0),
    (N'course_reviews', N'course_version', N'int', 4, 0, 0, 0, 0),
    (N'course_reviews', N'admin_id', N'int', 4, 0, 0, 0, 0),
    (N'course_reviews', N'decision', N'nvarchar', 40, 0, 0, 0, 0),
    (N'course_reviews', N'comment', N'nvarchar', 4000, 1, 0, 0, 0),
    (N'course_reviews', N'reviewed_at', N'datetime2', 8, 0, 0, 0, 7),
    (N'payments', N'payment_id', N'int', 4, 0, 1, 0, 0),
    (N'payments', N'student_id', N'int', 4, 0, 0, 0, 0),
    (N'payments', N'course_id', N'int', 4, 0, 0, 0, 0),
    (N'payments', N'provider', N'nvarchar', 100, 0, 0, 0, 0),
    (N'payments', N'provider_transaction_id', N'nvarchar', 510, 1, 0, 0, 0),
    (N'payments', N'request_key', N'nvarchar', 200, 0, 0, 0, 0),
    (N'payments', N'amount', N'decimal', 9, 0, 0, 18, 2),
    (N'payments', N'currency', N'char', 3, 0, 0, 0, 0),
    (N'payments', N'status', N'nvarchar', 40, 0, 0, 0, 0),
    (N'payments', N'created_at', N'datetime2', 8, 0, 0, 0, 7),
    (N'payments', N'completed_at', N'datetime2', 8, 1, 0, 0, 7),
    (N'payment_events', N'event_id', N'bigint', 8, 0, 1, 0, 0),
    (N'payment_events', N'payment_id', N'int', 4, 0, 0, 0, 0),
    (N'payment_events', N'provider_event_id', N'nvarchar', 510, 0, 0, 0, 0),
    (N'payment_events', N'event_type', N'nvarchar', 100, 0, 0, 0, 0),
    (N'payment_events', N'payload', N'nvarchar', -1, 1, 0, 0, 0),
    (N'payment_events', N'signature_verified', N'bit', 1, 0, 0, 0, 0),
    (N'payment_events', N'received_at', N'datetime2', 8, 0, 0, 0, 7),
    (N'payment_events', N'processed_at', N'datetime2', 8, 1, 0, 0, 7),
    (N'refunds', N'refund_id', N'int', 4, 0, 1, 0, 0),
    (N'refunds', N'payment_id', N'int', 4, 0, 0, 0, 0),
    (N'refunds', N'request_key', N'nvarchar', 200, 0, 0, 0, 0),
    (N'refunds', N'amount', N'decimal', 9, 0, 0, 18, 2),
    (N'refunds', N'reason', N'nvarchar', 4000, 1, 0, 0, 0),
    (N'refunds', N'status', N'nvarchar', 40, 0, 0, 0, 0),
    (N'refunds', N'processed_by', N'int', 4, 1, 0, 0, 0),
    (N'refunds', N'created_at', N'datetime2', 8, 0, 0, 0, 7),
    (N'refunds', N'processed_at', N'datetime2', 8, 1, 0, 0, 7),
    (N'enrollments', N'enrollment_id', N'int', 4, 0, 1, 0, 0),
    (N'enrollments', N'student_id', N'int', 4, 0, 0, 0, 0),
    (N'enrollments', N'course_id', N'int', 4, 0, 0, 0, 0),
    (N'enrollments', N'payment_id', N'int', 4, 1, 0, 0, 0),
    (N'enrollments', N'enrolled_at', N'datetime2', 8, 0, 0, 0, 7),
    (N'enrollments', N'status', N'nvarchar', 40, 0, 0, 0, 0),
    (N'enrollments', N'completed_at', N'datetime2', 8, 1, 0, 0, 7),
    (N'enrollments', N'dropped_at', N'datetime2', 8, 1, 0, 0, 7),
    (N'lessons', N'lesson_id', N'int', 4, 0, 1, 0, 0),
    (N'lessons', N'course_id', N'int', 4, 0, 0, 0, 0),
    (N'lessons', N'title', N'nvarchar', 510, 0, 0, 0, 0),
    (N'lessons', N'content', N'nvarchar', -1, 1, 0, 0, 0),
    (N'lessons', N'order_index', N'int', 4, 0, 0, 0, 0),
    (N'lessons', N'status', N'nvarchar', 40, 0, 0, 0, 0),
    (N'lessons', N'created_at', N'datetime2', 8, 0, 0, 0, 7),
    (N'lessons', N'updated_at', N'datetime2', 8, 1, 0, 0, 7),
    (N'materials', N'material_id', N'int', 4, 0, 1, 0, 0),
    (N'materials', N'lesson_id', N'int', 4, 0, 0, 0, 0),
    (N'materials', N'title', N'nvarchar', 510, 0, 0, 0, 0),
    (N'materials', N'type', N'nvarchar', 40, 0, 0, 0, 0),
    (N'materials', N'file_url', N'nvarchar', 4096, 0, 0, 0, 0),
    (N'materials', N'original_file_name', N'nvarchar', 510, 1, 0, 0, 0),
    (N'materials', N'content_type', N'nvarchar', 200, 1, 0, 0, 0),
    (N'materials', N'size_bytes', N'bigint', 8, 1, 0, 0, 0),
    (N'materials', N'order_index', N'int', 4, 0, 0, 0, 0),
    (N'materials', N'uploaded_by', N'int', 4, 0, 0, 0, 0),
    (N'materials', N'uploaded_at', N'datetime2', 8, 0, 0, 0, 7),
    (N'videos', N'video_id', N'int', 4, 0, 1, 0, 0),
    (N'videos', N'material_id', N'int', 4, 0, 0, 0, 0),
    (N'videos', N'original_file_url', N'nvarchar', 4096, 0, 0, 0, 0),
    (N'videos', N'processed_url', N'nvarchar', 4096, 1, 0, 0, 0),
    (N'videos', N'streaming_url', N'nvarchar', 4096, 1, 0, 0, 0),
    (N'videos', N'provider', N'nvarchar', 100, 1, 0, 0, 0),
    (N'videos', N'provider_job_id', N'nvarchar', 510, 1, 0, 0, 0),
    (N'videos', N'status', N'nvarchar', 40, 0, 0, 0, 0),
    (N'videos', N'duration_seconds', N'int', 4, 1, 0, 0, 0),
    (N'videos', N'error_message', N'nvarchar', 4000, 1, 0, 0, 0),
    (N'videos', N'uploaded_by', N'int', 4, 0, 0, 0, 0),
    (N'videos', N'uploaded_at', N'datetime2', 8, 0, 0, 0, 7),
    (N'videos', N'processed_at', N'datetime2', 8, 1, 0, 0, 7),
    (N'lesson_completions', N'completion_id', N'int', 4, 0, 1, 0, 0),
    (N'lesson_completions', N'student_id', N'int', 4, 0, 0, 0, 0),
    (N'lesson_completions', N'course_id', N'int', 4, 0, 0, 0, 0),
    (N'lesson_completions', N'lesson_id', N'int', 4, 0, 0, 0, 0),
    (N'lesson_completions', N'completed_at', N'datetime2', 8, 0, 0, 0, 7),
    (N'assignments', N'assignment_id', N'int', 4, 0, 1, 0, 0),
    (N'assignments', N'course_id', N'int', 4, 0, 0, 0, 0),
    (N'assignments', N'lesson_id', N'int', 4, 1, 0, 0, 0),
    (N'assignments', N'title', N'nvarchar', 510, 0, 0, 0, 0),
    (N'assignments', N'description', N'nvarchar', -1, 1, 0, 0, 0),
    (N'assignments', N'unlock_at', N'datetime2', 8, 1, 0, 0, 7),
    (N'assignments', N'due_date', N'datetime2', 8, 0, 0, 0, 7),
    (N'assignments', N'lock_at', N'datetime2', 8, 1, 0, 0, 7),
    (N'assignments', N'max_score', N'decimal', 5, 0, 0, 8, 2),
    (N'assignments', N'allow_resubmit', N'bit', 1, 0, 0, 0, 0),
    (N'assignments', N'max_attempts', N'int', 4, 0, 0, 0, 0),
    (N'assignments', N'status', N'nvarchar', 40, 0, 0, 0, 0),
    (N'assignments', N'created_by', N'int', 4, 0, 0, 0, 0),
    (N'assignments', N'created_at', N'datetime2', 8, 0, 0, 0, 7),
    (N'assignments', N'updated_at', N'datetime2', 8, 1, 0, 0, 7),
    (N'submissions', N'submission_id', N'int', 4, 0, 1, 0, 0),
    (N'submissions', N'assignment_id', N'int', 4, 0, 0, 0, 0),
    (N'submissions', N'student_id', N'int', 4, 0, 0, 0, 0),
    (N'submissions', N'course_id', N'int', 4, 0, 0, 0, 0),
    (N'submissions', N'file_url', N'nvarchar', 4096, 1, 0, 0, 0),
    (N'submissions', N'answer_text', N'nvarchar', -1, 1, 0, 0, 0),
    (N'submissions', N'attempt_number', N'int', 4, 0, 0, 0, 0),
    (N'submissions', N'submitted_at', N'datetime2', 8, 0, 0, 0, 7),
    (N'submissions', N'is_late', N'bit', 1, 0, 0, 0, 0),
    (N'submissions', N'status', N'nvarchar', 40, 0, 0, 0, 0),
    (N'grades', N'grade_id', N'int', 4, 0, 1, 0, 0),
    (N'grades', N'submission_id', N'int', 4, 0, 0, 0, 0),
    (N'grades', N'score', N'decimal', 5, 0, 0, 8, 2),
    (N'grades', N'max_score', N'decimal', 5, 0, 0, 8, 2),
    (N'grades', N'feedback', N'nvarchar', -1, 1, 0, 0, 0),
    (N'grades', N'graded_by', N'int', 4, 0, 0, 0, 0),
    (N'grades', N'graded_at', N'datetime2', 8, 0, 0, 0, 7),
    (N'grades', N'result_status', N'nvarchar', 40, 0, 0, 0, 0),
    (N'grades', N'published_by', N'int', 4, 1, 0, 0, 0),
    (N'grades', N'published_at', N'datetime2', 8, 1, 0, 0, 7),
    (N'quizzes', N'quiz_id', N'int', 4, 0, 1, 0, 0),
    (N'quizzes', N'course_id', N'int', 4, 0, 0, 0, 0),
    (N'quizzes', N'lesson_id', N'int', 4, 1, 0, 0, 0),
    (N'quizzes', N'title', N'nvarchar', 510, 0, 0, 0, 0),
    (N'quizzes', N'description', N'nvarchar', -1, 1, 0, 0, 0),
    (N'quizzes', N'time_limit_minutes', N'int', 4, 1, 0, 0, 0),
    (N'quizzes', N'max_attempts', N'int', 4, 0, 0, 0, 0),
    (N'quizzes', N'start_time', N'datetime2', 8, 1, 0, 0, 7),
    (N'quizzes', N'due_date', N'datetime2', 8, 1, 0, 0, 7),
    (N'quizzes', N'end_time', N'datetime2', 8, 1, 0, 0, 7),
    (N'quizzes', N'rules', N'nvarchar', -1, 1, 0, 0, 0),
    (N'quizzes', N'status', N'nvarchar', 40, 0, 0, 0, 0),
    (N'quizzes', N'created_by', N'int', 4, 0, 0, 0, 0),
    (N'quizzes', N'created_at', N'datetime2', 8, 0, 0, 0, 7),
    (N'questions', N'question_id', N'int', 4, 0, 1, 0, 0),
    (N'questions', N'quiz_id', N'int', 4, 0, 0, 0, 0),
    (N'questions', N'content', N'nvarchar', -1, 0, 0, 0, 0),
    (N'questions', N'type', N'nvarchar', 60, 0, 0, 0, 0),
    (N'questions', N'score', N'decimal', 5, 0, 0, 8, 2),
    (N'questions', N'order_index', N'int', 4, 0, 0, 0, 0),
    (N'questions', N'correct_answer', N'nvarchar', -1, 1, 0, 0, 0),
    (N'questions', N'explanation', N'nvarchar', -1, 1, 0, 0, 0),
    (N'answer_options', N'option_id', N'int', 4, 0, 1, 0, 0),
    (N'answer_options', N'question_id', N'int', 4, 0, 0, 0, 0),
    (N'answer_options', N'content', N'nvarchar', -1, 0, 0, 0, 0),
    (N'answer_options', N'is_correct', N'bit', 1, 0, 0, 0, 0),
    (N'answer_options', N'order_index', N'int', 4, 0, 0, 0, 0),
    (N'quiz_attempts', N'attempt_id', N'int', 4, 0, 1, 0, 0),
    (N'quiz_attempts', N'quiz_id', N'int', 4, 0, 0, 0, 0),
    (N'quiz_attempts', N'student_id', N'int', 4, 0, 0, 0, 0),
    (N'quiz_attempts', N'course_id', N'int', 4, 0, 0, 0, 0),
    (N'quiz_attempts', N'attempt_number', N'int', 4, 0, 0, 0, 0),
    (N'quiz_attempts', N'started_at', N'datetime2', 8, 0, 0, 0, 7),
    (N'quiz_attempts', N'deadline_at', N'datetime2', 8, 1, 0, 0, 7),
    (N'quiz_attempts', N'submitted_at', N'datetime2', 8, 1, 0, 0, 7),
    (N'quiz_attempts', N'status', N'nvarchar', 40, 0, 0, 0, 0),
    (N'quiz_attempts', N'score', N'decimal', 5, 1, 0, 8, 2),
    (N'quiz_attempts', N'max_score', N'decimal', 5, 0, 0, 8, 2),
    (N'quiz_attempts', N'result_status', N'nvarchar', 40, 0, 0, 0, 0),
    (N'quiz_attempts', N'published_by', N'int', 4, 1, 0, 0, 0),
    (N'quiz_attempts', N'published_at', N'datetime2', 8, 1, 0, 0, 7),
    (N'quiz_answers', N'answer_id', N'int', 4, 0, 1, 0, 0),
    (N'quiz_answers', N'attempt_id', N'int', 4, 0, 0, 0, 0),
    (N'quiz_answers', N'quiz_id', N'int', 4, 0, 0, 0, 0),
    (N'quiz_answers', N'question_id', N'int', 4, 0, 0, 0, 0),
    (N'quiz_answers', N'answer_text', N'nvarchar', -1, 1, 0, 0, 0),
    (N'quiz_answers', N'question_content_snapshot', N'nvarchar', -1, 0, 0, 0, 0),
    (N'quiz_answers', N'question_type_snapshot', N'nvarchar', 60, 0, 0, 0, 0),
    (N'quiz_answers', N'max_score', N'decimal', 5, 0, 0, 8, 2),
    (N'quiz_answers', N'awarded_score', N'decimal', 5, 1, 0, 8, 2),
    (N'quiz_answers', N'graded_by', N'int', 4, 1, 0, 0, 0),
    (N'quiz_answers', N'graded_at', N'datetime2', 8, 1, 0, 0, 7),
    (N'quiz_answer_options', N'answer_id', N'int', 4, 0, 0, 0, 0),
    (N'quiz_answer_options', N'question_id', N'int', 4, 0, 0, 0, 0),
    (N'quiz_answer_options', N'option_id', N'int', 4, 0, 0, 0, 0),
    (N'quiz_answer_options', N'option_content_snapshot', N'nvarchar', -1, 0, 0, 0, 0),
    (N'study_plans', N'plan_id', N'int', 4, 0, 1, 0, 0),
    (N'study_plans', N'student_id', N'int', 4, 0, 0, 0, 0),
    (N'study_plans', N'title', N'nvarchar', 510, 0, 0, 0, 0),
    (N'study_plans', N'description', N'nvarchar', 4000, 1, 0, 0, 0),
    (N'study_plans', N'start_date', N'date', 3, 0, 0, 0, 0),
    (N'study_plans', N'end_date', N'date', 3, 0, 0, 0, 0),
    (N'study_plans', N'timezone', N'nvarchar', 200, 0, 0, 0, 0),
    (N'study_plans', N'status', N'nvarchar', 40, 0, 0, 0, 0),
    (N'study_plans', N'created_at', N'datetime2', 8, 0, 0, 0, 7),
    (N'personal_tasks', N'task_id', N'int', 4, 0, 1, 0, 0),
    (N'personal_tasks', N'plan_id', N'int', 4, 0, 0, 0, 0),
    (N'personal_tasks', N'student_id', N'int', 4, 0, 0, 0, 0),
    (N'personal_tasks', N'title', N'nvarchar', 510, 0, 0, 0, 0),
    (N'personal_tasks', N'notes', N'nvarchar', -1, 1, 0, 0, 0),
    (N'personal_tasks', N'course_id', N'int', 4, 1, 0, 0, 0),
    (N'personal_tasks', N'related_lesson_id', N'int', 4, 1, 0, 0, 0),
    (N'personal_tasks', N'related_assignment_id', N'int', 4, 1, 0, 0, 0),
    (N'personal_tasks', N'related_quiz_id', N'int', 4, 1, 0, 0, 0),
    (N'personal_tasks', N'planned_start_at', N'datetime2', 8, 0, 0, 0, 7),
    (N'personal_tasks', N'planned_end_at', N'datetime2', 8, 0, 0, 0, 7),
    (N'personal_tasks', N'status', N'nvarchar', 40, 0, 0, 0, 0),
    (N'personal_tasks', N'completed_at', N'datetime2', 8, 1, 0, 0, 7),
    (N'learning_progress', N'progress_id', N'int', 4, 0, 1, 0, 0),
    (N'learning_progress', N'student_id', N'int', 4, 0, 0, 0, 0),
    (N'learning_progress', N'course_id', N'int', 4, 0, 0, 0, 0),
    (N'learning_progress', N'percent_complete', N'decimal', 5, 0, 0, 5, 2),
    (N'learning_progress', N'completed_lessons', N'int', 4, 0, 0, 0, 0),
    (N'learning_progress', N'total_lessons', N'int', 4, 0, 0, 0, 0),
    (N'learning_progress', N'last_accessed_at', N'datetime2', 8, 1, 0, 0, 7),
    (N'learning_progress', N'updated_at', N'datetime2', 8, 0, 0, 0, 7),
    (N'learning_history', N'history_id', N'bigint', 8, 0, 1, 0, 0),
    (N'learning_history', N'student_id', N'int', 4, 0, 0, 0, 0),
    (N'learning_history', N'course_id', N'int', 4, 0, 0, 0, 0),
    (N'learning_history', N'activity_type', N'nvarchar', 60, 0, 0, 0, 0),
    (N'learning_history', N'lesson_id', N'int', 4, 1, 0, 0, 0),
    (N'learning_history', N'assignment_id', N'int', 4, 1, 0, 0, 0),
    (N'learning_history', N'quiz_id', N'int', 4, 1, 0, 0, 0),
    (N'learning_history', N'details', N'nvarchar', 4000, 1, 0, 0, 0),
    (N'learning_history', N'occurred_at', N'datetime2', 8, 0, 0, 0, 7),
    (N'course_questions', N'question_id', N'int', 4, 0, 1, 0, 0),
    (N'course_questions', N'course_id', N'int', 4, 0, 0, 0, 0),
    (N'course_questions', N'lesson_id', N'int', 4, 1, 0, 0, 0),
    (N'course_questions', N'student_id', N'int', 4, 0, 0, 0, 0),
    (N'course_questions', N'title', N'nvarchar', 510, 0, 0, 0, 0),
    (N'course_questions', N'content', N'nvarchar', -1, 0, 0, 0, 0),
    (N'course_questions', N'status', N'nvarchar', 40, 0, 0, 0, 0),
    (N'course_questions', N'created_at', N'datetime2', 8, 0, 0, 0, 7),
    (N'course_answers', N'answer_id', N'int', 4, 0, 1, 0, 0),
    (N'course_answers', N'question_id', N'int', 4, 0, 0, 0, 0),
    (N'course_answers', N'instructor_id', N'int', 4, 0, 0, 0, 0),
    (N'course_answers', N'content', N'nvarchar', -1, 0, 0, 0, 0),
    (N'course_answers', N'created_at', N'datetime2', 8, 0, 0, 0, 7),
    (N'course_answers', N'updated_at', N'datetime2', 8, 1, 0, 0, 7),
    (N'discussions', N'discussion_id', N'int', 4, 0, 1, 0, 0),
    (N'discussions', N'course_id', N'int', 4, 0, 0, 0, 0),
    (N'discussions', N'user_id', N'int', 4, 0, 0, 0, 0),
    (N'discussions', N'title', N'nvarchar', 510, 0, 0, 0, 0),
    (N'discussions', N'content', N'nvarchar', -1, 0, 0, 0, 0),
    (N'discussions', N'status', N'nvarchar', 40, 0, 0, 0, 0),
    (N'discussions', N'created_at', N'datetime2', 8, 0, 0, 0, 7),
    (N'discussions', N'moderated_by', N'int', 4, 1, 0, 0, 0),
    (N'discussions', N'moderated_at', N'datetime2', 8, 1, 0, 0, 7),
    (N'discussions', N'moderation_reason', N'nvarchar', 4000, 1, 0, 0, 0),
    (N'discussion_replies', N'reply_id', N'int', 4, 0, 1, 0, 0),
    (N'discussion_replies', N'discussion_id', N'int', 4, 0, 0, 0, 0),
    (N'discussion_replies', N'user_id', N'int', 4, 0, 0, 0, 0),
    (N'discussion_replies', N'parent_reply_id', N'int', 4, 1, 0, 0, 0),
    (N'discussion_replies', N'content', N'nvarchar', -1, 0, 0, 0, 0),
    (N'discussion_replies', N'status', N'nvarchar', 40, 0, 0, 0, 0),
    (N'discussion_replies', N'created_at', N'datetime2', 8, 0, 0, 0, 7),
    (N'discussion_replies', N'moderated_by', N'int', 4, 1, 0, 0, 0),
    (N'discussion_replies', N'moderated_at', N'datetime2', 8, 1, 0, 0, 7),
    (N'discussion_replies', N'moderation_reason', N'nvarchar', 4000, 1, 0, 0, 0),
    (N'announcements', N'announcement_id', N'int', 4, 0, 1, 0, 0),
    (N'announcements', N'course_id', N'int', 4, 0, 0, 0, 0),
    (N'announcements', N'instructor_id', N'int', 4, 0, 0, 0, 0),
    (N'announcements', N'title', N'nvarchar', 510, 0, 0, 0, 0),
    (N'announcements', N'content', N'nvarchar', -1, 0, 0, 0, 0),
    (N'announcements', N'status', N'nvarchar', 40, 0, 0, 0, 0),
    (N'announcements', N'created_at', N'datetime2', 8, 0, 0, 0, 7),
    (N'announcements', N'sent_at', N'datetime2', 8, 1, 0, 0, 7),
    (N'notifications', N'notification_id', N'bigint', 8, 0, 1, 0, 0),
    (N'notifications', N'user_id', N'int', 4, 0, 0, 0, 0),
    (N'notifications', N'course_id', N'int', 4, 0, 0, 0, 0),
    (N'notifications', N'announcement_id', N'int', 4, 0, 0, 0, 0),
    (N'notifications', N'created_at', N'datetime2', 8, 0, 0, 0, 7),
    (N'notifications', N'read_at', N'datetime2', 8, 1, 0, 0, 7),
    (N'certificates', N'certificate_id', N'int', 4, 0, 1, 0, 0),
    (N'certificates', N'student_id', N'int', 4, 0, 0, 0, 0),
    (N'certificates', N'course_id', N'int', 4, 0, 0, 0, 0),
    (N'certificates', N'verification_code', N'nvarchar', 200, 0, 0, 0, 0),
    (N'certificates', N'file_url', N'nvarchar', 4096, 1, 0, 0, 0),
    (N'certificates', N'issued_at', N'datetime2', 8, 0, 0, 0, 7),
    (N'certificates', N'status', N'nvarchar', 40, 0, 0, 0, 0),
    (N'certificates', N'revoked_at', N'datetime2', 8, 1, 0, 0, 7),
    (N'certificates', N'revocation_reason', N'nvarchar', 4000, 1, 0, 0, 0),
    (N'study_groups', N'group_id', N'int', 4, 0, 1, 0, 0),
    (N'study_groups', N'course_id', N'int', 4, 0, 0, 0, 0),
    (N'study_groups', N'name', N'nvarchar', 200, 0, 0, 0, 0),
    (N'study_groups', N'description', N'nvarchar', 4000, 1, 0, 0, 0),
    (N'study_groups', N'created_by', N'int', 4, 0, 0, 0, 0),
    (N'study_groups', N'status', N'nvarchar', 40, 0, 0, 0, 0),
    (N'study_groups', N'created_at', N'datetime2', 8, 0, 0, 0, 7),
    (N'group_members', N'group_id', N'int', 4, 0, 0, 0, 0),
    (N'group_members', N'user_id', N'int', 4, 0, 0, 0, 0),
    (N'group_members', N'course_id', N'int', 4, 0, 0, 0, 0),
    (N'group_members', N'role_in_group', N'nvarchar', 40, 0, 0, 0, 0),
    (N'group_members', N'joined_at', N'datetime2', 8, 0, 0, 0, 7),
    (N'ai_learning_resources', N'resource_id', N'int', 4, 0, 1, 0, 0),
    (N'ai_learning_resources', N'title', N'nvarchar', 510, 0, 0, 0, 0),
    (N'ai_learning_resources', N'url', N'nvarchar', 4096, 0, 0, 0, 0),
    (N'ai_learning_resources', N'source', N'nvarchar', 510, 1, 0, 0, 0),
    (N'ai_learning_resources', N'course_id', N'int', 4, 1, 0, 0, 0),
    (N'ai_learning_resources', N'visibility', N'nvarchar', 40, 0, 0, 0, 0),
    (N'ai_learning_resources', N'status', N'nvarchar', 40, 0, 0, 0, 0),
    (N'ai_learning_resources', N'submitted_by', N'int', 4, 0, 0, 0, 0),
    (N'ai_learning_resources', N'reviewed_by', N'int', 4, 1, 0, 0, 0),
    (N'ai_learning_resources', N'reviewed_at', N'datetime2', 8, 1, 0, 0, 7),
    (N'ai_learning_resources', N'created_at', N'datetime2', 8, 0, 0, 0, 7),
    (N'ai_chat_sessions', N'session_id', N'int', 4, 0, 1, 0, 0),
    (N'ai_chat_sessions', N'student_id', N'int', 4, 0, 0, 0, 0),
    (N'ai_chat_sessions', N'course_id', N'int', 4, 1, 0, 0, 0),
    (N'ai_chat_sessions', N'title', N'nvarchar', 510, 1, 0, 0, 0),
    (N'ai_chat_sessions', N'created_at', N'datetime2', 8, 0, 0, 0, 7),
    (N'ai_chat_logs', N'chat_id', N'bigint', 8, 0, 1, 0, 0),
    (N'ai_chat_logs', N'session_id', N'int', 4, 0, 0, 0, 0),
    (N'ai_chat_logs', N'request_id', N'uniqueidentifier', 16, 0, 0, 0, 0),
    (N'ai_chat_logs', N'question', N'nvarchar', -1, 0, 0, 0, 0),
    (N'ai_chat_logs', N'answer', N'nvarchar', -1, 1, 0, 0, 0),
    (N'ai_chat_logs', N'model', N'nvarchar', 200, 1, 0, 0, 0),
    (N'ai_chat_logs', N'status', N'nvarchar', 40, 0, 0, 0, 0),
    (N'ai_chat_logs', N'created_at', N'datetime2', 8, 0, 0, 0, 7),
    (N'ai_chat_logs', N'completed_at', N'datetime2', 8, 1, 0, 0, 7),
    (N'ai_chat_logs', N'error_message', N'nvarchar', 4000, 1, 0, 0, 0),
    (N'ai_chat_sources', N'chat_id', N'bigint', 8, 0, 0, 0, 0),
    (N'ai_chat_sources', N'resource_id', N'int', 4, 0, 0, 0, 0),
    (N'ai_chat_sources', N'citation_text', N'nvarchar', 4000, 1, 0, 0, 0);

DECLARE @schema_error NVARCHAR(2048);
SELECT TOP (1) @schema_error = N'Incompatible or missing column: dbo.' + e.table_name + N'.' + e.column_name
FROM #EduSphereExpectedColumns e
LEFT JOIN sys.tables t ON t.name = e.table_name AND t.schema_id = SCHEMA_ID(N'dbo')
LEFT JOIN sys.columns c ON c.object_id = t.object_id AND c.name = e.column_name
LEFT JOIN sys.types ty ON ty.user_type_id = c.user_type_id
WHERE c.column_id IS NULL OR ty.name <> e.type_name OR c.max_length <> e.max_length
    OR c.is_nullable <> e.is_nullable OR c.is_identity <> e.is_identity
    OR (e.type_name = N'decimal' AND (c.precision <> e.expected_precision OR c.scale <> e.expected_scale))
    OR (e.type_name = N'datetime2' AND c.scale <> e.expected_scale);
IF @schema_error IS NOT NULL THROW 50001, @schema_error, 1;

IF OBJECT_ID(N'tempdb..#EduSphereExpectedKeys') IS NOT NULL DROP TABLE #EduSphereExpectedKeys;
CREATE TABLE #EduSphereExpectedKeys (table_name SYSNAME COLLATE DATABASE_DEFAULT, key_type NVARCHAR(2) COLLATE DATABASE_DEFAULT, column_list NVARCHAR(500) COLLATE DATABASE_DEFAULT);
INSERT INTO #EduSphereExpectedKeys VALUES
    (N'roles', N'PK', N'role_id'),
    (N'roles', N'UQ', N'role_name'),
    (N'users', N'PK', N'user_id'),
    (N'users', N'UQ', N'email'),
    (N'user_roles', N'PK', N'user_id,role_id'),
    (N'email_verification_tokens', N'PK', N'token_id'),
    (N'email_verification_tokens', N'UQ', N'token'),
    (N'password_reset_tokens', N'PK', N'token_id'),
    (N'password_reset_tokens', N'UQ', N'token'),
    (N'oauth_accounts', N'PK', N'oauth_id'),
    (N'oauth_accounts', N'UQ', N'provider,provider_user_id'),
    (N'account_events', N'PK', N'event_id'),
    (N'categories', N'PK', N'category_id'),
    (N'categories', N'UQ', N'parent_category_id,name'),
    (N'courses', N'PK', N'course_id'),
    (N'course_reviews', N'PK', N'review_id'),
    (N'payments', N'PK', N'payment_id'),
    (N'payments', N'UQ', N'request_key'),
    (N'payments', N'UQ', N'student_id,course_id,payment_id'),
    (N'payment_events', N'PK', N'event_id'),
    (N'payment_events', N'UQ', N'payment_id,provider_event_id'),
    (N'refunds', N'PK', N'refund_id'),
    (N'refunds', N'UQ', N'request_key'),
    (N'enrollments', N'PK', N'enrollment_id'),
    (N'enrollments', N'UQ', N'student_id,course_id'),
    (N'lessons', N'PK', N'lesson_id'),
    (N'lessons', N'UQ', N'course_id,order_index'),
    (N'lessons', N'UQ', N'course_id,lesson_id'),
    (N'materials', N'PK', N'material_id'),
    (N'materials', N'UQ', N'lesson_id,order_index'),
    (N'videos', N'PK', N'video_id'),
    (N'videos', N'UQ', N'material_id'),
    (N'lesson_completions', N'PK', N'completion_id'),
    (N'lesson_completions', N'UQ', N'student_id,lesson_id'),
    (N'assignments', N'PK', N'assignment_id'),
    (N'assignments', N'UQ', N'course_id,assignment_id'),
    (N'submissions', N'PK', N'submission_id'),
    (N'submissions', N'UQ', N'assignment_id,student_id,attempt_number'),
    (N'grades', N'PK', N'grade_id'),
    (N'grades', N'UQ', N'submission_id'),
    (N'quizzes', N'PK', N'quiz_id'),
    (N'quizzes', N'UQ', N'course_id,quiz_id'),
    (N'questions', N'PK', N'question_id'),
    (N'questions', N'UQ', N'quiz_id,order_index'),
    (N'questions', N'UQ', N'quiz_id,question_id'),
    (N'answer_options', N'PK', N'option_id'),
    (N'answer_options', N'UQ', N'question_id,order_index'),
    (N'answer_options', N'UQ', N'question_id,option_id'),
    (N'quiz_attempts', N'PK', N'attempt_id'),
    (N'quiz_attempts', N'UQ', N'quiz_id,student_id,attempt_number'),
    (N'quiz_attempts', N'UQ', N'attempt_id,quiz_id'),
    (N'quiz_answers', N'PK', N'answer_id'),
    (N'quiz_answers', N'UQ', N'attempt_id,question_id'),
    (N'quiz_answers', N'UQ', N'answer_id,question_id'),
    (N'quiz_answer_options', N'PK', N'answer_id,option_id'),
    (N'study_plans', N'PK', N'plan_id'),
    (N'study_plans', N'UQ', N'plan_id,student_id'),
    (N'personal_tasks', N'PK', N'task_id'),
    (N'learning_progress', N'PK', N'progress_id'),
    (N'learning_progress', N'UQ', N'student_id,course_id'),
    (N'learning_history', N'PK', N'history_id'),
    (N'course_questions', N'PK', N'question_id'),
    (N'course_answers', N'PK', N'answer_id'),
    (N'discussions', N'PK', N'discussion_id'),
    (N'discussion_replies', N'PK', N'reply_id'),
    (N'discussion_replies', N'UQ', N'discussion_id,reply_id'),
    (N'announcements', N'PK', N'announcement_id'),
    (N'announcements', N'UQ', N'course_id,announcement_id'),
    (N'notifications', N'PK', N'notification_id'),
    (N'notifications', N'UQ', N'user_id,announcement_id'),
    (N'certificates', N'PK', N'certificate_id'),
    (N'certificates', N'UQ', N'verification_code'),
    (N'certificates', N'UQ', N'student_id,course_id'),
    (N'study_groups', N'PK', N'group_id'),
    (N'study_groups', N'UQ', N'course_id,name'),
    (N'study_groups', N'UQ', N'group_id,course_id'),
    (N'group_members', N'PK', N'group_id,user_id'),
    (N'ai_learning_resources', N'PK', N'resource_id'),
    (N'ai_chat_sessions', N'PK', N'session_id'),
    (N'ai_chat_logs', N'PK', N'chat_id'),
    (N'ai_chat_logs', N'UQ', N'request_id'),
    (N'ai_chat_sources', N'PK', N'chat_id,resource_id');

SET @schema_error = NULL;
;WITH actual_keys AS (
    SELECT t.name AS table_name, CASE WHEN i.is_primary_key = 1 THEN N'PK' ELSE N'UQ' END AS key_type,
        STRING_AGG(CONVERT(NVARCHAR(MAX), c.name), N',') WITHIN GROUP (ORDER BY ic.key_ordinal) AS column_list
    FROM sys.tables t JOIN sys.indexes i ON i.object_id = t.object_id
    JOIN sys.index_columns ic ON ic.object_id = i.object_id AND ic.index_id = i.index_id
    JOIN sys.columns c ON c.object_id = ic.object_id AND c.column_id = ic.column_id
    WHERE t.schema_id = SCHEMA_ID(N'dbo') AND i.is_unique = 1 AND i.is_disabled = 0
        AND i.has_filter = 0 AND ic.key_ordinal > 0
    GROUP BY t.name, i.is_primary_key, i.index_id
)
SELECT TOP (1) @schema_error = N'Missing required key on dbo.' + e.table_name + N' (' + e.column_list + N').'
FROM #EduSphereExpectedKeys e
WHERE NOT EXISTS (SELECT 1 FROM actual_keys a WHERE a.table_name = e.table_name AND a.key_type = e.key_type AND a.column_list = e.column_list);
IF @schema_error IS NOT NULL THROW 50002, @schema_error, 1;

IF OBJECT_ID(N'tempdb..#EduSphereExpectedFks') IS NOT NULL DROP TABLE #EduSphereExpectedFks;
CREATE TABLE #EduSphereExpectedFks (table_name SYSNAME COLLATE DATABASE_DEFAULT, column_list NVARCHAR(500) COLLATE DATABASE_DEFAULT, referenced_table SYSNAME COLLATE DATABASE_DEFAULT, referenced_columns NVARCHAR(500) COLLATE DATABASE_DEFAULT, delete_action NVARCHAR(20) COLLATE DATABASE_DEFAULT);
INSERT INTO #EduSphereExpectedFks VALUES
    (N'user_roles', N'user_id', N'users', N'user_id', N'CASCADE'),
    (N'user_roles', N'role_id', N'roles', N'role_id', N'CASCADE'),
    (N'email_verification_tokens', N'user_id', N'users', N'user_id', N'CASCADE'),
    (N'password_reset_tokens', N'user_id', N'users', N'user_id', N'CASCADE'),
    (N'oauth_accounts', N'user_id', N'users', N'user_id', N'CASCADE'),
    (N'account_events', N'user_id', N'users', N'user_id', N'NO_ACTION'),
    (N'account_events', N'actor_id', N'users', N'user_id', N'NO_ACTION'),
    (N'account_events', N'role_id', N'roles', N'role_id', N'NO_ACTION'),
    (N'categories', N'parent_category_id', N'categories', N'category_id', N'NO_ACTION'),
    (N'courses', N'category_id', N'categories', N'category_id', N'NO_ACTION'),
    (N'courses', N'instructor_id', N'users', N'user_id', N'NO_ACTION'),
    (N'course_reviews', N'course_id', N'courses', N'course_id', N'NO_ACTION'),
    (N'course_reviews', N'admin_id', N'users', N'user_id', N'NO_ACTION'),
    (N'payments', N'student_id', N'users', N'user_id', N'NO_ACTION'),
    (N'payments', N'course_id', N'courses', N'course_id', N'NO_ACTION'),
    (N'payment_events', N'payment_id', N'payments', N'payment_id', N'NO_ACTION'),
    (N'refunds', N'payment_id', N'payments', N'payment_id', N'NO_ACTION'),
    (N'refunds', N'processed_by', N'users', N'user_id', N'NO_ACTION'),
    (N'enrollments', N'student_id', N'users', N'user_id', N'NO_ACTION'),
    (N'enrollments', N'course_id', N'courses', N'course_id', N'NO_ACTION'),
    (N'enrollments', N'student_id,course_id,payment_id', N'payments', N'student_id,course_id,payment_id', N'NO_ACTION'),
    (N'lessons', N'course_id', N'courses', N'course_id', N'NO_ACTION'),
    (N'materials', N'lesson_id', N'lessons', N'lesson_id', N'NO_ACTION'),
    (N'materials', N'uploaded_by', N'users', N'user_id', N'NO_ACTION'),
    (N'videos', N'material_id', N'materials', N'material_id', N'NO_ACTION'),
    (N'videos', N'uploaded_by', N'users', N'user_id', N'NO_ACTION'),
    (N'lesson_completions', N'student_id,course_id', N'enrollments', N'student_id,course_id', N'NO_ACTION'),
    (N'lesson_completions', N'course_id,lesson_id', N'lessons', N'course_id,lesson_id', N'NO_ACTION'),
    (N'assignments', N'course_id', N'courses', N'course_id', N'NO_ACTION'),
    (N'assignments', N'course_id,lesson_id', N'lessons', N'course_id,lesson_id', N'NO_ACTION'),
    (N'assignments', N'created_by', N'users', N'user_id', N'NO_ACTION'),
    (N'submissions', N'course_id,assignment_id', N'assignments', N'course_id,assignment_id', N'NO_ACTION'),
    (N'submissions', N'student_id,course_id', N'enrollments', N'student_id,course_id', N'NO_ACTION'),
    (N'grades', N'submission_id', N'submissions', N'submission_id', N'NO_ACTION'),
    (N'grades', N'graded_by', N'users', N'user_id', N'NO_ACTION'),
    (N'grades', N'published_by', N'users', N'user_id', N'NO_ACTION'),
    (N'quizzes', N'course_id', N'courses', N'course_id', N'NO_ACTION'),
    (N'quizzes', N'course_id,lesson_id', N'lessons', N'course_id,lesson_id', N'NO_ACTION'),
    (N'quizzes', N'created_by', N'users', N'user_id', N'NO_ACTION'),
    (N'questions', N'quiz_id', N'quizzes', N'quiz_id', N'NO_ACTION'),
    (N'answer_options', N'question_id', N'questions', N'question_id', N'NO_ACTION'),
    (N'quiz_attempts', N'course_id,quiz_id', N'quizzes', N'course_id,quiz_id', N'NO_ACTION'),
    (N'quiz_attempts', N'student_id,course_id', N'enrollments', N'student_id,course_id', N'NO_ACTION'),
    (N'quiz_attempts', N'published_by', N'users', N'user_id', N'NO_ACTION'),
    (N'quiz_answers', N'attempt_id,quiz_id', N'quiz_attempts', N'attempt_id,quiz_id', N'NO_ACTION'),
    (N'quiz_answers', N'quiz_id,question_id', N'questions', N'quiz_id,question_id', N'NO_ACTION'),
    (N'quiz_answers', N'graded_by', N'users', N'user_id', N'NO_ACTION'),
    (N'quiz_answer_options', N'answer_id,question_id', N'quiz_answers', N'answer_id,question_id', N'NO_ACTION'),
    (N'quiz_answer_options', N'question_id,option_id', N'answer_options', N'question_id,option_id', N'NO_ACTION'),
    (N'study_plans', N'student_id', N'users', N'user_id', N'NO_ACTION'),
    (N'personal_tasks', N'plan_id,student_id', N'study_plans', N'plan_id,student_id', N'NO_ACTION'),
    (N'personal_tasks', N'student_id,course_id', N'enrollments', N'student_id,course_id', N'NO_ACTION'),
    (N'personal_tasks', N'course_id,related_lesson_id', N'lessons', N'course_id,lesson_id', N'NO_ACTION'),
    (N'personal_tasks', N'course_id,related_assignment_id', N'assignments', N'course_id,assignment_id', N'NO_ACTION'),
    (N'personal_tasks', N'course_id,related_quiz_id', N'quizzes', N'course_id,quiz_id', N'NO_ACTION'),
    (N'learning_progress', N'student_id,course_id', N'enrollments', N'student_id,course_id', N'NO_ACTION'),
    (N'learning_history', N'student_id,course_id', N'enrollments', N'student_id,course_id', N'NO_ACTION'),
    (N'learning_history', N'course_id,lesson_id', N'lessons', N'course_id,lesson_id', N'NO_ACTION'),
    (N'learning_history', N'course_id,assignment_id', N'assignments', N'course_id,assignment_id', N'NO_ACTION'),
    (N'learning_history', N'course_id,quiz_id', N'quizzes', N'course_id,quiz_id', N'NO_ACTION'),
    (N'course_questions', N'student_id,course_id', N'enrollments', N'student_id,course_id', N'NO_ACTION'),
    (N'course_questions', N'course_id,lesson_id', N'lessons', N'course_id,lesson_id', N'NO_ACTION'),
    (N'course_answers', N'question_id', N'course_questions', N'question_id', N'NO_ACTION'),
    (N'course_answers', N'instructor_id', N'users', N'user_id', N'NO_ACTION'),
    (N'discussions', N'course_id', N'courses', N'course_id', N'NO_ACTION'),
    (N'discussions', N'user_id', N'users', N'user_id', N'NO_ACTION'),
    (N'discussions', N'moderated_by', N'users', N'user_id', N'NO_ACTION'),
    (N'discussion_replies', N'discussion_id', N'discussions', N'discussion_id', N'NO_ACTION'),
    (N'discussion_replies', N'user_id', N'users', N'user_id', N'NO_ACTION'),
    (N'discussion_replies', N'discussion_id,parent_reply_id', N'discussion_replies', N'discussion_id,reply_id', N'NO_ACTION'),
    (N'discussion_replies', N'moderated_by', N'users', N'user_id', N'NO_ACTION'),
    (N'announcements', N'course_id', N'courses', N'course_id', N'NO_ACTION'),
    (N'announcements', N'instructor_id', N'users', N'user_id', N'NO_ACTION'),
    (N'notifications', N'user_id,course_id', N'enrollments', N'student_id,course_id', N'NO_ACTION'),
    (N'notifications', N'course_id,announcement_id', N'announcements', N'course_id,announcement_id', N'NO_ACTION'),
    (N'certificates', N'student_id,course_id', N'enrollments', N'student_id,course_id', N'NO_ACTION'),
    (N'study_groups', N'course_id', N'courses', N'course_id', N'NO_ACTION'),
    (N'study_groups', N'created_by', N'users', N'user_id', N'NO_ACTION'),
    (N'group_members', N'group_id,course_id', N'study_groups', N'group_id,course_id', N'NO_ACTION'),
    (N'group_members', N'user_id', N'users', N'user_id', N'NO_ACTION'),
    (N'ai_learning_resources', N'course_id', N'courses', N'course_id', N'NO_ACTION'),
    (N'ai_learning_resources', N'submitted_by', N'users', N'user_id', N'NO_ACTION'),
    (N'ai_learning_resources', N'reviewed_by', N'users', N'user_id', N'NO_ACTION'),
    (N'ai_chat_sessions', N'student_id', N'users', N'user_id', N'NO_ACTION'),
    (N'ai_chat_sessions', N'student_id,course_id', N'enrollments', N'student_id,course_id', N'NO_ACTION'),
    (N'ai_chat_logs', N'session_id', N'ai_chat_sessions', N'session_id', N'NO_ACTION'),
    (N'ai_chat_sources', N'chat_id', N'ai_chat_logs', N'chat_id', N'NO_ACTION'),
    (N'ai_chat_sources', N'resource_id', N'ai_learning_resources', N'resource_id', N'NO_ACTION');

SET @schema_error = NULL;
;WITH actual_fks AS (
    SELECT pt.name AS table_name, rt.name AS referenced_table,
        f.delete_referential_action_desc COLLATE DATABASE_DEFAULT AS delete_action,
        STRING_AGG(CONVERT(NVARCHAR(MAX), pc.name), N',') WITHIN GROUP (ORDER BY fc.constraint_column_id) AS column_list,
        STRING_AGG(CONVERT(NVARCHAR(MAX), rc.name), N',') WITHIN GROUP (ORDER BY fc.constraint_column_id) AS referenced_columns
    FROM sys.foreign_keys f
    JOIN sys.tables pt ON pt.object_id = f.parent_object_id
    JOIN sys.tables rt ON rt.object_id = f.referenced_object_id
    JOIN sys.foreign_key_columns fc ON fc.constraint_object_id = f.object_id
    JOIN sys.columns pc ON pc.object_id = fc.parent_object_id AND pc.column_id = fc.parent_column_id
    JOIN sys.columns rc ON rc.object_id = fc.referenced_object_id AND rc.column_id = fc.referenced_column_id
    WHERE pt.schema_id = SCHEMA_ID(N'dbo') AND rt.schema_id = SCHEMA_ID(N'dbo')
        AND f.is_disabled = 0 AND f.is_not_trusted = 0
    GROUP BY pt.name, rt.name, f.delete_referential_action_desc, f.object_id
)
SELECT TOP (1) @schema_error = N'Missing or incompatible foreign key: dbo.' + e.table_name + N' (' + e.column_list + N').'
FROM #EduSphereExpectedFks e WHERE NOT EXISTS (
    SELECT 1 FROM actual_fks a WHERE a.table_name = e.table_name AND a.column_list = e.column_list
        AND a.referenced_table = e.referenced_table AND a.referenced_columns = e.referenced_columns AND a.delete_action = e.delete_action
);
IF @schema_error IS NOT NULL THROW 50003, @schema_error, 1;

IF OBJECT_ID(N'tempdb..#EduSphereExpectedChecks') IS NOT NULL DROP TABLE #EduSphereExpectedChecks;
CREATE TABLE #EduSphereExpectedChecks (table_name SYSNAME COLLATE DATABASE_DEFAULT, constraint_name SYSNAME COLLATE DATABASE_DEFAULT);
INSERT INTO #EduSphereExpectedChecks VALUES
    (N'users', N'CK_users_status'),
    (N'account_events', N'CK_account_events_action'),
    (N'account_events', N'CK_account_events_role'),
    (N'categories', N'CK_categories_status'),
    (N'categories', N'CK_categories_parent'),
    (N'courses', N'CK_courses_status'),
    (N'courses', N'CK_courses_level'),
    (N'courses', N'CK_courses_price'),
    (N'courses', N'CK_courses_version'),
    (N'courses', N'CK_courses_approval'),
    (N'courses', N'CK_courses_publication'),
    (N'courses', N'CK_courses_archive'),
    (N'course_reviews', N'CK_course_reviews_decision'),
    (N'course_reviews', N'CK_course_reviews_version'),
    (N'course_reviews', N'CK_course_reviews_rejection'),
    (N'payments', N'CK_payments_amount'),
    (N'payments', N'CK_payments_status'),
    (N'payments', N'CK_payments_completed'),
    (N'refunds', N'CK_refunds_amount'),
    (N'refunds', N'CK_refunds_status'),
    (N'enrollments', N'CK_enrollments_status'),
    (N'enrollments', N'CK_enrollments_completed'),
    (N'enrollments', N'CK_enrollments_dropped'),
    (N'lessons', N'CK_lessons_order'),
    (N'lessons', N'CK_lessons_status'),
    (N'materials', N'CK_materials_type'),
    (N'materials', N'CK_materials_size'),
    (N'materials', N'CK_materials_order'),
    (N'videos', N'CK_videos_status'),
    (N'videos', N'CK_videos_duration'),
    (N'videos', N'CK_videos_ready'),
    (N'assignments', N'CK_assignments_score'),
    (N'assignments', N'CK_assignments_attempts'),
    (N'assignments', N'CK_assignments_dates'),
    (N'assignments', N'CK_assignments_status'),
    (N'submissions', N'CK_submissions_attempt'),
    (N'submissions', N'CK_submissions_content'),
    (N'submissions', N'CK_submissions_status'),
    (N'grades', N'CK_grades_score'),
    (N'grades', N'CK_grades_status'),
    (N'grades', N'CK_grades_publication'),
    (N'quizzes', N'CK_quizzes_time_limit'),
    (N'quizzes', N'CK_quizzes_attempts'),
    (N'quizzes', N'CK_quizzes_dates'),
    (N'quizzes', N'CK_quizzes_status'),
    (N'questions', N'CK_questions_type'),
    (N'questions', N'CK_questions_score'),
    (N'questions', N'CK_questions_order'),
    (N'answer_options', N'CK_answer_options_order'),
    (N'quiz_attempts', N'CK_quiz_attempts_number'),
    (N'quiz_attempts', N'CK_quiz_attempts_status'),
    (N'quiz_attempts', N'CK_quiz_attempts_dates'),
    (N'quiz_attempts', N'CK_quiz_attempts_submitted'),
    (N'quiz_attempts', N'CK_quiz_attempts_score'),
    (N'quiz_attempts', N'CK_quiz_attempts_result'),
    (N'quiz_attempts', N'CK_quiz_attempts_publication'),
    (N'quiz_answers', N'CK_quiz_answers_score'),
    (N'quiz_answers', N'CK_quiz_answers_type'),
    (N'study_plans', N'CK_study_plans_dates'),
    (N'study_plans', N'CK_study_plans_status'),
    (N'personal_tasks', N'CK_personal_tasks_dates'),
    (N'personal_tasks', N'CK_personal_tasks_status'),
    (N'personal_tasks', N'CK_personal_tasks_done'),
    (N'personal_tasks', N'CK_personal_tasks_reference'),
    (N'learning_progress', N'CK_learning_progress_percent'),
    (N'learning_progress', N'CK_learning_progress_counts'),
    (N'learning_history', N'CK_learning_history_type'),
    (N'course_questions', N'CK_course_questions_status'),
    (N'discussions', N'CK_discussions_status'),
    (N'discussions', N'CK_discussions_moderation'),
    (N'discussion_replies', N'CK_discussion_replies_parent'),
    (N'discussion_replies', N'CK_discussion_replies_status'),
    (N'discussion_replies', N'CK_discussion_replies_moderation'),
    (N'announcements', N'CK_announcements_status'),
    (N'announcements', N'CK_announcements_sent'),
    (N'certificates', N'CK_certificates_status'),
    (N'certificates', N'CK_certificates_revoked'),
    (N'study_groups', N'CK_study_groups_status'),
    (N'group_members', N'CK_group_members_role'),
    (N'ai_learning_resources', N'CK_ai_resources_visibility'),
    (N'ai_learning_resources', N'CK_ai_resources_status'),
    (N'ai_learning_resources', N'CK_ai_resources_approval'),
    (N'ai_chat_logs', N'CK_ai_logs_status'),
    (N'ai_chat_logs', N'CK_ai_logs_completed');

SET @schema_error = NULL;
SELECT TOP (1) @schema_error = N'Missing or disabled check constraint: ' + e.constraint_name
FROM #EduSphereExpectedChecks e WHERE NOT EXISTS (
    SELECT 1 FROM sys.check_constraints c WHERE c.parent_object_id = OBJECT_ID(N'dbo.' + e.table_name)
        AND c.name = e.constraint_name AND c.is_disabled = 0 AND c.is_not_trusted = 0
);
IF @schema_error IS NOT NULL THROW 50004, @schema_error, 1;

IF OBJECT_ID(N'tempdb..#EduSphereExpectedDefaults') IS NOT NULL DROP TABLE #EduSphereExpectedDefaults;
CREATE TABLE #EduSphereExpectedDefaults (table_name SYSNAME COLLATE DATABASE_DEFAULT, column_name SYSNAME COLLATE DATABASE_DEFAULT);
INSERT INTO #EduSphereExpectedDefaults VALUES
    (N'users', N'status'),
    (N'users', N'created_at'),
    (N'user_roles', N'assigned_at'),
    (N'oauth_accounts', N'created_at'),
    (N'account_events', N'created_at'),
    (N'categories', N'status'),
    (N'courses', N'level'),
    (N'courses', N'price'),
    (N'courses', N'currency'),
    (N'courses', N'status'),
    (N'courses', N'version_no'),
    (N'courses', N'created_at'),
    (N'course_reviews', N'reviewed_at'),
    (N'payments', N'currency'),
    (N'payments', N'status'),
    (N'payments', N'created_at'),
    (N'payment_events', N'signature_verified'),
    (N'payment_events', N'received_at'),
    (N'refunds', N'status'),
    (N'refunds', N'created_at'),
    (N'enrollments', N'enrolled_at'),
    (N'enrollments', N'status'),
    (N'lessons', N'status'),
    (N'lessons', N'created_at'),
    (N'materials', N'uploaded_at'),
    (N'videos', N'status'),
    (N'videos', N'uploaded_at'),
    (N'lesson_completions', N'completed_at'),
    (N'assignments', N'allow_resubmit'),
    (N'assignments', N'max_attempts'),
    (N'assignments', N'status'),
    (N'assignments', N'created_at'),
    (N'submissions', N'submitted_at'),
    (N'submissions', N'is_late'),
    (N'submissions', N'status'),
    (N'grades', N'graded_at'),
    (N'grades', N'result_status'),
    (N'quizzes', N'max_attempts'),
    (N'quizzes', N'status'),
    (N'quizzes', N'created_at'),
    (N'answer_options', N'is_correct'),
    (N'quiz_attempts', N'started_at'),
    (N'quiz_attempts', N'status'),
    (N'quiz_attempts', N'result_status'),
    (N'study_plans', N'timezone'),
    (N'study_plans', N'status'),
    (N'study_plans', N'created_at'),
    (N'personal_tasks', N'status'),
    (N'learning_progress', N'percent_complete'),
    (N'learning_progress', N'completed_lessons'),
    (N'learning_progress', N'total_lessons'),
    (N'learning_progress', N'updated_at'),
    (N'learning_history', N'occurred_at'),
    (N'course_questions', N'status'),
    (N'course_questions', N'created_at'),
    (N'course_answers', N'created_at'),
    (N'discussions', N'status'),
    (N'discussions', N'created_at'),
    (N'discussion_replies', N'status'),
    (N'discussion_replies', N'created_at'),
    (N'announcements', N'status'),
    (N'announcements', N'created_at'),
    (N'notifications', N'created_at'),
    (N'certificates', N'issued_at'),
    (N'certificates', N'status'),
    (N'study_groups', N'status'),
    (N'study_groups', N'created_at'),
    (N'group_members', N'role_in_group'),
    (N'group_members', N'joined_at'),
    (N'ai_learning_resources', N'status'),
    (N'ai_learning_resources', N'created_at'),
    (N'ai_chat_sessions', N'created_at'),
    (N'ai_chat_logs', N'request_id'),
    (N'ai_chat_logs', N'status'),
    (N'ai_chat_logs', N'created_at');
SET @schema_error = NULL;
SELECT TOP (1) @schema_error = N'Missing default on dbo.' + e.table_name + N'.' + e.column_name
FROM #EduSphereExpectedDefaults e WHERE NOT EXISTS (
    SELECT 1 FROM sys.columns c WHERE c.object_id = OBJECT_ID(N'dbo.' + e.table_name)
        AND c.name = e.column_name AND c.default_object_id <> 0
);
IF @schema_error IS NOT NULL THROW 50005, @schema_error, 1;

-- Indexes for common lookups. Nullable external IDs require filtered unique indexes.
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.user_roles') AND name = N'IX_user_roles_role')
    CREATE INDEX IX_user_roles_role ON dbo.user_roles (role_id, user_id);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.email_verification_tokens') AND name = N'IX_email_tokens_user_expiry')
    CREATE INDEX IX_email_tokens_user_expiry ON dbo.email_verification_tokens (user_id, expires_at);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.password_reset_tokens') AND name = N'IX_reset_tokens_user_expiry')
    CREATE INDEX IX_reset_tokens_user_expiry ON dbo.password_reset_tokens (user_id, expires_at);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.oauth_accounts') AND name = N'IX_oauth_accounts_user')
    CREATE INDEX IX_oauth_accounts_user ON dbo.oauth_accounts (user_id);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.account_events') AND name = N'IX_account_events_user_time')
    CREATE INDEX IX_account_events_user_time ON dbo.account_events (user_id, created_at);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.courses') AND name = N'IX_courses_catalog')
    CREATE INDEX IX_courses_catalog ON dbo.courses (status, category_id, level, price);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.courses') AND name = N'IX_courses_instructor')
    CREATE INDEX IX_courses_instructor ON dbo.courses (instructor_id, status);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.course_reviews') AND name = N'IX_course_reviews_history')
    CREATE INDEX IX_course_reviews_history ON dbo.course_reviews (course_id, course_version, reviewed_at);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.payments') AND name = N'IX_payments_student_course')
    CREATE INDEX IX_payments_student_course ON dbo.payments (student_id, course_id, created_at);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.payments') AND name = N'UX_payments_provider_transaction')
    CREATE UNIQUE INDEX UX_payments_provider_transaction ON dbo.payments (provider, provider_transaction_id) WHERE provider_transaction_id IS NOT NULL;

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.payment_events') AND name = N'IX_payment_events_pending')
    CREATE INDEX IX_payment_events_pending ON dbo.payment_events (payment_id, processed_at);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.refunds') AND name = N'IX_refunds_payment')
    CREATE INDEX IX_refunds_payment ON dbo.refunds (payment_id, status);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.enrollments') AND name = N'IX_enrollments_course')
    CREATE INDEX IX_enrollments_course ON dbo.enrollments (course_id, status, student_id);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.videos') AND name = N'UX_videos_provider_job')
    CREATE UNIQUE INDEX UX_videos_provider_job ON dbo.videos (provider, provider_job_id) WHERE provider IS NOT NULL AND provider_job_id IS NOT NULL;

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.lesson_completions') AND name = N'IX_lesson_completions_progress')
    CREATE INDEX IX_lesson_completions_progress ON dbo.lesson_completions (student_id, course_id);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.assignments') AND name = N'IX_assignments_course_deadline')
    CREATE INDEX IX_assignments_course_deadline ON dbo.assignments (course_id, status, due_date);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.submissions') AND name = N'IX_submissions_student')
    CREATE INDEX IX_submissions_student ON dbo.submissions (student_id, course_id, submitted_at);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.quizzes') AND name = N'IX_quizzes_course')
    CREATE INDEX IX_quizzes_course ON dbo.quizzes (course_id, status);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.quiz_attempts') AND name = N'IX_quiz_attempts_student')
    CREATE INDEX IX_quiz_attempts_student ON dbo.quiz_attempts (student_id, course_id, started_at);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.quiz_answer_options') AND name = N'IX_quiz_answer_options_option')
    CREATE INDEX IX_quiz_answer_options_option ON dbo.quiz_answer_options (question_id, option_id);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.study_plans') AND name = N'IX_study_plans_student')
    CREATE INDEX IX_study_plans_student ON dbo.study_plans (student_id, start_date, end_date);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.personal_tasks') AND name = N'IX_personal_tasks_calendar')
    CREATE INDEX IX_personal_tasks_calendar ON dbo.personal_tasks (student_id, planned_start_at, planned_end_at);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.learning_progress') AND name = N'IX_learning_progress_course')
    CREATE INDEX IX_learning_progress_course ON dbo.learning_progress (course_id, percent_complete);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.learning_history') AND name = N'IX_learning_history_student')
    CREATE INDEX IX_learning_history_student ON dbo.learning_history (student_id, course_id, occurred_at);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.course_questions') AND name = N'IX_course_questions_course')
    CREATE INDEX IX_course_questions_course ON dbo.course_questions (course_id, status, created_at);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.course_answers') AND name = N'IX_course_answers_question')
    CREATE INDEX IX_course_answers_question ON dbo.course_answers (question_id, created_at);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.discussions') AND name = N'IX_discussions_course')
    CREATE INDEX IX_discussions_course ON dbo.discussions (course_id, status, created_at);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.discussion_replies') AND name = N'IX_discussion_replies_thread')
    CREATE INDEX IX_discussion_replies_thread ON dbo.discussion_replies (discussion_id, created_at);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.announcements') AND name = N'IX_announcements_course')
    CREATE INDEX IX_announcements_course ON dbo.announcements (course_id, status, sent_at);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.notifications') AND name = N'IX_notifications_unread')
    CREATE INDEX IX_notifications_unread ON dbo.notifications (user_id, read_at, created_at);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.group_members') AND name = N'IX_group_members_user')
    CREATE INDEX IX_group_members_user ON dbo.group_members (user_id, group_id);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.ai_learning_resources') AND name = N'IX_ai_resources_access')
    CREATE INDEX IX_ai_resources_access ON dbo.ai_learning_resources (visibility, course_id, status);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.ai_chat_sessions') AND name = N'IX_ai_sessions_student')
    CREATE INDEX IX_ai_sessions_student ON dbo.ai_chat_sessions (student_id, created_at);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.ai_chat_logs') AND name = N'IX_ai_logs_session')
    CREATE INDEX IX_ai_logs_session ON dbo.ai_chat_logs (session_id, created_at);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.ai_chat_sources') AND name = N'IX_ai_sources_resource')
    CREATE INDEX IX_ai_sources_resource ON dbo.ai_chat_sources (resource_id, chat_id);

-- Seed roles by name rather than assuming fixed identity values.
INSERT INTO dbo.roles (role_name)
SELECT v.role_name FROM (VALUES (N'STUDENT'), (N'INSTRUCTOR'), (N'ADMINISTRATOR')) v(role_name)
WHERE NOT EXISTS (SELECT 1 FROM dbo.roles r WHERE r.role_name = v.role_name);

DROP TABLE #EduSphereExpectedColumns;
DROP TABLE #EduSphereExpectedKeys;
DROP TABLE #EduSphereExpectedFks;
DROP TABLE #EduSphereExpectedChecks;
DROP TABLE #EduSphereExpectedDefaults;

    COMMIT TRANSACTION;
    PRINT N'EduSphere schema ready: 44 application tables; existing data preserved.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO
