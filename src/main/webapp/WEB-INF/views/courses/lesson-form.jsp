<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<!DOCTYPE html><html lang="vi"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"><title>Bài học — EduSphere</title><link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app.css?v=restore-0bfd0e1-20261014"></head><body>
<jsp:include page="/WEB-INF/views/common/navbar.jsp"/>
<main class="shell shell--narrow"><a class="back-link" href="${pageContext.request.contextPath}/instructor/courses/${courseId}/lessons">← Danh sách bài học</a>
<header class="page-heading"><div><p class="eyebrow">Không gian giảng viên</p><h1><c:choose><c:when test="${empty lessonId}">Tạo bài học</c:when><c:otherwise>Sửa bài học</c:otherwise></c:choose></h1><p>Nội dung bài học sẽ hiển thị cho học viên khi khóa học được công bố.</p></div></header>
<div class="card form-card"><form:form method="post" modelAttribute="lessonForm" action="${pageContext.request.contextPath}${formAction}" htmlEscape="true"><input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
<div class="field"><label for="title">Tên bài học *</label><form:input path="title" id="title" maxlength="255" required="required"/><form:errors path="title" cssClass="field-error"/></div>
<div class="field"><label for="content">Nội dung</label><form:textarea path="content" id="content" rows="12"/><form:errors path="content" cssClass="field-error"/></div>
<c:if test="${not empty lessonId}"><div class="field"><label for="orderIndex">Vị trí trong khóa học</label><form:input path="orderIndex" id="orderIndex" type="number" min="1" max="${maxOrder}"/><span class="field__hint">Chọn vị trí từ 1 đến ${maxOrder}. Các bài khác sẽ tự dịch chuyển.</span><form:errors path="orderIndex" cssClass="field-error"/></div></c:if>
<div class="form-actions"><button class="button button--primary" type="submit">Lưu bài học</button><a class="button button--outline" href="${pageContext.request.contextPath}/instructor/courses/${courseId}/lessons">Hủy</a></div></form:form></div></main>
<jsp:include page="/WEB-INF/views/common/footer.jsp"/></body></html>
