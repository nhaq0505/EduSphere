package com.edusphere.service.course;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Objects;

import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.edusphere.dto.course.CourseSectionView;
import com.edusphere.dto.course.SectionForm;
import com.edusphere.entity.course.Course;
import com.edusphere.entity.course.CourseSection;
import com.edusphere.entity.course.Lesson;
import com.edusphere.repository.course.CourseRepository;
import com.edusphere.repository.course.CourseSectionRepository;
import com.edusphere.repository.course.LessonRepository;

@Service
public class CourseSectionService {

    private final CourseSectionRepository sectionRepository;
    private final CourseRepository courseRepository;
    private final LessonRepository lessonRepository;

    @org.springframework.beans.factory.annotation.Autowired(required = false)
    private CourseChangeLogService changeLogService;

    public void setChangeLogService(CourseChangeLogService changeLogService) {
        this.changeLogService = changeLogService;
    }

    public CourseSectionService(CourseSectionRepository sectionRepository,
                                CourseRepository courseRepository,
                                LessonRepository lessonRepository) {
        this.sectionRepository = sectionRepository;
        this.courseRepository = courseRepository;
        this.lessonRepository = lessonRepository;
    }

    @Transactional(readOnly = true)
    public List<CourseSectionView> getSectionsWithLessons(Integer courseId, Integer instructorId) {
        Course course = verifyOwnership(courseId, instructorId);
        List<CourseSection> sections = sectionRepository.findByCourse_CourseIdOrderByOrderIndexAsc(courseId);
        List<CourseSectionView> views = new ArrayList<>();

        for (CourseSection s : sections) {
            CourseSectionView sv = new CourseSectionView(s.getSectionId(), courseId, s.getTitle(), s.getDescription(), s.getOrderIndex());
            List<Lesson> lessons = lessonRepository.findBySection_SectionIdOrderByOrderIndexAsc(s.getSectionId());
            sv.setLessons(lessons);
            views.add(sv);
        }

        // Check if there are lessons without section
        List<Lesson> unsectioned = lessonRepository.findByCourse_CourseIdAndSectionIsNullOrderByOrderIndexAsc(courseId);
        if (!unsectioned.isEmpty()) {
            CourseSectionView defaultView = new CourseSectionView(null, courseId, "Bài học chưa phân mục", null, 9999);
            defaultView.setLessons(unsectioned);
            views.add(defaultView);
        }

        return views;
    }

    @Transactional
    public CourseSection createSection(Integer courseId, Integer instructorId, SectionForm form) {
        Course course = verifyOwnership(courseId, instructorId);
        long count = sectionRepository.countByCourse_CourseId(courseId);

        CourseSection section = new CourseSection();
        section.setCourse(course);
        section.setTitle(form.getTitle().trim());
        section.setDescription(form.getDescription() != null ? form.getDescription().trim() : null);
        section.setOrderIndex(form.getOrderIndex() != null ? form.getOrderIndex() : (int) (count + 1));
        section.setCreatedAt(LocalDateTime.now());
        section.setUpdatedAt(LocalDateTime.now());

        CourseSection saved = sectionRepository.save(section);
        if (changeLogService != null) {
            changeLogService.recordSectionCreate(course, saved);
        }
        return saved;
    }

    @Transactional
    public CourseSection updateSection(Integer courseId, Integer sectionId, Integer instructorId, SectionForm form) {
        Course course = verifyOwnership(courseId, instructorId);
        CourseSection section = sectionRepository.findBySectionIdAndCourse_CourseId(sectionId, courseId)
                .orElseThrow(() -> new CourseActionException(HttpStatus.NOT_FOUND, "Không tìm thấy chương này trong khóa học."));

        var before = changeLogService != null ? changeLogService.snapshotSection(section) : null;
        section.setTitle(form.getTitle().trim());
        if (form.getDescription() != null) {
            section.setDescription(form.getDescription().trim());
        }
        section.setUpdatedAt(LocalDateTime.now());
        CourseSection saved = sectionRepository.save(section);
        if (changeLogService != null) {
            changeLogService.recordSectionUpdate(course, saved, before, changeLogService.snapshotSection(saved));
        }
        return saved;
    }

    @Transactional
    public void deleteSection(Integer courseId, Integer sectionId, Integer instructorId) {
        Course course = verifyOwnership(courseId, instructorId);
        CourseSection section = sectionRepository.findBySectionIdAndCourse_CourseId(sectionId, courseId)
                .orElseThrow(() -> new CourseActionException(HttpStatus.NOT_FOUND, "Không tìm thấy chương mục."));

        var beforeSnapshot = changeLogService != null ? changeLogService.snapshotSection(section) : null;

        // Unlink lessons in this section so lessons are not accidentally deleted
        List<Lesson> lessons = lessonRepository.findBySection_SectionIdOrderByOrderIndexAsc(sectionId);
        for (Lesson l : lessons) {
            l.setSection(null);
            lessonRepository.save(l);
        }

        sectionRepository.delete(section);
        if (changeLogService != null) {
            changeLogService.recordSectionDelete(course, beforeSnapshot);
        }
    }

    @Transactional
    public void reorderSections(Integer courseId, Integer instructorId, List<Integer> sectionIds) {
        Course course = verifyOwnership(courseId, instructorId);
        if (sectionIds == null || sectionIds.isEmpty()) return;

        List<CourseSection> beforeList = sectionRepository.findByCourse_CourseIdOrderByOrderIndexAsc(courseId);
        String beforeOrder = formatSectionOrder(beforeList);

        for (int i = 0; i < sectionIds.size(); i++) {
            Integer sId = sectionIds.get(i);
            var opt = sectionRepository.findBySectionIdAndCourse_CourseId(sId, courseId);
            if (opt.isPresent()) {
                CourseSection s = opt.get();
                s.setOrderIndex(i + 1);
                s.setUpdatedAt(LocalDateTime.now());
                sectionRepository.save(s);
            }
        }
        if (changeLogService != null) {
            List<CourseSection> afterList = sectionRepository.findByCourse_CourseIdOrderByOrderIndexAsc(courseId);
            changeLogService.recordSectionReorder(course, beforeOrder, formatSectionOrder(afterList));
        }
    }

    @Transactional
    public void moveSection(Integer courseId, Integer sectionId, Integer instructorId, String direction) {
        Course course = verifyOwnership(courseId, instructorId);
        List<CourseSection> sections = sectionRepository.findByCourse_CourseIdOrderByOrderIndexAsc(courseId);
        String beforeOrder = formatSectionOrder(sections);
        int idx = -1;
        for (int i = 0; i < sections.size(); i++) {
            if (Objects.equals(sections.get(i).getSectionId(), sectionId)) {
                idx = i;
                break;
            }
        }
        if (idx == -1) return;

        if ("up".equalsIgnoreCase(direction) && idx > 0) {
            Collections.swap(sections, idx, idx - 1);
        } else if ("down".equalsIgnoreCase(direction) && idx < sections.size() - 1) {
            Collections.swap(sections, idx, idx + 1);
        }

        for (int i = 0; i < sections.size(); i++) {
            CourseSection s = sections.get(i);
            s.setOrderIndex(i + 1);
            s.setUpdatedAt(LocalDateTime.now());
            sectionRepository.save(s);
        }
        if (changeLogService != null) {
            changeLogService.recordSectionReorder(course, beforeOrder, formatSectionOrder(sections));
        }
    }

    private String formatSectionOrder(List<CourseSection> list) {
        if (list == null || list.isEmpty()) return "";
        return list.stream()
                .map(s -> s.getOrderIndex() + ". " + s.getTitle())
                .collect(java.util.stream.Collectors.joining(" | "));
    }

    private Course verifyOwnership(Integer courseId, Integer instructorId) {
        Course course = courseRepository.findById(courseId)
                .orElseThrow(() -> new CourseActionException(HttpStatus.NOT_FOUND, "Không tìm thấy khóa học."));
        if (!Objects.equals(course.getInstructor().getUserId(), instructorId)) {
            throw new CourseActionException(HttpStatus.FORBIDDEN, "Bạn không có quyền chỉnh sửa khóa học này.");
        }
        return course;
    }
}

