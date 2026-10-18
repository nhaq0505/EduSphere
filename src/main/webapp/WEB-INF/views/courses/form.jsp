<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Thông tin khóa học — EduSphere</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/home.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/instructor.css">
</head>
<body>
<jsp:include page="/WEB-INF/views/courses/ins-header.jsp"/>
<div class="ins-shell">
    <jsp:include page="/WEB-INF/views/courses/ins-sidebar.jsp"/>
    <main class="ins-content">

        <a class="ins-back-link" href="${pageContext.request.contextPath}/instructor/courses">← Quay lại danh sách</a>

        <div class="ins-form-card">
            <div class="ins-form-card__header">
                <div class="ins-form-card__eyebrow">🧑‍🏫 Giảng viên</div>
                <h1><c:choose><c:when test="${formAction.contains('/edit')}">Chỉnh sửa khóa học</c:when><c:otherwise>Tạo khóa học mới</c:otherwise></c:choose></h1>
                <p>Điền thông tin bên dưới, lưu bản nháp trước khi gửi duyệt.</p>
            </div>
            <div class="ins-form-card__body">
                <form:form method="post" modelAttribute="courseForm"
                           action="${pageContext.request.contextPath}${formAction}" htmlEscape="true">
                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">

                    <div class="ins-field">
                        <label for="title">Tên khóa học <span style="color:#EF4444">*</span></label>
                        <form:input path="title" id="title" maxlength="255" placeholder="VD: Java từ cơ bản đến nâng cao"/>
                        <form:errors path="title" cssClass="ins-field__error"/>
                    </div>

                    <div class="ins-field">
                        <label for="description">Mô tả khóa học</label>
                        <form:textarea path="description" id="description" rows="6"
                                       placeholder="Mô tả ngắn về nội dung, đối tượng và mục tiêu của khóa học..."/>
                        <form:errors path="description" cssClass="ins-field__error"/>
                    </div>

                    <div class="ins-form-grid">
                        <div class="ins-field">
                            <label for="categoryId">Danh mục</label>
                            <form:select path="categoryId" id="categoryId">
                                <form:option value="" label="Chưa phân loại"/>
                                <form:options items="${categories}" itemValue="categoryId" itemLabel="name"/>
                            </form:select>
                            <form:errors path="categoryId" cssClass="ins-field__error"/>
                        </div>
                        <div class="ins-field">
                            <label for="level">Trình độ <span style="color:#EF4444">*</span></label>
                            <form:select path="level" id="level">
                                <form:option value="ALL_LEVELS" label="Mọi trình độ"/>
                                <form:option value="BEGINNER"   label="Cơ bản"/>
                                <form:option value="INTERMEDIATE" label="Trung cấp"/>
                                <form:option value="ADVANCED"   label="Nâng cao"/>
                            </form:select>
                            <form:errors path="level" cssClass="ins-field__error"/>
                        </div>
                    </div>

                    <div class="ins-field">
                        <label for="price">Học phí (VND) <span style="color:#EF4444">*</span></label>
                        <form:input path="price" id="price" type="number" min="0" step="1000"/>
                        <span class="ins-field__hint">Nhập 0 nếu khóa học miễn phí.</span>
                        <form:errors path="price" cssClass="ins-field__error"/>
                    </div>

                    <div class="ins-form-actions">
                        <button class="ins-form-btn-primary" type="submit">💾 Lưu khóa học</button>
                        <a class="ins-form-btn-cancel" href="${pageContext.request.contextPath}/instructor/courses">Hủy</a>
                    </div>
                </form:form>
            </div>
        </div>
    </main>
</div>
<script>
function toggleUserMenu(e){e.stopPropagation();e.currentTarget.closest('.hn-user-menu').classList.toggle('open');}
document.addEventListener('click',()=>document.querySelectorAll('.hn-user-menu.open').forEach(m=>m.classList.remove('open')));
</script>
</body></html>
