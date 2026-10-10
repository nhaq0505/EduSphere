<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<header class="site-header"><div class="site-header__inner">
    <a class="wordmark" href="${pageContext.request.contextPath}/" aria-label="EduSphere"><span class="wordmark__symbol">E</span>Edu<span>Sphere</span></a>
    <nav class="primary-nav" aria-label="Điều hướng chính">
        <a href="${pageContext.request.contextPath}/courses">Khám phá khóa học</a>
        <sec:authorize access="hasRole('STUDENT')"><a href="${pageContext.request.contextPath}/my-courses">Khóa học của tôi</a></sec:authorize>
        <sec:authorize access="hasRole('INSTRUCTOR')"><a href="${pageContext.request.contextPath}/instructor/courses">Quản lý khóa học</a></sec:authorize>
        <sec:authorize access="hasRole('ADMINISTRATOR')"><a href="${pageContext.request.contextPath}/admin/courses/review">Duyệt khóa học</a></sec:authorize>
        <sec:authorize access="hasRole('ADMINISTRATOR')"><a href="${pageContext.request.contextPath}/admin/users">Tài khoản</a></sec:authorize>
    </nav>
    <div class="header-actions">
        <sec:authorize access="isAnonymous()"><a href="${pageContext.request.contextPath}/login">Đăng nhập</a><a class="button button--small button--primary" href="${pageContext.request.contextPath}/register">Tạo tài khoản</a></sec:authorize>
        <sec:authorize access="isAuthenticated()">
            <a href="${pageContext.request.contextPath}/profile">Hồ sơ</a>
            <form method="post" action="${pageContext.request.contextPath}/logout"><input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"><button class="button button--small button--outline" type="submit">Đăng xuất</button></form>
        </sec:authorize>
    </div>
</div></header>
