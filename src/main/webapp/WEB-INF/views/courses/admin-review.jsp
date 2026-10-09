<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Duyệt khóa học — EduSphere</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/main.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/courses.css">
</head>
<body>
<nav class="navbar">
    <a class="brand" href="${pageContext.request.contextPath}/">EduSphere</a>
    <div class="nav-links"><a href="${pageContext.request.contextPath}/courses">Khóa học</a><a href="${pageContext.request.contextPath}/dashboard">Trang cá nhân</a></div>
</nav>
<main class="course-container">
    <header class="course-header"><p class="course-eyebrow">QUẢN TRỊ VIÊN</p><h1>Duyệt khóa học</h1><p>Các khóa học giảng viên đã gửi.</p></header>
    <c:if test="${not empty success}"><div class="alert alert-success"><c:out value="${success}"/></div></c:if>
    <c:choose>
        <c:when test="${empty courses}"><div class="course-empty"><h3>Không có khóa học chờ duyệt</h3></div></c:when>
        <c:otherwise><c:forEach var="course" items="${courses}">
            <article class="course-detail-main" style="margin-bottom:24px">
                <span class="badge badge-pending">Chờ duyệt</span>
                <h2 style="margin:14px 0"><c:out value="${course.title}"/></h2>
                <p class="course-instructor">Giảng viên: <c:out value="${course.instructorName}"/> · Danh mục: <c:out value="${course.categoryName}"/> · Phiên bản <c:out value="${course.versionNo}"/></p>
                <p class="course-instructor">Học phí: <fmt:formatNumber value="${course.price}" type="number" maxFractionDigits="0"/> VND</p>
                <p class="course-description" style="margin:16px 0"><c:out value="${course.description}"/></p>
                <form method="post" action="${pageContext.request.contextPath}/admin/courses/${course.courseId}/review" style="margin-bottom:20px">
                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"><input type="hidden" name="decision" value="APPROVED"><button class="btn btn-primary" type="submit">Phê duyệt</button>
                </form>
                <form method="post" action="${pageContext.request.contextPath}/admin/courses/${course.courseId}/review">
                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"><input type="hidden" name="decision" value="REJECTED">
                    <div class="form-group"><label for="reason-${course.courseId}">Lý do từ chối *</label><textarea class="form-control" id="reason-${course.courseId}" name="comment" rows="3" maxlength="2000" required></textarea></div>
                    <button class="btn btn-secondary" type="submit">Từ chối</button>
                </form>
            </article>
        </c:forEach></c:otherwise>
    </c:choose>
</main>
</body>
</html>
