<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<header class="hn-header">
    <div class="hn-header__inner">
        <a class="hn-logo" href="${pageContext.request.contextPath}/instructor/courses" style="color:#15803D">
            <div class="hn-logo__icon" style="background:#D1FAE5">🧑‍🏫</div>
            <span>EduSphere Instructor</span>
        </a>
        <div style="flex:1"></div>
        <div class="hn-header__right">
            <sec:authorize access="isAuthenticated()">
                <div class="hn-user-menu">
                    <button class="hn-user-btn" onclick="toggleUserMenu(event)">
                        <div class="hn-user-btn__avatar" style="background:#D1FAE5;color:#15803D">
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
                            <div class="hn-user-dropdown__avatar-icon"><svg viewBox="0 0 24 24" fill="none" width="20" height="20"><circle cx="12" cy="8" r="4" stroke="white" stroke-width="1.8"/><path d="M4 20c0-4 3.6-7 8-7s8 3 8 7" stroke="white" stroke-width="1.8" stroke-linecap="round"/></svg></div>
                            <span><sec:authentication property="principal.fullName"/></span>
                        </div>
                        <div class="hn-user-dropdown__body">
                            <a class="hn-user-dropdown__item" href="${pageContext.request.contextPath}/instructor/courses">
                                <svg viewBox="0 0 24 24" fill="none" width="16" height="16"><rect x="3" y="3" width="18" height="18" rx="3" stroke="currentColor" stroke-width="1.7"/><path d="M8 12l3 3 5-5" stroke="currentColor" stroke-width="1.7" stroke-linecap="round"/></svg>
                                Khóa học của tôi
                            </a>
                            <a class="hn-user-dropdown__item" href="${pageContext.request.contextPath}/profile">
                                <svg viewBox="0 0 24 24" fill="none" width="16" height="16"><circle cx="12" cy="8" r="4" stroke="currentColor" stroke-width="1.7"/><path d="M4 20c0-4 3.6-7 8-7s8 3 8 7" stroke="currentColor" stroke-width="1.7" stroke-linecap="round"/></svg>
                                Hồ sơ cá nhân
                            </a>
                            <div class="hn-user-dropdown__divider"></div>
                            <form method="post" action="${pageContext.request.contextPath}/logout" style="margin:0">
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
