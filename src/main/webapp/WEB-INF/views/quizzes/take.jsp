<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đang làm bài: <c:out value="${attempt.quiz.title}"/> — EduSphere</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/home.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/quiz.css?v=2.0">
</head>
<body style="background:#F8FAFD;">

<!-- Sticky Exam Header -->
<header class="quiz-take-header">
    <div style="display:flex; align-items:center; gap:16px;">
        <div style="font-size:1.4rem;">🎓</div>
        <div>
            <div class="quiz-take-header__title"><c:out value="${attempt.quiz.title}"/></div>
            <div class="quiz-take-header__meta">Lần làm thứ ${attempt.attemptNumber} · Tổng cộng ${fn:length(questions)} câu hỏi</div>
        </div>
    </div>
    <div style="display:flex; align-items:center; gap:14px;">
        <c:if test="${attempt.deadlineAt != null}">
            <div class="quiz-timer-badge" id="timer">--:--</div>
        </c:if>
        <a href="${pageContext.request.contextPath}/courses/${courseId}/quizzes/${quizId}"
           onclick="return confirm('Bạn có chắc chắn muốn thoát? Bài làm đang tiến hành sẽ được lưu tạm nhưng đồng hồ vẫn tiếp tục tính giờ.')"
           class="quiz-btn quiz-btn--outline" style="padding:6px 14px; font-size:.82rem; background:rgba(255,255,255,0.1); color:#fff !important; border-color:rgba(255,255,255,0.25);">
            Thoát
        </a>
    </div>
</header>

<div class="quiz-take-progress-bar">
    <div class="quiz-take-progress-bar__fill" id="progressFill" style="width:0%"></div>
</div>

<div class="quiz-page-wrap" style="padding-top:8px;">
    <main class="quiz-shell">
        <form id="quizForm" method="post"
              action="${pageContext.request.contextPath}/courses/${courseId}/quizzes/${quizId}/attempts/${attemptId}/submit">
            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">

            <div class="quiz-layout">
                <!-- Questions Area -->
                <div id="questionsArea">
                    <c:forEach var="q" items="${questions}" varStatus="st">
                        <div class="quiz-test-qcard" id="qcard-${q.questionId}" data-qid="${q.questionId}">
                            <div style="display:flex; align-items:center; justify-content:space-between; margin-bottom:12px;">
                                <span class="quiz-qcard__num" style="background:#EFF6FF; color:#1B9AF5; font-size:.88rem; padding:4px 12px; border-radius:8px;">
                                    Câu hỏi ${st.count}
                                </span>
                                <span style="font-size:.86rem; font-weight:700; color:#64748B;">
                                    <fmt:formatNumber value="${q.score}" maxFractionDigits="1"/> điểm
                                </span>
                            </div>

                            <div class="quiz-qcard__title" style="font-size:1.05rem; margin-bottom:16px;">
                                <c:out value="${q.content}"/>
                            </div>

                            <c:if test="${not empty q.imageUrl}">
                                <div style="margin:14px 0;">
                                    <img src="${pageContext.request.contextPath}${q.imageUrl}"
                                         style="max-height:280px; max-width:100%; border-radius:10px; border:1px solid #E2E8F0; cursor:pointer; object-fit:contain;"
                                         onclick="zoomImage(this.src)" alt="Minh họa câu hỏi"/>
                                </div>
                            </c:if>

                            <c:if test="${not empty q.videoUrl}">
                                <div style="margin:12px 0; font-size:0.88rem; color:#2563eb; background:#EFF6FF; padding:8px 14px; border-radius:8px;">
                                    📹 Video bổ trợ câu hỏi: <a href="<c:out value="${q.videoUrl}"/>" target="_blank" style="color:#2563eb; text-decoration:underline; font-weight:600;"><c:out value="${q.videoUrl}"/></a>
                                </div>
                            </c:if>

                            <c:choose>
                                <%-- 1. SINGLE_CHOICE --%>
                                <c:when test="${q.type eq 'SINGLE_CHOICE'}">
                                    <div style="font-size:.8rem; font-weight:700; color:#64748B; text-transform:uppercase; margin-bottom:10px;">
                                        🔘 Chọn một đáp án đúng nhất
                                    </div>
                                    <c:forEach var="o" items="${q.options}">
                                        <label class="quiz-opt-select" onclick="markAnswered(${q.questionId}, this.closest('.quiz-test-qcard'))">
                                            <input type="radio" name="answer_${q.questionId}" value="${o.optionId}">
                                            <span><c:out value="${o.content}"/></span>
                                        </label>
                                    </c:forEach>
                                </c:when>

                                <%-- 2. MULTIPLE_CHOICE --%>
                                <c:when test="${q.type eq 'MULTIPLE_CHOICE'}">
                                    <div style="font-size:.8rem; font-weight:700; color:#64748B; text-transform:uppercase; margin-bottom:10px;">
                                        ☑️ Chọn tất cả các đáp án đúng
                                    </div>
                                    <c:forEach var="o" items="${q.options}">
                                        <label class="quiz-opt-select" onclick="markAnswered(${q.questionId}, this.closest('.quiz-test-qcard'))">
                                            <input type="checkbox" name="answer_${q.questionId}" value="${o.optionId}">
                                            <span><c:out value="${o.content}"/></span>
                                        </label>
                                    </c:forEach>
                                </c:when>

                                <%-- 3. TRUE_FALSE --%>
                                <c:when test="${q.type eq 'TRUE_FALSE'}">
                                    <div style="font-size:.8rem; font-weight:700; color:#64748B; text-transform:uppercase; margin-bottom:10px;">
                                        ⚖️ Nhận định trên là Đúng hay Sai?
                                    </div>
                                    <label class="quiz-opt-select" onclick="markAnswered(${q.questionId}, this.closest('.quiz-test-qcard'))">
                                        <input type="radio" name="answer_${q.questionId}" value="true">
                                        <span>✅ Đúng (True)</span>
                                    </label>
                                    <label class="quiz-opt-select" onclick="markAnswered(${q.questionId}, this.closest('.quiz-test-qcard'))">
                                        <input type="radio" name="answer_${q.questionId}" value="false">
                                        <span>❌ Sai (False)</span>
                                    </label>
                                </c:when>

                                <%-- 4. SHORT_ANSWER --%>
                                <c:when test="${q.type eq 'SHORT_ANSWER'}">
                                    <div style="font-size:.8rem; font-weight:700; color:#64748B; text-transform:uppercase; margin-bottom:10px;">
                                        ✍️ Điền câu trả lời ngắn vào ô bên dưới
                                    </div>
                                    <input type="text" name="answer_${q.questionId}"
                                           placeholder="Nhập câu trả lời ngắn của bạn tại đây..."
                                           style="width:100%; box-sizing:border-box; border:1.5px solid #CBD5E1; border-radius:10px; padding:12px 16px; font-size:.95rem; font-family:inherit; outline:none; transition:border-color .15s;"
                                           onfocus="this.style.borderColor='#1B9AF5'" onblur="this.style.borderColor='#CBD5E1'"
                                           oninput="markAnswered(${q.questionId}, this.closest('.quiz-test-qcard'))">
                                </c:when>

                                <%-- 5. ESSAY --%>
                                <c:otherwise>
                                    <div style="font-size:.8rem; font-weight:700; color:#64748B; text-transform:uppercase; margin-bottom:10px;">
                                        📝 Trả lời tự luận
                                    </div>
                                    <textarea name="answer_${q.questionId}" rows="6"
                                              placeholder="Trình bày chi tiết câu trả lời của bạn tại đây..."
                                              style="width:100%; box-sizing:border-box; border:1.5px solid #CBD5E1; border-radius:10px; padding:12px 16px; font-size:.95rem; font-family:inherit; outline:none; transition:border-color .15s; resize:vertical;"
                                              onfocus="this.style.borderColor='#1B9AF5'" onblur="this.style.borderColor='#CBD5E1'"
                                              oninput="markAnswered(${q.questionId}, this.closest('.quiz-test-qcard'))"></textarea>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </c:forEach>

                    <!-- Submit zone -->
                    <div class="quiz-card" style="text-align:center; padding:32px 24px; margin-top:28px;">
                        <div style="font-size:1.8rem; margin-bottom:8px;">📤</div>
                        <h3 style="font-size:1.15rem; font-weight:800; color:#0F172A; margin:0 0 6px 0;">Sẵn sàng nộp bài?</h3>
                        <p style="font-size:.9rem; color:#64748B; margin-bottom:18px;">
                            Hãy kiểm tra lại tất cả các câu trả lời trước khi nộp. Sau khi nộp bài, bạn sẽ không thể thay đổi đáp án.
                        </p>
                        <div id="unansweredWarning" style="display:none; background:#FEF9C3; border:1px solid #FDE68A; border-radius:10px; padding:12px 18px; margin-bottom:18px; font-size:.9rem; color:#854D0E; font-weight:600;"></div>
                        <button class="quiz-btn quiz-btn--primary" style="padding:14px 48px; font-size:1.05rem; font-weight:800; border-radius:12px;" type="button" onclick="confirmSubmit()">
                            Nộp bài kiểm tra
                        </button>
                    </div>
                </div>

                <!-- Navigation Palette (Sidebar) -->
                <aside>
                    <div class="quiz-palette-card">
                        <div style="display:flex; align-items:center; justify-content:space-between; margin-bottom:10px;">
                            <span style="font-size:.82rem; font-weight:800; color:#64748B; text-transform:uppercase;">Mục lục câu hỏi</span>
                            <span style="font-size:.82rem; font-weight:700; color:#1B9AF5;">
                                <span id="answeredCount">0</span> / ${fn:length(questions)}
                            </span>
                        </div>

                        <div class="quiz-palette-grid">
                            <c:forEach var="q" items="${questions}" varStatus="st">
                                <button type="button" class="quiz-palette-btn" id="navbtn-${q.questionId}"
                                        onclick="scrollToQuestion(${q.questionId})">
                                    ${st.count}
                                </button>
                            </c:forEach>
                        </div>

                        <div style="margin-top:16px; padding-top:14px; border-top:1px solid #F1F5F9; font-size:.78rem; color:#64748B; display:flex; flex-direction:column; gap:6px;">
                            <div style="display:flex; align-items:center; gap:8px;">
                                <span style="display:inline-block; width:12px; height:12px; background:#DCFCE7; border:1.5px solid #86EFAC; border-radius:3px;"></span>
                                <span>Đã trả lời</span>
                            </div>
                            <div style="display:flex; align-items:center; gap:8px;">
                                <span style="display:inline-block; width:12px; height:12px; background:#F8FAFC; border:1.5px solid #CBD5E1; border-radius:3px;"></span>
                                <span>Chưa trả lời</span>
                            </div>
                        </div>
                    </div>
                </aside>
            </div>
        </form>
    </main>
</div>

<!-- Modal zoom image -->
<div id="imageZoomModal" style="display:none; position:fixed; top:0; left:0; right:0; bottom:0; background:rgba(0,0,0,0.7); z-index:10000; align-items:center; justify-content:center;" onclick="closeZoomModal()">
    <img id="zoomedImg" src="" style="max-width:92vw; max-height:92vh; border-radius:12px; box-shadow:0 25px 50px -12px rgba(0,0,0,0.5);"/>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>

<script>
var totalQuestions = ${fn:length(questions)};
var answeredSet = new Set();

function checkQuestionAnswered(qid, card) {
    if (!card) card = document.getElementById('qcard-' + qid);
    if (!card) return;
    var isAnswered = false;
    var choiceInputs = card.querySelectorAll('input[type="radio"], input[type="checkbox"]');
    if (choiceInputs.length > 0) {
        choiceInputs.forEach(function(inp) {
            if (inp.checked) isAnswered = true;
        });
    } else {
        var textInputs = card.querySelectorAll('input[type="text"], textarea');
        textInputs.forEach(function(inp) {
            if (inp.value && inp.value.trim().length > 0) isAnswered = true;
        });
    }
    var navBtn = document.getElementById('navbtn-' + qid);
    if (isAnswered) {
        answeredSet.add(qid);
        card.classList.add('answered');
        if (navBtn) navBtn.classList.add('answered');
    } else {
        answeredSet.delete(qid);
        card.classList.remove('answered');
        if (navBtn) navBtn.classList.remove('answered');
    }
    updateProgress();
}

function markAnswered(qid, card) {
    checkQuestionAnswered(qid, card);
    setTimeout(function() {
        checkQuestionAnswered(qid, card);
    }, 0);
}

function updateProgress() {
    var count = answeredSet.size;
    var countEl = document.getElementById('answeredCount');
    if (countEl) countEl.textContent = count;
    var pct = totalQuestions > 0 ? (count / totalQuestions * 100) : 0;
    var fillEl = document.getElementById('progressFill');
    if (fillEl) fillEl.style.width = pct + '%';
}

function scrollToQuestion(qid) {
    var el = document.getElementById('qcard-' + qid);
    if (el) {
        el.scrollIntoView({ behavior: 'smooth', block: 'start' });
        document.querySelectorAll('.quiz-palette-btn').forEach(function(b) { b.classList.remove('current'); });
        var navBtn = document.getElementById('navbtn-' + qid);
        if (navBtn) navBtn.classList.add('current');
    }
}

function confirmSubmit() {
    var unanswered = [];
    var navBtns = document.querySelectorAll('.quiz-palette-btn:not(.answered)');
    navBtns.forEach(function(d) {
        unanswered.push(d.textContent.trim());
    });

    if (unanswered.length > 0) {
        var warn = document.getElementById('unansweredWarning');
        warn.style.display = 'block';
        warn.textContent = '⚠️ Bạn còn ' + unanswered.length + ' câu chưa trả lời (Câu số ' + unanswered.join(', ') + '). Những câu này sẽ được tính 0 điểm.';
        if (!confirm('Bạn còn ' + unanswered.length + ' câu chưa trả lời (Câu số ' + unanswered.join(', ') + '). Bạn có chắc chắn muốn nộp bài?')) return;
    } else {
        if (!confirm('Bạn đã hoàn thành đủ ' + totalQuestions + ' câu hỏi. Nộp bài ngay bây giờ?')) return;
    }
    document.getElementById('quizForm').submit();
}

// Option item select highlight
document.querySelectorAll('.quiz-opt-select input').forEach(function(inp) {
    inp.addEventListener('change', function() {
        if (inp.type === 'radio') {
            var name = inp.getAttribute('name');
            document.querySelectorAll('input[name="' + name + '"]').forEach(function(r) {
                var p = r.closest('.quiz-opt-select');
                if (p) p.classList.remove('selected');
            });
            var parent = inp.closest('.quiz-opt-select');
            if (parent) parent.classList.add('selected');
        } else {
            var parent = inp.closest('.quiz-opt-select');
            if (parent) parent.classList.toggle('selected', inp.checked);
        }
        var card = inp.closest('.quiz-test-qcard');
        if (card && card.getAttribute('data-qid')) {
            checkQuestionAnswered(parseInt(card.getAttribute('data-qid')), card);
        }
    });
});

// Timer
<c:if test="${attempt.deadlineAt != null}">
(function() {
    var endStr = '${fn:replace(fn:substring(attempt.deadlineAt, 0, 19), "T", " ")}';
    var end = new Date(endStr.replace(' ', 'T')).getTime();
    var timerEl = document.getElementById('timer');
    var form = document.getElementById('quizForm');
    function tick() {
        var left = Math.floor((end - Date.now()) / 1000);
        if (left <= 0) {
            timerEl.textContent = '00:00';
            timerEl.className = 'quiz-timer-badge quiz-timer-badge--danger';
            alert('Đã hết thời gian làm bài! Hệ thống sẽ tự động nộp bài làm của bạn.');
            form.submit();
            return;
        }
        var m = Math.floor(left / 60), s = left % 60;
        timerEl.textContent = String(m).padStart(2,'0') + ':' + String(s).padStart(2,'0');
        if (left <= 60) {
            timerEl.className = 'quiz-timer-badge quiz-timer-badge--danger';
        } else if (left <= 300) {
            timerEl.className = 'quiz-timer-badge quiz-timer-badge--warning';
        } else {
            timerEl.className = 'quiz-timer-badge';
        }
        setTimeout(tick, 1000);
    }
    tick();
})();
</c:if>

function zoomImage(src) {
    document.getElementById('zoomedImg').src = src;
    document.getElementById('imageZoomModal').style.display = 'flex';
}
function closeZoomModal() {
    document.getElementById('imageZoomModal').style.display = 'none';
}
</script>
</body>
</html>
