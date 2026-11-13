package com.edusphere.service.course;

import com.edusphere.dto.course.CourseView;
import com.edusphere.dto.course.LessonItemView;
import com.edusphere.entity.course.Category;
import com.edusphere.entity.course.Course;
import com.edusphere.entity.course.Lesson;
import com.edusphere.repository.course.CategoryRepository;
import com.edusphere.repository.course.CourseRatingRepository;
import com.edusphere.repository.course.CourseRepository;
import com.edusphere.repository.course.CourseSectionRepository;
import com.edusphere.repository.course.LessonRepository;

import jakarta.persistence.criteria.Predicate;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
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
    private final CourseRatingRepository courseRatingRepository;
    private final CourseSectionRepository courseSectionRepository;

    @Autowired
    public CourseDiscoveryService(CourseRepository courseRepository,
                                  CategoryRepository categoryRepository,
                                  LessonRepository lessonRepository,
                                  CourseRatingRepository courseRatingRepository,
                                  @Autowired(required = false) CourseSectionRepository courseSectionRepository) {
        this.courseRepository = courseRepository;
        this.categoryRepository = categoryRepository;
        this.lessonRepository = lessonRepository;
        this.courseRatingRepository = courseRatingRepository;
        this.courseSectionRepository = courseSectionRepository;
    }

    public CourseDiscoveryService(CourseRepository courseRepository,
                                  CategoryRepository categoryRepository,
                                  LessonRepository lessonRepository,
                                  CourseRatingRepository courseRatingRepository) {
        this(courseRepository, categoryRepository, lessonRepository, courseRatingRepository, null);
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
        Page<Course> coursesPage = courseRepository.findAll(filters, pageable);
        Map<Integer, double[]> ratingMap = loadRatingStats(
                coursesPage.getContent().stream().map(Course::getCourseId).toList());
        return coursesPage.map(c -> toListView(c, ratingMap.get(c.getCourseId())));
    }

    @Transactional(readOnly = true)
    public Optional<CourseView> findPublishedCourse(Integer courseId) {
        return courseRepository.findById(courseId)
                .or(() -> courseRepository.findByCourseIdAndStatus(courseId, PUBLISHED))
                .filter(c -> PUBLISHED.equals(c.getStatus())
                        || "UPDATING".equals(c.getStatus())
                        || ("SUBMITTED".equals(c.getStatus()) && c.getPublishedAt() != null))
                .map(c -> {
                    Map<Integer, double[]> ratingMap = loadRatingStats(List.of(c.getCourseId()));
                    return toDetailView(c, ratingMap.get(c.getCourseId()));
                });
    }

    @Transactional(readOnly = true)
    public List<CourseView> featuredCourses(int limit) {
        PageRequest pageable = PageRequest.of(0, Math.max(1, limit),
                Sort.by(Sort.Order.desc("publishedAt"), Sort.Order.desc("courseId")));
        Specification<Course> filters = (root, query, criteria) -> {
            Predicate isPublishedOrUpdating = root.get("status").in(PUBLISHED, "UPDATING");
            Predicate isSubmittedWithPriorPublish = criteria.and(
                    criteria.equal(root.get("status"), "SUBMITTED"),
                    criteria.isNotNull(root.get("publishedAt"))
            );
            return criteria.or(isPublishedOrUpdating, isSubmittedWithPriorPublish);
        };
        Page<Course> coursesPage = courseRepository.findAll(filters, pageable);
        if (coursesPage.isEmpty()) {
            PageRequest fallbackPageable = PageRequest.of(0, Math.max(1, limit),
                    Sort.by(Sort.Order.desc("courseId")));
            coursesPage = courseRepository.findAll(fallbackPageable);
        }
        Map<Integer, double[]> ratingMap = loadRatingStats(
                coursesPage.getContent().stream().map(Course::getCourseId).toList());
        return coursesPage.getContent().stream().map(c -> toListView(c, ratingMap.get(c.getCourseId()))).toList();
    }

    @Transactional(readOnly = true)
    public List<Category> activeCategories() {
        List<Category> list = categoryRepository.findByStatusOrderByNameAsc("ACTIVE");
        if (list.isEmpty()) {
            return categoryRepository.findAll();
        }
        return list;
    }

    @Transactional(readOnly = true)
    public List<String> publishedLessonTitles(Integer courseId) {
        return lessonRepository.findByCourse_CourseIdAndStatusOrderByOrderIndexAsc(courseId, PUBLISHED)
                .stream().map(Lesson::getTitle).toList();
    }

    @Transactional(readOnly = true)
    public List<LessonItemView> publishedLessonItems(Integer courseId) {
        return lessonRepository.findByCourse_CourseIdAndStatusOrderByOrderIndexAsc(courseId, PUBLISHED)
                .stream()
                .map(l -> new LessonItemView(
                        l.getLessonId(),
                        l.getTitle(),
                        l.getOrderIndex(),
                        false,
                        false,
                        l.getLessonType(),
                        l.getVideoDuration(),
                        false,
                        l.getSection() != null ? l.getSection().getSectionId() : null,
                        l.getSection() != null ? l.getSection().getTitle() : null
                ))
                .toList();
    }

    private Map<Integer, double[]> loadRatingStats(List<Integer> courseIds) {
        Map<Integer, double[]> map = new HashMap<>();
        if (courseIds == null || courseIds.isEmpty() || courseRatingRepository == null) {
            return map;
        }
        for (Object[] row : courseRatingRepository.summarizeByCourseIds(courseIds)) {
            Integer id = (Integer) row[0];
            double avg = row[1] == null ? 0.0 : Math.round(((Number) row[1]).doubleValue() * 10.0) / 10.0;
            long count = row[2] == null ? 0L : ((Number) row[2]).longValue();
            map.put(id, new double[]{avg, count});
        }
        return map;
    }

    private CourseView toListView(Course course, double[] stats) {
        String categoryName = course.getCategory() == null ? "Chưa phân loại" : course.getCategory().getName();
        double avgRating = stats != null ? stats[0] : 0.0;
        long ratingCount = stats != null ? (long) stats[1] : 0L;
        String insName = course.getInstructor() != null ? course.getInstructor().getFullName() : "Giảng viên";
        return new CourseView(course.getCourseId(), course.getTitle(), course.getDescription(),
                categoryName, insName, levelLabel(course.getLevel()),
                course.getThumbnailUrl(), course.getPrice(), course.getCurrency(),
                avgRating, ratingCount);
    }

    private CourseView toDetailView(Course course, double[] stats) {
        String categoryName = course.getCategory() == null ? "Chưa phân loại" : course.getCategory().getName();
        double avgRating = stats != null ? stats[0] : 0.0;
        long ratingCount = stats != null ? (long) stats[1] : 0L;

        String insName = course.getInstructor() != null ? course.getInstructor().getFullName() : "Giảng viên EduSphere";
        String insAvatar = course.getInstructor() != null ? course.getInstructor().getAvatarUrl() : null;
        String insEmail = course.getInstructor() != null ? course.getInstructor().getEmail() : null;

        List<Lesson> lessons = lessonRepository.findByCourse_CourseIdAndStatusOrderByOrderIndexAsc(course.getCourseId(), PUBLISHED);
        int lessonCount = lessons.size();
        int totalSecs = lessons.stream()
                .filter(l -> l.getVideoDuration() != null && l.getVideoDuration() > 0)
                .mapToInt(Lesson::getVideoDuration)
                .sum();
        int totalMins = totalSecs > 0 ? (int) Math.ceil(totalSecs / 60.0) : 0;
        String formattedDuration = formatDuration(totalMins);

        int sectionCount = courseSectionRepository != null
                ? (int) courseSectionRepository.countByCourse_CourseId(course.getCourseId())
                : 0;

        return new CourseView(
                course.getCourseId(),
                course.getTitle(),
                course.getDescription(),
                categoryName,
                insName,
                insAvatar,
                insEmail,
                levelLabel(course.getLevel()),
                course.getThumbnailUrl(),
                course.getPrice(),
                course.getCurrency(),
                avgRating,
                ratingCount,
                course.getObjectives(),
                course.getRequirements(),
                course.getCredits(),
                sectionCount,
                lessonCount,
                totalMins,
                formattedDuration
        );
    }

    private String formatDuration(int totalMinutes) {
        if (totalMinutes <= 0) return null;
        int hours = totalMinutes / 60;
        int mins = totalMinutes % 60;
        if (hours > 0 && mins > 0) {
            return hours + " giờ " + mins + " phút";
        } else if (hours > 0) {
            return hours + " giờ";
        } else {
            return mins + " phút";
        }
    }

    private String levelLabel(String level) {
        if (level == null) return "Mọi trình độ";
        return switch (level) {
            case "BEGINNER" -> "Cơ bản";
            case "INTERMEDIATE" -> "Trung cấp";
            case "ADVANCED" -> "Nâng cao";
            default -> "Mọi trình độ";
        };
    }
}
