package com.edusphere.dto.course;

import java.util.List;

/**
 * DTO tổng hợp dữ liệu thống kê cho Dashboard giáo viên.
 */
public class InstructorDashboardStats {

    private final int totalCourses;
    private final int publishedCourses;
    private final int draftCourses;
    private final int totalStudents;
    private final int totalLessons;
    private final List<ManagedCourseView> recentCourses;

    public InstructorDashboardStats(int totalCourses, int publishedCourses, int draftCourses,
                                    int totalStudents, int totalLessons,
                                    List<ManagedCourseView> recentCourses) {
        this.totalCourses    = totalCourses;
        this.publishedCourses = publishedCourses;
        this.draftCourses    = draftCourses;
        this.totalStudents   = totalStudents;
        this.totalLessons    = totalLessons;
        this.recentCourses   = recentCourses;
    }

    public int getTotalCourses()    { return totalCourses; }
    public int getPublishedCourses(){ return publishedCourses; }
    public int getDraftCourses()    { return draftCourses; }
    public int getTotalStudents()   { return totalStudents; }
    public int getTotalLessons()    { return totalLessons; }
    public List<ManagedCourseView> getRecentCourses() { return recentCourses; }
}
