<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<!DOCTYPE html><html lang="vi"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"><title>Quên mật khẩu — EduSphere</title><link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app.css"></head><body>
<jsp:include page="/WEB-INF/views/common/navbar.jsp"/>
<main class="shell"><div class="auth-layout"><section class="auth-side"><p class="eyebrow">EduSphere · Học tập có định hướng</p><h1>Bạn luôn có thể bắt đầu lại.</h1><div class="auth-side__line"></div><p>Khôi phục mật khẩu theo các bước rõ ràng, sau đó tiếp tục việc học.</p></section><section class="card auth-card" aria-label="Quên mật khẩu">
<p class="eyebrow">Khôi phục tài khoản</p><h2>Quên mật khẩu?</h2><p class="auth-card__sub">Nhập email để nhận mã xác minh và đặt mật khẩu mới.</p>
<c:if test="${not empty errorMessage}"><div class="alert alert--error" role="alert"><c:out value="${errorMessage}"/></div></c:if><c:if test="${not empty successMessage}"><div class="alert alert--success"><c:out value="${successMessage}"/></div></c:if>
<form:form method="post" action="${pageContext.request.contextPath}/forgot-password" modelAttribute="forgotPasswordRequest"><input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"><div class="field"><label for="email">Email tài khoản</label><form:input path="email" id="email" type="email" autocomplete="email" required="required" placeholder="ten@example.com"/><form:errors path="email" cssClass="field-error"/></div><button class="button button--primary button--block" type="submit">Gửi mã xác minh</button></form:form>
<p class="auth-card__foot"><a href="${pageContext.request.contextPath}/login">← Quay lại đăng nhập</a></p></section></div></main>
<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</body></html>
