-- Migration: Kiro Improvements (courses-and-exercises branch)
-- Run this script on your SQL Server EduSphere database before starting the app
-- Date: 2026-11-01
-- Safe to run multiple times (idempotent)

USE [EduSphere];
GO

-- 1. Add UPDATING status to courses table
IF EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_courses_status' AND parent_object_id = OBJECT_ID('dbo.courses'))
    ALTER TABLE dbo.courses DROP CONSTRAINT CK_courses_status;
ALTER TABLE dbo.courses ADD CONSTRAINT CK_courses_status
    CHECK (status IN (N'DRAFT', N'SUBMITTED', N'APPROVED', N'REJECTED', N'PUBLISHED', N'ARCHIVED', N'UPDATING'));
GO

-- 2. Add change_note column to courses
IF COL_LENGTH('dbo.courses', 'change_note') IS NULL
    ALTER TABLE dbo.courses ADD change_note NVARCHAR(2000) NULL;
GO

-- 3. Add quiz settings columns
IF COL_LENGTH('dbo.quizzes', 'passing_score') IS NULL
    ALTER TABLE dbo.quizzes ADD passing_score DECIMAL(5,2) NULL;
IF COL_LENGTH('dbo.quizzes', 'shuffle_questions') IS NULL
    ALTER TABLE dbo.quizzes ADD shuffle_questions BIT NOT NULL DEFAULT 0;
IF COL_LENGTH('dbo.quizzes', 'shuffle_options') IS NULL
    ALTER TABLE dbo.quizzes ADD shuffle_options BIT NOT NULL DEFAULT 0;
GO

-- 4. Fix CK_learning_history_type constraint
IF EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_learning_history_type' AND parent_object_id = OBJECT_ID('dbo.learning_history'))
    ALTER TABLE dbo.learning_history DROP CONSTRAINT CK_learning_history_type;
ALTER TABLE dbo.learning_history ADD CONSTRAINT CK_learning_history_type CHECK (
    activity_type IN (N'LESSON', N'LESSON_COMPLETED', N'ASSIGNMENT', N'ASSIGNMENT_SUBMITTED',
                      N'QUIZ', N'QUIZ_SUBMITTED', N'COURSE_ENROLLED', N'COURSE_COMPLETED', N'COURSE_ACCESSED')
);
GO

PRINT '=== Migration completed successfully ===';
