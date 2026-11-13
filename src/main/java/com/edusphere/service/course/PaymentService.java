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
import java.time.Instant;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.Map;
import java.util.Objects;
import java.util.concurrent.ThreadLocalRandom;

/**
 * Dịch vụ xử lý thanh toán khóa học qua cổng PayOS và kích hoạt ghi danh (Enrollment).
 */
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

    /**
     * Bước 1: Chuẩn bị đơn hàng thanh toán cho học viên.
     * - Kiểm tra khóa học hợp lệ, học viên chưa mua và không phải là giảng viên sở hữu khóa học.
     * - Tái sử dụng đơn PENDING/INITIATED nếu cùng mức giá; nếu khóa học đã đổi giá thì tự động hủy đơn cũ và tạo đơn mới.
     */
    @Transactional
    public Checkout prepare(Integer courseId, Integer studentId) {
        Course course = courses.findLockedById(courseId)
                .orElseThrow(() -> error(HttpStatus.NOT_FOUND, "Không tìm thấy khóa học."));

        if (!isOnSale(course))
            throw error(HttpStatus.CONFLICT, "Khóa học này hiện chưa mở bán.");
        if (course.getPrice() == null || course.getPrice().signum() <= 0)
            throw error(HttpStatus.CONFLICT, "Khóa học này miễn phí, không cần thanh toán.");
        if (!"VND".equals(course.getCurrency()))
            throw error(HttpStatus.CONFLICT, "PayOS chỉ hỗ trợ thanh toán VND.");
        if (course.getInstructor() != null && Objects.equals(course.getInstructor().getUserId(), studentId))
            throw error(HttpStatus.CONFLICT, "Bạn là giảng viên của khóa học này, không cần thanh toán.");
        if (enrollments.findByStudent_UserIdAndCourse_CourseId(studentId, courseId)
                .filter(e -> !"DROPPED".equals(e.getStatus())).isPresent())
            throw error(HttpStatus.CONFLICT, "Bạn đã ghi danh khóa học này.");

        long amount = amount(course.getPrice());

        // Nếu có đơn PENDING cũ: cùng giá thì dùng lại link PayOS, khác giá thì hủy đơn cũ để tạo đơn mới
        Payment pending = payments.findFirstByStudent_UserIdAndCourse_CourseIdAndStatusOrderByCreatedAtDesc(
                studentId, courseId, "PENDING").orElse(null);
        if (pending != null) {
            // Dùng lại khi cùng giá và mã QR còn hạn ít nhất 1 phút; hết hạn thì tạo đơn mới
            boolean stillValid = pending.getExpiresAt() == null
                    || pending.getExpiresAt().isAfter(LocalDateTime.now().plusMinutes(1));
            if (pending.getCheckoutUrl() != null && stillValid && pending.getAmount().compareTo(course.getPrice()) == 0) {
                return new Checkout(pending.getPaymentId(), Long.parseLong(pending.getRequestKey()), amount,
                        pending.getCheckoutUrl(), pending.getQrCode() != null);
            }
            pending.setStatus("CANCELLED");
            payments.saveAndFlush(pending);
        }

        // Nếu có đơn INITIATED cũ: cùng giá thì dùng lại mã đơn, khác giá thì hủy đơn cũ để tạo đơn mới
        Payment initiating = payments.findFirstByStudent_UserIdAndCourse_CourseIdAndStatusOrderByCreatedAtDesc(
                studentId, courseId, "INITIATED").orElse(null);
        if (initiating != null) {
            if (initiating.getAmount().compareTo(course.getPrice()) == 0) {
                return new Checkout(initiating.getPaymentId(), Long.parseLong(initiating.getRequestKey()), amount, null, false);
            }
            initiating.setStatus("CANCELLED");
            payments.saveAndFlush(initiating);
        }

        // Tạo đơn thanh toán mới
        Payment payment = new Payment();
        payment.setStudent(users.getReferenceById(studentId));
        payment.setCourse(course);
        payment.setRequestKey(Long.toString(System.currentTimeMillis() * 1000
                + ThreadLocalRandom.current().nextInt(1000)));
        payment.setAmount(course.getPrice());
        payment = payments.saveAndFlush(payment);
        return new Checkout(payment.getPaymentId(), Long.parseLong(payment.getRequestKey()), amount, null, false);
    }

    /**
     * Bước 2a: Lưu đường dẫn thanh toán (checkoutUrl) sau khi tạo link trên PayOS thành công,
     * chuyển trạng thái đơn từ INITIATED sang PENDING.
     */
    @Transactional
    public void markPending(Integer paymentId, CreatePaymentLinkResponse link) {
        Payment payment = locked(paymentId);
        if (link.getOrderCode() == null || link.getOrderCode() != Long.parseLong(payment.getRequestKey())
                || link.getAmount() == null || link.getAmount() != amount(payment.getAmount()))
            throw error(HttpStatus.BAD_GATEWAY, "Thông tin PayOS không khớp với đơn hàng.");
        payment.setProviderTransactionId(link.getPaymentLinkId());
        payment.setCheckoutUrl(link.getCheckoutUrl());
        payment.setQrCode(trimTo(link.getQrCode(), 1000));
        payment.setBankBin(trimTo(link.getBin(), 20));
        payment.setAccountNumber(trimTo(link.getAccountNumber(), 50));
        payment.setAccountName(trimTo(link.getAccountName(), 150));
        payment.setTransferNote(trimTo(link.getDescription(), 100));
        if (link.getExpiredAt() != null && link.getExpiredAt() > 0) {
            payment.setExpiresAt(LocalDateTime.ofInstant(Instant.ofEpochSecond(link.getExpiredAt()), ZoneId.systemDefault()));
        }
        if ("INITIATED".equals(payment.getStatus())) payment.setStatus("PENDING");
    }

    /**
     * Bước 2b: Khôi phục thông tin link PayOS nếu lần gọi tạo link trước đó bị đứt mạng giữa chừng.
     */
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

    /**
     * Bước 3a: Đối soát trạng thái đơn hàng khi học viên từ trang PayOS quay về lại hệ thống (/payments/result).
     */
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

    /**
     * Kiểm tra quyền sở hữu giao dịch của học viên trước khi hiển thị trang kết quả thanh toán.
     */
    @Transactional(readOnly = true)
    public void verifyOwner(long orderCode, Integer studentId) {
        Payment payment = payments.findByRequestKey(Long.toString(orderCode))
                .orElseThrow(() -> error(HttpStatus.NOT_FOUND, "Không tìm thấy giao dịch."));
        if (!payment.getStudent().getUserId().equals(studentId))
            throw error(HttpStatus.NOT_FOUND, "Không tìm thấy giao dịch.");
    }

    /**
     * Bước 3b: Xử lý thông báo Webhook tự động từ PayOS gửi về khi học viên chuyển khoản thành công.
     */
    @Transactional
    public void applyVerifiedWebhook(WebhookData data) {
        if (data == null || data.getOrderCode() == null || data.getOrderCode() < 1) return;
        Payment known = payments.findByRequestKey(Long.toString(data.getOrderCode())).orElse(null);
        if (known == null) return; // Bỏ qua gói tin test mẫu khi đăng ký webhook trên PayOS
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

    /**
     * Hoàn tất đơn thanh toán (chuyển sang SUCCEEDED) và kích hoạt quyền học (Enrollment ACTIVE) cho học viên.
     */
    private void complete(Payment payment) {
        if ("SUCCEEDED".equals(payment.getStatus())) return;
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

    /** Tìm và khóa bản ghi Payment theo ID. */
    private Payment locked(Integer id) {
        return payments.findLockedById(id)
                .orElseThrow(() -> error(HttpStatus.NOT_FOUND, "Không tìm thấy giao dịch."));
    }

    /** Tìm và khóa bản ghi Payment theo mã đơn hàng (orderCode). */
    private Payment lockedByOrderCode(long orderCode) {
        return payments.findLockedByRequestKey(Long.toString(orderCode))
                .orElseThrow(() -> error(HttpStatus.NOT_FOUND, "Không tìm thấy giao dịch."));
    }

    /** Chuyển đổi giá tiền BigDecimal sang số nguyên VND cho PayOS. */
    /**
     * Khóa học đang có bản công khai cho học viên: đã xuất bản, hoặc đã từng xuất bản và đang
     * được giảng viên cập nhật/chờ duyệt lại. Khớp với quy tắc hiển thị của CourseDiscoveryService.
     */
    static boolean isOnSale(Course course) {
        String status = course.getStatus();
        if ("PUBLISHED".equals(status)) return true;
        return ("UPDATING".equals(status) || "SUBMITTED".equals(status)) && course.getPublishedAt() != null;
    }

    private long amount(BigDecimal price) {
        try {
            return price.longValueExact();
        } catch (ArithmeticException ex) {
            throw error(HttpStatus.CONFLICT, "Học phí VND phải là số nguyên hợp lệ.");
        }
    }

    /** Tạo ngoại lệ nghiệp vụ với mã HTTP tương ứng. */
    private CourseActionException error(HttpStatus status, String message) {
        return new CourseActionException(status, message);
    }

    /**
     * Dữ liệu cho trang quét mã QR trong EduSphere. Chỉ chủ đơn hàng mới đọc được.
     */
    @Transactional(readOnly = true)
    public CheckoutView getCheckoutView(long orderCode, Integer studentId) {
        Payment payment = payments.findByRequestKey(Long.toString(orderCode))
                .filter(p -> p.getStudent().getUserId().equals(studentId))
                .orElseThrow(() -> error(HttpStatus.NOT_FOUND, "Không tìm thấy giao dịch."));
        Course course = payment.getCourse();
        String instructor = course.getInstructor() != null ? course.getInstructor().getFullName() : null;
        Long expiresAtMillis = payment.getExpiresAt() == null ? null
                : payment.getExpiresAt().atZone(ZoneId.systemDefault()).toInstant().toEpochMilli();
        return new CheckoutView(orderCode, payment.getStatus(), amount(payment.getAmount()),
                course.getCourseId(), course.getTitle(), course.getThumbnailUrl(), instructor,
                payment.getQrCode(), bankName(payment.getBankBin()), payment.getAccountNumber(),
                payment.getAccountName(), payment.getTransferNote(), expiresAtMillis, payment.getCheckoutUrl());
    }

    /** Trạng thái hiện tại của đơn trong cơ sở dữ liệu (đã kiểm tra chủ đơn). */
    @Transactional(readOnly = true)
    public String statusOf(long orderCode, Integer studentId) {
        return payments.findByRequestKey(Long.toString(orderCode))
                .filter(p -> p.getStudent().getUserId().equals(studentId))
                .map(Payment::getStatus)
                .orElseThrow(() -> error(HttpStatus.NOT_FOUND, "Không tìm thấy giao dịch."));
    }

    // Mã BIN ngân hàng theo chuẩn VietQR (Napas) của các ngân hàng phổ biến
    private static final Map<String, String> BANK_NAMES = Map.ofEntries(
            Map.entry("970422", "MB Bank"), Map.entry("970436", "Vietcombank"),
            Map.entry("970415", "VietinBank"), Map.entry("970418", "BIDV"),
            Map.entry("970405", "Agribank"), Map.entry("970407", "Techcombank"),
            Map.entry("970416", "ACB"), Map.entry("970432", "VPBank"),
            Map.entry("970423", "TPBank"), Map.entry("970403", "Sacombank"),
            Map.entry("970437", "HDBank"), Map.entry("970448", "OCB"),
            Map.entry("970441", "VIB"), Map.entry("970443", "SHB"),
            Map.entry("970426", "MSB"));

    static String bankName(String bin) {
        if (bin == null || bin.isBlank()) return null;
        return BANK_NAMES.getOrDefault(bin, "Ngân hàng (mã " + bin + ")");
    }

    private static String trimTo(String value, int max) {
        if (value == null) return null;
        String v = value.trim();
        return v.length() > max ? v.substring(0, max) : v;
    }

    public record CheckoutView(long orderCode, String status, long amount,
                               Integer courseId, String courseTitle, String courseThumbnail, String instructorName,
                               String qrCode, String bankName, String accountNumber, String accountName,
                               String transferNote, Long expiresAtMillis, String payosUrl) {
        public long getOrderCode() { return orderCode; }
        public String getStatus() { return status; }
        public long getAmount() { return amount; }
        public Integer getCourseId() { return courseId; }
        public String getCourseTitle() { return courseTitle; }
        public String getCourseThumbnail() { return courseThumbnail; }
        public String getInstructorName() { return instructorName; }
        public String getQrCode() { return qrCode; }
        public String getBankName() { return bankName; }
        public String getAccountNumber() { return accountNumber; }
        public String getAccountName() { return accountName; }
        public String getTransferNote() { return transferNote; }
        public Long getExpiresAtMillis() { return expiresAtMillis; }
        public String getPayosUrl() { return payosUrl; }
    }

    public record Checkout(Integer paymentId, long orderCode, long amount, String checkoutUrl, boolean hasQr) {}
    public record Result(Integer courseId, String status) {}
}
