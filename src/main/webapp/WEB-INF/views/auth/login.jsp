<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<!DOCTYPE html><html lang="vi"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"><title>Đăng nhập — EduSphere</title><link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app.css"></head><body>
<jsp:include page="/WEB-INF/views/common/navbar.jsp"/>
<main class="shell"><div class="auth-layout"><section class="auth-side"><p class="eyebrow">EduSphere · Học tập có định hướng</p><h1>Một nơi để học tập mỗi ngày.</h1><div class="auth-side__line"></div><p>Khám phá những chủ đề mới và xây dựng hành trình học phù hợp với bạn.</p></section><section class="card auth-card" aria-label="Đăng nhập">
<p class="eyebrow">Chào mừng trở lại</p><h2>Đăng nhập</h2><p class="auth-card__sub">Tiếp tục hành trình học tập của bạn.</p>
<c:if test="${not empty errorMessage}"><div class="alert alert--error" role="alert"><c:out value="${errorMessage}"/></div></c:if>
<c:if test="${not empty successMessage}"><div class="alert alert--success"><c:out value="${successMessage}"/></div></c:if>
<form method="post" action="${pageContext.request.contextPath}/login"><input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
<div class="field"><label for="username">Email</label><input type="email" id="username" name="username" autocomplete="username" required autofocus placeholder="ten@example.com"></div>
<div class="field"><label for="password">Mật khẩu</label><input type="password" id="password" name="password" autocomplete="current-password" required placeholder="Nhập mật khẩu"></div>
<div class="auth-card__meta"><span></span><a href="${pageContext.request.contextPath}/forgot-password">Quên mật khẩu?</a></div>
<button class="button button--primary button--block" type="submit">Đăng nhập</button></form>
<div class="auth-card__separator">hoặc</div><a class="button button--outline button--block" href="${pageContext.request.contextPath}/oauth2/authorization/google">Tiếp tục với Google</a>
<p class="auth-card__foot">Chưa có tài khoản? <a href="${pageContext.request.contextPath}/register">Đăng ký ngay</a></p></section></div></main>
<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</body></html>
