<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<!DOCTYPE html><html lang="vi"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"><title>Không tìm thấy khóa học — EduSphere</title><link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app.css"></head><body>
<jsp:include page="/WEB-INF/views/common/navbar.jsp"/>
<main class="shell shell--narrow">
<div class="empty-state"><span class="empty-state__mark">?</span><h1>Không tìm thấy khóa học</h1><p>Khóa học này không tồn tại hoặc chưa được công bố.</p><a class="button button--primary" href="${pageContext.request.contextPath}/courses">Xem khóa học công khai</a></div></main>
<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</body></html>
