<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c"   uri="jakarta.tags.core" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<c:set var="cp" value="${pageContext.request.contextPath}"/>
<header class="hn-header">
    <div class="hn-header__inner">

        <%-- Logo --%>
        <a class="hn-logo" href="${cp}/" aria-label="EduSphere">
            <div class="hn-logo__icon">🎓</div>
            <span>EduSphere</span>
        </a>

        <%-- Navigation links --%>
        <nav class="hn-nav" aria-label="Điều hướng chính">
            <a class="hn-nav__link" href="${cp}/courses">Khám phá khóa học</a>
            <sec:authorize access="hasRole('STUDENT')">
                <a class="hn-nav__link" href="${cp}/my-courses">Khóa học của tôi</a>
                <a class="hn-nav__link" href="${cp}/certificates">Kho tín chỉ &amp; Chứng chỉ</a>
                <a class="hn-nav__link" href="${cp}/study/plans">Kế hoạch học tập</a>
            </sec:authorize>
            <sec:authorize access="hasRole('INSTRUCTOR')">
                <a class="hn-nav__link" href="${cp}/instructor/dashboard">Giảng viên</a>
            </sec:authorize>
            <sec:authorize access="hasRole('ADMINISTRATOR')">
                <a class="hn-nav__link" href="${cp}/admin/courses/review">Duyệt khóa học</a>
                <a class="hn-nav__link" href="${cp}/admin/users">Tài khoản</a>
            </sec:authorize>
        </nav>

        <%-- Right section --%>
        <div class="hn-header__right">
            <sec:authorize access="isAnonymous()">
                <a class="hn-btn hn-btn--ghost" href="${cp}/login">Đăng nhập</a>
                <a class="hn-btn hn-btn--primary" href="${cp}/register">Đăng ký</a>
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
                            <a class="hn-user-dropdown__item" href="${cp}/profile">
                                <svg viewBox="0 0 24 24" fill="none" width="15" height="15"><circle cx="12" cy="8" r="4" stroke="currentColor" stroke-width="1.7"/><path d="M4 20c0-4 3.6-7 8-7s8 3 8 7" stroke="currentColor" stroke-width="1.7" stroke-linecap="round"/></svg>
                                Hồ sơ cá nhân
                            </a>
                            <sec:authorize access="hasRole('STUDENT')">
                                <a class="hn-user-dropdown__item" href="${cp}/my-courses">
                                    <svg viewBox="0 0 24 24" fill="none" width="15" height="15"><path d="M4 19.5A2.5 2.5 0 016.5 17H20" stroke="currentColor" stroke-width="1.7" stroke-linecap="round"/><path d="M6.5 2H20v20H6.5A2.5 2.5 0 014 19.5v-15A2.5 2.5 0 016.5 2z" stroke="currentColor" stroke-width="1.7"/></svg>
                                    Khóa học của tôi
                                </a>
                            </sec:authorize>
                            <sec:authorize access="hasRole('INSTRUCTOR')">
                                <a class="hn-user-dropdown__item" href="${cp}/instructor/dashboard">
                                    <svg viewBox="0 0 24 24" fill="none" width="15" height="15"><rect x="3" y="3" width="7" height="7" rx="2" stroke="currentColor" stroke-width="1.7"/><rect x="14" y="3" width="7" height="7" rx="2" stroke="currentColor" stroke-width="1.7"/><rect x="3" y="14" width="7" height="7" rx="2" stroke="currentColor" stroke-width="1.7"/><rect x="14" y="14" width="7" height="7" rx="2" stroke="currentColor" stroke-width="1.7"/></svg>
                                    Dashboard Giảng viên
                                </a>
                            </sec:authorize>
                            <a class="hn-user-dropdown__item" href="${cp}/change-password">
                                <svg viewBox="0 0 24 24" fill="none" width="15" height="15"><rect x="3" y="11" width="18" height="11" rx="2" stroke="currentColor" stroke-width="1.7"/><path d="M7 11V7a5 5 0 0110 0v4" stroke="currentColor" stroke-width="1.7" stroke-linecap="round"/></svg>
                                Đổi mật khẩu
                            </a>
                            <div class="hn-user-dropdown__divider"></div>
                            <form method="post" action="${cp}/logout" style="margin:0">
                                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                <button class="hn-user-dropdown__item hn-user-dropdown__item--danger" type="submit">
                                    <svg viewBox="0 0 24 24" fill="none" width="15" height="15"><path d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1" stroke="currentColor" stroke-width="1.7" stroke-linecap="round"/></svg>
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
<script>
function toggleUserMenu(e) {
    e.stopPropagation();
    document.getElementById('userDropdown').closest('.hn-user-menu').classList.toggle('open');
}
document.addEventListener('click', function() {
    document.querySelectorAll('.hn-user-menu.open').forEach(function(m) { m.classList.remove('open'); });
});
</script>
