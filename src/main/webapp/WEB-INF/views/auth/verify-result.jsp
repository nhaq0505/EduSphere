<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<!DOCTYPE html><html lang="vi"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"><title>Kết quả xác minh — EduSphere</title><link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app.css"></head><body>
<jsp:include page="/WEB-INF/views/common/navbar.jsp"/>
<main class="shell"><div class="auth-layout"><section class="auth-side"><p class="eyebrow">EduSphere · Học tập có định hướng</p><h1>Một nơi để học tập mỗi ngày.</h1><div class="auth-side__line"></div><p>Khám phá những chủ đề mới và xây dựng hành trình học phù hợp với bạn.</p></section><section class="card auth-card" aria-label="Kết quả xác minh">
<c:choose><c:when test="${not empty successMessage}"><p class="eyebrow">Xác minh thành công</p><h2>Tài khoản đã sẵn sàng</h2><div class="alert alert--success"><c:out value="${successMessage}"/></div><a class="button button--primary button--block" href="${pageContext.request.contextPath}/login">Đăng nhập</a></c:when><c:otherwise><p class="eyebrow">Xác minh chưa thành công</p><h2>Vui lòng thử lại</h2><div class="alert alert--error" role="alert"><c:out value="${errorMessage}"/></div><a class="button button--outline button--block" href="${pageContext.request.contextPath}/register">Đăng ký lại</a></c:otherwise></c:choose></section></div></main>
<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</body></html>
