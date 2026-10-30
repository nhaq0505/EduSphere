<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html><html lang="vi"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"><title><c:out value="${quiz.title}"/> — EduSphere</title><link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app.css?v=restore-0bfd0e1-20261014"></head><body>
<jsp:include page="/WEB-INF/views/common/navbar.jsp"/>
<main class="shell"><a class="back-link" href="${pageContext.request.contextPath}/courses/${courseId}/quizzes">← Danh sách quiz</a>
<header class="page-heading"><div><p class="eyebrow">Quiz</p><h1><c:out value="${quiz.title}"/></h1></div></header>
<c:if test="${not empty success}"><div class="alert alert--success"><c:out value="${success}"/></div></c:if>

<article class="card" style="padding:18px;margin-bottom:16px">
<c:if test="${not empty quiz.description}"><p style="white-space:pre-wrap"><c:out value="${quiz.description}"/></p></c:if>
<ul>
<li>Số lần làm tối đa: <strong>${quiz.maxAttempts}</strong></li>
<li>Thời gian làm bài: <strong><c:choose><c:when test="${quiz.timeLimitMinutes != null}">${quiz.timeLimitMinutes} phút</c:when><c:otherwise>Không giới hạn</c:otherwise></c:choose></strong></li>
<c:if test="${quiz.startTime != null}"><li>Mở lúc: ${fn:replace(fn:substring(quiz.startTime, 0, 16), 'T', ' ')}</li></c:if>
<c:if test="${quiz.endTime != null}"><li>Đóng lúc: ${fn:replace(fn:substring(quiz.endTime, 0, 16), 'T', ' ')}</li></c:if>
</ul>
<c:if test="${not empty quiz.rules}"><h3>Quy định</h3><p style="white-space:pre-wrap"><c:out value="${quiz.rules}"/></p></c:if>
<form method="post" action="${pageContext.request.contextPath}/courses/${courseId}/quizzes/${quizId}/start">
<input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
<button class="button button--primary" type="submit">Bắt đầu làm bài</button>
</form></article>

<article class="card" style="padding:18px"><h3>Lịch sử làm bài</h3>
<c:choose><c:when test="${empty myAttempts}"><p class="muted">Bạn chưa làm quiz này.</p></c:when><c:otherwise>
<c:forEach var="a" items="${myAttempts}">
<div style="border-top:1px solid #e5e7eb;padding:10px 0">
<strong>Lần ${a.attemptNumber}</strong> · <span class="pill pill--neutral">${a.status}</span>
<c:if test="${a.submittedAt != null}"> · ${fn:replace(fn:substring(a.submittedAt, 0, 16), 'T', ' ')}</c:if>
<c:if test="${a.resultStatus eq 'PUBLISHED' && a.score != null}"> · Điểm: <strong><fmt:formatNumber value="${a.score}" maxFractionDigits="2"/> / <fmt:formatNumber value="${a.maxScore}" maxFractionDigits="2"/></strong></c:if>
<c:choose>
<c:when test="${a.status eq 'IN_PROGRESS'}"> <a class="button button--outline" href="${pageContext.request.contextPath}/courses/${courseId}/quizzes/${quizId}/attempts/${a.attemptId}">Tiếp tục</a></c:when>
<c:otherwise> <a class="button button--outline" href="${pageContext.request.contextPath}/courses/${courseId}/quizzes/${quizId}/attempts/${a.attemptId}/result">Xem kết quả</a></c:otherwise>
</c:choose>
</div></c:forEach>
</c:otherwise></c:choose></article>
</main><jsp:include page="/WEB-INF/views/common/footer.jsp"/></body></html>
