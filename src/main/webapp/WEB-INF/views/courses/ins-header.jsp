<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<c:set var="cp" value="${pageContext.request.contextPath}"/>

<header class="ins-topbar">
    <%-- Search bar --%>
    <div class="ins-topbar__search">
        <span class="ins-topbar__search-icon">
            <svg width="15" height="15" viewBox="0 0 24 24" fill="none">
                <circle cx="11" cy="11" r="7" stroke="currentColor" stroke-width="1.8"/>
                <path d="M20 20l-3.5-3.5" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/>
            </svg>
        </span>
        <form method="get" action="${cp}/instructor/courses" style="display:contents">
            <input type="text" name="q" placeholder="Tìm kiếm khóa học, học viên…" autocomplete="off"/>
        </form>
    </div>

    <%-- Right section --%>
    <div class="ins-topbar__right">
        <%-- Notification bell (placeholder, can be wired to a real notification API later) --%>
        <a href="#" class="ins-notif-btn" title="Thông báo">
            <svg width="17" height="17" viewBox="0 0 24 24" fill="none">
                <path d="M18 8A6 6 0 006 8c0 7-3 9-3 9h18s-3-2-3-9" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
                <path d="M13.73 21a2 2 0 01-3.46 0" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/>
            </svg>
        </a>

        <%-- User menu --%>
        <sec:authorize access="isAuthenticated()">
            <div class="ins-user-menu" id="insUserMenu">
                <button class="ins-user-btn" type="button" onclick="insToggleMenu(event)">
                    <div class="ins-user-btn__avatar">
                        <svg viewBox="0 0 24 24" fill="none" width="16" height="16">
                            <circle cx="12" cy="8" r="4" stroke="white" stroke-width="1.8"/>
                            <path d="M4 20c0-4 3.6-7 8-7s8 3 8 7" stroke="white" stroke-width="1.8" stroke-linecap="round"/>
                        </svg>
                    </div>
                    <div class="ins-user-btn__info">
                        <span class="ins-user-btn__name"><sec:authentication property="principal.fullName"/></span>
                        <span class="ins-user-btn__role">Giáo viên</span>
                    </div>
                    <svg class="ins-user-btn__caret" viewBox="0 0 12 8" fill="none" width="10" height="10">
                        <path d="M1 1l5 5 5-5" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"/>
                    </svg>
                </button>

                <div class="ins-user-dropdown">
                    <div class="ins-user-dropdown__head">
                        <div class="ins-user-dropdown__head-avatar">
                            <svg viewBox="0 0 24 24" fill="none" width="18" height="18">
                                <circle cx="12" cy="8" r="4" stroke="white" stroke-width="1.8"/>
                                <path d="M4 20c0-4 3.6-7 8-7s8 3 8 7" stroke="white" stroke-width="1.8" stroke-linecap="round"/>
                            </svg>
                        </div>
                        <div>
                            <span class="ins-user-dropdown__head-name"><sec:authentication property="principal.fullName"/></span>
                            <span class="ins-user-dropdown__head-role">Giáo viên</span>
                        </div>
                    </div>
                    <div class="ins-user-dropdown__body">
                        <a class="ins-user-dropdown__item" href="${cp}/instructor/dashboard">
                            <svg viewBox="0 0 24 24" fill="none" width="15" height="15"><rect x="3" y="3" width="7" height="7" rx="2" stroke="currentColor" stroke-width="1.7"/><rect x="14" y="3" width="7" height="7" rx="2" stroke="currentColor" stroke-width="1.7"/><rect x="3" y="14" width="7" height="7" rx="2" stroke="currentColor" stroke-width="1.7"/><rect x="14" y="14" width="7" height="7" rx="2" stroke="currentColor" stroke-width="1.7"/></svg>
                            Trang chủ
                        </a>
                        <a class="ins-user-dropdown__item" href="${cp}/instructor/courses">
                            <svg viewBox="0 0 24 24" fill="none" width="15" height="15"><path d="M4 19.5A2.5 2.5 0 016.5 17H20" stroke="currentColor" stroke-width="1.7" stroke-linecap="round"/><path d="M6.5 2H20v20H6.5A2.5 2.5 0 014 19.5v-15A2.5 2.5 0 016.5 2z" stroke="currentColor" stroke-width="1.7"/></svg>
                            Khóa học của tôi
                        </a>
                        <a class="ins-user-dropdown__item" href="${cp}/profile">
                            <svg viewBox="0 0 24 24" fill="none" width="15" height="15"><circle cx="12" cy="8" r="4" stroke="currentColor" stroke-width="1.7"/><path d="M4 20c0-4 3.6-7 8-7s8 3 8 7" stroke="currentColor" stroke-width="1.7" stroke-linecap="round"/></svg>
                            Hồ sơ cá nhân
                        </a>
                        <div class="ins-user-dropdown__divider"></div>
                        <form method="post" action="${cp}/logout" style="margin:0">
                            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                            <button class="ins-user-dropdown__item ins-user-dropdown__item--danger" type="submit">
                                <svg viewBox="0 0 24 24" fill="none" width="15" height="15"><path d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1" stroke="currentColor" stroke-width="1.7" stroke-linecap="round"/></svg>
                                Đăng xuất
                            </button>
                        </form>
                    </div>
                </div>
            </div>
        </sec:authorize>
    </div>
</header>
