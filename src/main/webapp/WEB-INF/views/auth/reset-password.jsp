<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<!DOCTYPE html><html lang="vi"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"><title>Đặt lại mật khẩu — EduSphere</title><link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app.css"></head><body>
<jsp:include page="/WEB-INF/views/common/navbar.jsp"/>
<main class="shell"><div class="auth-layout"><section class="auth-side"><p class="eyebrow">EduSphere · Học tập có định hướng</p><h1>Một nơi để học tập mỗi ngày.</h1><div class="auth-side__line"></div><p>Khám phá những chủ đề mới và xây dựng hành trình học phù hợp với bạn.</p></section><section class="card auth-card" aria-label="Đặt lại mật khẩu">
<p class="eyebrow">Khôi phục tài khoản · Bước 3</p><h2>Đặt mật khẩu mới</h2><p class="auth-card__sub">Chọn mật khẩu mới để bảo vệ tài khoản của bạn.</p>
<c:if test="${not empty errorMessage}"><div class="alert alert--error" role="alert"><c:out value="${errorMessage}"/></div></c:if>
<form method="post" action="${pageContext.request.contextPath}/reset-password"><input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
<div class="field"><label for="newPassword">Mật khẩu mới</label><input type="password" id="newPassword" name="newPassword" autocomplete="new-password" minlength="8" required><span class="field__hint">Tối thiểu 8 ký tự.</span></div>
<div class="field"><label for="confirmPassword">Xác nhận mật khẩu</label><input type="password" id="confirmPassword" name="confirmPassword" autocomplete="new-password" required></div>
<button class="button button--primary button--block" type="submit">Đặt lại mật khẩu</button></form><p class="auth-card__foot"><a href="${pageContext.request.contextPath}/login">Quay lại đăng nhập</a></p></section></div></main>
<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</body></html>
