<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Thêm câu hỏi — EduSphere</title>
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
                <span class="ins-page-head__eyebrow">❓ Quiz</span>
                <h1 class="ins-page-head__title">Thêm câu hỏi</h1>
            </div>
        </div>

        <div class="ins-form-card" style="max-width:700px">
            <form method="post" action="${pageContext.request.contextPath}/instructor/courses/${courseId}/quizzes/${quizId}/questions">
                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>

                <div class="ins-field">
                    <label class="ins-label" for="content">Nội dung câu hỏi <span style="color:red">*</span></label>
                    <textarea class="ins-input" id="content" name="content" rows="3" required style="resize:vertical"><c:out value="${questionForm.content}"/></textarea>
                </div>

                <div class="ins-field">
                    <label class="ins-label" for="type">Loại câu hỏi</label>
                    <select class="ins-input" id="type" name="type" onchange="syncType()">
                        <option value="SINGLE_CHOICE" ${questionForm.type eq 'SINGLE_CHOICE' ? 'selected' : ''}>Một đáp án đúng</option>
                        <option value="MULTIPLE_CHOICE" ${questionForm.type eq 'MULTIPLE_CHOICE' ? 'selected' : ''}>Nhiều đáp án đúng</option>
                        <option value="TRUE_FALSE" ${questionForm.type eq 'TRUE_FALSE' ? 'selected' : ''}>Đúng / Sai</option>
                        <option value="SHORT_ANSWER" ${questionForm.type eq 'SHORT_ANSWER' ? 'selected' : ''}>Trả lời ngắn (chấm tay)</option>
                        <option value="ESSAY" ${questionForm.type eq 'ESSAY' ? 'selected' : ''}>Tự luận (chấm tay)</option>
                    </select>
                </div>

                <div class="ins-field">
                    <label class="ins-label" for="score">Điểm <span style="color:red">*</span></label>
                    <input class="ins-input" type="number" id="score" name="score" min="0.5" step="0.5" required
                           value="${questionForm.score != null ? questionForm.score : 1}">
                </div>

                <div id="optionsBox" class="ins-field">
                    <label class="ins-label">Các lựa chọn</label>
                    <c:forEach var="i" begin="0" end="5">
                        <div style="display:flex;gap:8px;margin-bottom:8px">
                            <input class="ins-input" type="text" name="optionContents" placeholder="Lựa chọn ${i + 1}" style="flex:1">
                            <select class="ins-input" name="optionCorrects" style="width:110px">
                                <option value="false">Sai</option>
                                <option value="true">Đúng</option>
                            </select>
                        </div>
                    </c:forEach>
                    <span class="small">Để trống các lựa chọn không dùng. Loại "Một đáp án đúng" chỉ nên chọn 1 "Đúng".</span>
                </div>

                <div id="tfBox" class="ins-field" style="display:none">
                    <label class="ins-label" for="tfAnswer">Đáp án đúng</label>
                    <select class="ins-input" id="tfAnswer" name="correctAnswer">
                        <option value="true">Đúng</option>
                        <option value="false">Sai</option>
                    </select>
                </div>

                <div id="shortBox" class="ins-field" style="display:none">
                    <label class="ins-label" for="shortAnswer">Đáp án tham khảo</label>
                    <input class="ins-input" type="text" id="shortAnswer" name="correctAnswer" value="<c:out value='${questionForm.correctAnswer}'/>">
                </div>

                <div class="ins-field">
                    <label class="ins-label" for="explanation">Giải thích (tuỳ chọn)</label>
                    <textarea class="ins-input" id="explanation" name="explanation" rows="2" style="resize:vertical"><c:out value="${questionForm.explanation}"/></textarea>
                </div>

                <div style="display:flex;gap:12px;margin-top:8px">
                    <button type="submit" class="ins-btn-primary" style="width:auto;padding:10px 28px">💾 Lưu câu hỏi</button>
                    <a href="${pageContext.request.contextPath}/instructor/courses/${courseId}/quizzes/${quizId}" class="ins-link-btn" style="padding:10px 20px">Hủy</a>
                </div>
            </form>
        </div>
    </main>
</div>
<script>
function syncType(){
    var t=document.getElementById('type').value;
    var choice=(t==='SINGLE_CHOICE'||t==='MULTIPLE_CHOICE');
    var box=document.getElementById('optionsBox');
    box.style.display=choice?'':'none';
    box.querySelectorAll('input,select').forEach(function(e){e.disabled=!choice;});
    var tf=document.getElementById('tfBox'), sh=document.getElementById('shortBox');
    tf.style.display=(t==='TRUE_FALSE')?'':'none';
    document.getElementById('tfAnswer').disabled=(t!=='TRUE_FALSE');
    sh.style.display=(t==='SHORT_ANSWER')?'':'none';
    document.getElementById('shortAnswer').disabled=(t!=='SHORT_ANSWER');
}
syncType();
function toggleUserMenu(e){e.stopPropagation();e.currentTarget.closest('.hn-user-menu').classList.toggle('open');}
document.addEventListener('click',()=>document.querySelectorAll('.hn-user-menu.open').forEach(m=>m.classList.remove('open')));
</script>
</body></html>
