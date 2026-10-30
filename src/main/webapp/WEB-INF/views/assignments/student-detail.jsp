<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html><html lang="vi"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"><title><c:out value="${assignment.title}"/> — EduSphere</title><link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app.css?v=restore-0bfd0e1-20261014"></head><body>
<jsp:include page="/WEB-INF/views/common/navbar.jsp"/>
<main class="shell"><a class="back-link" href="${pageContext.request.contextPath}/courses/${courseId}/assignments">← Danh sách bài tập</a>
<header class="page-heading"><div><p class="eyebrow">Bài tập</p><h1><c:out value="${assignment.title}"/></h1>
<p>Điểm tối đa: <strong><fmt:formatNumber value="${assignment.maxScore}" maxFractionDigits="1"/></strong>
<c:if test="${assignment.dueDate != null}"> · Hạn nộp: <strong>${fn:replace(fn:substring(assignment.dueDate, 0, 16), 'T', ' ')}</strong></c:if>
· Số lần nộp tối đa: <strong>${assignment.maxAttempts}</strong></p></div></header>
<c:if test="${not empty success}"><div class="alert alert--success"><c:out value="${success}"/></div></c:if>

<article class="card" style="padding:18px;margin-bottom:16px"><h3>Đề bài</h3>
<p style="white-space:pre-wrap"><c:out value="${assignment.description}" default="Không có mô tả."/></p></article>

<article class="card" style="padding:18px;margin-bottom:16px"><h3>Bài đã nộp (${fn:length(mySubmissions)}/${assignment.maxAttempts})</h3>
<c:choose><c:when test="${empty mySubmissions}"><p class="muted">Bạn chưa nộp bài.</p></c:when><c:otherwise>
<c:forEach var="s" items="${mySubmissions}">
<div style="border-top:1px solid #e5e7eb;padding:10px 0">
<strong>Lần ${s.attemptNumber}</strong> · ${fn:replace(fn:substring(s.submittedAt, 0, 16), 'T', ' ')}
<c:if test="${s.late}"> <span class="pill pill--neutral">Nộp trễ</span></c:if>
<span class="pill ${s.status eq 'GRADED' ? 'pill--success' : 'pill--neutral'}">${s.status eq 'GRADED' ? 'Đã chấm' : 'Chờ chấm'}</span>
<c:if test="${not empty s.fileUrl}"><div><a href="<c:out value='${s.fileUrl}'/>" target="_blank" rel="noopener noreferrer">Liên kết tệp ↗</a></div></c:if>
<c:if test="${not empty s.answerText}"><p style="white-space:pre-wrap;margin:6px 0 0"><c:out value="${s.answerText}"/></p></c:if>
</div></c:forEach>
<p><a class="button button--outline" href="${pageContext.request.contextPath}/courses/${courseId}/assignments/${assignmentId}/result">Xem kết quả đã công bố</a></p>
</c:otherwise></c:choose></article>

<c:if test="${fn:length(mySubmissions) < assignment.maxAttempts}">
<article class="card" style="padding:18px"><h3>Nộp bài</h3>
<form method="post" action="${pageContext.request.contextPath}/courses/${courseId}/assignments/${assignmentId}/submit">
<input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
<p><label for="answerText"><strong>Nội dung bài làm</strong></label><br>
<textarea id="answerText" name="answerText" rows="6" style="width:100%"></textarea></p>
<p><label for="fileUrl"><strong>Liên kết tệp (http/https)</strong></label><br>
<input id="fileUrl" type="url" name="fileUrl" style="width:100%" placeholder="https://..."></p>
<p class="small muted">Cần nhập ít nhất nội dung bài làm hoặc liên kết tệp.</p>
<button class="button button--primary" type="submit">Nộp bài</button>
</form></article>
</c:if>
</main><jsp:include page="/WEB-INF/views/common/footer.jsp"/></body></html>
