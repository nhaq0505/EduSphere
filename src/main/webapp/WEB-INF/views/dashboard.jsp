<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<!DOCTYPE html><html lang="vi"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"><title>Tổng quan — EduSphere</title><link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app.css"></head><body>
<jsp:include page="/WEB-INF/views/common/navbar.jsp"/>
<main class="shell">

<header class="page-heading"><div><p class="eyebrow">Tổng quan</p><h1>Chào mừng trở lại.</h1><p>Chọn nơi bạn muốn tiếp tục hôm nay.</p></div></header>
<c:if test="${not empty successMessage}"><div class="alert alert--success"><c:out value="${successMessage}"/></div></c:if>
<section class="overview-grid" aria-label="Các khu vực"><a class="card overview-card" href="${pageContext.request.contextPath}/courses"><h2>Khám phá khóa học</h2><p>Tìm một chủ đề mới để bắt đầu.</p><span class="overview-card__arrow">→</span></a>
<sec:authorize access="hasRole('STUDENT')"><a class="card overview-card" href="${pageContext.request.contextPath}/my-courses"><h2>Khóa học của tôi</h2><p>Xem các khóa học đã ghi danh.</p><span class="overview-card__arrow">→</span></a></sec:authorize>
<sec:authorize access="hasRole('INSTRUCTOR')"><a class="card overview-card" href="${pageContext.request.contextPath}/instructor/courses"><h2>Quản lý khóa học</h2><p>Tạo, chỉnh sửa và theo dõi trạng thái duyệt.</p><span class="overview-card__arrow">→</span></a></sec:authorize>
<sec:authorize access="hasRole('ADMINISTRATOR')"><a class="card overview-card" href="${pageContext.request.contextPath}/admin/courses/review"><h2>Duyệt khóa học</h2><p>Xem và xử lý khóa học đang chờ.</p><span class="overview-card__arrow">→</span></a></sec:authorize>
<a class="card overview-card" href="${pageContext.request.contextPath}/profile"><h2>Hồ sơ cá nhân</h2><p>Cập nhật thông tin tài khoản.</p><span class="overview-card__arrow">→</span></a></section>
</main>
<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</body></html>
