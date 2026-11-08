package com.edusphere.config;

import jakarta.annotation.PostConstruct;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.BeansException;
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
        } catch (Exception ex) {
            log.debug("[DbAutoMigration] Bỏ qua bước pre-Hibernate migration: {}", ex.getMessage());
        }
    }

    @Override
    public void run(ApplicationArguments args) {
        try {
            ensureDefaultRoles();
            syncCheckConstraints();
            ensureDefaultCategories();
            log.info("[DbAutoMigration] Tự động migration schema, CHECK constraints và dữ liệu nền hoàn tất.");
        } catch (Exception ex) {
            log.warn("[DbAutoMigration] Bỏ qua đồng bộ SQL Server đặc thù: {}", ex.getMessage());
        }
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

        // 4. CK_learning_history_type: hỗ trợ đầy đủ 9 loại hoạt động học tập
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
                        N'COURSE_ENROLLED', N'COURSE_COMPLETED', N'COURSE_ACCESSED'
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
}
