<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Thông báo — EduSphere</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/home.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/quiz.css?v=2.0">
</head>
<body style="background:#F8FAFD;">
<jsp:include page="/WEB-INF/views/common/navbar.jsp"/>

<div class="quiz-page-wrap" style="display:flex; align-items:center; justify-content:center; min-height:calc(100vh - 160px);">
    <main class="quiz-shell quiz-shell--narrow" style="width:100%;">
        <div class="quiz-card" style="text-align:center; padding:48px 32px; max-width:540px; margin:0 auto; box-shadow:0 12px 36px rgba(15,23,42,0.06);">
            <div style="width:68px; height:68px; margin:0 auto 20px; background:#FEF2F2; border:2px solid #FECACA; border-radius:50%; display:flex; align-items:center; justify-content:center; font-size:2rem; color:#EF4444;">
                !
            </div>
            <h1 style="font-size:1.45rem; font-weight:800; color:#0F172A; margin:0 0 10px 0;">Không thể thực hiện thao tác</h1>
            <p style="font-size:.95rem; color:#64748B; line-height:1.6; margin-bottom:28px;">
                <c:out value="${errorMessage != null ? errorMessage : 'Đã có vấn đề xảy ra với yêu cầu của bạn.'}"/>
            </p>
            <div style="display:flex; gap:12px; justify-content:center;">
                <a class="quiz-btn quiz-btn--outline" href="javascript:history.back()">
                    ← Quay lại trang trước
                </a>
                <a class="quiz-btn quiz-btn--primary" href="${pageContext.request.contextPath}/">
                    Về trang chủ
                </a>
            </div>
        </div>
    </main>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</body>
</html>
