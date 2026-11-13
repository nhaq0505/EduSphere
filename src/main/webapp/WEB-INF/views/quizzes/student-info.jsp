<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><c:out value="${quiz.title}"/> — EduSphere</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/home.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/quiz.css?v=2.0">
</head>
<body>
<jsp:include page="/WEB-INF/views/common/navbar.jsp"/>

<div class="quiz-page-wrap">
    <main class="quiz-shell">
        <!-- Top Navigation -->
        <div class="quiz-nav-top">
            <a class="quiz-back-link" href="${pageContext.request.contextPath}/courses/${courseId}/learn">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><path d="M19 12H5M12 19l-7-7 7-7"/></svg>
                Quay lại khóa học
            </a>
            <c:if test="${quiz.course != null}">
                <div class="quiz-nav-crumb">
                    <span>/</span>
                    <span class="quiz-nav-crumb__cur"><c:out value="${quiz.course.title}"/></span>
                </div>
            </c:if>
        </div>

        <!-- Hero -->
        <div class="quiz-hero quiz-hero--info">
            <div class="quiz-hero__pattern"></div>
            <div class="quiz-hero__pattern-2"></div>
            <div class="quiz-hero__body">
                <!-- Main Info -->
                <div class="quiz-hero__main">
                    <div class="quiz-hero__eyebrow-badge">
                        <span>📝</span> BÀI KIỂM TRA ĐÁNH GIÁ
                    </div>
                    <h1 class="quiz-hero__title"><c:out value="${quiz.title}"/></h1>
                    <c:if test="${not empty quiz.description}">
                        <p class="quiz-hero__desc"><c:out value="${quiz.description}"/></p>
                    </c:if>
                    <div class="quiz-hero__chips">
                        <span class="quiz-hero__chip">
                            ⏱ <c:choose>
                                <c:when test="${quiz.timeLimitMinutes != null}">${quiz.timeLimitMinutes} phút</c:when>
                                <c:otherwise>Không giới hạn thời gian</c:otherwise>
                            </c:choose>
                        </span>
                        <span class="quiz-hero__chip">🔄 Không giới hạn lượt làm</span>
                        <c:if test="${quiz.passingScore != null}">
                            <span class="quiz-hero__chip">🎯 Điểm đạt: ${quiz.passingScore}%</span>
                        </c:if>
                        <c:if test="${quiz.lesson != null}">
                            <span class="quiz-hero__chip">📖 Bài học: <c:out value="${quiz.lesson.title}"/></span>
                        </c:if>
                    </div>
                </div>

                <!-- Aside Glass Card -->
                <div class="quiz-hero__aside">
                    <c:set var="bestScore" value="-1"/>
                    <c:set var="maxPossibleScore" value="10"/>
                    <c:set var="hasCompleted" value="false"/>
                    <c:forEach var="a" items="${myAttempts}">
                        <c:if test="${a.status eq 'SCORED' or a.status eq 'SUBMITTED'}">
                            <c:set var="hasCompleted" value="true"/>
                            <c:if test="${a.score != null and a.score > bestScore}">
                                <c:set var="bestScore" value="${a.score}"/>
                            </c:if>
                            <c:if test="${a.maxScore != null}">
                                <c:set var="maxPossibleScore" value="${a.maxScore}"/>
                            </c:if>
                        </c:if>
                    </c:forEach>

                    <div class="quiz-hero__glass-card">
                        <c:choose>
                            <c:when test="${hasCompleted and bestScore >= 0}">
                                <div class="quiz-hero__glass-icon">🏆</div>
                                <div class="quiz-hero__glass-label">Điểm cao nhất của bạn</div>
                                <div class="quiz-hero__glass-score">
                                    <fmt:formatNumber value="${bestScore}" maxFractionDigits="1"/>
                                    <span class="quiz-hero__glass-sub">/ <fmt:formatNumber value="${maxPossibleScore}" maxFractionDigits="1"/></span>
                                </div>
                                <div class="quiz-hero__glass-footer">
                                    Đã hoàn thành ${fn:length(myAttempts)} lượt làm
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div class="quiz-hero__glass-icon">🎯</div>
                                <div class="quiz-hero__glass-label">Trạng thái làm bài</div>
                                <div class="quiz-hero__glass-highlight">Sẵn sàng thử sức</div>
                                <div class="quiz-hero__glass-footer">
                                    Không giới hạn lượt làm · <c:choose><c:when test="${quiz.timeLimitMinutes != null}">${quiz.timeLimitMinutes} phút</c:when><c:otherwise>Tự do</c:otherwise></c:choose>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>
        </div>

        <c:if test="${not empty success}">
            <div class="quiz-alert quiz-alert--success">
                <span>✅</span> <c:out value="${success}"/>
            </div>
        </c:if>

        <div class="quiz-layout">
            <div>
                <!-- Rules -->
                <c:if test="${not empty quiz.rules}">
                    <div class="quiz-card">
                        <div class="quiz-card__header">
                            <h2 class="quiz-card__title">
                                <span>⚠️</span> QUY ĐỊNH LÀM BÀI
                            </h2>
                        </div>
                        <div class="quiz-rules-box"><c:out value="${quiz.rules}"/></div>
                    </div>
                </c:if>

                <!-- History -->
                <div class="quiz-card">
                    <div class="quiz-card__header">
                        <h2 class="quiz-card__title">
                            <span>📋</span> LỊCH SỬ LÀM BÀI CỦA BẠN
                        </h2>
                        <c:if test="${not empty myAttempts}">
                            <span class="quiz-badge quiz-badge--submitted">${fn:length(myAttempts)} lần đã làm</span>
                        </c:if>
                    </div>

                    <c:choose>
                        <c:when test="${empty myAttempts}">
                            <div class="quiz-empty-history">
                                <div class="quiz-empty-history__icon">📝</div>
                                <h3>Bạn chưa làm bài kiểm tra này</h3>
                                <p>Nhấn vào nút "Bắt đầu làm bài" ở khung bên phải để thử sức ngay.</p>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="quiz-attempts-list">
                                <c:forEach var="a" items="${myAttempts}">
                                    <div class="quiz-attempt-card">
                                        <div class="quiz-attempt-card__main">
                                            <div class="quiz-attempt-card__header">
                                                <span class="quiz-attempt-card__pill">Lần làm ${a.attemptNumber}</span>
                                                <c:choose>
                                                    <c:when test="${a.status eq 'IN_PROGRESS'}">
                                                        <span class="quiz-badge quiz-badge--progress">⏳ Đang làm</span>
                                                    </c:when>
                                                    <c:when test="${a.status eq 'SCORED'}">
                                                        <span class="quiz-badge quiz-badge--scored">✅ Đã chấm</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="quiz-badge quiz-badge--submitted">📝 Chờ chấm tự luận</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>
                                            <div class="quiz-attempt-card__meta">
                                                <c:if test="${a.submittedAt != null}">
                                                    <span class="quiz-attempt-card__date">
                                                        📅 Nộp lúc ${a.formattedSubmittedAt}
                                                    </span>
                                                </c:if>
                                                <c:if test="${a.score != null and a.status ne 'IN_PROGRESS'}">
                                                    <div class="quiz-attempt-card__score">
                                                        Điểm: <strong><fmt:formatNumber value="${a.score}" maxFractionDigits="2"/> / <fmt:formatNumber value="${a.maxScore}" maxFractionDigits="2"/></strong>
                                                        <c:if test="${a.status eq 'SUBMITTED'}">
                                                            <span class="quiz-attempt-card__subnote">(Trắc nghiệm)</span>
                                                        </c:if>
                                                    </div>
                                                </c:if>
                                            </div>
                                        </div>
                                        <div class="quiz-attempt-card__action">
                                            <c:choose>
                                                <c:when test="${a.status eq 'IN_PROGRESS'}">
                                                    <a class="quiz-btn quiz-btn--primary quiz-btn--sm"
                                                       href="${pageContext.request.contextPath}/courses/${courseId}/quizzes/${quizId}/attempts/${a.attemptId}">
                                                        Tiếp tục →
                                                    </a>
                                                </c:when>
                                                <c:otherwise>
                                                    <a class="quiz-btn quiz-btn--outline quiz-btn--sm"
                                                       href="${pageContext.request.contextPath}/courses/${courseId}/quizzes/${quizId}/attempts/${a.attemptId}/result">
                                                        Xem kết quả →
                                                    </a>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                                    </div>
                                </c:forEach>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>

            <!-- Aside: Action Card -->
            <aside>
                <div class="quiz-card quiz-card--action">
                    <div class="quiz-card__header">
                        <h2 class="quiz-card__title">
                            <span>🚀</span> BẮT ĐẦU LÀM BÀI
                        </h2>
                    </div>

                    <c:set var="attemptCount" value="${fn:length(myAttempts)}"/>
                    <c:set var="hasInProgress" value="false"/>
                    <c:set var="hasPassed" value="false"/>
                    <c:set var="bestScore" value="0"/>
                    <c:set var="bestScorePct" value="0"/>
                    <c:forEach var="a" items="${myAttempts}">
                        <c:if test="${a.status eq 'IN_PROGRESS'}"><c:set var="hasInProgress" value="true"/></c:if>
                        <c:if test="${a.status eq 'SCORED' or a.status eq 'SUBMITTED'}">
                            <c:if test="${a.maxScore != null and a.maxScore > 0 and a.score != null}">
                                <c:set var="pct" value="${a.score / a.maxScore * 100}"/>
                                <c:if test="${pct > bestScorePct}">
                                    <c:set var="bestScorePct" value="${pct}"/>
                                    <c:set var="bestScore" value="${a.score}"/>
                                </c:if>
                                <c:if test="${quiz.passingScore == null or pct >= quiz.passingScore}">
                                    <c:set var="hasPassed" value="true"/>
                                </c:if>
                            </c:if>
                            <c:if test="${quiz.passingScore == null and (a.maxScore == null or a.maxScore == 0)}">
                                <c:set var="hasPassed" value="true"/>
                            </c:if>
                        </c:if>
                    </c:forEach>

                    <c:choose>
                        <%-- 1. Chưa đủ điều kiện video 80% --%>
                        <c:when test="${not videoRequirementMet}">
                            <div class="quiz-notice-box quiz-notice-box--locked">
                                <div style="display:flex; align-items:flex-start; gap:8px;">
                                    <span style="font-size:1.2rem; flex-shrink:0;">🔒</span>
                                    <div>
                                        <strong>Yêu cầu xem video</strong>
                                        <div style="font-size:.84rem; margin-top:2px;">
                                            Bạn cần xem ít nhất <strong>${requiredWatchPercent}%</strong> video bài học để mở khóa.
                                        </div>
                                    </div>
                                </div>
                                <div style="margin-top:10px;">
                                    <div style="display:flex; justify-content:space-between; font-size:.8rem; font-weight:700;">
                                        <span>Tiến độ hiện tại:</span>
                                        <span>${currentWatchPercent}% / ${requiredWatchPercent}%</span>
                                    </div>
                                    <div class="quiz-progress-track">
                                        <div class="quiz-progress-fill" style="width:${currentWatchPercent > 100 ? 100 : currentWatchPercent}%;"></div>
                                    </div>
                                </div>
                            </div>
                            <button class="quiz-btn quiz-btn--cta" disabled style="background:#94A3B8; color:#fff; cursor:not-allowed;">
                                🔒 Bài kiểm tra đang bị khóa
                            </button>
                            <c:if test="${quiz.lesson != null}">
                                <a href="${pageContext.request.contextPath}/courses/${courseId}/lessons/${quiz.lesson.lessonId}"
                                   class="quiz-btn quiz-btn--primary quiz-btn--cta" style="margin-top:10px;">
                                    ▶ Quay lại xem video bài học
                                </a>
                            </c:if>
                        </c:when>

                        <%-- 2. Đang có bài chưa hoàn thành --%>
                        <c:when test="${hasInProgress}">
                            <div class="quiz-notice-box quiz-notice-box--info">
                                <div style="display:flex; align-items:center; gap:8px;">
                                    <span style="font-size:1.2rem;">⏳</span>
                                    <div>
                                        <strong>Bạn có bài làm dở dang</strong>
                                        <div style="font-size:.82rem; margin-top:2px;">Vui lòng hoàn thành bài làm trước khi bắt đầu bài mới.</div>
                                    </div>
                                </div>
                            </div>
                            <c:forEach var="a" items="${myAttempts}">
                                <c:if test="${a.status eq 'IN_PROGRESS'}">
                                    <a class="quiz-btn quiz-btn--primary quiz-btn--cta"
                                       href="${pageContext.request.contextPath}/courses/${courseId}/quizzes/${quizId}/attempts/${a.attemptId}">
                                        Tiếp tục làm bài (Lần ${a.attemptNumber}) →
                                    </a>
                                </c:if>
                            </c:forEach>
                        </c:when>

                        <%-- 3. Đã đạt yêu cầu bài kiểm tra --%>
                        <c:when test="${hasPassed}">
                            <div class="quiz-notice-box" style="background:#F0FDF4; border:1px solid #BBF7D0; color:#166534; padding:14px; border-radius:10px; margin-bottom:14px;">
                                <div style="display:flex; align-items:flex-start; gap:10px;">
                                    <span style="font-size:1.4rem; flex-shrink:0;">🎉</span>
                                    <div>
                                        <strong style="color:#15803D;">Bạn đã hoàn thành bài kiểm tra!</strong>
                                        <div style="font-size:.84rem; margin-top:3px; color:#166534;">
                                            Điểm cao nhất: <strong><fmt:formatNumber value="${bestScorePct}" maxFractionDigits="1"/>%</strong>
                                            <c:if test="${quiz.passingScore != null}"> (Điểm yêu cầu: ${quiz.passingScore}%)</c:if>.
                                        </div>
                                        <div style="font-size:.8rem; margin-top:4px; color:#475569;">
                                            Bạn có thể làm lại để cải thiện điểm số bất cứ lúc nào.
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <form method="post" action="${pageContext.request.contextPath}/courses/${courseId}/quizzes/${quizId}/start">
                                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                <button class="quiz-btn quiz-btn--primary quiz-btn--cta" type="submit"
                                        onclick="return confirm('Bắt đầu làm lại bài kiểm tra? Kết quả cao hơn sẽ giúp bạn cải thiện thành tích.')">
                                    🔄 Làm lại bài kiểm tra (Lần ${attemptCount + 1})
                                </button>
                            </form>
                            <c:if test="${quiz.lesson != null}">
                                <a href="${pageContext.request.contextPath}/courses/${courseId}/learn"
                                   class="quiz-btn quiz-btn--outline quiz-btn--cta" style="margin-top:10px; text-decoration:none;">
                                    📚 Tiếp tục học khóa học →
                                </a>
                            </c:if>
                        </c:when>

                        <%-- 4. Chưa đạt yêu cầu và đã làm bài trước đó --%>
                        <c:when test="${attemptCount > 0}">
                            <div class="quiz-notice-box" style="background:#FFFBEB; border:1px solid #FDE68A; color:#92400E; padding:14px; border-radius:10px; margin-bottom:14px;">
                                <div style="display:flex; align-items:flex-start; gap:10px;">
                                    <span style="font-size:1.4rem; flex-shrink:0;">⚠️</span>
                                    <div>
                                        <strong style="color:#B45309;">Chưa đạt điểm yêu cầu</strong>
                                        <div style="font-size:.84rem; margin-top:3px; color:#92400E;">
                                            Điểm cao nhất hiện tại: <strong><fmt:formatNumber value="${bestScorePct}" maxFractionDigits="1"/>%</strong>
                                            <c:if test="${quiz.passingScore != null}"> (Cần tối thiểu ${quiz.passingScore}% để qua bài)</c:if>.
                                        </div>
                                        <div style="font-size:.8rem; margin-top:4px; color:#78350F;">
                                            Bạn được làm lại không giới hạn cho tới khi đạt điểm. Cố lên nhé!
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <form method="post" action="${pageContext.request.contextPath}/courses/${courseId}/quizzes/${quizId}/start">
                                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                <button class="quiz-btn quiz-btn--primary quiz-btn--cta" type="submit"
                                        onclick="return confirm('Bắt đầu làm bài kiểm tra lần ${attemptCount + 1}?')">
                                    ▶ Làm lại bài kiểm tra (Lần ${attemptCount + 1})
                                </button>
                            </form>
                        </c:when>

                        <%-- 5. Lần đầu làm bài --%>
                        <c:otherwise>
                            <div style="font-size:.84rem; color:#64748B; margin-bottom:12px; display:flex; align-items:center; gap:6px;">
                                <span>🔄</span> Không giới hạn số lần làm bài
                                <c:if test="${quiz.timeLimitMinutes != null}">
                                    <span>· ⏱ ${quiz.timeLimitMinutes} phút</span>
                                </c:if>
                            </div>
                            <form method="post" action="${pageContext.request.contextPath}/courses/${courseId}/quizzes/${quizId}/start">
                                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                <button class="quiz-btn quiz-btn--primary quiz-btn--cta" type="submit"
                                        onclick="return confirm('Bắt đầu làm bài ngay? Đồng hồ tính giờ sẽ bắt đầu chạy.')">
                                    ▶ Bắt đầu làm bài
                                </button>
                            </form>
                        </c:otherwise>
                    </c:choose>
                </div>
            </aside>
        </div>
    </main>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</body>
</html>
