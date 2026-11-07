-- Migration: Update foreign keys to ON DELETE SET NULL for questions and quizzes
-- Run in EduSphere database

IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_questions_bank_question')
BEGIN
    ALTER TABLE dbo.questions DROP CONSTRAINT FK_questions_bank_question;
    PRINT 'Dropped FK_questions_bank_question';
END;

ALTER TABLE dbo.questions ADD CONSTRAINT FK_questions_bank_question 
    FOREIGN KEY (bank_question_id) REFERENCES dbo.bank_questions(bank_question_id) ON DELETE SET NULL;
PRINT 'Recreated FK_questions_bank_question with ON DELETE SET NULL';

IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_quizzes_bank')
BEGIN
    ALTER TABLE dbo.quizzes DROP CONSTRAINT FK_quizzes_bank;
    PRINT 'Dropped FK_quizzes_bank';
END;

ALTER TABLE dbo.quizzes ADD CONSTRAINT FK_quizzes_bank 
    FOREIGN KEY (bank_id) REFERENCES dbo.question_banks(bank_id) ON DELETE SET NULL;
PRINT 'Recreated FK_quizzes_bank with ON DELETE SET NULL';

