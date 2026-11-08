<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<aside class="adm-sidebar">

    <!-- Brand -->
    <div class="adm-sidebar__brand">
        <div class="adm-sidebar__brand-icon">🛡️</div>
        <div>
            <div class="adm-sidebar__brand-text">EduSphere</div>
            <div class="adm-sidebar__brand-sub">Quản trị viên</div>
        </div>
    </div>

    <!-- Nav label -->
    <div class="adm-sidebar__label">Quản lý</div>

    <!-- Nav items -->
    <a class="adm-nav-item ${pageContext.request.servletPath.contains('users.jsp') ? 'adm-nav-item--active' : ''}"
       href="${pageContext.request.contextPath}/admin/users">
        <span class="adm-nav-item__icon">👥</span>
        Tài khoản
    </a>

    <a class="adm-nav-item ${pageContext.request.servletPath.contains('course-review') ? 'adm-nav-item--active' : ''}"
       href="${pageContext.request.contextPath}/admin/courses/review">
        <span class="adm-nav-item__icon">✅</span>
        Duyệt khóa học
    </a>

    <a class="adm-nav-item ${pageContext.request.servletPath.contains('revenue.jsp') ? 'adm-nav-item--active' : ''}"
       href="${pageContext.request.contextPath}/admin/revenue">
        <span class="adm-nav-item__icon">💰</span>
        Doanh thu &amp; Rút tiền
    </a>

    <!-- Logout ở cuối -->
    <div class="adm-sidebar__bottom">
        <form method="post" action="${pageContext.request.contextPath}/logout" style="margin:0">
            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
            <button class="adm-logout-btn" type="submit">
                <svg viewBox="0 0 24 24" fill="none" width="16" height="16">
                    <path d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"
                          stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
                </svg>
                Đăng xuất
            </button>
        </form>
    </div>
</aside>
