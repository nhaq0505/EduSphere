<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đang làm bài: <c:out value="${attempt.quiz.title}"/> — EduSphere</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app.css?v=restore-0bfd0e1-20261014">
    <style>
        /* ── Header bar ── */
        .qt-header {
            position:sticky; top:0; z-index:100;
            background:#0F172A; color:#fff;
            padding:12px 24px; display:flex; align-items:center; justify-content:space-between;
            gap:16px; flex-wrap:wrap;
        }
        .qt-header__title { font-weight:800; font-size:.95rem; }
        .qt-header__meta { font-size:.82rem; opacity:.7; }
        .qt-timer {
            background:#EF4444; color:#fff; border-radius:8px;
            padding:7px 16px; font-weight:900; font-size:1.1rem; letter-spacing:.05em;
            min-width:80px; text-align:center;
        }
        .qt-timer--warning { background:#F59E0B; }
        .qt-timer--ok { background:#16A34A; }

        /* ── Progress bar ── */
        .qt-progress-bar {
            height:4px; background:#E2E8F0; margin-bottom:24px; border-radius:2px; overflow:hidden;
        }
        .qt-progress-bar__fill {
            height:100%; background:#2563EB; border-radius:2px;
            transition:width .3s ease;
        }

        /* ── Question card ── */
        .qt-question {
            background:#fff; border:2px solid #E2E8F0; border-radius:12px;
            padding:22px 24px; margin-bottom:16px; transition:border-color .2s;
        }
        .qt-question.answered { border-color:#86EFAC; }
        .qt-question__num {
            display:inline-block; background:#EFF6FF; color:#2563EB;
            font-weight:800; font-size:.8rem; padding:3px 12px; border-radius:20px; margin-bottom:10px;
        }
        .qt-question__score { color:#94A3B8; font-size:.8rem; }
        .qt-question__text { font-size:.97rem; font-weight:600; color:#0F172A; line-height:1.6; margin-bottom:16px; white-space:pre-line; }
        .qt-question__hint { font-size:.78rem; color:#94A3B8; margin-bottom:10px; }

        /* ── Options ── */
        .qt-option {
            display:flex; align-items:center; gap:12px;
            padding:12px 16px; border:2px solid #E2E8F0; border-radius:10px;
            margin-bottom:8px; cursor:pointer; transition:all .15s;
            font-size:.9rem; color:#334155; user-select:none;
        }
        .qt-option:hover { border-color:#3B82F6; background:#F0F7FF; }
        .qt-option input[type=radio], .qt-option input[type=checkbox] {
            width:18px; height:18px; accent-color:#2563EB; flex-shrink:0; cursor:pointer;
        }
        .qt-option.selected { border-color:#2563EB; background:#EFF6FF; font-weight:600; }

        /* ── Text inputs ── */
        .qt-text-input {
            width:100%; box-sizing:border-box;
            border:2px solid #E2E8F0; border-radius:10px;
            padding:12px 14px; font-size:.9rem; font-family:inherit;
            resize:vertical; transition:border-color .15s;
        }
        .qt-text-input:focus { outline:none; border-color:#3B82F6; }

        /* ── Submit zone ── */
        .qt-submit-zone {
            background:#fff; border:1px solid #E2E8F0; border-radius:12px;
            padding:24px; text-align:center; margin-top:24px; margin-bottom:40px;
        }
        .qt-btn-submit {
            background:#16A34A; color:#fff; border:none; border-radius:10px;
            padding:14px 40px; font-size:1rem; font-weight:800; cursor:pointer;
            transition:background .15s;
        }
        .qt-btn-submit:hover { background:#15803D; }

        /* ── Nav sidebar ── */
        .qt-layout { display:grid; grid-template-columns:1fr 220px; gap:24px; align-items:start; margin-top:24px; }
        @media(max-width:820px){ .qt-layout{ grid-template-columns:1fr; } }
        .qt-nav { position:sticky; top:80px; background:#fff; border:1px solid #E2E8F0; border-radius:12px; padding:16px; }
        .qt-nav__title { font-size:.78rem; font-weight:700; color:#94A3B8; text-transform:uppercase; margin-bottom:10px; }
        .qt-nav-grid { display:grid; grid-template-columns:repeat(5, 1fr); gap:5px; }
        .qt-nav-btn {
            width:34px; height:34px; border:2px solid #E2E8F0; border-radius:6px;
            background:#F8FAFC; font-size:.82rem; font-weight:700; cursor:pointer;
            display:flex; align-items:center; justify-content:center; color:#64748B;
            transition:all .15s;
        }
        .qt-nav-btn:hover { border-color:#3B82F6; }
        .qt-nav-btn.answered { background:#DCFCE7; border-color:#86EFAC; color:#166534; }
        .qt-nav-btn.current { border-color:#2563EB; background:#EFF6FF; color:#2563EB; font-weight:900; }
    </style>
</head>
<body>
<!-- Sticky header bar -->
<div class="qt-header">
    <div>
        <div class="qt-header__title"><c:out value="${attempt.quiz.title}"/></div>
        <div class="qt-header__meta">Lần làm ${attempt.attemptNumber} · ${fn:length(questions)} câu hỏi</div>
    </div>
    <c:if test="${attempt.deadlineAt != null}">
        <div class="qt-timer qt-timer--ok" id="timer">--:--</div>
    </c:if>
</div>

<main class="shell" style="padding-top:16px;">

    <!-- Progress bar -->
    <div class="qt-progress-bar">
        <div class="qt-progress-bar__fill" id="progressFill" style="width:0%"></div>
    </div>

    <form id="quizForm" method="post"
          action="${pageContext.request.contextPath}/courses/${courseId}/quizzes/${quizId}/attempts/${attemptId}/submit">
        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">

        <div class="qt-layout">
            <!-- Questions -->
            <div id="questionsArea">
                <c:forEach var="q" items="${questions}" varStatus="st">
                    <div class="qt-question" id="qcard-${q.questionId}" data-qid="${q.questionId}">
                        <div style="display:flex;align-items:center;justify-content:space-between;margin-bottom:8px;">
                            <span class="qt-question__num">Câu ${st.count}</span>
                            <span class="qt-question__score"><fmt:formatNumber value="${q.score}" maxFractionDigits="1"/> điểm</span>
                        </div>
                        <p class="qt-question__text"><c:out value="${q.content}"/></p>

                        <c:choose>
                            <c:when test="${q.type eq 'SINGLE_CHOICE'}">
                                <p class="qt-question__hint">🔘 Chọn một đáp án đúng</p>
                                <c:forEach var="o" items="${q.options}">
                                    <label class="qt-option" onclick="markAnswered(${q.questionId}, this.closest('.qt-question'))">
                                        <input type="radio" name="answer_${q.questionId}" value="${o.optionId}">
                                        <span><c:out value="${o.content}"/></span>
                                    </label>
                                </c:forEach>
                            </c:when>

                            <c:when test="${q.type eq 'MULTIPLE_CHOICE'}">
                                <p class="qt-question__hint">☑️ Chọn tất cả đáp án đúng (có thể nhiều hơn 1)</p>
                                <c:forEach var="o" items="${q.options}">
                                    <label class="qt-option" onclick="markAnswered(${q.questionId}, this.closest('.qt-question'))">
                                        <input type="checkbox" name="answer_${q.questionId}" value="${o.optionId}">
                                        <span><c:out value="${o.content}"/></span>
                                    </label>
                                </c:forEach>
                            </c:when>

                            <c:when test="${q.type eq 'TRUE_FALSE'}">
                                <p class="qt-question__hint">⚖️ Nhận định này là Đúng hay Sai?</p>
                                <label class="qt-option" onclick="markAnswered(${q.questionId}, this.closest('.qt-question'))">
                                    <input type="radio" name="answer_${q.questionId}" value="true">
                                    <span>✅ Đúng (True)</span>
                                </label>
                                <label class="qt-option" onclick="markAnswered(${q.questionId}, this.closest('.qt-question'))">
                                    <input type="radio" name="answer_${q.questionId}" value="false">
                                    <span>❌ Sai (False)</span>
                                </label>
                            </c:when>

                            <c:when test="${q.type eq 'SHORT_ANSWER'}">
                                <p class="qt-question__hint">✍️ Điền câu trả lời ngắn vào ô bên dưới</p>
                                <input class="qt-text-input" type="text"
                                       name="answer_${q.questionId}"
                                       placeholder="Nhập câu trả lời của bạn..."
                                       oninput="markAnswered(${q.questionId}, this.closest('.qt-question'))">
                            </c:when>

                            <c:otherwise>
                                <p class="qt-question__hint">📝 Viết câu trả lời tự luận đầy đủ</p>
                                <textarea class="qt-text-input" name="answer_${q.questionId}" rows="6"
                                          placeholder="Viết câu trả lời của bạn tại đây..."
                                          oninput="markAnswered(${q.questionId}, this.closest('.qt-question'))"></textarea>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </c:forEach>

                <!-- Submit zone -->
                <div class="qt-submit-zone">
                    <p style="font-size:.9rem;color:#64748B;margin-bottom:16px;">
                        Kiểm tra lại tất cả câu trả lời trước khi nộp. <strong>Bạn không thể sửa sau khi đã nộp.</strong>
                    </p>
                    <div id="unansweredWarning" style="display:none;background:#FEF9C3;border:1px solid #FDE68A;border-radius:8px;padding:10px 16px;margin-bottom:14px;font-size:.87rem;color:#854D0E;font-weight:600;"></div>
                    <button class="qt-btn-submit" type="button" onclick="confirmSubmit()">
                        📤 Nộp bài
                    </button>
                </div>
            </div>

            <!-- Navigation sidebar -->
            <aside class="qt-nav" id="questionNav">
                <p class="qt-nav__title">Điều hướng câu hỏi</p>
                <div class="qt-nav-grid">
                    <c:forEach var="q" items="${questions}" varStatus="st">
                        <button type="button" class="qt-nav-btn" id="navbtn-${q.questionId}"
                                onclick="scrollToQuestion(${q.questionId})">
                            ${st.count}
                        </button>
                    </c:forEach>
                </div>
                <p style="font-size:.75rem;color:#94A3B8;margin-top:10px;">
                    🟢 Đã trả lời &nbsp; ⬜ Chưa trả lời
                </p>
                <div style="margin-top:12px;text-align:center;">
                    <span id="answeredCount" style="font-size:.82rem;font-weight:700;color:#16A34A;">0</span>
                    <span style="font-size:.82rem;color:#64748B;"> / ${fn:length(questions)} đã trả lời</span>
                </div>
            </aside>
        </div>
    </form>
</main>

<script>
var totalQuestions = ${fn:length(questions)};
var answeredSet = new Set();

// Mark a question as answered
function markAnswered(qid, card) {
    answeredSet.add(qid);
    card.classList.add('answered');
    var navBtn = document.getElementById('navbtn-' + qid);
    if (navBtn) navBtn.classList.add('answered');
    updateProgress();
}

function updateProgress() {
    var count = answeredSet.size;
    document.getElementById('answeredCount').textContent = count;
    var pct = totalQuestions > 0 ? (count / totalQuestions * 100) : 0;
    document.getElementById('progressFill').style.width = pct + '%';
}

// Scroll to question
function scrollToQuestion(qid) {
    var el = document.getElementById('qcard-' + qid);
    if (el) el.scrollIntoView({ behavior: 'smooth', block: 'start' });
}

// Submit with confirmation
function confirmSubmit() {
    var unanswered = [];
    var cards = document.querySelectorAll('.qt-question[data-qid]');
    cards.forEach(function(card) {
        var qid = parseInt(card.getAttribute('data-qid'));
        if (!answeredSet.has(qid)) unanswered.push(qid);
    });

    if (unanswered.length > 0) {
        var warn = document.getElementById('unansweredWarning');
        warn.style.display = '';
        warn.textContent = '⚠️ Bạn còn ' + unanswered.length + ' câu chưa trả lời (câu: ' + unanswered.join(', ') + '). Nộp bài sẽ tính 0 điểm cho các câu đó.';
        if (!confirm('Bạn còn ' + unanswered.length + ' câu chưa trả lời. Vẫn nộp bài?')) return;
    } else {
        if (!confirm('Bạn đã trả lời tất cả ' + totalQuestions + ' câu. Nộp bài ngay?')) return;
    }
    document.getElementById('quizForm').submit();
}

// Highlight selected radio option labels
document.querySelectorAll('.qt-option input').forEach(function(inp) {
    inp.addEventListener('change', function() {
        if (inp.type === 'radio') {
            var name = inp.getAttribute('name');
            document.querySelectorAll('input[name="' + name + '"]').forEach(function(r) {
                r.closest('.qt-option').classList.remove('selected');
            });
            inp.closest('.qt-option').classList.add('selected');
        } else {
            inp.closest('.qt-option').classList.toggle('selected', inp.checked);
        }
    });
});

// Timer countdown
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
            timerEl.className = 'qt-timer';
            form.submit();
            return;
        }
        var m = Math.floor(left / 60), s = left % 60;
        timerEl.textContent = String(m).padStart(2,'0') + ':' + String(s).padStart(2,'0');
        if (left <= 60) timerEl.className = 'qt-timer';
        else if (left <= 300) timerEl.className = 'qt-timer qt-timer--warning';
        else timerEl.className = 'qt-timer qt-timer--ok';
        setTimeout(tick, 1000);
    }
    tick();
})();
</c:if>
</script>
<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</body>
</html>
