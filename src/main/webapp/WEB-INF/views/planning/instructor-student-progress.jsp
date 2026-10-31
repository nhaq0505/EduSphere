<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tiến độ học viên: ${course.title} — EduSphere</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/home.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/instructor.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/planning.css">
</head>
<body>
<jsp:include page="/WEB-INF/views/courses/ins-header.jsp"/>

<div class="ins-shell">
    <jsp:include page="/WEB-INF/views/courses/ins-sidebar.jsp"/>

    <main class="ins-content">
        <a class="ins-back-link" href="${pageContext.request.contextPath}/instructor/courses/${course.courseId}">
            &larr; Quay lại chi tiết khóa học
        </a>

        <!-- Header -->
        <div style="margin-top: 12px; margin-bottom: 24px;">
            <div style="font-size: 0.85rem; font-weight: 700; color: #2563eb; text-transform: uppercase; letter-spacing: 0.04em;">
                Theo dõi tiến độ học viên (UC39)
            </div>
            <h1 style="font-size: 1.7rem; font-weight: 800; color: #0f172a; margin: 4px 0 6px;">
                ${course.title}
            </h1>
            <p style="color: #64748b; font-size: 0.92rem; margin: 0;">
                Danh sách học viên đã ghi danh và mức độ hoàn thành bài học trong khóa học do bạn phụ trách.
            </p>
        </div>

        <!-- Summary Stats -->
        <div class="plan-stats-grid">
            <div class="plan-stat-card">
                <div class="plan-stat-icon plan-stat-icon--blue">👥</div>
                <div class="plan-stat-info">
                    <h4>${totalStudents}</h4>
                    <p>Tổng học viên ghi danh</p>
                </div>
            </div>
            <div class="plan-stat-card">
                <div class="plan-stat-icon plan-stat-icon--green">🎓</div>
                <div class="plan-stat-info">
                    <h4>${completedStudents}</h4>
                    <p>Học viên đã hoàn thành</p>
                </div>
            </div>
            <div class="plan-stat-card">
                <div class="plan-stat-icon plan-stat-icon--amber">📊</div>
                <div class="plan-stat-info">
                    <h4>${avgProgress}%</h4>
                    <p>Tiến độ trung bình khóa học</p>
                </div>
            </div>
        </div>

        <!-- Student Progress Table -->
        <c:choose>
            <c:when test="${empty students}">
                <div style="text-align: center; padding: 60px 20px; background: #fff; border: 1px dashed #cbd5e1; border-radius: 12px; margin-top: 20px;">
                    <div style="font-size: 3rem; margin-bottom: 12px;">👨‍🎓</div>
                    <h3 style="color: #1e293b; margin: 0 0 6px;">Chưa có học viên nào ghi danh khóa học này</h3>
                    <p style="color: #64748b;">Khi có học viên tham gia học, tiến độ chi tiết sẽ được tự động cập nhật tại đây.</p>
                </div>
            </c:when>
            <c:otherwise>
                <div class="task-table-card">
                    <table class="task-table">
                        <thead>
                            <tr>
                                <th style="width: 32%;">Học viên</th>
                                <th style="width: 25%;">Tiến độ hoàn thành</th>
                                <th style="width: 15%;">Số bài đã học</th>
                                <th style="width: 15%;">Truy cập gần nhất</th>
                                <th style="width: 13%; text-align: center;">Trạng thái</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach items="${students}" var="s">
                                <tr>
                                    <td>
                                        <div class="student-info-cell">
                                            <div class="student-avatar">
                                                ${s.fullName.substring(0, 1).toUpperCase()}
                                            </div>
                                            <div>
                                                <div class="student-name">${s.fullName}</div>
                                                <div class="student-email">${s.email}</div>
                                            </div>
                                        </div>
                                    </td>
                                    <td>
                                        <div class="progress-bar-container" style="margin-bottom: 0;">
                                            <div class="progress-bar-labels" style="font-size: 0.78rem;">
                                                <span>${s.percentComplete}%</span>
                                            </div>
                                            <div class="progress-bar-track">
                                                <div class="progress-bar-fill ${s.percentComplete >= 100 ? 'progress-bar-fill--green' : ''}"
                                                     style="width: ${s.percentComplete}%;"></div>
                                            </div>
                                        </div>
                                    </td>
                                    <td>
                                        <div style="font-weight: 600; color: #1e293b;">
                                            ${s.completedLessons} / ${s.totalLessons} bài
                                        </div>
                                    </td>
                                    <td>
                                        <div style="font-size: 0.82rem; color: #64748b;">
                                            <c:if test="${not empty s.lastAccessedAt}">
                                                ${s.lastAccessedAt}
                                            </c:if>
                                            <c:if test="${empty s.lastAccessedAt}">
                                                <span style="font-style: italic; color: #94a3b8;">Chưa học</span>
                                            </c:if>
                                        </div>
                                    </td>
                                    <td style="text-align: center;">
                                        <span class="badge badge--${s.enrollmentStatus.toLowerCase()}">
                                            ${s.enrollmentStatus}
                                        </span>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </c:otherwise>
        </c:choose>

    </main>
</div>

<script>
function toggleUserMenu(e){e.stopPropagation();e.currentTarget.closest('.hn-user-menu').classList.toggle('open');}
document.addEventListener('click',()=>document.querySelectorAll('.hn-user-menu.open').forEach(m=>m.classList.remove('open')));
</script>
</body>
</html>

