<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<!DOCTYPE html><html lang="vi"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"><title>Xác minh email — EduSphere</title><link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app.css"></head><body>
<jsp:include page="/WEB-INF/views/common/navbar.jsp"/>
<main class="shell"><div class="auth-layout"><section class="auth-side"><p class="eyebrow">EduSphere · Học tập có định hướng</p><h1>Một bước nữa để bắt đầu.</h1><div class="auth-side__line"></div><p>Xác minh email giúp bảo vệ tài khoản và giữ hành trình học tập của bạn an toàn.</p></section><section class="card auth-card" aria-label="Xác minh email">
<p class="eyebrow">Bước cuối để tạo tài khoản</p><h2>Xác minh email</h2><p class="auth-card__sub">Nhập mã 6 chữ số được gửi tới <strong><c:out value="${maskedEmail}"/></strong>.</p>
<c:if test="${not empty errorMessage}"><div class="alert alert--error" role="alert"><c:out value="${errorMessage}"/></div></c:if><c:if test="${not empty successMessage}"><div class="alert alert--success"><c:out value="${successMessage}"/></div></c:if>
<form method="post" action="${pageContext.request.contextPath}/verify-otp"><input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"><div class="field"><label for="otp">Mã xác minh</label><input class="otp-input" id="otp" name="otp" inputmode="numeric" autocomplete="one-time-code" pattern="[0-9]{6}" maxlength="6" required placeholder="000000"></div><button class="button button--primary button--block" type="submit">Xác minh</button></form>
<div class="divider"></div><form method="post" action="${pageContext.request.contextPath}/resend-otp"><input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"><button class="button button--outline button--block" type="submit">Gửi lại mã</button></form><p class="auth-card__foot"><a href="${pageContext.request.contextPath}/register">Quay lại đăng ký</a></p></section></div></main>
<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</body></html>
