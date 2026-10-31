<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tiến độ học tập — EduSphere</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/home.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/planning.css">
</head>
<body>

<!-- ══════ NAVBAR ══════ -->
<header class="hn-header">
    <div class="hn-header__inner">
        <a class="hn-logo" href="${pageContext.request.contextPath}/">
            <div class="hn-logo__icon">🎓</div>
            <span>EduSphere</span>
        </a>
        <nav class="hn-nav">
            <a class="hn-nav__link" href="${pageContext.request.contextPath}/">Trang chủ</a>
            <a class="hn-nav__link" href="${pageContext.request.contextPath}/courses">Khóa học</a>
            <a class="hn-nav__link" href="${pageContext.request.contextPath}/my-courses">Khóa học của tôi</a>
            <a class="hn-nav__link hn-nav__link--active" href="${pageContext.request.contextPath}/study/plans">Kế hoạch học tập</a>
        </nav>
        <div class="hn-header__right">
            <sec:authorize access="isAuthenticated()">
                <div class="hn-user-menu">
                    <button class="hn-user-btn" onclick="toggleUserMenu(event)">
                        <span class="hn-user-btn__name"><sec:authentication property="principal.fullName"/></span>
                    </button>
                    <div class="hn-user-dropdown" id="userDropdown">
                        <div class="hn-user-dropdown__body">
                            <a class="hn-user-dropdown__item" href="${pageContext.request.contextPath}/study/plans">Kế hoạch học tập</a>
                            <a class="hn-user-dropdown__item" href="${pageContext.request.contextPath}/study/progress">Tiến độ học tập</a>
                            <div class="hn-user-dropdown__divider"></div>
                            <form method="post" action="${pageContext.request.contextPath}/logout" style="margin:0">
                                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                <button class="hn-user-dropdown__item hn-user-dropdown__item--danger" type="submit">Đăng xuất</button>
                            </form>
                        </div>
                    </div>
                </div>
            </sec:authorize>
        </div>
    </div>
</header>

<main style="max-width: 1200px; margin: 32px auto; padding: 0 24px; min-height: 70vh;">

    <!-- Subnav Tabs -->
    <nav class="plan-tabs">
        <a class="plan-tab" href="${pageContext.request.contextPath}/study/plans">
            📋 Kế hoạch
        </a>
        <a class="plan-tab" href="${pageContext.request.contextPath}/study/calendar">
            📅 Lịch học (Calendar)
        </a>
        <a class="plan-tab plan-tab--active" href="${pageContext.request.contextPath}/study/progress">
            📈 Tiến độ khóa học (${totalCourses})
        </a>
        <a class="plan-tab" href="${pageContext.request.contextPath}/study/history">
            ⏱️ Lịch sử hoạt động
        </a>
    </nav>

    <!-- Header -->
    <div class="plan-header">
        <div>
            <h1 class="plan-header__title">Tiến độ học tập (Learning Progress)</h1>
            <p class="plan-header__subtitle">Theo dõi mức độ hoàn thành bài học và hoạt động trong các khóa học bạn đã đăng ký (UC37)</p>
        </div>
    </div>

    <!-- Stats Summary -->
    <div class="plan-stats-grid">
        <div class="plan-stat-card">
            <div class="plan-stat-icon plan-stat-icon--blue">📚</div>
            <div class="plan-stat-info">
                <h4>${totalCourses}</h4>
                <p>Khóa học đã đăng ký</p>
            </div>
        </div>
        <div class="plan-stat-card">
            <div class="plan-stat-icon plan-stat-icon--amber">⏳</div>
            <div class="plan-stat-info">
                <h4>${activeCourses}</h4>
                <p>Đang tiếp tục học</p>
            </div>
        </div>
        <div class="plan-stat-card">
            <div class="plan-stat-icon plan-stat-icon--green">🏆</div>
            <div class="plan-stat-info">
                <h4>${completedCourses}</h4>
                <p>Đã hoàn thành</p>
            </div>
        </div>
    </div>

    <!-- Course Progress Grid -->
    <c:choose>
        <c:when test="${empty progressList}">
            <div style="text-align: center; padding: 60px 20px; background: #fff; border: 1px dashed #cbd5e1; border-radius: 14px;">
                <div style="font-size: 3rem; margin-bottom: 16px;">🎓</div>
                <h3 style="color: #1e293b; margin: 0 0 8px;">Bạn chưa ghi danh khóa học nào</h3>
                <p style="color: #64748b; margin-bottom: 24px;">Hãy khám phá các khóa học thú vị trên EduSphere để bắt đầu lộ trình học tập!</p>
                <a class="btn-primary" href="${pageContext.request.contextPath}/courses">
                    Khám phá khóa học ngay
                </a>
            </div>
        </c:when>
        <c:otherwise>
            <div class="progress-grid">
                <c:forEach items="${progressList}" var="p">
                    <article class="progress-card">
                        <div>
                            <div class="progress-card__header">
                                <div style="display: flex; justify-content: space-between; align-items: center;">
                                    <div class="progress-card__category">${p.categoryName}</div>
                                    <span class="badge badge--${p.enrollmentStatus.toLowerCase()}">${p.enrollmentStatus}</span>
                                </div>
                                <h3 class="progress-card__title">
                                    <a href="${pageContext.request.contextPath}/courses/${p.courseId}" style="text-decoration:none; color:inherit;">
                                        ${p.courseTitle}
                                    </a>
                                </h3>
                                <div class="progress-card__instructor">👨‍🏫 Giảng viên: ${p.instructorName}</div>
                            </div>

                            <div class="progress-bar-container">
                                <div class="progress-bar-labels">
                                    <span>Bài học đã học: ${p.completedLessons} / ${p.totalLessons}</span>
                                    <span style="font-weight: 700; color: #2563eb;">${p.percentComplete}%</span>
                                </div>
                                <div class="progress-bar-track" style="height: 10px;">
                                    <div class="progress-bar-fill ${p.percentComplete >= 100 ? 'progress-bar-fill--green' : ''}"
                                         style="width: ${p.percentComplete}%;"></div>
                                </div>
                            </div>

                            <div style="font-size: 0.8rem; color: #64748b; margin-top: 10px;">
                                <c:if test="${not empty p.lastAccessedAt}">
                                    <div>🕒 Truy cập gần nhất: ${p.lastAccessedAt}</div>
                                </c:if>
                                <c:if test="${empty p.lastAccessedAt}">
                                    <div>🕒 Chưa bắt đầu học</div>
                                </c:if>
                            </div>
                        </div>

                        <div class="progress-card__footer">
                            <a class="btn-primary btn-sm" href="${pageContext.request.contextPath}/courses/${p.courseId}/learn">
                                ${p.percentComplete >= 100 ? 'Xem lại bài học' : 'Tiếp tục học &rarr;'}
                            </a>
                            <a class="btn-secondary btn-sm" href="${pageContext.request.contextPath}/courses/${p.courseId}/results">
                                Bảng điểm
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
</body>
</html>

