<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chấm điểm — EduSphere</title>
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
        <a class="ins-back-link"
           href="${pageContext.request.contextPath}/instructor/courses/${courseId}/assignments/${assignmentId}/submissions">
            ← Danh sách bài nộp
        </a>
        <div class="ins-page-head">
            <div>
                <span class="ins-page-head__eyebrow">📊 Chấm điểm</span>
                <h1 class="ins-page-head__title">Chấm điểm bài nộp</h1>
                <p class="ins-page-head__sub">Học viên: <strong><c:out value="${submission.student.fullName}"/></strong> — Lần nộp #${submission.attemptNumber}</p>
            </div>
        </div>

        <%-- Hiển thị bài nộp --%>
        <div class="ins-form-card" style="max-width:720px;margin-bottom:24px">
            <h3 style="margin:0 0 12px;font-size:16px;color:#374151">📄 Nội dung bài nộp</h3>
            <c:if test="${not empty submission.answerText}">
                <div style="background:#f9fafb;border:1px solid #e5e7eb;border-radius:8px;padding:14px;white-space:pre-wrap;font-size:14px;line-height:1.6">
                    <c:out value="${submission.answerText}"/>
                </div>
            </c:if>
            <c:if test="${not empty submission.fileUrl}">
                <p style="margin-top:10px">📎 File đính kèm:
                    <a href="${submission.fileUrl}" target="_blank" style="color:#6366f1">
                        <c:out value="${submission.fileUrl}"/>
                    </a>
                </p>
            </c:if>
            <c:if test="${submission.late}">
                <p style="color:#ef4444;font-size:13px;margin-top:8px">⚠️ Bài nộp trễ hạn</p>
            </c:if>
        </div>

        <%-- Hiển thị điểm hiện tại (nếu có) --%>
        <c:if test="${existingGrade != null}">
            <div class="ins-alert ins-alert--warning" style="max-width:720px">
                ⚠️ Đã chấm điểm: <strong>${existingGrade.score} / ${existingGrade.maxScore}</strong>
                — Trạng thái: ${existingGrade.resultStatus eq 'PUBLISHED' ? '✅ Đã công bố' : '⏳ Chưa công bố'}
            </div>
        </c:if>

        <%-- Form chấm điểm --%>
        <div class="ins-form-card" style="max-width:560px">
            <h3 style="margin:0 0 16px;font-size:16px;color:#374151">✍️ Nhập điểm</h3>
            <form method="post"
                  action="${pageContext.request.contextPath}/instructor/courses/${courseId}/assignments/${assignmentId}/submissions/${submission.submissionId}/grade">
                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>

                <div class="ins-field">
                    <label class="ins-label" for="score">
                        Điểm số (tối đa: <fmt:formatNumber value="${assignment.maxScore}" maxFractionDigits="1"/>)
                        <span style="color:red">*</span>
                    </label>
                    <input class="ins-input" type="number" id="score" name="score" required
                           min="0" max="${assignment.maxScore}" step="0.5"
                           value="${existingGrade != null ? existingGrade.score : ''}">
                </div>

                <div class="ins-field">
                    <label class="ins-label" for="feedback">Nhận xét</label>
                    <textarea class="ins-input" id="feedback" name="feedback" rows="4"
                              style="resize:vertical">${existingGrade != null ? existingGrade.feedback : ''}</textarea>
                </div>

                <div style="display:flex;gap:12px;margin-top:8px">
                    <button type="submit" class="ins-btn-primary" style="width:auto;padding:10px 24px">
                        💾 Lưu điểm
                    </button>
                </div>
            </form>
        </div>

        <%-- Publish grade --%>
        <c:if test="${existingGrade != null && existingGrade.resultStatus ne 'PUBLISHED'}">
            <div style="max-width:560px;margin-top:16px">
                <form method="post"
                      action="${pageContext.request.contextPath}/instructor/courses/${courseId}/assignments/${assignmentId}/submissions/${submission.submissionId}/publish-grade">
                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                    <button type="submit" class="ins-btn-primary"
                            style="width:auto;padding:10px 24px;background:#16a34a"
                            onclick="return confirm('Công bố kết quả cho học viên?')">
                        🚀 Công bố kết quả
                    </button>
                </form>
            </div>
        </c:if>
    </main>
</div>
<script>
function toggleUserMenu(e){e.stopPropagation();e.currentTarget.closest('.hn-user-menu').classList.toggle('open');}
document.addEventListener('click',()=>document.querySelectorAll('.hn-user-menu.open').forEach(m=>m.classList.remove('open')));
</script>
</body></html>
