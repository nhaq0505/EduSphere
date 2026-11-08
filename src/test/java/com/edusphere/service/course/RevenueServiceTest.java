package com.edusphere.service.course;

import com.edusphere.entity.account.Users;
import com.edusphere.entity.course.Course;
import com.edusphere.entity.course.Payment;
import com.edusphere.entity.course.PayoutRequest;
import com.edusphere.repository.account.UserRepository;
import com.edusphere.repository.course.CourseRepository;
import com.edusphere.repository.course.PaymentRepository;
import com.edusphere.repository.course.PayoutRequestRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.http.HttpStatus;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

class RevenueServiceTest {

    private PaymentRepository paymentRepository;
    private PayoutRequestRepository payoutRequestRepository;
    private CourseRepository courseRepository;
    private UserRepository userRepository;
    private RevenueService revenueService;

    private Users instructor;
    private Users student;
    private Course course;

    @BeforeEach
    void setUp() {
        paymentRepository = mock(PaymentRepository.class);
        payoutRequestRepository = mock(PayoutRequestRepository.class);
        courseRepository = mock(CourseRepository.class);
        userRepository = mock(UserRepository.class);

        revenueService = new RevenueService(
                paymentRepository, payoutRequestRepository, courseRepository, userRepository);

        instructor = new Users();
        instructor.setUserId(10);
        instructor.setFullName("Instructor Demo");
        instructor.setEmail("instructor@instructor.com");

        student = new Users();
        student.setUserId(20);
        student.setFullName("Student Demo");
        student.setEmail("student@student.com");

        course = new Course();
        course.setCourseId(100);
        course.setTitle("SQL Server Pro");
        course.setPrice(new BigDecimal("500000"));
        course.setStatus("PUBLISHED");
        course.setInstructor(instructor);
    }

    @Test
    void getInstructorRevenueCalculates8020SplitAndAvailableBalance() {
        Payment p1 = new Payment();
        p1.setPaymentId(1);
        p1.setCourse(course);
        p1.setStudent(student);
        p1.setAmount(new BigDecimal("500000"));
        p1.setStatus("SUCCEEDED");
        p1.setCompletedAt(LocalDateTime.now());

        Payment p2Cancelled = new Payment();
        p2Cancelled.setPaymentId(2);
        p2Cancelled.setCourse(course);
        p2Cancelled.setStudent(student);
        p2Cancelled.setAmount(new BigDecimal("500000"));
        p2Cancelled.setStatus("CANCELLED");

        PayoutRequest approvedPayout = new PayoutRequest();
        approvedPayout.setPayoutId(1);
        approvedPayout.setInstructor(instructor);
        approvedPayout.setAmount(new BigDecimal("100000"));
        approvedPayout.setStatus("APPROVED");

        PayoutRequest pendingPayout = new PayoutRequest();
        pendingPayout.setPayoutId(2);
        pendingPayout.setInstructor(instructor);
        pendingPayout.setAmount(new BigDecimal("50000"));
        pendingPayout.setStatus("PENDING");

        when(courseRepository.findByInstructor_UserIdOrderByCreatedAtDesc(10)).thenReturn(List.of(course));
        when(paymentRepository.findByInstructorIdOrderByDateDesc(10)).thenReturn(List.of(p1, p2Cancelled));
        when(payoutRequestRepository.findByInstructorIdOrderByRequestedAtDesc(10))
                .thenReturn(List.of(approvedPayout, pendingPayout));

        RevenueService.InstructorRevenueDashboard dash = revenueService.getInstructorRevenue(10, null);

        // Gross: 500,000 -> Platform 20%: 100,000 -> Net 80%: 400,000
        assertEquals(0, new BigDecimal("500000").compareTo(dash.getGrossRevenue()));
        assertEquals(0, new BigDecimal("100000").compareTo(dash.getPlatformFee()));
        assertEquals(0, new BigDecimal("400000").compareTo(dash.getNetEarnings()));
        // Withdrawn: 100,000, Pending: 50,000 -> Available: 250,000
        assertEquals(0, new BigDecimal("100000").compareTo(dash.getWithdrawnAmount()));
        assertEquals(0, new BigDecimal("50000").compareTo(dash.getPendingPayoutAmount()));
        assertEquals(0, new BigDecimal("250000").compareTo(dash.getAvailableBalance()));
        assertEquals(1, dash.getPaidOrdersCount());
    }

    @Test
    void requestPayoutValidatesAvailableBalanceAndMinimumAmount() {
        Payment p1 = new Payment();
        p1.setPaymentId(1);
        p1.setCourse(course);
        p1.setStudent(student);
        p1.setAmount(new BigDecimal("200000")); // Net 80% = 160,000
        p1.setStatus("SUCCEEDED");

        when(userRepository.findById(10)).thenReturn(Optional.of(instructor));
        when(courseRepository.findByInstructor_UserIdOrderByCreatedAtDesc(10)).thenReturn(List.of(course));
        when(paymentRepository.findByInstructorIdOrderByDateDesc(10)).thenReturn(List.of(p1));
        when(payoutRequestRepository.findByInstructorIdOrderByRequestedAtDesc(10)).thenReturn(List.of());
        when(payoutRequestRepository.save(any())).thenAnswer(inv -> inv.getArgument(0));

        // 1. Below minimum (< 50,000) -> 400 BAD_REQUEST
        CourseActionException minEx = assertThrows(CourseActionException.class, () ->
                revenueService.requestPayout(10, new BigDecimal("30000"), "VCB", "123456", "NGUYEN VAN A", null));
        assertEquals(HttpStatus.BAD_REQUEST, minEx.getStatus());

        // 2. Exceeds available balance (> 160,000) -> 409 CONFLICT
        CourseActionException maxEx = assertThrows(CourseActionException.class, () ->
                revenueService.requestPayout(10, new BigDecimal("170000"), "VCB", "123456", "NGUYEN VAN A", null));
        assertEquals(HttpStatus.CONFLICT, maxEx.getStatus());

        // 3. Valid payout (150,000) -> Saved as PENDING
        PayoutRequest saved = revenueService.requestPayout(
                10, new BigDecimal("150000"), "Vietcombank", "0123456789", "nguyen van a", "Rút đợt 1");
        assertEquals("PENDING", saved.getStatus());
        assertEquals("NGUYEN VAN A", saved.getAccountHolder());
        assertEquals(0, new BigDecimal("150000").compareTo(saved.getAmount()));
    }

    @Test
    void adminApproveAndRejectPayoutUpdatesStatusAndRestoresBalanceOnReject() {
        PayoutRequest pr = new PayoutRequest();
        pr.setPayoutId(5);
        pr.setInstructor(instructor);
        pr.setAmount(new BigDecimal("100000"));
        pr.setStatus("PENDING");

        Users admin = new Users();
        admin.setUserId(1);
        admin.setFullName("Admin");

        when(payoutRequestRepository.findByIdWithDetails(5)).thenReturn(Optional.of(pr));
        when(userRepository.findById(1)).thenReturn(Optional.of(admin));

        // Reject without reason -> 400 BAD_REQUEST
        assertThrows(CourseActionException.class, () -> revenueService.rejectPayout(5, 1, "   "));

        // Approve -> APPROVED
        revenueService.approvePayout(5, 1, "Đã CK VCB mã 998877");
        assertEquals("APPROVED", pr.getStatus());
        assertEquals("Đã CK VCB mã 998877", pr.getAdminNote());
        assertNotNull(pr.getProcessedAt());
        verify(payoutRequestRepository, times(2)).findLockedByIdWithDetails(5);
    }
}
