<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<!DOCTYPE html><html lang="vi"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"><title>Liên kết không hợp lệ — EduSphere</title><link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app.css"></head><body>
<jsp:include page="/WEB-INF/views/common/navbar.jsp"/>
<main class="shell"><div class="auth-layout"><section class="auth-side"><p class="eyebrow">EduSphere · Học tập có định hướng</p><h1>Một nơi để học tập mỗi ngày.</h1><div class="auth-side__line"></div><p>Khám phá những chủ đề mới và xây dựng hành trình học phù hợp với bạn.</p></section><section class="card auth-card" aria-label="Liên kết không hợp lệ">
<p class="eyebrow">Khôi phục tài khoản</p><h2>Không thể tiếp tục</h2><div class="alert alert--error" role="alert"><c:out value="${errorMessage}" default="Liên kết hoặc mã xác minh không còn hiệu lực."/></div><a class="button button--primary button--block" href="${pageContext.request.contextPath}/forgot-password">Yêu cầu mã mới</a></section></div></main>
<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</body></html>
