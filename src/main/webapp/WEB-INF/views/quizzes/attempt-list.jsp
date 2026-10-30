<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Bài làm quiz — EduSphere</title>
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
        <a class="ins-back-link" href="${pageContext.request.contextPath}/instructor/courses/${courseId}/quizzes/${quizId}">← Chi tiết quiz</a>
        <div class="ins-page-head">
            <div>
                <span class="ins-page-head__eyebrow">❓ Bài làm</span>
                <h1 class="ins-page-head__title"><c:out value="${quiz.title}"/></h1>
            </div>
        </div>

        <c:choose>
            <c:when test="${empty attempts}">
                <div class="ins-empty"><div class="ins-empty__icon">📋</div><h3>Chưa có bài làm nào</h3></div>
            </c:when>
            <c:otherwise>
                <table style="width:100%;border-collapse:collapse;background:#fff;border-radius:10px;overflow:hidden">
                    <thead><tr style="background:#f3f4f6;text-align:left">
                        <th style="padding:10px 14px">Học viên</th><th style="padding:10px 14px">Lần</th>
                        <th style="padding:10px 14px">Nộp lúc</th><th style="padding:10px 14px">Điểm</th>
                        <th style="padding:10px 14px">Trạng thái</th><th style="padding:10px 14px"></th>
                    </tr></thead>
                    <tbody>
                    <c:forEach var="a" items="${attempts}">
                        <tr style="border-top:1px solid #e5e7eb">
                            <td style="padding:10px 14px"><c:out value="${a.studentName}"/></td>
                            <td style="padding:10px 14px">${a.attemptNumber}</td>
                            <td style="padding:10px 14px"><c:if test="${a.submittedAt != null}">${fn:replace(fn:substring(a.submittedAt, 0, 16), 'T', ' ')}</c:if></td>
                            <td style="padding:10px 14px"><c:choose><c:when test="${a.score != null}"><fmt:formatNumber value="${a.score}" maxFractionDigits="2"/> / <fmt:formatNumber value="${a.maxScore}" maxFractionDigits="2"/></c:when><c:otherwise>—</c:otherwise></c:choose></td>
                            <td style="padding:10px 14px">${a.status} · ${a.resultStatus eq 'PUBLISHED' ? 'Đã công bố' : 'Chưa công bố'}</td>
                            <td style="padding:10px 14px">
                                <a class="ins-link-btn ins-link-btn--primary"
                                   href="${pageContext.request.contextPath}/instructor/courses/${courseId}/quizzes/${quizId}/attempts/${a.attemptId}">Xem / chấm</a>
                            </td>
                        </tr>
                    </c:forEach>
                    </tbody>
                </table>
            </c:otherwise>
        </c:choose>
    </main>
</div>
<script>
function toggleUserMenu(e){e.stopPropagation();e.currentTarget.closest('.hn-user-menu').classList.toggle('open');}
document.addEventListener('click',()=>document.querySelectorAll('.hn-user-menu.open').forEach(m=>m.classList.remove('open')));
</script>
</body></html>
