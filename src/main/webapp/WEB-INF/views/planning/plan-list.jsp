<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1.0">
    <title>Kế hoạch học tập — EduSphere</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/home.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/planning-new.css">
</head>
<body>
<jsp:include page="/WEB-INF/views/common/navbar.jsp"/>

<div class="pl-shell">

    <!-- Tabs -->
    <nav class="pl-tabs">
        <a class="pl-tab active" href="${pageContext.request.contextPath}/study/plans">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2"/></svg>
            Kế hoạch học tập
        </a>
        <a class="pl-tab" href="${pageContext.request.contextPath}/study/calendar">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
            Lịch học cá nhân
        </a>
        <a class="pl-tab" href="${pageContext.request.contextPath}/study/progress">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="22 12 18 12 15 21 9 3 6 12 2 12"/></svg>
            Theo dõi tiến độ
        </a>
        <a class="pl-tab" href="${pageContext.request.contextPath}/study/history">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
            Lịch sử hoạt động
        </a>
    </nav>

    <c:if test="${not empty success}">
        <div class="pl-alert pl-alert--success">✅ <c:out value="${success}"/></div>
    </c:if>

    <!-- Page header -->
    <div class="pl-page-head">
        <div>
            <h1>Kế hoạch học tập cá nhân</h1>
            <p>Đặt mục tiêu, sắp xếp thời gian và theo dõi tiến độ học tập sát sao (UC34)</p>
        </div>
        <a class="pl-btn pl-btn--primary" href="${pageContext.request.contextPath}/study/plans/new">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" style="width:18px;height:18px;"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
            Tạo kế hoạch mới
        </a>
    </div>

    <!-- Stats -->
    <div class="pl-stats">
        <div class="pl-stat-card">
            <div class="pl-stat-icon pl-stat-icon--blue">📋</div>
            <div>
                <div class="pl-stat-num">${plans.size()}</div>
                <div class="pl-stat-label">Tổng kế hoạch</div>
            </div>
        </div>
        <div class="pl-stat-card">
            <div class="pl-stat-icon pl-stat-icon--green">🎯</div>
            <div>
                <div class="pl-stat-num">${activeCount}</div>
                <div class="pl-stat-label">Đang thực hiện</div>
            </div>
        </div>
        <div class="pl-stat-card" onclick="window.location='${pageContext.request.contextPath}/study/calendar'" style="cursor:pointer;">
            <div class="pl-stat-icon pl-stat-icon--amber">📅</div>
            <div>
                <div class="pl-stat-num" style="font-size:1rem;color:#009bf2;">Xem lịch →</div>
                <div class="pl-stat-label">Lịch học theo tuần</div>
            </div>
        </div>
    </div>

    <!-- Plans -->
    <c:choose>
        <c:when test="${empty plans}">
            <div class="pl-empty">
                <div class="pl-empty__icon">📝</div>
                <h3>Chưa có kế hoạch học tập nào</h3>
                <p>Tạo kế hoạch đầu tiên để học tập có kỷ luật và hiệu quả hơn!</p>
                <a class="pl-btn pl-btn--primary" href="${pageContext.request.contextPath}/study/plans/new">➕ Tạo kế hoạch ngay</a>
            </div>
        </c:when>
        <c:otherwise>
            <div class="pl-plan-grid">
                <c:forEach items="${plans}" var="plan">
                    <article class="pl-plan-card">
                        <div>
                            <div class="pl-plan-card__head">
                                <a class="pl-plan-card__title" href="${pageContext.request.contextPath}/study/plans/${plan.planId}">
                                    <c:out value="${plan.title}"/>
                                </a>
                                <span class="pl-badge pl-badge--${plan.status.toLowerCase()}"><c:out value="${plan.status}"/></span>
                            </div>
                            <c:if test="${not empty plan.description}">
                                <div class="pl-plan-card__desc"><c:out value="${plan.description}"/></div>
                            </c:if>
                            <div class="pl-plan-card__meta">
                                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="width:14px;height:14px;flex-shrink:0;"><rect x="3" y="4" width="18" height="18" rx="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
                                <c:out value="${plan.startDate}"/> → <c:out value="${plan.endDate}"/>
                            </div>
                            <div class="pl-prog-wrap">
                                <div class="pl-prog-labels">
                                    <span>${plan.doneTasks}/${plan.totalTasks} nhiệm vụ</span>
                                    <span style="color:#009bf2;font-weight:700;">${plan.progressPercent}%</span>
                                </div>
                                <div class="pl-prog-track">
                                    <div class="pl-prog-fill ${plan.progressPercent >= 100 ? 'pl-prog-fill--done' : ''}" style="width:${plan.progressPercent}%;"></div>
                                </div>
                            </div>
                        </div>
                        <div style="display:flex;justify-content:space-between;align-items:center;margin-top:16px;padding-top:14px;border-top:1px solid #f1f5f9;">
                            <a class="pl-btn pl-btn--primary pl-btn--sm" href="${pageContext.request.contextPath}/study/plans/${plan.planId}">Chi tiết →</a>
                            <div style="display:flex;gap:6px;">
                                <a class="pl-btn pl-btn--outline pl-btn--sm pl-btn--icon" href="${pageContext.request.contextPath}/study/plans/${plan.planId}/edit" title="Sửa">✏️</a>
                                <form method="post" action="${pageContext.request.contextPath}/study/plans/${plan.planId}/delete" onsubmit="return confirm('Xóa kế hoạch này?');" style="margin:0;">
                                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                    <button class="pl-btn pl-btn--danger pl-btn--sm pl-btn--icon" type="submit" title="Xóa">🗑️</button>
                                </form>
                            </div>
                        </div>
                    </article>
                </c:forEach>
            </div>
        </c:otherwise>
    </c:choose>

    <!-- UC35 Callout -->
    <div class="pl-callout" style="margin-top:28px;">
        <div class="pl-callout__icon">⏰</div>
        <div style="flex:1;">
            <div class="pl-callout__title">Đặt thời điểm học cá nhân (UC35)</div>
            <div class="pl-callout__desc">Sắp xếp giờ riêng để tự học bài tập hoặc làm quiz. <strong>Tuyệt đối không làm thay đổi Due Date chính thức của giảng viên.</strong></div>
        </div>
        <a class="pl-btn pl-btn--outline" href="${pageContext.request.contextPath}/study/tasks/new" style="white-space:nowrap;">
            + Tạo nhiệm vụ cá nhân
        </a>
    </div>
</div>

<jsp:include page="/WEB-INF/views/planning/planning-footer.jsp"/>
</body></html>