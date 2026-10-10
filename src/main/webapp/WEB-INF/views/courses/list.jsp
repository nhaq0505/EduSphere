<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<!DOCTYPE html><html lang="vi"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"><title>Khám phá khóa học — EduSphere</title><link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app.css"></head><body>
<jsp:include page="/WEB-INF/views/common/navbar.jsp"/>
<main class="shell">

<header class="page-heading"><div><p class="eyebrow">Thư viện khóa học</p><h1>Khám phá khóa học</h1><p>Tìm nội dung phù hợp với sở thích, trình độ và ngân sách của bạn.</p></div></header>
<form class="card filter-panel" method="get" action="${pageContext.request.contextPath}/courses" role="search">
  <div><label for="q">Từ khóa</label><input id="q" name="q" type="search" maxlength="100" placeholder="Bạn muốn học gì?" value="<c:out value='${q}'/>"></div>
  <div><label for="categoryId">Danh mục</label><select id="categoryId" name="categoryId"><option value="">Tất cả</option><c:forEach var="category" items="${categories}"><option value="${category.categoryId}" ${categoryId == category.categoryId ? 'selected="selected"' : ''}><c:out value="${category.name}"/></option></c:forEach></select></div>
  <div><label for="level">Trình độ</label><select id="level" name="level"><option value="">Tất cả</option><option value="BEGINNER" ${level == 'BEGINNER' ? 'selected="selected"' : ''}>Cơ bản</option><option value="INTERMEDIATE" ${level == 'INTERMEDIATE' ? 'selected="selected"' : ''}>Trung cấp</option><option value="ADVANCED" ${level == 'ADVANCED' ? 'selected="selected"' : ''}>Nâng cao</option><option value="ALL_LEVELS" ${level == 'ALL_LEVELS' ? 'selected="selected"' : ''}>Mọi trình độ</option></select></div>
  <div><label for="priceFilter">Học phí</label><select id="priceFilter" name="priceFilter"><option value="">Tất cả</option><option value="FREE" ${priceFilter == 'FREE' ? 'selected="selected"' : ''}>Miễn phí</option><option value="PAID" ${priceFilter == 'PAID' ? 'selected="selected"' : ''}>Có phí</option></select></div>
  <button class="button button--primary" type="submit">Tìm kiếm</button>
</form>
<div class="section-heading"><h2>Khóa học đang mở</h2><span class="muted"><fmt:formatNumber value="${coursePage.totalElements}" type="number"/> kết quả</span></div>
<c:choose><c:when test="${empty coursePage.content}"><div class="empty-state"><span class="empty-state__mark">?</span><h3>Chưa tìm thấy khóa học phù hợp</h3><p>Thử một từ khóa khác hoặc xóa bộ lọc để xem tất cả khóa học.</p><a class="button button--outline" href="${pageContext.request.contextPath}/courses">Xóa bộ lọc</a></div></c:when>
<c:otherwise><div class="course-grid"><c:forEach var="course" items="${coursePage.content}"><c:url var="detailUrl" value="/courses/${course.courseId}"/>
<article class="card course-card"><div class="course-card__visual" aria-hidden="true">EduSphere · Khóa học</div><div class="course-card__body"><div class="course-card__meta"><span class="pill"><c:out value="${course.categoryName}"/></span><span class="pill pill--neutral"><c:out value="${course.levelLabel}"/></span></div>
<h3><a href="${detailUrl}"><c:out value="${course.title}"/></a></h3><p><c:out value="${course.summary}"/></p><p class="small">Giảng viên: <c:out value="${course.instructorName}"/></p>
<div class="course-card__bottom"><strong class="price"><c:choose><c:when test="${course.free}">Miễn phí</c:when><c:otherwise><fmt:formatNumber value="${course.price}" type="number" maxFractionDigits="0"/> <c:out value="${course.currency}"/></c:otherwise></c:choose></strong><a href="${detailUrl}">Xem chi tiết →</a></div></div></article>
</c:forEach></div></c:otherwise></c:choose>
<c:if test="${coursePage.totalPages > 1}"><nav class="pagination" aria-label="Phân trang">
<c:if test="${coursePage.number > 0}"><c:url var="previousUrl" value="/courses"><c:param name="q" value="${q}"/><c:param name="categoryId" value="${categoryId}"/><c:param name="level" value="${level}"/><c:param name="priceFilter" value="${priceFilter}"/><c:param name="page" value="${coursePage.number - 1}"/></c:url><a href="${previousUrl}">← Trang trước</a></c:if>
<span>Trang ${coursePage.number + 1} / ${coursePage.totalPages}</span>
<c:if test="${coursePage.number + 1 < coursePage.totalPages}"><c:url var="nextUrl" value="/courses"><c:param name="q" value="${q}"/><c:param name="categoryId" value="${categoryId}"/><c:param name="level" value="${level}"/><c:param name="priceFilter" value="${priceFilter}"/><c:param name="page" value="${coursePage.number + 1}"/></c:url><a href="${nextUrl}">Trang sau →</a></c:if>
</nav></c:if>
</main>
<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</body></html>
