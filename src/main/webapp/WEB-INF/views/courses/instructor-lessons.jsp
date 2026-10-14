<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html><html lang="vi"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"><title>Bài học — EduSphere</title><link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app.css?v=restore-0bfd0e1-20261014"></head><body>
<jsp:include page="/WEB-INF/views/common/navbar.jsp"/>
<main class="shell shell--narrow">
<a class="back-link" href="${pageContext.request.contextPath}/instructor/courses/${course.courseId}">← Khóa học</a>
<header class="page-heading"><div><p class="eyebrow">Không gian giảng viên</p><h1>Bài học</h1><p><c:out value="${course.title}"/></p></div><c:if test="${editable}"><a class="button button--primary" href="${pageContext.request.contextPath}/instructor/courses/${course.courseId}/lessons/new">+ Tạo bài học</a></c:if></header>
<c:if test="${not editable}"><div class="alert alert--info">Khóa học đang chờ duyệt hoặc đã lưu trữ nên chưa thể sửa bài học.</div></c:if>
<c:choose><c:when test="${empty lessons}"><div class="empty-state"><span class="empty-state__mark">+</span><h2>Chưa có bài học</h2><p>Thêm bài học đầu tiên để học viên có nội dung khi vào khóa.</p></div></c:when><c:otherwise>
<div class="lesson-manager"><c:forEach var="lesson" items="${lessons}"><article class="card lesson-manager__item"><span class="lesson-manager__number"><c:out value="${lesson.orderIndex}"/></span><div><h2><c:out value="${lesson.title}"/></h2><c:choose><c:when test="${lesson.status eq 'PUBLISHED'}"><span class="pill pill--success">Học viên có thể xem</span></c:when><c:otherwise><span class="pill pill--neutral">Bản nháp</span></c:otherwise></c:choose></div><a href="${pageContext.request.contextPath}/instructor/courses/${course.courseId}/lessons/${lesson.lessonId}">Xem bài học →</a></article></c:forEach></div>
</c:otherwise></c:choose></main><jsp:include page="/WEB-INF/views/common/footer.jsp"/></body></html>
