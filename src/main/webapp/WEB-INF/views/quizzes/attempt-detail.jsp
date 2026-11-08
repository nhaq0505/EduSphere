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
<div class="ins-layout">
    <jsp:include page="../courses/ins-sidebar.jsp"/>
    <div class="ins-main-wrapper">
        <jsp:include page="../courses/ins-header.jsp"/>
        <main class="ins-page">
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
            · Kết quả: <strong>
                <c:choose>
                    <c:when test="${attempt.status eq 'SCORED' or attempt.resultStatus eq 'PUBLISHED'}">✅ Đã công bố</c:when>
                    <c:when test="${attempt.status eq 'SUBMITTED'}">📝 Đã công bố trắc nghiệm (Chờ chấm tự luận)</c:when>
                    <c:otherwise>Chưa công bố</c:otherwise>
                </c:choose>
            </strong>
        </p>
        <c:if test="${attempt.status eq 'SUBMITTED'}">
            <div class="ins-alert">Còn câu hỏi tự luận chưa chấm. Sau khi chấm hết các câu tự luận, kết quả bài làm sẽ tự động được hoàn tất và công bố.</div>
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
                                    <c:if test="${a.question != null and not empty a.question.sampleEssayAnswer}">
                                        <div style="margin-bottom:8px;padding:8px 12px;background:#fdf4ff;border-left:3px solid #c026d3;border-radius:4px;font-size:0.83rem;color:#86198f">
                                            💡 <strong>Gợi ý đáp án / Tiêu chí chấm:</strong> <c:out value="${a.question.sampleEssayAnswer}"/>
                                        </div>
                                    </c:if>
                                    <form method="post" style="display:flex;gap:8px;align-items:center"
                                          action="${pageContext.request.contextPath}/instructor/courses/${courseId}/quizzes/${quizId}/attempts/${attempt.attemptId}/answers/${a.answerId}/grade">
                                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                                        <label>Điểm:</label>
                                        <input class="ins-input" type="number" name="score" min="0" max="${a.maxScore}" step="0.25" required
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
