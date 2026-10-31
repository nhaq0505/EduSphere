<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"    uri="jakarta.tags.core" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<%@ taglib prefix="sec"  uri="http://www.springframework.org/security/tags" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đổi mật khẩu — EduSphere</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/home.css">
    <sec:authorize access="hasRole('INSTRUCTOR')">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/instructor.css">
    </sec:authorize>
    <style>
        /* Styles riêng cho trang đổi mật khẩu */
        .cpw-wrap {
            max-width: 520px;
            margin: 0 auto;
        }
        .cpw-card {
            background: #fff;
            border-radius: 16px;
            border: 1px solid var(--ins-line, #E8EFF6);
            box-shadow: 0 4px 20px rgba(27,154,245,.08);
            overflow: hidden;
        }
        .cpw-card__header {
            background: linear-gradient(135deg, #1B9AF5, #0F7DD8);
            padding: 24px 28px;
            display: flex;
            align-items: center;
            gap: 14px;
        }
        .cpw-card__header-icon {
            width: 44px; height: 44px;
            border-radius: 12px;
            background: rgba(255,255,255,.2);
            display: flex; align-items: center; justify-content: center;
            flex-shrink: 0;
        }
        .cpw-card__header h1 {
            font-size: 1.15rem;
            font-weight: 800;
            color: white;
            margin: 0 0 3px;
        }
        .cpw-card__header p {
            font-size: .82rem;
            color: rgba(255,255,255,.8);
            margin: 0;
        }
        .cpw-card__body {
            padding: 28px;
        }
        .cpw-field {
            margin-bottom: 20px;
        }
        .cpw-field label {
            display: block;
            font-size: .84rem;
            font-weight: 700;
            color: #2D3A4A;
            margin-bottom: 7px;
        }
        .cpw-field__input-wrap {
            position: relative;
        }
        .cpw-field input[type=password],
        .cpw-field input[type=text] {
            width: 100%;
            padding: 10px 42px 10px 14px;
            border: 1.5px solid #E8EFF6;
            border-radius: 8px;
            font-size: .9rem;
            color: #0D1B2E;
            background: white;
            font-family: inherit;
            outline: none;
            transition: border .18s, box-shadow .18s;
        }
        .cpw-field input:focus {
            border-color: #1B9AF5;
            box-shadow: 0 0 0 3px rgba(27,154,245,.12);
        }
        .cpw-field__toggle {
            position: absolute;
            right: 12px; top: 50%;
            transform: translateY(-50%);
            background: none; border: none;
            cursor: pointer; color: #7A8C9E;
            padding: 0; display: flex; align-items: center;
            transition: color .18s;
        }
        .cpw-field__toggle:hover { color: #1B9AF5; }
        .cpw-field__error {
            display: block;
            color: #DC2626;
            font-size: .79rem;
            margin-top: 5px;
        }
        .cpw-hint {
            font-size: .78rem;
            color: #7A8C9E;
            margin-top: 5px;
            display: block;
        }
        .cpw-strength {
            display: flex;
            align-items: center;
            gap: 8px;
            margin-top: 7px;
        }
        .cpw-strength__bars {
            display: flex; gap: 4px;
        }
        .cpw-strength__bar {
            width: 36px; height: 4px;
            border-radius: 99px;
            background: #E8EFF6;
            transition: background .3s;
        }
        .cpw-strength__label {
            font-size: .75rem;
            font-weight: 600;
            color: #7A8C9E;
        }
        .cpw-divider {
            height: 1px;
            background: #E8EFF6;
            margin: 24px 0;
        }
        .cpw-actions {
            display: flex;
            gap: 10px;
        }
        .cpw-btn-submit {
            flex: 1;
            padding: 11px 20px;
            border-radius: 999px;
            background: #1B9AF5;
            color: white;
            border: none;
            font-size: .9rem;
            font-weight: 700;
            cursor: pointer;
            font-family: inherit;
            transition: all .18s;
            display: flex; align-items: center; justify-content: center; gap: 7px;
        }
        .cpw-btn-submit:hover {
            background: #0F7DD8;
            transform: translateY(-1px);
            box-shadow: 0 4px 14px rgba(27,154,245,.35);
        }
        .cpw-btn-cancel {
            padding: 11px 22px;
            border-radius: 999px;
            background: white;
            color: #2D3A4A;
            border: 1.5px solid #E8EFF6;
            font-size: .9rem;
            font-weight: 600;
            cursor: pointer;
            font-family: inherit;
            transition: all .18s;
            text-decoration: none;
            display: inline-flex; align-items: center; justify-content: center;
        }
        .cpw-btn-cancel:hover {
            border-color: #1B9AF5;
            color: #1B9AF5;
            background: #E8F4FD;
            text-decoration: none;
        }
        .cpw-alert {
            padding: 12px 16px;
            border-radius: 8px;
            font-size: .875rem;
            font-weight: 500;
            margin-bottom: 20px;
            border-left: 4px solid;
            display: flex; align-items: center; gap: 8px;
        }
        .cpw-alert--error   { background: #FEF2F2; color: #DC2626; border-color: #EF4444; }
        .cpw-alert--success { background: #F0FDF4; color: #16A34A; border-color: #22C55E; }

        /* Khi không có ins-page, thêm padding cho body */
        .cpw-standalone-page {
            min-height: calc(100vh - 66px);
            background: #F4F7FC;
            padding: 40px 24px 80px;
        }
    </style>
</head>
<body>

<%-- ══ INSTRUCTOR layout ══ --%>
<sec:authorize access="hasRole('INSTRUCTOR')">
<div class="ins-layout">
    <jsp:include page="/WEB-INF/views/courses/ins-sidebar.jsp"/>
    <div class="ins-main-wrapper">
        <jsp:include page="/WEB-INF/views/courses/ins-header.jsp"/>
        <main class="ins-page">
</sec:authorize>

<%-- ══ Student / Admin layout ══ --%>
<sec:authorize access="!hasRole('INSTRUCTOR')">
<header class="hn-header">
    <div class="hn-header__inner">
        <a class="hn-logo" href="${pageContext.request.contextPath}/">
            <div class="hn-logo__icon">🎓</div>
            <span>EduSphere</span>
        </a>
        <div class="hn-header__right">
            <sec:authorize access="isAuthenticated()">
                <div class="hn-user-menu">
                    <button class="hn-user-btn" onclick="toggleUserMenu(event)">
                        <div class="hn-user-btn__avatar"><svg viewBox="0 0 24 24" fill="none" width="18" height="18"><circle cx="12" cy="8" r="4" stroke="currentColor" stroke-width="1.8"/><path d="M4 20c0-4 3.6-7 8-7s8 3 8 7" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/></svg></div>
                        <span class="hn-user-btn__name"><sec:authentication property="principal.fullName"/></span>
                        <svg class="hn-user-btn__arrow" viewBox="0 0 12 8" fill="none" width="10"><path d="M1 1l5 5 5-5" stroke="currentColor" stroke-width="1.6" stroke-linecap="round"/></svg>
                    </button>
                    <div class="hn-user-dropdown" id="userDropdown">
                        <div class="hn-user-dropdown__head">
                            <div class="hn-user-dropdown__avatar-icon"><svg viewBox="0 0 24 24" fill="none" width="20" height="20"><circle cx="12" cy="8" r="4" stroke="white" stroke-width="1.8"/><path d="M4 20c0-4 3.6-7 8-7s8 3 8 7" stroke="white" stroke-width="1.8" stroke-linecap="round"/></svg></div>
                            <span><sec:authentication property="principal.fullName"/></span>
                        </div>
                        <div class="hn-user-dropdown__body">
                            <a class="hn-user-dropdown__item" href="${pageContext.request.contextPath}/profile">Hồ sơ cá nhân</a>
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
<div class="cpw-standalone-page">
</sec:authorize>

<%-- ══ NỘI DUNG FORM (chung) ══ --%>
<div class="cpw-wrap">

    <c:if test="${not empty errorMessage}">
        <div class="cpw-alert cpw-alert--error">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none"><circle cx="12" cy="12" r="9" stroke="currentColor" stroke-width="1.8"/><path d="M12 8v4M12 16h.01" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/></svg>
            <c:out value="${errorMessage}"/>
        </div>
    </c:if>
    <c:if test="${not empty successMessage}">
        <div class="cpw-alert cpw-alert--success">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none"><circle cx="12" cy="12" r="9" stroke="currentColor" stroke-width="1.8"/><path d="M8 12l3 3 5-5" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/></svg>
            <c:out value="${successMessage}"/>
        </div>
    </c:if>

    <div class="cpw-card">
        <div class="cpw-card__header">
            <div class="cpw-card__header-icon">
                <svg viewBox="0 0 24 24" fill="none" width="22" height="22">
                    <rect x="3" y="11" width="18" height="11" rx="2" stroke="white" stroke-width="1.8"/>
                    <path d="M7 11V7a5 5 0 0110 0v4" stroke="white" stroke-width="1.8" stroke-linecap="round"/>
                    <circle cx="12" cy="16" r="1.5" fill="white"/>
                </svg>
            </div>
            <div>
                <h1>Đổi mật khẩu</h1>
                <p>Nhập mật khẩu hiện tại và mật khẩu mới để cập nhật bảo mật tài khoản.</p>
            </div>
        </div>

        <div class="cpw-card__body">
            <form:form method="post"
                       action="${pageContext.request.contextPath}/change-password"
                       modelAttribute="changePasswordRequest">
                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">

                <%-- Mật khẩu hiện tại --%>
                <div class="cpw-field">
                    <label for="currentPassword">Mật khẩu hiện tại <span style="color:#EF4444">*</span></label>
                    <div class="cpw-field__input-wrap">
                        <form:password path="currentPassword" id="currentPassword"
                                       placeholder="Nhập mật khẩu hiện tại"/>
                        <button type="button" class="cpw-field__toggle"
                                onclick="togglePwd('currentPassword', this)" title="Hiện/ẩn">
                            <svg id="eye-currentPassword" viewBox="0 0 24 24" fill="none" width="18" height="18"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z" stroke="currentColor" stroke-width="1.7"/><circle cx="12" cy="12" r="3" stroke="currentColor" stroke-width="1.7"/></svg>
                        </button>
                    </div>
                    <form:errors path="currentPassword" cssClass="cpw-field__error"/>
                </div>

                <div class="cpw-divider"></div>

                <%-- Mật khẩu mới --%>
                <div class="cpw-field">
                    <label for="newPassword">Mật khẩu mới <span style="color:#EF4444">*</span></label>
                    <div class="cpw-field__input-wrap">
                        <form:password path="newPassword" id="newPassword"
                                       placeholder="Tối thiểu 8 ký tự" oninput="checkStrength(this.value)"/>
                        <button type="button" class="cpw-field__toggle"
                                onclick="togglePwd('newPassword', this)" title="Hiện/ẩn">
                            <svg id="eye-newPassword" viewBox="0 0 24 24" fill="none" width="18" height="18"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z" stroke="currentColor" stroke-width="1.7"/><circle cx="12" cy="12" r="3" stroke="currentColor" stroke-width="1.7"/></svg>
                        </button>
                    </div>
                    <form:errors path="newPassword" cssClass="cpw-field__error"/>
                    <%-- Strength indicator --%>
                    <div class="cpw-strength" id="strengthWrap" style="display:none">
                        <div class="cpw-strength__bars">
                            <div class="cpw-strength__bar" id="bar1"></div>
                            <div class="cpw-strength__bar" id="bar2"></div>
                            <div class="cpw-strength__bar" id="bar3"></div>
                            <div class="cpw-strength__bar" id="bar4"></div>
                        </div>
                        <span class="cpw-strength__label" id="strengthLabel"></span>
                    </div>
                    <span class="cpw-hint">Nên dùng ≥ 8 ký tự, bao gồm chữ hoa, số và ký tự đặc biệt.</span>
                </div>

                <%-- Xác nhận mật khẩu mới --%>
                <div class="cpw-field">
                    <label for="confirmPassword">Xác nhận mật khẩu mới <span style="color:#EF4444">*</span></label>
                    <div class="cpw-field__input-wrap">
                        <form:password path="confirmPassword" id="confirmPassword"
                                       placeholder="Nhập lại mật khẩu mới" oninput="checkMatch()"/>
                        <button type="button" class="cpw-field__toggle"
                                onclick="togglePwd('confirmPassword', this)" title="Hiện/ẩn">
                            <svg id="eye-confirmPassword" viewBox="0 0 24 24" fill="none" width="18" height="18"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z" stroke="currentColor" stroke-width="1.7"/><circle cx="12" cy="12" r="3" stroke="currentColor" stroke-width="1.7"/></svg>
                        </button>
                    </div>
                    <form:errors path="confirmPassword" cssClass="cpw-field__error"/>
                    <span id="matchMsg" style="display:none;font-size:.79rem;margin-top:5px;"></span>
                </div>

                <div class="cpw-actions">
                    <button class="cpw-btn-submit" type="submit">
                        <svg viewBox="0 0 24 24" fill="none" width="16" height="16"><path d="M19 21H5a2 2 0 01-2-2V5a2 2 0 012-2h11l5 5v14a2 2 0 01-2 2z" stroke="white" stroke-width="1.8" stroke-linecap="round"/><path d="M17 21v-8H7v8M7 3v5h8" stroke="white" stroke-width="1.8" stroke-linecap="round"/></svg>
                        Lưu mật khẩu mới
                    </button>
                    <a class="cpw-btn-cancel" href="${pageContext.request.contextPath}/profile">Huỷ</a>
                </div>

            </form:form>
        </div>
    </div>

</div><%-- /cpw-wrap --%>

<%-- ══ Đóng layout theo role ══ --%>
<sec:authorize access="hasRole('INSTRUCTOR')">
        </main>
    </div>
</div>
</sec:authorize>

<sec:authorize access="!hasRole('INSTRUCTOR')">
</div><%-- /cpw-standalone-page --%>
</sec:authorize>

<script>
/* Show/hide password */
function togglePwd(fieldId, btn) {
    const inp = document.getElementById(fieldId);
    const isText = inp.type === 'text';
    inp.type = isText ? 'password' : 'text';
    const eye = document.getElementById('eye-' + fieldId);
    eye.innerHTML = isText
        ? '<path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z" stroke="currentColor" stroke-width="1.7"/><circle cx="12" cy="12" r="3" stroke="currentColor" stroke-width="1.7"/>'
        : '<path d="M17.94 17.94A10.07 10.07 0 0112 20c-7 0-11-8-11-8a18.45 18.45 0 015.06-5.94M9.9 4.24A9.12 9.12 0 0112 4c7 0 11 8 11 8a18.5 18.5 0 01-2.16 3.19m-6.72-1.07a3 3 0 11-4.24-4.24" stroke="currentColor" stroke-width="1.7" stroke-linecap="round"/><path d="M1 1l22 22" stroke="currentColor" stroke-width="1.7" stroke-linecap="round"/>';
}

/* Password strength */
function checkStrength(val) {
    const wrap = document.getElementById('strengthWrap');
    const label = document.getElementById('strengthLabel');
    const bars = ['bar1','bar2','bar3','bar4'];
    const colors = { 0:'#E8EFF6', 1:'#EF4444', 2:'#F59E0B', 3:'#3B82F6', 4:'#22C55E' };
    const labels = { 0:'', 1:'Rất yếu', 2:'Yếu', 3:'Trung bình', 4:'Mạnh' };
    let score = 0;
    if (!val) { wrap.style.display='none'; return; }
    wrap.style.display = 'flex';
    if (val.length >= 8) score++;
    if (/[A-Z]/.test(val)) score++;
    if (/[0-9]/.test(val)) score++;
    if (/[^A-Za-z0-9]/.test(val)) score++;
    bars.forEach((id, i) => {
        document.getElementById(id).style.background = i < score ? colors[score] : '#E8EFF6';
    });
    label.textContent = labels[score];
    label.style.color = colors[score];
}

/* Confirm match */
function checkMatch() {
    const np = document.getElementById('newPassword').value;
    const cp = document.getElementById('confirmPassword').value;
    const msg = document.getElementById('matchMsg');
    if (!cp) { msg.style.display='none'; return; }
    msg.style.display = 'block';
    if (np === cp) {
        msg.textContent = '✅ Mật khẩu khớp';
        msg.style.color = '#16A34A';
    } else {
        msg.textContent = '❌ Mật khẩu chưa khớp';
        msg.style.color = '#DC2626';
    }
}

/* Dropdown menus */
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
