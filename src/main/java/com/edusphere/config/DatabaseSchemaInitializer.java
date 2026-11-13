package com.edusphere.config;

import jakarta.annotation.PostConstruct;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.config.BeanDefinition;
import org.springframework.beans.factory.config.BeanFactoryPostProcessor;
import org.springframework.beans.factory.config.ConfigurableListableBeanFactory;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.annotation.Order;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;

/**
 * Tự động migration schema, các cột NOT NULL có DEFAULT, CHECK constraints
 * và dữ liệu nền (roles, categories) mỗi khi ứng dụng khởi động cùng Hibernate ddl-auto=update.
 *
 * Hoạt động theo 2 pha:
 * - Pha 1 (@PostConstruct - chạy trước EntityManagerFactory): Bổ sung an toàn các cột NOT NULL kèm DEFAULT
 *   trên các bảng đã có dữ liệu từ phiên bản cũ để Hibernate ddl-auto=update không bị lỗi.
 * - Pha 2 (ApplicationRunner @Order(1) - chạy ngay sau khi Hibernate tạo/cập nhật bảng và trước AdminDataInitializer):
 *   Đồng bộ các CHECK constraints và seed dữ liệu nền (roles, categories) kể cả trên DB mới hoàn toàn.
 */
@Component
@Order(1)
public class DatabaseSchemaInitializer implements ApplicationRunner {

    private static final Logger log = LoggerFactory.getLogger(DatabaseSchemaInitializer.class);

    private final JdbcTemplate jdbcTemplate;

    public DatabaseSchemaInitializer(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @Configuration
    static class JpaDependencyConfig {
        @Bean
        static BeanFactoryPostProcessor entityManagerFactoryDependsOnSchemaInitializer() {
            return (ConfigurableListableBeanFactory beanFactory) -> {
                if (beanFactory.containsBeanDefinition("entityManagerFactory")) {
                    BeanDefinition bd = beanFactory.getBeanDefinition("entityManagerFactory");
                    bd.setDependsOn("databaseSchemaInitializer");
                }
            };
        }
    }

    @PostConstruct
    public void migrateLegacyColumnsBeforeHibernate() {
        try {
            // Đảm bảo các cột NOT NULL mới trên bảng đã có dữ liệu có sẵn DEFAULT trước khi Hibernate update
            jdbcTemplate.execute("""
                IF OBJECT_ID(N'dbo.lessons', N'U') IS NOT NULL
                BEGIN
                    IF COL_LENGTH('dbo.lessons', 'lesson_type') IS NULL
                        ALTER TABLE dbo.lessons ADD lesson_type NVARCHAR(20) NOT NULL CONSTRAINT DF_lessons_type DEFAULT N'ARTICLE';
                    IF COL_LENGTH('dbo.lessons', 'allow_seek') IS NULL
                        ALTER TABLE dbo.lessons ADD allow_seek BIT NOT NULL CONSTRAINT DF_lessons_seek DEFAULT 1;
                    IF COL_LENGTH('dbo.lessons', 'is_preview') IS NULL
                        ALTER TABLE dbo.lessons ADD is_preview BIT NOT NULL CONSTRAINT DF_lessons_preview DEFAULT 0;
                    IF COL_LENGTH('dbo.lessons', 'bunny_video_id') IS NULL
                        ALTER TABLE dbo.lessons ADD bunny_video_id NVARCHAR(100) NULL;
                    IF COL_LENGTH('dbo.lessons', 'video_status') IS NULL
                        ALTER TABLE dbo.lessons ADD video_status NVARCHAR(20) NULL;
                    IF COL_LENGTH('dbo.lessons', 'quiz_requires_video') IS NULL
                        ALTER TABLE dbo.lessons ADD quiz_requires_video BIT NOT NULL CONSTRAINT DF_lessons_quiz_requires_video DEFAULT 0;
                    IF COL_LENGTH('dbo.lessons', 'min_watch_percent') IS NULL
                        ALTER TABLE dbo.lessons ADD min_watch_percent INT NOT NULL CONSTRAINT DF_lessons_min_watch_percent DEFAULT 0;
                END
                """);

            jdbcTemplate.execute("""
                IF OBJECT_ID(N'dbo.lesson_watch_progress', N'U') IS NOT NULL
                BEGIN
                    IF COL_LENGTH('dbo.lesson_watch_progress', 'watched_segments') IS NULL
                        ALTER TABLE dbo.lesson_watch_progress ADD watched_segments NVARCHAR(MAX) NULL;
                    IF COL_LENGTH('dbo.lesson_watch_progress', 'quiz_unlocked') IS NULL
                        ALTER TABLE dbo.lesson_watch_progress ADD quiz_unlocked BIT NOT NULL CONSTRAINT DF_lwp_quiz_unlocked DEFAULT 0;
                END
                """);

            jdbcTemplate.execute("""
                IF OBJECT_ID(N'dbo.quizzes', N'U') IS NOT NULL
                BEGIN
                    IF COL_LENGTH('dbo.quizzes', 'shuffle_questions') IS NULL
                        ALTER TABLE dbo.quizzes ADD shuffle_questions BIT NOT NULL CONSTRAINT DF_quizzes_shuffle_q DEFAULT 0;
                    IF COL_LENGTH('dbo.quizzes', 'shuffle_options') IS NULL
                        ALTER TABLE dbo.quizzes ADD shuffle_options BIT NOT NULL CONSTRAINT DF_quizzes_shuffle_o DEFAULT 0;
                    IF COL_LENGTH('dbo.quizzes', 'bank_id') IS NULL
                        ALTER TABLE dbo.quizzes ADD bank_id INT NULL;
                END
                """);

            jdbcTemplate.execute("""
                IF OBJECT_ID(N'dbo.questions', N'U') IS NOT NULL
                BEGIN
                    IF COL_LENGTH('dbo.questions', 'image_url') IS NULL
                        ALTER TABLE dbo.questions ADD image_url NVARCHAR(500) NULL;
                    IF COL_LENGTH('dbo.questions', 'video_url') IS NULL
                        ALTER TABLE dbo.questions ADD video_url NVARCHAR(500) NULL;
                    IF COL_LENGTH('dbo.questions', 'bank_question_id') IS NULL
                        ALTER TABLE dbo.questions ADD bank_question_id INT NULL;
                    IF COL_LENGTH('dbo.questions', 'sample_essay_answer') IS NULL
                        ALTER TABLE dbo.questions ADD sample_essay_answer NVARCHAR(MAX) NULL;
                END
                """);

            jdbcTemplate.execute("""
                IF OBJECT_ID(N'dbo.courses', N'U') IS NOT NULL
                BEGIN
                    IF COL_LENGTH('dbo.courses', 'credits') IS NULL
                        ALTER TABLE dbo.courses ADD credits INT NOT NULL CONSTRAINT DF_courses_credits DEFAULT 3;
                END
                """);

            jdbcTemplate.execute("""
                IF OBJECT_ID(N'dbo.certificates', N'U') IS NOT NULL
                BEGIN
                    IF COL_LENGTH('dbo.certificates', 'credits_earned') IS NULL
                        ALTER TABLE dbo.certificates ADD credits_earned INT NULL CONSTRAINT DF_certificates_credits DEFAULT 3;
                    IF COL_LENGTH('dbo.certificates', 'grade_percent') IS NULL
                        ALTER TABLE dbo.certificates ADD grade_percent DECIMAL(5,2) NULL CONSTRAINT DF_certificates_grade DEFAULT 100.00;
                    IF COL_LENGTH('dbo.certificates', 'total_hours') IS NULL
                        ALTER TABLE dbo.certificates ADD total_hours INT NULL CONSTRAINT DF_certificates_hours DEFAULT 18;
                END
                """);

            // Tự động tạo hoặc nâng cấp bảng lesson_ai_materials (Tài liệu học tập AI)
            jdbcTemplate.execute("""
                IF OBJECT_ID(N'dbo.lesson_ai_materials', N'U') IS NULL
                BEGIN
                    CREATE TABLE dbo.lesson_ai_materials (
                        id INT IDENTITY(1,1) PRIMARY KEY,
                        lesson_id INT NOT NULL,
                        task_id NVARCHAR(100) NULL,
                        status NVARCHAR(30) NOT NULL CONSTRAINT DF_lam_status DEFAULT N'PENDING',
                        original_transcript NVARCHAR(MAX) NULL,
                        corrected_transcript NVARCHAR(MAX) NULL,
                        summary NVARCHAR(MAX) NULL,
                        key_points NVARCHAR(MAX) NULL,
                        terms NVARCHAR(MAX) NULL,
                        conclusion NVARCHAR(MAX) NULL,
                        ai_model NVARCHAR(100) NULL,
                        error_message NVARCHAR(1000) NULL,
                        created_at DATETIME2 NOT NULL CONSTRAINT DF_lam_created DEFAULT SYSDATETIME(),
                        updated_at DATETIME2 NULL,
                        CONSTRAINT UQ_lesson_ai_materials_lesson UNIQUE (lesson_id),
                        CONSTRAINT FK_lesson_ai_materials_lesson FOREIGN KEY (lesson_id) REFERENCES dbo.lessons(lesson_id) ON DELETE CASCADE
                    );
                END
                ELSE
                BEGIN
                    IF COL_LENGTH('dbo.lesson_ai_materials', 'task_id') IS NULL
                        ALTER TABLE dbo.lesson_ai_materials ADD task_id NVARCHAR(100) NULL;
                    IF COL_LENGTH('dbo.lesson_ai_materials', 'error_message') IS NULL
                        ALTER TABLE dbo.lesson_ai_materials ADD error_message NVARCHAR(1000) NULL;
                END
                """);
        } catch (Exception ex) {
            log.debug("[DbAutoMigration] Bỏ qua bước pre-Hibernate migration: {}", ex.getMessage());
        }
    }

    @Override
    public void run(ApplicationArguments args) {
        try {
            ensureDefaultRoles();
            ensureUnicodeColumns();
            syncCheckConstraints();
            syncTrueFalseAnswers();
            ensureDefaultCategories();
            ensureStudentStudyLogsTable();
            ensureCourseChangeLogsTable();
            log.info("[DbAutoMigration] Tự động migration schema, CHECK constraints và dữ liệu nền hoàn tất.");
        } catch (Exception ex) {
            log.warn("[DbAutoMigration] Bỏ qua đồng bộ SQL Server đặc thù: {}", ex.getMessage());
        }
    }

    /**
     * Chuyển đổi các cột văn bản từng bị tạo nhầm thành VARCHAR sang NVARCHAR (Unicode)
     * và khôi phục các bản ghi tiếng Việt bị lỗi dấu '?' trong bảng payout_requests.
     */
    private void ensureUnicodeColumns() {
        // 1. Bảng payout_requests
        jdbcTemplate.execute("""
            IF OBJECT_ID(N'dbo.payout_requests', N'U') IS NOT NULL
            BEGIN
                IF EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = N'CK_payout_requests_status' AND parent_object_id = OBJECT_ID(N'dbo.payout_requests'))
                    ALTER TABLE dbo.payout_requests DROP CONSTRAINT CK_payout_requests_status;

                ALTER TABLE dbo.payout_requests ALTER COLUMN bank_name NVARCHAR(100) NOT NULL;
                ALTER TABLE dbo.payout_requests ALTER COLUMN account_number NVARCHAR(50) NOT NULL;
                ALTER TABLE dbo.payout_requests ALTER COLUMN account_holder NVARCHAR(150) NOT NULL;
                ALTER TABLE dbo.payout_requests ALTER COLUMN instructor_note NVARCHAR(500) NULL;
                ALTER TABLE dbo.payout_requests ALTER COLUMN admin_note NVARCHAR(500) NULL;
                ALTER TABLE dbo.payout_requests ALTER COLUMN status NVARCHAR(20) NOT NULL;

                UPDATE dbo.payout_requests
                SET bank_name = N'MB Bank (Quân Đội)'
                WHERE bank_name LIKE N'%MB Bank%Quân%i%';

                UPDATE dbo.payout_requests
                SET admin_note = N'Thử lại sau'
                WHERE admin_note = N'Th? l?i sau';
            END
            """);

        // 2. Bảng question_banks, bank_categories, bank_questions
        jdbcTemplate.execute("""
            IF OBJECT_ID(N'dbo.question_banks', N'U') IS NOT NULL
            BEGIN
                ALTER TABLE dbo.question_banks ALTER COLUMN name NVARCHAR(255) NOT NULL;
                ALTER TABLE dbo.question_banks ALTER COLUMN status NVARCHAR(20) NOT NULL;
            END

            IF OBJECT_ID(N'dbo.bank_categories', N'U') IS NOT NULL
            BEGIN
                ALTER TABLE dbo.bank_categories ALTER COLUMN name NVARCHAR(255) NOT NULL;
                ALTER TABLE dbo.bank_categories ALTER COLUMN description NVARCHAR(500) NULL;
            END

            IF OBJECT_ID(N'dbo.bank_questions', N'U') IS NOT NULL
            BEGIN
                ALTER TABLE dbo.bank_questions ALTER COLUMN image_url NVARCHAR(500) NULL;
                ALTER TABLE dbo.bank_questions ALTER COLUMN video_url NVARCHAR(500) NULL;
                ALTER TABLE dbo.bank_questions ALTER COLUMN type NVARCHAR(30) NOT NULL;
                ALTER TABLE dbo.bank_questions ALTER COLUMN difficulty_level NVARCHAR(20) NOT NULL;
                ALTER TABLE dbo.bank_questions ALTER COLUMN tags NVARCHAR(500) NULL;
            END
            """);
    }

    private void ensureDefaultRoles() {
        jdbcTemplate.execute("""
            IF OBJECT_ID(N'dbo.roles', N'U') IS NOT NULL
            BEGIN
                IF NOT EXISTS (SELECT 1 FROM dbo.roles WHERE role_name = N'STUDENT')
                    INSERT INTO dbo.roles (role_name) VALUES (N'STUDENT');
                IF NOT EXISTS (SELECT 1 FROM dbo.roles WHERE role_name = N'INSTRUCTOR')
                    INSERT INTO dbo.roles (role_name) VALUES (N'INSTRUCTOR');
                IF NOT EXISTS (SELECT 1 FROM dbo.roles WHERE role_name = N'ADMINISTRATOR')
                    INSERT INTO dbo.roles (role_name) VALUES (N'ADMINISTRATOR');
            END
            """);
    }

    private void syncCheckConstraints() {
        // 1. CK_courses_status: hỗ trợ đầy đủ cả UPDATING
        jdbcTemplate.execute("""
            IF OBJECT_ID(N'dbo.courses', N'U') IS NOT NULL
            BEGIN
                IF EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = N'CK_courses_status' AND parent_object_id = OBJECT_ID(N'dbo.courses'))
                    ALTER TABLE dbo.courses DROP CONSTRAINT CK_courses_status;
                ALTER TABLE dbo.courses WITH CHECK ADD CONSTRAINT CK_courses_status
                    CHECK (status IN (N'DRAFT', N'SUBMITTED', N'APPROVED', N'REJECTED', N'PUBLISHED', N'ARCHIVED', N'UPDATING'));
            END
            """);

        // 2. CK_study_plans_status: hỗ trợ ACTIVE, COMPLETED, CANCELLED, ARCHIVED
        jdbcTemplate.execute("""
            IF OBJECT_ID(N'dbo.study_plans', N'U') IS NOT NULL
            BEGIN
                IF EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = N'CK_study_plans_status' AND parent_object_id = OBJECT_ID(N'dbo.study_plans'))
                    ALTER TABLE dbo.study_plans DROP CONSTRAINT CK_study_plans_status;
                ALTER TABLE dbo.study_plans WITH CHECK ADD CONSTRAINT CK_study_plans_status
                    CHECK (status IN (N'ACTIVE', N'COMPLETED', N'CANCELLED', N'ARCHIVED'));
            END
            """);

        // 3. CK_personal_tasks_status: hỗ trợ TODO, PENDING, IN_PROGRESS, DONE, SKIPPED, CANCELLED
        jdbcTemplate.execute("""
            IF OBJECT_ID(N'dbo.personal_tasks', N'U') IS NOT NULL
            BEGIN
                IF EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = N'CK_personal_tasks_status' AND parent_object_id = OBJECT_ID(N'dbo.personal_tasks'))
                    ALTER TABLE dbo.personal_tasks DROP CONSTRAINT CK_personal_tasks_status;
                ALTER TABLE dbo.personal_tasks WITH CHECK ADD CONSTRAINT CK_personal_tasks_status
                    CHECK (status IN (N'TODO', N'PENDING', N'IN_PROGRESS', N'DONE', N'SKIPPED', N'CANCELLED'));
            END
            """);

        // 4. CK_learning_history_type: hỗ trợ đầy đủ các loại hoạt động học tập & nhận chứng chỉ
        jdbcTemplate.execute("""
            IF OBJECT_ID(N'dbo.learning_history', N'U') IS NOT NULL
            BEGIN
                IF EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = N'CK_learning_history_type' AND parent_object_id = OBJECT_ID(N'dbo.learning_history'))
                    ALTER TABLE dbo.learning_history DROP CONSTRAINT CK_learning_history_type;
                ALTER TABLE dbo.learning_history WITH CHECK ADD CONSTRAINT CK_learning_history_type
                    CHECK (activity_type IN (
                        N'LESSON', N'LESSON_COMPLETED',
                        N'ASSIGNMENT', N'ASSIGNMENT_SUBMITTED',
                        N'QUIZ', N'QUIZ_SUBMITTED',
                        N'COURSE_ENROLLED', N'COURSE_COMPLETED', N'COURSE_ACCESSED',
                        N'CERTIFICATE_EARNED'
                    ));
            END
            """);

        // 5. FK_questions_bank_question & FK_quizzes_bank: đảm bảo ON DELETE SET NULL an toàn
        jdbcTemplate.execute("""
            IF OBJECT_ID(N'dbo.questions', N'U') IS NOT NULL AND OBJECT_ID(N'dbo.bank_questions', N'U') IS NOT NULL
            BEGIN
                IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_questions_bank_question')
                    ALTER TABLE dbo.questions DROP CONSTRAINT FK_questions_bank_question;
                ALTER TABLE dbo.questions ADD CONSTRAINT FK_questions_bank_question
                    FOREIGN KEY (bank_question_id) REFERENCES dbo.bank_questions(bank_question_id) ON DELETE SET NULL;
            END
            """);

        jdbcTemplate.execute("""
            IF OBJECT_ID(N'dbo.quizzes', N'U') IS NOT NULL AND OBJECT_ID(N'dbo.question_banks', N'U') IS NOT NULL
            BEGIN
                IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = N'FK_quizzes_bank')
                    ALTER TABLE dbo.quizzes DROP CONSTRAINT FK_quizzes_bank;
                ALTER TABLE dbo.quizzes ADD CONSTRAINT FK_quizzes_bank
                    FOREIGN KEY (bank_id) REFERENCES dbo.question_banks(bank_id) ON DELETE SET NULL;
            END
            """);

        // 6. CK_payout_requests_status & CK_payout_requests_amount
        jdbcTemplate.execute("""
            IF OBJECT_ID(N'dbo.payout_requests', N'U') IS NOT NULL
            BEGIN
                IF EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = N'CK_payout_requests_status' AND parent_object_id = OBJECT_ID(N'dbo.payout_requests'))
                    ALTER TABLE dbo.payout_requests DROP CONSTRAINT CK_payout_requests_status;
                ALTER TABLE dbo.payout_requests WITH CHECK ADD CONSTRAINT CK_payout_requests_status
                    CHECK (status IN (N'PENDING', N'APPROVED', N'REJECTED'));

                IF EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = N'CK_payout_requests_amount' AND parent_object_id = OBJECT_ID(N'dbo.payout_requests'))
                    ALTER TABLE dbo.payout_requests DROP CONSTRAINT CK_payout_requests_amount;
                ALTER TABLE dbo.payout_requests WITH CHECK ADD CONSTRAINT CK_payout_requests_amount
                    CHECK (amount > 0);
            END
            """);

        // 7. CK_lesson_ai_materials_status: hỗ trợ PENDING, PROCESSING, COMPLETED, FAILED
        jdbcTemplate.execute("""
            IF OBJECT_ID(N'dbo.lesson_ai_materials', N'U') IS NOT NULL
            BEGIN
                IF EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = N'CK_lesson_ai_materials_status' AND parent_object_id = OBJECT_ID(N'dbo.lesson_ai_materials'))
                    ALTER TABLE dbo.lesson_ai_materials DROP CONSTRAINT CK_lesson_ai_materials_status;
                ALTER TABLE dbo.lesson_ai_materials WITH CHECK ADD CONSTRAINT CK_lesson_ai_materials_status
                    CHECK (status IN (N'PENDING', N'PROCESSING', N'COMPLETED', N'FAILED'));
            END
            """);
    }

    private void syncTrueFalseAnswers() {
        jdbcTemplate.execute("""
            IF OBJECT_ID(N'dbo.bank_questions', N'U') IS NOT NULL AND OBJECT_ID(N'dbo.bank_answer_options', N'U') IS NOT NULL
            BEGIN
                -- 1. Nếu bank_questions có correct_answer IS NULL nhưng có option is_correct = 1
                UPDATE bq
                SET bq.correct_answer = CASE
                    WHEN UPPER(bao.content) LIKE N'%ĐÚNG%' OR UPPER(bao.content) LIKE N'%TRUE%' OR bao.order_index = 1 THEN N'TRUE'
                    ELSE N'FALSE'
                END
                FROM dbo.bank_questions bq
                JOIN dbo.bank_answer_options bao ON bq.bank_question_id = bao.bank_question_id
                WHERE bq.type = N'TRUE_FALSE' AND (bq.correct_answer IS NULL OR bq.correct_answer = N'') AND bao.is_correct = 1;

                -- 2. Chuẩn hóa 'Đúng'/'Sai' sang 'TRUE'/'FALSE' trong bank_questions
                UPDATE dbo.bank_questions
                SET correct_answer = N'TRUE'
                WHERE type = N'TRUE_FALSE' AND (UPPER(correct_answer) = N'ĐÚNG' OR UPPER(correct_answer) = N'TRUE');

                UPDATE dbo.bank_questions
                SET correct_answer = N'FALSE'
                WHERE type = N'TRUE_FALSE' AND (UPPER(correct_answer) = N'SAI' OR UPPER(correct_answer) = N'FALSE');
            END
            """);

        jdbcTemplate.execute("""
            IF OBJECT_ID(N'dbo.questions', N'U') IS NOT NULL
            BEGIN
                -- 3. Đồng bộ correct_answer từ bank_questions sang questions nếu câu hỏi quiz đang bị null
                IF OBJECT_ID(N'dbo.bank_questions', N'U') IS NOT NULL
                BEGIN
                    UPDATE q
                    SET q.correct_answer = bq.correct_answer
                    FROM dbo.questions q
                    JOIN dbo.bank_questions bq ON q.bank_question_id = bq.bank_question_id
                    WHERE q.type = N'TRUE_FALSE' AND (q.correct_answer IS NULL OR q.correct_answer = N'') AND bq.correct_answer IS NOT NULL;
                END

                -- 4. Chuẩn hóa 'Đúng'/'Sai' sang 'TRUE'/'FALSE' trong questions
                UPDATE dbo.questions
                SET correct_answer = N'TRUE'
                WHERE type = N'TRUE_FALSE' AND (UPPER(correct_answer) = N'ĐÚNG' OR UPPER(correct_answer) = N'TRUE');

                UPDATE dbo.questions
                SET correct_answer = N'FALSE'
                WHERE type = N'TRUE_FALSE' AND (UPPER(correct_answer) = N'SAI' OR UPPER(correct_answer) = N'FALSE');
            END
            """);
    }

    private void ensureDefaultCategories() {
        jdbcTemplate.execute("""
            IF OBJECT_ID(N'dbo.categories', N'U') IS NOT NULL
            BEGIN
                IF NOT EXISTS (SELECT 1 FROM dbo.categories)
                BEGIN
                    INSERT INTO dbo.categories (name, description, status) VALUES
                        (N'Lập trình Web', N'Các khóa học phát triển ứng dụng Web Frontend & Backend', N'ACTIVE'),
                        (N'Khoa học Dữ liệu & AI', N'Phân tích dữ liệu, Machine Learning và Trí tuệ nhân tạo', N'ACTIVE'),
                        (N'Lập trình Di động', N'Phát triển ứng dụng iOS, Android và Đa nền tảng', N'ACTIVE'),
                        (N'Cơ sở dữ liệu & Hệ thống', N'SQL Server, DevOps, Cloud và Kiến trúc phần mềm', N'ACTIVE');
                END
            END
            """);
    }

    /**
     * Tự động tạo bảng student_study_logs (nếu chưa có) để lưu số giờ học của học viên,
     * đồng thời đồng bộ dữ liệu xem video sẵn có từ lesson_watch_progress khi bảng mới được tạo.
     */
    private void ensureStudentStudyLogsTable() {
        jdbcTemplate.execute("""
            IF OBJECT_ID(N'dbo.student_study_logs', N'U') IS NULL
            BEGIN
                CREATE TABLE dbo.student_study_logs (
                    log_id BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
                    student_id INT NOT NULL,
                    course_id INT NOT NULL,
                    study_date DATE NOT NULL,
                    duration_seconds INT NOT NULL CONSTRAINT DF_student_study_logs_duration DEFAULT 0,
                    updated_at DATETIME2 NOT NULL CONSTRAINT DF_student_study_logs_updated DEFAULT SYSDATETIME(),
                    CONSTRAINT UQ_student_study_logs_student_course_date UNIQUE (student_id, course_id, study_date),
                    CONSTRAINT FK_student_study_logs_student FOREIGN KEY (student_id) REFERENCES dbo.users(user_id),
                    CONSTRAINT FK_student_study_logs_course FOREIGN KEY (course_id) REFERENCES dbo.courses(course_id)
                );
            END
            """);

        jdbcTemplate.execute("""
            IF OBJECT_ID(N'dbo.student_study_logs', N'U') IS NOT NULL
               AND OBJECT_ID(N'dbo.lesson_watch_progress', N'U') IS NOT NULL
               AND OBJECT_ID(N'dbo.lessons', N'U') IS NOT NULL
            BEGIN
                IF NOT EXISTS (SELECT 1 FROM dbo.student_study_logs)
                BEGIN
                    INSERT INTO dbo.student_study_logs (student_id, course_id, study_date, duration_seconds, updated_at)
                    SELECT
                        lwp.student_id,
                        lwp.course_id,
                        CAST(lwp.updated_at AS DATE) AS study_date,
                        SUM(
                            CASE
                                WHEN ISNULL(l.video_duration, 0) > 0 THEN
                                    CAST((CASE WHEN l.video_duration > 60 THEN l.video_duration ELSE l.video_duration * 60 END) * ISNULL(lwp.watch_percent, 0) / 100.0 AS INT)
                                ELSE ISNULL(lwp.last_position, 0)
                            END
                        ) AS duration_seconds,
                        MAX(lwp.updated_at) AS updated_at
                    FROM dbo.lesson_watch_progress lwp
                    JOIN dbo.lessons l ON lwp.lesson_id = l.lesson_id
                    WHERE ISNULL(lwp.watch_percent, 0) > 0 OR ISNULL(lwp.last_position, 0) > 0
                    GROUP BY lwp.student_id, lwp.course_id, CAST(lwp.updated_at AS DATE)
                    HAVING SUM(
                        CASE
                            WHEN ISNULL(l.video_duration, 0) > 0 THEN
                                CAST((CASE WHEN l.video_duration > 60 THEN l.video_duration ELSE l.video_duration * 60 END) * ISNULL(lwp.watch_percent, 0) / 100.0 AS INT)
                            ELSE ISNULL(lwp.last_position, 0)
                        END
                    ) > 0;
                END
            END
            """);
    }

    /**
     * Tự động tạo bảng course_change_logs (nếu chưa có) để lưu toàn bộ lịch sử thay đổi khóa học cho Admin.
     */
    private void ensureCourseChangeLogsTable() {
        jdbcTemplate.execute("""
            IF OBJECT_ID(N'dbo.course_change_logs', N'U') IS NULL
            BEGIN
                CREATE TABLE dbo.course_change_logs (
                    log_id BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
                    course_id INT NOT NULL,
                    course_title NVARCHAR(255) NULL,
                    actor_id INT NOT NULL,
                    actor_name NVARCHAR(255) NULL,
                    actor_email NVARCHAR(255) NULL,
                    actor_role NVARCHAR(30) NULL CONSTRAINT DF_ccl_actor_role DEFAULT N'INSTRUCTOR',
                    entity_type NVARCHAR(40) NOT NULL,
                    entity_id INT NULL,
                    entity_title NVARCHAR(500) NULL,
                    parent_lesson_id INT NULL,
                    action_type NVARCHAR(40) NOT NULL,
                    summary NVARCHAR(1000) NOT NULL,
                    changed_fields NVARCHAR(500) NULL,
                    before_data NVARCHAR(MAX) NULL,
                    after_data NVARCHAR(MAX) NULL,
                    created_at DATETIME2 NOT NULL CONSTRAINT DF_ccl_created_at DEFAULT SYSDATETIME()
                );

                CREATE INDEX IX_course_change_logs_course_id ON dbo.course_change_logs(course_id, created_at DESC);
                CREATE INDEX IX_course_change_logs_actor_id ON dbo.course_change_logs(actor_id, created_at DESC);
                CREATE INDEX IX_course_change_logs_created_at ON dbo.course_change_logs(created_at DESC);
            END
            """);
    }
}
