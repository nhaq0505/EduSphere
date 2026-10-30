<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý bài tập — EduSphere</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/home.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/instructor.css">
</head>
<body>
<jsp:include page="/WEB-INF/views/courses/ins-header.jsp"/>
<div class="ins-shell">
    <jsp:include page="/WEB-INF/views/courses/ins-sidebar.jsp"/>
    <main class="ins-content">

        <div class="ins-page-head">
            <div>
                <span class="ins-page-head__eyebrow">📝 Bài tập</span>
                <h1 class="ins-page-head__title">Quản lý bài tập</h1>
            </div>
            <a class="ins-btn-primary" style="width:auto;padding:10px 22px"
               href="${pageContext.request.contextPath}/instructor/courses/${courseId}/assignments/new">
                + Thêm bài tập
            </a>
        </div>

        <c:if test="${not empty success}"><div class="ins-alert ins-alert--success">✅ <c:out value="${success}"/></div></c:if>
        <c:if test="${not empty error}"><div class="ins-alert ins-alert--danger">❌ <c:out value="${error}"/></div></c:if>

        <c:choose>
            <c:when test="${empty assignments}">
                <div class="ins-empty">
                    <div class="ins-empty__icon">📋</div>
                    <h3>Chưa có bài tập nào</h3>
                    <p>Tạo bài tập để giao cho học viên trong khóa học này.</p>
                    <a class="ins-btn-primary" style="width:auto;padding:11px 28px;margin:0 auto"
                       href="${pageContext.request.contextPath}/instructor/courses/${courseId}/assignments/new">
                        + Tạo bài tập đầu tiên
                    </a>
                </div>
            </c:when>
            <c:otherwise>
                <div class="ins-lesson-list">
                    <c:forEach var="a" items="${assignments}">
                        <div class="ins-lesson-item">
                            <div class="ins-lesson-item__info">
                                <div class="ins-lesson-item__title"><c:out value="${a.title}"/></div>
                                <div class="ins-lesson-item__status">
                                    <c:choose>
                                        <c:when test="${a.status eq 'PUBLISHED'}"><span class="ins-pill-published">✅ Đã công bố</span></c:when>
                                        <c:when test="${a.status eq 'ARCHIVED'}"><span class="ins-pill-draft" style="background:#e5e7eb;color:#6b7280">📦 Lưu trữ</span></c:when>
                                        <c:otherwise><span class="ins-pill-draft">📝 Bản nháp</span></c:otherwise>
                                    </c:choose>
                                    &nbsp;|&nbsp; Điểm tối đa: <strong><fmt:formatNumber value="${a.maxScore}" maxFractionDigits="1"/></strong>
                                    &nbsp;|&nbsp; Bài nộp: <strong>${a.submissionCount}</strong>
                                    <c:if test="${a.dueDate != null}">
                                        &nbsp;|&nbsp; Hạn: ${fn:replace(fn:substring(a.dueDate, 0, 16), 'T', ' ')}
                                    </c:if>
                                </div>
                            </div>
                            <div class="ins-lesson-item__actions">
                                <a class="ins-link-btn ins-link-btn--primary"
                                   href="${pageContext.request.contextPath}/instructor/courses/${courseId}/assignments/${a.assignmentId}/submissions">
                                    Bài nộp
                                </a>
                                <a class="ins-link-btn"
                                   href="${pageContext.request.contextPath}/instructor/courses/${courseId}/assignments/${a.assignmentId}/edit">
                                    ✏️ Sửa
                                </a>
                                <c:if test="${a.status eq 'DRAFT'}">
                                    <form method="post" style="display:inline"
                                          action="${pageContext.request.contextPath}/instructor/courses/${courseId}/assignments/${a.assignmentId}/publish">
                                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                                        <button type="submit" class="ins-link-btn ins-link-btn--success">🚀 Công bố</button>
                                    </form>
                                </c:if>
                                <c:if test="${a.status eq 'PUBLISHED'}">
                                    <form method="post" style="display:inline"
                                          action="${pageContext.request.contextPath}/instructor/courses/${courseId}/assignments/${a.assignmentId}/archive">
                                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                                        <button type="submit" class="ins-link-btn">📦 Lưu trữ</button>
                                    </form>
                                </c:if>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </c:otherwise>
        </c:choose>

    </main>
</div>
<script>
function toggleUserMenu(e){e.stopPropagation();e.currentTarget.closest('.hn-user-menu').classList.toggle('open');}
document.addEventListener('click',()=>document.querySelectorAll('.hn-user-menu.open').forEach(m=>m.classList.remove('open')));
</script>
</body></html>
