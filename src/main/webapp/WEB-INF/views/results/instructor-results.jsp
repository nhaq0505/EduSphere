<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Công bố kết quả — EduSphere</title>
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
        <a class="ins-back-link" href="${pageContext.request.contextPath}/instructor/courses/${courseId}/lessons">← Quản lý bài học</a>
        <div class="ins-page-head">
            <div>
                <span class="ins-page-head__eyebrow">📊 Kết quả học tập</span>
                <h1 class="ins-page-head__title">Công bố kết quả</h1>
                <p class="ins-page-head__sub"><c:out value="${course.title}"/></p>
            </div>
            <form method="post" action="${pageContext.request.contextPath}/instructor/courses/${courseId}/results/publish-all"
                  onsubmit="return confirm('Công bố tất cả kết quả đã chấm xong?')">
                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                <button type="submit" class="ins-btn-primary" style="width:auto;padding:10px 22px">🚀 Công bố tất cả đã chấm</button>
            </form>
        </div>

        <c:if test="${not empty success}"><div class="ins-alert ins-alert--success">✅ <c:out value="${success}"/></div></c:if>

        <c:choose>
            <c:when test="${empty rows}">
                <div class="ins-empty"><div class="ins-empty__icon">📊</div><h3>Chưa có bài nộp hay bài làm nào</h3></div>
            </c:when>
            <c:otherwise>
                <table style="width:100%;border-collapse:collapse;background:#fff;border-radius:10px;overflow:hidden">
                    <thead><tr style="background:#f3f4f6;text-align:left">
                        <th style="padding:10px 14px">Loại</th><th style="padding:10px 14px">Nội dung</th>
                        <th style="padding:10px 14px">Học viên</th><th style="padding:10px 14px">Lần</th>
                        <th style="padding:10px 14px">Điểm</th><th style="padding:10px 14px">Trạng thái</th>
                        <th style="padding:10px 14px"></th>
                    </tr></thead>
                    <tbody>
                    <c:forEach var="r" items="${rows}">
                        <tr style="border-top:1px solid #e5e7eb">
                            <td style="padding:10px 14px">${r.kind eq 'QUIZ' ? '❓ Quiz' : '📝 Bài tập'}</td>
                            <td style="padding:10px 14px"><c:out value="${r.title}"/></td>
                            <td style="padding:10px 14px"><c:out value="${r.studentName}"/></td>
                            <td style="padding:10px 14px">${r.attemptNumber}</td>
                            <td style="padding:10px 14px"><c:choose><c:when test="${r.score != null}"><fmt:formatNumber value="${r.score}" maxFractionDigits="2"/> / <fmt:formatNumber value="${r.maxScore}" maxFractionDigits="2"/></c:when><c:otherwise>—</c:otherwise></c:choose></td>
                            <td style="padding:10px 14px">
                                <c:choose>
                                    <c:when test="${r.state eq 'PUBLISHED'}"><span class="ins-pill-published">✅ Đã công bố</span></c:when>
                                    <c:when test="${r.state eq 'READY'}"><span class="ins-pill-draft">Sẵn sàng công bố</span></c:when>
                                    <c:otherwise><span class="ins-pill-draft" style="background:#fee2e2;color:#b91c1c">Chưa chấm xong</span></c:otherwise>
                                </c:choose>
                            </td>
                            <td style="padding:10px 14px">
                                <c:choose>
                                    <c:when test="${r.state eq 'READY' && r.kind eq 'QUIZ'}">
                                        <form method="post" style="display:inline" action="${pageContext.request.contextPath}/instructor/courses/${courseId}/results/quizzes/${r.parentId}/attempts/${r.refId}/publish">
                                            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                                            <button type="submit" class="ins-link-btn ins-link-btn--success">Công bố</button>
                                        </form>
                                    </c:when>
                                    <c:when test="${r.state eq 'READY'}">
                                        <form method="post" style="display:inline" action="${pageContext.request.contextPath}/instructor/courses/${courseId}/results/assignments/${r.parentId}/submissions/${r.refId}/publish">
                                            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                                            <button type="submit" class="ins-link-btn ins-link-btn--success">Công bố</button>
                                        </form>
                                    </c:when>
                                    <c:when test="${r.state eq 'NOT_GRADED' && r.kind eq 'QUIZ'}">
                                        <a class="ins-link-btn ins-link-btn--primary" href="${pageContext.request.contextPath}/instructor/courses/${courseId}/quizzes/${r.parentId}/attempts/${r.refId}">Chấm</a>
                                    </c:when>
                                    <c:when test="${r.state eq 'NOT_GRADED'}">
                                        <a class="ins-link-btn ins-link-btn--primary" href="${pageContext.request.contextPath}/instructor/courses/${courseId}/assignments/${r.parentId}/submissions/${r.refId}/grade">Chấm</a>
                                    </c:when>
                                </c:choose>
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
