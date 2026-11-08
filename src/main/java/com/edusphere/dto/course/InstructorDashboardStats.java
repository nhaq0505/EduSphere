package com.edusphere.dto.course;

import java.math.BigDecimal;
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

    private BigDecimal grossRevenue = BigDecimal.ZERO;
    private BigDecimal netEarnings = BigDecimal.ZERO;
    private BigDecimal availableBalance = BigDecimal.ZERO;
    private int paidOrdersCount = 0;

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

    public BigDecimal getGrossRevenue() { return grossRevenue; }
    public void setGrossRevenue(BigDecimal grossRevenue) { this.grossRevenue = grossRevenue; }

    public BigDecimal getNetEarnings() { return netEarnings; }
    public void setNetEarnings(BigDecimal netEarnings) { this.netEarnings = netEarnings; }

    public BigDecimal getAvailableBalance() { return availableBalance; }
    public void setAvailableBalance(BigDecimal availableBalance) { this.availableBalance = availableBalance; }

    public int getPaidOrdersCount() { return paidOrdersCount; }
    public void setPaidOrdersCount(int paidOrdersCount) { this.paidOrdersCount = paidOrdersCount; }
}
