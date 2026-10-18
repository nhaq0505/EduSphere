<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chi tiết khóa học — EduSphere</title>
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

        <a class="ins-back-link" href="${pageContext.request.contextPath}/instructor/courses">← Danh sách khóa học</a>

        <c:if test="${not empty success}"><div class="ins-alert ins-alert--success">✅ <c:out value="${success}"/></div></c:if>

        <div class="ins-detail-layout">
            <!-- Main info -->
            <div class="ins-detail-main">
                <div class="ins-detail-main__header">
                    <c:choose>
                        <c:when test="${course.status=='DRAFT'}">     <span class="ins-status-badge ins-status-badge--draft">Bản nháp</span></c:when>
                        <c:when test="${course.status=='SUBMITTED'}"> <span class="ins-status-badge ins-status-badge--submitted">Chờ duyệt</span></c:when>
                        <c:when test="${course.status=='APPROVED'}">  <span class="ins-status-badge ins-status-badge--approved">Đã duyệt</span></c:when>
                        <c:when test="${course.status=='PUBLISHED'}"> <span class="ins-status-badge ins-status-badge--published">Đã công bố</span></c:when>
                        <c:when test="${course.status=='REJECTED'}">  <span class="ins-status-badge ins-status-badge--rejected">Cần chỉnh sửa</span></c:when>
                        <c:otherwise>                                 <span class="ins-status-badge ins-status-badge--archived">Đã lưu trữ</span></c:otherwise>
                    </c:choose>
                    <h1><c:out value="${course.title}"/></h1>
                </div>
                <div class="ins-detail-main__body">

                    <c:if test="${course.status == 'REJECTED' && not empty course.latestReviewComment}">
                        <div class="ins-alert ins-alert--error">
                            ❌ <strong>Lý do từ chối:</strong> <c:out value="${course.latestReviewComment}"/>
                        </div>
                    </c:if>

                    <h2>Thông tin chung</h2>
                    <table class="ins-info-table">
                        <tr>
                            <th>Danh mục</th>
                            <td><c:out value="${course.categoryName}" default="Chưa phân loại"/></td>
                        </tr>
                        <tr>
                            <th>Trình độ</th>
                            <td><c:choose>
                                <c:when test="${course.level=='BEGINNER'}">Cơ bản</c:when>
                                <c:when test="${course.level=='INTERMEDIATE'}">Trung cấp</c:when>
                                <c:when test="${course.level=='ADVANCED'}">Nâng cao</c:when>
                                <c:otherwise>Mọi trình độ</c:otherwise>
                            </c:choose></td>
                        </tr>
                        <tr>
                            <th>Học phí</th>
                            <td>
                                <c:choose>
                                    <c:when test="${course.price == 0}"><span style="color:#16A34A;font-weight:700">Miễn phí</span></c:when>
                                    <c:otherwise><fmt:formatNumber value="${course.price}" type="number" maxFractionDigits="0"/>đ</c:otherwise>
                                </c:choose>
                            </td>
                        </tr>
                        <tr>
                            <th>Phiên bản</th>
                            <td>v<c:out value="${course.versionNo}"/></td>
                        </tr>
                    </table>

                    <h2>Mô tả khóa học</h2>
                    <p class="ins-detail-desc"><c:out value="${course.description}" default="Chưa có mô tả."/></p>

                    <div style="margin-top:24px">
                        <a class="ins-btn-outline" style="width:auto;display:inline-flex"
                           href="${pageContext.request.contextPath}/instructor/courses/${course.courseId}/lessons">
                            📋 Quản lý bài học →
                        </a>
                    </div>
                </div>
            </div>

            <!-- Action aside -->
            <aside class="ins-aside">
                <div class="ins-aside__header">⚡ Bước tiếp theo</div>
                <div class="ins-aside__body">
                    <c:choose>
                        <c:when test="${course.status == 'DRAFT' || course.status == 'REJECTED'}">
                            <p class="ins-aside__note">Kiểm tra thông tin và bài học trước khi gửi duyệt.</p>
                            <a class="ins-btn-outline"
                               href="${pageContext.request.contextPath}/instructor/courses/${course.courseId}/edit">
                               ✏️ Chỉnh sửa thông tin
                            </a>
                            <div class="ins-aside__divider"></div>
                            <form method="post" action="${pageContext.request.contextPath}/instructor/courses/${course.courseId}/submit" style="margin:0">
                                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                <button class="ins-btn-primary" type="submit">📤 Gửi duyệt</button>
                            </form>
                        </c:when>
                        <c:when test="${course.status == 'SUBMITTED'}">
                            <p class="ins-aside__note">⏳ Đang chờ quản trị viên xem xét. Bạn không thể chỉnh sửa lúc này.</p>
                        </c:when>
                        <c:when test="${course.status == 'APPROVED'}">
                            <p class="ins-aside__note">✅ Khóa học đã được duyệt! Công bố để học viên có thể nhìn thấy.</p>
                            <form method="post" action="${pageContext.request.contextPath}/instructor/courses/${course.courseId}/publish" style="margin:0">
                                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                <button class="ins-btn-primary" type="submit">🚀 Công bố khóa học</button>
                            </form>
                        </c:when>
                        <c:when test="${course.status == 'PUBLISHED'}">
                            <p class="ins-aside__note">🌐 Khóa học đang được công khai cho học viên.</p>
                            <div class="ins-aside__divider"></div>
                            <form method="post" action="${pageContext.request.contextPath}/instructor/courses/${course.courseId}/archive" style="margin:0">
                                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                <button class="ins-btn-danger" type="submit">📦 Lưu trữ khóa học</button>
                            </form>
                        </c:when>
                        <c:otherwise>
                            <p class="ins-aside__note">📦 Khóa học đã được lưu trữ.</p>
                        </c:otherwise>
                    </c:choose>
                </div>
            </aside>
        </div>
    </main>
</div>
<script>
function toggleUserMenu(e){e.stopPropagation();e.currentTarget.closest('.hn-user-menu').classList.toggle('open');}
document.addEventListener('click',()=>document.querySelectorAll('.hn-user-menu.open').forEach(m=>m.classList.remove('open')));
</script>
</body></html>
