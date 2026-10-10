<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<!DOCTYPE html><html lang="vi"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"><title>Chỉnh sửa hồ sơ — EduSphere</title><link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app.css"></head><body><jsp:include page="/WEB-INF/views/common/navbar.jsp"/><main class="shell shell--narrow">
<a class="back-link" href="${pageContext.request.contextPath}/profile">← Hồ sơ cá nhân</a><header class="page-heading"><div><p class="eyebrow">Thông tin tài khoản</p><h1>Chỉnh sửa hồ sơ</h1><p>Cập nhật thông tin để mọi người nhận biết bạn.</p></div></header>
<c:if test="${not empty errorMessage}"><div class="alert alert--error" role="alert"><c:out value="${errorMessage}"/></div></c:if>
<div class="card form-card"><form:form method="post" action="${pageContext.request.contextPath}/profile/edit" modelAttribute="updateProfileRequest"><input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
<div class="field"><label for="fullName">Họ và tên</label><form:input path="fullName" id="fullName" autocomplete="name" required="required"/><form:errors path="fullName" cssClass="field-error"/></div>
<div class="field"><label for="email">Email</label><input id="email" type="email" value="<c:out value='${user.email}'/>" disabled><span class="field__hint">Email không thể thay đổi tại đây.</span></div>
<div class="field"><label for="phone">Số điện thoại</label><form:input path="phone" id="phone" type="tel" autocomplete="tel"/><form:errors path="phone" cssClass="field-error"/></div>
<div class="form-actions"><button class="button button--primary" type="submit">Lưu thay đổi</button><a class="button button--outline" href="${pageContext.request.contextPath}/profile">Hủy</a></div></form:form></div></main><jsp:include page="/WEB-INF/views/common/footer.jsp"/></body></html>