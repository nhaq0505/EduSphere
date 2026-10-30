<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html><html lang="vi"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"><title>Kết quả bài tập — EduSphere</title><link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app.css?v=restore-0bfd0e1-20261014"></head><body>
<jsp:include page="/WEB-INF/views/common/navbar.jsp"/>
<main class="shell shell--narrow"><a class="back-link" href="${pageContext.request.contextPath}/courses/${courseId}/assignments/${assignmentId}">← Chi tiết bài tập</a>
<header class="page-heading"><div><p class="eyebrow">Kết quả bài tập</p><h1><c:out value="${assignment.title}"/></h1></div></header>
<c:choose><c:when test="${empty grade}">
<div class="empty-state"><span class="empty-state__mark">○</span><h2>Chưa có kết quả</h2><p>Giảng viên chưa chấm hoặc chưa công bố điểm cho bài của bạn.</p></div>
</c:when><c:otherwise>
<article class="card" style="padding:20px">
<p style="font-size:2rem;margin:0"><strong><fmt:formatNumber value="${grade.score}" maxFractionDigits="2"/></strong> / <fmt:formatNumber value="${grade.maxScore}" maxFractionDigits="2"/></p>
<p class="small muted">Chấm lúc ${fn:replace(fn:substring(grade.gradedAt, 0, 16), 'T', ' ')}</p>
<h3>Nhận xét của giảng viên</h3>
<p style="white-space:pre-wrap"><c:out value="${grade.feedback}" default="Không có nhận xét."/></p>
</article>
</c:otherwise></c:choose>
</main><jsp:include page="/WEB-INF/views/common/footer.jsp"/></body></html>
