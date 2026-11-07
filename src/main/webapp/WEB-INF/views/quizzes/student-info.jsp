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
        <a class="quiz-back-link" href="${pageContext.request.contextPath}/courses/${courseId}/quizzes">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><path d="M19 12H5M12 19l-7-7 7-7"/></svg>
            Danh sách bài kiểm tra
        </a>

        <!-- Hero -->
        <div class="quiz-hero quiz-hero--info">
            <p class="quiz-hero__eyebrow">
                <span>📝</span> BÀI KIỂM TRA ĐÁNH GIÁ
            </p>
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
                            <div style="text-align:center; padding:32px 16px; color:#64748B;">
                                <div style="font-size:2.5rem; margin-bottom:8px;">📝</div>
                                <p style="font-size:.95rem; font-weight:600; margin:0;">Bạn chưa làm bài kiểm tra này lần nào.</p>
                                <p style="font-size:.85rem; margin-top:4px;">Nhấn vào nút "Bắt đầu làm bài" ở bên phải để làm bài.</p>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <c:forEach var="a" items="${myAttempts}">
                                <div class="quiz-attempt-item">
                                    <div>
                                        <div class="quiz-attempt-num">Lần làm ${a.attemptNumber}</div>
                                        <c:if test="${a.submittedAt != null}">
                                            <div class="quiz-attempt-date">
                                                📅 Nộp lúc ${a.formattedSubmittedAt}
                                            </div>
                                        </c:if>
                                        <c:if test="${a.resultStatus eq 'PUBLISHED' and a.score != null}">
                                            <div class="quiz-score-highlight">
                                                Điểm: <fmt:formatNumber value="${a.score}" maxFractionDigits="2"/> / <fmt:formatNumber value="${a.maxScore}" maxFractionDigits="2"/>
                                            </div>
                                        </c:if>
                                    </div>
                                    <div style="display:flex; gap:10px; align-items:center;">
                                        <c:choose>
                                            <c:when test="${a.status eq 'IN_PROGRESS'}">
                                                <span class="quiz-badge quiz-badge--progress">⏳ Đang làm</span>
                                            </c:when>
                                            <c:when test="${a.status eq 'SCORED'}">
                                                <span class="quiz-badge quiz-badge--scored">✅ Đã chấm</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="quiz-badge quiz-badge--submitted">📤 Đã nộp</span>
                                            </c:otherwise>
                                        </c:choose>

                                        <c:choose>
                                            <c:when test="${a.status eq 'IN_PROGRESS'}">
                                                <a class="quiz-btn quiz-btn--primary" style="padding:6px 14px; font-size:.84rem;"
                                                   href="${pageContext.request.contextPath}/courses/${courseId}/quizzes/${quizId}/attempts/${a.attemptId}">
                                                    Tiếp tục →
                                                </a>
                                            </c:when>
                                            <c:otherwise>
                                                <a class="quiz-btn quiz-btn--outline" style="padding:6px 14px; font-size:.84rem;"
                                                   href="${pageContext.request.contextPath}/courses/${courseId}/quizzes/${quizId}/attempts/${a.attemptId}/result">
                                                    Xem kết quả →
                                                </a>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                </div>
                            </c:forEach>
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
