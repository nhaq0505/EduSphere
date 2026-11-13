<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Duyệt khóa học — EduSphere Admin</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/home.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/admin.css">
</head>
<body>

<jsp:include page="/WEB-INF/views/admin/header.jsp"/>

<div class="adm-shell">
    <jsp:include page="/WEB-INF/views/admin/sidebar.jsp"/>

    <main class="adm-content">

        <!-- Page head -->
        <div class="adm-page-head">
            <div>
                <span class="adm-page-head__eyebrow">✅ Kiểm duyệt</span>
                <h1 class="adm-page-head__title">Duyệt khóa học</h1>
                <p class="adm-page-head__sub">Xem nội dung giảng viên gửi lên và đưa ra quyết định.</p>
            </div>
            <c:if test="${not empty courses}">
                <div class="adm-page-head__stats">
                    <div class="adm-stat">
                        <span class="adm-stat__num">${courses.size()}</span>
                        <span class="adm-stat__label">Chờ duyệt</span>
                    </div>
                </div>
            </c:if>
        </div>

        <!-- Alerts -->
        <c:if test="${not empty success}"><div class="adm-alert adm-alert--success">✅ <c:out value="${success}"/></div></c:if>

        <!-- Course list -->
        <c:choose>
            <c:when test="${empty courses}">
                <div class="adm-empty">
                    <div class="adm-empty__icon">✅</div>
                    <h3>Không có khóa học chờ duyệt</h3>
                    <p>Hàng chờ hiện đã được xử lý hết.</p>
                </div>
            </c:when>
            <c:otherwise>
                <div class="adm-review-list">
                    <c:forEach var="course" items="${courses}">
                        <div class="adm-review-card">
                            <!-- Card header -->
                            <div class="adm-review-card__head">
                                <div class="adm-review-card__top">
                                    <div>
                                        <h2 class="adm-review-card__title"><c:out value="${course.title}"/></h2>
                                        <div class="adm-review-card__meta">
                                            <span>Giảng viên: <strong><c:out value="${course.instructorName}"/></strong></span>
                                            <c:if test="${not empty course.categoryName}">
                                                <span>Danh mục: <c:out value="${course.categoryName}"/></span>
                                            </c:if>
                                            <span>Phiên bản v<c:out value="${course.versionNo}"/></span>
                                            <span><strong>${course.lessonCount}</strong> bài học</span>
                                            <span>Học phí:
                                                <c:choose>
                                                    <c:when test="${course.price == null or course.price <= 0}">Miễn phí</c:when>
                                                    <c:otherwise><fmt:formatNumber value="${course.price}" type="number" maxFractionDigits="0"/> VNĐ</c:otherwise>
                                                </c:choose>
                                            </span>
                                        </div>
                                    </div>
                                    <span class="adm-pending-badge">Chờ duyệt</span>
                                </div>
                                <c:if test="${not empty course.description}">
                                    <div class="adm-review-card__desc"><c:out value="${course.description}"/></div>
                                </c:if>
                            </div>

                            <!-- Actions -->
                            <div class="adm-review-card__actions">
                                <!-- Xem chi tiết -->
                                <div class="adm-review-form" style="flex:0 0 auto; align-items:flex-start;">
                                    <div class="adm-review-form__label">Xem chi tiết</div>
                                    <p>Xem toàn bộ nội dung, bài học và tài liệu trước khi duyệt.</p>
                                    <div style="display:flex; gap:8px; flex-wrap:wrap;">
                                        <a class="hn-btn hn-btn--outline adm-btn-sm"
                                           href="${pageContext.request.contextPath}/admin/courses/${course.courseId}/review">
                                            Xem nội dung chi tiết →
                                        </a>
                                        <c:if test="${course.versionNo != null and course.versionNo > 1 or course.publishedAt != null}">
                                            <a class="hn-btn hn-btn--outline adm-btn-sm"
                                               href="${pageContext.request.contextPath}/admin/course-change-logs/course/${course.courseId}">
                                                Lịch sử thay đổi
                                            </a>
                                        </c:if>
                                    </div>
                                </div>

                                <!-- Phê duyệt -->
                                <form class="adm-review-form" method="post"
                                      action="${pageContext.request.contextPath}/admin/courses/${course.courseId}/review">
                                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                    <input type="hidden" name="decision" value="APPROVED">
                                    <div class="adm-review-form__label">✅ Phê duyệt</div>
                                    <p>Xác nhận nội dung khóa học đã phù hợp và sẵn sàng công bố.</p>
                                    <button class="hn-btn hn-btn--primary adm-btn-sm" type="submit">Phê duyệt khóa học</button>
                                </form>

                                <!-- Từ chối -->
                                <form class="adm-review-form" method="post"
                                      action="${pageContext.request.contextPath}/admin/courses/${course.courseId}/review">
                                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                    <input type="hidden" name="decision" value="REJECTED">
                                    <div class="adm-review-form__label">❌ Từ chối</div>
                                    <textarea name="comment" rows="3" maxlength="2000"
                                              placeholder="Lý do từ chối (bắt buộc)..." required></textarea>
                                    <button class="adm-btn-danger adm-btn-sm" type="submit">Từ chối khóa học</button>
                                </form>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </c:otherwise>
        </c:choose>

    </main>
</div>

<script>
function toggleUserMenu(e) {
    e.stopPropagation();
    e.currentTarget.closest('.hn-user-menu').classList.toggle('open');
}
document.addEventListener('click', () => {
    document.querySelectorAll('.hn-user-menu.open').forEach(m => m.classList.remove('open'));
});
</script>
</body>
</html>
