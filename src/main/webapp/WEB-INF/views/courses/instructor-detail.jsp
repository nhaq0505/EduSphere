<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><c:out value="${course.title}"/> — EduSphere</title>
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
    <div class="course-detail-layout">
        <article class="course-detail-main">
            <span class="badge ${course.status == 'PUBLISHED' ? 'badge-active' : 'badge-pending'}"><c:out value="${course.status}"/></span>
            <h1><c:out value="${course.title}"/></h1>
            <p class="course-instructor">Phiên bản <c:out value="${course.versionNo}"/> · <c:out value="${course.categoryName}"/></p>
            <c:if test="${course.status == 'REJECTED' && not empty course.latestReviewComment}"><div class="alert alert-error">Lý do từ chối: <c:out value="${course.latestReviewComment}"/></div></c:if>
            <h2>Mô tả</h2>
            <p class="course-description"><c:out value="${course.description}" default="Chưa có mô tả."/></p>
            <h2>Thông tin</h2>
            <table class="info-table"><tr><th>Trình độ</th><td><c:out value="${course.level}"/></td></tr><tr><th>Học phí</th><td><fmt:formatNumber value="${course.price}" type="number" maxFractionDigits="0"/> VND</td></tr></table>
        </article>
        <aside class="course-detail-side"><div class="course-detail-side-body">
            <h2>Thao tác</h2>
            <c:if test="${course.status == 'DRAFT' || course.status == 'REJECTED'}">
                <p style="margin:16px 0"><a class="btn btn-secondary" href="${pageContext.request.contextPath}/instructor/courses/${course.courseId}/edit">Chỉnh sửa</a></p>
                <form method="post" action="${pageContext.request.contextPath}/instructor/courses/${course.courseId}/submit"><input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"><button class="btn btn-primary" type="submit">Gửi duyệt</button></form>
            </c:if>
            <c:if test="${course.status == 'APPROVED'}">
                <form method="post" action="${pageContext.request.contextPath}/instructor/courses/${course.courseId}/publish"><input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"><button class="btn btn-primary" type="submit">Công bố khóa học</button></form>
            </c:if>
            <c:if test="${course.status == 'PUBLISHED'}">
                <form method="post" action="${pageContext.request.contextPath}/instructor/courses/${course.courseId}/archive"><input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"><button class="btn btn-secondary" type="submit">Lưu trữ khóa học</button></form>
            </c:if>
            <c:if test="${course.status == 'SUBMITTED'}"><p class="course-note">Khóa học đang chờ quản trị viên duyệt.</p></c:if>
            <c:if test="${course.status == 'ARCHIVED'}"><p class="course-note">Khóa học đã được lưu trữ.</p></c:if>
        </div></aside>
    </div>
</main>
</body>
</html>
