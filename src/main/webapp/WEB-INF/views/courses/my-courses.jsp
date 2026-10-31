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
<header class="hn-header">
    <div class="hn-header__inner">
        <a class="hn-logo" href="${pageContext.request.contextPath}/">
            <div class="hn-logo__icon">🎓</div>
            <span>EduSphere</span>
        </a>
        <nav class="hn-nav">
            <a class="hn-nav__link" href="${pageContext.request.contextPath}/">Trang chủ</a>
            <a class="hn-nav__link" href="${pageContext.request.contextPath}/courses">Khóa học</a>
            <a class="hn-nav__link hn-nav__link--active" href="${pageContext.request.contextPath}/my-courses">Khóa học của tôi</a>
            <a class="hn-nav__link" href="${pageContext.request.contextPath}/study/plans">Kế hoạch học tập</a>
        </nav>
        <div class="hn-header__right">
            <div class="hn-search">
                <svg class="hn-search__icon" width="16" height="16" viewBox="0 0 20 20" fill="none">
                    <circle cx="9" cy="9" r="6" stroke="#94a3b8" stroke-width="1.8"/>
                    <path d="M14 14l3 3" stroke="#94a3b8" stroke-width="1.8" stroke-linecap="round"/>
                </svg>
                <input class="hn-search__input" type="text" placeholder="Tìm kiếm khóa học..."
                       onkeydown="if(event.key==='Enter') window.location='${pageContext.request.contextPath}/courses?q='+encodeURIComponent(this.value)">
            </div>
            <sec:authorize access="isAuthenticated()">
                <div class="hn-user-menu">
                    <button class="hn-user-btn" onclick="toggleUserMenu(event)">
                        <div class="hn-user-btn__avatar">
                            <svg viewBox="0 0 24 24" fill="none" width="18" height="18">
                                <circle cx="12" cy="8" r="4" stroke="currentColor" stroke-width="1.8"/>
                                <path d="M4 20c0-4 3.6-7 8-7s8 3 8 7" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/>
                            </svg>
                        </div>
                        <span class="hn-user-btn__name"><sec:authentication property="principal.fullName"/></span>
                        <svg class="hn-user-btn__arrow" viewBox="0 0 12 8" fill="none" width="10" height="10">
                            <path d="M1 1l5 5 5-5" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"/>
                        </svg>
                    </button>
                    <div class="hn-user-dropdown" id="userDropdown">
                        <div class="hn-user-dropdown__head">
                            <div class="hn-user-dropdown__avatar-icon">
                                <svg viewBox="0 0 24 24" fill="none" width="20" height="20">
                                    <circle cx="12" cy="8" r="4" stroke="white" stroke-width="1.8"/>
                                    <path d="M4 20c0-4 3.6-7 8-7s8 3 8 7" stroke="white" stroke-width="1.8" stroke-linecap="round"/>
                                </svg>
                            </div>
                            <span><sec:authentication property="principal.fullName"/></span>
                        </div>
                        <div class="hn-user-dropdown__body">
                            <a class="hn-user-dropdown__item" href="${pageContext.request.contextPath}/profile">
                                <svg viewBox="0 0 24 24" fill="none" width="16" height="16"><circle cx="12" cy="8" r="4" stroke="currentColor" stroke-width="1.7"/><path d="M4 20c0-4 3.6-7 8-7s8 3 8 7" stroke="currentColor" stroke-width="1.7" stroke-linecap="round"/></svg>
                                Thông tin cá nhân
                            </a>
                            <a class="hn-user-dropdown__item" href="${pageContext.request.contextPath}/my-courses">
                                <svg viewBox="0 0 24 24" fill="none" width="16" height="16"><rect x="3" y="3" width="18" height="18" rx="3" stroke="currentColor" stroke-width="1.7"/><path d="M8 12l3 3 5-5" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"/></svg>
                                Khóa học của tôi
                            </a>
                            <a class="hn-user-dropdown__item" href="${pageContext.request.contextPath}/study/plans">
                                <svg viewBox="0 0 24 24" fill="none" width="16" height="16"><rect x="3" y="4" width="18" height="18" rx="2" stroke="currentColor" stroke-width="1.7"/><path d="M16 2v4M8 2v4M3 10h18" stroke="currentColor" stroke-width="1.7"/></svg>
                                Kế hoạch học tập
                            </a>
                            <a class="hn-user-dropdown__item" href="${pageContext.request.contextPath}/change-password">
                                <svg viewBox="0 0 24 24" fill="none" width="16" height="16"><rect x="5" y="11" width="14" height="10" rx="2" stroke="currentColor" stroke-width="1.7"/><path d="M8 11V7a4 4 0 018 0v4" stroke="currentColor" stroke-width="1.7" stroke-linecap="round"/></svg>
                                Đổi mật khẩu
                            </a>
                            <div class="hn-user-dropdown__divider"></div>
                            <form method="post" action="${pageContext.request.contextPath}/logout" style="margin:0">
                                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                <button class="hn-user-dropdown__item hn-user-dropdown__item--danger" type="submit">
                                    <svg viewBox="0 0 24 24" fill="none" width="16" height="16"><path d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"/></svg>
                                    Đăng xuất
                                </button>
                            </form>
                        </div>
                    </div>
                </div>
            </sec:authorize>
        </div>
    </div>
</header>

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
