<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<!DOCTYPE html><html lang="vi"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"><title>Chi tiết khóa học — EduSphere</title><link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app.css"></head><body>
<jsp:include page="/WEB-INF/views/common/navbar.jsp"/>
<main class="shell">
<a class="back-link" href="${pageContext.request.contextPath}/instructor/courses">← Quản lý khóa học</a>
<div class="detail-layout"><article class="card detail-main"><c:choose><c:when test="${course.status == 'DRAFT'}"><span class="pill pill--neutral">Bản nháp</span></c:when><c:when test="${course.status == 'SUBMITTED'}"><span class="pill pill--gold">Chờ duyệt</span></c:when><c:when test="${course.status == 'APPROVED'}"><span class="pill pill--success">Đã duyệt</span></c:when><c:when test="${course.status == 'PUBLISHED'}"><span class="pill pill--success">Đã công bố</span></c:when><c:when test="${course.status == 'REJECTED'}"><span class="pill pill--danger">Cần chỉnh sửa</span></c:when><c:when test="${course.status == 'ARCHIVED'}"><span class="pill pill--neutral">Đã lưu trữ</span></c:when><c:otherwise><span class="pill pill--neutral">Đang xử lý</span></c:otherwise></c:choose><h1><c:out value="${course.title}"/></h1><p>Phiên bản <c:out value="${course.versionNo}"/> · <c:out value="${course.categoryName}"/></p>
<c:if test="${course.status == 'REJECTED' && not empty course.latestReviewComment}"><div class="alert alert--error"><strong>Lý do từ chối:</strong> <c:out value="${course.latestReviewComment}"/></div></c:if>
<h2>Mô tả</h2><p class="description"><c:out value="${course.description}" default="Chưa có mô tả."/></p><h2>Thông tin khóa học</h2>
<dl class="info-list"><dt>Trình độ</dt><dd><c:choose><c:when test="${course.level == 'BEGINNER'}">Cơ bản</c:when><c:when test="${course.level == 'INTERMEDIATE'}">Trung cấp</c:when><c:when test="${course.level == 'ADVANCED'}">Nâng cao</c:when><c:otherwise>Mọi trình độ</c:otherwise></c:choose></dd><dt>Học phí</dt><dd><fmt:formatNumber value="${course.price}" type="number" maxFractionDigits="0"/> VND</dd></dl>
</article><aside class="card detail-aside"><p class="eyebrow">Bước tiếp theo</p>
<c:choose><c:when test="${course.status == 'DRAFT' || course.status == 'REJECTED'}"><p>Kiểm tra thông tin trước khi gửi duyệt.</p><a class="button button--outline" href="${pageContext.request.contextPath}/instructor/courses/${course.courseId}/edit">Chỉnh sửa</a><form method="post" action="${pageContext.request.contextPath}/instructor/courses/${course.courseId}/submit" style="margin-top:12px"><input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"><button class="button button--primary" type="submit">Gửi duyệt</button></form></c:when>
<c:when test="${course.status == 'APPROVED'}"><p>Khóa học đã được duyệt. Bạn có thể công bố để học viên nhìn thấy.</p><form method="post" action="${pageContext.request.contextPath}/instructor/courses/${course.courseId}/publish"><input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"><button class="button button--primary" type="submit">Công bố khóa học</button></form></c:when>
<c:when test="${course.status == 'PUBLISHED'}"><p>Khóa học đang được công khai.</p><form method="post" action="${pageContext.request.contextPath}/instructor/courses/${course.courseId}/archive"><input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"><button class="button button--outline" type="submit">Lưu trữ khóa học</button></form></c:when>
<c:when test="${course.status == 'SUBMITTED'}"><p class="status-note">Đang chờ quản trị viên duyệt.</p></c:when><c:otherwise><p class="status-note">Khóa học đã lưu trữ.</p></c:otherwise></c:choose>
</aside></div></main>
<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</body></html>
