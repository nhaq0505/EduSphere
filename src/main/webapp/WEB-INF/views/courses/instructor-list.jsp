<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Khóa học của tôi — EduSphere</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/instructor.css">
</head>
<body>
<div class="ins-layout">
    <jsp:include page="/WEB-INF/views/courses/ins-sidebar.jsp"/>
    <div class="ins-main-wrapper">
        <jsp:include page="/WEB-INF/views/courses/ins-header.jsp"/>
        <main class="ins-page">

            <div class="ins-page-head">
                <div>
                    <span class="ins-page-head__eyebrow">Giáo viên</span>
                    <h1 class="ins-page-head__title">Khóa học của tôi</h1>
                    <p class="ins-page-head__sub">Tạo bản nháp, gửi duyệt và theo dõi quá trình công bố.</p>
                </div>
                <a class="ins-btn ins-btn--primary"
                   href="${pageContext.request.contextPath}/instructor/courses/new">
                    <svg width="14" height="14" viewBox="0 0 24 24" fill="none">
                        <circle cx="12" cy="12" r="9" stroke="white" stroke-width="2"/>
                        <path d="M12 8v8M8 12h8" stroke="white" stroke-width="2" stroke-linecap="round"/>
                    </svg>
                    Tạo khóa học mới
                </a>
            </div>

            <c:if test="${not empty success}">
                <div class="ins-alert ins-alert--success">✅ <c:out value="${success}"/></div>
            </c:if>

            <c:choose>
                <c:when test="${empty courses}">
                    <div class="ins-empty">
                        <span class="ins-empty__icon">📚</span>
                        <h3>Bắt đầu với khóa học đầu tiên</h3>
                        <p>Tạo bản nháp, thêm bài học rồi gửi quản trị viên duyệt.</p>
                        <a class="ins-btn ins-btn--primary" style="margin:0 auto"
                           href="${pageContext.request.contextPath}/instructor/courses/new">+ Tạo khóa học mới</a>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="ins-course-grid">
                        <c:forEach var="course" items="${courses}">
                            <article class="ins-course-card">
                                <div class="ins-course-card__thumb">
                                    📖
                                    <div class="ins-course-card__status-badge">
                                        <c:choose>
                                            <c:when test="${course.hidden}">
                                                <span class="ins-badge ins-badge--hidden">Tạm ẩn</span>
                                            </c:when>
                                            <c:when test="${course.status == 'DRAFT'}">
                                                <span class="ins-badge ins-badge--draft">Bản nháp</span>
                                            </c:when>
                                            <c:when test="${course.status == 'SUBMITTED'}">
                                                <span class="ins-badge ins-badge--submitted">Chờ duyệt</span>
                                            </c:when>
                                            <c:when test="${course.status == 'APPROVED'}">
                                                <span class="ins-badge ins-badge--approved">Đã duyệt</span>
                                            </c:when>
                                            <c:when test="${course.status == 'PUBLISHED'}">
                                                <span class="ins-badge ins-badge--published">Đã xuất bản</span>
                                            </c:when>
                                            <c:when test="${course.status == 'REJECTED'}">
                                                <span class="ins-badge ins-badge--rejected">Cần chỉnh sửa</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="ins-badge ins-badge--archived">Đã lưu trữ</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                </div>
                                <div class="ins-course-card__body">
                                    <span class="ins-course-card__cat">
                                        <c:out value="${course.categoryName}" default="Chưa phân loại"/>
                                    </span>
                                    <h3 class="ins-course-card__title">
                                        <a href="${pageContext.request.contextPath}/instructor/courses/${course.courseId}">
                                            <c:out value="${course.title}"/>
                                        </a>
                                    </h3>
                                    <div class="ins-course-card__meta">
                                        <span>v<c:out value="${course.versionNo}"/></span>
                                        <span>•</span>
                                        <span>${course.lessonCount} bài học</span>
                                    </div>
                                    <div class="ins-course-card__footer">
                                        <a class="ins-btn ins-btn--primary ins-btn--sm"
                                           href="${pageContext.request.contextPath}/instructor/courses/${course.courseId}">
                                            Chi tiết →
                                        </a>
                                        <c:if test="${course.status != 'SUBMITTED' && course.status != 'ARCHIVED'}">
                                            <a class="ins-btn ins-btn--outline ins-btn--sm"
                                               href="${pageContext.request.contextPath}/instructor/courses/${course.courseId}/edit">
                                                ✏️ Sửa
                                            </a>
                                        </c:if>
                                    </div>
                                </div>
                            </article>
                        </c:forEach>
                    </div>
                </c:otherwise>
            </c:choose>
        </main>
    </div>
</div>
<script>
function insToggleMenu(e) {
    e.stopPropagation();
    document.getElementById('insUserMenu').classList.toggle('open');
}
document.addEventListener('click', function() {
    var m = document.getElementById('insUserMenu');
    if (m) m.classList.remove('open');
});
</script>
</body>
</html>
