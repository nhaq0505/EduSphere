<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Khám phá khóa học — EduSphere</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/home.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/courses.css">
</head>
<body>

<!-- ══════ NAVBAR ══════ -->
<jsp:include page="/WEB-INF/views/common/navbar.jsp"/>

<!-- ══════ PAGE BODY ══════ -->
<main class="cl-main">
    <div class="hn-container">

        <!-- ── Tiêu đề trang ── -->
        <div class="cl-page-head">
            <div>
                <h1 class="cl-page-head__title">Khám phá khóa học</h1>
                <p class="cl-page-head__sub">Tìm nội dung phù hợp với sở thích, trình độ và ngân sách của bạn.</p>
            </div>
            <span class="cl-result-count">
                <fmt:formatNumber value="${coursePage.totalElements}" type="number"/> kết quả
            </span>
        </div>

        <!-- ── Khung filter: tabs + search + bộ lọc ── -->
        <div class="cl-filter-wrapper">

            <!-- Category tabs -->
            <div class="cl-tabs">
                <a class="cl-tab ${empty categoryId ? 'cl-tab--active' : ''}"
                   href="${pageContext.request.contextPath}/courses?q=${q}&level=${level}&priceFilter=${priceFilter}">
                    Tất cả
                </a>
                <c:forEach var="cat" items="${categories}">
                    <a class="cl-tab ${categoryId == cat.categoryId ? 'cl-tab--active' : ''}"
                       href="${pageContext.request.contextPath}/courses?q=${q}&categoryId=${cat.categoryId}&level=${level}&priceFilter=${priceFilter}">
                        <c:out value="${cat.name}"/>
                    </a>
                </c:forEach>
            </div>

            <!-- Divider -->
            <div class="cl-filter-divider"></div>

            <!-- Bộ lọc + search -->
            <form class="cl-filter-bar" method="get" action="${pageContext.request.contextPath}/courses">
                <div class="cl-filter-bar__left">
                    <span class="cl-filter-bar__label">
                        <svg width="14" height="14" viewBox="0 0 24 24" fill="none">
                            <path d="M4 6h16M7 12h10M10 18h4" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
                        </svg>
                        Bộ lọc
                    </span>
                    <select class="cl-select" name="level" onchange="this.form.submit()">
                        <option value="">Trình độ</option>
                        <option value="BEGINNER"     ${level == 'BEGINNER'     ? 'selected' : ''}>Cơ bản</option>
                        <option value="INTERMEDIATE" ${level == 'INTERMEDIATE' ? 'selected' : ''}>Trung cấp</option>
                        <option value="ADVANCED"     ${level == 'ADVANCED'     ? 'selected' : ''}>Nâng cao</option>
                        <option value="ALL_LEVELS"   ${level == 'ALL_LEVELS'   ? 'selected' : ''}>Mọi trình độ</option>
                    </select>
                    <select class="cl-select" name="priceFilter" onchange="this.form.submit()">
                        <option value="">Học phí</option>
                        <option value="FREE" ${priceFilter == 'FREE' ? 'selected' : ''}>Miễn phí</option>
                        <option value="PAID" ${priceFilter == 'PAID' ? 'selected' : ''}>Có phí</option>
                    </select>
                    <input type="hidden" name="q"          value="${q}">
                    <input type="hidden" name="categoryId" value="${categoryId}">
                </div>
                <div class="cl-filter-bar__right">
                    <div class="cl-search-wrap">
                        <input class="cl-search-input" type="text" name="q"
                               placeholder="Tìm kiếm khóa học..."
                               value="${q}">
                        <button class="cl-search-btn" type="submit" aria-label="Tìm kiếm">
                            <svg width="16" height="16" viewBox="0 0 20 20" fill="none">
                                <circle cx="9" cy="9" r="6" stroke="white" stroke-width="2"/>
                                <path d="M14 14l3 3" stroke="white" stroke-width="2" stroke-linecap="round"/>
                            </svg>
                        </button>
                    </div>
                </div>
            </form>

        </div><!-- /cl-filter-wrapper -->

        <!-- ── Course grid ── -->
        <c:choose>
            <c:when test="${empty coursePage.content}">
                <div class="cl-empty">
                    <div class="cl-empty__icon">🔍</div>
                    <h3>Chưa tìm thấy khóa học phù hợp</h3>
                    <p>Thử một từ khóa khác hoặc xóa bộ lọc để xem tất cả khóa học.</p>
                    <a class="hn-btn hn-btn--primary" href="${pageContext.request.contextPath}/courses">Xóa bộ lọc</a>
                </div>
            </c:when>
            <c:otherwise>
                <div class="cl-grid">
                    <c:forEach var="course" items="${coursePage.content}">
                        <c:url var="detailUrl" value="/courses/${course.courseId}"/>
                        <article class="cl-card">
                            <!-- Thumbnail -->
                            <div class="cl-card__thumb">
                                <c:choose>
                                    <c:when test="${not empty course.thumbnailUrl}">
                                        <c:choose>
                                            <c:when test="${fn:startsWith(course.thumbnailUrl, 'http://') or fn:startsWith(course.thumbnailUrl, 'https://') or fn:startsWith(course.thumbnailUrl, pageContext.request.contextPath)}">
                                                <img src="<c:out value='${course.thumbnailUrl}'/>" alt="<c:out value='${course.title}'/>" class="cl-card__img">
                                            </c:when>
                                            <c:otherwise>
                                                <img src="${pageContext.request.contextPath}<c:out value='${course.thumbnailUrl}'/>" alt="<c:out value='${course.title}'/>" class="cl-card__img">
                                            </c:otherwise>
                                        </c:choose>
                                    </c:when>
                                    <c:otherwise>
                                        <div class="cl-card__thumb-placeholder">
                                            <span>📚</span>
                                        </div>
                                    </c:otherwise>
                                </c:choose>
                                <span class="cl-card__level-badge">
                                    <c:out value="${course.levelLabel}"/>
                                </span>
                            </div>

                            <!-- Body -->
                            <div class="cl-card__body">
                                <c:if test="${not empty course.categoryName}">
                                    <span class="cl-card__cat"><c:out value="${course.categoryName}"/></span>
                                </c:if>
                                <h3 class="cl-card__title">
                                    <a href="${detailUrl}"><c:out value="${course.title}"/></a>
                                </h3>
                                <p class="cl-card__instructor">
                                    👤 <c:out value="${course.instructorName}"/>
                                </p>
                                <div style="display:flex; align-items:center; gap:5px; font-size:.78rem; margin:4px 0 8px; color:#64748B; font-weight:600;">
                                    <c:choose>
                                        <c:when test="${course.ratingCount > 0}">
                                            <span style="color:#F59E0B;">★</span>
                                            <strong style="color:#0F172A;">${course.averageRating}</strong>
                                            <span>(${course.ratingCount} đánh giá)</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span style="color:#CBD5E1;">★</span>
                                            <span>Chưa có đánh giá</span>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                                <div class="cl-card__footer">
                                    <span class="cl-card__price ${course.free ? 'cl-card__price--free' : ''}">
                                        <c:choose>
                                            <c:when test="${course.free}">Miễn phí</c:when>
                                            <c:otherwise>
                                                <fmt:formatNumber value="${course.price}" type="number" maxFractionDigits="0"/>đ
                                            </c:otherwise>
                                        </c:choose>
                                    </span>
                                    <a class="cl-card__arrow" href="${detailUrl}">→</a>
                                </div>
                            </div>
                        </article>
                    </c:forEach>
                </div>
            </c:otherwise>
        </c:choose>

        <!-- ── Phân trang ── -->
        <c:if test="${coursePage.totalPages > 1}">
            <nav class="cl-pagination" aria-label="Phân trang">
                <c:if test="${coursePage.number > 0}">
                    <c:url var="prevUrl" value="/courses">
                        <c:param name="q"           value="${q}"/>
                        <c:param name="categoryId"  value="${categoryId}"/>
                        <c:param name="level"       value="${level}"/>
                        <c:param name="priceFilter" value="${priceFilter}"/>
                        <c:param name="page"        value="${coursePage.number - 1}"/>
                    </c:url>
                    <a class="cl-page-btn" href="${prevUrl}">← Trang trước</a>
                </c:if>

                <span class="cl-page-info">
                    Trang ${coursePage.number + 1} / ${coursePage.totalPages}
                </span>

                <c:if test="${coursePage.number + 1 < coursePage.totalPages}">
                    <c:url var="nextUrl" value="/courses">
                        <c:param name="q"           value="${q}"/>
                        <c:param name="categoryId"  value="${categoryId}"/>
                        <c:param name="level"       value="${level}"/>
                        <c:param name="priceFilter" value="${priceFilter}"/>
                        <c:param name="page"        value="${coursePage.number + 1}"/>
                    </c:url>
                    <a class="cl-page-btn" href="${nextUrl}">Trang sau →</a>
                </c:if>
            </nav>
        </c:if>

    </div>
</main>

<!-- ══════ FOOTER ══════ -->
<footer class="hn-footer">
    <div class="hn-footer__inner">
        <div class="hn-footer__brand">
            <a class="hn-logo" href="${pageContext.request.contextPath}/">
                <div class="hn-logo__icon">🎓</div>
                <span>EduSphere</span>
            </a>
            <p>Nền tảng học tập trực tuyến chất lượng cao dành cho mọi người.</p>
        </div>
        <div class="hn-footer__col">
            <h4>Khóa học</h4>
            <a href="${pageContext.request.contextPath}/courses">Tất cả khóa học</a>
            <a href="${pageContext.request.contextPath}/courses?level=BEGINNER">Dành cho người mới</a>
            <a href="${pageContext.request.contextPath}/courses?priceFilter=FREE">Miễn phí</a>
        </div>
        <div class="hn-footer__col">
            <h4>Tài khoản</h4>
            <a href="${pageContext.request.contextPath}/register">Đăng ký</a>
            <a href="${pageContext.request.contextPath}/login">Đăng nhập</a>
            <a href="${pageContext.request.contextPath}/profile">Hồ sơ</a>
        </div>
        <div class="hn-footer__col">
            <h4>Liên hệ</h4>
            <span>📧 support@edusphere.vn</span>
            <span>📞 1800-1234</span>
        </div>
    </div>
    <div class="hn-footer__bottom">
        <p>© 2026 EduSphere. Bản quyền thuộc về EduSphere.</p>
    </div>
</footer>

</body>
</html>
