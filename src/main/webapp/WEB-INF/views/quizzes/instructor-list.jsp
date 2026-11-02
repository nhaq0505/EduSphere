<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý quiz — EduSphere</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/home.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/instructor.css">
</head>
<body>
<div class="ins-layout">
    <jsp:include page="../courses/ins-sidebar.jsp"/>
    <div class="ins-main-wrapper">
        <jsp:include page="../courses/ins-header.jsp"/>
        <main class="ins-page">
            <div class="ins-page-head">
                <div>
                    <span class="ins-page-head__eyebrow">❓ Quiz</span>
                    <h1 class="ins-page-head__title">Quản lý quiz</h1>
                </div>
                <a class="ins-btn-primary" style="width:auto;padding:10px 22px"
                   href="${pageContext.request.contextPath}/instructor/courses/${courseId}/quizzes/new<c:if test="${selectedLessonId != null}">?lessonId=${selectedLessonId}</c:if>">+ Tạo Quiz mới</a>
            </div>

        <c:if test="${not empty success}"><div class="ins-alert ins-alert--success">✅ <c:out value="${success}"/></div></c:if>

        <c:choose>
            <c:when test="${empty quizzes}">
                <div class="ins-empty">
                    <div class="ins-empty__icon">❓</div>
                    <h3>Chưa có quiz nào</h3>
                    <p>Tạo quiz để kiểm tra kiến thức học viên.</p>
                </div>
            </c:when>
            <c:otherwise>
                <div class="ins-lesson-list">
                    <c:forEach var="q" items="${quizzes}">
                        <div class="ins-lesson-item">
                            <div class="ins-lesson-item__info">
                                <div class="ins-lesson-item__title"><c:out value="${q.title}"/></div>
                                <div class="ins-lesson-item__status">
                                    <c:choose>
                                        <c:when test="${q.status eq 'PUBLISHED'}"><span class="ins-pill-published">✅ Đã công bố</span></c:when>
                                        <c:when test="${q.status eq 'ARCHIVED'}"><span class="ins-pill-draft" style="background:#e5e7eb;color:#6b7280">📦 Lưu trữ</span></c:when>
                                        <c:otherwise><span class="ins-pill-draft">📝 Bản nháp</span></c:otherwise>
                                    </c:choose>
                                    &nbsp;|&nbsp; Câu hỏi: <strong>${q.questionCount}</strong>
                                    &nbsp;|&nbsp; Tổng điểm: <strong><fmt:formatNumber value="${q.maxScore}" maxFractionDigits="1"/></strong>
                                    <c:if test="${q.timeLimitMinutes != null}">&nbsp;|&nbsp; ${q.timeLimitMinutes} phút</c:if>
                                    <c:if test="${q.dueDate != null}">&nbsp;|&nbsp; Hạn: ${fn:replace(fn:substring(q.dueDate, 0, 16), 'T', ' ')}</c:if>
                                </div>
                            </div>
                            <div class="ins-lesson-item__actions">
                                <a class="ins-link-btn ins-link-btn--primary"
                                   href="${pageContext.request.contextPath}/instructor/courses/${courseId}/quizzes/${q.quizId}">Chi tiết</a>
                                <a class="ins-link-btn"
                                   href="${pageContext.request.contextPath}/instructor/courses/${courseId}/quizzes/${q.quizId}/attempts">Bài làm</a>
                                <c:if test="${q.status eq 'DRAFT'}">
                                    <form method="post" style="display:inline"
                                          action="${pageContext.request.contextPath}/instructor/courses/${courseId}/quizzes/${q.quizId}/publish">
                                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                                        <button type="submit" class="ins-link-btn ins-link-btn--success">🚀 Công bố</button>
                                    </form>
                                </c:if>
                                <c:if test="${q.status eq 'PUBLISHED'}">
                                    <form method="post" style="display:inline"
                                          action="${pageContext.request.contextPath}/instructor/courses/${courseId}/quizzes/${q.quizId}/archive">
                                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                                        <button type="submit" class="ins-link-btn">📦 Lưu trữ</button>
                                    </form>
                                </c:if>
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
