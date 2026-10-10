<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<!DOCTYPE html><html lang="vi"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"><title>Chi tiết khóa học — EduSphere</title><link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app.css"></head><body>
<jsp:include page="/WEB-INF/views/common/navbar.jsp"/>
<main class="shell">

<a class="back-link" href="${pageContext.request.contextPath}/courses">← Tất cả khóa học</a>
<div class="detail-layout"><article class="card detail-main"><div class="course-card__meta"><span class="pill"><c:out value="${course.categoryName}"/></span><span class="pill pill--neutral"><c:out value="${course.levelLabel}"/></span></div>
<h1><c:out value="${course.title}"/></h1><p>Giảng viên <strong><c:out value="${course.instructorName}"/></strong></p>
<div class="divider"></div><h2>Giới thiệu khóa học</h2><p class="description"><c:out value="${course.description}" default="Chưa có mô tả."/></p>
<h2>Nội dung giới thiệu</h2><c:choose><c:when test="${empty lessonTitles}"><p>Chưa có bài học công khai để giới thiệu.</p></c:when><c:otherwise><ol class="lesson-list"><c:forEach var="lessonTitle" items="${lessonTitles}"><li><c:out value="${lessonTitle}"/></li></c:forEach></ol></c:otherwise></c:choose>
</article><aside class="card detail-aside"><p class="eyebrow">Thông tin ghi danh</p><span class="muted"><c:choose><c:when test="${course.free}">Học phí</c:when><c:otherwise>Học phí dự kiến</c:otherwise></c:choose></span><strong class="price"><c:choose><c:when test="${course.free}">Miễn phí</c:when><c:otherwise><fmt:formatNumber value="${course.price}" type="number" maxFractionDigits="0"/> <c:out value="${course.currency}"/></c:otherwise></c:choose></strong>
<c:if test="${not course.free}"><p class="status-note">Đang cho ghi danh thử, chưa thu học phí.</p></c:if>
<c:choose>
<c:when test="${enrolled}"><p class="status-note">Bạn đã ghi danh khóa học này.</p><a class="button button--primary" href="${pageContext.request.contextPath}/my-courses">Khóa học của tôi</a></c:when>
<c:when test="${student}"><form method="post" action="${pageContext.request.contextPath}/courses/${course.courseId}/enroll"><input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"><button class="button button--primary" type="submit">Ghi danh khóa học</button></form></c:when>
<c:otherwise><sec:authorize access="isAnonymous()"><p>Đăng nhập bằng tài khoản học viên để ghi danh.</p><a class="button button--primary" href="${pageContext.request.contextPath}/login?courseId=${course.courseId}">Đăng nhập</a></sec:authorize>
<sec:authorize access="isAuthenticated()"><p>Chỉ tài khoản học viên mới có thể ghi danh.</p></sec:authorize></c:otherwise>
</c:choose>
</aside></div>
</main>
<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</body></html>
