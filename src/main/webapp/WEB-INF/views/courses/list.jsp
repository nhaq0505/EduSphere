<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Khám phá khóa học — EduSphere</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/main.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/courses.css">
</head>
<body>
<nav class="navbar">
    <a href="${pageContext.request.contextPath}/" class="brand">EduSphere</a>
    <div class="nav-links">
        <a href="${pageContext.request.contextPath}/courses" aria-current="page">Khóa học</a>
        <sec:authorize access="isAnonymous()">
            <a href="${pageContext.request.contextPath}/login">Đăng nhập</a>
            <a href="${pageContext.request.contextPath}/register" class="btn btn-primary btn-small">Đăng ký</a>
        </sec:authorize>
        <sec:authorize access="isAuthenticated()">
            <a href="${pageContext.request.contextPath}/dashboard">Trang cá nhân</a>
        </sec:authorize>
    </div>
</nav>

<main class="course-container">
    <header class="course-header">
        <p class="course-eyebrow">EDUSPHERE</p>
        <h1>Khám phá khóa học</h1>
        <p>Chọn khóa học phù hợp với mục tiêu và trình độ của bạn.</p>
    </header>

    <form class="course-filters" method="get" action="${pageContext.request.contextPath}/courses" role="search">
        <div class="course-filter-search">
            <label for="q">Tên khóa học</label>
            <input id="q" name="q" type="search" maxlength="100" placeholder="Bạn muốn học gì?" value="<c:out value='${q}'/>">
        </div>
        <div>
            <label for="categoryId">Danh mục</label>
            <select id="categoryId" name="categoryId">
                <option value="">Tất cả</option>
                <c:forEach var="category" items="${categories}">
                    <option value="${category.categoryId}" ${categoryId == category.categoryId ? 'selected="selected"' : ''}><c:out value="${category.name}"/></option>
                </c:forEach>
            </select>
        </div>
        <div>
            <label for="level">Trình độ</label>
            <select id="level" name="level">
                <option value="">Tất cả</option>
                <option value="BEGINNER" ${level == 'BEGINNER' ? 'selected="selected"' : ''}>Cơ bản</option>
                <option value="INTERMEDIATE" ${level == 'INTERMEDIATE' ? 'selected="selected"' : ''}>Trung cấp</option>
                <option value="ADVANCED" ${level == 'ADVANCED' ? 'selected="selected"' : ''}>Nâng cao</option>
                <option value="ALL_LEVELS" ${level == 'ALL_LEVELS' ? 'selected="selected"' : ''}>Mọi trình độ</option>
            </select>
        </div>
        <div>
            <label for="priceFilter">Học phí</label>
            <select id="priceFilter" name="priceFilter">
                <option value="">Tất cả</option>
                <option value="FREE" ${priceFilter == 'FREE' ? 'selected="selected"' : ''}>Miễn phí</option>
                <option value="PAID" ${priceFilter == 'PAID' ? 'selected="selected"' : ''}>Trả phí</option>
            </select>
        </div>
        <button class="btn btn-primary" type="submit">Tìm khóa học</button>
    </form>

    <section aria-label="Kết quả tìm kiếm">
        <div class="course-results-heading">
            <h2>Khóa học đang mở</h2>
            <span><fmt:formatNumber value="${coursePage.totalElements}" type="number"/> kết quả</span>
        </div>

        <c:choose>
            <c:when test="${empty coursePage.content}">
                <div class="course-empty">
                    <h3>Chưa tìm thấy khóa học phù hợp</h3>
                    <p>Hãy thử từ khóa hoặc bộ lọc khác.</p>
                    <a href="${pageContext.request.contextPath}/courses" class="btn btn-secondary">Xóa bộ lọc</a>
                </div>
            </c:when>
            <c:otherwise>
                <div class="course-grid">
                    <c:forEach var="course" items="${coursePage.content}">
                        <c:url var="detailUrl" value="/courses/${course.courseId}"/>
                        <article class="course-card">
                            <div class="course-card-art" aria-hidden="true">EduSphere</div>
                            <div class="course-card-body">
                                <div class="course-tags">
                                    <span><c:out value="${course.categoryName}"/></span>
                                    <span><c:out value="${course.levelLabel}"/></span>
                                </div>
                                <h3><a href="${detailUrl}"><c:out value="${course.title}"/></a></h3>
                                <p class="course-summary"><c:out value="${course.summary}"/></p>
                                <p class="course-instructor">Giảng viên: <c:out value="${course.instructorName}"/></p>
                                <div class="course-card-footer">
                                    <strong>
                                        <c:choose>
                                            <c:when test="${course.free}">Miễn phí</c:when>
                                            <c:otherwise><fmt:formatNumber value="${course.price}" type="number" maxFractionDigits="0"/> <c:out value="${course.currency}"/></c:otherwise>
                                        </c:choose>
                                    </strong>
                                    <a href="${detailUrl}">Xem chi tiết →</a>
                                </div>
                            </div>
                        </article>
                    </c:forEach>
                </div>
            </c:otherwise>
        </c:choose>

        <c:if test="${coursePage.totalPages > 1}">
            <nav class="course-pagination" aria-label="Phân trang khóa học">
                <c:if test="${coursePage.number > 0}">
                    <c:url var="previousUrl" value="/courses">
                        <c:param name="q" value="${q}"/><c:param name="categoryId" value="${categoryId}"/>
                        <c:param name="level" value="${level}"/><c:param name="priceFilter" value="${priceFilter}"/>
                        <c:param name="page" value="${coursePage.number - 1}"/>
                    </c:url>
                    <a href="${previousUrl}">← Trang trước</a>
                </c:if>
                <span>Trang ${coursePage.number + 1} / ${coursePage.totalPages}</span>
                <c:if test="${coursePage.number + 1 < coursePage.totalPages}">
                    <c:url var="nextUrl" value="/courses">
                        <c:param name="q" value="${q}"/><c:param name="categoryId" value="${categoryId}"/>
                        <c:param name="level" value="${level}"/><c:param name="priceFilter" value="${priceFilter}"/>
                        <c:param name="page" value="${coursePage.number + 1}"/>
                    </c:url>
                    <a href="${nextUrl}">Trang sau →</a>
                </c:if>
            </nav>
        </c:if>
    </section>
</main>
</body>
</html>
