<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<!DOCTYPE html><html lang="vi"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"><title>Xác minh mã khôi phục — EduSphere</title><link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app.css"></head><body>
<jsp:include page="/WEB-INF/views/common/navbar.jsp"/>
<main class="shell"><div class="auth-layout"><section class="auth-side"><p class="eyebrow">EduSphere · Học tập có định hướng</p><h1>Một nơi để học tập mỗi ngày.</h1><div class="auth-side__line"></div><p>Khám phá những chủ đề mới và xây dựng hành trình học phù hợp với bạn.</p></section><section class="card auth-card" aria-label="Xác minh mã khôi phục">
<p class="eyebrow">Khôi phục tài khoản · Bước 2</p><h2>Kiểm tra email</h2><p class="auth-card__sub">Nhập mã 6 chữ số được gửi tới <strong><c:out value="${maskedEmail}"/></strong>.</p>
<c:if test="${not empty errorMessage}"><div class="alert alert--error" role="alert"><c:out value="${errorMessage}"/></div></c:if><c:if test="${not empty successMessage}"><div class="alert alert--success"><c:out value="${successMessage}"/></div></c:if>
<form method="post" action="${pageContext.request.contextPath}/forgot-password/verify-otp"><input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"><div class="field"><label for="otp">Mã xác minh</label><input class="otp-input" id="otp" name="otp" inputmode="numeric" autocomplete="one-time-code" pattern="[0-9]{6}" maxlength="6" required placeholder="000000"></div><button class="button button--primary button--block" type="submit">Tiếp tục</button></form>
<div class="divider"></div><form method="post" action="${pageContext.request.contextPath}/forgot-password/resend-otp"><input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"><button class="button button--outline button--block" type="submit">Gửi lại mã</button></form><p class="auth-card__foot"><a href="${pageContext.request.contextPath}/forgot-password">Dùng email khác</a></p></section></div></main>
<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</body></html>
