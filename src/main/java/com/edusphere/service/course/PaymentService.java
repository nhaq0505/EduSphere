package com.edusphere.service.course;

import com.edusphere.entity.course.Course;
import com.edusphere.entity.course.Enrollment;
import com.edusphere.entity.course.Payment;
import com.edusphere.repository.account.UserRepository;
import com.edusphere.repository.course.CourseRepository;
import com.edusphere.repository.course.EnrollmentRepository;
import com.edusphere.repository.course.PaymentRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.payos.model.v2.paymentRequests.CreatePaymentLinkResponse;
import vn.payos.model.v2.paymentRequests.PaymentLink;
import vn.payos.model.v2.paymentRequests.PaymentLinkStatus;
import vn.payos.model.webhooks.WebhookData;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.concurrent.ThreadLocalRandom;

@Service
public class PaymentService {
    private final PaymentRepository payments;
    private final CourseRepository courses;
    private final EnrollmentRepository enrollments;
    private final UserRepository users;

    public PaymentService(PaymentRepository payments, CourseRepository courses,
                          EnrollmentRepository enrollments, UserRepository users) {
        this.payments = payments;
        this.courses = courses;
        this.enrollments = enrollments;
        this.users = users;
    }

    @Transactional
    public Checkout prepare(Integer courseId, Integer studentId) {
        Course course = courses.findLockedById(courseId)
                .orElseThrow(() -> error(HttpStatus.NOT_FOUND, "Không tìm thấy khóa học."));
        if (!"PUBLISHED".equals(course.getStatus()) || course.getPrice().signum() <= 0)
            throw error(HttpStatus.CONFLICT, "Khóa học này không cần thanh toán.");
        if (!"VND".equals(course.getCurrency()))
            throw error(HttpStatus.CONFLICT, "PayOS chỉ hỗ trợ thanh toán VND.");
        long amount = amount(course.getPrice());
        if (enrollments.findByStudent_UserIdAndCourse_CourseId(studentId, courseId)
                .filter(e -> !"DROPPED".equals(e.getStatus())).isPresent())
            throw error(HttpStatus.CONFLICT, "Bạn đã ghi danh khóa học này.");

        Payment pending = payments.findFirstByStudent_UserIdAndCourse_CourseIdAndStatusOrderByCreatedAtDesc(
                studentId, courseId, "PENDING").orElse(null);
        if (pending != null && pending.getCheckoutUrl() != null
                && pending.getAmount().compareTo(course.getPrice()) == 0)
            return new Checkout(pending.getPaymentId(), Long.parseLong(pending.getRequestKey()), amount, pending.getCheckoutUrl());

        Payment initiating = payments.findFirstByStudent_UserIdAndCourse_CourseIdAndStatusOrderByCreatedAtDesc(
                studentId, courseId, "INITIATED").orElse(null);
        if (initiating != null) {
            if (initiating.getAmount().compareTo(course.getPrice()) != 0)
                throw error(HttpStatus.CONFLICT, "Học phí đã thay đổi. Vui lòng liên hệ quản trị viên.");
            return new Checkout(initiating.getPaymentId(), Long.parseLong(initiating.getRequestKey()), amount, null);
        }

        Payment payment = new Payment();
        payment.setStudent(users.getReferenceById(studentId));
        payment.setCourse(course);
        // Numeric, channel-wide order code; the database unique constraint prevents reuse.
        payment.setRequestKey(Long.toString(System.currentTimeMillis() * 1000
                + ThreadLocalRandom.current().nextInt(1000)));
        payment.setAmount(course.getPrice());
        payment = payments.saveAndFlush(payment);
        return new Checkout(payment.getPaymentId(), Long.parseLong(payment.getRequestKey()), amount, null);
    }

    @Transactional
    public void markPending(Integer paymentId, CreatePaymentLinkResponse link) {
        Payment payment = locked(paymentId);
        if (link.getOrderCode() == null || link.getOrderCode() != Long.parseLong(payment.getRequestKey())
                || link.getAmount() == null || link.getAmount() != amount(payment.getAmount()))
            throw error(HttpStatus.BAD_GATEWAY, "Thông tin PayOS không khớp với đơn hàng.");
        payment.setProviderTransactionId(link.getPaymentLinkId());
        payment.setCheckoutUrl(link.getCheckoutUrl());
        if ("INITIATED".equals(payment.getStatus())) payment.setStatus("PENDING");
    }

    @Transactional
    public void markRecovered(Integer paymentId, PaymentLink link) {
        Payment payment = locked(paymentId);
        if (link == null || link.getOrderCode() == null
                || link.getOrderCode() != Long.parseLong(payment.getRequestKey())
                || link.getAmount() == null || link.getAmount() != amount(payment.getAmount())
                || link.getId() == null || !link.getId().matches("[A-Za-z0-9]{1,255}"))
            throw error(HttpStatus.BAD_GATEWAY, "Thông tin PayOS không khớp với đơn hàng.");
        payment.setProviderTransactionId(link.getId());
        payment.setCheckoutUrl("https://pay.payos.vn/web/" + link.getId());
        if ("INITIATED".equals(payment.getStatus())) payment.setStatus("PENDING");
    }

    @Transactional
    public Result reconcile(long orderCode, Integer studentId, PaymentLink link) {
        Payment owner = payments.findByRequestKey(Long.toString(orderCode))
                .orElseThrow(() -> error(HttpStatus.NOT_FOUND, "Không tìm thấy giao dịch."));
        if (!owner.getStudent().getUserId().equals(studentId))
            throw error(HttpStatus.NOT_FOUND, "Không tìm thấy giao dịch.");
        courses.findLockedById(owner.getCourse().getCourseId()).orElseThrow();
        Payment payment = lockedByOrderCode(orderCode);
        if (!payment.getStudent().getUserId().equals(studentId))
            throw error(HttpStatus.NOT_FOUND, "Không tìm thấy giao dịch.");
        if (link == null || link.getOrderCode() == null || link.getOrderCode() != orderCode
                || link.getId() == null || (payment.getProviderTransactionId() != null
                && !link.getId().equals(payment.getProviderTransactionId()))
                || link.getAmount() == null || link.getAmount() != amount(payment.getAmount()))
            throw error(HttpStatus.BAD_GATEWAY, "Trạng thái PayOS không khớp với đơn hàng.");
        if (payment.getProviderTransactionId() == null) payment.setProviderTransactionId(link.getId());
        if (link.getStatus() == PaymentLinkStatus.PAID
                && link.getAmountPaid() != null && link.getAmountPaid() == amount(payment.getAmount())) {
            complete(payment);
        } else if (!"SUCCEEDED".equals(payment.getStatus())
                && link.getStatus() == PaymentLinkStatus.CANCELLED) {
            payment.setStatus("CANCELLED");
        } else if (!"SUCCEEDED".equals(payment.getStatus())
                && (link.getStatus() == PaymentLinkStatus.EXPIRED || link.getStatus() == PaymentLinkStatus.FAILED)) {
            payment.setStatus("FAILED");
        }
        return new Result(payment.getCourse().getCourseId(), payment.getStatus());
    }

    @Transactional(readOnly = true)
    public void verifyOwner(long orderCode, Integer studentId) {
        Payment payment = payments.findByRequestKey(Long.toString(orderCode))
                .orElseThrow(() -> error(HttpStatus.NOT_FOUND, "Không tìm thấy giao dịch."));
        if (!payment.getStudent().getUserId().equals(studentId))
            throw error(HttpStatus.NOT_FOUND, "Không tìm thấy giao dịch.");
    }

    @Transactional
    public void applyVerifiedWebhook(WebhookData data) {
        if (data == null || data.getOrderCode() == null || data.getOrderCode() < 1) return;
        Payment known = payments.findByRequestKey(Long.toString(data.getOrderCode())).orElse(null);
        if (known == null) return; // PayOS sends a sample event when a webhook is registered.
        courses.findLockedById(known.getCourse().getCourseId()).orElseThrow();
        Payment payment = lockedByOrderCode(data.getOrderCode());
        if (!"00".equals(data.getCode()) || data.getAmount() == null
                || data.getAmount() != amount(payment.getAmount())
                || !"VND".equals(data.getCurrency())
                || data.getPaymentLinkId() == null
                || (payment.getProviderTransactionId() != null
                && !data.getPaymentLinkId().equals(payment.getProviderTransactionId())))
            throw error(HttpStatus.BAD_REQUEST, "Dữ liệu thanh toán không khớp với đơn hàng.");
        if (payment.getProviderTransactionId() == null) payment.setProviderTransactionId(data.getPaymentLinkId());
        complete(payment);
    }

    private void complete(Payment payment) {
        if ("SUCCEEDED".equals(payment.getStatus())) return;
        // The caller has locked the course before the payment to serialize enrollment writes.
        Enrollment enrollment = enrollments.findByStudent_UserIdAndCourse_CourseId(
                payment.getStudent().getUserId(), payment.getCourse().getCourseId()).orElse(null);
        if (enrollment == null) {
            enrollment = new Enrollment();
            enrollment.setStudent(payment.getStudent());
            enrollment.setCourse(payment.getCourse());
        } else if ("DROPPED".equals(enrollment.getStatus())) {
            enrollment.setStatus("ACTIVE");
            enrollment.setDroppedAt(null);
            enrollment.setCompletedAt(null);
            enrollment.setEnrolledAt(LocalDateTime.now());
        }
        enrollment.setPaymentId(payment.getPaymentId());
        enrollments.save(enrollment);
        payment.setStatus("SUCCEEDED");
        payment.setCompletedAt(LocalDateTime.now());
    }

    private Payment locked(Integer id) {
        return payments.findLockedById(id)
                .orElseThrow(() -> error(HttpStatus.NOT_FOUND, "Không tìm thấy giao dịch."));
    }

    private Payment lockedByOrderCode(long orderCode) {
        return payments.findLockedByRequestKey(Long.toString(orderCode))
                .orElseThrow(() -> error(HttpStatus.NOT_FOUND, "Không tìm thấy giao dịch."));
    }

    private long amount(BigDecimal price) {
        try {
            return price.longValueExact();
        } catch (ArithmeticException ex) {
            throw error(HttpStatus.CONFLICT, "Học phí VND phải là số nguyên hợp lệ.");
        }
    }

    private CourseActionException error(HttpStatus status, String message) {
        return new CourseActionException(status, message);
    }

    public record Checkout(Integer paymentId, long orderCode, long amount, String checkoutUrl) {}
    public record Result(Integer courseId, String status) {}
}
