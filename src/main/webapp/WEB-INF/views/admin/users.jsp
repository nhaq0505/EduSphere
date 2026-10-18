<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý tài khoản — EduSphere Admin</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/home.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/admin.css">
</head>
<body>

<jsp:include page="/WEB-INF/views/admin/header.jsp"/>

<div class="adm-shell">
    <jsp:include page="/WEB-INF/views/admin/sidebar.jsp"/>

    <main class="adm-content">

        <!-- Page head -->
        <div class="adm-page-head">
            <div>
                <span class="adm-page-head__eyebrow">👥 Quản lý</span>
                <h1 class="adm-page-head__title">Tài khoản người dùng</h1>
                <p class="adm-page-head__sub">Gán vai trò, khoá và khôi phục tài khoản.</p>
            </div>
            <div class="adm-page-head__stats">
                <div class="adm-stat">
                    <span class="adm-stat__num">${usersPage.totalElements}</span>
                    <span class="adm-stat__label">Tổng tài khoản</span>
                </div>
            </div>
        </div>

        <!-- Alerts -->
        <c:if test="${not empty success}"><div class="adm-alert adm-alert--success">✅ <c:out value="${success}"/></div></c:if>
        <c:if test="${not empty error}"><div class="adm-alert adm-alert--error">❌ <c:out value="${error}"/></div></c:if>

        <!-- Search -->
        <form class="adm-search-bar" method="get" action="${pageContext.request.contextPath}/admin/users">
            <div class="adm-search-wrap">
                <svg width="16" height="16" viewBox="0 0 20 20" fill="none"
                     style="position:absolute;left:12px;top:50%;transform:translateY(-50%);pointer-events:none">
                    <circle cx="9" cy="9" r="6" stroke="#94a3b8" stroke-width="1.8"/>
                    <path d="M14 14l3 3" stroke="#94a3b8" stroke-width="1.8" stroke-linecap="round"/>
                </svg>
                <input class="adm-search-input" type="text" name="q"
                       value="<c:out value='${q}'/>" maxlength="255"
                       placeholder="Tìm theo tên hoặc email...">
            </div>
            <button class="hn-btn hn-btn--primary" type="submit">Tìm kiếm</button>
            <c:if test="${not empty q}">
                <a class="hn-btn hn-btn--ghost" href="${pageContext.request.contextPath}/admin/users">Xoá lọc</a>
            </c:if>
        </form>

        <!-- User list -->
        <c:choose>
            <c:when test="${empty usersPage.content}">
                <div class="adm-empty">
                    <div class="adm-empty__icon">🔍</div>
                    <h3>Không tìm thấy tài khoản</h3>
                    <p>Thử từ khoá khác.</p>
                </div>
            </c:when>
            <c:otherwise>
                <div class="adm-user-list">
                    <c:forEach var="user" items="${usersPage.content}">
                        <div class="adm-user-card ${user.self ? 'adm-user-card--self' : ''}">
                            <div class="adm-user-card__head">
                                <div class="adm-user-card__avatar">
                                    <c:out value="${fn:substring(user.fullName,0,1)}"/>
                                </div>
                                <div class="adm-user-card__info">
                                    <div class="adm-user-card__name">
                                        <c:out value="${user.fullName}"/>
                                        <c:if test="${user.self}"><span class="adm-badge--self">Bạn</span></c:if>
                                    </div>
                                    <div class="adm-user-card__email"><c:out value="${user.email}"/></div>
                                    <div class="adm-user-card__roles">
                                        <c:if test="${user.student}"><span class="adm-role-tag adm-role-tag--student">Student</span></c:if>
                                        <c:if test="${user.instructor}"><span class="adm-role-tag adm-role-tag--instructor">Instructor</span></c:if>
                                        <c:if test="${user.administrator}"><span class="adm-role-tag adm-role-tag--admin">Admin</span></c:if>
                                    </div>
                                </div>
                                <div class="adm-user-card__status-wrap">
                                    <c:choose>
                                        <c:when test="${user.status eq 'ACTIVE'}">
                                            <span class="adm-status adm-status--active"><span class="adm-status__dot"></span>Hoạt động</span>
                                        </c:when>
                                        <c:when test="${user.status eq 'LOCKED'}">
                                            <span class="adm-status adm-status--locked"><span class="adm-status__dot"></span>Đã khoá</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="adm-status adm-status--pending"><span class="adm-status__dot"></span>Chờ xác minh</span>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>

                            <c:if test="${not user.self}">
                                <div class="adm-user-card__actions">
                                    <!-- Vai trò -->
                                    <form class="adm-action-form" method="post"
                                          action="${pageContext.request.contextPath}/admin/users/${user.userId}/roles">
                                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                        <div class="adm-action-form__label">
                                            <svg viewBox="0 0 24 24" fill="none" width="13" height="13"><path d="M17 21v-2a4 4 0 00-4-4H5a4 4 0 00-4 4v2" stroke="currentColor" stroke-width="1.8"/><circle cx="9" cy="7" r="4" stroke="currentColor" stroke-width="1.8"/></svg>
                                            Vai trò
                                        </div>
                                        <div class="adm-role-checks">
                                            <label class="adm-check-label">
                                                <input type="checkbox" name="roles" value="STUDENT" ${user.student ? 'checked' : ''}> Học viên
                                            </label>
                                            <label class="adm-check-label">
                                                <input type="checkbox" name="roles" value="INSTRUCTOR" ${user.instructor ? 'checked' : ''}> Giảng viên
                                            </label>
                                            <label class="adm-check-label">
                                                <input type="checkbox" name="roles" value="ADMINISTRATOR" ${user.administrator ? 'checked' : ''}> Quản trị viên
                                            </label>
                                        </div>
                                        <button class="hn-btn hn-btn--primary adm-btn-sm" type="submit">💾 Lưu vai trò</button>
                                    </form>

                                    <div class="adm-action-divider"></div>

                                    <!-- Khoá / Khôi phục -->
                                    <c:if test="${user.status eq 'ACTIVE'}">
                                        <form class="adm-action-form" method="post"
                                              action="${pageContext.request.contextPath}/admin/users/${user.userId}/status">
                                            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                            <input type="hidden" name="action" value="LOCK">
                                            <div class="adm-action-form__label">
                                                <svg viewBox="0 0 24 24" fill="none" width="13" height="13"><rect x="5" y="11" width="14" height="10" rx="2" stroke="currentColor" stroke-width="1.8"/><path d="M8 11V7a4 4 0 018 0v4" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/></svg>
                                                Khoá tài khoản
                                            </div>
                                            <textarea class="adm-textarea" name="reason" rows="2"
                                                      placeholder="Lý do khoá (bắt buộc)..." required></textarea>
                                            <button class="adm-btn-danger adm-btn-sm" type="submit">🔒 Khoá tài khoản</button>
                                        </form>
                                    </c:if>
                                    <c:if test="${user.status eq 'LOCKED'}">
                                        <form class="adm-action-form" method="post"
                                              action="${pageContext.request.contextPath}/admin/users/${user.userId}/status">
                                            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                            <input type="hidden" name="action" value="RESTORE">
                                            <div class="adm-action-form__label">
                                                <svg viewBox="0 0 24 24" fill="none" width="13" height="13"><path d="M3 12a9 9 0 109-9 9 9 0 00-9 9z" stroke="currentColor" stroke-width="1.8"/><path d="M9 12l2 2 4-4" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/></svg>
                                                Khôi phục
                                            </div>
                                            <button class="hn-btn hn-btn--primary adm-btn-sm" type="submit">🔓 Khôi phục tài khoản</button>
                                        </form>
                                    </c:if>
                                    <c:if test="${user.status eq 'PENDING'}">
                                        <div class="adm-action-form">
                                            <p class="adm-note">⏳ Chờ xác minh email.</p>
                                        </div>
                                    </c:if>
                                </div>
                            </c:if>

                            <c:if test="${user.self}">
                                <div class="adm-user-card__self-note">ℹ️ Bạn không thể thay đổi vai trò hoặc trạng thái của chính mình.</div>
                            </c:if>
                        </div>
                    </c:forEach>
                </div>

                <c:if test="${usersPage.totalPages gt 1}">
                    <nav class="adm-pagination">
                        <c:if test="${usersPage.number gt 0}">
                            <c:url var="prev" value="/admin/users"><c:param name="q" value="${q}"/><c:param name="page" value="${usersPage.number - 1}"/></c:url>
                            <a class="adm-page-btn" href="${prev}">← Trang trước</a>
                        </c:if>
                        <span class="adm-page-info">Trang ${usersPage.number + 1} / ${usersPage.totalPages}</span>
                        <c:if test="${usersPage.number + 1 lt usersPage.totalPages}">
                            <c:url var="next" value="/admin/users"><c:param name="q" value="${q}"/><c:param name="page" value="${usersPage.number + 1}"/></c:url>
                            <a class="adm-page-btn" href="${next}">Trang sau →</a>
                        </c:if>
                    </nav>
                </c:if>
            </c:otherwise>
        </c:choose>

    </main>
</div>

<script>
function toggleUserMenu(e) {
    e.stopPropagation();
    e.currentTarget.closest('.hn-user-menu').classList.toggle('open');
}
document.addEventListener('click', () => {
    document.querySelectorAll('.hn-user-menu.open').forEach(m => m.classList.remove('open'));
});
</script>
</body>
</html>
