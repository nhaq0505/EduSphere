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
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/home.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/quiz.css?v=2.1">
</head>
<body>
    <jsp:include page="/WEB-INF/views/common/navbar.jsp" />

    <div class="quiz-page-wrap">
        <main class="quiz-shell quiz-shell--narrow">
            <a class="quiz-back-link" href="${pageContext.request.contextPath}/courses/${courseId}/quizzes/${quizId}">
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

            <%-- Đếm số câu tự luận đang chờ giảng viên chấm điểm --%>
            <c:set var="pendingManualCount" value="0"/>
            <c:forEach var="ans" items="${answers}">
                <c:if test="${ans.awardedScore == null}">
                    <c:set var="pendingManualCount" value="${pendingManualCount + 1}"/>
                </c:if>
            </c:forEach>
            <c:set var="hasPendingManual" value="${pendingManualCount > 0 or attempt.status eq 'SUBMITTED'}"/>

            <c:choose>
                <%-- Trường hợp A: Còn câu tự luận đang chờ giảng viên chấm --%>
                <c:when test="${hasPendingManual}">
                    <div class="quiz-hero quiz-hero--pending" style="text-align:center;">
                        <p class="quiz-hero__eyebrow" style="justify-content:center;">
                            <span>📝</span> BÀI LÀM · LẦN ${attempt.attemptNumber}
                        </p>
                        <h1 class="quiz-hero__title" style="margin-bottom:8px !important;">Đã ghi nhận bài nộp!</h1>

                        <div class="quiz-score-panel">
                            <div style="font-size:0.88rem; color:rgba(255,255,255,0.85); font-weight:700; text-transform:uppercase; letter-spacing:0.05em; margin-bottom:6px;">
                                Điểm trắc nghiệm đã chấm tự động
                            </div>
                            <div>
                                <span class="quiz-score-val">
                                    <fmt:formatNumber value="${attempt.score != null ? attempt.score : 0}" maxFractionDigits="2" />
                                </span>
                                <span class="quiz-score-max"> /
                                    <fmt:formatNumber value="${attempt.maxScore}" maxFractionDigits="2" /> điểm
                                </span>
                            </div>
                        </div>

                        <p class="quiz-hero__desc" style="margin:0 auto 16px !important;">
                            Điểm của các câu hỏi trắc nghiệm đã được hệ thống tự động chấm và công bố ngay bên dưới.
                            Giảng viên sẽ chấm các câu tự luận còn lại trước khi tổng kết điểm chính thức.
                        </p>

                        <div class="quiz-hero__chips" style="justify-content:center;">
                            <c:if test="${attempt.submittedAt != null}">
                                <span class="quiz-hero__chip">
                                    📅 Nộp lúc ${attempt.submittedAt}
                                </span>
                            </c:if>
                            <span class="quiz-hero__chip" style="background:#FEF3C7; color:#92400E; border:1px solid #FCD34D;">
                                ⏳ Còn ${pendingManualCount} câu tự luận chờ giảng viên chấm
                            </span>
                        </div>
                    </div>
                </c:when>

                <%-- Trường hợp B: Toàn bộ câu hỏi đã có điểm (Tự động hoặc Giảng viên đã chấm xong) --%>
                <c:otherwise>
                    <%-- Tính toán phần trăm điểm --%>
                    <c:set var="pct" value="0" />
                    <c:if test="${attempt.maxScore != null and attempt.maxScore > 0 and attempt.score != null}">
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
                            <span>${passed ? '🎉' : '📊'}</span> KẾT QUẢ KIỂM TRA · LẦN ${attempt.attemptNumber}
                        </p>

                        <div class="quiz-score-panel">
                            <div>
                                <span class="quiz-score-val">
                                    <fmt:formatNumber value="${attempt.score}" maxFractionDigits="2" />
                                </span>
                                <span class="quiz-score-max"> /
                                    <fmt:formatNumber value="${attempt.maxScore}" maxFractionDigits="2" />
                                </span>
                            </div>
                            <div class="quiz-score-pct">${pct}%</div>
                        </div>

                        <p class="quiz-verdict-text">
                            <c:choose>
                                <c:when test="${passed}">🎉 Chúc mừng bạn đã hoàn thành và vượt qua bài kiểm tra!</c:when>
                                <c:otherwise>😔 Rất tiếc, điểm của bạn chưa đạt yêu cầu. Hãy ôn lại bài học và thử lại!</c:otherwise>
                            </c:choose>
                        </p>

                        <div class="quiz-hero__chips" style="justify-content:center; margin-top:20px;">
                            <c:if test="${attempt.submittedAt != null}">
                                <span class="quiz-hero__chip">📅 ${attempt.submittedAt}</span>
                            </c:if>
                            <c:if test="${attempt.quiz.passingScore != null}">
                                <span class="quiz-hero__chip">🎯 Điểm đạt: ${attempt.quiz.passingScore}%</span>
                            </c:if>
                        </div>
                    </div>
                </c:otherwise>
            </c:choose>

            <!-- Detailed answers list (Luôn hiển thị chi tiết câu hỏi cho học sinh) -->
            <div style="margin-top:32px; margin-bottom:20px; display:flex; align-items:center; justify-content:space-between;">
                <h2 style="font-size:1.2rem; font-weight:800; color:#0F172A; margin:0;">
                    📋 Chi tiết bài làm từng câu hỏi
                </h2>
                <span style="font-size:.85rem; color:#64748B; font-weight:600;">Tổng cộng: ${fn:length(answers)} câu</span>
            </div>

            <c:forEach var="a" items="${answers}" varStatus="st">
                <c:set var="isPending" value="${a.awardedScore == null}" />
                <c:set var="isCorrect" value="${not isPending and a.awardedScore >= a.maxScore}" />
                <c:set var="isPartial" value="${not isPending and a.awardedScore > 0 and a.awardedScore < a.maxScore}" />
                <c:set var="isWrong" value="${not isPending and a.awardedScore == 0}" />

                <div class="quiz-qcard
                    <c:choose>
                        <c:when test='${isPending}'>quiz-qcard--pending</c:when>
                        <c:when test='${isCorrect}'>quiz-qcard--correct</c:when>
                        <c:when test='${isPartial}'>quiz-qcard--partial</c:when>
                        <c:otherwise>quiz-qcard--wrong</c:otherwise>
                    </c:choose>">

                    <div class="quiz-qcard__header">
                        <span class="quiz-qcard__num">Câu hỏi ${st.count}</span>
                        <span class="quiz-qcard__score"
                            style="color:${isPending ? '#1B9AF5' : (isCorrect ? '#10B981' : (isPartial ? '#F59E0B' : '#EF4444'))};">
                            <c:choose>
                                <c:when test="${isPending}">⏳ Đang chờ chấm</c:when>
                                <c:when test="${isCorrect}">✅ +<fmt:formatNumber value="${a.awardedScore}" maxFractionDigits="1" /></c:when>
                                <c:when test="${isPartial}">🟡 +<fmt:formatNumber value="${a.awardedScore}" maxFractionDigits="1" /></c:when>
                                <c:otherwise>❌ 0</c:otherwise>
                            </c:choose>
                            / <fmt:formatNumber value="${a.maxScore}" maxFractionDigits="1" /> điểm
                        </span>
                    </div>

                    <div class="quiz-qcard__title">
                        <c:out value="${a.questionContentSnapshot}" />
                    </div>

                    <%-- Single / Multiple Choice --%>
                    <c:if test="${not empty a.selectedOptions}">
                        <div style="margin-top:12px;">
                            <c:forEach var="so" items="${a.selectedOptions}">
                                <div class="quiz-opt-result ${isCorrect ? 'quiz-opt-result--correct' : 'quiz-opt-result--wrong'}">
                                    <span style="font-weight:800; font-size:1.1rem;">
                                        <c:choose>
                                            <c:when test="${isCorrect}">✓</c:when>
                                            <c:otherwise>✕</c:otherwise>
                                        </c:choose>
                                    </span>
                                    <span>Bạn đã chọn: <strong><c:out value="${so.optionContentSnapshot}" /></strong></span>
                                </div>
                            </c:forEach>
                        </div>
                        <%-- Hiển thị đáp án đúng nếu trả lời sai --%>
                        <c:if test="${not isCorrect and not empty a.question and not empty a.question.options}">
                            <div style="margin-top:6px;">
                                <c:forEach var="opt" items="${a.question.options}">
                                    <c:if test="${opt.correct}">
                                        <div class="quiz-opt-result quiz-opt-result--missed">
                                            <span style="font-weight:800; font-size:1.1rem;">✓</span>
                                            <span>Đáp án đúng: <strong><c:out value="${opt.content}" /></strong></span>
                                        </div>
                                    </c:if>
                                </c:forEach>
                            </div>
                        </c:if>
                    </c:if>

                    <%-- True / False questions --%>
                    <c:if test="${a.questionTypeSnapshot eq 'TRUE_FALSE'}">
                        <div style="margin-top:12px;">
                            <div class="quiz-opt-result ${isCorrect ? 'quiz-opt-result--correct' : 'quiz-opt-result--wrong'}">
                                <span style="font-weight:800; font-size:1.1rem;">${isCorrect ? '✓' : '✕'}</span>
                                <span>Bạn đã chọn: <strong>
                                    <c:choose>
                                        <c:when test="${a.answerText eq 'TRUE' or a.answerText eq 'true'}">Đúng</c:when>
                                        <c:when test="${a.answerText eq 'FALSE' or a.answerText eq 'false'}">Sai</c:when>
                                        <c:otherwise><c:out value="${a.answerText}" /></c:otherwise>
                                    </c:choose>
                                </strong></span>
                            </div>
                            <c:if test="${not isCorrect and not empty a.question and not empty a.question.correctAnswer}">
                                <div class="quiz-opt-result quiz-opt-result--missed">
                                    <span style="font-weight:800; font-size:1.1rem;">✓</span>
                                    <span>Đáp án đúng: <strong>
                                        <c:choose>
                                            <c:when test="${a.question.correctAnswer eq 'TRUE' or a.question.correctAnswer eq 'true'}">Đúng</c:when>
                                            <c:when test="${a.question.correctAnswer eq 'FALSE' or a.question.correctAnswer eq 'false'}">Sai</c:when>
                                            <c:otherwise><c:out value="${a.question.correctAnswer}" /></c:otherwise>
                                        </c:choose>
                                    </strong></span>
                                </div>
                            </c:if>
                        </div>
                    </c:if>

                    <%-- Text answer for SHORT_ANSWER or ESSAY --%>
                    <c:if test="${a.questionTypeSnapshot eq 'SHORT_ANSWER' or a.questionTypeSnapshot eq 'ESSAY' or (empty a.selectedOptions and a.questionTypeSnapshot ne 'TRUE_FALSE')}">
                        <c:choose>
                            <c:when test="${not empty a.answerText}">
                                <div style="background:#F8FAFC; border:1px solid #E2E8F0; border-radius:10px; padding:12px 16px; margin-top:10px; font-size:.92rem; color:#334155;">
                                    <span style="font-weight:700; color:#64748B; font-size:.82rem; text-transform:uppercase; display:block; margin-bottom:4px;">Câu trả lời của bạn:</span>
                                    <div style="white-space:pre-wrap;"><c:out value="${a.answerText}" /></div>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <p style="color:#94A3B8; font-style:italic; font-size:.85rem; margin-top:10px;">(Học viên bỏ trống câu này)</p>
                            </c:otherwise>
                        </c:choose>

                        <c:if test="${isPending}">
                            <div style="margin-top:8px; font-size:0.85rem; color:#2563EB; font-weight:600; display:flex; align-items:center; gap:6px;">
                                <span>⏳</span> Câu hỏi tự luận đang chờ giảng viên chấm điểm.
                            </div>
                        </c:if>
                    </c:if>

                    <%-- Explanation if present and graded --%>
                    <c:if test="${not isPending and not empty a.question and not empty a.question.explanation}">
                        <div class="quiz-explanation-box">
                            💡 <strong>Giải thích đáp án:</strong>
                            <c:out value="${a.question.explanation}" />
                        </div>
                    </c:if>
                </div>
            </c:forEach>

            <!-- Actions -->
            <div style="display:flex; gap:14px; justify-content:center; margin-top:32px; flex-wrap:wrap;">
                <a class="quiz-btn quiz-btn--outline"
                    href="${pageContext.request.contextPath}/courses/${courseId}/quizzes/${quizId}">
                    ← Quay lại thông tin bài kiểm tra
                </a>
                <a class="quiz-btn quiz-btn--primary"
                    href="${pageContext.request.contextPath}/courses/${courseId}/learn">
                    📚 Tiếp tục học khóa học
                </a>
            </div>
        </main>
    </div>

    <jsp:include page="/WEB-INF/views/common/footer.jsp" />
</body>
</html>
