<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
            <%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
                <!DOCTYPE html>
                <html lang="vi">

                <head>
                    <meta charset="UTF-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1.0">
                    <title>Kết quả bài làm — EduSphere</title>
                    <link rel="preconnect" href="https://fonts.googleapis.com">
                    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap"
                        rel="stylesheet">
                    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/home.css">
                    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/quiz.css?v=2.0">
                </head>

                <body>
                    <jsp:include page="/WEB-INF/views/common/navbar.jsp" />

                    <div class="quiz-page-wrap">
                        <main class="quiz-shell quiz-shell--narrow">
                            <a class="quiz-back-link"
                                href="${pageContext.request.contextPath}/courses/${courseId}/quizzes/${quizId}">
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                    stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
                                    <path d="M19 12H5M12 19l-7-7 7-7" />
                                </svg>
                                Thông tin bài kiểm tra
                            </a>

                            <c:if test="${not empty success}">
                                <div class="quiz-alert quiz-alert--success">
                                    <span>✅</span>
                                    <c:out value="${success}" />
                                </div>
                            </c:if>

                            <c:choose>
                                <%-- 1. Chưa công bố kết quả (Chờ giảng viên chấm) --%>
                                    <c:when test="${attempt.resultStatus ne 'PUBLISHED'}">
                                        <div class="quiz-hero quiz-hero--pending" style="text-align:center;">
                                            <p class="quiz-hero__eyebrow" style="justify-content:center;">
                                                <span>📤</span> BÀI LÀM · LẦN ${attempt.attemptNumber}
                                            </p>
                                            <div
                                                style="width:72px; height:72px; margin:16px auto; background:rgba(255,255,255,0.2); border-radius:50%; display:flex; align-items:center; justify-content:center; font-size:2.5rem; color:#fff; border:2px solid rgba(255,255,255,0.35);">
                                                ✓
                                            </div>
                                            <h1 class="quiz-hero__title" style="margin-bottom:8px !important;">Đã nộp
                                                bài thành công!</h1>
                                            <p class="quiz-hero__desc" style="margin:0 auto 20px !important;">
                                                Bài làm của bạn đã được ghi nhận. Giảng viên đang chấm điểm và sẽ sớm
                                                công bố kết quả.
                                            </p>
                                            <div class="quiz-hero__chips" style="justify-content:center;">
                                                <c:if test="${attempt.submittedAt != null}">
                                                    <span class="quiz-hero__chip">
                                                        📅 Nộp lúc ${attempt.submittedAt}
                                                    </span>
                                                </c:if>
                                                <span class="quiz-hero__chip">🔄 Lần làm bài:
                                                    ${attempt.attemptNumber}</span>
                                            </div>
                                        </div>

                                        <div style="display:flex; gap:14px; justify-content:center; margin-top:28px;">
                                            <a class="quiz-btn quiz-btn--outline"
                                                href="${pageContext.request.contextPath}/courses/${courseId}/quizzes/${quizId}">
                                                ← Quay lại bài kiểm tra
                                            </a>
                                            <a class="quiz-btn quiz-btn--primary"
                                                href="${pageContext.request.contextPath}/courses/${courseId}/learn">
                                                📚 Tiếp tục học khóa học
                                            </a>
                                        </div>
                                    </c:when>

                                    <%-- 2. Đã công bố kết quả --%>
                                        <c:otherwise>
                                            <%-- Tính toán phần trăm điểm --%>
                                                <c:set var="pct" value="0" />
                                                <c:if
                                                    test="${attempt.maxScore != null and attempt.maxScore > 0 and attempt.score != null}">
                                                    <fmt:formatNumber var="pct"
                                                        value="${attempt.score / attempt.maxScore * 100}"
                                                        maxFractionDigits="0" />
                                                </c:if>

                                                <%-- Xác định đỗ / trượt --%>
                                                    <c:set var="passed"
                                                        value="${attempt.quiz.passingScore == null or pct >= attempt.quiz.passingScore}" />

                                                    <div class="quiz-hero ${passed ? 'quiz-hero--pass' : 'quiz-hero--fail'}"
                                                        style="text-align:center;">
                                                        <p class="quiz-hero__eyebrow" style="justify-content:center;">
                                                            <span>${passed ? '🎉' : '📊'}</span> KẾT QUẢ KIỂM TRA · LẦN
                                                            ${attempt.attemptNumber}
                                                        </p>

                                                        <div class="quiz-score-panel">
                                                            <div>
                                                                <span class="quiz-score-val">
                                                                    <fmt:formatNumber value="${attempt.score}"
                                                                        maxFractionDigits="2" />
                                                                </span>
                                                                <span class="quiz-score-max"> /
                                                                    <fmt:formatNumber value="${attempt.maxScore}"
                                                                        maxFractionDigits="2" />
                                                                </span>
                                                            </div>
                                                            <div class="quiz-score-pct">${pct}%</div>
                                                        </div>

                                                        <p class="quiz-verdict-text">
                                                            <c:choose>
                                                                <c:when test="${passed}">🎉 Chúc mừng bạn đã hoàn thành
                                                                    và vượt qua bài kiểm tra!</c:when>
                                                                <c:otherwise>😔 Rất tiếc, điểm của bạn chưa đạt yêu cầu.
                                                                    Hãy ôn lại bài học và thử lại!</c:otherwise>
                                                            </c:choose>
                                                        </p>

                                                        <div class="quiz-hero__chips"
                                                            style="justify-content:center; margin-top:20px;">
                                                            <c:if test="${attempt.submittedAt != null}">
                                                                <span class="quiz-hero__chip">📅
                                                                    ${attempt.submittedAt}</span>
                                                            </c:if>
                                                            <c:if test="${attempt.quiz.passingScore != null}">
                                                                <span class="quiz-hero__chip">🎯 Điểm đạt:
                                                                    ${attempt.quiz.passingScore}%</span>
                                                            </c:if>
                                                        </div>
                                                    </div>

                                                    <!-- Detailed answers list -->
                                                    <div
                                                        style="margin-top:32px; margin-bottom:20px; display:flex; align-items:center; justify-content:space-between;">
                                                        <h2
                                                            style="font-size:1.2rem; font-weight:800; color:#0F172A; margin:0;">
                                                            📋 Chi tiết bài làm từng câu hỏi
                                                        </h2>
                                                        <span
                                                            style="font-size:.85rem; color:#64748B; font-weight:600;">Tổng
                                                            cộng: ${fn:length(answers)} câu</span>
                                                    </div>

                                                    <c:forEach var="a" items="${answers}" varStatus="st">
                                                        <c:set var="isCorrect"
                                                            value="${a.awardedScore != null and a.awardedScore >= a.maxScore}" />
                                                        <c:set var="isPending" value="${a.awardedScore == null}" />
                                                        <c:set var="isPartial"
                                                            value="${not isPending and a.awardedScore > 0 and a.awardedScore < a.maxScore}" />
                                                        <c:set var="isWrong"
                                                            value="${not isPending and a.awardedScore == 0}" />

                                                        <div class="quiz-qcard
                        <c:choose>
                            <c:when test='${isCorrect}'>quiz-qcard--correct</c:when>
                            <c:when test='${isPending}'>quiz-qcard--pending</c:when>
                            <c:when test='${isPartial}'>quiz-qcard--partial</c:when>
                            <c:otherwise>quiz-qcard--wrong</c:otherwise>
                        </c:choose>">

                                                            <div class="quiz-qcard__header">
                                                                <span class="quiz-qcard__num">Câu hỏi ${st.count}</span>
                                                                <span class="quiz-qcard__score"
                                                                    style="color:${isCorrect ? '#10B981' : (isPending ? '#1B9AF5' : (isPartial ? '#F59E0B' : '#EF4444'))};">
                                                                    <c:choose>
                                                                        <c:when test="${isPending}">⏳ Đang chờ chấm
                                                                        </c:when>
                                                                        <c:when test="${isCorrect}">✅ +
                                                                            <fmt:formatNumber value="${a.awardedScore}"
                                                                                maxFractionDigits="1" />
                                                                        </c:when>
                                                                        <c:when test="${isPartial}">🟡 +
                                                                            <fmt:formatNumber value="${a.awardedScore}"
                                                                                maxFractionDigits="1" />
                                                                        </c:when>
                                                                        <c:otherwise>❌ 0</c:otherwise>
                                                                    </c:choose>
                                                                    /
                                                                    <fmt:formatNumber value="${a.maxScore}"
                                                                        maxFractionDigits="1" /> điểm
                                                                </span>
                                                            </div>

                                                            <div class="quiz-qcard__title">
                                                                <c:out value="${a.questionContentSnapshot}" />
                                                            </div>

                                                            <%-- Selected options for CHOICE questions --%>
                                                                <c:if test="${not empty a.selectedOptions}">
                                                                    <div style="margin-top:12px;">
                                                                        <c:forEach var="so"
                                                                            items="${a.selectedOptions}">
                                                                            <div
                                                                                class="quiz-opt-result ${isCorrect ? 'quiz-opt-result--correct' : 'quiz-opt-result--wrong'}">
                                                                                <span
                                                                                    style="font-weight:800; font-size:1.1rem;">
                                                                                    <c:choose>
                                                                                        <c:when test="${isCorrect}">✓
                                                                                        </c:when>
                                                                                        <c:otherwise>✕</c:otherwise>
                                                                                    </c:choose>
                                                                                </span>
                                                                                <span>Bạn đã chọn: <strong>
                                                                                        <c:out
                                                                                            value="${so.optionContentSnapshot}" />
                                                                                    </strong></span>
                                                                            </div>
                                                                        </c:forEach>
                                                                    </div>
                                                                </c:if>

                                                                <%-- Text answer for ESSAY questions --%>
                                                                    <c:if
                                                                        test="${empty a.selectedOptions and not empty a.answerText}">
                                                                        <div
                                                                            style="background:#F8FAFC; border:1px solid #E2E8F0; border-radius:10px; padding:12px 16px; margin-top:10px; font-size:.92rem; color:#334155;">
                                                                            <span
                                                                                style="font-weight:700; color:#64748B; font-size:.82rem; text-transform:uppercase; display:block; margin-bottom:4px;">Câu
                                                                                trả lời của bạn:</span>
                                                                            <div style="white-space:pre-wrap;">
                                                                                <c:out value="${a.answerText}" />
                                                                            </div>
                                                                        </div>
                                                                    </c:if>
                                                                    <c:if
                                                                        test="${empty a.selectedOptions and empty a.answerText}">
                                                                        <p
                                                                            style="color:#94A3B8; font-style:italic; font-size:.85rem; margin-top:10px;">
                                                                            (Học viên bỏ trống câu này)</p>
                                                                    </c:if>

                                                                    <%-- Explanation if present --%>
                                                                        <c:if
                                                                            test="${not empty a.question.explanation}">
                                                                            <div class="quiz-explanation-box">
                                                                                💡 <strong>Giải thích đáp án:</strong>
                                                                                <c:out
                                                                                    value="${a.question.explanation}" />
                                                                            </div>
                                                                        </c:if>
                                                        </div>
                                                    </c:forEach>

                                                    <!-- Actions -->
                                                    <div
                                                        style="display:flex; gap:14px; justify-content:center; margin-top:32px; flex-wrap:wrap;">
                                                        <a class="quiz-btn quiz-btn--outline"
                                                            href="${pageContext.request.contextPath}/courses/${courseId}/quizzes/${quizId}">
                                                            ← Quay lại thông tin bài kiểm tra
                                                        </a>
                                                        <a class="quiz-btn quiz-btn--primary"
                                                            href="${pageContext.request.contextPath}/courses/${courseId}/learn">
                                                            📚 Tiếp tục học khóa học
                                                        </a>
                                                    </div>
                                        </c:otherwise>
                            </c:choose>
                        </main>
                    </div>

                    <jsp:include page="/WEB-INF/views/common/footer.jsp" />
                </body>

                </html>