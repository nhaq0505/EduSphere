<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<!DOCTYPE html><html lang="vi"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"><title>Thông tin khóa học — EduSphere</title><link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app.css"></head><body>
<jsp:include page="/WEB-INF/views/common/navbar.jsp"/>
<main class="shell shell--narrow">
<a class="back-link" href="${pageContext.request.contextPath}/instructor/courses">← Quản lý khóa học</a>
<header class="page-heading"><div><p class="eyebrow">Không gian giảng viên</p><h1>Thông tin khóa học</h1><p>Lưu bản nháp trước khi gửi quản trị viên duyệt.</p></div></header>
<div class="card form-card"><form:form method="post" modelAttribute="courseForm" action="${pageContext.request.contextPath}${formAction}" htmlEscape="true">
<input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
<div class="field"><label for="title">Tên khóa học *</label><form:input path="title" id="title" maxlength="255" required="required"/><form:errors path="title" cssClass="field-error"/></div>
<div class="field"><label for="description">Mô tả khóa học</label><form:textarea path="description" id="description" rows="7"/><form:errors path="description" cssClass="field-error"/></div>
<div class="form-grid"><div class="field"><label for="categoryId">Danh mục</label><form:select path="categoryId" id="categoryId"><form:option value="" label="Chưa phân loại"/><form:options items="${categories}" itemValue="categoryId" itemLabel="name"/></form:select><form:errors path="categoryId" cssClass="field-error"/></div>
<div class="field"><label for="level">Trình độ</label><form:select path="level" id="level"><form:option value="ALL_LEVELS" label="Mọi trình độ"/><form:option value="BEGINNER" label="Cơ bản"/><form:option value="INTERMEDIATE" label="Trung cấp"/><form:option value="ADVANCED" label="Nâng cao"/></form:select><form:errors path="level" cssClass="field-error"/></div></div>
<div class="field"><label for="price">Học phí (VND)</label><form:input path="price" id="price" type="number" min="0" step="0.01" required="required"/><span class="field__hint">Nhập 0 nếu khóa học miễn phí. Khóa học có phí chưa mở thanh toán cho học viên.</span><form:errors path="price" cssClass="field-error"/></div>
<div class="form-actions"><button class="button button--primary" type="submit">Lưu khóa học</button><a class="button button--outline" href="${pageContext.request.contextPath}/instructor/courses">Hủy</a></div></form:form></div></main>
<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</body></html>
