<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<aside class="ins-sidebar">
    <div class="ins-sidebar__brand">
        <div class="ins-sidebar__brand-icon">🧑‍🏫</div>
        <div>
            <div class="ins-sidebar__brand-text">EduSphere</div>
            <div class="ins-sidebar__brand-sub">Giảng viên</div>
        </div>
    </div>

    <div class="ins-sidebar__label">Quản lý</div>

    <a class="ins-nav-item ${pageContext.request.servletPath.contains('/instructor/courses') && !pageContext.request.servletPath.contains('/new') ? 'ins-nav-item--active' : ''}"
       href="${pageContext.request.contextPath}/instructor/courses">
        <span class="ins-nav-item__icon">📚</span>
        Khóa học của tôi
    </a>

    <a class="ins-nav-item ${pageContext.request.servletPath.contains('/new') ? 'ins-nav-item--active' : ''}"
       href="${pageContext.request.contextPath}/instructor/courses/new">
        <span class="ins-nav-item__icon">➕</span>
        Tạo khóa học mới
    </a>

    <div class="ins-sidebar__label" style="margin-top:12px">Tài khoản</div>

    <a class="ins-nav-item" href="${pageContext.request.contextPath}/profile">
        <span class="ins-nav-item__icon">👤</span>
        Hồ sơ cá nhân
    </a>

    <a class="ins-nav-item" href="${pageContext.request.contextPath}/change-password">
        <span class="ins-nav-item__icon">🔒</span>
        Đổi mật khẩu
    </a>

    <div class="ins-sidebar__bottom">
        <form method="post" action="${pageContext.request.contextPath}/logout" style="margin:0">
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
