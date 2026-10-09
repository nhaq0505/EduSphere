<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
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
    <a href="${pageContext.request.contextPath}/" class="brand">EduSphere</a>
    <div class="nav-links">
        <a href="${pageContext.request.contextPath}/courses">Khóa học</a>
        <sec:authorize access="isAnonymous()">
            <a href="${pageContext.request.contextPath}/login">Đăng nhập</a>
            <a href="${pageContext.request.contextPath}/register" class="btn btn-primary btn-small">Đăng ký</a>
        </sec:authorize>
        <sec:authorize access="isAuthenticated()">
            <a href="${pageContext.request.contextPath}/dashboard">Trang cá nhân</a>
        </sec:authorize>
    </div>
</nav>

<main class="course-container">
    <a class="course-back" href="${pageContext.request.contextPath}/courses">← Tất cả khóa học</a>
    <div class="course-detail-layout">
        <article class="course-detail-main">
            <div class="course-tags">
                <span><c:out value="${course.categoryName}"/></span>
                <span><c:out value="${course.levelLabel}"/></span>
            </div>
            <h1><c:out value="${course.title}"/></h1>
            <p class="course-instructor">Giảng viên: <c:out value="${course.instructorName}"/></p>
            <h2>Giới thiệu khóa học</h2>
            <p class="course-description"><c:out value="${course.description}" default="Chưa có mô tả."/></p>
            <h2>Nội dung khóa học</h2>
            <c:choose>
                <c:when test="${empty lessonTitles}">
                    <p class="course-description">Chưa có bài học công khai.</p>
                </c:when>
                <c:otherwise>
                    <ol class="course-lesson-list">
                        <c:forEach var="lessonTitle" items="${lessonTitles}">
                            <li><c:out value="${lessonTitle}"/></li>
                        </c:forEach>
                    </ol>
                </c:otherwise>
            </c:choose>
        </article>
        <aside class="course-detail-side">
            <div class="course-card-art" aria-hidden="true">EduSphere</div>
            <div class="course-detail-side-body">
                <p>Học phí</p>
                <strong class="course-detail-price">
                    <c:choose>
                        <c:when test="${course.free}">Miễn phí</c:when>
                        <c:otherwise><fmt:formatNumber value="${course.price}" type="number" maxFractionDigits="0"/> <c:out value="${course.currency}"/></c:otherwise>
                    </c:choose>
                </strong>
                <c:choose>
                    <c:when test="${enrolled}"><p class="course-note">Bạn đã ghi danh khóa học này.</p><a class="btn btn-primary" href="${pageContext.request.contextPath}/my-courses">Khóa học của tôi</a></c:when>
                    <c:when test="${student}"><p class="course-note"><c:if test="${!course.free}">Khóa học có phí yêu cầu quyền truy cập trước khi ghi danh.</c:if></p><form method="post" action="${pageContext.request.contextPath}/courses/${course.courseId}/enroll"><input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"><button class="btn btn-primary" type="submit">Ghi danh khóa học</button></form></c:when>
                    <c:otherwise><p class="course-note">Đăng nhập bằng tài khoản học viên để ghi danh.</p><a class="btn btn-primary" href="${pageContext.request.contextPath}/login">Đăng nhập</a></c:otherwise>
                </c:choose>
            </div>
        </aside>
    </div>
</main>
</body>
</html>
