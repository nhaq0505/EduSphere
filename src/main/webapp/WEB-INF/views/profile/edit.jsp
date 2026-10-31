<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"    uri="jakarta.tags.core" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<%@ taglib prefix="sec"  uri="http://www.springframework.org/security/tags" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chỉnh sửa hồ sơ — EduSphere</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/home.css">
    <sec:authorize access="hasRole('INSTRUCTOR')">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/instructor.css">
    </sec:authorize>
</head>
<body>

<sec:authorize access="hasRole('INSTRUCTOR')">
<div class="ins-layout">
    <jsp:include page="/WEB-INF/views/courses/ins-sidebar.jsp"/>
    <div class="ins-main-wrapper">
        <jsp:include page="/WEB-INF/views/courses/ins-header.jsp"/>
        <main class="ins-page">
</sec:authorize>

<sec:authorize access="!hasRole('INSTRUCTOR')">
<div style="min-height:100vh;background:#F4F7FC;padding:40px 24px 80px;">
    <div style="max-width:560px;margin:0 auto;">
    <a href="${pageContext.request.contextPath}/profile"
       style="display:inline-flex;align-items:center;gap:6px;color:#7A8C9E;font-size:.84rem;font-weight:600;text-decoration:none;margin-bottom:20px;">
        ← Hồ sơ cá nhân
    </a>
</sec:authorize>

<%-- FORM card --%>
<div style="max-width:560px;">
    <c:if test="${not empty errorMessage}">
        <div class="ins-alert ins-alert--error" style="margin-bottom:16px;">❌ <c:out value="${errorMessage}"/></div>
    </c:if>

    <div style="background:#fff;border-radius:16px;border:1px solid #E8EFF6;overflow:hidden;box-shadow:0 4px 20px rgba(27,154,245,.07);">
        <div style="background:linear-gradient(135deg,#1B9AF5,#0F7DD8);padding:22px 28px;">
            <h1 style="font-size:1.15rem;font-weight:800;color:white;margin:0 0 3px;">Chỉnh sửa hồ sơ</h1>
            <p style="font-size:.82rem;color:rgba(255,255,255,.8);margin:0;">Cập nhật họ tên và số điện thoại của bạn.</p>
        </div>
        <div style="padding:28px;">
            <form:form method="post"
                       action="${pageContext.request.contextPath}/profile/edit"
                       modelAttribute="updateProfileRequest">
                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">

                <div class="ins-field">
                    <label for="fullName">Họ và tên <span style="color:#EF4444">*</span></label>
                    <form:input path="fullName" id="fullName" maxlength="100"/>
                    <form:errors path="fullName" cssClass="ins-field__error"/>
                </div>

                <div class="ins-field">
                    <label>Email <span style="font-size:.78rem;color:#7A8C9E;font-weight:400">(không thể thay đổi)</span></label>
                    <input type="text" value="<c:out value='${user.email}'/>"
                           style="width:100%;padding:10px 14px;border:1.5px solid #E8EFF6;border-radius:8px;font-size:.9rem;color:#7A8C9E;background:#F4F7FC;font-family:inherit;" disabled>
                </div>

                <div class="ins-field">
                    <label for="phone">Số điện thoại</label>
                    <form:input path="phone" id="phone" placeholder="0912345678" maxlength="20"/>
                    <form:errors path="phone" cssClass="ins-field__error"/>
                </div>

                <div class="ins-form-actions" style="margin-top:8px;">
                    <button class="ins-form-btn-primary" type="submit">💾 Lưu thay đổi</button>
                    <a class="ins-form-btn-cancel" href="${pageContext.request.contextPath}/profile">Huỷ</a>
                </div>
            </form:form>
        </div>
    </div>
</div>

<sec:authorize access="hasRole('INSTRUCTOR')">
        </main>
    </div>
</div>
</sec:authorize>

<sec:authorize access="!hasRole('INSTRUCTOR')">
    </div><%-- max-width wrapper --%>
</div><%-- standalone-page --%>
</sec:authorize>

<script>
function insToggleMenu(e){e.stopPropagation();document.getElementById('insUserMenu').classList.toggle('open');}
document.addEventListener('click',function(){var m=document.getElementById('insUserMenu');if(m)m.classList.remove('open');});
</script>
</body>
</html>
