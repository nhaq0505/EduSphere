<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Thông tin khóa học — EduSphere</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/main.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/courses.css">
</head>
<body>
<nav class="navbar">
    <a class="brand" href="${pageContext.request.contextPath}/">EduSphere</a>
    <div class="nav-links"><a href="${pageContext.request.contextPath}/instructor/courses">Quản lý khóa học</a><a href="${pageContext.request.contextPath}/dashboard">Trang cá nhân</a></div>
</nav>
<main class="course-container">
    <a class="course-back" href="${pageContext.request.contextPath}/instructor/courses">← Quản lý khóa học</a>
    <header class="course-header"><p class="course-eyebrow">GIẢNG VIÊN</p><h1>Thông tin khóa học</h1><p>Tạo hoặc chỉnh sửa bản nháp trước khi gửi duyệt.</p></header>
    <div class="form-card" style="max-width:760px">
        <form:form method="post" modelAttribute="courseForm" action="${pageContext.request.contextPath}${formAction}" htmlEscape="true">
            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
            <div class="form-group"><label for="title">Tên khóa học *</label><form:input path="title" id="title" maxlength="255" cssClass="form-control" required="required"/><form:errors path="title" cssClass="field-error"/></div>
            <div class="form-group"><label for="description">Mô tả</label><form:textarea path="description" id="description" rows="7" cssClass="form-control"/><form:errors path="description" cssClass="field-error"/></div>
            <div class="form-group"><label for="categoryId">Danh mục</label><form:select path="categoryId" id="categoryId" cssClass="form-control"><form:option value="" label="Chưa phân loại"/><form:options items="${categories}" itemValue="categoryId" itemLabel="name"/></form:select></div>
            <div class="form-group"><label for="level">Trình độ</label><form:select path="level" id="level" cssClass="form-control"><form:option value="ALL_LEVELS" label="Mọi trình độ"/><form:option value="BEGINNER" label="Cơ bản"/><form:option value="INTERMEDIATE" label="Trung cấp"/><form:option value="ADVANCED" label="Nâng cao"/></form:select><form:errors path="level" cssClass="field-error"/></div>
            <div class="form-group"><label for="price">Học phí (VND)</label><form:input path="price" id="price" type="number" min="0" step="0.01" cssClass="form-control" required="required"/><form:errors path="price" cssClass="field-error"/></div>
            <div class="form-actions"><button class="btn btn-primary" type="submit">Lưu khóa học</button><a class="btn btn-secondary" href="${pageContext.request.contextPath}/instructor/courses">Hủy</a></div>
        </form:form>
    </div>
</main>
</body>
</html>
