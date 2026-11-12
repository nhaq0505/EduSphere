<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"   uri="jakarta.tags.core" %>
<%@ taglib prefix="fn"  uri="jakarta.tags.functions" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<c:set var="cp" value="${pageContext.request.contextPath}"/>

<%-- Xác định tab đang active dựa trên request URI --%>
<c:set var="currentUri" value="${requestScope['jakarta.servlet.forward.request_uri']}"/>
<c:if test="${empty currentUri}">
    <c:set var="currentUri" value="${pageContext.request.requestURI}"/>
</c:if>
<c:set var="isHome" value="${empty currentUri or currentUri == cp or currentUri == cp.concat('/') or fn:endsWith(currentUri, '/index.jsp')}"/>
<c:set var="isCourses" value="${fn:contains(currentUri, '/courses') and not fn:contains(currentUri, '/my-courses')}"/>
<c:set var="isPlans" value="${fn:contains(currentUri, '/study/') or fn:contains(currentUri, '/planning')}"/>

<header class="hn-header">
    <div class="hn-header__inner">

        <!-- Logo -->
        <a class="hn-logo" href="${cp}/" aria-label="EduSphere">
            <div class="hn-logo__icon">🎓</div>
            <span>EduSphere</span>
        </a>

        <!-- Navigation Links -->
        <nav class="hn-nav" aria-label="Điều hướng chính">
            <a class="hn-nav__link ${isHome ? 'hn-nav__link--active' : ''}" href="${cp}/">Trang chủ</a>
            <a class="hn-nav__link ${isCourses ? 'hn-nav__link--active' : ''}" href="${cp}/courses">Khóa học</a>
            
            <sec:authorize access="hasRole('INSTRUCTOR')">
                <a class="hn-nav__link" href="${cp}/instructor/courses">Giảng viên</a>
            </sec:authorize>
            <sec:authorize access="hasRole('ADMINISTRATOR')">
                <a class="hn-nav__link" href="${cp}/admin/users">Quản trị</a>
            </sec:authorize>
            
            <a class="hn-nav__link" href="${cp}/#about">Về chúng tôi</a>
            <a class="hn-nav__link" href="${cp}/#contact">Liên hệ</a>
            
            <sec:authorize access="hasRole('STUDENT') or isAnonymous()">
                <a class="hn-nav__link ${isPlans ? 'hn-nav__link--active' : ''}" href="${cp}/study/plans">Kế Hoạch &amp; Tiến Độ</a>
            </sec:authorize>
        </nav>

        <!-- Right: Search + Notifications + User Menu -->
        <div class="hn-header__right">
            <!-- Search Bar -->
            <div class="hn-search">
                <svg class="hn-search__icon" width="16" height="16" viewBox="0 0 20 20" fill="none" xmlns="http://www.w3.org/2000/svg">
                    <circle cx="9" cy="9" r="6" stroke="#94a3b8" stroke-width="1.8"/>
                    <path d="M14 14l3 3" stroke="#94a3b8" stroke-width="1.8" stroke-linecap="round"/>
                </svg>
                <input class="hn-search__input" type="text" placeholder="Tìm kiếm khóa học..."
                       value="<c:out value='${param.q}'/>"
                       onkeydown="if(event.key==='Enter') window.location='${cp}/courses?q='+encodeURIComponent(this.value)">
            </div>

            <!-- Notification Bell Icon -->
            <button class="hn-icon-btn" aria-label="Thông báo" type="button" title="Thông báo">
                <svg viewBox="0 0 24 24" fill="none" width="20" height="20">
                    <path d="M15 17h5l-1.4-1.4A2 2 0 0118 14V11a6 6 0 00-4-5.66V5a2 2 0 10-4 0v.34A6 6 0 006 11v3a2 2 0 01-.6 1.4L4 17h5m6 0v1a3 3 0 01-6 0v-1m6 0H9" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"/>
                </svg>
            </button>

            <!-- Authentication Controls -->
            <sec:authorize access="isAnonymous()">
                <a class="hn-btn hn-btn--ghost" href="${cp}/login">Đăng nhập</a>
                <a class="hn-btn hn-btn--primary" href="${cp}/register">Đăng ký</a>
            </sec:authorize>

            <sec:authorize access="isAuthenticated()">
                <div class="hn-user-menu">
                    <button class="hn-user-btn" type="button" onclick="toggleCommonUserMenu(event)">
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

                    <div class="hn-user-dropdown" id="commonUserDropdown">
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
                                <svg viewBox="0 0 24 24" fill="none" width="16" height="16"><circle cx="12" cy="8" r="4" stroke="currentColor" stroke-width="1.7"/><path d="M4 20c0-4 3.6-7 8-7s8 3 8 7" stroke="currentColor" stroke-width="1.7" stroke-linecap="round"/></svg>
                                Thông tin cá nhân
                            </a>
                            <sec:authorize access="hasRole('STUDENT')">
                                <a class="hn-user-dropdown__item" href="${cp}/my-courses">
                                    <svg viewBox="0 0 24 24" fill="none" width="16" height="16"><rect x="3" y="3" width="18" height="18" rx="3" stroke="currentColor" stroke-width="1.7"/><path d="M8 12l3 3 5-5" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"/></svg>
                                    Khóa học của tôi
                                </a>
                                <a class="hn-user-dropdown__item" href="${cp}/study/plans">
                                    <svg viewBox="0 0 24 24" fill="none" width="16" height="16"><path d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" stroke="currentColor" stroke-width="1.7"/></svg>
                                    Kế hoạch học tập
                                </a>
                                <a class="hn-user-dropdown__item" href="${cp}/study/progress">
                                    <svg viewBox="0 0 24 24" fill="none" width="16" height="16"><circle cx="12" cy="12" r="10" stroke="currentColor" stroke-width="1.7"/><path d="M12 6v6l4 2" stroke="currentColor" stroke-width="1.7"/></svg>
                                    Tiến độ học tập
                                </a>
                                <a class="hn-user-dropdown__item" href="${cp}/certificates">
                                    <svg viewBox="0 0 24 24" fill="none" width="16" height="16"><path d="M12 15l-2 5 4-2 4 2-2-5" stroke="currentColor" stroke-width="1.7"/><circle cx="12" cy="9" r="6" stroke="currentColor" stroke-width="1.7"/></svg>
                                    Kho tín chỉ &amp; Chứng chỉ
                                </a>
                            </sec:authorize>
                            <sec:authorize access="hasRole('INSTRUCTOR')">
                                <a class="hn-user-dropdown__item" href="${cp}/instructor/courses">
                                    <svg viewBox="0 0 24 24" fill="none" width="16" height="16"><path d="M12 2L2 7l10 5 10-5-10-5zM2 17l10 5 10-5M2 12l10 5 10-5" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"/></svg>
                                    Quản lý khóa học
                                </a>
                            </sec:authorize>
                            <a class="hn-user-dropdown__item" href="${cp}/change-password">
                                <svg viewBox="0 0 24 24" fill="none" width="16" height="16"><rect x="5" y="11" width="14" height="10" rx="2" stroke="currentColor" stroke-width="1.7"/><path d="M8 11V7a4 4 0 018 0v4" stroke="currentColor" stroke-width="1.7" stroke-linecap="round"/></svg>
                                Đổi mật khẩu
                            </a>
                            <div class="hn-user-dropdown__divider"></div>
                            <form method="post" action="${cp}/logout" style="margin:0">
                                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                <button class="hn-user-dropdown__item hn-user-dropdown__item--danger" type="submit">
                                    <svg viewBox="0 0 24 24" fill="none" width="16" height="16"><path d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1" stroke="currentColor" stroke-width="1.7" stroke-linecap="round"/></svg>
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
if (!window.eduSphereNavbarInitialized) {
    window.eduSphereNavbarInitialized = true;
    function toggleCommonUserMenu(e) {
        e.stopPropagation();
        var menu = e.currentTarget.closest('.hn-user-menu');
        if (menu) {
            menu.classList.toggle('open');
        }
    }
    // Hỗ trợ hàm toggleUserMenu cũ nếu trang nào đang gọi
    window.toggleUserMenu = toggleCommonUserMenu;
    window.togglePlanningUserMenu = toggleCommonUserMenu;

    document.addEventListener('click', function(e) {
        document.querySelectorAll('.hn-user-menu.open').forEach(function(m) {
            if (!m.contains(e.target)) {
                m.classList.remove('open');
            }
        });
    });
}
</script>
