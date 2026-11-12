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
                        <span class="quiz-hero__chip">🔄 Tối đa ${quiz.maxAttempts} lần làm</span>
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
                                    Đã hoàn thành ${fn:length(myAttempts)} / ${quiz.maxAttempts} lượt làm
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div class="quiz-hero__glass-icon">🎯</div>
                                <div class="quiz-hero__glass-label">Trạng thái làm bài</div>
                                <div class="quiz-hero__glass-highlight">Sẵn sàng thử sức</div>
                                <div class="quiz-hero__glass-footer">
                                    Tối đa ${quiz.maxAttempts} lần · <c:choose><c:when test="${quiz.timeLimitMinutes != null}">${quiz.timeLimitMinutes} phút</c:when><c:otherwise>Tự do</c:otherwise></c:choose>
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
                    <c:forEach var="a" items="${myAttempts}">
                        <c:if test="${a.status eq 'IN_PROGRESS'}"><c:set var="hasInProgress" value="true"/></c:if>
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

                        <%-- 3. Đã hết lượt làm --%>
                        <c:when test="${attemptCount >= quiz.maxAttempts}">
                            <div class="quiz-notice-box quiz-notice-box--locked">
                                <div style="display:flex; align-items:center; gap:8px;">
                                    <span style="font-size:1.2rem;">🔒</span>
                                    <div>
                                        <strong>Đã hết số lượt làm bài</strong>
                                        <div style="font-size:.82rem; margin-top:2px;">Bạn đã dùng hết ${quiz.maxAttempts} / ${quiz.maxAttempts} lượt làm cho bài kiểm tra này.</div>
                                    </div>
                                </div>
                            </div>
                            <button class="quiz-btn quiz-btn--cta" disabled style="background:#CBD5E1; color:#64748B; cursor:not-allowed;">
                                Đã hết lượt làm bài
                            </button>
                        </c:when>

                        <%-- 4. Đủ điều kiện và sẵn sàng làm bài --%>
                        <c:otherwise>
                            <div class="quiz-remaining-badge">
                                Còn lại <strong>${quiz.maxAttempts - attemptCount}</strong> / ${quiz.maxAttempts} lần làm bài
                                <c:if test="${quiz.timeLimitMinutes != null}">
                                    <div style="font-size:.8rem; color:#64748B; margin-top:4px;">⏱ Thời gian làm: ${quiz.timeLimitMinutes} phút</div>
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
