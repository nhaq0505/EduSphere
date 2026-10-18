<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý khóa học — EduSphere</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/home.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/instructor.css">
</head>
<body>
<jsp:include page="/WEB-INF/views/courses/ins-header.jsp"/>
<div class="ins-shell">
    <jsp:include page="/WEB-INF/views/courses/ins-sidebar.jsp"/>
    <main class="ins-content">

        <div class="ins-page-head">
            <div>
                <span class="ins-page-head__eyebrow">🧑‍🏫 Giảng viên</span>
                <h1 class="ins-page-head__title">Khóa học của tôi</h1>
                <p class="ins-page-head__sub">Tạo bản nháp, gửi duyệt và theo dõi quá trình công bố.</p>
            </div>
            <a class="ins-btn-primary" style="width:auto;padding:10px 22px"
               href="${pageContext.request.contextPath}/instructor/courses/new">+ Tạo khóa học mới</a>
        </div>

        <c:if test="${not empty success}"><div class="ins-alert ins-alert--success">✅ <c:out value="${success}"/></div></c:if>

        <c:choose>
            <c:when test="${empty courses}">
                <div class="ins-empty">
                    <div class="ins-empty__icon">📚</div>
                    <h3>Bắt đầu với khóa học đầu tiên</h3>
                    <p>Tạo bản nháp, thêm bài học rồi gửi quản trị viên duyệt.</p>
                    <a class="ins-btn-primary" style="width:auto;padding:11px 28px;margin:0 auto"
                       href="${pageContext.request.contextPath}/instructor/courses/new">+ Tạo khóa học mới</a>
                </div>
            </c:when>
            <c:otherwise>
                <div class="ins-course-grid">
                    <c:forEach var="course" items="${courses}">
                        <article class="ins-course-card">
                            <div class="ins-course-card__thumb">
                                📖
                                <c:choose>
                                    <c:when test="${course.status == 'DRAFT'}">     <span class="ins-status-badge ins-status-badge--draft">Bản nháp</span></c:when>
                                    <c:when test="${course.status == 'SUBMITTED'}"> <span class="ins-status-badge ins-status-badge--submitted">Chờ duyệt</span></c:when>
                                    <c:when test="${course.status == 'APPROVED'}">  <span class="ins-status-badge ins-status-badge--approved">Đã duyệt</span></c:when>
                                    <c:when test="${course.status == 'PUBLISHED'}"> <span class="ins-status-badge ins-status-badge--published">Đã công bố</span></c:when>
                                    <c:when test="${course.status == 'REJECTED'}">  <span class="ins-status-badge ins-status-badge--rejected">Cần chỉnh sửa</span></c:when>
                                    <c:otherwise>                                   <span class="ins-status-badge ins-status-badge--archived">Đã lưu trữ</span></c:otherwise>
                                </c:choose>
                            </div>
                            <div class="ins-course-card__body">
                                <span class="ins-course-card__cat"><c:out value="${course.categoryName}" default="Chưa phân loại"/></span>
                                <h3 class="ins-course-card__title">
                                    <a href="${pageContext.request.contextPath}/instructor/courses/${course.courseId}">
                                        <c:out value="${course.title}"/>
                                    </a>
                                </h3>
                                <p class="ins-course-card__meta">Phiên bản <c:out value="${course.versionNo}"/></p>
                                <div class="ins-course-card__footer">
                                    <a class="ins-link-btn ins-link-btn--primary"
                                       href="${pageContext.request.contextPath}/instructor/courses/${course.courseId}">
                                       Chi tiết →
                                    </a>
                                    <c:if test="${course.status == 'DRAFT' || course.status == 'REJECTED'}">
                                        <a class="ins-link-btn"
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
<script>
function toggleUserMenu(e){e.stopPropagation();e.currentTarget.closest('.hn-user-menu').classList.toggle('open');}
document.addEventListener('click',()=>document.querySelectorAll('.hn-user-menu.open').forEach(m=>m.classList.remove('open')));
</script>
</body></html>
