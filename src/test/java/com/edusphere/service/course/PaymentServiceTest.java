package com.edusphere.service.course;

import com.edusphere.entity.account.Users;
import com.edusphere.entity.course.Course;
import com.edusphere.entity.course.Enrollment;
import com.edusphere.entity.course.Payment;
import com.edusphere.repository.account.UserRepository;
import com.edusphere.repository.course.CourseRepository;
import com.edusphere.repository.course.EnrollmentRepository;
import com.edusphere.repository.course.PaymentRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import vn.payos.model.v2.paymentRequests.PaymentLink;
import vn.payos.model.v2.paymentRequests.PaymentLinkStatus;
import vn.payos.model.webhooks.WebhookData;

import java.math.BigDecimal;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

class PaymentServiceTest {
    private final PaymentRepository payments = mock(PaymentRepository.class);
    private final CourseRepository courses = mock(CourseRepository.class);
    private final EnrollmentRepository enrollments = mock(EnrollmentRepository.class);
    private final UserRepository users = mock(UserRepository.class);
    private final PaymentService service = new PaymentService(payments, courses, enrollments, users);
    private Payment payment;

    @BeforeEach
    void setup() {
        Users student = new Users();
        student.setUserId(7);
        Course course = new Course();
        course.setCourseId(42);
        course.setStatus("PUBLISHED");
        course.setPrice(new BigDecimal("199000"));
        course.setCurrency("VND");
        payment = new Payment();
        payment.setPaymentId(13);
        payment.setStudent(student);
        payment.setCourse(course);
        payment.setAmount(course.getPrice());
        payment.setRequestKey("1770000000013");
        payment.setProviderTransactionId("payos-link-13");
        payment.setStatus("PENDING");
        when(payments.findLockedById(13)).thenReturn(Optional.of(payment));
        when(payments.findByRequestKey("1770000000013")).thenReturn(Optional.of(payment));
        when(payments.findLockedByRequestKey("1770000000013")).thenReturn(Optional.of(payment));
        when(courses.findLockedById(42)).thenReturn(Optional.of(course));
    }

    @Test
    void forgedReturnCannotGrantAccess() {
        PaymentLink link = new PaymentLink();
        link.setOrderCode(1770000000013L);
        link.setId("another-link");
        link.setAmount(199000L);
        link.setAmountPaid(199000L);
        link.setStatus(PaymentLinkStatus.PAID);

        assertThrows(CourseActionException.class, () -> service.reconcile(1770000000013L, 7, link));
        verifyNoInteractions(enrollments);
    }

    @Test
    void paidStatusFromPayOsGrantsAccessOnReturn() {
        when(enrollments.findByStudent_UserIdAndCourse_CourseId(7, 42)).thenReturn(Optional.empty());
        PaymentLink link = paymentLink(PaymentLinkStatus.PAID, 199000L);

        PaymentService.Result result = service.reconcile(1770000000013L, 7, link);

        assertEquals("SUCCEEDED", result.status());
        assertNotNull(payment.getCompletedAt());
        verify(enrollments).save(argThat(e -> e.getPaymentId() == 13
                && e.getCourse().getCourseId() == 42));
    }

    @Test
    void pendingOrUnderpaidStatusCannotGrantAccessOnReturn() {
        PaymentService.Result pending = service.reconcile(1770000000013L, 7,
                paymentLink(PaymentLinkStatus.PENDING, 0L));
        PaymentService.Result underpaid = service.reconcile(1770000000013L, 7,
                paymentLink(PaymentLinkStatus.PAID, 1000L));

        assertEquals("PENDING", pending.status());
        assertEquals("PENDING", underpaid.status());
        verifyNoInteractions(enrollments);
    }

    @Test
    void verifiedWebhookWithWrongAmountCannotGrantAccess() {
        WebhookData data = webhook(1000L);
        assertThrows(CourseActionException.class, () -> service.applyVerifiedWebhook(data));
        verifyNoInteractions(enrollments);
    }

    @Test
    void verifiedWebhookGrantsAccessOnlyOnce() {
        when(enrollments.findByStudent_UserIdAndCourse_CourseId(7, 42)).thenReturn(Optional.empty());
        WebhookData data = webhook(199000L);

        service.applyVerifiedWebhook(data);
        service.applyVerifiedWebhook(data);

        assertEquals("SUCCEEDED", payment.getStatus());
        assertNotNull(payment.getCompletedAt());
        verify(enrollments, times(1)).save(argThat(e -> e.getPaymentId() == 13
                && e.getCourse().getCourseId() == 42));
    }

    @Test
    void signedWebhookCanRecoverAnOrderWhoseCreateResponseWasLost() {
        payment.setProviderTransactionId(null);
        payment.setStatus("INITIATED");
        when(enrollments.findByStudent_UserIdAndCourse_CourseId(7, 42)).thenReturn(Optional.empty());

        service.applyVerifiedWebhook(webhook(199000L));

        assertEquals("payos-link-13", payment.getProviderTransactionId());
        assertEquals("SUCCEEDED", payment.getStatus());
        verify(enrollments).save(any());
    }

    @Test
    void checkoutRetryUsesTheSameOrderCode() {
        payment.setStatus("INITIATED");
        when(payments.findFirstByStudent_UserIdAndCourse_CourseIdAndStatusOrderByCreatedAtDesc(
                7, 42, "INITIATED")).thenReturn(Optional.of(payment));

        PaymentService.Checkout checkout = service.prepare(42, 7);

        assertEquals(1770000000013L, checkout.orderCode());
        verify(payments, never()).saveAndFlush(any());
    }

    @Test
    void anotherStudentCannotInspectPayment() {
        when(payments.findByRequestKey("1770000000013")).thenReturn(Optional.of(payment));
        assertThrows(CourseActionException.class, () -> service.verifyOwner(1770000000013L, 8));
    }

    private WebhookData webhook(long amount) {
        WebhookData data = new WebhookData();
        data.setOrderCode(1770000000013L);
        data.setAmount(amount);
        data.setCurrency("VND");
        data.setPaymentLinkId("payos-link-13");
        data.setCode("00");
        return data;
    }

    private PaymentLink paymentLink(PaymentLinkStatus status, long amountPaid) {
        PaymentLink link = new PaymentLink();
        link.setOrderCode(1770000000013L);
        link.setId("payos-link-13");
        link.setAmount(199000L);
        link.setAmountPaid(amountPaid);
        link.setStatus(status);
        return link;
    }
}
