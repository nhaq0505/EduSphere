<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Danh sách bài nộp — EduSphere</title>
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
        <a class="ins-back-link" href="${pageContext.request.contextPath}/instructor/courses/${courseId}/assignments">
            ← Bài tập: <c:out value="${assignment.title}"/>
        </a>
        <div class="ins-page-head">
            <div>
                <span class="ins-page-head__eyebrow">📬 Bài nộp</span>
                <h1 class="ins-page-head__title">Danh sách bài nộp</h1>
                <p class="ins-page-head__sub"><c:out value="${assignment.title}"/></p>
            </div>
        </div>

        <c:if test="${not empty success}"><div class="ins-alert ins-alert--success">✅ <c:out value="${success}"/></div></c:if>

        <c:choose>
            <c:when test="${empty submissions}">
                <div class="ins-empty">
                    <div class="ins-empty__icon">📭</div>
                    <h3>Chưa có bài nộp nào</h3>
                    <p>Học viên chưa nộp bài tập này.</p>
                </div>
            </c:when>
            <c:otherwise>
                <div style="overflow-x:auto">
                    <table style="width:100%;border-collapse:collapse;font-size:14px">
                        <thead>
                        <tr style="background:#f3f4f6;text-align:left">
                            <th style="padding:10px 14px;border-bottom:1px solid #e5e7eb">Học viên</th>
                            <th style="padding:10px 14px;border-bottom:1px solid #e5e7eb">Lần nộp</th>
                            <th style="padding:10px 14px;border-bottom:1px solid #e5e7eb">Thời gian</th>
                            <th style="padding:10px 14px;border-bottom:1px solid #e5e7eb">Trạng thái</th>
                            <th style="padding:10px 14px;border-bottom:1px solid #e5e7eb">Điểm</th>
                            <th style="padding:10px 14px;border-bottom:1px solid #e5e7eb">Thao tác</th>
                        </tr>
                        </thead>
                        <tbody>
                        <c:forEach var="sub" items="${submissions}">
                            <tr style="border-bottom:1px solid #f3f4f6">
                                <td style="padding:10px 14px"><c:out value="${sub.student.fullName}"/></td>
                                <td style="padding:10px 14px">#<c:out value="${sub.attemptNumber}"/>
                                    <c:if test="${sub.late}"> <span style="color:#ef4444;font-size:12px">⚠️ Trễ hạn</span></c:if>
                                </td>
                                <td style="padding:10px 14px">${fn:replace(fn:substring(sub.submittedAt, 0, 16), 'T', ' ')}</td>
                                <td style="padding:10px 14px">
                                    <c:choose>
                                        <c:when test="${sub.status eq 'GRADED'}"><span style="color:#16a34a;font-weight:600">✅ Đã chấm</span></c:when>
                                        <c:otherwise><span style="color:#f59e0b;font-weight:600">⏳ Chờ chấm</span></c:otherwise>
                                    </c:choose>
                                </td>
                                <td style="padding:10px 14px">—</td>
                                <td style="padding:10px 14px">
                                    <a class="ins-link-btn ins-link-btn--primary"
                                       href="${pageContext.request.contextPath}/instructor/courses/${courseId}/assignments/${assignmentId}/submissions/${sub.submissionId}/grade">
                                        Chấm điểm
                                    </a>
                                </td>
                            </tr>
                        </c:forEach>
                        </tbody>
                    </table>
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
