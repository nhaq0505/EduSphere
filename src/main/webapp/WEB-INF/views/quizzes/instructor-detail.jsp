<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chi tiết quiz — EduSphere</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/home.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/instructor.css">
</head>
<body>
<div class="ins-layout">
    <jsp:include page="/WEB-INF/views/courses/ins-sidebar.jsp"/>
    <div class="ins-main-wrapper">
        <jsp:include page="/WEB-INF/views/courses/ins-header.jsp"/>
        <main class="ins-page">
        <a class="ins-back-link" href="${pageContext.request.contextPath}/instructor/courses/${courseId}/quizzes">← Danh sách quiz</a>
        <div class="ins-page-head">
            <div>
                <span class="ins-page-head__eyebrow">❓ Quiz · ${quiz.status}</span>
                <h1 class="ins-page-head__title"><c:out value="${quiz.title}"/></h1>
            </div>
            <div style="display:flex;gap:8px">
                <c:if test="${quiz.status eq 'DRAFT'}">
                    <a class="ins-btn-primary" style="width:auto;padding:10px 22px"
                       href="${pageContext.request.contextPath}/instructor/courses/${courseId}/quizzes/${quizId}/questions/new">+ Thêm câu hỏi</a>
                    <form method="post" action="${pageContext.request.contextPath}/instructor/courses/${courseId}/quizzes/${quizId}/publish">
                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                        <button type="submit" class="ins-link-btn ins-link-btn--success" style="padding:10px 20px">🚀 Công bố</button>
                    </form>
                </c:if>
                <a class="ins-link-btn" style="padding:10px 20px"
                   href="${pageContext.request.contextPath}/instructor/courses/${courseId}/quizzes/${quizId}/attempts">Bài làm</a>
            </div>
        </div>

        <c:if test="${not empty success}"><div class="ins-alert ins-alert--success">✅ <c:out value="${success}"/></div></c:if>

        <p>
            Số lần làm tối đa: <strong>${quiz.maxAttempts}</strong>
            <c:if test="${quiz.timeLimitMinutes != null}"> · Thời gian: <strong>${quiz.timeLimitMinutes} phút</strong></c:if>
            <c:if test="${quiz.dueDate != null}"> · Hạn: <strong>${fn:replace(fn:substring(quiz.dueDate, 0, 16), 'T', ' ')}</strong></c:if>
        </p>
        <c:if test="${not empty quiz.description}"><p style="white-space:pre-wrap"><c:out value="${quiz.description}"/></p></c:if>

        <c:choose>
            <c:when test="${empty questions}">
                <div class="ins-empty">
                    <div class="ins-empty__icon">❓</div>
                    <h3>Chưa có câu hỏi</h3>
                    <p>Thêm câu hỏi trước khi công bố quiz.</p>
                </div>
            </c:when>
            <c:otherwise>
                <div class="ins-lesson-list">
                    <c:forEach var="q" items="${questions}">
                        <div class="ins-lesson-item" style="align-items:flex-start">
                            <div class="ins-lesson-item__info">
                                <div class="ins-lesson-item__title">Câu ${q.orderIndex}. <c:out value="${q.content}"/></div>
                                <div class="ins-lesson-item__status">
                                    ${q.type} &nbsp;|&nbsp; <strong><fmt:formatNumber value="${q.score}" maxFractionDigits="1"/></strong> điểm
                                </div>
                                <c:if test="${not empty q.options}">
                                    <ul style="margin:8px 0 0 18px">
                                        <c:forEach var="o" items="${q.options}">
                                            <li><c:out value="${o.content}"/><c:if test="${o.correct}"> <strong style="color:#16a34a">✔ đúng</strong></c:if></li>
                                        </c:forEach>
                                    </ul>
                                </c:if>
                                <c:if test="${q.type eq 'TRUE_FALSE' || q.type eq 'SHORT_ANSWER'}">
                                    <div class="small">Đáp án: <strong><c:out value="${q.correctAnswer}"/></strong></div>
                                </c:if>
                                <c:if test="${not empty q.explanation}"><div class="small">Giải thích: <c:out value="${q.explanation}"/></div></c:if>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </c:otherwise>
        </c:choose>
        </main>
    </div>
</div>
<script>
function insToggleMenu(e) {
    e.stopPropagation();
    document.getElementById('insUserMenu').classList.toggle('open');
}
document.addEventListener('click', function() {
    var m = document.getElementById('insUserMenu');
    if (m) m.classList.remove('open');
});
</script>
</body></html>
