<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html><html lang="vi"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1.0">
<title>Lịch học — EduSphere</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/home.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/planning-new.css">
</head><body>
<jsp:include page="/WEB-INF/views/planning/planning-navbar.jsp"/>
<div class="pl-shell">
<nav class="pl-tabs">
    <a class="pl-tab" href="${pageContext.request.contextPath}/study/plans">📋 Kế hoạch học tập</a>
    <a class="pl-tab active" href="${pageContext.request.contextPath}/study/calendar">📅 Lịch học cá nhân</a>
    <a class="pl-tab" href="${pageContext.request.contextPath}/study/progress">📈 Theo dõi tiến độ</a>
    <a class="pl-tab" href="${pageContext.request.contextPath}/study/history">⏱️ Lịch sử hoạt động</a>
</nav>

<div class="pl-cal-controls">
    <div>
        <h1 style="font-size:1.4rem;font-weight:800;color:#0f172a;margin:0;">Lịch học cá nhân theo tuần</h1>
        <p style="color:#64748b;font-size:.82rem;margin:3px 0 0;">Xem nhiệm vụ theo mốc thời gian cá nhân (UC36)</p>
    </div>
    <div style="display:flex;align-items:center;gap:10px;flex-wrap:wrap;">
        <div style="display:flex;align-items:center;gap:6px;background:#f8fafc;border:1px solid #e2e8f0;border-radius:12px;padding:6px 12px;">
            <a href="${pageContext.request.contextPath}/study/calendar?date=${prevWeekDate}" style="color:#64748b;text-decoration:none;font-weight:700;font-size:.9rem;padding:4px 8px;border-radius:8px;transition:background .15s;" onmouseover="this.style.background='#e2e8f0'" onmouseout="this.style.background='transparent'">←</a>
            <span style="font-size:.85rem;font-weight:700;color:#0f172a;min-width:180px;text-align:center;"><c:out value="${week[0].date}"/> – <c:out value="${week[6].date}"/></span>
            <a href="${pageContext.request.contextPath}/study/calendar?date=${nextWeekDate}" style="color:#64748b;text-decoration:none;font-weight:700;font-size:.9rem;padding:4px 8px;border-radius:8px;transition:background .15s;" onmouseover="this.style.background='#e2e8f0'" onmouseout="this.style.background='transparent'">→</a>
        </div>
        <a href="${pageContext.request.contextPath}/study/calendar?date=${todayDate}" class="pl-btn pl-btn--outline pl-btn--sm">Hôm nay</a>
        <a href="${pageContext.request.contextPath}/study/plans/new" class="pl-btn pl-btn--primary pl-btn--sm">+ Thêm nhiệm vụ</a>
    </div>
</div>

<div class="pl-cal-week">
    <c:forEach items="${week}" var="day">
        <div class="pl-cal-day ${day.today ? 'pl-cal-day--today' : ''}">
            <div class="pl-cal-day-head">
                <div class="pl-cal-day-name"><c:out value="${day.dayOfWeekName}"/></div>
                <div class="pl-cal-day-num"><c:out value="${day.date}"/></div>
            </div>
            <c:choose>
                <c:when test="${empty day.tasks}">
                    <div class="pl-cal-empty">Không có lịch</div>
                </c:when>
                <c:otherwise>
                    <c:forEach items="${day.tasks}" var="t">
                        <a class="pl-cal-task ${t.status == 'DONE' ? 'pl-cal-task--done' : ''}"
                           href="${pageContext.request.contextPath}/study/plans/${t.planId}">
                            <div class="pl-cal-task-time">
                                ⏰ <fmt:parseDate value="${t.plannedStartAt}" pattern="yyyy-MM-dd'T'HH:mm" var="ps"/>
                                <fmt:formatDate value="${ps}" pattern="HH:mm"/>
                            </div>
                            <div class="pl-cal-task-title"><c:out value="${t.title}"/></div>
                            <c:if test="${not empty t.courseTitle}">
                                <div style="font-size:.7rem;color:#009bf2;font-weight:600;margin-top:3px;">📚 <c:out value="${t.courseTitle}"/></div>
                            </c:if>
                            <span class="pl-badge pl-badge--${t.status.toLowerCase()}" style="font-size:.65rem;margin-top:4px;"><c:out value="${t.status}"/></span>
                        </a>
                    </c:forEach>
                </c:otherwise>
            </c:choose>
        </div>
    </c:forEach>
</div>

</div>
<jsp:include page="/WEB-INF/views/planning/planning-footer.jsp"/>
</body></html>