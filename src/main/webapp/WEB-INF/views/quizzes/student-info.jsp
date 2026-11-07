<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><c:out value="${quiz.title}"/> — EduSphere</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app.css?v=restore-0bfd0e1-20261014">
    <style>
        .qi-hero { background:linear-gradient(135deg,#1E3A5F,#2563EB); color:#fff; border-radius:16px; padding:32px 36px; margin-bottom:24px; }
        .qi-hero__eyebrow { font-size:.78rem; font-weight:700; opacity:.7; text-transform:uppercase; letter-spacing:.06em; margin-bottom:6px; }
        .qi-hero__title { font-size:1.7rem; font-weight:900; margin:0 0 12px; }
        .qi-hero__desc { opacity:.85; font-size:.93rem; line-height:1.6; margin:0 0 20px; white-space:pre-wrap; }
        .qi-meta { display:flex; flex-wrap:wrap; gap:16px; }
        .qi-meta-item { display:flex; align-items:center; gap:6px; font-size:.85rem; font-weight:600; background:rgba(255,255,255,.12); border-radius:20px; padding:5px 14px; }
        .qi-layout { display:grid; grid-template-columns:1fr 300px; gap:24px; align-items:start; }
        @media(max-width:820px){ .qi-layout{ grid-template-columns:1fr; } }
        .qi-card { background:#fff; border:1px solid #E2E8F0; border-radius:12px; padding:22px 24px; margin-bottom:16px; }
        .qi-card__title { font-size:.78rem; font-weight:700; color:#94A3B8; text-transform:uppercase; letter-spacing:.06em; margin:0 0 14px; }
        .qi-rules { background:#FFFBEB; border:1px solid #FDE68A; border-radius:10px; padding:16px 18px; font-size:.88rem; color:#78350F; line-height:1.6; white-space:pre-wrap; }
        .qi-btn-start { width:100%; display:block; text-align:center; background:#2563EB; color:#fff; border:none; border-radius:10px; padding:14px 20px; font-size:1rem; font-weight:800; cursor:pointer; transition:background .15s; }
        .qi-btn-start:hover { background:#1D4ED8; }
        .qi-btn-start:disabled { background:#94A3B8; cursor:not-allowed; }
        .qi-attempt-row { padding:12px 0; border-top:1px solid #F1F5F9; display:flex; align-items:center; justify-content:space-between; gap:10px; flex-wrap:wrap; }
        .qi-attempt-status { padding:3px 10px; border-radius:20px; font-size:.75rem; font-weight:700; }
        .qi-attempt-status--in-progress { background:#FEF9C3; color:#854D0E; }
        .qi-attempt-status--scored { background:#DCFCE7; color:#166534; }
        .qi-attempt-status--submitted { background:#EFF6FF; color:#1D4ED8; }
        .qi-locked-banner { background:#FEF2F2; border:1.5px solid #FECACA; border-radius:10px; padding:14px 18px; color:#991B1B; font-size:.88rem; font-weight:600; margin-bottom:14px; }
    </style>
</head>
<body>
<jsp:include page="/WEB-INF/views/common/navbar.jsp"/>
<main class="shell">
    <a class="back-link" href="${pageContext.request.contextPath}/courses/${courseId}/quizzes">← Danh sách bài kiểm tra</a>

    <!-- Hero -->
    <div class="qi-hero">
        <p class="qi-hero__eyebrow">📝 Bài kiểm tra</p>
        <h1 class="qi-hero__title"><c:out value="${quiz.title}"/></h1>
        <c:if test="${not empty quiz.description}">
            <p class="qi-hero__desc"><c:out value="${quiz.description}"/></p>
        </c:if>
        <div class="qi-meta">
            <span class="qi-meta-item">
                ⏱ <c:choose>
                    <c:when test="${quiz.timeLimitMinutes != null}">${quiz.timeLimitMinutes} phút</c:when>
                    <c:otherwise>Không giới hạn thời gian</c:otherwise>
                </c:choose>
            </span>
            <span class="qi-meta-item">🔄 Tối đa ${quiz.maxAttempts} lần làm</span>
            <c:if test="${quiz.passingScore != null}">
                <span class="qi-meta-item">🎯 Qua bài: ${quiz.passingScore}%</span>
            </c:if>
        </div>
    </div>

    <c:if test="${not empty success}"><div class="alert alert--success"><c:out value="${success}"/></div></c:if>

    <div class="qi-layout">
        <div>
            <!-- Rules -->
            <c:if test="${not empty quiz.rules}">
                <div class="qi-card">
                    <p class="qi-card__title">⚠️ Quy định làm bài</p>
                    <div class="qi-rules"><c:out value="${quiz.rules}"/></div>
                </div>
            </c:if>

            <!-- History -->
            <div class="qi-card">
                <p class="qi-card__title">📋 Lịch sử làm bài của bạn</p>
                <c:choose>
                    <c:when test="${empty myAttempts}">
                        <p class="muted" style="font-size:.88rem;">Bạn chưa làm bài này lần nào.</p>
                    </c:when>
                    <c:otherwise>
                        <c:forEach var="a" items="${myAttempts}">
                            <div class="qi-attempt-row">
                                <div>
                                    <strong>Lần ${a.attemptNumber}</strong>
                                    <c:if test="${a.submittedAt != null}">
                                        <span style="font-size:.82rem;color:#64748B;"> · Nộp lúc ${fn:replace(fn:substring(a.submittedAt, 0, 16), 'T', ' ')}</span>
                                    </c:if>
                                    <c:if test="${a.resultStatus eq 'PUBLISHED' and a.score != null}">
                                        <div style="font-size:.88rem;font-weight:700;color:#16A34A;margin-top:2px;">
                                            Điểm: <fmt:formatNumber value="${a.score}" maxFractionDigits="2"/> / <fmt:formatNumber value="${a.maxScore}" maxFractionDigits="2"/>
                                        </div>
                                    </c:if>
                                </div>
                                <div style="display:flex;gap:8px;align-items:center;">
                                    <c:choose>
                                        <c:when test="${a.status eq 'IN_PROGRESS'}">
                                            <span class="qi-attempt-status qi-attempt-status--in-progress">⏳ Đang làm</span>
                                        </c:when>
                                        <c:when test="${a.status eq 'SCORED'}">
                                            <span class="qi-attempt-status qi-attempt-status--scored">✅ Đã chấm</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="qi-attempt-status qi-attempt-status--submitted">📤 Đã nộp</span>
                                        </c:otherwise>
                                    </c:choose>
                                    <c:choose>
                                        <c:when test="${a.status eq 'IN_PROGRESS'}">
                                            <a class="button button--outline" style="padding:5px 12px;font-size:.82rem;"
                                               href="${pageContext.request.contextPath}/courses/${courseId}/quizzes/${quizId}/attempts/${a.attemptId}">
                                                Tiếp tục →
                                            </a>
                                        </c:when>
                                        <c:otherwise>
                                            <a class="button button--outline" style="padding:5px 12px;font-size:.82rem;"
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

        <!-- Aside: Start button -->
        <aside>
            <div class="qi-card" style="text-align:center;">
                <p class="qi-card__title" style="text-align:left;">🚀 Bắt đầu làm bài</p>

                <c:set var="attemptCount" value="${fn:length(myAttempts)}"/>
                <c:set var="hasInProgress" value="false"/>
                <c:forEach var="a" items="${myAttempts}">
                    <c:if test="${a.status eq 'IN_PROGRESS'}"><c:set var="hasInProgress" value="true"/></c:if>
                </c:forEach>

                <c:choose>
                    <c:when test="${hasInProgress}">
                        <div class="qi-locked-banner">⏳ Bạn đang có bài làm chưa hoàn thành. Tiếp tục bài đó trước.</div>
                    </c:when>
                    <c:when test="${attemptCount >= quiz.maxAttempts}">
                        <div class="qi-locked-banner">🔒 Bạn đã dùng hết ${quiz.maxAttempts} lần làm bài.</div>
                        <button class="qi-btn-start" disabled>Đã hết lượt</button>
                    </c:when>
                    <c:otherwise>
                        <p style="font-size:.85rem;color:#64748B;margin-bottom:16px;">
                            Còn lại <strong>${quiz.maxAttempts - attemptCount}</strong> / ${quiz.maxAttempts} lần.
                            <c:if test="${quiz.timeLimitMinutes != null}"><br/>Đồng hồ sẽ bắt đầu ngay khi bạn nhấn.</c:if>
                        </p>
                        <form method="post" action="${pageContext.request.contextPath}/courses/${courseId}/quizzes/${quizId}/start">
                            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                            <button class="qi-btn-start" type="submit"
                                    onclick="return confirm('Bắt đầu làm bài? Đồng hồ sẽ chạy ngay lập tức.')">
                                ▶ Bắt đầu làm bài
                            </button>
                        </form>
                    </c:otherwise>
                </c:choose>
            </div>
        </aside>
    </div>
</main>
<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</body>
</html>
