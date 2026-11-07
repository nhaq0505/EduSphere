-- ============================================================
-- Migration: Bổ sung theo dõi khoảng thời gian xem video và trạng thái mở khóa Quiz
-- Chạy script này trên SQL Server database EduSphere
-- ============================================================

IF COL_LENGTH('dbo.lesson_watch_progress', 'watched_segments') IS NULL
BEGIN
    ALTER TABLE dbo.lesson_watch_progress ADD watched_segments NVARCHAR(MAX) NULL;
    PRINT N'Đã thêm cột watched_segments vào bảng lesson_watch_progress.';
END
ELSE
BEGIN
    PRINT N'Cột watched_segments đã tồn tại.';
END
GO

IF COL_LENGTH('dbo.lesson_watch_progress', 'quiz_unlocked') IS NULL
BEGIN
    ALTER TABLE dbo.lesson_watch_progress ADD quiz_unlocked BIT NOT NULL CONSTRAINT DF_lwp_quiz_unlocked DEFAULT 0;
    PRINT N'Đã thêm cột quiz_unlocked vào bảng lesson_watch_progress.';
END
ELSE
BEGIN
    PRINT N'Cột quiz_unlocked đã tồn tại.';
END
GO

-- Cập nhật quiz_unlocked = 1 cho các bản ghi đã đạt watch_percent >= 80 từ trước
UPDATE dbo.lesson_watch_progress
SET quiz_unlocked = 1
WHERE watch_percent >= 80 AND (quiz_unlocked IS NULL OR quiz_unlocked = 0);
GO

