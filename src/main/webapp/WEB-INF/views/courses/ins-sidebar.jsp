<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c"   uri="jakarta.tags.core" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<c:set var="cp" value="${pageContext.request.contextPath}"/>

<aside class="ins-sidebar">
    <%-- Brand / Logo --%>
    <a class="ins-sidebar__brand" href="${cp}/instructor/dashboard">
        <div class="ins-sidebar__brand-logo">
            <svg width="22" height="22" viewBox="0 0 24 24" fill="none">
                <path d="M12 2L2 7l10 5 10-5-10-5z" fill="white" opacity=".9"/>
                <path d="M2 17l10 5 10-5" stroke="white" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" fill="none"/>
                <path d="M2 12l10 5 10-5" stroke="white" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" fill="none" opacity=".7"/>
            </svg>
        </div>
        <div class="ins-sidebar__brand-text">
            <span class="ins-sidebar__brand-name">EduSphere</span>
            <span class="ins-sidebar__brand-tagline">Learn · Teach · Grow</span>
        </div>
    </a>

    <%-- Navigation --%>
    <nav class="ins-nav">
        <span class="ins-nav-label">Tổng quan</span>

        <a class="ins-nav-item" id="nav-dashboard" href="${cp}/instructor/dashboard">
            <span class="ins-nav-item__icon">
                <svg width="17" height="17" viewBox="0 0 24 24" fill="none">
                    <rect x="3"  y="3"  width="7" height="7" rx="2" stroke="currentColor" stroke-width="1.8"/>
                    <rect x="14" y="3"  width="7" height="7" rx="2" stroke="currentColor" stroke-width="1.8"/>
                    <rect x="3"  y="14" width="7" height="7" rx="2" stroke="currentColor" stroke-width="1.8"/>
                    <rect x="14" y="14" width="7" height="7" rx="2" stroke="currentColor" stroke-width="1.8"/>
                </svg>
            </span>
            Trang chủ
        </a>

        <span class="ins-nav-label">Quản lý</span>

        <a class="ins-nav-item" id="nav-courses" href="${cp}/instructor/courses">
            <span class="ins-nav-item__icon">
                <svg width="17" height="17" viewBox="0 0 24 24" fill="none">
                    <path d="M4 19.5A2.5 2.5 0 016.5 17H20" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/>
                    <path d="M6.5 2H20v20H6.5A2.5 2.5 0 014 19.5v-15A2.5 2.5 0 016.5 2z" stroke="currentColor" stroke-width="1.8"/>
                </svg>
            </span>
            Khóa học của tôi
        </a>

        <a class="ins-nav-item" id="nav-new-course" href="${cp}/instructor/courses/new">
            <span class="ins-nav-item__icon">
                <svg width="17" height="17" viewBox="0 0 24 24" fill="none">
                    <circle cx="12" cy="12" r="9" stroke="currentColor" stroke-width="1.8"/>
                    <path d="M12 8v8M8 12h8" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/>
                </svg>
            </span>
            Tạo khóa học mới
        </a>

        <span class="ins-nav-label">Tài khoản</span>

        <a class="ins-nav-item" id="nav-profile" href="${cp}/profile">
            <span class="ins-nav-item__icon">
                <svg width="17" height="17" viewBox="0 0 24 24" fill="none">
                    <circle cx="12" cy="8" r="4" stroke="currentColor" stroke-width="1.8"/>
                    <path d="M4 20c0-4 3.6-7 8-7s8 3 8 7" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/>
                </svg>
            </span>
            Hồ sơ cá nhân
        </a>

        <a class="ins-nav-item" id="nav-settings" href="${cp}/change-password">
            <span class="ins-nav-item__icon">
                <svg width="17" height="17" viewBox="0 0 24 24" fill="none">
                    <rect x="3" y="11" width="18" height="11" rx="2" stroke="currentColor" stroke-width="1.8"/>
                    <path d="M7 11V7a5 5 0 0110 0v4" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/>
                </svg>
            </span>
            Cài đặt
        </a>
    </nav>

    <%-- Promo box --%>
    <div class="ins-sidebar__promo">
        <span class="ins-sidebar__promo-icon">🎓</span>
        <span class="ins-sidebar__promo-text">Cùng EduSphere kiến tạo tri thức!</span>
        <span class="ins-sidebar__promo-sub">Phát triển sự nghiệp giảng dạy</span>
    </div>

    <%-- Logout --%>
    <div class="ins-sidebar__bottom">
        <form method="post" action="${cp}/logout" style="margin:0">
            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
            <button class="ins-logout-btn" type="submit">
                <svg viewBox="0 0 24 24" fill="none" width="16" height="16">
                    <path d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"
                          stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
                </svg>
                Đăng xuất
            </button>
        </form>
    </div>
</aside>

<script>
(function() {
    var path = window.location.pathname;
    var cp   = '${cp}';

    // Bỏ context path ra khỏi pathname để so sánh
    var p = path.startsWith(cp) ? path.slice(cp.length) : path;
    // Đảm bảo bắt đầu bằng /
    if (!p.startsWith('/')) p = '/' + p;

    var active = null;

    if (p === '/instructor/dashboard' || p === '/') {
        active = 'nav-dashboard';
    } else if (p.startsWith('/instructor/courses/new')) {
        active = 'nav-new-course';
    } else if (p.startsWith('/instructor/courses')) {
        active = 'nav-courses';
    } else if (p.startsWith('/profile')) {
        active = 'nav-profile';
    } else if (p.startsWith('/change-password')) {
        active = 'nav-settings';
    }

    if (active) {
        var el = document.getElementById(active);
        if (el) el.classList.add('ins-nav-item--active');
    }
})();
</script>
