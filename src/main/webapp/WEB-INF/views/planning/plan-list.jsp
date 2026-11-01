<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Kế hoạch học tập — EduSphere</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/home.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app.css?v=planning">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/planning.css">
</head>
<body>

<jsp:include page="/WEB-INF/views/common/navbar.jsp"/>

<main style="max-width: 1200px; margin: 32px auto; padding: 0 24px; min-height: 70vh;">

    <!-- Planning Subnav Tabs (UC34, UC36, UC37, UC38) -->
    <nav class="plan-tabs">
        <a class="plan-tab plan-tab--active" href="${pageContext.request.contextPath}/study/plans">
            📋 Kế hoạch (${plans.size()})
        </a>
        <a class="plan-tab" href="${pageContext.request.contextPath}/study/calendar">
            📅 Lịch học (Calendar)
        </a>
        <a class="plan-tab" href="${pageContext.request.contextPath}/study/progress">
            📈 Tiến độ khóa học
        </a>
        <a class="plan-tab" href="${pageContext.request.contextPath}/study/history">
            ⏱️ Lịch sử hoạt động
        </a>
    </nav>

    <c:if test="${not empty success}">
        <div class="alert alert-success">${success}</div>
    </c:if>

    <!-- Header & Action -->
    <div class="plan-header">
        <div>
            <h1 class="plan-header__title">Kế hoạch học tập cá nhân</h1>
            <p class="plan-header__subtitle">Đặt mục tiêu và quản lý lịch trình học tập cho từng khoảng thời gian (UC34)</p>
        </div>
        <a class="btn-primary" href="${pageContext.request.contextPath}/study/plans/new">
            + Tạo kế hoạch mới
        </a>
    </div>

    <!-- Stats summary -->
    <div class="plan-stats-grid">
        <div class="plan-stat-card">
            <div class="plan-stat-icon plan-stat-icon--blue">📋</div>
            <div class="plan-stat-info">
                <h4>${plans.size()}</h4>
                <p>Tổng kế hoạch</p>
            </div>
        </div>
        <div class="plan-stat-card">
            <div class="plan-stat-icon plan-stat-icon--green">🎯</div>
            <div class="plan-stat-info">
                <h4>${activeCount}</h4>
                <p>Đang thực hiện</p>
            </div>
        </div>
        <div class="plan-stat-card">
            <div class="plan-stat-icon plan-stat-icon--amber">📅</div>
            <div class="plan-stat-info">
                <h4>Xem Lịch</h4>
                <p><a href="${pageContext.request.contextPath}/study/calendar" style="color:#2563eb;text-decoration:none;font-weight:600;">Xem theo tuần &rarr;</a></p>
            </div>
        </div>
    </div>

    <!-- Plan List -->
    <c:choose>
        <c:when test="${empty plans}">
            <div style="text-align: center; padding: 60px 20px; background: #fff; border: 1px dashed #cbd5e1; border-radius: 14px;">
                <div style="font-size: 3rem; margin-bottom: 16px;">📝</div>
                <h3 style="color: #1e293b; margin: 0 0 8px;">Bạn chưa có kế hoạch học tập nào</h3>
                <p style="color: #64748b; margin-bottom: 24px;">Hãy tạo kế hoạch đầu tiên để sắp xếp thời gian và hoàn thành mục tiêu học tập!</p>
                <a class="btn-primary" href="${pageContext.request.contextPath}/study/plans/new">
                    + Tạo kế hoạch ngay
                </a>
            </div>
        </c:when>
        <c:otherwise>
            <div class="plan-grid">
                <c:forEach items="${plans}" var="plan">
                    <article class="plan-card">
                        <div>
                            <div class="plan-card__head">
                                <a class="plan-card__title" href="${pageContext.request.contextPath}/study/plans/${plan.planId}">
                                    ${plan.title}
                                </a>
                                <span class="badge badge--${plan.status.toLowerCase()}">${plan.status}</span>
                            </div>
                            <c:if test="${not empty plan.description}">
                                <div class="plan-card__desc">${plan.description}</div>
                            </c:if>
                            <div class="plan-card__meta">
                                <span>📅 ${plan.startDate} &rarr; ${plan.endDate}</span>
                            </div>

                            <div class="progress-bar-container">
                                <div class="progress-bar-labels">
                                    <span>Nhiệm vụ: ${plan.doneTasks}/${plan.totalTasks}</span>
                                    <span>${plan.progressPercent}%</span>
                                </div>
                                <div class="progress-bar-track">
                                    <div class="progress-bar-fill ${plan.progressPercent == 100 ? 'progress-bar-fill--green' : ''}"
                                         style="width: ${plan.progressPercent}%;"></div>
                                </div>
                            </div>
                        </div>

                        <div style="display: flex; justify-content: space-between; align-items: center; margin-top: 16px; pt-3; border-top: 1px solid #f1f5f9;">
                            <a class="btn-secondary btn-sm" href="${pageContext.request.contextPath}/study/plans/${plan.planId}">
                                Chi tiết & Nhiệm vụ &rarr;
                            </a>
                            <a class="btn-secondary btn-sm" href="${pageContext.request.contextPath}/study/plans/${plan.planId}/edit">
                                Sửa
                            </a>
                        </div>
                    </article>
                </c:forEach>
            </div>
        </c:otherwise>
    </c:choose>

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

