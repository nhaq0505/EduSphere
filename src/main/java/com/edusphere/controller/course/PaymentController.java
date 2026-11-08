package com.edusphere.controller.course;

import com.edusphere.security.CustomUserDetails;
import com.edusphere.service.course.CourseActionException;
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

/**
 * Controller điều phối luồng thanh toán khóa học qua cổng PayOS (Checkout, Return URL và Webhook).
 */
@Controller
public class PaymentController {
    private final PaymentService payments;
    private final PayOsGateway payOs;

    public PaymentController(PaymentService payments, PayOsGateway payOs) {
        this.payments = payments;
        this.payOs = payOs;
    }

    /**
     * Khởi tạo đơn hàng thanh toán cho khóa học và chuyển hướng học viên sang trang QR của PayOS.
     */
    @PostMapping("/courses/{courseId}/checkout")
    public String checkout(@PathVariable Integer courseId, @AuthenticationPrincipal CustomUserDetails user) {
        if (!payOs.isConfigured()) throw new CourseActionException(HttpStatus.SERVICE_UNAVAILABLE,
                "Chưa cấu hình PayOS. Vui lòng liên hệ quản trị viên.");
        PaymentService.Checkout checkout = payments.prepare(courseId, user.getUserId());
        if (checkout.checkoutUrl() != null) return "redirect:" + checkout.checkoutUrl();
        CreatePaymentLinkResponse link;
        try {
            link = payOs.create(checkout.orderCode(), checkout.amount());
        } catch (RuntimeException ex) {
            // Khôi phục link nếu PayOS đã tạo đơn thành công nhưng phản hồi mạng bị ngắt
            PaymentLink existing;
            try {
                existing = payOs.get(checkout.orderCode());
            } catch (RuntimeException lookupError) {
                throw ex;
            }
            payments.markRecovered(checkout.paymentId(), existing);
            if (existing.getStatus() != PaymentLinkStatus.PENDING)
                return "redirect:/payments/result?orderCode=" + checkout.orderCode();
            return "redirect:https://pay.payos.vn/web/" + existing.getId();
        }
        payments.markPending(checkout.paymentId(), link);
        return "redirect:" + link.getCheckoutUrl();
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
