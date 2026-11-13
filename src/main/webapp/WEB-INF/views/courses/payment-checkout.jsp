<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="cp" value="${pageContext.request.contextPath}"/>
<fmt:setLocale value="vi_VN"/>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Thanh toán khóa học — EduSphere</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <%-- home.css chứa style của navbar/footer dùng chung (hn-*) --%>
    <link rel="stylesheet" href="${cp}/assets/css/home.css">
    <style>
        .co-page { max-width: 1040px; margin: 0 auto; padding: 32px 20px 64px; }
        .co-head { margin-bottom: 22px; }
        .co-crumb { font-size: .85rem; color: #64748B; margin: 0 0 6px; }
        .co-crumb a { color: #64748B; text-decoration: none; }
        .co-crumb a:hover { color: #2563EB; }
        .co-title { font-size: 1.6rem; font-weight: 800; color: #0F172A; margin: 0; letter-spacing: -.01em; }
        .co-grid { display: grid; grid-template-columns: minmax(0, 1.05fr) minmax(0, 1fr); gap: 22px; align-items: start; }
        .co-card { background: #fff; border: 1px solid #E2E8F0; border-radius: 18px; box-shadow: 0 10px 30px rgba(15,23,42,.05); }
        .co-qr-card { padding: 26px; text-align: center; position: relative; }
        .co-status { display: inline-flex; align-items: center; gap: 8px; font-size: .85rem; font-weight: 600;
                     color: #B45309; background: #FFFBEB; border: 1px solid #FDE68A; padding: 6px 12px; border-radius: 999px; }
        .co-dot { width: 8px; height: 8px; border-radius: 50%; background: #F59E0B; animation: co-pulse 1.4s ease-in-out infinite; }
        @keyframes co-pulse { 0%,100% { opacity: 1; transform: scale(1); } 50% { opacity: .35; transform: scale(.8); } }
        .co-qr-wrap { margin: 18px auto 14px; width: min(300px, 100%); aspect-ratio: 1; padding: 14px; border-radius: 16px;
                      border: 1px solid #E2E8F0; background: #fff; position: relative; }
        .co-qr { width: 100%; height: 100%; }
        .co-qr svg, .co-qr img { width: 100%; height: 100%; display: block; }
        .co-qr-label { font-size: .78rem; color: #64748B; letter-spacing: .04em; text-transform: uppercase; font-weight: 600; }
        .co-amount { font-size: 2rem; font-weight: 800; color: #0F172A; margin: 6px 0 2px; font-variant-numeric: tabular-nums; }
        .co-expire { font-size: .9rem; color: #475569; margin: 0 0 16px; }
        .co-expire b { font-variant-numeric: tabular-nums; color: #0F172A; }
        .co-actions { display: flex; gap: 10px; justify-content: center; flex-wrap: wrap; }
        .co-btn { display: inline-flex; align-items: center; justify-content: center; gap: 6px; padding: 10px 18px; border-radius: 10px;
                  font: 700 .9rem 'Inter', sans-serif; text-decoration: none; border: 1px solid transparent; cursor: pointer; }
        .co-btn--primary { background: #2563EB; color: #fff; }
        .co-btn--primary:hover { background: #1D4ED8; }
        .co-btn--outline { background: #fff; color: #334155; border-color: #CBD5E1; }
        .co-btn--outline:hover { border-color: #94A3B8; }
        .co-btn--ghost { background: transparent; color: #DC2626; padding: 8px 10px; }
        .co-btn--ghost:hover { background: #FEF2F2; }
        .co-btn:focus-visible, .co-copy:focus-visible { outline: 2px solid #2563EB; outline-offset: 2px; }
        .co-overlay { position: absolute; inset: 0; border-radius: 16px; background: rgba(255,255,255,.95); display: flex;
                      flex-direction: column; align-items: center; justify-content: center; gap: 10px; padding: 16px; }
        .co-overlay[hidden] { display: none; }
        .co-overlay p { margin: 0; font-weight: 700; color: #0F172A; }
        .co-overlay small { color: #64748B; }
        .co-ok-icon { width: 64px; height: 64px; border-radius: 50%; background: #ECFDF5; border: 2px solid #A7F3D0; color: #059669;
                      display: flex; align-items: center; justify-content: center; font-size: 1.9rem; font-weight: 800; }
        .co-side { display: flex; flex-direction: column; gap: 18px; min-width: 0; }
        .co-section { padding: 20px 22px; }
        .co-section h2 { font-size: 1rem; font-weight: 700; color: #0F172A; margin: 0 0 14px; }
        .co-course { display: grid; grid-template-columns: 96px 1fr; gap: 14px; align-items: center; }
        .co-thumb { width: 96px; height: 64px; border-radius: 10px; object-fit: cover; background: #F1F5F9; }
        .co-course-title { font-weight: 700; color: #0F172A; margin: 0 0 4px; line-height: 1.35; overflow-wrap: anywhere; }
        .co-course-sub { font-size: .85rem; color: #64748B; margin: 0; }
        .co-total { display: flex; justify-content: space-between; align-items: baseline; border-top: 1px dashed #E2E8F0;
                    margin-top: 16px; padding-top: 14px; font-weight: 600; color: #334155; }
        .co-total strong { font-size: 1.25rem; color: #2563EB; font-variant-numeric: tabular-nums; }
        .co-rows { display: flex; flex-direction: column; gap: 2px; margin: 0; }
        .co-row { display: grid; grid-template-columns: 120px minmax(0, 1fr) auto; gap: 10px; align-items: center;
                  padding: 9px 0; border-bottom: 1px solid #F1F5F9; }
        .co-row:last-child { border-bottom: 0; }
        .co-row dt { font-size: .85rem; color: #64748B; }
        .co-row dd { margin: 0; font-weight: 600; color: #0F172A; overflow-wrap: anywhere; font-variant-numeric: tabular-nums; }
        .co-row--note dd { color: #B91C1C; }
        .co-copy { font: 600 .78rem 'Inter', sans-serif; color: #2563EB; background: #EFF6FF; border: 1px solid #DBEAFE;
                   border-radius: 8px; padding: 5px 10px; cursor: pointer; white-space: nowrap; }
        .co-copy.is-done { color: #059669; background: #ECFDF5; border-color: #A7F3D0; }
        .co-hint { font-size: .82rem; color: #64748B; margin: 10px 0 0; line-height: 1.55; }
        .co-steps { margin: 0; padding-left: 1.2em; display: flex; flex-direction: column; gap: 6px; color: #334155; font-size: .9rem; }
        .co-foot { display: flex; justify-content: space-between; align-items: center; gap: 10px; flex-wrap: wrap;
                   font-size: .85rem; color: #64748B; }
        .co-foot a { color: #2563EB; font-weight: 600; text-decoration: none; }
        .co-foot form { margin: 0; }
        @media (max-width: 860px) { .co-grid { grid-template-columns: 1fr; } }
        @media (max-width: 480px) { .co-row { grid-template-columns: 1fr auto; } .co-row dt { grid-column: 1 / -1; } .co-amount { font-size: 1.6rem; } }
        @media (prefers-reduced-motion: reduce) { .co-dot { animation: none; } }
    </style>
</head>
<body style="background:#F8FAFD;">
<jsp:include page="/WEB-INF/views/common/navbar.jsp"/>

<main class="co-page" id="checkout"
      data-order="<c:out value='${checkout.orderCode}'/>"
      data-qr="<c:out value='${checkout.qrCode}'/>"
      data-expires="<c:out value='${checkout.expiresAtMillis}'/>"
      data-status-url="${cp}/payments/<c:out value='${checkout.orderCode}'/>/status"
      data-cp="${cp}">

    <div class="co-head">
        <p class="co-crumb">
            <a href="${cp}/courses">Khóa học</a> ›
            <a href="${cp}/courses/${checkout.courseId}"><c:out value="${checkout.courseTitle}"/></a> › Thanh toán
        </p>
        <h1 class="co-title">Thanh toán khóa học</h1>
    </div>

    <div class="co-grid">
        <%-- Cột trái: mã QR --%>
        <section class="co-card co-qr-card" aria-labelledby="qr-heading">
            <h2 id="qr-heading" class="co-qr-label">Quét mã VietQR để thanh toán</h2>
            <div style="margin-top:10px">
                <span class="co-status" id="co-status" role="status"><span class="co-dot"></span>Đang chờ thanh toán</span>
            </div>

            <div class="co-qr-wrap">
                <div class="co-qr" id="co-qr" aria-label="Mã QR chuyển khoản"></div>

                <div class="co-overlay" id="co-expired" hidden>
                    <p>Mã QR đã hết hạn</p>
                    <small>Tạo mã mới để tiếp tục thanh toán.</small>
                    <form method="post" action="${cp}/courses/${checkout.courseId}/checkout">
                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                        <button class="co-btn co-btn--primary" type="submit">Tạo mã mới</button>
                    </form>
                </div>

                <div class="co-overlay" id="co-paid" hidden>
                    <div class="co-ok-icon" aria-hidden="true">&#10003;</div>
                    <p>Đã nhận thanh toán</p>
                    <small>Đang chuyển tới khóa học…</small>
                </div>
            </div>

            <div class="co-amount"><fmt:formatNumber value="${checkout.amount}" type="number" groupingUsed="true"/> ₫</div>
            <p class="co-expire" id="co-expire-line">Mã hết hạn sau <b id="co-countdown">--:--</b></p>

            <div class="co-actions">
                <a class="co-btn co-btn--outline" id="co-download" href="#" download="EduSphere-QR-${checkout.orderCode}.gif">Lưu ảnh QR</a>
                <c:if test="${not empty checkout.payosUrl}">
                    <a class="co-btn co-btn--outline" href="<c:out value='${checkout.payosUrl}'/>" rel="noopener">Mở trang PayOS</a>
                </c:if>
            </div>
        </section>

        <%-- Cột phải: đơn hàng và thông tin chuyển khoản --%>
        <div class="co-side">
            <section class="co-card co-section" aria-labelledby="order-heading">
                <h2 id="order-heading">Đơn hàng</h2>
                <div class="co-course">
                    <c:choose>
                        <c:when test="${not empty checkout.courseThumbnail}">
                            <img class="co-thumb" src="<c:out value='${checkout.courseThumbnail}'/>" alt="" width="96" height="64">
                        </c:when>
                        <c:otherwise><div class="co-thumb" aria-hidden="true"></div></c:otherwise>
                    </c:choose>
                    <div>
                        <p class="co-course-title"><c:out value="${checkout.courseTitle}"/></p>
                        <c:if test="${not empty checkout.instructorName}">
                            <p class="co-course-sub">Giảng viên: <c:out value="${checkout.instructorName}"/></p>
                        </c:if>
                    </div>
                </div>
                <div class="co-total">
                    <span>Tổng thanh toán</span>
                    <strong><fmt:formatNumber value="${checkout.amount}" type="number" groupingUsed="true"/> ₫</strong>
                </div>
            </section>

            <section class="co-card co-section" aria-labelledby="bank-heading">
                <h2 id="bank-heading">Hoặc chuyển khoản thủ công</h2>
                <dl class="co-rows">
                    <c:if test="${not empty checkout.bankName}">
                        <div class="co-row"><dt>Ngân hàng</dt><dd><c:out value="${checkout.bankName}"/></dd><span></span></div>
                    </c:if>
                    <div class="co-row"><dt>Số tài khoản</dt><dd><c:out value="${checkout.accountNumber}"/></dd>
                        <button type="button" class="co-copy" data-copy="<c:out value='${checkout.accountNumber}'/>">Sao chép</button></div>
                    <div class="co-row"><dt>Chủ tài khoản</dt><dd><c:out value="${checkout.accountName}"/></dd><span></span></div>
                    <div class="co-row"><dt>Số tiền</dt><dd><fmt:formatNumber value="${checkout.amount}" type="number" groupingUsed="true"/> ₫</dd>
                        <button type="button" class="co-copy" data-copy="<c:out value='${checkout.amount}'/>">Sao chép</button></div>
                    <div class="co-row co-row--note"><dt>Nội dung</dt><dd><c:out value="${checkout.transferNote}"/></dd>
                        <button type="button" class="co-copy" data-copy="<c:out value='${checkout.transferNote}'/>">Sao chép</button></div>
                </dl>
                <p class="co-hint">Nhập đúng <b>số tiền</b> và <b>nội dung chuyển khoản</b> để hệ thống tự xác nhận. Sai nội dung có thể khiến giao dịch không được ghi nhận tự động.</p>
            </section>

            <section class="co-card co-section" aria-labelledby="steps-heading">
                <h2 id="steps-heading">Cách thanh toán</h2>
                <ol class="co-steps">
                    <li>Mở ứng dụng ngân hàng hoặc ví điện tử có hỗ trợ VietQR.</li>
                    <li>Chọn quét mã QR và quét mã bên trái (hoặc tải ảnh QR lên ứng dụng).</li>
                    <li>Kiểm tra số tiền, nội dung rồi xác nhận chuyển khoản.</li>
                    <li>Giữ nguyên trang này: hệ thống tự ghi danh và chuyển bạn vào khóa học khi nhận được tiền.</li>
                </ol>
            </section>

            <div class="co-foot">
                <span>Mã đơn hàng: <b><c:out value="${checkout.orderCode}"/></b></span>
                <form method="post" action="${cp}/payments/${checkout.orderCode}/cancel"
                      onsubmit="return confirm('Hủy giao dịch này? Mã QR sẽ không dùng được nữa.');">
                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                    <button class="co-btn co-btn--ghost" type="submit">Hủy giao dịch</button>
                </form>
            </div>
        </div>
    </div>
</main>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>

<script src="https://cdnjs.cloudflare.com/ajax/libs/qrcode-generator/1.4.4/qrcode.min.js"></script>
<script>
(function () {
    var root = document.getElementById('checkout');
    var payload = root.dataset.qr;
    var expiresAt = parseInt(root.dataset.expires, 10);
    var statusUrl = root.dataset.statusUrl;
    var cp = root.dataset.cp;

    // 1. Vẽ mã QR từ chuỗi VietQR do PayOS trả về
    var qrBox = document.getElementById('co-qr');
    var download = document.getElementById('co-download');
    try {
        var qr = qrcode(0, 'M');
        qr.addData(payload);
        qr.make();
        qrBox.innerHTML = qr.createSvgTag(6, 0);
        download.href = qr.createDataURL(8, 16);
    } catch (e) {
        qrBox.innerHTML = '<p style="color:#B91C1C;font-size:.9rem;margin-top:40%">Không vẽ được mã QR. Hãy dùng thông tin chuyển khoản thủ công hoặc mở trang PayOS.</p>';
        download.hidden = true;
    }

    // 2. Nút sao chép
    document.querySelectorAll('.co-copy').forEach(function (btn) {
        btn.addEventListener('click', function () {
            var text = btn.dataset.copy || '';
            var done = function () {
                btn.textContent = 'Đã chép'; btn.classList.add('is-done');
                setTimeout(function () { btn.textContent = 'Sao chép'; btn.classList.remove('is-done'); }, 1600);
            };
            if (navigator.clipboard && navigator.clipboard.writeText) {
                navigator.clipboard.writeText(text).then(done).catch(function () { window.prompt('Sao chép:', text); });
            } else {
                window.prompt('Sao chép:', text);
            }
        });
    });

    // 3. Đếm ngược thời hạn mã QR
    var countdown = document.getElementById('co-countdown');
    var expiredBox = document.getElementById('co-expired');
    var expired = false;
    function tick() {
        if (!expiresAt) { document.getElementById('co-expire-line').hidden = true; return; }
        var left = Math.max(0, Math.floor((expiresAt - Date.now()) / 1000));
        countdown.textContent = String(Math.floor(left / 60)).padStart(2, '0') + ':' + String(left % 60).padStart(2, '0');
        if (left === 0 && !expired) {
            expired = true;
            expiredBox.hidden = false;
            checkStatus(); // kiểm tra lần cuối phòng trường hợp vừa chuyển khoản xong
        }
    }
    tick();
    var timer = setInterval(tick, 1000);

    // 4. Hỏi trạng thái định kỳ; nhận tiền thì chuyển sang trang kết quả
    var finished = false;
    function goToResult(url) {
        finished = true;
        clearInterval(timer);
        setTimeout(function () { window.location.href = cp + url; }, 1200);
    }
    function checkStatus() {
        if (finished) return;
        fetch(statusUrl, { headers: { 'Accept': 'application/json' }, credentials: 'same-origin' })
            .then(function (r) { return r.ok ? r.json() : null; })
            .then(function (data) {
                if (!data || finished) return;
                if (data.status === 'SUCCEEDED') {
                    document.getElementById('co-paid').hidden = false;
                    expiredBox.hidden = true;
                    var s = document.getElementById('co-status');
                    s.innerHTML = 'Đã thanh toán';
                    s.style.cssText = 'color:#047857;background:#ECFDF5;border-color:#A7F3D0';
                    goToResult(data.resultUrl);
                } else if (data.status === 'CANCELLED' || data.status === 'FAILED') {
                    goToResult(data.resultUrl);
                }
            })
            .catch(function () { /* mạng chập chờn: lần sau hỏi lại */ });
    }
    setInterval(function () {
        if (!document.hidden && !expired) checkStatus();
    }, 4000);
    document.addEventListener('visibilitychange', function () { if (!document.hidden) checkStatus(); });
})();
</script>
</body>
</html>
