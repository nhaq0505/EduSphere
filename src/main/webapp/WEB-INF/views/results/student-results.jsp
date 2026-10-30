<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html><html lang="vi"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"><title>Kết quả học tập — EduSphere</title><link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app.css?v=restore-0bfd0e1-20261014"></head><body>
<jsp:include page="/WEB-INF/views/common/navbar.jsp"/>
<main class="shell"><a class="back-link" href="${pageContext.request.contextPath}/courses/${courseId}/learn">← Quay lại bài học</a>
<header class="page-heading"><div><p class="eyebrow">Kết quả học tập</p><h1><c:out value="${results.courseTitle}"/></h1>
<p>Đã công bố: <strong>${results.publishedCount}</strong>
<c:if test="${results.averagePercent != null}"> · Điểm trung bình: <strong>${results.averagePercent}%</strong></c:if></p></div></header>

<c:choose><c:when test="${empty results.rows}">
<div class="empty-state"><span class="empty-state__mark">○</span><h2>Chưa có kết quả</h2><p>Bạn chưa nộp bài tập hoặc làm quiz nào trong khóa học này.</p></div>
</c:when><c:otherwise>
<c:forEach var="r" items="${results.rows}">
<article class="card" style="margin-bottom:12px;padding:16px">
<p style="margin:0 0 4px"><span class="pill pill--neutral">${r.kind eq 'QUIZ' ? 'Quiz' : 'Bài tập'}</span>
<strong><c:out value="${r.title}"/></strong> <span class="small muted">· Lần ${r.attemptNumber}
<c:if test="${r.submittedAt != null}"> · nộp ${fn:replace(fn:substring(r.submittedAt, 0, 16), 'T', ' ')}</c:if></span></p>
<c:choose>
<c:when test="${r.state eq 'PUBLISHED'}">
<p style="font-size:1.4rem;margin:6px 0"><strong><fmt:formatNumber value="${r.score}" maxFractionDigits="2"/></strong> / <fmt:formatNumber value="${r.maxScore}" maxFractionDigits="2"/> <span class="pill pill--success">Đã công bố</span></p>
<c:if test="${not empty r.feedback}"><p style="white-space:pre-wrap;margin:0"><strong>Nhận xét:</strong> <c:out value="${r.feedback}"/></p></c:if>
<p style="margin:8px 0 0"><c:choose>
<c:when test="${r.kind eq 'QUIZ'}"><a href="${pageContext.request.contextPath}/courses/${courseId}/quizzes/${r.parentId}/attempts/${r.refId}/result">Xem chi tiết bài làm →</a></c:when>
<c:otherwise><a href="${pageContext.request.contextPath}/courses/${courseId}/assignments/${r.parentId}/result">Xem chi tiết →</a></c:otherwise>
</c:choose></p>
</c:when>
<c:otherwise>
<p class="muted" style="margin:6px 0 0">${r.state eq 'READY' ? 'Đã chấm — đang chờ giảng viên công bố.' : 'Đang chờ giảng viên chấm điểm.'}</p>
</c:otherwise>
</c:choose>
</article></c:forEach>
</c:otherwise></c:choose>
</main><jsp:include page="/WEB-INF/views/common/footer.jsp"/></body></html>
