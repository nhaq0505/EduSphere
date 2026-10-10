<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<!DOCTYPE html><html lang="vi"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"><title>Duyệt khóa học — EduSphere</title><link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app.css"></head><body>
<jsp:include page="/WEB-INF/views/common/navbar.jsp"/>
<main class="shell">
<header class="page-heading"><div><p class="eyebrow">Không gian quản trị</p><h1>Duyệt khóa học</h1><p>Xem nội dung giảng viên đã gửi và đưa ra quyết định.</p></div></header>
<c:if test="${not empty success}"><div class="alert alert--success"><c:out value="${success}"/></div></c:if>
<c:choose><c:when test="${empty courses}"><div class="empty-state"><span class="empty-state__mark">✓</span><h2>Không có khóa học chờ duyệt</h2><p>Hàng chờ hiện đã được xử lý hết.</p></div></c:when><c:otherwise>
<c:forEach var="course" items="${courses}"><article class="card review-card"><span class="pill pill--gold">Chờ duyệt</span><h2 style="margin:16px 0 10px"><c:out value="${course.title}"/></h2><p>Giảng viên <strong><c:out value="${course.instructorName}"/></strong> · <c:out value="${course.categoryName}"/> · Phiên bản <c:out value="${course.versionNo}"/></p><p>Học phí: <fmt:formatNumber value="${course.price}" type="number" maxFractionDigits="0"/> VND</p><p class="description"><c:out value="${course.description}"/></p>
<div class="review-actions"><form method="post" action="${pageContext.request.contextPath}/admin/courses/${course.courseId}/review"><input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"><input type="hidden" name="decision" value="APPROVED"><p class="small">Xác nhận thông tin khóa học đã phù hợp.</p><button class="button button--primary" type="submit">Phê duyệt</button></form>
<form method="post" action="${pageContext.request.contextPath}/admin/courses/${course.courseId}/review"><input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"><input type="hidden" name="decision" value="REJECTED"><div class="field"><label for="reason-${course.courseId}">Lý do từ chối *</label><textarea id="reason-${course.courseId}" name="comment" rows="3" maxlength="2000" required></textarea></div><button class="button button--danger" type="submit">Từ chối</button></form></div></article></c:forEach></c:otherwise></c:choose></main>
<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</body></html>
