<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý bài học — EduSphere</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/instructor.css">
</head>
<body>
<div class="ins-layout">
    <jsp:include page="/WEB-INF/views/courses/ins-sidebar.jsp"/>
    <div class="ins-main-wrapper">
        <jsp:include page="/WEB-INF/views/courses/ins-header.jsp"/>
        <main class="ins-page">


            <div class="ins-page-head">
                <div>
                    <span class="ins-page-head__eyebrow">Bài học · Phiên bản v${course.versionNo}</span>
                    <h1 class="ins-page-head__title">Quản lý bài học</h1>
                    <p class="ins-page-head__sub"><c:out value="${course.title}"/></p>
                </div>
                <c:if test="${editable}">
                    <a class="ins-btn ins-btn--primary"
                       href="${pageContext.request.contextPath}/instructor/courses/${course.courseId}/lessons/new">
                        + Thêm bài học
                    </a>
                </c:if>
            </div>

            <c:if test="${not empty success}">
                <div class="ins-alert ins-alert--success">✅ <c:out value="${success}"/></div>
            </c:if>

            <c:if test="${course.status eq 'DRAFT'}">
                <div class="ins-alert ins-alert--warning" style="justify-content:space-between;align-items:center;gap:12px">
                    <div>
                        📝 <strong>Bản nháp (v${course.versionNo}):</strong>
                        Sau khi hoàn thiện, hãy về trang khóa học để gửi duyệt.
                    </div>
                    <a href="${pageContext.request.contextPath}/instructor/courses/${course.courseId}"
                       class="ins-btn ins-btn--outline ins-btn--sm" style="white-space:nowrap;">
                        Về trang khóa học →
                    </a>
                </div>
            </c:if>

            <c:if test="${not editable}">
                <div class="ins-alert ins-alert--warning">
                    ⚠️ Khóa học đang chờ duyệt hoặc đã lưu trữ — không thể thêm/sửa bài học.
                </div>
            </c:if>

            <c:choose>
                <c:when test="${empty lessons}">
                    <div class="ins-empty">
                        <span class="ins-empty__icon">📝</span>
                        <h3>Chưa có bài học nào</h3>
                        <p>Thêm bài học đầu tiên để học viên có nội dung khi khóa học được công bố.</p>
                        <c:if test="${editable}">
                            <a class="ins-btn ins-btn--primary" style="margin:0 auto"
                               href="${pageContext.request.contextPath}/instructor/courses/${course.courseId}/lessons/new">
                                + Thêm bài học đầu tiên
                            </a>
                        </c:if>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="ins-lesson-list">
                        <c:forEach var="lesson" items="${lessons}">
                            <div class="ins-lesson-item">
                                <div class="ins-lesson-num"><c:out value="${lesson.orderIndex}"/></div>
                                <div class="ins-lesson-item__info">
                                    <div class="ins-lesson-item__title"><c:out value="${lesson.title}"/></div>
                                    <div class="ins-lesson-item__status">
                                        <c:choose>
                                            <c:when test="${lesson.status eq 'PUBLISHED'}">
                                                <span class="ins-pill-published">✅ Học viên có thể xem</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="ins-pill-draft">📝 Bản nháp</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                </div>
                                <div class="ins-lesson-item__actions">
                                    <a class="ins-link-btn ins-link-btn--primary"
                                       href="${pageContext.request.contextPath}/instructor/courses/${course.courseId}/lessons/${lesson.lessonId}">
                                        Xem →
                                    </a>
                                    <c:if test="${editable}">
                                        <a class="ins-link-btn"
                                           href="${pageContext.request.contextPath}/instructor/courses/${course.courseId}/lessons/${lesson.lessonId}/edit">
                                            ✏️ Sửa
                                        </a>
                                    </c:if>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                </c:otherwise>
            </c:choose>

        </main>
    </div>
</div>
<script>
function insToggleMenu(e){e.stopPropagation();document.getElementById('insUserMenu').classList.toggle('open');}
document.addEventListener('click',function(){var m=document.getElementById('insUserMenu');if(m)m.classList.remove('open');});
</script>
</body></html>
