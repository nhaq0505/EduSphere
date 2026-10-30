<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chi tiết bài làm — EduSphere</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/home.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/instructor.css">
</head>
<body>
<jsp:include page="/WEB-INF/views/courses/ins-header.jsp"/>
<div class="ins-shell">
    <jsp:include page="/WEB-INF/views/courses/ins-sidebar.jsp"/>
    <main class="ins-content">
        <a class="ins-back-link" href="${pageContext.request.contextPath}/instructor/courses/${courseId}/quizzes/${quizId}/attempts">← Danh sách bài làm</a>
        <div class="ins-page-head">
            <div>
                <span class="ins-page-head__eyebrow">❓ Lần ${attempt.attemptNumber} · ${attempt.status}</span>
                <h1 class="ins-page-head__title"><c:out value="${attempt.student.fullName}"/></h1>
            </div>
            <div>
                <c:if test="${attempt.status eq 'SCORED' && attempt.resultStatus ne 'PUBLISHED'}">
                    <form method="post" action="${pageContext.request.contextPath}/instructor/courses/${courseId}/quizzes/${quizId}/attempts/${attempt.attemptId}/publish">
                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                        <button type="submit" class="ins-btn-primary" style="width:auto;padding:10px 22px">🚀 Công bố kết quả</button>
                    </form>
                </c:if>
            </div>
        </div>

        <c:if test="${not empty success}"><div class="ins-alert ins-alert--success">✅ <c:out value="${success}"/></div></c:if>

        <p>Điểm hiện tại:
            <strong><c:choose><c:when test="${attempt.score != null}"><fmt:formatNumber value="${attempt.score}" maxFractionDigits="2"/></c:when><c:otherwise>—</c:otherwise></c:choose>
            / <fmt:formatNumber value="${attempt.maxScore}" maxFractionDigits="2"/></strong>
            · Kết quả: <strong>${attempt.resultStatus eq 'PUBLISHED' ? 'Đã công bố' : 'Chưa công bố'}</strong>
        </p>
        <c:if test="${attempt.status eq 'SUBMITTED'}">
            <div class="ins-alert">Còn câu trả lời ngắn / tự luận chưa chấm. Chấm hết để có thể công bố.</div>
        </c:if>

        <div class="ins-lesson-list">
            <c:forEach var="a" items="${answers}" varStatus="st">
                <div class="ins-lesson-item" style="align-items:flex-start">
                    <div class="ins-lesson-item__info" style="width:100%">
                        <div class="ins-lesson-item__title">Câu ${st.count}. <c:out value="${a.questionContentSnapshot}"/></div>
                        <div class="ins-lesson-item__status">${a.questionTypeSnapshot} · tối đa <fmt:formatNumber value="${a.maxScore}" maxFractionDigits="1"/> điểm</div>
                        <c:choose>
                            <c:when test="${not empty a.selectedOptions}">
                                <ul style="margin:8px 0 0 18px">
                                    <c:forEach var="so" items="${a.selectedOptions}"><li><c:out value="${so.optionContentSnapshot}"/></li></c:forEach>
                                </ul>
                            </c:when>
                            <c:otherwise>
                                <p style="white-space:pre-wrap;margin:8px 0 0"><strong>Trả lời:</strong> <c:out value="${a.answerText}" default="(bỏ trống)"/></p>
                            </c:otherwise>
                        </c:choose>
                        <div style="margin-top:8px">
                            <c:choose>
                                <c:when test="${a.questionTypeSnapshot eq 'SHORT_ANSWER' || a.questionTypeSnapshot eq 'ESSAY'}">
                                    <form method="post" style="display:flex;gap:8px;align-items:center"
                                          action="${pageContext.request.contextPath}/instructor/courses/${courseId}/quizzes/${quizId}/attempts/${attempt.attemptId}/answers/${a.answerId}/grade">
                                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                                        <label>Điểm:</label>
                                        <input class="ins-input" type="number" name="score" min="0" max="${a.maxScore}" step="0.5" required
                                               value="${a.awardedScore}" style="width:100px">
                                        <button type="submit" class="ins-link-btn ins-link-btn--primary">Lưu điểm</button>
                                    </form>
                                </c:when>
                                <c:otherwise>
                                    Điểm: <strong><fmt:formatNumber value="${a.awardedScore}" maxFractionDigits="2"/></strong>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>
            </c:forEach>
        </div>
    </main>
</div>
<script>
function toggleUserMenu(e){e.stopPropagation();e.currentTarget.closest('.hn-user-menu').classList.toggle('open');}
document.addEventListener('click',()=>document.querySelectorAll('.hn-user-menu.open').forEach(m=>m.classList.remove('open')));
</script>
</body></html>
