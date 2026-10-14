<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard — EduSphere</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/main.css?v=restore-0bfd0e1-20261014">
</head>
<body>

<jsp:include page="/WEB-INF/views/common/navbar.jsp"/>

<div class="page-container">
    <c:if test="${not empty successMessage}">
        <div class="alert alert-success"><c:out value="${successMessage}"/></div>
    </c:if>

    <h2>Chào mừng, <sec:authentication property="principal.fullName"/>!</h2>

    <div class="dashboard-grid">
        <a href="${pageContext.request.contextPath}/courses" class="dashboard-card"><span class="card-icon">📚</span><span>Khám phá khóa học</span></a>
        <sec:authorize access="hasRole('STUDENT')"><a href="${pageContext.request.contextPath}/my-courses" class="dashboard-card"><span class="card-icon">📖</span><span>Khóa học của tôi</span></a></sec:authorize>
        <sec:authorize access="hasRole('INSTRUCTOR')"><a href="${pageContext.request.contextPath}/instructor/courses" class="dashboard-card"><span class="card-icon">📝</span><span>Quản lý khóa học</span></a></sec:authorize>
        <sec:authorize access="hasRole('ADMINISTRATOR')"><a href="${pageContext.request.contextPath}/admin/courses/review" class="dashboard-card"><span class="card-icon">✓</span><span>Duyệt khóa học</span></a></sec:authorize>
        <a href="${pageContext.request.contextPath}/profile" class="dashboard-card">
            <span class="card-icon">👤</span>
            <span>Hồ sơ cá nhân</span>
        </a>
        <a href="${pageContext.request.contextPath}/change-password" class="dashboard-card">
            <span class="card-icon">🔒</span>
            <span>Đổi mật khẩu</span>
        </a>

        <%-- Chỉ ADMINISTRATOR thấy link Admin --%>
        <sec:authorize access="hasRole('ADMINISTRATOR')">
            <a href="${pageContext.request.contextPath}/admin/users" class="dashboard-card">
                <span class="card-icon">⚙️</span>
                <span>Quản trị</span>
            </a>
        </sec:authorize>
    </div>
</div>

</body>
</html>
