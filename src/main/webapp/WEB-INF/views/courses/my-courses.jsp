<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Khóa học của tôi — EduSphere</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/home.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/my-courses.css">
</head>
<body>

<!-- ══════ NAVBAR ══════ -->
<jsp:include page="/WEB-INF/views/common/navbar.jsp"/>

<!-- ══════ MAIN ══════ -->
<main class="mc-main">
    <div class="hn-container">

        <!-- Page header -->
        <div class="mc-page-head">
            <div>
                <span class="mc-page-head__eyebrow">Không gian học viên</span>
                <h1 class="mc-page-head__title">Khóa học của tôi</h1>
                <p class="mc-page-head__sub">Những khóa học bạn đã ghi danh.</p>
            </div>
            <a class="hn-btn hn-btn--primary" href="${pageContext.request.contextPath}/courses">
                + Khám phá thêm
            </a>
        </div>

        <!-- Flash success -->
        <c:if test="${not empty success}">
            <div class="mc-alert mc-alert--success">✅ <c:out value="${success}"/></div>
        </c:if>

        <!-- Course list -->
        <c:choose>
            <c:when test="${empty courses}">
                <!-- Empty state -->
                <div class="mc-empty">
                    <div class="mc-empty__icon">📚</div>
                    <h2>Chưa có khóa học nào</h2>
                    <p>Khám phá thư viện và chọn khóa học đầu tiên dành cho bạn.</p>
                    <a class="hn-btn hn-btn--primary hn-btn--lg" href="${pageContext.request.contextPath}/courses">
                        Khám phá khóa học
                    </a>
                </div>
            </c:when>
            <c:otherwise>
                <div class="mc-grid">
                    <c:forEach var="course" items="${courses}">
                        <article class="mc-card">
                            <!-- Thumbnail -->
                            <div class="mc-card__thumb">
                                <span class="mc-card__thumb-icon">📖</span>
                                <!-- Status badge -->
                                <c:choose>
                                    <c:when test="${course.enrollmentStatus == 'COMPLETED'}">
                                        <span class="mc-card__status mc-card__status--done">✅ Hoàn thành</span>
                                    </c:when>
                                    <c:when test="${course.enrollmentStatus == 'ACTIVE'}">
                                        <span class="mc-card__status mc-card__status--active">▶ Đang học</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="mc-card__status mc-card__status--dropped">Đã rời</span>
                                    </c:otherwise>
                                </c:choose>
                            </div>

                            <!-- Body -->
                            <div class="mc-card__body">
                                <h3 class="mc-card__title">
                                    <a href="${pageContext.request.contextPath}/courses/${course.courseId}">
                                        <c:out value="${course.title}"/>
                                    </a>
                                </h3>
                                <p class="mc-card__instructor">
                                    👤 <c:out value="${course.instructorName}"/>
                                </p>

                                <!-- Actions -->
                                <div class="mc-card__actions">
                                    <c:if test="${course.enrollmentStatus ne 'DROPPED'}">
                                        <a class="hn-btn hn-btn--primary mc-btn-sm"
                                           href="${pageContext.request.contextPath}/courses/${course.courseId}/learn">
                                            Vào học →
                                        </a>
                                    </c:if>
                                    <a class="hn-btn mc-btn-outline mc-btn-sm"
                                       href="${pageContext.request.contextPath}/courses/${course.courseId}/results">
                                        📊 Kết quả
                                    </a>
                                    <a class="hn-btn mc-btn-outline mc-btn-sm"
                                       href="${pageContext.request.contextPath}/courses/${course.courseId}#course-reviews">
                                        ⭐ Đánh giá
                                    </a>
                                    <a class="hn-btn mc-btn-outline mc-btn-sm"
                                       href="${pageContext.request.contextPath}/courses/${course.courseId}">
                                        Chi tiết
                                    </a>
                                </div>
                            </div>
                        </article>
                    </c:forEach>
                </div>
            </c:otherwise>
        </c:choose>

    </div>
</main>

<!-- ══════ FOOTER ══════ -->
<footer class="hn-footer">
    <div class="hn-footer__inner">
        <div class="hn-footer__brand">
            <a class="hn-logo" href="${pageContext.request.contextPath}/">
                <div class="hn-logo__icon">🎓</div>
                <span>EduSphere</span>
            </a>
            <p>Nền tảng học tập trực tuyến chất lượng cao dành cho mọi người.</p>
        </div>
        <div class="hn-footer__col">
            <h4>Khóa học</h4>
            <a href="${pageContext.request.contextPath}/courses">Tất cả khóa học</a>
            <a href="${pageContext.request.contextPath}/my-courses">Khóa học của tôi</a>
        </div>
        <div class="hn-footer__col">
            <h4>Tài khoản</h4>
            <a href="${pageContext.request.contextPath}/profile">Hồ sơ</a>
            <a href="${pageContext.request.contextPath}/change-password">Đổi mật khẩu</a>
        </div>
        <div class="hn-footer__col">
            <h4>Liên hệ</h4>
            <span>📧 support@edusphere.vn</span>
            <span>📞 1800-1234</span>
        </div>
    </div>
    <div class="hn-footer__bottom">
        <p>© 2026 EduSphere. Bản quyền thuộc về EduSphere.</p>
    </div>
</footer>

</body>
</html>
