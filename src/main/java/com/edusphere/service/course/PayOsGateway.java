package com.edusphere.service.course;

import jakarta.annotation.PostConstruct;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import vn.payos.PayOS;
import vn.payos.exception.PayOSException;
import vn.payos.model.v2.paymentRequests.CreatePaymentLinkRequest;
import vn.payos.model.v2.paymentRequests.CreatePaymentLinkResponse;
import vn.payos.model.v2.paymentRequests.PaymentLink;
import vn.payos.model.webhooks.Webhook;
import vn.payos.model.webhooks.WebhookData;

import java.net.URI;
import java.time.Duration;
import java.time.Instant;
import java.util.Locale;

@Service
@Slf4j
public class PayOsGateway {
    /** Thời gian hiệu lực của mỗi mã QR thanh toán. */
    public static final Duration LINK_LIFETIME = Duration.ofMinutes(15);

    private final String clientId;
    private final String apiKey;
    private final String checksumKey;
    private final String baseUrl;

    public PayOsGateway(@Value("${payos.client-id}") String clientId,
                        @Value("${payos.api-key}") String apiKey,
                        @Value("${payos.checksum-key}") String checksumKey,
                        @Value("${app.base-url}") String baseUrl) {
        this.clientId = clientId;
        this.apiKey = apiKey;
        this.checksumKey = checksumKey;
        this.baseUrl = baseUrl.replaceAll("/+$", "");
    }

    @PostConstruct
    void reportConfiguration() {
        if (isConfigured()) {
            log.info("PayOS credentials are configured");
        } else {
            log.warn("PayOS is disabled. Set PAYOS_CLIENT_ID, PAYOS_API_KEY, and PAYOS_CHECKSUM_KEY in the service environment");
        }
        if (!baseUrl.toLowerCase(Locale.ROOT).startsWith("https://")) {
            log.warn("PayOS return and cancel URLs are not using HTTPS: {}", baseUrl);
        }
    }

    public CreatePaymentLinkResponse create(long orderCode, long amount) {
        PayOS client = client();
        try {
            String description = Long.toString(orderCode, 36).toUpperCase(Locale.ROOT);
            if (description.length() > 9) description = description.substring(description.length() - 9);
            CreatePaymentLinkRequest request = CreatePaymentLinkRequest.builder()
                    .orderCode(orderCode)
                    .amount(amount)
                    .description(description)
                    .returnUrl(baseUrl + "/payments/result?orderCode=" + orderCode)
                    .cancelUrl(baseUrl + "/payments/result?orderCode=" + orderCode)
                    .expiredAt(Instant.now().plus(LINK_LIFETIME).getEpochSecond())
                    .build();
            CreatePaymentLinkResponse link = client.paymentRequests().create(request);
            if (link.getOrderCode() == null || link.getOrderCode() != orderCode
                    || link.getAmount() == null || link.getAmount() != amount
                    || !"VND".equals(link.getCurrency())
                    || link.getCheckoutUrl() == null || link.getPaymentLinkId() == null
                    || !isPayOsCheckoutUrl(link.getCheckoutUrl())) {
                throw new CourseActionException(HttpStatus.BAD_GATEWAY, "PayOS trả về link thanh toán không hợp lệ.");
            }
            return link;
        } catch (PayOSException ex) {
            log.error("PayOS could not create payment link: {}", safeMessage(ex));
            throw new CourseActionException(HttpStatus.BAD_GATEWAY, "Không tạo được link thanh toán. Vui lòng thử lại.");
        } finally {
            client.close();
        }
    }

    public PaymentLink get(long orderCode) {
        PayOS client = client();
        try {
            return client.paymentRequests().get(orderCode);
        } catch (PayOSException ex) {
            log.error("PayOS could not retrieve payment status: {}", safeMessage(ex));
            throw new CourseActionException(HttpStatus.BAD_GATEWAY, "Không kiểm tra được trạng thái thanh toán.");
        } finally {
            client.close();
        }
    }

    /** Hủy link thanh toán trên PayOS để mã QR cũ không còn nhận tiền. */
    public PaymentLink cancel(long orderCode, String reason) {
        PayOS client = client();
        try {
            return client.paymentRequests().cancel(orderCode, reason);
        } catch (PayOSException ex) {
            log.error("PayOS could not cancel payment link: {}", safeMessage(ex));
            throw new CourseActionException(HttpStatus.BAD_GATEWAY, "Không hủy được giao dịch trên PayOS. Vui lòng thử lại.");
        } finally {
            client.close();
        }
    }

    public WebhookData verify(Webhook webhook) {
        PayOS client = client();
        try {
            return client.webhooks().verify(webhook);
        } finally {
            client.close();
        }
    }

    public boolean isConfigured() {
        return !clientId.isBlank() && !apiKey.isBlank() && !checksumKey.isBlank();
    }

    private PayOS client() {
        if (!isConfigured()) {
            throw new CourseActionException(HttpStatus.SERVICE_UNAVAILABLE,
                    "Chưa cấu hình PayOS. Cần PAYOS_CLIENT_ID, PAYOS_API_KEY và PAYOS_CHECKSUM_KEY.");
        }
        return new PayOS(clientId, apiKey, checksumKey);
    }

    private String safeMessage(PayOSException exception) {
        String message = exception.getMessage();
        if (message == null || message.isBlank()) return exception.getClass().getSimpleName();
        if (clientId != null && !clientId.isBlank()) message = message.replace(clientId, "[redacted]");
        if (apiKey != null && !apiKey.isBlank()) message = message.replace(apiKey, "[redacted]");
        if (checksumKey != null && !checksumKey.isBlank()) message = message.replace(checksumKey, "[redacted]");
        return message;
    }

    private boolean isPayOsCheckoutUrl(String value) {
        try {
            URI url = URI.create(value);
            return "https".equalsIgnoreCase(url.getScheme())
                    && "pay.payos.vn".equalsIgnoreCase(url.getHost());
        } catch (IllegalArgumentException ex) {
            return false;
        }
    }
}
