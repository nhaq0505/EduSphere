<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<header class="hn-header">
    <div class="hn-header__inner">
        <a class="hn-logo" href="${pageContext.request.contextPath}/">
            <div class="hn-logo__icon">🎓</div>
            <span>EduSphere</span>
        </a>
        <nav class="hn-nav">
            <a class="hn-nav__link" href="${pageContext.request.contextPath}/">Trang chủ</a>
            <a class="hn-nav__link" href="${pageContext.request.contextPath}/courses">Khóa học</a>
            <sec:authorize access="hasRole('STUDENT')">
            <a class="hn-nav__link" href="#">Về chúng tôi</a>
            <a class="hn-nav__link" href="#">Liên hệ</a>
            <sec:authorize access="hasRole('STUDENT')">
                <a class="hn-nav__link hn-nav__link--active" href="${pageContext.request.contextPath}/study/plans">Kế Hoạch &amp; Tiến Độ</a>
            </sec:authorize>
            </sec:authorize>
            <sec:authorize access="hasRole('INSTRUCTOR')">
                <a class="hn-nav__link" href="${pageContext.request.contextPath}/instructor/courses">Quản lý khóa học</a>
            </sec:authorize>
        </nav>
        <div class="hn-header__right">
            <div class="hn-search">
                <svg class="hn-search__icon" width="16" height="16" viewBox="0 0 20 20" fill="none">
                    <circle cx="9" cy="9" r="6" stroke="#94a3b8" stroke-width="1.8"/>
                    <path d="M14 14l3 3" stroke="#94a3b8" stroke-width="1.8" stroke-linecap="round"/>
                </svg>
                <input class="hn-search__input" type="text" placeholder="Tìm kiếm khóa học..."
                       onkeydown="if(event.key==='Enter') window.location='${pageContext.request.contextPath}/courses?q='+encodeURIComponent(this.value)">
            </div>
            <sec:authorize access="isAuthenticated()">
                <div class="hn-user-menu">
                    <button class="hn-user-btn" onclick="togglePlanningUserMenu(event)">
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
                    <div class="hn-user-dropdown" id="planningUserDropdown">
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
                            <a class="hn-user-dropdown__item" href="${pageContext.request.contextPath}/profile">Thông tin cá nhân</a>
                            <a class="hn-user-dropdown__item" href="${pageContext.request.contextPath}/my-courses">Khóa học của tôi</a>
                            <a class="hn-user-dropdown__item" href="${pageContext.request.contextPath}/study/plans">Kế hoạch học tập</a>
                            <a class="hn-user-dropdown__item" href="${pageContext.request.contextPath}/study/progress">Tiến độ học tập</a>
                            <div class="hn-user-dropdown__divider"></div>
                            <form method="post" action="${pageContext.request.contextPath}/logout" style="margin:0">
                                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                <button class="hn-user-dropdown__item hn-user-dropdown__item--danger" type="submit">Đăng xuất</button>
                            </form>
                        </div>
                    </div>
                </div>
            </sec:authorize>
            <sec:authorize access="isAnonymous()">
                <a class="hn-btn hn-btn--outline" href="${pageContext.request.contextPath}/login">Đăng nhập</a>
                <a class="hn-btn hn-btn--primary" href="${pageContext.request.contextPath}/register">Đăng ký</a>
            </sec:authorize>
        </div>
    </div>
</header>
<script>
function togglePlanningUserMenu(e) {
    e.stopPropagation();
    document.getElementById('planningUserDropdown').classList.toggle('open');
}
document.addEventListener('click', function() {
    var d = document.getElementById('planningUserDropdown');
    if (d) d.classList.remove('open');
});
</script>