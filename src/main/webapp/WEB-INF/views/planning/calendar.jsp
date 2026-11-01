<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Lịch học tập cá nhân (Calendar) — EduSphere</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/home.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app.css?v=planning">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/planning.css">
</head>
<body>

<jsp:include page="/WEB-INF/views/common/navbar.jsp"/>

<main style="max-width: 1300px; margin: 32px auto; padding: 0 20px; min-height: 70vh;">

    <!-- Planning Subnav Tabs -->
    <nav class="plan-tabs">
        <a class="plan-tab" href="${pageContext.request.contextPath}/study/plans">
            📋 Kế hoạch
        </a>
        <a class="plan-tab plan-tab--active" href="${pageContext.request.contextPath}/study/calendar">
            📅 Lịch học (Calendar)
        </a>
        <a class="plan-tab" href="${pageContext.request.contextPath}/study/progress">
            📈 Tiến độ khóa học
        </a>
        <a class="plan-tab" href="${pageContext.request.contextPath}/study/history">
            ⏱️ Lịch sử hoạt động
        </a>
    </nav>

    <!-- Calendar Controls -->
    <div class="cal-controls">
        <div>
            <h1 style="font-size: 1.5rem; font-weight: 800; color: #0f172a; margin: 0;">Lịch học theo tuần</h1>
            <p style="color: #64748b; font-size: 0.88rem; margin: 2px 0 0;">Theo dõi các nhiệm vụ học tập theo mốc thời gian cụ thể (UC36)</p>
        </div>

        <div class="cal-nav">
            <a class="btn-secondary btn-sm" href="${pageContext.request.contextPath}/study/calendar?date=${prevWeekDate}">
                &larr; Tuần trước
            </a>
            <a class="btn-secondary btn-sm" href="${pageContext.request.contextPath}/study/calendar?date=${todayDate}">
                Hôm nay
            </a>
            <span class="cal-range-text">
                Tuần: ${week[0].date} &rarr; ${week[6].date}
            </span>
            <a class="btn-secondary btn-sm" href="${pageContext.request.contextPath}/study/calendar?date=${nextWeekDate}">
                Tuần sau &rarr;
            </a>
        </div>
    </div>

    <!-- 7-Day Grid -->
    <div class="cal-week-grid">
        <c:forEach items="${week}" var="day">
            <div class="cal-day-col ${day.today ? 'cal-day-col--today' : ''}">
                <div class="cal-day-head">
                    <div class="cal-day-name">${day.dayOfWeekName}</div>
                    <div class="cal-day-date">${day.date}</div>
                </div>

                <c:choose>
                    <c:when test="${empty day.tasks}">
                        <div class="cal-empty">
                            <span>Không có lịch</span>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <c:forEach items="${day.tasks}" var="t">
                            <a class="cal-task-item ${t.status == 'DONE' ? 'cal-task-item--done' : ''}"
                               href="${pageContext.request.contextPath}/study/plans/${t.planId}"
                               title="Kế hoạch: ${t.planTitle}">
                                <div class="cal-task-time">
                                    ⏰ <fmt:parseDate value="${t.plannedStartAt}" pattern="yyyy-MM-dd'T'HH:mm" var="parsedStart"/>
                                    <fmt:formatDate value="${parsedStart}" pattern="HH:mm"/> -
                                    <fmt:parseDate value="${t.plannedEndAt}" pattern="yyyy-MM-dd'T'HH:mm" var="parsedEnd"/>
                                    <fmt:formatDate value="${parsedEnd}" pattern="HH:mm"/>
                                </div>
                                <div class="cal-task-title">
                                    ${t.title}
                                </div>
                                <c:if test="${not empty t.courseTitle}">
                                    <div style="font-size: 0.73rem; color: #2563eb; font-weight: 600;">
                                        📚 ${t.courseTitle}
                                    </div>
                                </c:if>
                                <div style="display: flex; justify-content: space-between; align-items: center; margin-top: 4px;">
                                    <span class="badge badge--${t.status.toLowerCase()}" style="font-size: 0.68rem; padding: 1px 5px;">
                                        ${t.status}
                                    </span>
                                </div>
                            </a>
                        </c:forEach>
                    </c:otherwise>
                </c:choose>
            </div>
        </c:forEach>
    </div>

</main>

<script>
function toggleUserMenu(e) {
    e.stopPropagation();
    const menu = e.currentTarget.closest('.hn-user-menu');
    menu.classList.toggle('open');
}
document.addEventListener('click', function() {
    document.querySelectorAll('.hn-user-menu.open').forEach(m => m.classList.remove('open'));
});
</script>
<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</body>
</html>

