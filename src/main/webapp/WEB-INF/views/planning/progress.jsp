<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html><html lang="vi"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1.0">
<title>Tiến độ học tập — EduSphere</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/home.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/planning-new.css">
</head><body>
<jsp:include page="/WEB-INF/views/planning/planning-navbar.jsp"/>
<div class="pl-shell">
<nav class="pl-tabs">
    <a class="pl-tab" href="${pageContext.request.contextPath}/study/plans">📋 Kế hoạch học tập</a>
    <a class="pl-tab" href="${pageContext.request.contextPath}/study/calendar">📅 Lịch học cá nhân</a>
    <a class="pl-tab active" href="${pageContext.request.contextPath}/study/progress">📈 Theo dõi tiến độ</a>
    <a class="pl-tab" href="${pageContext.request.contextPath}/study/history">⏱️ Lịch sử hoạt động</a>
</nav>

<div class="pl-page-head">
    <div>
        <h1>Theo dõi tiến độ học tập</h1>
        <p>Mức độ hoàn thành bài học trong các khóa học đã đăng ký (UC37)</p>
    </div>
</div>

<div class="pl-stats">
    <div class="pl-stat-card">
        <div class="pl-stat-icon pl-stat-icon--blue">📚</div>
        <div><div class="pl-stat-num">${totalCourses}</div><div class="pl-stat-label">Đã ghi danh</div></div>
    </div>
    <div class="pl-stat-card">
        <div class="pl-stat-icon pl-stat-icon--amber">⏳</div>
        <div><div class="pl-stat-num">${activeCourses}</div><div class="pl-stat-label">Đang học</div></div>
    </div>
    <div class="pl-stat-card">
        <div class="pl-stat-icon pl-stat-icon--green">🏆</div>
        <div><div class="pl-stat-num">${completedCourses}</div><div class="pl-stat-label">Đã hoàn thành</div></div>
    </div>
</div>

<c:choose>
    <c:when test="${empty progressList}">
        <div class="pl-empty">
            <div class="pl-empty__icon">🎓</div>
            <h3>Chưa ghi danh khóa học nào</h3>
            <p>Hãy khám phá các khóa học thú vị trên EduSphere!</p>
            <a class="pl-btn pl-btn--primary" href="${pageContext.request.contextPath}/courses">Khám phá khóa học</a>
        </div>
    </c:when>
    <c:otherwise>
        <div class="pl-progress-grid">
            <c:forEach items="${progressList}" var="p">
                <article class="pl-progress-card">
                    <div>
                        <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:4px;">
                            <div class="pl-progress-card__cat"><c:out value="${p.categoryName}"/></div>
                            <span class="pl-badge pl-badge--${p.enrollmentStatus.toLowerCase()}"><c:out value="${p.enrollmentStatus}"/></span>
                        </div>
                        <h3 class="pl-progress-card__title">
                            <a href="${pageContext.request.contextPath}/courses/${p.courseId}/learn" style="text-decoration:none;color:inherit;"><c:out value="${p.courseTitle}"/></a>
                        </h3>
                        <div style="font-size:.82rem;color:#64748b;margin-bottom:14px;">👨‍🏫 <c:out value="${p.instructorName}"/></div>
                        <div class="pl-prog-wrap">
                            <div class="pl-prog-labels">
                                <span>Bài học: ${p.completedLessons} / ${p.totalLessons}</span>
                                <span style="font-weight:700;color:#009bf2;">${p.percentComplete}%</span>
                            </div>
                            <div class="pl-prog-track" style="height:10px;">
                                <div class="pl-prog-fill ${p.percentComplete >= 100 ? 'pl-prog-fill--done' : ''}" style="width:${p.percentComplete}%;"></div>
                            </div>
                        </div>
                        <c:if test="${not empty p.lastAccessedAt}">
                            <div style="font-size:.75rem;color:#94a3b8;">🕒 Gần nhất: <c:out value="${p.lastAccessedAt}"/></div>
                        </c:if>
                        <c:if test="${empty p.lastAccessedAt}">
                            <div style="font-size:.75rem;color:#cbd5e1;">🕒 Chưa bắt đầu học</div>
                        </c:if>
                    </div>
                    <div class="pl-progress-card__footer">
                        <a class="pl-btn pl-btn--primary pl-btn--sm" href="${pageContext.request.contextPath}/courses/${p.courseId}/learn">
                            ${p.percentComplete >= 100 ? 'Xem lại' : 'Tiếp tục học →'}
                        </a>
                    </div>
                </article>
            </c:forEach>
        </div>
    </c:otherwise>
</c:choose>
</div>
<jsp:include page="/WEB-INF/views/planning/planning-footer.jsp"/>
</body></html>