<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<!DOCTYPE html><html lang="vi"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"><title>Trang chủ — EduSphere</title><link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app.css"></head><body>
<jsp:include page="/WEB-INF/views/common/navbar.jsp"/>
<main class="shell">

<section class="hero">
  <div class="hero__content"><p class="eyebrow">Học tập có định hướng</p><h1>Học điều bạn muốn. Đi xa hơn mỗi ngày.</h1><p class="lead">Khám phá khóa học phù hợp với mục tiêu của bạn, theo dõi hành trình học và học cùng những giảng viên tâm huyết.</p><div class="hero__actions"><a class="button button--primary" href="${pageContext.request.contextPath}/courses">Khám phá khóa học</a><a class="button button--outline" href="${pageContext.request.contextPath}/register">Tạo tài khoản</a></div></div>
  <div class="hero__art" aria-hidden="true"><div class="hero__quote">“Kiến thức bắt đầu từ một bước nhỏ.”<span>EduSphere</span></div></div>
</section>
<div class="section-heading"><h2>Một nơi để bắt đầu và tiếp tục</h2></div>
<section class="feature-grid" aria-label="Giá trị của EduSphere">
  <article class="card feature-card"><span class="feature-card__number">01</span><h3>Chọn đúng khóa học</h3><p>Tìm kiếm theo chủ đề, trình độ và học phí trước khi quyết định.</p></article>
  <article class="card feature-card"><span class="feature-card__number">02</span><h3>Học theo mục tiêu</h3><p>Xem nội dung giới thiệu và thông tin giảng viên một cách rõ ràng.</p></article>
  <article class="card feature-card"><span class="feature-card__number">03</span><h3>Theo dõi dễ dàng</h3><p>Quản lý những khóa học đã ghi danh tại một nơi.</p></article>
</section>
</main>
<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</body></html>
