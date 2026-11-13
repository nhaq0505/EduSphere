package com.edusphere.controller.course;

import com.edusphere.dto.course.AdminLessonReviewView;
import com.edusphere.dto.course.CourseChangeLogView;
import com.edusphere.dto.course.CourseSectionView;
import com.edusphere.entity.account.Users;
import com.edusphere.entity.course.Course;
import com.edusphere.entity.course.CourseSection;
import com.edusphere.entity.course.Lesson;
import com.edusphere.repository.account.UserRepository;
import com.edusphere.repository.course.CourseRepository;
import com.edusphere.repository.course.CourseSectionRepository;
import com.edusphere.repository.course.LessonRepository;
import com.edusphere.service.course.CourseActionException;
import com.edusphere.service.course.CourseChangeLogService;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import org.hibernate.Hibernate;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

/**
 * Controller phục vụ ADMIN theo dõi toàn bộ lịch sử thay đổi khóa học, chương, bài học,
 * video, tài liệu, quiz và câu hỏi trên EduSphere.
 *
 * Chỉ ADMIN (ROLE_ADMINISTRATOR) được phép truy cập.
 */
@Controller
@PreAuthorize("hasRole('ADMINISTRATOR')")
public class AdminCourseChangeLogController {

    private final CourseChangeLogService changeLogService;
    private final CourseRepository courseRepository;
    private final CourseSectionRepository sectionRepository;
    private final LessonRepository lessonRepository;
    private final UserRepository userRepository;

    public AdminCourseChangeLogController(CourseChangeLogService changeLogService,
                                          CourseRepository courseRepository,
                                          CourseSectionRepository sectionRepository,
                                          LessonRepository lessonRepository,
                                          UserRepository userRepository) {
        this.changeLogService = changeLogService;
        this.courseRepository = courseRepository;
        this.sectionRepository = sectionRepository;
        this.lessonRepository = lessonRepository;
        this.userRepository = userRepository;
    }

    // =========================================================================
    // 1. DANH SÁCH LỊCH SỬ THAY ĐỔI TOÀN HỆ THỐNG
    //    GET /admin/course-change-logs
    // =========================================================================

    @GetMapping("/admin/course-change-logs")
    @Transactional(readOnly = true)
    public Object listLogs(
            @RequestParam(required = false) Integer courseId,
            @RequestParam(required = false) Integer teacherId,
            @RequestParam(required = false) String entityType,
            @RequestParam(required = false) String actionType,
            @RequestParam(required = false) String q,
            @RequestParam(required = false) String fromDate,
            @RequestParam(required = false) String toDate,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestParam(required = false) String format,
            HttpServletRequest request,
            Model model) {

        int safePage = Math.max(0, page);
        int safeSize = Math.min(100, Math.max(5, size));
        Pageable pageable = PageRequest.of(safePage, safeSize);

        LocalDateTime fromDt = parseStartDate(fromDate);
        LocalDateTime toDt = parseEndDate(toDate);

        Page<CourseChangeLogView> logsPage = changeLogService.searchLogs(
                courseId, teacherId, entityType, actionType, q, fromDt, toDt, pageable);

        if (wantsJson(request, format)) {
            return ResponseEntity.ok(buildPageJsonResponse(logsPage, courseId, teacherId, entityType, actionType, q));
        }

        populateFilterOptions(model, courseId, teacherId, entityType, actionType, q, fromDate, toDate);
        model.addAttribute("logsPage", logsPage);
        model.addAttribute("logs", logsPage.getContent());

        if (courseId != null) {
            courseRepository.findById(courseId).ifPresent(c -> {
                Hibernate.initialize(c.getInstructor());
                Hibernate.initialize(c.getCategory());
                model.addAttribute("focusedCourse", c);
                model.addAttribute("focusedCourseSections", buildCourseSections(courseId));
                model.addAttribute("lessonReviewMap", changeLogService.buildCourseLessonReviewMap(courseId));
            });
        }
        if (teacherId != null) {
            userRepository.findById(teacherId).ifPresent(u -> model.addAttribute("focusedTeacher", u));
        }

        return "admin/course-change-logs";
    }

    // =========================================================================
    // 2. CHI TIẾT 1 BẢN GHI LỊCH SỬ THAY ĐỔI (BEFORE / AFTER & TÀI NGUYÊN)
    //    GET /admin/course-change-logs/{id}
    // =========================================================================

    @GetMapping("/admin/course-change-logs/{id}")
    @Transactional(readOnly = true)
    public Object logDetail(@PathVariable Long id,
                            @RequestParam(required = false) String format,
                            HttpServletRequest request,
                            Model model) {
        CourseChangeLogView logView = changeLogService.getLogDetail(id);

        if (wantsJson(request, format)) {
            return ResponseEntity.ok(logView);
        }

        model.addAttribute("log", logView);
        if (logView.getCourseId() != null) {
            courseRepository.findById(logView.getCourseId()).ifPresent(c -> {
                Hibernate.initialize(c.getInstructor());
                model.addAttribute("course", c);
            });
        }
        if (logView.getCourseId() != null && logView.getParentLessonId() != null) {
            try {
                AdminLessonReviewView lessonDetail = changeLogService.getAdminLessonDetail(
                        logView.getCourseId(), logView.getParentLessonId());
                model.addAttribute("lessonDetail", lessonDetail);
            } catch (Exception ignored) {
                // Bài học đã bị xóa khỏi DB -> vẫn hiển thị lịch sử từ snapshot
            }
        }
        return "admin/course-change-log-detail";
    }

    // =========================================================================
    // 3. LỊCH SỬ THAY ĐỔI THEO KHÓA HỌC
    //    GET /admin/course-change-logs/course/{courseId}
    // =========================================================================

    @GetMapping("/admin/course-change-logs/course/{courseId}")
    @Transactional(readOnly = true)
    public Object logsByCourse(
            @PathVariable Integer courseId,
            @RequestParam(required = false) String entityType,
            @RequestParam(required = false) String actionType,
            @RequestParam(required = false) String q,
            @RequestParam(required = false) String fromDate,
            @RequestParam(required = false) String toDate,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestParam(required = false) String format,
            HttpServletRequest request,
            Model model) {
        return listLogs(courseId, null, entityType, actionType, q, fromDate, toDate, page, size, format, request, model);
    }

    // =========================================================================
    // 4. LỊCH SỬ THAY ĐỔI THEO GIẢNG VIÊN
    //    GET /admin/course-change-logs/teacher/{teacherId}
    // =========================================================================

    @GetMapping("/admin/course-change-logs/teacher/{teacherId}")
    @Transactional(readOnly = true)
    public Object logsByTeacher(
            @PathVariable Integer teacherId,
            @RequestParam(required = false) Integer courseId,
            @RequestParam(required = false) String entityType,
            @RequestParam(required = false) String actionType,
            @RequestParam(required = false) String q,
            @RequestParam(required = false) String fromDate,
            @RequestParam(required = false) String toDate,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestParam(required = false) String format,
            HttpServletRequest request,
            Model model) {
        return listLogs(courseId, teacherId, entityType, actionType, q, fromDate, toDate, page, size, format, request, model);
    }

    // =========================================================================
    // 5. API JSON CHO ADMIN XEM CHI TIẾT BÀI HỌC & LỊCH SỬ
    //    GET /admin/courses/{courseId}/lessons/{lessonId}/detail
    // =========================================================================

    @GetMapping("/admin/courses/{courseId}/lessons/{lessonId}/detail")
    @ResponseBody
    @Transactional(readOnly = true)
    public ResponseEntity<AdminLessonReviewView> adminLessonDetail(
            @PathVariable Integer courseId,
            @PathVariable Integer lessonId) {
        return ResponseEntity.ok(changeLogService.getAdminLessonDetail(courseId, lessonId));
    }

    // =========================================================================
    // PRIVATE HELPERS
    // =========================================================================

    private void populateFilterOptions(Model model, Integer courseId, Integer teacherId,
                                       String entityType, String actionType,
                                       String q, String fromDate, String toDate) {
        List<Course> allCourses = courseRepository.findAll();
        allCourses.forEach(c -> Hibernate.initialize(c.getInstructor()));
        List<Users> instructors = allCourses.stream()
                .map(Course::getInstructor)
                .filter(u -> u != null && u.getUserId() != null)
                .collect(java.util.stream.Collectors.toMap(
                        Users::getUserId,
                        u -> u,
                        (a, b) -> a,
                        LinkedHashMap::new))
                .values().stream().toList();

        model.addAttribute("allCourses", allCourses);
        model.addAttribute("instructors", instructors);
        model.addAttribute("selectedCourseId", courseId);
        model.addAttribute("selectedTeacherId", teacherId);
        model.addAttribute("selectedEntityType", entityType != null ? entityType : "");
        model.addAttribute("selectedActionType", actionType != null ? actionType : "");
        model.addAttribute("q", q != null ? q : "");
        model.addAttribute("fromDate", fromDate != null ? fromDate : "");
        model.addAttribute("toDate", toDate != null ? toDate : "");
    }

    private List<CourseSectionView> buildCourseSections(Integer courseId) {
        List<CourseSectionView> sectionViews = new ArrayList<>();
        if (sectionRepository != null) {
            List<CourseSection> courseSections = sectionRepository.findByCourse_CourseIdOrderByOrderIndexAsc(courseId);
            for (CourseSection s : courseSections) {
                CourseSectionView sv = new CourseSectionView(
                        s.getSectionId(), courseId, s.getTitle(), s.getDescription(), s.getOrderIndex());
                sv.setLessons(lessonRepository.findBySection_SectionIdOrderByOrderIndexAsc(s.getSectionId()));
                sectionViews.add(sv);
            }
        }
        if (lessonRepository != null) {
            List<Lesson> unsectioned = lessonRepository.findByCourse_CourseIdAndSectionIsNullOrderByOrderIndexAsc(courseId);
            if (!unsectioned.isEmpty()) {
                CourseSectionView unsectionedView = new CourseSectionView(
                        null, courseId, "Bài học chưa phân mục", null, 9999);
                unsectionedView.setLessons(unsectioned);
                sectionViews.add(unsectionedView);
            }
        }
        return sectionViews;
    }

    private Map<String, Object> buildPageJsonResponse(Page<CourseChangeLogView> page,
                                                      Integer courseId, Integer teacherId,
                                                      String entityType, String actionType, String q) {
        Map<String, Object> resp = new LinkedHashMap<>();
        resp.put("content", page.getContent());
        resp.put("page", page.getNumber());
        resp.put("size", page.getSize());
        resp.put("totalElements", page.getTotalElements());
        resp.put("totalPages", page.getTotalPages());
        resp.put("courseId", courseId);
        resp.put("teacherId", teacherId);
        resp.put("entityType", entityType);
        resp.put("actionType", actionType);
        resp.put("q", q);
        return resp;
    }

    private boolean wantsJson(HttpServletRequest request, String format) {
        if ("json".equalsIgnoreCase(format)) return true;
        if (request == null) return false;
        String accept = request.getHeader("Accept");
        return accept != null && accept.contains("application/json") && !accept.contains("text/html");
    }

    private LocalDateTime parseStartDate(String dateStr) {
        if (dateStr == null || dateStr.isBlank()) return null;
        try {
            return LocalDate.parse(dateStr.trim()).atStartOfDay();
        } catch (Exception e) {
            return null;
        }
    }

    private LocalDateTime parseEndDate(String dateStr) {
        if (dateStr == null || dateStr.isBlank()) return null;
        try {
            return LocalDate.parse(dateStr.trim()).atTime(LocalTime.MAX);
        } catch (Exception e) {
            return null;
        }
    }

    @ExceptionHandler(CourseActionException.class)
    public String handleCourseActionError(CourseActionException ex, HttpServletResponse response, Model model) {
        response.setStatus(ex.getStatus().value());
        model.addAttribute("errorMessage", ex.getMessage());
        return "courses/action-error";
    }
}
