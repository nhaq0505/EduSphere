<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<!DOCTYPE html><html lang="vi"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"><title>Khóa học của tôi — EduSphere</title><link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app.css?v=restore-0bfd0e1-20261014"></head><body>
<jsp:include page="/WEB-INF/views/common/navbar.jsp"/>
<main class="shell">

<header class="page-heading"><div><p class="eyebrow">Không gian học viên</p><h1>Khóa học của tôi</h1><p>Những khóa học bạn đã ghi danh.</p></div><a class="button button--outline" href="${pageContext.request.contextPath}/courses">Khám phá thêm</a></header>
<c:if test="${not empty success}"><div class="alert alert--success"><c:out value="${success}"/></div></c:if>
<c:choose><c:when test="${empty courses}"><div class="empty-state"><span class="empty-state__mark">+</span><h2>Chưa có khóa học nào</h2><p>Khám phá thư viện và chọn khóa học đầu tiên dành cho bạn.</p><a class="button button--primary" href="${pageContext.request.contextPath}/courses">Khám phá khóa học</a></div></c:when>
<c:otherwise><div class="course-grid"><c:forEach var="course" items="${courses}"><article class="card course-card"><div class="course-card__visual course-card__visual--alt" aria-hidden="true">EduSphere · Đã ghi danh</div><div class="course-card__body">
<div class="course-card__meta"><c:choose><c:when test="${course.enrollmentStatus == 'ACTIVE'}"><span class="pill pill--success">Đã ghi danh</span></c:when><c:when test="${course.enrollmentStatus == 'COMPLETED'}"><span class="pill pill--success">Đã hoàn thành</span></c:when><c:otherwise><span class="pill pill--neutral">Đã rời khóa học</span></c:otherwise></c:choose></div>
<h3><a href="${pageContext.request.contextPath}/courses/${course.courseId}"><c:out value="${course.title}"/></a></h3><p>Giảng viên: <c:out value="${course.instructorName}"/></p><div class="course-card__bottom"><a href="${pageContext.request.contextPath}/courses/${course.courseId}">Xem chi tiết</a><c:if test="${course.enrollmentStatus ne 'DROPPED'}"><a href="${pageContext.request.contextPath}/courses/${course.courseId}/learn">Vào học →</a></c:if></div></div></article></c:forEach></div></c:otherwise></c:choose>

</main>
<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</body></html>
