<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${pageTitle} — EduSphere</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/home.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/instructor.css">
</head>
<body>
<div class="ins-layout">
    <jsp:include page="../courses/ins-sidebar.jsp"/>
    <div class="ins-main-wrapper">
        <jsp:include page="../courses/ins-header.jsp"/>
        <main class="ins-page">
        <a class="ins-back-link" href="${pageContext.request.contextPath}/instructor/courses/${courseId}/assignments">
            ← Danh sách bài tập
        </a>
        <div class="ins-page-head">
            <div>
                <span class="ins-page-head__eyebrow">📝 Bài tập</span>
                <h1 class="ins-page-head__title">${pageTitle}</h1>
            </div>
        </div>

        <div class="ins-form-card" style="max-width:640px">
            <form method="post" action="${pageContext.request.contextPath}${formAction}">
                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>

                <div class="ins-field">
                    <label class="ins-label" for="title">Tiêu đề <span style="color:red">*</span></label>
                    <input class="ins-input" type="text" id="title" name="title"
                           value="<c:out value="${assignmentForm.title}"/>" required maxlength="255">
                    <c:if test="${not empty errors}">
                        <span class="ins-field-error">Tiêu đề không được để trống</span>
                    </c:if>
                </div>

                <div class="ins-field">
                    <label class="ins-label" for="description">Mô tả / Đề bài</label>
                    <textarea class="ins-input" id="description" name="description"
                              rows="5" style="resize:vertical"><c:out value="${assignmentForm.description}"/></textarea>
                </div>

                <div class="ins-field">
                    <label class="ins-label" for="dueDate">Hạn nộp bài</label>
                    <input class="ins-input" type="datetime-local" id="dueDate" name="dueDate"
                           value="<c:out value="${assignmentForm.dueDate}"/>">
                </div>

                <div class="ins-field">
                    <label class="ins-label" for="unlockAt">Mở khóa lúc</label>
                    <input class="ins-input" type="datetime-local" id="unlockAt" name="unlockAt"
                           value="<c:out value="${assignmentForm.unlockAt}"/>">
                </div>

                <div class="ins-field">
                    <label class="ins-label" for="lockAt">Khóa lúc</label>
                    <input class="ins-input" type="datetime-local" id="lockAt" name="lockAt"
                           value="<c:out value="${assignmentForm.lockAt}"/>">
                </div>

                <div class="ins-field">
                    <label class="ins-label" for="maxScore">Điểm tối đa <span style="color:red">*</span></label>
                    <input class="ins-input" type="number" id="maxScore" name="maxScore"
                           value="${assignmentForm.maxScore != null ? assignmentForm.maxScore : 100}"
                           min="0" step="0.5" required>
                </div>

                <div class="ins-field">
                    <label class="ins-label" for="maxAttempts">Số lần nộp tối đa</label>
                    <input class="ins-input" type="number" id="maxAttempts" name="maxAttempts"
                           value="${assignmentForm.maxAttempts != null ? assignmentForm.maxAttempts : 1}" min="1">
                </div>

                <div class="ins-field" style="display:flex;align-items:center;gap:10px">
                    <input type="checkbox" id="allowResubmit" name="allowResubmit"
                           ${assignmentForm.allowResubmit ? 'checked' : ''} style="width:18px;height:18px">
                    <label for="allowResubmit" style="margin:0">Cho phép nộp lại</label>
                </div>

                <div class="ins-field">
                    <label class="ins-label" for="lessonId">Gắn với bài học (tuỳ chọn)</label>
                    <input class="ins-input" type="number" id="lessonId" name="lessonId"
                           value="${assignmentForm.lessonId}" placeholder="Nhập ID bài học (nếu có)">
                </div>

                <div style="display:flex;gap:12px;margin-top:8px">
                    <button type="submit" class="ins-btn-primary" style="width:auto;padding:10px 28px">
                        💾 Lưu bài tập
                    </button>
                    <a href="${pageContext.request.contextPath}/instructor/courses/${courseId}/assignments"
                       class="ins-link-btn" style="padding:10px 20px">Hủy</a>
                </div>
            </form>
        </div>
        </main>
    </div>
</div>
<script>
function insToggleMenu(e) {
    e.stopPropagation();
    document.getElementById('insUserMenu').classList.toggle('open');
}
document.addEventListener('click', function() {
    var m = document.getElementById('insUserMenu');
    if (m) m.classList.remove('open');
});
</script>
</body></html>
