-- Migration: Add UPDATING status to courses table
-- Purpose: Allow instructors to update course content while students continue learning
-- Date: 2026-11-01

-- Drop existing status constraint and recreate with UPDATING added
IF EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_courses_status' AND parent_object_id = OBJECT_ID('dbo.courses'))
BEGIN
    ALTER TABLE dbo.courses DROP CONSTRAINT CK_courses_status;
END;

ALTER TABLE dbo.courses ADD CONSTRAINT CK_courses_status
    CHECK (status IN (N'DRAFT', N'SUBMITTED', N'APPROVED', N'REJECTED', N'PUBLISHED', N'ARCHIVED', N'UPDATING'));
