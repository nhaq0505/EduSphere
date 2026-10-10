<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<!DOCTYPE html><html lang="vi"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"><title>Đăng ký — EduSphere</title><link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app.css"></head><body>
<jsp:include page="/WEB-INF/views/common/navbar.jsp"/>
<main class="shell"><div class="auth-layout"><section class="auth-side"><p class="eyebrow">EduSphere · Học tập có định hướng</p><h1>Bắt đầu từ điều bạn tò mò.</h1><div class="auth-side__line"></div><p>Tạo tài khoản để ghi danh và lưu lại những khóa học bạn quan tâm.</p></section><section class="card auth-card" aria-label="Đăng ký">
<p class="eyebrow">Bắt đầu cùng EduSphere</p><h2>Tạo tài khoản</h2><p class="auth-card__sub">Điền thông tin để bắt đầu học tập.</p>
<c:if test="${not empty errorMessage}"><div class="alert alert--error" role="alert"><c:out value="${errorMessage}"/></div></c:if>
<c:if test="${not empty successMessage}"><div class="alert alert--success"><c:out value="${successMessage}"/></div></c:if>
<form:form method="post" action="${pageContext.request.contextPath}/register" modelAttribute="registerRequest"><input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
<div class="field"><label for="fullName">Họ và tên *</label><form:input path="fullName" id="fullName" autocomplete="name" required="required" maxlength="100"/><form:errors path="fullName" cssClass="field-error"/></div>
<div class="field"><label for="email">Email *</label><form:input path="email" id="email" type="email" autocomplete="email" required="required"/><form:errors path="email" cssClass="field-error"/></div>
<div class="field"><label for="password">Mật khẩu *</label><form:password path="password" id="password" autocomplete="new-password" minlength="8" required="required"/><span class="field__hint">Tối thiểu 8 ký tự.</span><form:errors path="password" cssClass="field-error"/></div>
<div class="field"><label for="confirmPassword">Xác nhận mật khẩu *</label><form:password path="confirmPassword" id="confirmPassword" autocomplete="new-password" required="required"/><form:errors path="confirmPassword" cssClass="field-error"/></div>
<div class="field"><label for="phone">Số điện thoại</label><form:input path="phone" id="phone" type="tel" autocomplete="tel"/><form:errors path="phone" cssClass="field-error"/></div>
<button class="button button--primary button--block" type="submit">Tạo tài khoản</button></form:form>
<div class="auth-card__separator">hoặc</div><a class="button button--outline button--block" href="${pageContext.request.contextPath}/oauth2/authorization/google">Tiếp tục với Google</a>
<p class="auth-card__foot">Đã có tài khoản? <a href="${pageContext.request.contextPath}/login">Đăng nhập</a></p></section></div></main>
<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</body></html>
