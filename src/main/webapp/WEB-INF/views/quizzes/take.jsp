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
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/quiz.css?v=2.2">
</head>
<body style="background:#F8FAFD;">

<!-- Sticky Exam Header -->
<header class="quiz-take-header">
    <div style="display:flex; align-items:center; gap:16px;">
        <a class="quiz-take-brand" href="${pageContext.request.contextPath}/" title="EduSphere">
            <span style="font-size:1.35rem;">🎓</span>
            <span>EduSphere</span>
        </a>
        <div class="quiz-take-divider"></div>
        <div>
            <div class="quiz-take-header__title"><c:out value="${attempt.quiz.title}"/></div>
            <div class="quiz-take-header__meta">Lần làm thứ ${attempt.attemptNumber} · Tổng cộng ${fn:length(questions)} câu hỏi</div>
        </div>
    </div>
    <div style="display:flex; align-items:center; gap:16px;">
        <c:if test="${attempt.deadlineAt != null}">
            <div class="quiz-timer-wrap">
                <span class="quiz-timer-label">Thời gian còn lại</span>
                <div class="quiz-timer-badge" id="timer">--:--</div>
            </div>
        </c:if>
        <a href="${pageContext.request.contextPath}/courses/${courseId}/quizzes/${quizId}"
           onclick="return confirm('Bạn có chắc chắn muốn thoát? Bài làm đang tiến hành sẽ được lưu tạm nhưng đồng hồ vẫn tiếp tục tính giờ.')"
           class="quiz-exit-btn">
            <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><path d="M15 3h4a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2h-4"/><polyline points="10 17 15 12 10 7"/><line x1="15" y1="12" x2="3" y2="12"/></svg>
            <span>Thoát bài thi</span>
        </a>
    </div>
</header>

<div class="quiz-take-progress-bar">
    <div class="quiz-take-progress-bar__fill" id="progressFill" style="width:0%"></div>
</div>

<div class="quiz-page-wrap" style="padding-top:12px;">
    <main class="quiz-shell">
        <form id="quizForm" method="post"
              action="${pageContext.request.contextPath}/courses/${courseId}/quizzes/${quizId}/attempts/${attemptId}/submit">
            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">

            <!-- Layout 2 cột: Mục lục câu hỏi BÊN TRÁI, Làm bài BÊN PHẢI -->
            <div class="quiz-take-layout">

                <!-- ── CỘT TRÁI: MỤC LỤC CÂU HỎI (Sticky Navigation Sidebar) ── -->
                <aside class="quiz-take-sidebar">
                    <div class="quiz-palette-card">
                        <div class="quiz-palette-card__head">
                            <div>
                                <h3 class="quiz-palette-card__title">
                                    <span>📋</span> Mục lục câu hỏi
                                </h3>
                                <p class="quiz-palette-card__sub">Bấm số câu để cuộn nhanh</p>
                            </div>
                            <div class="quiz-palette-card__status">
                                <span id="flaggedBadge" class="quiz-flagged-pill" style="display:none;">
                                    🚩 <span id="flaggedCount">0</span>
                                </span>
                                <span class="quiz-answered-pill">
                                    <span id="answeredCount">0</span>/${fn:length(questions)}
                                </span>
                            </div>
                        </div>

                        <!-- Mini progress -->
                        <div class="quiz-palette-progress">
                            <div class="quiz-palette-progress__fill" id="paletteProgressFill" style="width:0%"></div>
                        </div>

                        <!-- Grid nút câu hỏi -->
                        <div class="quiz-palette-grid">
                            <c:forEach var="q" items="${questions}" varStatus="st">
                                <button type="button" class="quiz-palette-btn" id="navbtn-${q.questionId}"
                                        onclick="scrollToQuestion(${q.questionId})" title="Câu hỏi ${st.count}">
                                    ${st.count}
                                </button>
                            </c:forEach>
                        </div>

                        <!-- Chú thích trạng thái -->
                        <div class="quiz-palette-legend">
                            <div class="quiz-palette-legend__item">
                                <span class="quiz-dot quiz-dot--answered"></span>
                                <span>Đã trả lời</span>
                            </div>
                            <div class="quiz-palette-legend__item">
                                <span class="quiz-dot quiz-dot--unanswered"></span>
                                <span>Chưa trả lời</span>
                            </div>
                            <div class="quiz-palette-legend__item">
                                <span class="quiz-dot quiz-dot--flagged">
                                    <span class="quiz-dot__flag">🚩</span>
                                </span>
                                <span>Đã đánh dấu (xem lại)</span>
                            </div>
                            <div class="quiz-palette-legend__item">
                                <span class="quiz-dot quiz-dot--both">
                                    <span class="quiz-dot__flag">🚩</span>
                                </span>
                                <span>Đã trả lời &amp; Đánh dấu</span>
                            </div>
                        </div>

                        <!-- Nút cuộn nhanh đến Nộp bài -->
                        <div class="quiz-palette-actions">
                            <button type="button" class="quiz-btn quiz-btn--outline quiz-btn--block" onclick="scrollToSubmit()">
                                <span>🏁</span> Nộp bài thi
                            </button>
                        </div>
                    </div>
                </aside>

                <!-- ── CỘT PHẢI: VÙNG LÀM BÀI THI ── -->
                <section class="quiz-take-content" id="questionsArea">
                    <c:set var="letters" value="${fn:split('A,B,C,D,E,F,G,H', ',')}"/>
                    <c:forEach var="q" items="${questions}" varStatus="st">
                        <div class="quiz-test-qcard" id="qcard-${q.questionId}" data-qid="${q.questionId}">
                            <!-- Header thẻ câu hỏi -->
                            <div class="quiz-qcard-bar">
                                <div class="quiz-qcard-bar__left">
                                    <span class="quiz-qcard-badge">
                                        Câu ${st.count < 10 ? '0' : ''}${st.count}
                                    </span>
                                    <button type="button" class="quiz-flag-btn" id="flagbtn-${q.questionId}" onclick="toggleFlag(${q.questionId})" title="Đánh dấu câu hỏi để xem lại">
                                        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
                                            <path d="M4 15s1-1 4-1 5 2 8 2 4-1 4-1V3s-1 1-4 1-5-2-8-2-4 1-4 1z"></path>
                                            <line x1="4" y1="22" x2="4" y2="15"></line>
                                        </svg>
                                        <span class="quiz-flag-text">Đánh dấu</span>
                                    </button>
                                </div>
                                <div class="quiz-qcard-bar__right">
                                    <span class="quiz-score-tag">
                                        ⭐ <fmt:formatNumber value="${q.score}" maxFractionDigits="1"/> điểm
                                    </span>
                                </div>
                            </div>

                            <!-- Nội dung câu hỏi -->
                            <div class="quiz-qcard-text">
                                <c:out value="${q.content}"/>
                            </div>

                            <c:if test="${not empty q.imageUrl}">
                                <div style="margin:16px 0;">
                                    <img src="${pageContext.request.contextPath}${q.imageUrl}"
                                         style="max-height:280px; max-width:100%; border-radius:12px; border:1px solid #E2E8F0; cursor:pointer; object-fit:contain; box-shadow:0 2px 8px rgba(0,0,0,0.04);"
                                         onclick="zoomImage(this.src)" alt="Minh họa câu hỏi"/>
                                </div>
                            </c:if>

                            <c:if test="${not empty q.videoUrl}">
                                <div style="margin:14px 0; font-size:0.88rem; color:#0284C7; background:#F0F9FF; border:1px solid #BAE6FD; padding:10px 16px; border-radius:10px;">
                                    📹 Video bổ trợ câu hỏi: <a href="<c:out value="${q.videoUrl}"/>" target="_blank" style="color:#0284C7; text-decoration:underline; font-weight:700;"><c:out value="${q.videoUrl}"/></a>
                                </div>
                            </c:if>

                            <c:choose>
                                <%-- 1. SINGLE_CHOICE --%>
                                <c:when test="${q.type eq 'SINGLE_CHOICE'}">
                                    <div class="quiz-qcard-instruction">
                                        🔘 Chọn một đáp án đúng nhất
                                    </div>
                                    <div class="quiz-options-group">
                                        <c:forEach var="o" items="${q.options}" varStatus="optSt">
                                            <label class="quiz-opt-select" onclick="markAnswered(${q.questionId}, this.closest('.quiz-test-qcard'))">
                                                <input type="radio" name="answer_${q.questionId}" value="${o.optionId}">
                                                <span class="quiz-opt-letter">${letters[optSt.index]}</span>
                                                <span class="quiz-opt-text"><c:out value="${o.content}"/></span>
                                            </label>
                                        </c:forEach>
                                    </div>
                                </c:when>

                                <%-- 2. MULTIPLE_CHOICE --%>
                                <c:when test="${q.type eq 'MULTIPLE_CHOICE'}">
                                    <div class="quiz-qcard-instruction">
                                        ☑️ Chọn tất cả các đáp án đúng
                                    </div>
                                    <div class="quiz-options-group">
                                        <c:forEach var="o" items="${q.options}" varStatus="optSt">
                                            <label class="quiz-opt-select" onclick="markAnswered(${q.questionId}, this.closest('.quiz-test-qcard'))">
                                                <input type="checkbox" name="answer_${q.questionId}" value="${o.optionId}">
                                                <span class="quiz-opt-letter">${letters[optSt.index]}</span>
                                                <span class="quiz-opt-text"><c:out value="${o.content}"/></span>
                                            </label>
                                        </c:forEach>
                                    </div>
                                </c:when>

                                <%-- 3. TRUE_FALSE --%>
                                <c:when test="${q.type eq 'TRUE_FALSE'}">
                                    <div class="quiz-qcard-instruction">
                                        ⚖️ Nhận định trên là Đúng hay Sai?
                                    </div>
                                    <div class="quiz-options-group quiz-options-group--tf">
                                        <label class="quiz-opt-select" onclick="markAnswered(${q.questionId}, this.closest('.quiz-test-qcard'))">
                                            <input type="radio" name="answer_${q.questionId}" value="true">
                                            <span class="quiz-opt-letter">T</span>
                                            <span class="quiz-opt-text">✅ Đúng (True)</span>
                                        </label>
                                        <label class="quiz-opt-select" onclick="markAnswered(${q.questionId}, this.closest('.quiz-test-qcard'))">
                                            <input type="radio" name="answer_${q.questionId}" value="false">
                                            <span class="quiz-opt-letter">F</span>
                                            <span class="quiz-opt-text">❌ Sai (False)</span>
                                        </label>
                                    </div>
                                </c:when>

                                <%-- 4. SHORT_ANSWER --%>
                                <c:when test="${q.type eq 'SHORT_ANSWER'}">
                                    <div class="quiz-qcard-instruction">
                                        ✍️ Điền câu trả lời ngắn vào ô bên dưới
                                    </div>
                                    <input type="text" name="answer_${q.questionId}"
                                           class="quiz-input-field"
                                           placeholder="Nhập câu trả lời ngắn của bạn tại đây..."
                                           oninput="markAnswered(${q.questionId}, this.closest('.quiz-test-qcard'))">
                                </c:when>

                                <%-- 5. ESSAY --%>
                                <c:otherwise>
                                    <div class="quiz-qcard-instruction">
                                        📝 Trả lời tự luận
                                    </div>
                                    <textarea name="answer_${q.questionId}" rows="6"
                                              class="quiz-textarea-field"
                                              placeholder="Trình bày chi tiết câu trả lời của bạn tại đây..."
                                              oninput="markAnswered(${q.questionId}, this.closest('.quiz-test-qcard'))"></textarea>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </c:forEach>

                    <!-- Khối Nộp bài kiểm tra -->
                    <div class="quiz-submit-card" id="submitZone">
                        <div class="quiz-submit-card__icon">🏁</div>
                        <h3 class="quiz-submit-card__title">Sẵn sàng nộp bài thi?</h3>
                        <p class="quiz-submit-card__sub">
                            Hãy kiểm tra lại tất cả các câu trả lời và câu đã đánh dấu xem lại trước khi nộp. Sau khi nộp bài, bạn sẽ không thể thay đổi đáp án.
                        </p>
                        <div id="unansweredWarning" class="quiz-submit-warning" style="display:none;"></div>
                        <div>
                            <button class="quiz-btn quiz-btn--primary quiz-btn--lg" type="button" onclick="confirmSubmit()">
                                Nộp bài kiểm tra ngay
                            </button>
                        </div>
                    </div>
                </section>

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
var attemptId = ${attemptId};
var answeredSet = new Set();
var flaggedSet = new Set();

// Khôi phục danh sách câu hỏi đã đánh dấu từ localStorage
try {
    var savedFlags = JSON.parse(localStorage.getItem('quiz_flagged_' + attemptId) || '[]');
    if (Array.isArray(savedFlags)) {
        savedFlags.forEach(function(qid) {
            flaggedSet.add(Number(qid));
        });
    }
} catch(e) {}

function applyFlagState(qid) {
    var isFlagged = flaggedSet.has(qid);
    var card = document.getElementById('qcard-' + qid);
    var navBtn = document.getElementById('navbtn-' + qid);
    var flagBtn = document.getElementById('flagbtn-' + qid);

    if (card) card.classList.toggle('flagged', isFlagged);
    if (navBtn) navBtn.classList.toggle('flagged', isFlagged);
    if (flagBtn) {
        flagBtn.classList.toggle('active', isFlagged);
        var textEl = flagBtn.querySelector('.quiz-flag-text');
        if (textEl) textEl.textContent = isFlagged ? 'Đã đánh dấu' : 'Đánh dấu';
    }
    updateFlaggedCount();
}

function toggleFlag(qid) {
    if (flaggedSet.has(qid)) {
        flaggedSet.delete(qid);
    } else {
        flaggedSet.add(qid);
    }
    applyFlagState(qid);
    try {
        localStorage.setItem('quiz_flagged_' + attemptId, JSON.stringify(Array.from(flaggedSet)));
    } catch(e) {}
}

function updateFlaggedCount() {
    var count = flaggedSet.size;
    var badge = document.getElementById('flaggedBadge');
    var countEl = document.getElementById('flaggedCount');
    if (badge && countEl) {
        countEl.textContent = count;
        badge.style.display = count > 0 ? 'inline-flex' : 'none';
    }
}

// Khôi phục trạng thái đánh dấu và trạng thái đã trả lời ngay khi nạp trang
document.addEventListener('DOMContentLoaded', function() {
    flaggedSet.forEach(function(qid) {
        applyFlagState(qid);
    });
    updateFlaggedCount();

    // Khởi tạo trạng thái đã chọn cho các câu hỏi nếu đang mở lại bài làm
    document.querySelectorAll('.quiz-test-qcard').forEach(function(card) {
        var qid = parseInt(card.getAttribute('data-qid'));
        if (qid) {
            checkQuestionAnswered(qid, card);
        }
    });

    // Tự động làm nổi bật câu hỏi đang hiển thị trên màn hình trong mục lục
    if ('IntersectionObserver' in window) {
        var observer = new IntersectionObserver(function(entries) {
            entries.forEach(function(entry) {
                if (entry.isIntersecting) {
                    var qid = entry.target.getAttribute('data-qid');
                    if (qid) {
                        document.querySelectorAll('.quiz-palette-btn').forEach(function(b) { b.classList.remove('current'); });
                        var navBtn = document.getElementById('navbtn-' + qid);
                        if (navBtn) navBtn.classList.add('current');
                    }
                }
            });
        }, { rootMargin: '-70px 0px -65% 0px', threshold: 0.05 });

        document.querySelectorAll('.quiz-test-qcard').forEach(function(card) {
            observer.observe(card);
        });
    }
});

function checkQuestionAnswered(qid, card) {
    if (!card) card = document.getElementById('qcard-' + qid);
    if (!card) return;
    var isAnswered = false;
    var choiceInputs = card.querySelectorAll('input[type="radio"], input[type="checkbox"]');
    if (choiceInputs.length > 0) {
        choiceInputs.forEach(function(inp) {
            if (inp.checked) {
                isAnswered = true;
                var p = inp.closest('.quiz-opt-select');
                if (p) p.classList.add('selected');
            }
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
    var palFill = document.getElementById('paletteProgressFill');
    if (palFill) palFill.style.width = pct + '%';
}

function scrollToQuestion(qid) {
    var el = document.getElementById('qcard-' + qid);
    if (el) {
        var headerOffset = 80;
        var elementPosition = el.getBoundingClientRect().top;
        var offsetPosition = elementPosition + window.pageYOffset - headerOffset;
        window.scrollTo({
            top: offsetPosition,
            behavior: 'smooth'
        });
        document.querySelectorAll('.quiz-palette-btn').forEach(function(b) { b.classList.remove('current'); });
        var navBtn = document.getElementById('navbtn-' + qid);
        if (navBtn) navBtn.classList.add('current');
    }
}

function scrollToSubmit() {
    var el = document.getElementById('submitZone');
    if (el) {
        var headerOffset = 80;
        var elementPosition = el.getBoundingClientRect().top;
        var offsetPosition = elementPosition + window.pageYOffset - headerOffset;
        window.scrollTo({
            top: offsetPosition,
            behavior: 'smooth'
        });
    }
}

function confirmSubmit() {
    var unanswered = [];
    var navBtns = document.querySelectorAll('.quiz-palette-btn:not(.answered)');
    navBtns.forEach(function(d) {
        unanswered.push(d.textContent.trim());
    });

    var flaggedCount = flaggedSet.size;
    var flaggedMsg = flaggedCount > 0 ? '\n(Lưu ý: Bạn đang có ' + flaggedCount + ' câu hỏi được đánh dấu cần xem lại).' : '';

    if (unanswered.length > 0) {
        var warn = document.getElementById('unansweredWarning');
        warn.style.display = 'block';
        warn.textContent = '⚠️ Bạn còn ' + unanswered.length + ' câu chưa trả lời (Câu số ' + unanswered.join(', ') + '). Những câu này sẽ được tính 0 điểm.' + (flaggedCount > 0 ? ' Và có ' + flaggedCount + ' câu đang đánh dấu xem lại.' : '');
        if (!confirm('Bạn còn ' + unanswered.length + ' câu chưa trả lời (Câu số ' + unanswered.join(', ') + ').' + flaggedMsg + '\n\nBạn có chắc chắn muốn nộp bài?')) return;
    } else {
        if (!confirm('Bạn đã hoàn thành đủ ' + totalQuestions + ' câu hỏi.' + flaggedMsg + '\n\nNộp bài ngay bây giờ?')) return;
    }

    try {
        localStorage.removeItem('quiz_flagged_' + attemptId);
    } catch(e) {}

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
