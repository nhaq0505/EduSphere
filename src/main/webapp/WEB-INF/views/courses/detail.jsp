<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<fmt:setLocale value="vi_VN"/>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><c:out value="${course.title}"/> — EduSphere</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/home.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/course-detail.css">
</head>
<body>
<header class="hn-header">
    <div class="hn-header__inner">
        <a class="hn-logo" href="${pageContext.request.contextPath}/" aria-label="EduSphere - Trang chủ"><span class="hn-logo__icon" aria-hidden="true">🎓</span><span>EduSphere</span></a>
        <nav class="hn-nav" aria-label="Điều hướng chính">
            <a class="hn-nav__link" href="${pageContext.request.contextPath}/">Trang chủ</a>
            <a class="hn-nav__link hn-nav__link--active" href="${pageContext.request.contextPath}/courses" aria-current="page">Khóa học</a>
            <sec:authorize access="hasRole('STUDENT')"><a class="hn-nav__link" href="${pageContext.request.contextPath}/my-courses">Khóa học của tôi</a></sec:authorize>
            <sec:authorize access="hasRole('INSTRUCTOR')"><a class="hn-nav__link" href="${pageContext.request.contextPath}/instructor/courses">Giảng viên</a></sec:authorize>
            <sec:authorize access="hasRole('ADMINISTRATOR')"><a class="hn-nav__link" href="${pageContext.request.contextPath}/admin/users">Quản trị</a></sec:authorize>
        </nav>
        <div class="hn-header__right cd-header-actions">
            <form class="cd-header-search" action="${pageContext.request.contextPath}/courses" method="get" role="search">
                <label class="cd-sr-only" for="course-search">Tìm khóa học</label>
                <input id="course-search" name="q" type="search" placeholder="Tìm kiếm khóa học...">
                <button type="submit" aria-label="Tìm kiếm">⌕</button>
            </form>
            <sec:authorize access="isAnonymous()"><a class="hn-btn hn-btn--ghost" href="${pageContext.request.contextPath}/login">Đăng nhập</a><a class="hn-btn hn-btn--primary" href="${pageContext.request.contextPath}/register">Đăng ký</a></sec:authorize>
            <sec:authorize access="isAuthenticated()"><a class="cd-profile-link" href="${pageContext.request.contextPath}/profile">Hồ sơ</a></sec:authorize>
        </div>
    </div>
</header>

<main class="cd-main">
    <div class="hn-container">
        <nav class="cd-breadcrumb" aria-label="Đường dẫn trang"><a href="${pageContext.request.contextPath}/courses">Khóa học</a><span aria-hidden="true">/</span><span aria-current="page"><c:out value="${course.title}"/></span></nav>
        <div class="cd-layout">
            <div class="cd-content">
                <section class="cd-hero" aria-labelledby="course-title">
                    <div><span class="cd-eyebrow">KHÁM PHÁ KHÓA HỌC</span><div class="cd-tags"><span class="cd-tag"><c:out value="${course.categoryName}"/></span><span class="cd-tag"><c:out value="${course.levelLabel}"/></span></div><h1 id="course-title"><c:out value="${course.title}"/></h1><p>Giảng viên <strong><c:out value="${course.instructorName}"/></strong></p></div>
                    <div class="cd-hero__art" aria-hidden="true">📚</div>
                </section>
                <section class="cd-panel" aria-labelledby="course-about"><span class="cd-section-kicker">TỔNG QUAN</span><h2 id="course-about">Về khóa học này</h2><p class="cd-description"><c:out value="${course.description}" default="Khóa học hiện chưa có mô tả."/></p></section>
                <section class="cd-panel" aria-labelledby="course-lessons">
                    <div class="cd-section-heading"><div><span class="cd-section-kicker">LỘ TRÌNH HỌC</span><h2 id="course-lessons">Nội dung khóa học</h2></div><c:if test="${not empty lessonTitles}"><span class="cd-count">${lessonTitles.size()} bài học</span></c:if></div>
                    <c:choose><c:when test="${empty lessonTitles}"><p class="cd-empty">Nội dung bài học sẽ được cập nhật sớm.</p></c:when><c:otherwise><ol class="cd-lessons"><c:forEach var="lessonTitle" items="${lessonTitles}" varStatus="item"><li><span class="cd-lesson-number"><fmt:formatNumber value="${item.count}" minIntegerDigits="2"/></span><span><c:out value="${lessonTitle}"/></span><span class="cd-lesson-label">Bài học</span></li></c:forEach></ol></c:otherwise></c:choose>
                </section>
            </div>
            <aside class="cd-enroll" aria-labelledby="enroll-heading">
                <div class="cd-enroll__top"><span aria-hidden="true">🎓</span><span>ĐĂNG KÝ KHÓA HỌC</span></div>
                <h2 id="enroll-heading">Bắt đầu học hôm nay</h2>
                <p class="cd-enroll__intro">Học theo lộ trình và truy cập nội dung ngay khi ghi danh thành công.</p>
                <div class="cd-price-block"><span>Học phí khóa học</span><strong><c:choose><c:when test="${course.free}">Miễn phí</c:when><c:otherwise><fmt:formatNumber value="${course.price}" type="number" maxFractionDigits="0" var="formattedPrice"/><c:out value="${fn:replace(formattedPrice, ',', '.')}"/> <c:out value="${course.currency}"/></c:otherwise></c:choose></strong></div>
                <c:choose>
                    <c:when test="${enrolled}"><p class="cd-enroll__notice">Bạn đã ghi danh khóa học này.</p><a class="hn-btn hn-btn--primary hn-btn--block cd-enroll__button" href="${pageContext.request.contextPath}/courses/${course.courseId}/learn">Vào học <span aria-hidden="true">→</span></a><a class="cd-secondary-link" href="${pageContext.request.contextPath}/my-courses">Xem khóa học của tôi</a></c:when>
                    <c:when test="${student}"><form method="post" action="${pageContext.request.contextPath}/courses/${course.courseId}/${course.free ? 'enroll' : 'checkout'}"><input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"><button class="hn-btn hn-btn--primary hn-btn--block cd-enroll__button" type="submit">${course.free ? 'Ghi danh miễn phí' : 'Đăng ký khóa học'} <span aria-hidden="true">→</span></button></form><c:if test="${not course.free}"><p class="cd-enroll__hint">Bạn sẽ được chuyển sang PayOS. Quyền học mở sau khi thanh toán được xác nhận.</p></c:if></c:when>
                    <c:otherwise><sec:authorize access="isAnonymous()"><p class="cd-enroll__hint">Đăng nhập bằng tài khoản học viên để tiếp tục.</p><a class="hn-btn hn-btn--primary hn-btn--block cd-enroll__button" href="${pageContext.request.contextPath}/login?courseId=${course.courseId}">Đăng nhập để ghi danh <span aria-hidden="true">→</span></a></sec:authorize><sec:authorize access="isAuthenticated()"><p class="cd-enroll__hint">Chỉ tài khoản học viên mới có thể ghi danh khóa học.</p></sec:authorize></c:otherwise>
                </c:choose>
                <div class="cd-enroll__foot"><span aria-hidden="true">✓</span> Học trên EduSphere theo tiến độ của bạn</div>
            </aside>
        </div>
    </div>
</main>
<footer class="cd-footer"><div class="hn-container"><strong>EduSphere</strong><span>Học tập theo cách của bạn.</span><a href="${pageContext.request.contextPath}/courses">Khám phá khóa học</a></div></footer>
</body>
</html>
