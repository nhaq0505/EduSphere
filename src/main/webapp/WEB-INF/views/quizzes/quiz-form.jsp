<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tạo quiz — EduSphere</title>
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
        <a class="ins-back-link" href="${pageContext.request.contextPath}/instructor/courses/${courseId}/quizzes">← Danh sách quiz</a>
        <div class="ins-page-head">
            <div>
                <span class="ins-page-head__eyebrow">❓ Quiz</span>
                <h1 class="ins-page-head__title">Tạo quiz mới</h1>
            </div>
        </div>

        <div class="ins-form-card" style="max-width:640px">
            <form method="post" action="${pageContext.request.contextPath}/instructor/courses/${courseId}/quizzes">
                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>

                <div class="ins-field">
                    <label class="ins-label" for="title">Tiêu đề <span style="color:red">*</span></label>
                    <input class="ins-input" type="text" id="title" name="title" maxlength="255" required
                           value="<c:out value='${quizForm.title}'/>">
                    <c:if test="${not empty errors && errors.hasFieldErrors('title')}"><span class="ins-field-error"><c:out value="${errors.getFieldError('title').defaultMessage}"/></span></c:if>
                </div>

                <div class="ins-field">
                    <label class="ins-label" for="description">Mô tả</label>
                    <textarea class="ins-input" id="description" name="description" rows="3" style="resize:vertical"><c:out value="${quizForm.description}"/></textarea>
                </div>

                <div class="ins-field">
                    <label class="ins-label" for="timeLimitMinutes">Thời gian làm bài (phút, để trống nếu không giới hạn)</label>
                    <input class="ins-input" type="number" min="1" id="timeLimitMinutes" name="timeLimitMinutes" value="${quizForm.timeLimitMinutes}">
                </div>

                <div class="ins-field">
                    <label class="ins-label" for="maxAttempts">Số lần làm tối đa</label>
                    <input class="ins-input" type="number" min="1" id="maxAttempts" name="maxAttempts" value="${quizForm.maxAttempts != null ? quizForm.maxAttempts : 1}">
                </div>

                <div class="ins-field">
                    <label class="ins-label" for="startTime">Thời điểm mở</label>
                    <input class="ins-input" type="datetime-local" id="startTime" name="startTime" value="<c:out value='${quizForm.startTime}'/>">
                </div>
                <div class="ins-field">
                    <label class="ins-label" for="dueDate">Hạn làm bài</label>
                    <input class="ins-input" type="datetime-local" id="dueDate" name="dueDate" value="<c:out value='${quizForm.dueDate}'/>">
                </div>
                <div class="ins-field">
                    <label class="ins-label" for="endTime">Thời điểm đóng</label>
                    <input class="ins-input" type="datetime-local" id="endTime" name="endTime" value="<c:out value='${quizForm.endTime}'/>">
                </div>

                <div class="ins-field">
                    <label class="ins-label" for="rules">Quy định</label>
                    <textarea class="ins-input" id="rules" name="rules" rows="3" style="resize:vertical"><c:out value="${quizForm.rules}"/></textarea>
                </div>

                <div class="ins-field">
                    <label class="ins-label" for="lessonId">Gắn với bài học (tuỳ chọn)</label>
                    <input class="ins-input" type="number" id="lessonId" name="lessonId" value="${quizForm.lessonId}" placeholder="Nhập ID bài học (nếu có)">
                </div>

                <div style="display:flex;gap:12px;margin-top:8px">
                    <button type="submit" class="ins-btn-primary" style="width:auto;padding:10px 28px">💾 Lưu quiz</button>
                    <a href="${pageContext.request.contextPath}/instructor/courses/${courseId}/quizzes" class="ins-link-btn" style="padding:10px 20px">Hủy</a>
                </div>
            </form>
        </div>
    </main>
</div>
<script>
function toggleUserMenu(e){e.stopPropagation();e.currentTarget.closest('.hn-user-menu').classList.toggle('open');}
document.addEventListener('click',()=>document.querySelectorAll('.hn-user-menu.open').forEach(m=>m.classList.remove('open')));
</script>
</body></html>
