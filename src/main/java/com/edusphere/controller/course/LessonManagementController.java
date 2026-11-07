package com.edusphere.controller.course;

import com.edusphere.dto.course.LessonForm;
import com.edusphere.dto.course.MaterialForm;
import com.edusphere.entity.course.Lesson;
import com.edusphere.security.CustomUserDetails;
import com.edusphere.service.course.CourseActionException;
import com.edusphere.service.course.CourseSectionService;
import com.edusphere.service.course.LessonManagementService;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.validation.Valid;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.List;

@Controller
@RequestMapping("/instructor/courses/{courseId}/lessons")
public class LessonManagementController {
    private final LessonManagementService service;
    private final CourseSectionService sectionService;

    public LessonManagementController(LessonManagementService service, CourseSectionService sectionService) {
        this.service = service;
        this.sectionService = sectionService;
    }

    @GetMapping
    public String list(@PathVariable Integer courseId, @AuthenticationPrincipal CustomUserDetails instructor,
                       Model model) {
        var course = service.ownedCourse(courseId, instructor.getUserId());
        model.addAttribute("course", course);
        model.addAttribute("lessons", service.lessons(courseId, instructor.getUserId()));
        model.addAttribute("sections", sectionService.getSectionsWithLessons(courseId, instructor.getUserId()));
        model.addAttribute("editable", !"SUBMITTED".equals(course.getStatus()) && !"ARCHIVED".equals(course.getStatus()));
        return "courses/instructor-lessons";
    }

    @GetMapping("/new")
    public String newForm(@PathVariable Integer courseId,
                          @RequestParam(required = false) Integer sectionId,
                          @AuthenticationPrincipal CustomUserDetails instructor,
                          Model model) {
        var course = service.editableForDisplay(courseId, instructor.getUserId());
        LessonForm form = new LessonForm();
        if (sectionId != null) {
            form.setSectionId(sectionId);
        }
        model.addAttribute("course", course);
        model.addAttribute("lessonForm", form);
        model.addAttribute("courseId", courseId);
        model.addAttribute("sections", sectionService.getSectionsWithLessons(courseId, instructor.getUserId()));
        model.addAttribute("existingLessons", service.lessons(courseId, instructor.getUserId()));
        model.addAttribute("formAction", "/instructor/courses/" + courseId + "/lessons");
        return "courses/lesson-form";
    }

    @PostMapping
    public String create(@PathVariable Integer courseId, @Valid @ModelAttribute("lessonForm") LessonForm form,
                         BindingResult errors, @AuthenticationPrincipal CustomUserDetails instructor,
                         Model model, RedirectAttributes flash) {
        if (errors.hasErrors()) {
            var course = service.editableForDisplay(courseId, instructor.getUserId());
            model.addAttribute("course", course);
            model.addAttribute("courseId", courseId);
            model.addAttribute("sections", sectionService.getSectionsWithLessons(courseId, instructor.getUserId()));
            model.addAttribute("existingLessons", service.lessons(courseId, instructor.getUserId()));
            model.addAttribute("formAction", "/instructor/courses/" + courseId + "/lessons");
            return "courses/lesson-form";
        }
        Integer lessonId = service.create(courseId, instructor.getUserId(), form);
        var course = service.ownedCourse(courseId, instructor.getUserId());
        if ("DRAFT".equals(course.getStatus()) && course.getVersionNo() != null && course.getVersionNo() > 1) {
            flash.addFlashAttribute("success", "Đã tạo bài học mới. Khóa học đã được chuyển về bản nháp (v" + course.getVersionNo() + ") để bạn hoàn thiện và gửi Admin duyệt lại.");
        } else {
            flash.addFlashAttribute("success", "Đã tạo bài học thành công.");
        }
        return "redirect:/instructor/courses/" + courseId;
    }

    @GetMapping("/{lessonId}")
    public String detail(@PathVariable Integer courseId, @PathVariable Integer lessonId,
                         @AuthenticationPrincipal CustomUserDetails instructor, Model model) {
        var course = service.ownedCourse(courseId, instructor.getUserId());
        model.addAttribute("course", course);
        model.addAttribute("lesson", service.lesson(courseId, lessonId, instructor.getUserId()));
        model.addAttribute("materials", service.materials(courseId, lessonId, instructor.getUserId()));
        model.addAttribute("materialForm", new MaterialForm());
        model.addAttribute("editable", !"SUBMITTED".equals(course.getStatus()) && !"ARCHIVED".equals(course.getStatus()));
        return "courses/instructor-lesson-detail";
    }

    @GetMapping("/{lessonId}/edit")
    public String editForm(@PathVariable Integer courseId, @PathVariable Integer lessonId,
                           @AuthenticationPrincipal CustomUserDetails instructor, Model model) {
        var course = service.editableForDisplay(courseId, instructor.getUserId());
        Lesson lesson = service.lesson(courseId, lessonId, instructor.getUserId());
        LessonForm form = new LessonForm();
        form.setTitle(lesson.getTitle());
        form.setContent(lesson.getContent());
        form.setOrderIndex(lesson.getOrderIndex());
        form.setSectionId(lesson.getSection() != null ? lesson.getSection().getSectionId() : null);
        form.setLessonType(lesson.getLessonType() != null ? lesson.getLessonType() : "ARTICLE");
        form.setVideoUrl(lesson.getVideoUrl());
        form.setVideoDuration(lesson.getVideoDuration());
        form.setAllowSeek(lesson.getAllowSeek() != null ? lesson.getAllowSeek() : true);
        form.setIsPreview(Boolean.TRUE.equals(lesson.getIsPreview()));
        form.setUnlockDaysAfterEnroll(lesson.getUnlockDaysAfterEnroll());
        form.setPrerequisiteLessonId(lesson.getPrerequisiteLesson() != null ? lesson.getPrerequisiteLesson().getLessonId() : null);
        form.setInstructorNotes(lesson.getInstructorNotes());

        List<Lesson> allLessons = service.lessons(courseId, instructor.getUserId());
        List<Lesson> candidatePrereqs = allLessons.stream().filter(l -> !l.getLessonId().equals(lessonId)).toList();

        model.addAttribute("course", course);
        model.addAttribute("lessonForm", form);
        model.addAttribute("courseId", courseId);
        model.addAttribute("lessonId", lessonId);
        model.addAttribute("sections", sectionService.getSectionsWithLessons(courseId, instructor.getUserId()));
        model.addAttribute("existingLessons", candidatePrereqs);
        model.addAttribute("materials", service.materials(courseId, lessonId, instructor.getUserId()));
        model.addAttribute("maxOrder", allLessons.size());
        model.addAttribute("formAction", "/instructor/courses/" + courseId + "/lessons/" + lessonId + "/edit");
        return "courses/lesson-form";
    }

    @PostMapping("/{lessonId}/edit")
    public String edit(@PathVariable Integer courseId, @PathVariable Integer lessonId,
                       @Valid @ModelAttribute("lessonForm") LessonForm form, BindingResult errors,
                       @AuthenticationPrincipal CustomUserDetails instructor, Model model,
                       RedirectAttributes flash) {
        if (errors.hasErrors()) {
            var course = service.editableForDisplay(courseId, instructor.getUserId());
            model.addAttribute("course", course);
            model.addAttribute("courseId", courseId);
            model.addAttribute("lessonId", lessonId);
            model.addAttribute("sections", sectionService.getSectionsWithLessons(courseId, instructor.getUserId()));
            model.addAttribute("existingLessons", service.lessons(courseId, instructor.getUserId()).stream().filter(l -> !l.getLessonId().equals(lessonId)).toList());
            model.addAttribute("materials", service.materials(courseId, lessonId, instructor.getUserId()));
            model.addAttribute("maxOrder", service.lessons(courseId, instructor.getUserId()).size());
            model.addAttribute("formAction", "/instructor/courses/" + courseId + "/lessons/" + lessonId + "/edit");
            return "courses/lesson-form";
        }
        service.edit(courseId, lessonId, instructor.getUserId(), form);
        var course = service.ownedCourse(courseId, instructor.getUserId());
        if ("DRAFT".equals(course.getStatus()) && course.getVersionNo() != null && course.getVersionNo() > 1) {
            flash.addFlashAttribute("success", "Đã cập nhật bài học. Khóa học đã được chuyển về bản nháp (v" + course.getVersionNo() + ") để bạn hoàn thiện và gửi Admin duyệt lại.");
        } else {
            flash.addFlashAttribute("success", "Đã cập nhật bài học.");
        }
        return "redirect:/instructor/courses/" + courseId;
    }

    @PostMapping("/{lessonId}/delete")
    public String deleteLesson(@PathVariable Integer courseId,
                               @PathVariable Integer lessonId,
                               @AuthenticationPrincipal CustomUserDetails instructor,
                               RedirectAttributes flash) {
        service.deleteLesson(courseId, lessonId, instructor.getUserId());
        flash.addFlashAttribute("success", "Đã xóa bài học.");
        return "redirect:/instructor/courses/" + courseId;
    }

    @PostMapping("/{lessonId}/materials")
    public String addMaterial(@PathVariable Integer courseId, @PathVariable Integer lessonId,
                              @Valid @ModelAttribute("materialForm") MaterialForm form, BindingResult errors,
                              @AuthenticationPrincipal CustomUserDetails instructor, Model model,
                              RedirectAttributes flash) {
        if (errors.hasErrors()) {
            service.editableForDisplay(courseId, instructor.getUserId());
            detail(courseId, lessonId, instructor, model);
            model.addAttribute("materialForm", form);
            return "courses/instructor-lesson-detail";
        }
        service.addMaterial(courseId, lessonId, instructor.getUserId(), form);
        var course = service.ownedCourse(courseId, instructor.getUserId());
        if ("DRAFT".equals(course.getStatus()) && course.getVersionNo() != null && course.getVersionNo() > 1) {
            flash.addFlashAttribute("success", "Đã thêm tài liệu cho bài học. Khóa học đã được chuyển về bản nháp (v" + course.getVersionNo() + ") để bạn hoàn thiện và gửi Admin duyệt lại.");
        } else {
            flash.addFlashAttribute("success", "Đã thêm tài liệu cho bài học.");
        }
        return "redirect:/instructor/courses/" + courseId + "/lessons/" + lessonId;
    }

    @PostMapping("/{lessonId}/materials/{materialId}/delete")
    public String deleteMaterial(@PathVariable Integer courseId,
                                 @PathVariable Integer lessonId,
                                 @PathVariable Integer materialId,
                                 @AuthenticationPrincipal CustomUserDetails instructor,
                                 RedirectAttributes flash) {
        service.deleteMaterial(courseId, lessonId, materialId, instructor.getUserId());
        flash.addFlashAttribute("success", "Đã xóa tài liệu.");
        return "redirect:/instructor/courses/" + courseId + "/lessons/" + lessonId;
    }

    @ExceptionHandler(CourseActionException.class)
    public String courseError(CourseActionException ex, HttpServletResponse response, Model model) {
        response.setStatus(ex.getStatus().value());
        model.addAttribute("errorMessage", ex.getMessage());
        return "courses/action-error";
    }
}
