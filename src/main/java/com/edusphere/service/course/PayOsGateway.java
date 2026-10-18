package com.edusphere.service.course;

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
import java.util.Locale;

@Service
public class PayOsGateway {
    private final String clientId;
    private final String apiKey;
    private final String checksumKey;
    private final String baseUrl;

    public PayOsGateway(@Value("${PAYOS_CLIENT_ID:}") String clientId,
                        @Value("${PAYOS_API_KEY:}") String apiKey,
                        @Value("${PAYOS_CHECKSUM_KEY:}") String checksumKey,
                        @Value("${app.base-url}") String baseUrl) {
        this.clientId = clientId;
        this.apiKey = apiKey;
        this.checksumKey = checksumKey;
        this.baseUrl = baseUrl.replaceAll("/+$", "");
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
            throw new CourseActionException(HttpStatus.BAD_GATEWAY, "Không kiểm tra được trạng thái thanh toán.");
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
