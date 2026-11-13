package com.edusphere.controller.course;

import com.edusphere.dto.course.CourseView;
import com.edusphere.entity.course.Payment;
import com.edusphere.security.CustomUserDetails;
import com.edusphere.service.course.CourseActionException;
import com.edusphere.service.course.CourseDiscoveryService;
import com.edusphere.service.course.PayOsGateway;
import com.edusphere.service.course.PaymentService;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.http.converter.HttpMessageNotReadableException;
import vn.payos.exception.PayOSException;
import vn.payos.model.v2.paymentRequests.CreatePaymentLinkResponse;
import vn.payos.model.v2.paymentRequests.PaymentLink;
import vn.payos.model.v2.paymentRequests.PaymentLinkStatus;
import vn.payos.model.webhooks.Webhook;
import vn.payos.model.webhooks.WebhookData;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.Map;

/**
 * Controller điều phối luồng thanh toán khóa học qua cổng PayOS (Checkout, Return URL và Webhook).
 */
@Controller
public class PaymentController {
    private final PaymentService payments;
    private final PayOsGateway payOs;
    private final CourseDiscoveryService courseDiscoveryService;

    public PaymentController(PaymentService payments, PayOsGateway payOs, CourseDiscoveryService courseDiscoveryService) {
        this.payments = payments;
        this.payOs = payOs;
        this.courseDiscoveryService = courseDiscoveryService;
    }

    /**
     * Khởi tạo hoặc chuyển hướng sang trang thanh toán mã QR của khóa học.
     */
    @PostMapping("/courses/{courseId}/checkout")
    public String checkout(@PathVariable Integer courseId) {
        return "redirect:/courses/" + courseId + "/payment";
    }

    /**
     * Hiển thị trang thanh toán QR đồng bộ trong hệ thống.
     */
    @GetMapping("/courses/{courseId}/payment")
    public String paymentPage(@PathVariable Integer courseId,
                              @AuthenticationPrincipal CustomUserDetails user,
                              Model model) {
        if (user == null) {
            return "redirect:/login";
        }
        if (!payOs.isConfigured()) {
            throw new CourseActionException(HttpStatus.SERVICE_UNAVAILABLE,
                    "Chưa cấu hình PayOS. Vui lòng liên hệ quản trị viên.");
        }
        CourseView course = courseDiscoveryService.findPublishedCourse(courseId)
                .orElseThrow(() -> new CourseActionException(HttpStatus.NOT_FOUND, "Không tìm thấy khóa học."));
        model.addAttribute("course", course);

        PaymentService.Checkout checkout = payments.prepare(courseId, user.getUserId());
        CreatePaymentLinkResponse link;
        try {
            link = payOs.create(checkout.orderCode(), checkout.amount());
            payments.markPending(checkout.paymentId(), link);
        } catch (RuntimeException ex) {
            PaymentLink existing;
            try {
                existing = payOs.get(checkout.orderCode());
            } catch (RuntimeException lookupError) {
                throw ex;
            }
            payments.markRecovered(checkout.paymentId(), existing);
            if (existing.getStatus() != PaymentLinkStatus.PENDING) {
                return "redirect:/payments/result?orderCode=" + checkout.orderCode();
            }
            link = CreatePaymentLinkResponse.builder()
                    .orderCode(existing.getOrderCode())
                    .amount(existing.getAmount())
                    .checkoutUrl("https://pay.payos.vn/web/" + existing.getId())
                    .paymentLinkId(existing.getId())
                    .status(existing.getStatus())
                    .build();
        }

        model.addAttribute("orderCode", checkout.orderCode());
        model.addAttribute("amount", checkout.amount());
        model.addAttribute("checkoutUrl", link.getCheckoutUrl());

        String bin = link.getBin() != null && !link.getBin().isBlank() ? link.getBin() : "970422";
        String accNo = link.getAccountNumber() != null && !link.getAccountNumber().isBlank() ? link.getAccountNumber() : "";
        String desc = link.getDescription() != null && !link.getDescription().isBlank() ? link.getDescription() : Long.toString(checkout.orderCode());
        String accName = link.getAccountName() != null && !link.getAccountName().isBlank() ? link.getAccountName() : "EDUSPHERE";

        model.addAttribute("bin", bin);
        model.addAttribute("accountNumber", accNo);
        model.addAttribute("accountName", accName);
        model.addAttribute("description", desc);
        model.addAttribute("qrCode", link.getQrCode());

        String vietQrUrl = "https://img.vietqr.io/image/" + bin + "-" + accNo + "-print.png?amount=" + checkout.amount()
                + "&addInfo=" + URLEncoder.encode(desc, StandardCharsets.UTF_8)
                + "&accountName=" + URLEncoder.encode(accName, StandardCharsets.UTF_8);
        model.addAttribute("vietQrUrl", vietQrUrl);

        return "courses/payment";
    }

    /**
     * API kiểm tra nhanh trạng thái thanh toán từ client (Polling mỗi 3 giây).
     */
    @ResponseBody
    @GetMapping("/payments/status")
    public Map<String, Object> checkStatus(@RequestParam Long orderCode,
                                           @AuthenticationPrincipal CustomUserDetails user) {
        if (user == null) {
            return Map.of("status", "UNAUTHORIZED");
        }
        try {
            Payment payment = payments.findByOrderCode(orderCode);
            if (payment != null && "COMPLETED".equals(payment.getStatus())) {
                return Map.of("status", "PAID", "courseId", payment.getCourse().getCourseId());
            }
            PaymentLink link = payOs.get(orderCode);
            if (link != null && link.getStatus() == PaymentLinkStatus.PAID) {
                PaymentService.Result res = payments.reconcile(orderCode, user.getUserId(), link);
                return Map.of("status", "PAID", "courseId", res.courseId());
            }
            return Map.of("status", link != null ? link.getStatus().name() : "PENDING");
        } catch (Exception ex) {
            return Map.of("status", "PENDING");
        }
    }

    /**
     * Đối soát trạng thái đơn hàng và hiển thị trang kết quả khi học viên từ PayOS quay về hệ thống.
     */
    @GetMapping("/payments/result")
    public String result(@RequestParam Long orderCode,
                         @AuthenticationPrincipal CustomUserDetails user, Model model) {
        payments.verifyOwner(orderCode, user.getUserId());
        PaymentService.Result result = payments.reconcile(orderCode, user.getUserId(), payOs.get(orderCode));
        model.addAttribute("paymentStatus", result.status());
        model.addAttribute("courseId", result.courseId());
        model.addAttribute("orderCode", orderCode);
        return "courses/payment-result";
    }

    /**
     * Nhận thông báo Webhook tự động từ PayOS khi giao dịch chuyển khoản hoàn tất.
     */
    @ResponseBody
    @PostMapping("/payments/payos/webhook")
    public ResponseEntity<String> webhook(@RequestBody Webhook webhook) {
        try {
            WebhookData data = payOs.verify(webhook);
            if (Boolean.TRUE.equals(webhook.getSuccess()) && "00".equals(webhook.getCode()))
                payments.applyVerifiedWebhook(data);
            return ResponseEntity.ok("OK");
        } catch (CourseActionException ex) {
            return ResponseEntity.status(ex.getStatus()).body("Payment not accepted");
        } catch (PayOSException | IllegalArgumentException ex) {
            return ResponseEntity.badRequest().body("Invalid webhook");
        } catch (RuntimeException ex) {
            return ResponseEntity.internalServerError().body("Webhook processing failed");
        }
    }

    /**
     * Trả về lỗi 400 nếu gói tin JSON gửi vào Webhook không đúng định dạng.
     */
    @ResponseBody
    @ExceptionHandler(HttpMessageNotReadableException.class)
    public ResponseEntity<String> malformedWebhook() {
        return ResponseEntity.badRequest().body("Invalid webhook");
    }

    /**
     * Hiển thị trang thông báo lỗi thân thiện khi gặp ngoại lệ nghiệp vụ trong quá trình thanh toán.
     */
    @ExceptionHandler(CourseActionException.class)
    public String paymentError(CourseActionException ex, HttpServletResponse response, Model model) {
        response.setStatus(ex.getStatus().value());
        model.addAttribute("errorMessage", ex.getMessage());
        return "courses/action-error";
    }
}
