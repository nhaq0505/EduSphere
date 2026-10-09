<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Khóa học của tôi — EduSphere</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/main.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/courses.css">
</head>
<body>
<nav class="navbar">
    <a class="brand" href="${pageContext.request.contextPath}/">EduSphere</a>
    <div class="nav-links"><a href="${pageContext.request.contextPath}/courses">Khóa học</a><a href="${pageContext.request.contextPath}/dashboard">Trang cá nhân</a></div>
</nav>
<main class="course-container">
    <header class="course-header"><p class="course-eyebrow">HỌC VIÊN</p><h1>Khóa học của tôi</h1><p>Danh sách khóa học bạn đã ghi danh.</p></header>
    <c:if test="${not empty success}"><div class="alert alert-success"><c:out value="${success}"/></div></c:if>
    <c:choose>
        <c:when test="${empty courses}"><div class="course-empty"><h3>Bạn chưa ghi danh khóa học nào</h3><p>Hãy tìm khóa học phù hợp để bắt đầu.</p><a class="btn btn-primary" href="${pageContext.request.contextPath}/courses">Khám phá khóa học</a></div></c:when>
        <c:otherwise><div class="course-grid">
            <c:forEach var="course" items="${courses}"><article class="course-card"><div class="course-card-art" aria-hidden="true">EduSphere</div><div class="course-card-body">
                <span class="badge badge-active"><c:out value="${course.enrollmentStatus}"/></span>
                <h3><a href="${pageContext.request.contextPath}/courses/${course.courseId}"><c:out value="${course.title}"/></a></h3>
                <p class="course-instructor">Giảng viên: <c:out value="${course.instructorName}"/></p>
                <p class="course-instructor">Trạng thái khóa học: <c:out value="${course.courseStatus}"/></p>
                <div class="course-card-footer"><a href="${pageContext.request.contextPath}/courses/${course.courseId}">Xem khóa học →</a></div>
            </div></article></c:forEach>
        </div></c:otherwise>
    </c:choose>
</main>
</body>
</html>
