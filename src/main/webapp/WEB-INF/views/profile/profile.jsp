<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"   uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn"  uri="jakarta.tags.functions" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Hồ sơ cá nhân — EduSphere</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
    <%-- CSS chung cho trang profile --%>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/home.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/profile.css">
    <%-- CSS instructor (chỉ dùng khi role INSTRUCTOR để lấy sidebar/topbar) --%>
    <sec:authorize access="hasRole('INSTRUCTOR')">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/instructor.css">
    </sec:authorize>
</head>
<body>

<%-- ══════════════════════════════════════════
     LAYOUT INSTRUCTOR
══════════════════════════════════════════ --%>
<sec:authorize access="hasRole('INSTRUCTOR')">
<div class="ins-layout">
    <jsp:include page="/WEB-INF/views/courses/ins-sidebar.jsp"/>
    <div class="ins-main-wrapper">
        <jsp:include page="/WEB-INF/views/courses/ins-header.jsp"/>
        <main class="ins-page">
</sec:authorize>

<%-- ══════════════════════════════════════════
     LAYOUT STUDENT / ADMIN (navbar chung)
══════════════════════════════════════════ --%>
<sec:authorize access="!hasRole('INSTRUCTOR')">
<header class="hn-header">
    <div class="hn-header__inner">
        <a class="hn-logo" href="${pageContext.request.contextPath}/">
            <div class="hn-logo__icon">🎓</div>
            <span>EduSphere</span>
        </a>
        <nav class="hn-nav">
            <a class="hn-nav__link" href="${pageContext.request.contextPath}/">Trang chủ</a>
            <a class="hn-nav__link" href="${pageContext.request.contextPath}/courses">Khóa học</a>
            <sec:authorize access="hasRole('ADMINISTRATOR')">
                <a class="hn-nav__link" href="${pageContext.request.contextPath}/admin/users">Quản trị</a>
            </sec:authorize>
        </nav>
        <div class="hn-header__right">
            <sec:authorize access="isAuthenticated()">
                <div class="hn-user-menu">
                    <button class="hn-user-btn" onclick="toggleUserMenu(event)">
                        <div class="hn-user-btn__avatar">
                            <svg viewBox="0 0 24 24" fill="none" width="18" height="18"><circle cx="12" cy="8" r="4" stroke="currentColor" stroke-width="1.8"/><path d="M4 20c0-4 3.6-7 8-7s8 3 8 7" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/></svg>
                        </div>
                        <span class="hn-user-btn__name"><sec:authentication property="principal.fullName"/></span>
                        <svg class="hn-user-btn__arrow" viewBox="0 0 12 8" fill="none" width="10"><path d="M1 1l5 5 5-5" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"/></svg>
                    </button>
                    <div class="hn-user-dropdown" id="userDropdown">
                        <div class="hn-user-dropdown__head">
                            <div class="hn-user-dropdown__avatar-icon"><svg viewBox="0 0 24 24" fill="none" width="20" height="20"><circle cx="12" cy="8" r="4" stroke="white" stroke-width="1.8"/><path d="M4 20c0-4 3.6-7 8-7s8 3 8 7" stroke="white" stroke-width="1.8" stroke-linecap="round"/></svg></div>
                            <span><sec:authentication property="principal.fullName"/></span>
                        </div>
                        <div class="hn-user-dropdown__body">
                            <a class="hn-user-dropdown__item" href="${pageContext.request.contextPath}/profile">Hồ sơ cá nhân</a>
                            <a class="hn-user-dropdown__item" href="${pageContext.request.contextPath}/change-password">Đổi mật khẩu</a>
                            <div class="hn-user-dropdown__divider"></div>
                            <form method="post" action="${pageContext.request.contextPath}/logout" style="margin:0">
                                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                <button class="hn-user-dropdown__item hn-user-dropdown__item--danger" type="submit">Đăng xuất</button>
                            </form>
                        </div>
                    </div>
                </div>
            </sec:authorize>
        </div>
    </div>
</header>
<main class="pf-main">
    <div class="hn-container">
</sec:authorize>

<%-- ══════════════════════════════════════════
     NỘI DUNG TRANG (dùng chung cho cả 2 layout)
══════════════════════════════════════════ --%>

<%-- Breadcrumb (chỉ hiện khi không phải instructor) --%>
<sec:authorize access="!hasRole('INSTRUCTOR')">
    <div class="pf-breadcrumb">
        <a href="${pageContext.request.contextPath}/">Trang chủ</a>
        <span>›</span>
        <span>Hồ sơ cá nhân</span>
    </div>
</sec:authorize>

<%-- Back link (chỉ cho instructor) --%>
<sec:authorize access="hasRole('INSTRUCTOR')">
</sec:authorize>

<c:if test="${not empty successMessage}">
    <div class="pf-alert pf-alert--success">✅ <c:out value="${successMessage}"/></div>
</c:if>
<c:if test="${not empty errorMessage}">
    <div class="pf-alert pf-alert--error">❌ <c:out value="${errorMessage}"/></div>
</c:if>

<div class="pf-layout">

    <%-- Avatar card --%>
    <div class="pf-sidebar">
        <div class="pf-avatar-card">
            <div class="pf-avatar-wrap">
                <c:choose>
                    <c:when test="${not empty user.avatarUrl}">
                        <img src="<c:out value='${user.avatarUrl}'/>" alt="Avatar" class="pf-avatar-img">
                    </c:when>
                    <c:otherwise>
                        <div class="pf-avatar-placeholder">
                            <c:out value="${fn:substring(user.fullName, 0, 1)}"/>
                        </div>
                    </c:otherwise>
                </c:choose>
                <form method="post"
                      action="${pageContext.request.contextPath}/profile/avatar"
                      enctype="multipart/form-data"
                      class="pf-avatar-upload">
                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                    <label class="pf-avatar-upload__btn" title="Đổi ảnh đại diện">
                        <svg viewBox="0 0 24 24" fill="none" width="16" height="16">
                            <path d="M21 15v4a2 2 0 01-2 2H5a2 2 0 01-2-2v-4M17 8l-5-5-5 5M12 3v12"
                                  stroke="white" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                        </svg>
                        <input type="file" name="avatarFile" accept="image/*"
                               style="display:none;" onchange="this.form.submit()">
                    </label>
                </form>
            </div>

            <h2 class="pf-avatar-card__name"><c:out value="${user.fullName}"/></h2>
            <div class="pf-avatar-card__roles">
                <c:forEach var="roleName" items="${roleNames}">
                    <span class="pf-role-badge"><c:out value="${roleName}"/></span>
                </c:forEach>
            </div>
            <span class="pf-status-badge pf-status-badge--${user.status.toLowerCase()}">
                <span class="pf-status-badge__dot"></span>
                <c:out value="${user.status}"/>
            </span>
            <div class="pf-sidebar-actions">
                <a class="pf-btn-outline pf-btn-block"
                   href="${pageContext.request.contextPath}/change-password">
                    🔒 Đổi mật khẩu
                </a>
            </div>
        </div>
    </div>

    <%-- Info card --%>
    <div class="pf-content">
        <div class="pf-info-card">
            <div class="pf-info-card__header">
                <h3>Thông tin cá nhân</h3>
            </div>
            <div class="pf-info-card__body">

                <div class="pf-info-row">
                    <div class="pf-info-row__icon">
                        <svg viewBox="0 0 24 24" fill="none" width="18" height="18"><circle cx="12" cy="8" r="4" stroke="currentColor" stroke-width="1.7"/><path d="M4 20c0-4 3.6-7 8-7s8 3 8 7" stroke="currentColor" stroke-width="1.7" stroke-linecap="round"/></svg>
                    </div>
                    <div class="pf-info-row__content">
                        <span class="pf-info-row__label">Họ và tên</span>
                        <div class="pf-editable" id="edit-fullName">
                            <span class="pf-editable__text"><c:out value="${user.fullName}"/></span>
                            <button class="pf-editable__pencil" onclick="startEdit('fullName')" title="Chỉnh sửa">
                                <svg viewBox="0 0 24 24" fill="none" width="14" height="14"><path d="M11 4H4a2 2 0 00-2 2v14a2 2 0 002 2h14a2 2 0 002-2v-7" stroke="currentColor" stroke-width="2" stroke-linecap="round"/><path d="M18.5 2.5a2.121 2.121 0 013 3L12 15l-4 1 1-4 9.5-9.5z" stroke="currentColor" stroke-width="2" stroke-linecap="round"/></svg>
                            </button>
                            <div class="pf-editable__form" style="display:none">
                                <input class="pf-editable__input" type="text" id="input-fullName"
                                       value="<c:out value='${user.fullName}'/>" maxlength="100">
                                <button class="pf-editable__save" onclick="saveEdit('fullName')">Lưu</button>
                                <button class="pf-editable__cancel" onclick="cancelEdit('fullName')">Huỷ</button>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="pf-info-row">
                    <div class="pf-info-row__icon">
                        <svg viewBox="0 0 24 24" fill="none" width="18" height="18"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z" stroke="currentColor" stroke-width="1.7"/><path d="M22 6l-10 7L2 6" stroke="currentColor" stroke-width="1.7" stroke-linecap="round"/></svg>
                    </div>
                    <div class="pf-info-row__content">
                        <span class="pf-info-row__label">Email</span>
                        <span class="pf-info-row__value"><c:out value="${user.email}"/></span>
                    </div>
                </div>

                <div class="pf-info-row">
                    <div class="pf-info-row__icon">
                        <svg viewBox="0 0 24 24" fill="none" width="18" height="18"><path d="M22 16.92v3a2 2 0 01-2.18 2 19.79 19.79 0 01-8.63-3.07 19.5 19.5 0 01-6-6A19.79 19.79 0 012.12 4.18 2 2 0 014.11 2h3a2 2 0 012 1.72c.127.96.361 1.903.7 2.81a2 2 0 01-.45 2.11L8.09 9.91a16 16 0 006 6l1.27-1.27a2 2 0 012.11-.45c.907.339 1.85.573 2.81.7A2 2 0 0122 16.92z" stroke="currentColor" stroke-width="1.7" stroke-linecap="round"/></svg>
                    </div>
                    <div class="pf-info-row__content">
                        <span class="pf-info-row__label">Số điện thoại</span>
                        <div class="pf-editable" id="edit-phone">
                            <span class="pf-editable__text">
                                <c:choose>
                                    <c:when test="${not empty user.phone}"><c:out value="${user.phone}"/></c:when>
                                    <c:otherwise><em class="pf-info-row__empty">Chưa cập nhật</em></c:otherwise>
                                </c:choose>
                            </span>
                            <button class="pf-editable__pencil" onclick="startEdit('phone')" title="Chỉnh sửa">
                                <svg viewBox="0 0 24 24" fill="none" width="14" height="14"><path d="M11 4H4a2 2 0 00-2 2v14a2 2 0 002 2h14a2 2 0 002-2v-7" stroke="currentColor" stroke-width="2" stroke-linecap="round"/><path d="M18.5 2.5a2.121 2.121 0 013 3L12 15l-4 1 1-4 9.5-9.5z" stroke="currentColor" stroke-width="2" stroke-linecap="round"/></svg>
                            </button>
                            <div class="pf-editable__form" style="display:none">
                                <input class="pf-editable__input" type="text" id="input-phone"
                                       value="<c:out value='${user.phone}'/>" maxlength="20"
                                       placeholder="Nhập số điện thoại...">
                                <button class="pf-editable__save" onclick="saveEdit('phone')">Lưu</button>
                                <button class="pf-editable__cancel" onclick="cancelEdit('phone')">Huỷ</button>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="pf-info-row">
                    <div class="pf-info-row__icon">
                        <svg viewBox="0 0 24 24" fill="none" width="18" height="18"><rect x="3" y="4" width="18" height="18" rx="2" stroke="currentColor" stroke-width="1.7"/><path d="M16 2v4M8 2v4M3 10h18" stroke="currentColor" stroke-width="1.7" stroke-linecap="round"/></svg>
                    </div>
                    <div class="pf-info-row__content">
                        <span class="pf-info-row__label">Ngày tạo tài khoản</span>
                        <span class="pf-info-row__value">
                            <fmt:formatDate value="${user.createdAt}" pattern="dd/MM/yyyy HH:mm"/>
                        </span>
                    </div>
                </div>

                <div class="pf-info-row pf-info-row--last">
                    <div class="pf-info-row__icon">
                        <svg viewBox="0 0 24 24" fill="none" width="18" height="18"><path d="M12 2l2.4 7.4H22l-6.2 4.5 2.4 7.4L12 17l-6.2 4.3 2.4-7.4L2 9.4h7.6L12 2z" stroke="currentColor" stroke-width="1.7" stroke-linejoin="round"/></svg>
                    </div>
                    <div class="pf-info-row__content">
                        <span class="pf-info-row__label">Vai trò</span>
                        <span class="pf-info-row__value">
                            <c:forEach var="roleName" items="${roleNames}">
                                <span class="pf-role-badge"><c:out value="${roleName}"/></span>
                            </c:forEach>
                        </span>
                    </div>
                </div>

            </div>
        </div>
    </div>

</div><%-- /pf-layout --%>

<%-- ══════ Đóng layout theo role ══════ --%>
<sec:authorize access="hasRole('INSTRUCTOR')">
        </main>
    </div>
</div>
</sec:authorize>

<sec:authorize access="!hasRole('INSTRUCTOR')">
    </div><%-- /hn-container --%>
</main>

<footer class="hn-footer">
    <div class="hn-footer__inner">
        <div class="hn-footer__brand">
            <a class="hn-logo" href="${pageContext.request.contextPath}/">
                <div class="hn-logo__icon">🎓</div>
                <span>EduSphere</span>
            </a>
            <p>Nền tảng học tập trực tuyến chất lượng cao dành cho mọi người.</p>
        </div>
        <div class="hn-footer__col">
            <h4>Tài khoản</h4>
            <a href="${pageContext.request.contextPath}/profile">Hồ sơ</a>
            <a href="${pageContext.request.contextPath}/change-password">Đổi mật khẩu</a>
        </div>
    </div>
    <div class="hn-footer__bottom">
        <p>© 2026 EduSphere. Bản quyền thuộc về EduSphere.</p>
    </div>
</footer>
</sec:authorize>

<script>
const csrfParam = '<c:out value="${_csrf.parameterName}"/>';
const csrfToken = '<c:out value="${_csrf.token}"/>';
const ctxPath   = '${pageContext.request.contextPath}';

/* ── Inline edit ── */
function startEdit(field) {
    const wrap = document.getElementById('edit-' + field);
    wrap.querySelector('.pf-editable__text').style.display   = 'none';
    wrap.querySelector('.pf-editable__pencil').style.display = 'none';
    wrap.querySelector('.pf-editable__form').style.display   = 'flex';
    document.getElementById('input-' + field).focus();
}
function cancelEdit(field) {
    const wrap = document.getElementById('edit-' + field);
    wrap.querySelector('.pf-editable__text').style.display   = '';
    wrap.querySelector('.pf-editable__pencil').style.display = '';
    wrap.querySelector('.pf-editable__form').style.display   = 'none';
}
function saveEdit(field) {
    const input = document.getElementById('input-' + field);
    const value = input.value.trim();
    if (field === 'fullName' && !value) {
        input.classList.add('pf-editable__input--error');
        input.placeholder = 'Họ tên không được trống!';
        return;
    }
    input.classList.remove('pf-editable__input--error');
    const fd = new FormData();
    fd.append(csrfParam, csrfToken);
    fd.append('fullName', field === 'fullName' ? value
        : document.querySelector('#edit-fullName .pf-editable__text').textContent.trim());
    fd.append('phone', field === 'phone' ? value
        : document.querySelector('#edit-phone .pf-editable__text').textContent.trim().replace('Chưa cập nhật',''));
    fetch(ctxPath + '/profile/edit', { method: 'POST', body: fd })
        .then(res => {
            if (res.ok || res.redirected) {
                const textEl = document.querySelector('#edit-' + field + ' .pf-editable__text');
                textEl.innerHTML = value
                    ? escapeHtml(value)
                    : '<em class="pf-info-row__empty">Chưa cập nhật</em>';
                if (field === 'fullName') {
                    document.querySelectorAll('.hn-user-btn__name, .ins-user-btn__name, .pf-avatar-card__name')
                        .forEach(el => el.textContent = value);
                }
                cancelEdit(field);
                showToast('Đã cập nhật thành công!', 'success');
            } else { showToast('Cập nhật thất bại.', 'error'); }
        })
        .catch(() => showToast('Lỗi kết nối.', 'error'));
}
function escapeHtml(s) {
    return s.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');
}
function showToast(msg, type) {
    const t = document.createElement('div');
    t.className = 'pf-toast pf-toast--' + type;
    t.textContent = (type === 'success' ? '✅ ' : '❌ ') + msg;
    document.body.appendChild(t);
    setTimeout(() => t.classList.add('pf-toast--show'), 10);
    setTimeout(() => { t.classList.remove('pf-toast--show'); setTimeout(() => t.remove(), 300); }, 2500);
}

/* ── Menu toggles ── */
function toggleUserMenu(e) {
    e.stopPropagation();
    e.currentTarget.closest('.hn-user-menu').classList.toggle('open');
}
function insToggleMenu(e) {
    e.stopPropagation();
    document.getElementById('insUserMenu').classList.toggle('open');
}
document.addEventListener('click', function() {
    document.querySelectorAll('.hn-user-menu.open').forEach(m => m.classList.remove('open'));
    const im = document.getElementById('insUserMenu');
    if (im) im.classList.remove('open');
});
</script>
</body>
</html>
