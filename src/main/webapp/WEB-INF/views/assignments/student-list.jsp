<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html><html lang="vi"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"><title>Bài tập — EduSphere</title><link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app.css?v=restore-0bfd0e1-20261014"></head><body>
<jsp:include page="/WEB-INF/views/common/navbar.jsp"/>
<main class="shell"><a class="back-link" href="${pageContext.request.contextPath}/courses/${courseId}/learn">← Quay lại bài học</a>
<header class="page-heading"><div><p class="eyebrow">Không gian học viên</p><h1>Bài tập của khóa học</h1></div></header>
<c:if test="${not empty success}"><div class="alert alert--success"><c:out value="${success}"/></div></c:if>
<c:choose><c:when test="${empty assignments}">
<div class="empty-state"><span class="empty-state__mark">○</span><h2>Chưa có bài tập</h2><p>Giảng viên chưa công bố bài tập nào cho khóa học này.</p></div>
</c:when><c:otherwise>
<div class="material-list"><c:forEach var="a" items="${assignments}">
<article class="card" style="margin-bottom:12px;padding:16px">
<h3 style="margin:0 0 6px"><a href="${pageContext.request.contextPath}/courses/${courseId}/assignments/${a.assignmentId}"><c:out value="${a.title}"/></a></h3>
<p class="small muted" style="margin:0">
Điểm tối đa: <strong><fmt:formatNumber value="${a.maxScore}" maxFractionDigits="1"/></strong>
<c:if test="${a.dueDate != null}"> · Hạn nộp: <strong>${fn:replace(fn:substring(a.dueDate, 0, 16), 'T', ' ')}</strong></c:if>
<c:if test="${not empty a.lessonTitle}"> · Bài học: <c:out value="${a.lessonTitle}"/></c:if>
</p>
<div style="margin-top:10px"><a class="button button--outline" href="${pageContext.request.contextPath}/courses/${courseId}/assignments/${a.assignmentId}">Xem &amp; nộp bài</a>
<a class="button button--outline" href="${pageContext.request.contextPath}/courses/${courseId}/assignments/${a.assignmentId}/result">Xem kết quả</a></div>
</article></c:forEach></div>
</c:otherwise></c:choose>
</main><jsp:include page="/WEB-INF/views/common/footer.jsp"/></body></html>
