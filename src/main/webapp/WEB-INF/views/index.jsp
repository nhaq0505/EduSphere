<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>EduSphere — Nền tảng học trực tuyến</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/home.css">
</head>
<body>

<!-- ══════════════════════════════════════════════
     NAVBAR
══════════════════════════════════════════════ -->
<header class="hn-header">
    <div class="hn-header__inner">

        <!-- Logo -->
        <a class="hn-logo" href="${pageContext.request.contextPath}/">
            <div class="hn-logo__icon">🎓</div>
            <span>EduSphere</span>
        </a>

        <!-- Nav links -->
        <nav class="hn-nav">
            <a class="hn-nav__link hn-nav__link--active" href="${pageContext.request.contextPath}/">Trang chủ</a>
            <a class="hn-nav__link" href="${pageContext.request.contextPath}/courses">Khóa học</a>
            <sec:authorize access="hasRole('INSTRUCTOR')">
                <a class="hn-nav__link" href="${pageContext.request.contextPath}/instructor/courses">Giảng viên</a>
            </sec:authorize>
            <sec:authorize access="hasRole('ADMINISTRATOR')">
                <a class="hn-nav__link" href="${pageContext.request.contextPath}/admin/users">Quản trị</a>
            </sec:authorize>
            <a class="hn-nav__link" href="#">Về chúng tôi</a>
            <a class="hn-nav__link" href="#">Liên hệ</a>
            <sec:authorize access="hasRole('STUDENT')">
                <a class="hn-nav__link" href="${pageContext.request.contextPath}/student/dashboard">Dashboard</a>
                <a class="hn-nav__link" href="${pageContext.request.contextPath}/study/plans">Kế Hoạch &amp; Tiến Độ</a>
            </sec:authorize>
        </nav>

        <!-- Search + Auth -->
        <div class="hn-header__right">
            <div class="hn-search">
                <svg class="hn-search__icon" width="16" height="16" viewBox="0 0 20 20" fill="none" xmlns="http://www.w3.org/2000/svg">
                    <circle cx="9" cy="9" r="6" stroke="#94a3b8" stroke-width="1.8"/>
                    <path d="M14 14l3 3" stroke="#94a3b8" stroke-width="1.8" stroke-linecap="round"/>
                </svg>
                <input class="hn-search__input" type="text" placeholder="Tìm kiếm khóa học..."
                       onkeydown="if(event.key==='Enter') window.location='${pageContext.request.contextPath}/courses?q='+encodeURIComponent(this.value)">
            </div>

            <button class="hn-icon-btn" aria-label="Thông báo">
                <svg viewBox="0 0 24 24" fill="none" width="20" height="20">
                    <path d="M15 17h5l-1.4-1.4A2 2 0 0118 14V11a6 6 0 00-4-5.66V5a2 2 0 10-4 0v.34A6 6 0 006 11v3a2 2 0 01-.6 1.4L4 17h5m6 0v1a3 3 0 01-6 0v-1m6 0H9" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"/>
                </svg>
            </button>

            <sec:authorize access="isAnonymous()">
                <a class="hn-btn hn-btn--ghost" href="${pageContext.request.contextPath}/login">Đăng nhập</a>
                <a class="hn-btn hn-btn--primary" href="${pageContext.request.contextPath}/register">Đăng ký</a>
            </sec:authorize>
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
                            <sec:authorize access="hasRole('STUDENT')">
                                <a class="hn-user-dropdown__item" href="${pageContext.request.contextPath}/my-courses">
                                    <svg viewBox="0 0 24 24" fill="none" width="16" height="16"><rect x="3" y="3" width="18" height="18" rx="3" stroke="currentColor" stroke-width="1.7"/><path d="M8 12l3 3 5-5" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"/></svg>
                                    Khóa học của tôi
                                </a>
                            </sec:authorize>
                            <sec:authorize access="hasRole('INSTRUCTOR')">
                                <a class="hn-user-dropdown__item" href="${pageContext.request.contextPath}/instructor/courses">
                                    <svg viewBox="0 0 24 24" fill="none" width="16" height="16"><path d="M12 2L2 7l10 5 10-5-10-5zM2 17l10 5 10-5M2 12l10 5 10-5" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"/></svg>
                                    Quản lý khóa học
                                </a>
                            </sec:authorize>
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

<!-- ══════════════════════════════════════════════
     HERO BANNER
══════════════════════════════════════════════ -->
<section class="hn-hero">
    <!-- Background image trải full width -->
    <div class="hn-hero__bg"></div>
    <!-- Overlay nhẹ để chữ dễ đọc bên trái -->
    <div class="hn-hero__overlay"></div>

    <div class="hn-hero__inner">
        <!-- Chữ đè lên ảnh, căn trái -->
        <div class="hn-hero__content">
            <p class="hn-hero__welcome">Chào mừng bạn đến với EduSphere 👋</p>
            <h1 class="hn-hero__title">
                Học mọi lúc, mọi nơi<br>
                <span class="hn-hero__title--blue">Kiến tạo tương lai</span>
            </h1>
            <p class="hn-hero__desc">
                EduSphere là nền tảng học trực tuyến giúp bạn tiếp cận
                kiến thức chất lượng, nâng cao kỹ năng và chinh phục
                những mục tiêu trong học tập và công việc.
            </p>
            <div class="hn-hero__actions">
                <a class="hn-btn hn-btn--primary hn-btn--lg" href="${pageContext.request.contextPath}/courses">
                    Khám phá khóa học →
                </a>
                <a class="hn-btn hn-btn--outline hn-btn--lg" href="#">
                    <span class="hn-play-icon">▶</span>
                    Xem video giới thiệu
                </a>
            </div>
        </div>

        <!-- Floating cards đã bỏ theo yêu cầu -->
        <div class="hn-hero__cards"></div>
    </div>
</section>

<!-- ══════════════════════════════════════════════
     FEATURES BAR
══════════════════════════════════════════════ -->
<section class="hn-features-bar">
    <div class="hn-features-bar__inner">

        <div class="hn-feat-item">
            <div class="hn-feat-item__icon hn-feat-item__icon--blue">
                <svg viewBox="0 0 24 24" fill="none" width="22" height="22">
                    <rect x="3" y="3" width="18" height="18" rx="3" stroke="currentColor" stroke-width="1.8"/>
                    <path d="M8 12l3 3 5-5" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
                </svg>
            </div>
            <div>
                <div class="hn-feat-item__title">Khóa học đa dạng</div>
                <div class="hn-feat-item__sub">Từ cơ bản đến nâng cao,<br>phù hợp mọi nhu cầu.</div>
            </div>
        </div>

        <div class="hn-feat-item__divider"></div>

        <div class="hn-feat-item">
            <div class="hn-feat-item__icon hn-feat-item__icon--blue">
                <svg viewBox="0 0 24 24" fill="none" width="22" height="22">
                    <circle cx="12" cy="8" r="4" stroke="currentColor" stroke-width="1.8"/>
                    <path d="M4 20c0-4 3.6-7 8-7s8 3 8 7" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/>
                </svg>
            </div>
            <div>
                <div class="hn-feat-item__title">Giảng viên chất lượng</div>
                <div class="hn-feat-item__sub">Đội ngũ giảng viên giàu kinh nghiệm,<br>tận tâm.</div>
            </div>
        </div>

        <div class="hn-feat-item__divider"></div>

        <div class="hn-feat-item">
            <div class="hn-feat-item__icon hn-feat-item__icon--blue">
                <svg viewBox="0 0 24 24" fill="none" width="22" height="22">
                    <rect x="2" y="5" width="20" height="14" rx="3" stroke="currentColor" stroke-width="1.8"/>
                    <path d="M8 5V3M16 5V3" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/>
                </svg>
            </div>
            <div>
                <div class="hn-feat-item__title">Học mọi lúc, mọi nơi</div>
                <div class="hn-feat-item__sub">Trên mọi thiết bị: máy tính,<br>điện thoại, tablet.</div>
            </div>
        </div>

        <div class="hn-feat-item__divider"></div>

        <div class="hn-feat-item">
            <div class="hn-feat-item__icon hn-feat-item__icon--blue">
                <svg viewBox="0 0 24 24" fill="none" width="22" height="22">
                    <path d="M12 2l2.4 7.4H22l-6.2 4.5 2.4 7.4L12 17l-6.2 4.3 2.4-7.4L2 9.4h7.6L12 2z" stroke="currentColor" stroke-width="1.8" stroke-linejoin="round"/>
                </svg>
            </div>
            <div>
                <div class="hn-feat-item__title">Thanh toán an toàn</div>
                <div class="hn-feat-item__sub">Nhiều phương thức thanh toán<br>linh hoạt, bảo mật.</div>
            </div>
        </div>

        <div class="hn-feat-item__divider"></div>

        <div class="hn-feat-item">
            <div class="hn-feat-item__icon hn-feat-item__icon--blue">
                <svg viewBox="0 0 24 24" fill="none" width="22" height="22">
                    <path d="M3 5a2 2 0 012-2h14a2 2 0 012 2v10a2 2 0 01-2 2H5a2 2 0 01-2-2V5z" stroke="currentColor" stroke-width="1.8"/>
                    <path d="M3 9h18M9 9v10" stroke="currentColor" stroke-width="1.8"/>
                </svg>
            </div>
            <div>
                <div class="hn-feat-item__title">Hỗ trợ 24/7</div>
                <div class="hn-feat-item__sub">Luôn sẵn sàng giải đáp<br>mọi thắc mắc của bạn.</div>
            </div>
        </div>

    </div>
</section>

<!-- ══════════════════════════════════════════════
     FEATURED COURSES
══════════════════════════════════════════════ -->
<section class="hn-courses-section">
    <div class="hn-container">
        <div class="hn-courses-wrapper">

            <!-- Header: tiêu đề banner + subtitle -->
            <div class="hn-courses-header">
                <div class="hn-courses-header__title-wrap">
                    <span class="hn-courses-header__badge">🔥 Khóa học nổi bật 🔥</span>
                </div>
                <p class="hn-courses-header__sub">• Những khóa học được nhiều người quan tâm nhất •</p>
            </div>

            <!-- Grid courses (sẽ thêm data sau) -->
            <div class="hn-courses-body">
                <div class="hn-course-grid">
                    <!-- Khóa học sẽ được thêm sau -->
                </div>
            </div><!-- /hn-courses-body -->

            <!-- Link xem tất cả -->
            <div class="hn-courses-footer">
                <a class="hn-link-more" href="${pageContext.request.contextPath}/courses">Xem tất cả khóa học →</a>
            </div>

        </div><!-- /hn-courses-wrapper -->
    </div>
</section>

<!-- ══════════════════════════════════════════════
     DANH MỤC KHÓA HỌC
══════════════════════════════════════════════ -->
<section class="hn-cat-section">
    <div class="hn-container">
        <div class="hn-cat-wrapper">

            <!-- Header -->
            <div class="hn-cat-header">
                <div class="hn-cat-header__left">
                    <h2 class="hn-cat-header__title">Danh mục khoá học</h2>
                    <p class="hn-cat-header__sub">Khám phá khoá học theo lĩnh vực bạn quan tâm</p>
                </div>
                <a class="hn-link-more" href="${pageContext.request.contextPath}/courses">Xem tất cả →</a>
            </div>

            <!-- Danh mục sẽ được thêm sau -->
            <div class="hn-cat-grid">
                <!-- items sẽ thêm sau -->
            </div>

        </div>
    </div>
</section>
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
            <a href="${pageContext.request.contextPath}/courses?level=BEGINNER">Dành cho người mới</a>
            <a href="${pageContext.request.contextPath}/courses?priceFilter=FREE">Miễn phí</a>
        </div>
        <div class="hn-footer__col">
            <h4>Tài khoản</h4>
            <a href="${pageContext.request.contextPath}/register">Đăng ký</a>
            <a href="${pageContext.request.contextPath}/login">Đăng nhập</a>
            <a href="${pageContext.request.contextPath}/profile">Hồ sơ</a>
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