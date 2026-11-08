-- ==============================================================================
-- DỮ LIỆU MẪU: NGÂN HÀNG CÂU HỎI & CÂU HỎI DEMO
-- Chạy script này sau khi đã chạy migration-quiz-quizbank-video.sql
-- ==============================================================================

USE [EduSphere];
GO

SET NOCOUNT ON;

DECLARE @instructor_id INT;
SELECT TOP 1 @instructor_id = u.user_id 
FROM dbo.users u
JOIN dbo.user_roles ur ON u.user_id = ur.user_id
JOIN dbo.roles r ON ur.role_id = r.role_id
WHERE r.role_name = 'INSTRUCTOR';

IF @instructor_id IS NULL
BEGIN
    SELECT TOP 1 @instructor_id = user_id FROM dbo.users;
END;

IF @instructor_id IS NOT NULL
BEGIN
    -- 1. Tạo ngân hàng câu hỏi mẫu nếu chưa có
    DECLARE @bank_id INT;
    SELECT @bank_id = bank_id FROM dbo.question_banks WHERE name = N'Ngân hàng trắc nghiệm Vật lý đại cương' AND instructor_id = @instructor_id;

    IF @bank_id IS NULL
    BEGIN
        INSERT INTO dbo.question_banks (instructor_id, name, description, status, created_at)
        VALUES (@instructor_id, N'Ngân hàng trắc nghiệm Vật lý đại cương', N'Tổng hợp các câu hỏi trắc nghiệm và tự luận cơ bản dành cho môn Vật lí.', N'ACTIVE', SYSDATETIME());
        SET @bank_id = SCOPE_IDENTITY();
        PRINT N'-> Đã tạo ngân hàng câu hỏi mẫu: ID = ' + CAST(@bank_id AS NVARCHAR(10));
    END;

    -- 2. Tạo danh mục chuyên đề
    DECLARE @cat1_id INT, @cat2_id INT;
    SELECT @cat1_id = category_id FROM dbo.bank_categories WHERE bank_id = @bank_id AND name = N'Chương 1: Mở đầu';
    IF @cat1_id IS NULL
    BEGIN
        INSERT INTO dbo.bank_categories (bank_id, name, description, order_index)
        VALUES (@bank_id, N'Chương 1: Mở đầu', N'Khái niệm, quy tắc an toàn và sai số', 1);
        SET @cat1_id = SCOPE_IDENTITY();
    END;

    SELECT @cat2_id = category_id FROM dbo.bank_categories WHERE bank_id = @bank_id AND name = N'Chương 2: Động học';
    IF @cat2_id IS NULL
    BEGIN
        INSERT INTO dbo.bank_categories (bank_id, name, description, order_index)
        VALUES (@bank_id, N'Chương 2: Động học', N'Vận tốc, gia tốc và độ dịch chuyển', 2);
        SET @cat2_id = SCOPE_IDENTITY();
    END;

    -- 3. Tạo một số câu hỏi mẫu trong ngân hàng
    -- Câu 1 (Single choice)
    IF NOT EXISTS (SELECT 1 FROM dbo.bank_questions WHERE bank_id = @bank_id AND content LIKE N'%quang năng thành điện năng%')
    BEGIN
        DECLARE @bq1 INT;
        INSERT INTO dbo.bank_questions (bank_id, category_id, content, type, difficulty_level, default_score, explanation, created_by)
        VALUES (@bank_id, @cat1_id, N'Thiết bị nào sau đây chuyển đổi quang năng thành điện năng dựa trên hiệu ứng quang điện?', N'SINGLE_CHOICE', N'EASY', 1.0, N'Pin Mặt Trời (pin quang điện) biến đổi trực tiếp quang năng thành điện năng.', @instructor_id);
        SET @bq1 = SCOPE_IDENTITY();

        INSERT INTO dbo.bank_answer_options (bank_question_id, content, is_correct, order_index) VALUES
            (@bq1, N'Động cơ đêzen.', 0, 1),
            (@bq1, N'Pin Mặt Trời.', 1, 2),
            (@bq1, N'Bình ắc quy.', 0, 3),
            (@bq1, N'Máy phát điện gió.', 0, 4);
    END;

    -- Câu 2 (True/False)
    IF NOT EXISTS (SELECT 1 FROM dbo.bank_questions WHERE bank_id = @bank_id AND content LIKE N'%Trong chuyển động thẳng đều%')
    BEGIN
        INSERT INTO dbo.bank_questions (bank_id, category_id, content, type, difficulty_level, default_score, correct_answer, explanation, created_by)
        VALUES (@bank_id, @cat2_id, N'Trong chuyển động thẳng đều, vận tốc tức thời không đổi theo thời gian và luôn bằng vận tốc trung bình.', N'TRUE_FALSE', N'EASY', 1.0, N'TRUE', N'Theo định nghĩa chuyển động thẳng đều có gia tốc bằng 0 nên vận tốc là hằng số.', @instructor_id);
    END;

    -- Câu 3 (Multiple Choice)
    IF NOT EXISTS (SELECT 1 FROM dbo.bank_questions WHERE bank_id = @bank_id AND content LIKE N'%Đại lượng nào sau đây là đại lượng vectơ%')
    BEGIN
        DECLARE @bq3 INT;
        INSERT INTO dbo.bank_questions (bank_id, category_id, content, type, difficulty_level, default_score, explanation, created_by)
        VALUES (@bank_id, @cat2_id, N'Những đại lượng nào sau đây là đại lượng vectơ? (Chọn tất cả đáp án đúng)', N'MULTIPLE_CHOICE', N'MEDIUM', 2.0, N'Độ dịch chuyển, vận tốc và gia tốc đều là các đại lượng vectơ.', @instructor_id);
        SET @bq3 = SCOPE_IDENTITY();

        INSERT INTO dbo.bank_answer_options (bank_question_id, content, is_correct, order_index) VALUES
            (@bq3, N'Độ dịch chuyển', 1, 1),
            (@bq3, N'Vận tốc', 1, 2),
            (@bq3, N'Quãng đường đi được', 0, 3),
            (@bq3, N'Gia tốc', 1, 4);
    END;

    -- Câu 4 (Short answer)
    IF NOT EXISTS (SELECT 1 FROM dbo.bank_questions WHERE bank_id = @bank_id AND content LIKE N'%Đơn vị chuẩn của gia tốc trong hệ SI%')
    BEGIN
        INSERT INTO dbo.bank_questions (bank_id, category_id, content, type, difficulty_level, default_score, correct_answer, explanation, created_by)
        VALUES (@bank_id, @cat2_id, N'Đơn vị chuẩn của gia tốc trong hệ SI là gì? (Viết tắt dạng m/s2 hoặc m/s^2)', N'SHORT_ANSWER', N'EASY', 1.0, N'm/s2', N'Đơn vị đo gia tốc là mét trên giây bình phương (m/s²).', @instructor_id);
    END;

    PRINT N'-> Đã nạp thành công các câu hỏi mẫu vào Ngân hàng câu hỏi!';
END
ELSE
BEGIN
    PRINT N'-> Không tìm thấy tài khoản người dùng nào để gán ngân hàng câu hỏi.';
END;
GO
