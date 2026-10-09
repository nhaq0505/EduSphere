<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<%--
    EduSphere Common Navbar Fragment (Desktop-only, Pure CSS/HTML)
    Hỗ trợ 2 trạng thái:
      1. Khách (Chưa đăng nhập): Logo, Khóa học, Đăng nhập, Đăng ký
      2. Đã đăng nhập: Thông tin user, Role badge (STUDENT / INSTRUCTOR / ADMIN),
         Role-based navigation menu, Avatar dropdown (Hồ sơ cá nhân, Đổi mật khẩu, Đăng xuất)
--%>

<sec:authorize access="isAuthenticated()" var="isLoggedIn" />
<sec:authorize access="hasAnyRole('ADMINISTRATOR', 'ADMIN')" var="isAdmin" />
<sec:authorize access="hasRole('INSTRUCTOR')" var="isInstructor" />
<sec:authorize access="hasRole('STUDENT')" var="isStudent" />

<c:set var="userAuthenticated" value="${isLoggedIn or not empty pageContext.request.userPrincipal}" />

<c:if test="${userAuthenticated}">
    <c:catch var="authEx">
        <sec:authentication property="principal.fullName" var="authFullName" />
        <sec:authentication property="principal.username" var="authUsername" />
        <sec:authentication property="principal.avatarUrl" var="authAvatarUrl" />
    </c:catch>
    <c:set var="displayName" value="${not empty authFullName ? authFullName : (not empty user.fullName ? user.fullName : (not empty authUsername ? authUsername : 'Người dùng'))}" />
    <c:set var="displayEmail" value="${not empty authUsername ? authUsername : (not empty user.email ? user.email : '')}" />
    <c:set var="avatarSrc" value="${not empty authAvatarUrl ? authAvatarUrl : user.avatarUrl}" />
    <c:set var="firstChar" value="${fn:toUpperCase(fn:substring(displayName, 0, 1))}" />
    <c:set var="avatarInitial" value="${not empty firstChar ? firstChar : 'U'}" />
</c:if>

<style>
/* ===== EduSphere Common Navbar Styles ===== */
.navbar.edusphere-navbar {
    background: #ffffff;
    padding: 0 32px;
    height: 64px;
    display: flex;
    align-items: center;
    justify-content: space-between;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
    position: sticky;
    top: 0;
    z-index: 1000;
}

.edusphere-navbar .nav-brand {
    display: flex;
    align-items: center;
    gap: 8px;
}

.edusphere-navbar .nav-brand .brand {
    font-size: 1.45rem;
    font-weight: 800;
    color: #667eea;
    text-decoration: none;
    letter-spacing: -0.3px;
    display: inline-flex;
    align-items: center;
    gap: 6px;
    transition: color 0.15s ease;
}

.edusphere-navbar .nav-brand .brand:hover {
    color: #5365c8;
}

.edusphere-navbar .nav-center-menu {
    display: flex;
    align-items: center;
    gap: 12px;
}

.edusphere-navbar .nav-link {
    color: #4b5563;
    text-decoration: none;
    font-size: 0.92rem;
    font-weight: 600;
    padding: 8px 14px;
    border-radius: 8px;
    transition: color 0.15s ease, background-color 0.15s ease;
    display: inline-flex;
    align-items: center;
}

.edusphere-navbar .nav-link:hover {
    color: #667eea;
    background-color: #f4f6fc;
}

.edusphere-navbar .nav-right-actions {
    display: flex;
    align-items: center;
    gap: 16px;
}

/* Guest navigation */
.edusphere-navbar .nav-guest-group {
    display: flex;
    align-items: center;
    gap: 14px;
}

.edusphere-navbar .nav-link-login {
    color: #4b5563;
    text-decoration: none;
    font-size: 0.92rem;
    font-weight: 600;
    padding: 8px 14px;
    border-radius: 8px;
    transition: color 0.15s ease, background-color 0.15s ease;
}

.edusphere-navbar .nav-link-login:hover {
    color: #667eea;
    background-color: #f4f6fc;
}

.edusphere-navbar .nav-btn-register {
    display: inline-block;
    padding: 8px 18px;
    background: #667eea;
    color: #ffffff;
    border-radius: 8px;
    font-size: 0.88rem;
    font-weight: 600;
    text-decoration: none;
    border: none;
    transition: background-color 0.15s ease, opacity 0.2s ease;
}

.edusphere-navbar .nav-btn-register:hover {
    background: #5365c8;
    color: #ffffff;
    opacity: 0.95;
}

/* User Dropdown */
.edusphere-navbar .nav-user-dropdown {
    position: relative;
    display: inline-block;
}

.edusphere-navbar .nav-user-trigger {
    display: flex;
    align-items: center;
    gap: 10px;
    padding: 6px 12px;
    border-radius: 24px;
    cursor: pointer;
    background: #f8fafc;
    border: 1.5px solid #e2e8f0;
    transition: background-color 0.15s ease, border-color 0.15s ease, box-shadow 0.15s ease;
    user-select: none;
    outline: none;
}

.edusphere-navbar .nav-user-trigger:hover,
.edusphere-navbar .nav-user-dropdown:focus-within .nav-user-trigger {
    background: #eef2ff;
    border-color: #c7d2fe;
    box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.12);
}

.edusphere-navbar .nav-avatar-wrap {
    width: 34px;
    height: 34px;
    flex-shrink: 0;
}

.edusphere-navbar .nav-avatar-img {
    width: 34px;
    height: 34px;
    border-radius: 50%;
    object-fit: cover;
    border: 2px solid #667eea;
    display: block;
}

.edusphere-navbar .nav-avatar-placeholder {
    width: 34px;
    height: 34px;
    border-radius: 50%;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: #ffffff;
    font-size: 0.92rem;
    font-weight: 700;
    display: flex;
    align-items: center;
    justify-content: center;
    text-transform: uppercase;
}

.edusphere-navbar .nav-user-meta {
    display: flex;
    flex-direction: column;
    align-items: flex-start;
    line-height: 1.25;
}

.edusphere-navbar .nav-user-name {
    font-size: 0.88rem;
    font-weight: 700;
    color: #1e293b;
    max-width: 140px;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
}

.edusphere-navbar .nav-user-badge-wrap {
    display: flex;
    gap: 4px;
    margin-top: 2px;
}

/* Badge classes */
.edusphere-navbar .badge {
    display: inline-block;
    padding: 2px 7px;
    border-radius: 10px;
    font-size: 0.68rem;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 0.4px;
}

.edusphere-navbar .badge-role-admin {
    background: #fef2f2;
    color: #dc2626;
    border: 1px solid #fecaca;
}

.edusphere-navbar .badge-role-instructor {
    background: #eff6ff;
    color: #2563eb;
    border: 1px solid #bfdbfe;
}

.edusphere-navbar .badge-role-student {
    background: #f0fdf4;
    color: #16a34a;
    border: 1px solid #bbf7d0;
}

.edusphere-navbar .nav-caret {
    font-size: 0.75rem;
    color: #64748b;
    transition: transform 0.2s ease;
    margin-left: 2px;
}

.edusphere-navbar .nav-user-dropdown:hover .nav-caret,
.edusphere-navbar .nav-user-dropdown:focus-within .nav-caret {
    transform: rotate(180deg);
}

/* Dropdown menu container */
.edusphere-navbar .nav-dropdown-menu {
    position: absolute;
    top: calc(100% + 8px);
    right: 0;
    width: 250px;
    background: #ffffff;
    border-radius: 12px;
    box-shadow: 0 10px 25px -5px rgba(0, 0, 0, 0.12), 0 8px 10px -6px rgba(0, 0, 0, 0.08);
    border: 1px solid #e2e8f0;
    opacity: 0;
    visibility: hidden;
    transform: translateY(6px);
    transition: opacity 0.2s ease, transform 0.2s ease, visibility 0.2s ease;
    z-index: 1100;
    overflow: hidden;
}

.edusphere-navbar .nav-dropdown-menu::before {
    content: "";
    position: absolute;
    top: -10px;
    left: 0;
    right: 0;
    height: 10px;
}

.edusphere-navbar .nav-user-dropdown:hover .nav-dropdown-menu,
.edusphere-navbar .nav-user-dropdown:focus-within .nav-dropdown-menu {
    opacity: 1;
    visibility: visible;
    transform: translateY(0);
}

.edusphere-navbar .nav-dropdown-header {
    padding: 14px 16px;
    background: #f8fafc;
    border-bottom: 1px solid #edf2f7;
}

.edusphere-navbar .dropdown-user-name {
    font-size: 0.92rem;
    font-weight: 700;
    color: #1e293b;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
}

.edusphere-navbar .dropdown-user-email {
    font-size: 0.8rem;
    color: #64748b;
    margin-top: 3px;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
}

.edusphere-navbar .dropdown-user-badge {
    margin-top: 6px;
}

.edusphere-navbar .nav-dropdown-divider {
    height: 1px;
    background: #edf2f7;
    margin: 4px 0;
}

.edusphere-navbar .nav-dropdown-item {
    display: flex;
    align-items: center;
    gap: 10px;
    padding: 10px 16px;
    font-size: 0.88rem;
    color: #334155;
    text-decoration: none;
    font-weight: 500;
    transition: background-color 0.15s ease, color 0.15s ease;
    cursor: pointer;
    border: none;
    background: none;
    width: 100%;
    text-align: left;
    box-sizing: border-box;
}

.edusphere-navbar .nav-dropdown-item:hover {
    background-color: #f1f5f9;
    color: #667eea;
}

.edusphere-navbar .nav-dropdown-icon {
    font-size: 1rem;
    width: 20px;
    text-align: center;
    color: #64748b;
    display: inline-block;
}

.edusphere-navbar .nav-dropdown-item:hover .nav-dropdown-icon {
    color: #667eea;
}

.edusphere-navbar .nav-logout-btn {
    color: #dc2626;
    font-family: inherit;
    font-size: 0.88rem;
}

.edusphere-navbar .nav-logout-btn:hover {
    background-color: #fef2f2;
    color: #b91c1c;
}

.edusphere-navbar .nav-logout-btn .nav-dropdown-icon {
    color: #dc2626;
}

.edusphere-navbar .nav-logout-form {
    margin: 0;
    padding: 0;
}
</style>

<nav class="navbar edusphere-navbar" aria-label="Điều hướng chính">
    <%-- Logo Brand --%>
    <div class="nav-brand">
        <a href="${pageContext.request.contextPath}/" class="brand">EduSphere</a>
    </div>

    <%-- JSP JSTL <c:choose> theo trạng thái Đã đăng nhập vs Chưa đăng nhập --%>
    <c:choose>
        <%-- ==================== TRẠNG THÁI: ĐÃ ĐĂNG NHẬP ==================== --%>
        <c:when test="${userAuthenticated}">
            <%-- Menu điều hướng theo vai trò (Role navigation) --%>
            <div class="nav-center-menu">
                <c:choose>
                    <c:when test="${isAdmin}">
                        <a href="${pageContext.request.contextPath}/courses/admin/review" class="nav-link">Duyệt khóa học</a>
                        <a href="${pageContext.request.contextPath}/dashboard" class="nav-link">Dashboard</a>
                    </c:when>
                    <c:when test="${isInstructor}">
                        <a href="${pageContext.request.contextPath}/courses/instructor" class="nav-link">Quản lý khóa học</a>
                        <a href="${pageContext.request.contextPath}/courses/create" class="nav-link">Tạo khóa học</a>
                    </c:when>
                    <c:when test="${isStudent}">
                        <a href="${pageContext.request.contextPath}/courses/my-courses" class="nav-link">Khóa học của tôi</a>
                        <a href="${pageContext.request.contextPath}/courses" class="nav-link">Khám phá</a>
                        <a href="${pageContext.request.contextPath}/dashboard" class="nav-link">Dashboard</a>
                    </c:when>
                    <c:otherwise>
                        <a href="${pageContext.request.contextPath}/courses" class="nav-link">Khám phá</a>
                        <a href="${pageContext.request.contextPath}/dashboard" class="nav-link">Dashboard</a>
                    </c:otherwise>
                </c:choose>
            </div>

            <%-- User Info & Dropdown Action Menu --%>
            <div class="nav-right-actions">
                <div class="nav-user-dropdown">
                    <div class="nav-user-trigger" tabindex="0" role="button" aria-haspopup="true" aria-expanded="false" title="Menu tài khoản">
                        <div class="nav-avatar-wrap">
                            <c:choose>
                                <c:when test="${not empty avatarSrc}">
                                    <img src="${pageContext.request.contextPath}${avatarSrc}" alt="Avatar" class="nav-avatar-img"/>
                                </c:when>
                                <c:otherwise>
                                    <div class="nav-avatar-placeholder">${avatarInitial}</div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                        <div class="nav-user-meta">
                            <span class="nav-user-name"><c:out value="${displayName}"/></span>
                            <span class="nav-user-badge-wrap">
                                <c:choose>
                                    <c:when test="${isAdmin}">
                                        <span class="badge badge-role badge-role-admin">ADMIN</span>
                                    </c:when>
                                    <c:when test="${isInstructor}">
                                        <span class="badge badge-role badge-role-instructor">INSTRUCTOR</span>
                                    </c:when>
                                    <c:when test="${isStudent}">
                                        <span class="badge badge-role badge-role-student">STUDENT</span>
                                    </c:when>
                                </c:choose>
                            </span>
                        </div>
                        <span class="nav-caret" aria-hidden="true">▾</span>
                    </div>

                    <div class="nav-dropdown-menu" role="menu">
                        <div class="nav-dropdown-header">
                            <div class="dropdown-user-name"><c:out value="${displayName}"/></div>
                            <c:if test="${not empty displayEmail}">
                                <div class="dropdown-user-email"><c:out value="${displayEmail}"/></div>
                            </c:if>
                            <div class="dropdown-user-badge">
                                <c:choose>
                                    <c:when test="${isAdmin}">
                                        <span class="badge badge-role badge-role-admin">ADMIN</span>
                                    </c:when>
                                    <c:when test="${isInstructor}">
                                        <span class="badge badge-role badge-role-instructor">INSTRUCTOR</span>
                                    </c:when>
                                    <c:when test="${isStudent}">
                                        <span class="badge badge-role badge-role-student">STUDENT</span>
                                    </c:when>
                                </c:choose>
                            </div>
                        </div>
                        <div class="nav-dropdown-divider"></div>
                        <a href="${pageContext.request.contextPath}/profile" class="nav-dropdown-item" role="menuitem">
                            <span class="nav-dropdown-icon">👤</span>
                            <span>Hồ sơ cá nhân</span>
                        </a>
                        <a href="${pageContext.request.contextPath}/change-password" class="nav-dropdown-item" role="menuitem">
                            <span class="nav-dropdown-icon">🔒</span>
                            <span>Đổi mật khẩu</span>
                        </a>
                        <div class="nav-dropdown-divider"></div>
                        <form method="post" action="${pageContext.request.contextPath}/logout" class="nav-logout-form">
                            <c:if test="${not empty _csrf}">
                                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                            </c:if>
                            <button type="submit" class="nav-dropdown-item nav-logout-btn" role="menuitem">
                                <span class="nav-dropdown-icon">🚪</span>
                                <span>Đăng xuất</span>
                            </button>
                        </form>
                    </div>
                </div>
            </div>
        </c:when>

        <%-- ==================== TRẠNG THÁI: KHÁCH (CHƯA ĐĂNG NHẬP) ==================== --%>
        <c:otherwise>
            <div class="nav-right-actions">
                <div class="nav-guest-group">
                    <a href="${pageContext.request.contextPath}/courses" class="nav-link">Khóa học</a>
                    <a href="${pageContext.request.contextPath}/login" class="nav-link-login">Đăng nhập</a>
                    <a href="${pageContext.request.contextPath}/register" class="nav-btn-register">Đăng ký</a>
                </div>
            </div>
        </c:otherwise>
    </c:choose>
</nav>
