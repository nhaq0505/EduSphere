<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${not empty questionId ? 'Sửa' : 'Thêm'} câu hỏi — EduSphere</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/home.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/instructor.css">
    <style>
        .qf-type-grid { display:grid; grid-template-columns:repeat(5,1fr); gap:10px; margin-bottom:20px; }
        @media(max-width:640px){ .qf-type-grid{ grid-template-columns:1fr 1fr; } }
        .qf-type-card {
            border:2px solid #E2E8F0; border-radius:10px; padding:14px 10px;
            text-align:center; cursor:pointer; transition:all .15s;
            font-size:.82rem; font-weight:700; color:#475569; user-select:none;
        }
        .qf-type-card:hover { border-color:#7E22CE; background:#FAF5FF; color:#7E22CE; }
        .qf-type-card.selected { border-color:#7E22CE; background:#F3E8FF; color:#7E22CE; }
        .qf-type-card .icon { font-size:1.6rem; display:block; margin-bottom:6px; }
        .qf-option-row { display:flex; align-items:center; gap:8px; margin-bottom:8px; }
        .qf-option-row .ins-input { flex:1; }
        .qf-correct-btn {
            width:38px; height:38px; flex-shrink:0; border-radius:8px;
            border:2px solid #E2E8F0; background:#F8FAFC; cursor:pointer;
            display:flex; align-items:center; justify-content:center;
            font-weight:900; font-size:1rem; transition:all .15s;
        }
        .qf-correct-btn.active { background:#DCFCE7; border-color:#16A34A; color:#16A34A; }
        .qf-correct-btn:not(.active) { color:#94A3B8; }
        .qf-remove-btn {
            width:32px; height:32px; flex-shrink:0; border:none; background:none;
            cursor:pointer; color:#94A3B8; font-size:1.1rem; display:flex; align-items:center; justify-content:center;
        }
        .qf-remove-btn:hover { color:#DC2626; }
        .qf-hint { font-size:.78rem; color:#94A3B8; margin-top:4px; }
    </style>
</head>
<body>
<div class="ins-layout">
    <jsp:include page="../courses/ins-sidebar.jsp"/>
    <div class="ins-main-wrapper">
        <jsp:include page="../courses/ins-header.jsp"/>
        <main class="ins-page">
        <a class="ins-back-link" href="${pageContext.request.contextPath}/instructor/courses/${courseId}/quizzes/${quizId}">
            ← Quay lại Quiz Builder
        </a>

        <div class="ins-page-head">
            <div>
                <span class="ins-page-head__eyebrow">📝 Quiz</span>
                <h1 class="ins-page-head__title">
                    <c:choose>
                        <c:when test="${not empty questionId}">Chỉnh sửa câu hỏi</c:when>
                        <c:otherwise>Thêm câu hỏi mới</c:otherwise>
                    </c:choose>
                </h1>
            </div>
        </div>

        <div class="ins-form-card" style="max-width:760px">
            <form method="post"
                  action="${not empty questionId
                      ? pageContext.request.contextPath.concat('/instructor/courses/').concat(courseId).concat('/quizzes/').concat(quizId).concat('/questions/').concat(questionId).concat('/edit')
                      : pageContext.request.contextPath.concat('/instructor/courses/').concat(courseId).concat('/quizzes/').concat(quizId).concat('/questions')}">
                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>

                <!-- Step 1: Question type -->
                <div class="ins-field">
                    <label class="ins-label" style="margin-bottom:10px;">
                        Loại câu hỏi <span style="color:red">*</span>
                    </label>
                    <div class="qf-type-grid">
                        <div class="qf-type-card ${empty questionForm.type or questionForm.type eq 'SINGLE_CHOICE' ? 'selected' : ''}"
                             onclick="qfSelectType('SINGLE_CHOICE', this)">
                            <span class="icon">🔘</span>Một lựa chọn
                        </div>
                        <div class="qf-type-card ${questionForm.type eq 'MULTIPLE_CHOICE' ? 'selected' : ''}"
                             onclick="qfSelectType('MULTIPLE_CHOICE', this)">
                            <span class="icon">☑️</span>Nhiều lựa chọn
                        </div>
                        <div class="qf-type-card ${questionForm.type eq 'TRUE_FALSE' ? 'selected' : ''}"
                             onclick="qfSelectType('TRUE_FALSE', this)">
                            <span class="icon">⚖️</span>Đúng / Sai
                        </div>
                        <div class="qf-type-card ${questionForm.type eq 'SHORT_ANSWER' ? 'selected' : ''}"
                             onclick="qfSelectType('SHORT_ANSWER', this)">
                            <span class="icon">✍️</span>Trả lời ngắn
                        </div>
                        <div class="qf-type-card ${questionForm.type eq 'ESSAY' ? 'selected' : ''}"
                             onclick="qfSelectType('ESSAY', this)">
                            <span class="icon">📝</span>Tự luận
                        </div>
                    </div>
                    <input type="hidden" name="type" id="typeInput"
                           value="${not empty questionForm.type ? questionForm.type : 'SINGLE_CHOICE'}"/>
                </div>

                <!-- Step 2: Content & score side by side -->
                <div style="display:grid; grid-template-columns:1fr 180px; gap:16px; align-items:start;">
                    <div class="ins-field" style="margin:0;">
                        <label class="ins-label" for="content">
                            Nội dung câu hỏi <span style="color:red">*</span>
                        </label>
                        <textarea class="ins-input" id="content" name="content" rows="4" required
                                  style="resize:vertical;" placeholder="Nhập nội dung câu hỏi..."><c:out value="${questionForm.content}"/></textarea>
                    </div>
                    <div class="ins-field" style="margin:0;">
                        <label class="ins-label" for="score">Điểm <span style="color:red">*</span></label>
                        <input class="ins-input" type="number" id="score" name="score"
                               min="0.5" step="0.5" required
                               value="${questionForm.score != null ? questionForm.score : 1}">
                        <p class="qf-hint">VD: 1, 2, 3...</p>
                    </div>
                </div>

                <!-- Step 3: Answer options (SINGLE / MULTIPLE) -->
                <div id="optionsBox" class="ins-field" style="margin-top:16px;">
                    <label class="ins-label" style="margin-bottom:8px;">
                        Các lựa chọn đáp án
                        <span style="font-weight:400; color:#94A3B8; font-size:.8rem;">
                            — nhấn <strong style="color:#16A34A;">✓</strong> để đánh dấu đáp án đúng
                        </span>
                    </label>
                    <div id="optionRows">
                        <c:choose>
                            <c:when test="${not empty questionForm.optionContents}">
                                <c:forEach var="oc" items="${questionForm.optionContents}" varStatus="os">
                                    <div class="qf-option-row">
                                        <input class="ins-input" type="text" name="optionContents"
                                               value="<c:out value='${oc}'/>"
                                               placeholder="Lựa chọn ${os.index + 1}">
                                        <input type="hidden" name="optionCorrects" id="qfcorr_${os.index}"
                                               value="${questionForm.optionCorrects[os.index] ? 'true' : 'false'}"/>
                                        <div class="qf-correct-btn ${questionForm.optionCorrects[os.index] ? 'active' : ''}"
                                             onclick="qfToggleCorrect(this, ${os.index})">✓</div>
                                        <button type="button" class="qf-remove-btn" onclick="qfRemoveRow(this)">×</button>
                                    </div>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <%-- Default 4 empty rows --%>
                                <c:forEach var="i" begin="0" end="3">
                                    <div class="qf-option-row">
                                        <input class="ins-input" type="text" name="optionContents"
                                               placeholder="Lựa chọn ${i + 1}">
                                        <input type="hidden" name="optionCorrects" id="qfcorr_${i}" value="false"/>
                                        <div class="qf-correct-btn" onclick="qfToggleCorrect(this, ${i})">✓</div>
                                        <button type="button" class="qf-remove-btn" onclick="qfRemoveRow(this)">×</button>
                                    </div>
                                </c:forEach>
                            </c:otherwise>
                        </c:choose>
                    </div>
                    <button type="button" onclick="qfAddRow()"
                            class="ins-link-btn" style="margin-top:8px; padding:6px 14px; font-size:.82rem;">
                        + Thêm lựa chọn
                    </button>
                    <p class="qf-hint" style="margin-top:6px;">
                        Loại "Một lựa chọn" chỉ được đánh dấu đúng 1 ô. Để trống các ô không dùng.
                    </p>
                </div>

                <!-- Step 3b: TRUE/FALSE -->
                <div id="tfBox" class="ins-field" style="display:none; margin-top:16px;">
                    <label class="ins-label" for="tfAnswer">Đáp án đúng</label>
                    <div style="display:flex; gap:12px; margin-top:6px;">
                        <label style="display:flex; align-items:center; gap:8px; padding:10px 18px; border:2px solid #E2E8F0; border-radius:8px; cursor:pointer; font-weight:600; font-size:.9rem;"
                               id="tfTrue" onclick="qfSelectTF('true')">
                            <input type="radio" name="correctAnswer" id="tfAnswer" value="true"
                                   ${questionForm.correctAnswer eq 'true' ? 'checked' : ''} style="accent-color:#16A34A;">
                            ✅ Đúng (True)
                        </label>
                        <label style="display:flex; align-items:center; gap:8px; padding:10px 18px; border:2px solid #E2E8F0; border-radius:8px; cursor:pointer; font-weight:600; font-size:.9rem;"
                               id="tfFalse" onclick="qfSelectTF('false')">
                            <input type="radio" name="correctAnswer" value="false"
                                   ${questionForm.correctAnswer eq 'false' ? 'checked' : ''} style="accent-color:#DC2626;">
                            ❌ Sai (False)
                        </label>
                    </div>
                </div>

                <!-- Step 3c: SHORT_ANSWER -->
                <div id="shortBox" class="ins-field" style="display:none; margin-top:16px;">
                    <label class="ins-label" for="shortAnswer">Đáp án tham khảo</label>
                    <input class="ins-input" type="text" id="shortAnswer" name="correctAnswer"
                           value="<c:out value='${questionForm.correctAnswer}'/>"
                           placeholder="Đáp án mẫu để tham khảo khi chấm tay (không bắt buộc)">
                    <p class="qf-hint">Hệ thống không tự chấm loại này. Giảng viên xem đáp án tham khảo khi chấm tay.</p>
                </div>

                <!-- Step 3d: ESSAY Rubric -->
                <div id="essayBox" class="ins-field" style="display:none; margin-top:16px;">
                    <label class="ins-label" for="sampleEssayAnswer">
                        💡 Gợi ý đáp án / Tiêu chí chấm điểm (Rubric)
                    </label>
                    <textarea class="ins-input" id="sampleEssayAnswer" name="sampleEssayAnswer" rows="4"
                              style="resize:vertical;" placeholder="Nêu các luận điểm và thang điểm thành phần để hỗ trợ chấm thi tự luận..."><c:out value="${questionForm.sampleEssayAnswer}"/></textarea>
                </div>

                <!-- Step 3e: Media (Image & Video URL) -->
                <div style="display:grid; grid-template-columns:1fr 1fr; gap:16px; margin-top:16px;">
                    <div class="ins-field" style="margin:0;">
                        <label class="ins-label" for="imageUrl">🖼️ Đường dẫn hình ảnh (Image URL)</label>
                        <input class="ins-input" type="text" id="imageUrl" name="imageUrl"
                               value="<c:out value='${questionForm.imageUrl}'/>"
                               placeholder="/uploads/questions/... hoặc https://...">
                    </div>
                    <div class="ins-field" style="margin:0;">
                        <label class="ins-label" for="videoUrl">📹 Đường dẫn Video (Video URL)</label>
                        <input class="ins-input" type="text" id="videoUrl" name="videoUrl"
                               value="<c:out value='${questionForm.videoUrl}'/>"
                               placeholder="https://...">
                    </div>
                </div>

                <!-- Step 4: Explanation -->
                <div class="ins-field" style="margin-top:16px;">
                    <label class="ins-label" for="explanation">
                        💡 Giải thích đáp án
                        <span style="font-weight:400; color:#94A3B8;">(tùy chọn — hiển thị cho học viên sau khi nộp bài)</span>
                    </label>
                    <textarea class="ins-input" id="explanation" name="explanation" rows="3"
                              style="resize:vertical;" placeholder="Giải thích tại sao đáp án đúng, tài liệu tham khảo..."><c:out value="${questionForm.explanation}"/></textarea>
                </div>

                <!-- Actions -->
                <div style="display:flex; gap:12px; margin-top:24px; padding-top:20px; border-top:1px solid #E2E8F0;">
                    <button type="submit" class="ins-btn-primary" style="width:auto; padding:11px 28px;">
                        💾 Lưu câu hỏi
                    </button>
                    <a href="${pageContext.request.contextPath}/instructor/courses/${courseId}/quizzes/${quizId}"
                       class="ins-link-btn" style="padding:11px 20px;">
                        Hủy
                    </a>
                </div>
            </form>
        </div>
        </main>
    </div>
</div>

<script>
var optCount = document.querySelectorAll('.qf-option-row').length;

function qfSelectType(type, card) {
    document.querySelectorAll('.qf-type-card').forEach(c => c.classList.remove('selected'));
    card.classList.add('selected');
    document.getElementById('typeInput').value = type;

    var isChoice = type === 'SINGLE_CHOICE' || type === 'MULTIPLE_CHOICE';
    document.getElementById('optionsBox').style.display = isChoice ? '' : 'none';
    document.getElementById('optionsBox').querySelectorAll('input, button, div.qf-correct-btn').forEach(el => {
        if (!el.id || !el.id.startsWith('qfcorr_')) el.disabled = !isChoice;
    });

    document.getElementById('tfBox').style.display = type === 'TRUE_FALSE' ? '' : 'none';
    document.getElementById('tfBox').querySelectorAll('input').forEach(el => el.disabled = type !== 'TRUE_FALSE');

    document.getElementById('shortBox').style.display = type === 'SHORT_ANSWER' ? '' : 'none';
    document.getElementById('shortAnswer').disabled = type !== 'SHORT_ANSWER';

    document.getElementById('essayBox').style.display = type === 'ESSAY' ? '' : 'none';
}

function qfToggleCorrect(btn, idx) {
    var hidden = document.getElementById('qfcorr_' + idx);
    var newVal = hidden.value !== 'true';
    hidden.value = newVal ? 'true' : 'false';
    btn.classList.toggle('active', newVal);
}

function qfAddRow() {
    var rows = document.getElementById('optionRows');
    var idx = optCount++;
    var div = document.createElement('div');
    div.className = 'qf-option-row';
    div.innerHTML =
        '<input class="ins-input" type="text" name="optionContents" placeholder="Lựa chọn ' + (idx + 1) + '">' +
        '<input type="hidden" name="optionCorrects" id="qfcorr_' + idx + '" value="false">' +
        '<div class="qf-correct-btn" onclick="qfToggleCorrect(this,' + idx + ')">✓</div>' +
        '<button type="button" class="qf-remove-btn" onclick="qfRemoveRow(this)">×</button>';
    rows.appendChild(div);
}

function qfRemoveRow(btn) {
    var rows = document.querySelectorAll('.qf-option-row');
    if (rows.length <= 2) { alert('Cần ít nhất 2 lựa chọn.'); return; }
    btn.closest('.qf-option-row').remove();
}

function qfSelectTF(val) {
    document.querySelectorAll('#tfTrue, #tfFalse').forEach(el => {
        el.style.borderColor = '#E2E8F0';
        el.style.background = '#fff';
    });
    var target = document.getElementById(val === 'true' ? 'tfTrue' : 'tfFalse');
    target.style.borderColor = val === 'true' ? '#16A34A' : '#DC2626';
    target.style.background = val === 'true' ? '#DCFCE7' : '#FEF2F2';
}

// Init on page load
(function() {
    var currentType = document.getElementById('typeInput').value;
    var card = document.querySelector('.qf-type-card.selected');
    if (card) qfSelectType(currentType, card);

    // Init TF highlight if editing
    var checked = document.querySelector('#tfBox input[type=radio]:checked');
    if (checked) qfSelectTF(checked.value);
})();

function insToggleMenu(e) {
    e.stopPropagation();
    document.getElementById('insUserMenu').classList.toggle('open');
}
document.addEventListener('click', function() {
    var m = document.getElementById('insUserMenu');
    if (m) m.classList.remove('open');
});
</script>
</body>
</html>
