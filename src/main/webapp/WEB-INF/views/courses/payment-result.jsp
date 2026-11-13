<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Kết quả thanh toán — EduSphere</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <%-- home.css chứa style của navbar/footer dùng chung (hn-*) --%>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/home.css">
    <style>
        .pr-wrap { display:flex; align-items:center; justify-content:center; min-height:calc(100vh - 160px); padding:48px 16px; }
        .pr-card { width:100%; max-width:540px; background:#fff; border:1px solid #E2E8F0; border-radius:20px;
                   box-shadow:0 12px 36px rgba(15,23,42,.06); padding:44px 32px; text-align:center; }
        .pr-icon { width:72px; height:72px; margin:0 auto 20px; border-radius:50%; display:flex; align-items:center;
                   justify-content:center; font-size:2rem; font-weight:800; border:2px solid; }
        .pr-icon--ok      { background:#ECFDF5; border-color:#A7F3D0; color:#059669; }
        .pr-icon--cancel  { background:#F1F5F9; border-color:#CBD5E1; color:#475569; }
        .pr-icon--fail    { background:#FEF2F2; border-color:#FECACA; color:#DC2626; }
        .pr-icon--pending { background:#FFFBEB; border-color:#FDE68A; color:#D97706; }
        .pr-title { font-size:1.5rem; font-weight:800; color:#0F172A; margin:0 0 10px; }
        .pr-text { font-size:.95rem; color:#64748B; line-height:1.6; margin:0 0 8px; }
        .pr-code { font-size:.82rem; color:#94A3B8; margin:0 0 28px; }
        .pr-code b { color:#475569; font-weight:600; font-variant-numeric:tabular-nums; }
        .pr-actions { display:flex; gap:12px; justify-content:center; flex-wrap:wrap; }
        .pr-btn { display:inline-flex; align-items:center; justify-content:center; padding:11px 22px; border-radius:10px;
                  font-weight:700; font-size:.95rem; text-decoration:none; border:1px solid transparent; }
        .pr-btn--primary { background:#2563EB; color:#fff; }
        .pr-btn--primary:hover { background:#1D4ED8; }
        .pr-btn--outline { background:#fff; color:#334155; border-color:#CBD5E1; }
        .pr-btn--outline:hover { border-color:#94A3B8; }
    </style>
</head>
<body style="background:#F8FAFD;">
<jsp:include page="/WEB-INF/views/common/navbar.jsp"/>

<c:set var="cp" value="${pageContext.request.contextPath}"/>
<main class="pr-wrap">
    <section class="pr-card">
        <c:choose>
            <c:when test="${paymentStatus == 'SUCCEEDED'}">
                <div class="pr-icon pr-icon--ok" aria-hidden="true">&#10003;</div>
                <h1 class="pr-title">Thanh toán thành công</h1>
                <p class="pr-text">Bạn đã được ghi danh vào khóa học. Chúc bạn học tốt!</p>
                <p class="pr-code">Mã đơn hàng: <b><c:out value="${orderCode}"/></b></p>
                <div class="pr-actions">
                    <a class="pr-btn pr-btn--primary" href="${cp}/courses/${courseId}/learn">Vào học ngay</a>
                    <a class="pr-btn pr-btn--outline" href="${cp}/my-courses">Khóa học của tôi</a>
                </div>
            </c:when>
            <c:when test="${paymentStatus == 'CANCELLED'}">
                <div class="pr-icon pr-icon--cancel" aria-hidden="true">&#10005;</div>
                <h1 class="pr-title">Giao dịch đã bị hủy</h1>
                <p class="pr-text">Bạn chưa bị trừ tiền và chưa được ghi danh khóa học.</p>
                <p class="pr-code">Mã đơn hàng: <b><c:out value="${orderCode}"/></b></p>
                <div class="pr-actions">
                    <a class="pr-btn pr-btn--primary" href="${cp}/courses/${courseId}">Quay lại khóa học</a>
                </div>
            </c:when>
            <c:when test="${paymentStatus == 'FAILED'}">
                <div class="pr-icon pr-icon--fail" aria-hidden="true">!</div>
                <h1 class="pr-title">Thanh toán chưa thành công</h1>
                <p class="pr-text">Liên kết thanh toán đã hết hạn hoặc giao dịch thất bại. Bạn có thể thử thanh toán lại.</p>
                <p class="pr-code">Mã đơn hàng: <b><c:out value="${orderCode}"/></b></p>
                <div class="pr-actions">
                    <a class="pr-btn pr-btn--primary" href="${cp}/courses/${courseId}">Thử lại</a>
                </div>
            </c:when>
            <c:otherwise>
                <div class="pr-icon pr-icon--pending" aria-hidden="true">&#8987;</div>
                <h1 class="pr-title">Đang chờ xác nhận</h1>
                <p class="pr-text">PayOS chưa xác nhận thanh toán. Nếu bạn đã chuyển khoản, vui lòng kiểm tra lại sau ít phút.</p>
                <p class="pr-code">Mã đơn hàng: <b><c:out value="${orderCode}"/></b></p>
                <div class="pr-actions">
                    <a class="pr-btn pr-btn--primary" href="${cp}/payments/result?orderCode=${orderCode}">Kiểm tra lại</a>
                    <a class="pr-btn pr-btn--outline" href="${cp}/courses/${courseId}">Về trang khóa học</a>
                </div>
            </c:otherwise>
        </c:choose>
    </section>
</main>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</body>
</html>
