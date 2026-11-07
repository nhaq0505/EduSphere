<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html><html lang="vi"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"><title>Quiz — EduSphere</title><link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app.css?v=restore-0bfd0e1-20261014"></head><body>
<jsp:include page="/WEB-INF/views/common/navbar.jsp"/>
<main class="shell"><a class="back-link" href="${pageContext.request.contextPath}/courses/${courseId}/learn">← Quay lại bài học</a>
<header class="page-heading"><div><p class="eyebrow">Không gian học viên</p><h1>Quiz của khóa học</h1></div></header>
<c:choose><c:when test="${empty quizzes}">
<div class="empty-state"><span class="empty-state__mark">○</span><h2>Chưa có quiz</h2><p>Giảng viên chưa công bố quiz nào cho khóa học này.</p></div>
</c:when><c:otherwise>
<c:forEach var="q" items="${quizzes}">
<article class="card" style="margin-bottom:12px;padding:16px">
<h3 style="margin:0 0 6px"><a href="${pageContext.request.contextPath}/courses/${courseId}/quizzes/${q.quizId}"><c:out value="${q.title}"/></a></h3>
<p class="small muted" style="margin:0">
${q.questionCount} câu · Tổng điểm: <strong><fmt:formatNumber value="${q.maxScore}" maxFractionDigits="1"/></strong>
<c:if test="${q.timeLimitMinutes != null}"> · ${q.timeLimitMinutes} phút</c:if>
· Tối đa ${q.maxAttempts} lần
</p>
<div style="margin-top:10px"><a class="button button--outline" href="${pageContext.request.contextPath}/courses/${courseId}/quizzes/${q.quizId}">Xem chi tiết</a></div>
</article></c:forEach>
</c:otherwise></c:choose>
</main><jsp:include page="/WEB-INF/views/common/footer.jsp"/></body></html>
