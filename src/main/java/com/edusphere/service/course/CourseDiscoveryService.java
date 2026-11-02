package com.edusphere.service.course;

import com.edusphere.dto.course.CourseView;
import com.edusphere.entity.course.Category;
import com.edusphere.entity.course.Course;
import com.edusphere.repository.course.CategoryRepository;
import com.edusphere.repository.course.CourseRepository;
import com.edusphere.repository.course.LessonRepository;

import jakarta.persistence.criteria.Predicate;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.Optional;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class CourseDiscoveryService {

    private static final String PUBLISHED = "PUBLISHED";
    private static final int PAGE_SIZE = 12;

    private final CourseRepository courseRepository;
    private final CategoryRepository categoryRepository;
    private final LessonRepository lessonRepository;

    public CourseDiscoveryService(CourseRepository courseRepository, CategoryRepository categoryRepository,
                                  LessonRepository lessonRepository) {
        this.courseRepository = courseRepository;
        this.categoryRepository = categoryRepository;
        this.lessonRepository = lessonRepository;
    }

    @Transactional(readOnly = true)
    public Page<CourseView> search(String keyword, Integer categoryId, String level,
                                   String priceFilter, int page) {
        String text = keyword == null ? "" : keyword.trim();
        String selectedLevel = level == null ? "" : level.trim().toUpperCase(Locale.ROOT);
        String selectedPrice = priceFilter == null ? "" : priceFilter.trim().toUpperCase(Locale.ROOT);

        Specification<Course> filters = (root, query, criteria) -> {
            List<Predicate> conditions = new ArrayList<>();
            Predicate isPublishedOrUpdating = root.get("status").in(PUBLISHED, "UPDATING");
            Predicate isSubmittedWithPriorPublish = criteria.and(
                    criteria.equal(root.get("status"), "SUBMITTED"),
                    criteria.isNotNull(root.get("publishedAt"))
            );
            conditions.add(criteria.or(isPublishedOrUpdating, isSubmittedWithPriorPublish));
            if (!text.isEmpty()) {
                String escaped = text.toLowerCase(Locale.ROOT)
                        .replace("\\", "\\\\").replace("%", "\\%").replace("_", "\\_");
                conditions.add(criteria.like(criteria.lower(root.get("title")), "%" + escaped + "%", '\\'));
            }
            if (categoryId != null) {
                conditions.add(criteria.equal(root.get("category").get("categoryId"), categoryId));
            }
            if (!selectedLevel.isEmpty()) {
                conditions.add(criteria.equal(root.get("level"), selectedLevel));
            }
            if ("FREE".equals(selectedPrice)) {
                conditions.add(criteria.equal(root.get("price"), BigDecimal.ZERO));
            } else if ("PAID".equals(selectedPrice)) {
                conditions.add(criteria.greaterThan(root.get("price"), BigDecimal.ZERO));
            }
            return criteria.and(conditions.toArray(Predicate[]::new));
        };

        PageRequest pageable = PageRequest.of(Math.max(0, page), PAGE_SIZE,
                Sort.by(Sort.Order.desc("publishedAt"), Sort.Order.desc("courseId")));
        return courseRepository.findAll(filters, pageable).map(this::toView);
    }

    @Transactional(readOnly = true)
    public Optional<CourseView> findPublishedCourse(Integer courseId) {
        return courseRepository.findById(courseId)
                .or(() -> courseRepository.findByCourseIdAndStatus(courseId, PUBLISHED))
                .filter(c -> PUBLISHED.equals(c.getStatus())
                        || "UPDATING".equals(c.getStatus())
                        || ("SUBMITTED".equals(c.getStatus()) && c.getPublishedAt() != null))
                .map(this::toView);
    }

    @Transactional(readOnly = true)
    public List<Category> activeCategories() {
        return categoryRepository.findByStatusOrderByNameAsc("ACTIVE");
    }

    @Transactional(readOnly = true)
    public List<String> publishedLessonTitles(Integer courseId) {
        return lessonRepository.findByCourse_CourseIdAndStatusOrderByOrderIndexAsc(courseId, PUBLISHED)
                .stream().map(lesson -> lesson.getTitle()).toList();
    }

    private CourseView toView(Course course) {
        String categoryName = course.getCategory() == null ? "Chưa phân loại" : course.getCategory().getName();
        return new CourseView(course.getCourseId(), course.getTitle(), course.getDescription(),
                categoryName, course.getInstructor().getFullName(), levelLabel(course.getLevel()),
                course.getThumbnailUrl(), course.getPrice(), course.getCurrency());
    }

    private String levelLabel(String level) {
        return switch (level) {
            case "BEGINNER" -> "Cơ bản";
            case "INTERMEDIATE" -> "Trung cấp";
            case "ADVANCED" -> "Nâng cao";
            default -> "Mọi trình độ";
        };
    }
}
