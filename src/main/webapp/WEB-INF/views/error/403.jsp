<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<!DOCTYPE html><html lang="vi"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"><title>Không có quyền truy cập — EduSphere</title><link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app.css"></head><body>
<jsp:include page="/WEB-INF/views/common/navbar.jsp"/>
<main class="shell shell--narrow">
<div class="empty-state"><p class="error-code">403</p><h1>Không có quyền truy cập</h1><p>Tài khoản của bạn không có quyền xem trang này.</p><a class="button button--primary" href="${pageContext.request.contextPath}/">Về khu vực của tôi</a></div></main>
<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</body></html>
