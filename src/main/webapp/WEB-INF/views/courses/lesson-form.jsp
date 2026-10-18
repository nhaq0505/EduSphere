<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Bài học — EduSphere</title>
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

        <a class="ins-back-link"
           href="${pageContext.request.contextPath}/instructor/courses/${courseId}/lessons">
            ← Danh sách bài học
        </a>

        <div class="ins-form-card">
            <div class="ins-form-card__header">
                <div class="ins-form-card__eyebrow">📝 Bài học</div>
                <h1>
                    <c:choose>
                        <c:when test="${empty lessonId}">Tạo bài học mới</c:when>
                        <c:otherwise>Chỉnh sửa bài học</c:otherwise>
                    </c:choose>
                </h1>
                <p>Nội dung sẽ hiển thị cho học viên khi khóa học được công bố.</p>
            </div>
            <div class="ins-form-card__body">
                <form:form method="post" modelAttribute="lessonForm"
                           action="${pageContext.request.contextPath}${formAction}" htmlEscape="true">
                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">

                    <div class="ins-field">
                        <label for="title">Tên bài học <span style="color:#EF4444">*</span></label>
                        <form:input path="title" id="title" maxlength="255"
                                    placeholder="VD: Giới thiệu về Spring Boot"/>
                        <form:errors path="title" cssClass="ins-field__error"/>
                    </div>

                    <div class="ins-field">
                        <label for="content">Nội dung bài học</label>
                        <form:textarea path="content" id="content" rows="14"
                                       placeholder="Viết nội dung bài học ở đây..."/>
                        <form:errors path="content" cssClass="ins-field__error"/>
                    </div>

                    <c:if test="${not empty lessonId}">
                        <div class="ins-field" style="max-width:200px">
                            <label for="orderIndex">Vị trí trong khóa học</label>
                            <form:input path="orderIndex" id="orderIndex" type="number"
                                        min="1" max="${maxOrder}"/>
                            <span class="ins-field__hint">Từ 1 đến ${maxOrder}</span>
                            <form:errors path="orderIndex" cssClass="ins-field__error"/>
                        </div>
                    </c:if>

                    <div class="ins-form-actions">
                        <button class="ins-form-btn-primary" type="submit">💾 Lưu bài học</button>
                        <a class="ins-form-btn-cancel"
                           href="${pageContext.request.contextPath}/instructor/courses/${courseId}/lessons">
                            Hủy
                        </a>
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
