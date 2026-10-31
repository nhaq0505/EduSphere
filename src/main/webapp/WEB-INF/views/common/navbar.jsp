<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<nav class="navbar" aria-label="Điều hướng chính">
    <div class="nav-brand"><a class="brand" href="${pageContext.request.contextPath}/">EduSphere</a></div>
    <div class="nav-links">
        <a href="${pageContext.request.contextPath}/courses">Khám phá khóa học</a>
        <sec:authorize access="hasRole('STUDENT')">
            <a href="${pageContext.request.contextPath}/my-courses">Khóa học của tôi</a>
            <a href="${pageContext.request.contextPath}/study/plans">Kế hoạch học tập</a>
        </sec:authorize>
        <sec:authorize access="hasRole('INSTRUCTOR')"><a href="${pageContext.request.contextPath}/instructor/courses">Quản lý khóa học</a></sec:authorize>
        <sec:authorize access="hasRole('ADMINISTRATOR')"><a href="${pageContext.request.contextPath}/admin/courses/review">Duyệt khóa học</a><a href="${pageContext.request.contextPath}/admin/users">Tài khoản</a></sec:authorize>
    </div>
    <div class="nav-links">
        <sec:authorize access="isAnonymous()"><a href="${pageContext.request.contextPath}/login">Đăng nhập</a><a href="${pageContext.request.contextPath}/register">Đăng ký</a></sec:authorize>
        <sec:authorize access="isAuthenticated()">
            <a href="${pageContext.request.contextPath}/profile">Hồ sơ</a>
            <form method="post" action="${pageContext.request.contextPath}/logout">
                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                <button class="btn-link" type="submit">Đăng xuất</button>
            </form>
        </sec:authorize>
    </div>
</nav>
