<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html><html lang="vi"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"><title>Kết quả quiz — EduSphere</title><link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app.css?v=restore-0bfd0e1-20261014"></head><body>
<jsp:include page="/WEB-INF/views/common/navbar.jsp"/>
<main class="shell shell--narrow"><a class="back-link" href="${pageContext.request.contextPath}/courses/${courseId}/quizzes/${quizId}">← Thông tin quiz</a>
<header class="page-heading"><div><p class="eyebrow">Kết quả · Lần ${attempt.attemptNumber}</p><h1><c:out value="${attempt.quiz.title}"/></h1></div></header>
<c:if test="${not empty success}"><div class="alert alert--success"><c:out value="${success}"/></div></c:if>

<c:choose>
<c:when test="${attempt.resultStatus ne 'PUBLISHED'}">
<div class="empty-state"><span class="empty-state__mark">○</span><h2>Đã nộp bài</h2>
<p>Kết quả sẽ hiển thị sau khi giảng viên chấm và công bố.</p></div>
</c:when>
<c:otherwise>
<article class="card" style="padding:20px;margin-bottom:16px">
<p style="font-size:2rem;margin:0"><strong><fmt:formatNumber value="${attempt.score}" maxFractionDigits="2"/></strong> / <fmt:formatNumber value="${attempt.maxScore}" maxFractionDigits="2"/></p>
<c:if test="${attempt.submittedAt != null}"><p class="small muted">Nộp lúc ${fn:replace(fn:substring(attempt.submittedAt, 0, 16), 'T', ' ')}</p></c:if>
</article>
<c:forEach var="a" items="${answers}" varStatus="st">
<article class="card" style="padding:16px;margin-bottom:12px">
<p><strong>Câu ${st.count}.</strong> <c:out value="${a.questionContentSnapshot}"/></p>
<c:choose>
<c:when test="${not empty a.selectedOptions}"><ul><c:forEach var="so" items="${a.selectedOptions}"><li><c:out value="${so.optionContentSnapshot}"/></li></c:forEach></ul></c:when>
<c:otherwise><p style="white-space:pre-wrap"><c:out value="${a.answerText}" default="(bỏ trống)"/></p></c:otherwise>
</c:choose>
<p class="small">Điểm: <strong><fmt:formatNumber value="${a.awardedScore}" maxFractionDigits="2"/></strong> / <fmt:formatNumber value="${a.maxScore}" maxFractionDigits="2"/></p>
<c:if test="${not empty a.question.explanation}"><p class="small muted">Giải thích: <c:out value="${a.question.explanation}"/></p></c:if>
</article></c:forEach>
</c:otherwise></c:choose>
</main><jsp:include page="/WEB-INF/views/common/footer.jsp"/></body></html>
