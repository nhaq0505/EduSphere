<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Kết quả: <c:out value="${attempt.quiz.title}"/> — EduSphere</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app.css?v=restore-0bfd0e1-20261014">
    <style>
        /* ── Score hero ── */
        .qr-hero { border-radius:16px; padding:32px 36px; text-align:center; margin-bottom:24px; }
        .qr-hero--pass { background:linear-gradient(135deg,#14532D,#16A34A); color:#fff; }
        .qr-hero--fail { background:linear-gradient(135deg,#7F1D1D,#DC2626); color:#fff; }
        .qr-hero--pending { background:linear-gradient(135deg,#1E3A5F,#2563EB); color:#fff; }
        .qr-hero__eyebrow { font-size:.8rem; font-weight:700; opacity:.75; text-transform:uppercase; letter-spacing:.06em; margin-bottom:8px; }
        .qr-score { font-size:4rem; font-weight:900; line-height:1; margin:0; }
        .qr-score__max { font-size:1.5rem; opacity:.7; }
        .qr-percent { font-size:1.4rem; font-weight:700; opacity:.85; margin-top:6px; }
        .qr-verdict { font-size:1.1rem; font-weight:700; margin-top:12px; }
        .qr-meta { display:flex; flex-wrap:wrap; gap:12px; justify-content:center; margin-top:16px; }
        .qr-meta-item { background:rgba(255,255,255,.15); border-radius:20px; padding:5px 14px; font-size:.82rem; font-weight:600; }

        /* ── Answer cards ── */
        .qr-answer {
            background:#fff; border-radius:12px; padding:20px 24px; margin-bottom:14px;
            border-left:4px solid #E2E8F0;
        }
        .qr-answer--correct { border-left-color:#16A34A; }
        .qr-answer--wrong { border-left-color:#DC2626; }
        .qr-answer--partial { border-left-color:#F59E0B; }
        .qr-answer--pending { border-left-color:#3B82F6; }
        .qr-answer__header { display:flex; align-items:flex-start; justify-content:space-between; gap:12px; margin-bottom:8px; }
        .qr-answer__num { font-weight:800; font-size:.82rem; color:#64748B; white-space:nowrap; }
        .qr-answer__content { font-weight:600; font-size:.95rem; color:#0F172A; flex:1; line-height:1.5; white-space:pre-line; }
        .qr-score-badge { white-space:nowrap; }
        .qr-score-badge--correct { color:#16A34A; font-weight:800; }
        .qr-score-badge--wrong { color:#DC2626; font-weight:800; }
        .qr-score-badge--pending { color:#3B82F6; font-weight:800; }
        .qr-option { display:flex; align-items:center; gap:8px; padding:8px 12px; border-radius:8px; margin-bottom:5px; font-size:.88rem; }
        .qr-option--selected-correct { background:#DCFCE7; color:#166534; font-weight:700; }
        .qr-option--selected-wrong { background:#FEF2F2; color:#991B1B; }
        .qr-option--correct-not-selected { background:#F0FDF4; color:#166534; border:1px dashed #86EFAC; }
        .qr-option--neutral { background:#F8FAFC; color:#475569; }
        .qr-answer-text { background:#F8FAFC; border-radius:8px; padding:10px 14px; font-size:.88rem; color:#334155; white-space:pre-wrap; }
        .qr-explanation { background:#FFFBEB; border:1px solid #FDE68A; border-radius:8px; padding:12px 16px; margin-top:10px; font-size:.85rem; color:#78350F; line-height:1.5; }

        /* ── Actions ── */
        .qr-actions { display:flex; gap:12px; flex-wrap:wrap; justify-content:center; margin-top:24px; margin-bottom:40px; }
        .qr-btn { display:inline-flex; align-items:center; gap:6px; border-radius:10px; padding:12px 22px; font-size:.9rem; font-weight:700; text-decoration:none; cursor:pointer; border:none; }
        .qr-btn--primary { background:#2563EB; color:#fff; }
        .qr-btn--primary:hover { background:#1D4ED8; color:#fff; }
        .qr-btn--outline { background:#fff; color:#475569; border:1.5px solid #E2E8F0; }
        .qr-btn--outline:hover { border-color:#3B82F6; color:#2563EB; }
        .qr-btn--retry { background:#16A34A; color:#fff; }
        .qr-btn--retry:hover { background:#15803D; color:#fff; }
    </style>
</head>
<body>
<jsp:include page="/WEB-INF/views/common/navbar.jsp"/>
<main class="shell shell--narrow">
    <a class="back-link" href="${pageContext.request.contextPath}/courses/${courseId}/quizzes/${quizId}">
        ← Thông tin bài kiểm tra
    </a>

    <c:if test="${not empty success}"><div class="alert alert--success"><c:out value="${success}"/></div></c:if>

    <!-- Score hero -->
    <c:choose>
        <c:when test="${attempt.resultStatus ne 'PUBLISHED'}">
            <div class="qr-hero qr-hero--pending">
                <p class="qr-hero__eyebrow">📤 Bài làm · Lần ${attempt.attemptNumber}</p>
                <div class="qr-score">✓</div>
                <p class="qr-verdict">Đã nộp bài thành công!</p>
                <p style="opacity:.75;margin-top:8px;font-size:.9rem;">
                    Giảng viên đang chấm điểm và sẽ sớm công bố kết quả.
                </p>
                <div class="qr-meta">
                    <c:if test="${attempt.submittedAt != null}">
                        <span class="qr-meta-item">📅 Nộp lúc ${fn:replace(fn:substring(attempt.submittedAt, 0, 16), 'T', ' ')}</span>
                    </c:if>
                    <span class="qr-meta-item">🔄 Lần ${attempt.attemptNumber}</span>
                </div>
            </div>
            <div class="qr-actions">
                <a class="qr-btn qr-btn--outline" href="${pageContext.request.contextPath}/courses/${courseId}/quizzes/${quizId}">
                    ← Quay lại bài kiểm tra
                </a>
                <a class="qr-btn qr-btn--outline" href="${pageContext.request.contextPath}/courses/${courseId}/learn">
                    📚 Tiếp tục học
                </a>
            </div>
        </c:when>

        <c:otherwise>
            <%-- Calculate percent --%>
            <c:set var="pct" value="0"/>
            <c:if test="${attempt.maxScore != null and attempt.maxScore > 0 and attempt.score != null}">
                <fmt:formatNumber var="pct" value="${attempt.score / attempt.maxScore * 100}" maxFractionDigits="0"/>
            </c:if>

            <%-- Determine pass/fail --%>
            <c:set var="passed" value="${attempt.quiz.passingScore == null or pct >= attempt.quiz.passingScore}"/>

            <div class="qr-hero ${passed ? 'qr-hero--pass' : 'qr-hero--fail'}">
                <p class="qr-hero__eyebrow">Kết quả · Lần ${attempt.attemptNumber}</p>
                <div>
                    <span class="qr-score">
                        <fmt:formatNumber value="${attempt.score}" maxFractionDigits="2"/>
                    </span>
                    <span class="qr-score__max"> / <fmt:formatNumber value="${attempt.maxScore}" maxFractionDigits="2"/></span>
                </div>
                <p class="qr-percent">${pct}%</p>
                <p class="qr-verdict">
                    <c:choose>
                        <c:when test="${passed}">🎉 Chúc mừng! Bạn đã qua bài kiểm tra.</c:when>
                        <c:otherwise>😔 Chưa đạt yêu cầu. Hãy ôn lại và thử lại!</c:otherwise>
                    </c:choose>
                </p>
                <div class="qr-meta">
                    <c:if test="${attempt.submittedAt != null}">
                        <span class="qr-meta-item">📅 ${fn:replace(fn:substring(attempt.submittedAt, 0, 16), 'T', ' ')}</span>
                    </c:if>
                    <c:if test="${attempt.quiz.passingScore != null}">
                        <span class="qr-meta-item">🎯 Yêu cầu: ${attempt.quiz.passingScore}%</span>
                    </c:if>
                </div>
            </div>

            <!-- Detailed answers -->
            <h2 style="margin-bottom:16px;font-size:1.1rem;color:#0F172A;">📋 Chi tiết từng câu</h2>

            <c:forEach var="a" items="${answers}" varStatus="st">
                <c:set var="isCorrect" value="${a.awardedScore != null and a.awardedScore >= a.maxScore}"/>
                <c:set var="isPending" value="${a.awardedScore == null}"/>
                <c:set var="isPartial" value="${not isPending and a.awardedScore > 0 and a.awardedScore < a.maxScore}"/>
                <c:set var="isWrong" value="${not isPending and a.awardedScore == 0}"/>

                <div class="qr-answer
                    <c:choose>
                        <c:when test='${isCorrect}'>qr-answer--correct</c:when>
                        <c:when test='${isPending}'>qr-answer--pending</c:when>
                        <c:when test='${isPartial}'>qr-answer--partial</c:when>
                        <c:otherwise>qr-answer--wrong</c:otherwise>
                    </c:choose>">

                    <div class="qr-answer__header">
                        <span class="qr-answer__num">Câu ${st.count}</span>
                        <p class="qr-answer__content"><c:out value="${a.questionContentSnapshot}"/></p>
                        <span class="qr-score-badge
                            <c:choose>
                                <c:when test='${isCorrect}'>qr-score-badge--correct</c:when>
                                <c:when test='${isPending}'>qr-score-badge--pending</c:when>
                                <c:otherwise>qr-score-badge--wrong</c:otherwise>
                            </c:choose>">
                            <c:choose>
                                <c:when test="${isPending}">⏳ Chờ chấm</c:when>
                                <c:when test="${isCorrect}">✅ +<fmt:formatNumber value="${a.awardedScore}" maxFractionDigits="1"/></c:when>
                                <c:when test="${isPartial}">🟡 +<fmt:formatNumber value="${a.awardedScore}" maxFractionDigits="1"/></c:when>
                                <c:otherwise>❌ 0</c:otherwise>
                            </c:choose>
                            / <fmt:formatNumber value="${a.maxScore}" maxFractionDigits="1"/>
                        </span>
                    </div>

                    <%-- Selected options for CHOICE types --%>
                    <c:if test="${not empty a.selectedOptions}">
                        <div style="margin-top:8px;">
                            <c:forEach var="so" items="${a.selectedOptions}">
                                <div class="qr-option qr-option--selected-${isCorrect ? 'correct' : 'wrong'}">
                                    <c:choose>
                                        <c:when test="${isCorrect}">✅</c:when>
                                        <c:otherwise>✗</c:otherwise>
                                    </c:choose>
                                    <span>Bạn chọn: <c:out value="${so.optionContentSnapshot}"/></span>
                                </div>
                            </c:forEach>
                        </div>
                    </c:if>

                    <%-- Text answer --%>
                    <c:if test="${empty a.selectedOptions and not empty a.answerText}">
                        <div class="qr-answer-text" style="margin-top:8px;">
                            <strong>Câu trả lời của bạn:</strong><br/>
                            <c:out value="${a.answerText}"/>
                        </div>
                    </c:if>
                    <c:if test="${empty a.selectedOptions and empty a.answerText}">
                        <p style="color:#94A3B8;font-style:italic;font-size:.85rem;margin-top:8px;">(Bỏ trống)</p>
                    </c:if>

                    <%-- Explanation --%>
                    <c:if test="${not empty a.question.explanation}">
                        <div class="qr-explanation">
                            💡 <strong>Giải thích:</strong> <c:out value="${a.question.explanation}"/>
                        </div>
                    </c:if>
                </div>
            </c:forEach>

            <!-- Actions -->
            <div class="qr-actions">
                <a class="qr-btn qr-btn--outline" href="${pageContext.request.contextPath}/courses/${courseId}/quizzes/${quizId}">
                    ← Thông tin bài kiểm tra
                </a>
                <a class="qr-btn qr-btn--outline" href="${pageContext.request.contextPath}/courses/${courseId}/learn">
                    📚 Tiếp tục học
                </a>
            </div>
        </c:otherwise>
    </c:choose>
</main>
<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</body>
</html>
