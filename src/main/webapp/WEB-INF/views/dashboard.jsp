<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard — EduSphere</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/home.css">
</head>
<body>

<!-- ══════ NAVBAR ══════ -->
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
                <a class="hn-nav__link" href="${pageContext.request.contextPath}/my-courses">Khóa học của tôi</a>
            </sec:authorize>
            <sec:authorize access="hasRole('INSTRUCTOR')">
                <a class="hn-nav__link" href="${pageContext.request.contextPath}/instructor/courses">Giảng viên</a>
            </sec:authorize>
            <sec:authorize access="hasRole('ADMINISTRATOR')">
                <a class="hn-nav__link" href="${pageContext.request.contextPath}/admin/users">Quản trị</a>
            </sec:authorize>
        </nav>
        <div class="hn-header__right">
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
                            <a class="hn-user-dropdown__item" href="${pageContext.request.contextPath}/profile">
                                <svg viewBox="0 0 24 24" fill="none" width="16" height="16"><circle cx="12" cy="8" r="4" stroke="currentColor" stroke-width="1.7"/><path d="M4 20c0-4 3.6-7 8-7s8 3 8 7" stroke="currentColor" stroke-width="1.7" stroke-linecap="round"/></svg>
                                Thông tin cá nhân
                            </a>
                            <div class="hn-user-dropdown__divider"></div>
                            <form method="post" action="${pageContext.request.contextPath}/logout" style="margin:0">
                                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                <button class="hn-user-dropdown__item hn-user-dropdown__item--danger" type="submit">
                                    <svg viewBox="0 0 24 24" fill="none" width="16" height="16"><path d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"/></svg>
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

<!-- ══════ DASHBOARD ══════ -->
<main style="background:var(--bg);min-height:calc(100vh - 66px);padding:40px 0 60px">
    <div class="hn-container">

        <!-- Welcome banner -->
        <div style="background:linear-gradient(135deg,#0369a1 0%,#0ea5e9 60%,#38bdf8 100%);border-radius:20px;padding:36px 40px;margin-bottom:32px;display:flex;align-items:center;justify-content:space-between;gap:24px;position:relative;overflow:hidden">
            <div style="position:absolute;width:300px;height:300px;border-radius:50%;background:rgba(255,255,255,.06);top:-100px;right:-60px;pointer-events:none"></div>
            <div>
                <p style="color:rgba(255,255,255,.8);font-size:.85rem;font-weight:500;margin-bottom:8px">👋 Chào mừng trở lại!</p>
                <h1 style="color:#fff;font-size:1.8rem;font-weight:900;margin:0 0 8px;letter-spacing:-.02em">
                    <sec:authentication property="principal.fullName"/>
                </h1>
                <div style="display:flex;gap:8px;flex-wrap:wrap">
                    <sec:authorize access="hasRole('ADMINISTRATOR')"><span style="background:rgba(255,255,255,.2);color:#fff;font-size:.72rem;font-weight:700;padding:3px 10px;border-radius:99px;text-transform:uppercase;letter-spacing:.04em">🛡️ Admin</span></sec:authorize>
                    <sec:authorize access="hasRole('INSTRUCTOR')"><span style="background:rgba(255,255,255,.2);color:#fff;font-size:.72rem;font-weight:700;padding:3px 10px;border-radius:99px;text-transform:uppercase;letter-spacing:.04em">🧑‍🏫 Giảng viên</span></sec:authorize>
                    <sec:authorize access="hasRole('STUDENT')"><span style="background:rgba(255,255,255,.2);color:#fff;font-size:.72rem;font-weight:700;padding:3px 10px;border-radius:99px;text-transform:uppercase;letter-spacing:.04em">📚 Học viên</span></sec:authorize>
                </div>
            </div>
            <a class="hn-btn hn-btn--white" href="${pageContext.request.contextPath}/courses" style="flex-shrink:0">Khám phá khóa học →</a>
        </div>

        <!-- Quick links grid -->
        <div style="display:grid;grid-template-columns:repeat(auto-fill,minmax(200px,1fr));gap:16px">

            <!-- Luôn hiện -->
            <a href="${pageContext.request.contextPath}/courses" class="db-card">
                <div class="db-card__icon" style="background:#EFF6FF;color:#1D4ED8">📚</div>
                <div class="db-card__text">
                    <div class="db-card__title">Khám phá khóa học</div>
                    <div class="db-card__sub">Tìm khoá học mới</div>
                </div>
                <span class="db-card__arrow">→</span>
            </a>

            <a href="${pageContext.request.contextPath}/profile" class="db-card">
                <div class="db-card__icon" style="background:#F0FDF4;color:#16A34A">👤</div>
                <div class="db-card__text">
                    <div class="db-card__title">Hồ sơ cá nhân</div>
                    <div class="db-card__sub">Xem và chỉnh sửa</div>
                </div>
                <span class="db-card__arrow">→</span>
            </a>

            <a href="${pageContext.request.contextPath}/change-password" class="db-card">
                <div class="db-card__icon" style="background:#FFF7ED;color:#C2410C">🔒</div>
                <div class="db-card__text">
                    <div class="db-card__title">Đổi mật khẩu</div>
                    <div class="db-card__sub">Bảo mật tài khoản</div>
                </div>
                <span class="db-card__arrow">→</span>
            </a>

            <!-- STUDENT -->
            <sec:authorize access="hasRole('STUDENT')">
                <a href="${pageContext.request.contextPath}/my-courses" class="db-card">
                    <div class="db-card__icon" style="background:#EFF6FF;color:#0EA5E9">📖</div>
                    <div class="db-card__text">
                        <div class="db-card__title">Khóa học của tôi</div>
                        <div class="db-card__sub">Tiếp tục học</div>
                    </div>
                    <span class="db-card__arrow">→</span>
                </a>
            </sec:authorize>

            <!-- INSTRUCTOR -->
            <sec:authorize access="hasRole('INSTRUCTOR')">
                <a href="${pageContext.request.contextPath}/instructor/courses" class="db-card">
                    <div class="db-card__icon" style="background:#F0FDF4;color:#15803D">🧑‍🏫</div>
                    <div class="db-card__text">
                        <div class="db-card__title">Quản lý khóa học</div>
                        <div class="db-card__sub">Tạo & chỉnh sửa</div>
                    </div>
                    <span class="db-card__arrow">→</span>
                </a>
            </sec:authorize>

            <!-- ADMINISTRATOR -->
            <sec:authorize access="hasRole('ADMINISTRATOR')">
                <a href="${pageContext.request.contextPath}/admin/users" class="db-card">
                    <div class="db-card__icon" style="background:#FFF7ED;color:#EA580C">⚙️</div>
                    <div class="db-card__text">
                        <div class="db-card__title">Quản lý tài khoản</div>
                        <div class="db-card__sub">Gán vai trò, khoá TK</div>
                    </div>
                    <span class="db-card__arrow">→</span>
                </a>
                <a href="${pageContext.request.contextPath}/admin/courses/review" class="db-card">
                    <div class="db-card__icon" style="background:#FEF2F2;color:#DC2626">✅</div>
                    <div class="db-card__text">
                        <div class="db-card__title">Duyệt khóa học</div>
                        <div class="db-card__sub">Chờ phê duyệt</div>
                    </div>
                    <span class="db-card__arrow">→</span>
                </a>
            </sec:authorize>

        </div>

    </div>
</main>

<style>
.db-card {
    display: flex;
    align-items: center;
    gap: 14px;
    background: #fff;
    border-radius: 14px;
    border: 1.5px solid #E2E8F0;
    padding: 18px 16px;
    text-decoration: none;
    transition: all .2s ease;
    box-shadow: 0 2px 8px rgba(0,0,0,.04);
}
.db-card:hover {
    border-color: #0EA5E9;
    box-shadow: 0 6px 24px rgba(14,165,233,.14);
    transform: translateY(-3px);
    text-decoration: none;
}
.db-card__icon {
    width: 46px; height: 46px;
    border-radius: 12px;
    display: flex; align-items: center; justify-content: center;
    font-size: 1.4rem;
    flex-shrink: 0;
}
.db-card__text { flex: 1; }
.db-card__title { font-size: .9rem; font-weight: 700; color: #0F172A; margin-bottom: 2px; }
.db-card__sub   { font-size: .76rem; color: #64748B; }
.db-card__arrow { font-size: 1rem; color: #94A3B8; font-weight: 700; flex-shrink: 0; transition: transform .2s; }
.db-card:hover .db-card__arrow { color: #0EA5E9; transform: translateX(3px); }
</style>

<script>
function toggleUserMenu(e) {
    e.stopPropagation();
    const menu = e.currentTarget.closest('.hn-user-menu');
    menu.classList.toggle('open');
}
document.addEventListener('click', function() {
    document.querySelectorAll('.hn-user-menu.open').forEach(m => m.classList.remove('open'));
});
</script>
</body>
</html>
