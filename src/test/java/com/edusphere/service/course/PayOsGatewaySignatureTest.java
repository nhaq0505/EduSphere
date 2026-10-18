package com.edusphere.service.course;

import org.junit.jupiter.api.Test;
import vn.payos.model.webhooks.Webhook;
import vn.payos.model.webhooks.WebhookData;

import static org.junit.jupiter.api.Assertions.*;

class PayOsGatewaySignatureTest {
    // Public sample from https://payos.vn/docs/tich-hop-webhook/kiem-tra-du-lieu-voi-signature/
    private static final String CHECKSUM_KEY = "1a54716c8f0efb2744fb28b6e38b25da7f67a925d98bc1c18bd8faaecadd7675";
    private static final String SIGNATURE = "412e915d2871504ed31be63c8f62a149a4410d34c4c42affc9006ef9917eaa03";

    @Test
    void officialSignedWebhookCanBeVerified() {
        PayOsGateway gateway = new PayOsGateway("sample-client", "sample-api-key", CHECKSUM_KEY, "http://localhost");
        Webhook webhook = sample();
        assertEquals(123L, gateway.verify(webhook).getOrderCode());
    }

    @Test
    void tamperedAmountIsRejected() {
        PayOsGateway gateway = new PayOsGateway("sample-client", "sample-api-key", CHECKSUM_KEY, "http://localhost");
        Webhook webhook = sample();
        webhook.getData().setAmount(1L);
        assertThrows(RuntimeException.class, () -> gateway.verify(webhook));
    }

    private Webhook sample() {
        WebhookData data = new WebhookData();
        data.setOrderCode(123L);
        data.setAmount(3000L);
        data.setDescription("VQRIO123");
        data.setAccountNumber("12345678");
        data.setReference("TF230204212323");
        data.setTransactionDateTime("2023-02-04 18:25:00");
        data.setCurrency("VND");
        data.setPaymentLinkId("124c33293c43417ab7879e14c8d9eb18");
        data.setCode("00");
        data.setDesc("Thành công");
        data.setCounterAccountBankId("");
        data.setCounterAccountBankName("");
        data.setCounterAccountName("");
        data.setCounterAccountNumber("");
        data.setVirtualAccountName("");
        data.setVirtualAccountNumber("");
        Webhook webhook = new Webhook();
        webhook.setCode("00");
        webhook.setDesc("success");
        webhook.setSuccess(true);
        webhook.setData(data);
        webhook.setSignature(SIGNATURE);
        return webhook;
    }
}
