<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý khóa học — EduSphere</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/main.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/courses.css">
</head>
<body>
<nav class="navbar">
    <a class="brand" href="${pageContext.request.contextPath}/">EduSphere</a>
    <div class="nav-links"><a href="${pageContext.request.contextPath}/courses">Khóa học</a><a href="${pageContext.request.contextPath}/dashboard">Trang cá nhân</a></div>
</nav>
<main class="course-container">
    <header class="course-header"><p class="course-eyebrow">GIẢNG VIÊN</p><h1>Quản lý khóa học</h1><p>Tạo và theo dõi các khóa học của bạn.</p></header>
    <p style="margin-bottom:24px"><a class="btn btn-primary" href="${pageContext.request.contextPath}/instructor/courses/new">Tạo khóa học</a></p>
    <c:if test="${not empty success}"><div class="alert alert-success"><c:out value="${success}"/></div></c:if>
    <c:choose>
        <c:when test="${empty courses}"><div class="course-empty"><h3>Chưa có khóa học</h3><p>Hãy tạo khóa học đầu tiên của bạn.</p></div></c:when>
        <c:otherwise><div class="course-grid"><c:forEach var="course" items="${courses}"><article class="course-card"><div class="course-card-body">
            <span class="badge ${course.status == 'PUBLISHED' ? 'badge-active' : 'badge-pending'}"><c:out value="${course.status}"/></span>
            <h3><a href="${pageContext.request.contextPath}/instructor/courses/${course.courseId}"><c:out value="${course.title}"/></a></h3>
            <p class="course-instructor"><c:out value="${course.categoryName}"/> · Phiên bản <c:out value="${course.versionNo}"/></p>
            <div class="course-card-footer"><a href="${pageContext.request.contextPath}/instructor/courses/${course.courseId}">Xem và quản lý →</a></div>
        </div></article></c:forEach></div></c:otherwise>
    </c:choose>
</main>
</body>
</html>
