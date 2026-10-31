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
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/instructor.css">
</head>
<body>
<div class="ins-layout">
    <jsp:include page="/WEB-INF/views/courses/ins-sidebar.jsp"/>
    <div class="ins-main-wrapper">
        <jsp:include page="/WEB-INF/views/courses/ins-header.jsp"/>
        <main class="ins-page">


        <div class="ins-form-card">
            <div class="ins-form-card__header">
                <div class="ins-form-card__eyebrow">🧑‍🏫 Giảng viên</div>
                <h1><c:choose><c:when test="${not empty course}">Chỉnh sửa khóa học (v${course.versionNo})</c:when><c:otherwise>Tạo khóa học mới</c:otherwise></c:choose></h1>
                <p>Điền thông tin bên dưới, lưu bản nháp trước khi gửi duyệt.</p>
            </div>
            <div class="ins-form-card__body">
                <c:if test="${not empty course && (course.status == 'APPROVED' || course.status == 'PUBLISHED')}">
                    <div style="background:#EFF6FF; border:1.5px solid #BFDBFE; border-radius:var(--r8); padding:12px 16px; margin-bottom:20px; font-size:.85rem; color:#1E40AF;">
                        💡 <strong>Lưu ý:</strong> Khóa học này hiện đang ở trạng thái <strong>${course.status == 'PUBLISHED' ? 'Đã công bố' : 'Đã duyệt / Tạm ẩn'}</strong>.
                        Khi bạn lưu thay đổi, hệ thống sẽ nâng lên phiên bản <strong>v${course.versionNo + 1}</strong> và đưa về <strong>Bản nháp</strong> để bạn hoàn thiện trước khi gửi Admin duyệt lại.
                    </div>
                </c:if>
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
</div>
<script>
function insToggleMenu(e){e.stopPropagation();document.getElementById('insUserMenu').classList.toggle('open');}
document.addEventListener('click',function(){var m=document.getElementById('insUserMenu');if(m)m.classList.remove('open');});
</script>
</body></html>
