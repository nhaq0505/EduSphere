<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Xây dựng Quiz: <c:out value="${quiz.title}"/> — EduSphere</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/home.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/instructor.css">
    <style>
        /* ── Builder Layout ── */
        .qb-layout { display:grid; grid-template-columns:1fr 340px; gap:24px; align-items:start; }
        @media(max-width:960px){ .qb-layout{ grid-template-columns:1fr; } }

        /* ── Tabs ── */
        .qb-tabs { display:flex; gap:0; border-bottom:2px solid #E2E8F0; margin-bottom:24px; }
        .qb-tab { padding:10px 22px; font-weight:700; font-size:.9rem; cursor:pointer;
                  color:#64748B; border-bottom:2px solid transparent; margin-bottom:-2px;
                  background:none; border-top:none; border-left:none; border-right:none;
                  transition:color .15s,border-color .15s; }
        .qb-tab.active { color:#2563EB; border-bottom-color:#2563EB; }

        /* ── Panels ── */
        .qb-panel { display:none; } .qb-panel.active { display:block; }

        /* ── Settings card ── */
        .qb-card { background:#fff; border:1px solid #E2E8F0; border-radius:12px; padding:22px 24px; margin-bottom:20px; }
        .qb-card__title { font-size:.78rem; font-weight:700; color:#94A3B8; text-transform:uppercase; letter-spacing:.06em; margin:0 0 16px; }
        .qb-field { margin-bottom:16px; }
        .qb-field label { font-size:.82rem; font-weight:700; color:#475569; display:block; margin-bottom:5px; }
        .qb-input { width:100%; box-sizing:border-box; border:1.5px solid #E2E8F0; border-radius:8px;
                    padding:9px 12px; font-size:.88rem; font-family:inherit; }
        .qb-input:focus { outline:none; border-color:#3B82F6; }
        .qb-grid-2 { display:grid; grid-template-columns:1fr 1fr; gap:14px; }
        .qb-grid-3 { display:grid; grid-template-columns:1fr 1fr 1fr; gap:14px; }
        @media(max-width:640px){ .qb-grid-2,.qb-grid-3{ grid-template-columns:1fr; } }
        .qb-toggle { display:flex; align-items:center; gap:10px; cursor:pointer; user-select:none; }
        .qb-toggle input[type=checkbox] { width:18px; height:18px; accent-color:#2563EB; cursor:pointer; }

        /* ── Status badge ── */
        .qb-status-badge {
            display:inline-flex; align-items:center; gap:6px;
            padding:4px 12px; border-radius:20px; font-size:.78rem; font-weight:700;
        }
        .qb-status-badge--draft { background:#F1F5F9; color:#475569; }
        .qb-status-badge--published { background:#DCFCE7; color:#166534; }
        .qb-status-badge--archived { background:#F1F5F9; color:#6B7280; }

        /* ── Question list ── */
        .qb-question-card {
            background:#fff; border:1.5px solid #E2E8F0; border-radius:12px;
            padding:18px 20px; margin-bottom:14px; transition:border-color .15s;
        }
        .qb-question-card:hover { border-color:#3B82F6; }
        .qb-question-card__header {
            display:flex; align-items:flex-start; justify-content:space-between; gap:12px;
        }
        .qb-question-card__num {
            background:#EFF6FF; color:#2563EB; font-weight:800; font-size:.82rem;
            padding:3px 10px; border-radius:20px; white-space:nowrap; flex-shrink:0; margin-top:2px;
        }
        .qb-question-card__content {
            flex:1; font-weight:600; font-size:.92rem; color:#0F172A; line-height:1.5;
            white-space:pre-line;
        }
        .qb-question-card__actions { display:flex; gap:6px; flex-shrink:0; }
        .qb-action-btn {
            border:1.5px solid #E2E8F0; background:#fff; border-radius:6px;
            padding:5px 10px; font-size:.78rem; font-weight:700; cursor:pointer;
            color:#475569; transition:all .15s;
        }
        .qb-action-btn:hover { border-color:#3B82F6; color:#2563EB; }
        .qb-action-btn--danger:hover { border-color:#EF4444; color:#DC2626; }
        .qb-question-meta {
            display:flex; flex-wrap:wrap; gap:8px; margin-top:10px;
            font-size:.78rem; color:#64748B;
        }
        .qb-type-badge {
            padding:2px 10px; border-radius:20px; font-weight:700;
            background:#F1F5F9; color:#334155;
        }
        .qb-options { margin-top:12px; list-style:none; padding:0; }
        .qb-options li {
            display:flex; align-items:center; gap:8px;
            padding:7px 12px; border-radius:6px; margin-bottom:5px;
            background:#F8FAFC; font-size:.87rem; border:1px solid #E2E8F0;
        }
        .qb-options li.correct { background:#DCFCE7; border-color:#86EFAC; font-weight:600; color:#166534; }
        .qb-options li.correct::before { content:"✓"; font-weight:900; }
        .qb-options li:not(.correct)::before { content:"○"; color:#94A3B8; }
        .qb-explanation {
            margin-top:10px; background:#FFFBEB; border:1px solid #FDE68A;
            border-radius:8px; padding:10px 14px; font-size:.82rem; color:#78350F;
        }

        /* ── Add question form ── */
        .qb-add-form {
            background:#F8FAFC; border:2px dashed #CBD5E1; border-radius:12px;
            padding:24px; margin-top:14px;
        }
        .qb-add-form.hidden { display:none; }
        .qb-type-select { display:grid; grid-template-columns:repeat(5, 1fr); gap:8px; margin-bottom:16px; }
        @media(max-width:640px){ .qb-type-select{ grid-template-columns:1fr 1fr; } }
        .qb-type-card {
            border:2px solid #E2E8F0; border-radius:8px; padding:10px 8px;
            text-align:center; cursor:pointer; transition:all .15s;
            font-size:.78rem; font-weight:700; color:#475569;
        }
        .qb-type-card:hover, .qb-type-card.selected { border-color:#2563EB; background:#EFF6FF; color:#2563EB; }
        .qb-type-card .icon { font-size:1.2rem; display:block; margin-bottom:4px; }
        .qb-options-builder { margin-top:12px; }
        .qb-option-row { display:flex; align-items:center; gap:8px; margin-bottom:8px; }
        .qb-option-row .qb-input { flex:1; }
        .qb-correct-toggle {
            width:36px; height:36px; border-radius:6px; border:2px solid #E2E8F0;
            display:flex; align-items:center; justify-content:center; cursor:pointer;
            font-weight:900; font-size:.9rem; flex-shrink:0; transition:all .15s;
        }
        .qb-correct-toggle.active { background:#DCFCE7; border-color:#16A34A; color:#16A34A; }
        .qb-correct-toggle:not(.active) { color:#94A3B8; }
        .qb-remove-btn {
            width:30px; height:30px; border:none; background:none; cursor:pointer;
            color:#94A3B8; font-size:1.1rem; display:flex; align-items:center; justify-content:center;
        }
        .qb-remove-btn:hover { color:#DC2626; }

        /* ── Aside ── */
        .qb-aside { position:sticky; top:24px; }
        .qb-aside-card { background:#fff; border:1px solid #E2E8F0; border-radius:12px; overflow:hidden; margin-bottom:16px; }
        .qb-aside-head { background:#0F172A; color:#fff; padding:13px 18px; font-weight:700; font-size:.88rem; }
        .qb-aside-body { padding:16px 18px; }
        .qb-aside-stat { display:flex; justify-content:space-between; align-items:center; padding:6px 0; border-bottom:1px solid #F1F5F9; font-size:.85rem; }
        .qb-aside-stat:last-child { border-bottom:none; }
        .qb-aside-stat span:last-child { font-weight:700; color:#0F172A; }

        /* ── Buttons ── */
        .qb-btn-primary {
            display:inline-flex; align-items:center; gap:6px;
            background:#2563EB; color:#fff; border:none; border-radius:8px;
            padding:10px 20px; font-size:.88rem; font-weight:700; cursor:pointer;
        }
        .qb-btn-primary:hover { background:#1D4ED8; }
        .qb-btn-success {
            display:inline-flex; align-items:center; gap:6px;
            background:#16A34A; color:#fff; border:none; border-radius:8px;
            padding:10px 20px; font-size:.88rem; font-weight:700; cursor:pointer;
        }
        .qb-btn-success:hover { background:#15803D; }
        .qb-btn-outline {
            display:inline-flex; align-items:center; gap:6px;
            background:#fff; color:#475569; border:1.5px solid #E2E8F0; border-radius:8px;
            padding:9px 18px; font-size:.88rem; font-weight:700; cursor:pointer; text-decoration:none;
        }
        .qb-btn-outline:hover { border-color:#3B82F6; color:#2563EB; }

        /* ── Inline hint ── */
        .qb-hint { font-size:.78rem; color:#94A3B8; margin-top:4px; }
    </style>
</head>
<body>
<jsp:include page="/WEB-INF/views/courses/ins-header.jsp"/>
<div class="ins-shell">
    <jsp:include page="/WEB-INF/views/courses/ins-sidebar.jsp"/>
    <main class="ins-content">

        <!-- Breadcrumb -->
        <a class="ins-back-link" href="${pageContext.request.contextPath}/instructor/courses/${courseId}/quizzes">
            ← Danh sách Quiz
        </a>

        <!-- Page heading -->
        <div class="ins-page-head" style="margin-bottom:20px;">
            <div>
                <div style="display:flex;align-items:center;gap:10px;margin-bottom:4px;">
                    <c:choose>
                        <c:when test="${quiz.status eq 'DRAFT'}">
                            <span class="qb-status-badge qb-status-badge--draft">📝 Bản nháp</span>
                        </c:when>
                        <c:when test="${quiz.status eq 'PUBLISHED'}">
                            <span class="qb-status-badge qb-status-badge--published">✅ Đã công bố</span>
                        </c:when>
                        <c:otherwise>
                            <span class="qb-status-badge qb-status-badge--archived">📦 Lưu trữ</span>
                        </c:otherwise>
                    </c:choose>
                </div>
                <h1 class="ins-page-head__title" style="margin:0 0 2px;"><c:out value="${quiz.title}"/></h1>
                <p style="font-size:.85rem;color:#64748B;margin:0;">
                    <c:if test="${quiz.timeLimitMinutes != null}">⏱ ${quiz.timeLimitMinutes} phút · </c:if>
                    🔄 Tối đa ${quiz.maxAttempts} lần làm ·
                    📊 ${fn:length(questions)} câu hỏi
                    <c:if test="${quiz.passingScore != null}"> · 🎯 Qua bài: ${quiz.passingScore}%</c:if>
                </p>
            </div>
            <div style="display:flex;gap:8px;flex-wrap:wrap;">
                <c:if test="${quiz.status eq 'DRAFT'}">
                    <form method="post" action="${pageContext.request.contextPath}/instructor/courses/${courseId}/quizzes/${quizId}/publish" style="margin:0">
                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                        <button type="submit" class="qb-btn-success">🚀 Công bố Quiz</button>
                    </form>
                </c:if>
                <c:if test="${quiz.status eq 'PUBLISHED'}">
                    <a class="qb-btn-outline" href="${pageContext.request.contextPath}/instructor/courses/${courseId}/quizzes/${quizId}/attempts">
                        📋 Bài làm học viên
                    </a>
                    <form method="post" action="${pageContext.request.contextPath}/instructor/courses/${courseId}/quizzes/${quizId}/archive" style="margin:0">
                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                        <button type="submit" class="qb-btn-outline" style="color:#DC2626;border-color:#FCA5A5;">📦 Lưu trữ</button>
                    </form>
                </c:if>
                <c:if test="${quiz.status eq 'ARCHIVED'}">
                    <form method="post" action="${pageContext.request.contextPath}/instructor/courses/${courseId}/quizzes/${quizId}/restore" style="margin:0">
                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                        <button type="submit" class="qb-btn-success">♻️ Khôi phục Quiz</button>
                    </form>
                </c:if>
            </div>
        </div>

        <c:if test="${not empty success}">
            <div class="ins-alert ins-alert--success" style="margin-bottom:20px;">✅ <c:out value="${success}"/></div>
        </c:if>

        <!-- Tab navigation -->
        <div class="qb-tabs">
            <button class="qb-tab active" id="tab-questions" onclick="qbTab('questions')">
                ❓ Danh sách câu hỏi (${fn:length(questions)})
            </button>
            <button class="qb-tab" id="tab-settings" onclick="qbTab('settings')">
                ⚙️ Cài đặt Quiz
            </button>
        </div>

        <div class="qb-layout">
            <!-- ══ MAIN ══ -->
            <div>

                <%-- ════ TAB: QUESTIONS ════ --%>
                <div class="qb-panel active" id="panel-questions">

                    <c:choose>
                        <c:when test="${empty questions}">
                            <div class="ins-empty" style="padding:40px 20px;text-align:center;">
                                <div style="font-size:2.5rem;margin-bottom:12px;">❓</div>
                                <h3 style="margin:0 0 6px;">Chưa có câu hỏi nào</h3>
                                <p style="color:#64748B;margin:0 0 18px;">Thêm câu hỏi đầu tiên để bắt đầu xây dựng bài kiểm tra.</p>
                                <button class="qb-btn-primary" onclick="qbShowAddForm()">➕ Thêm câu hỏi đầu tiên</button>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <c:forEach var="q" items="${questions}" varStatus="vs">
                                <div class="qb-question-card" id="qcard-${q.questionId}">
                                    <div class="qb-question-card__header">
                                        <span class="qb-question-card__num">Câu ${q.orderIndex}</span>
                                        <div class="qb-question-card__content"><c:out value="${q.content}"/></div>
                                        <div class="qb-question-card__actions">
                                            <%-- Move up --%>
                                            <c:if test="${q.orderIndex > 1}">
                                                <form method="post"
                                                      action="${pageContext.request.contextPath}/instructor/courses/${courseId}/quizzes/${quizId}/questions/${q.questionId}/move"
                                                      style="margin:0">
                                                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                                                    <input type="hidden" name="direction" value="up"/>
                                                    <button type="submit" class="qb-action-btn" title="Lên">↑</button>
                                                </form>
                                            </c:if>
                                            <%-- Move down --%>
                                            <c:if test="${q.orderIndex < fn:length(questions)}">
                                                <form method="post"
                                                      action="${pageContext.request.contextPath}/instructor/courses/${courseId}/quizzes/${quizId}/questions/${q.questionId}/move"
                                                      style="margin:0">
                                                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                                                    <input type="hidden" name="direction" value="down"/>
                                                    <button type="submit" class="qb-action-btn" title="Xuống">↓</button>
                                                </form>
                                            </c:if>
                                            <%-- Edit --%>
                                            <a class="qb-action-btn"
                                               href="${pageContext.request.contextPath}/instructor/courses/${courseId}/quizzes/${quizId}/questions/${q.questionId}/edit">
                                                ✏️
                                            </a>
                                            <%-- Delete --%>
                                            <form method="post"
                                                  action="${pageContext.request.contextPath}/instructor/courses/${courseId}/quizzes/${quizId}/questions/${q.questionId}/delete"
                                                  style="margin:0"
                                                  onsubmit="return confirm('Xóa câu hỏi này?')">
                                                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                                                <button type="submit" class="qb-action-btn qb-action-btn--danger" title="Xóa">🗑️</button>
                                            </form>
                                        </div>
                                    </div>

                                    <div class="qb-question-meta">
                                        <span class="qb-type-badge">
                                            <c:choose>
                                                <c:when test="${q.type eq 'SINGLE_CHOICE'}">🔘 Một lựa chọn</c:when>
                                                <c:when test="${q.type eq 'MULTIPLE_CHOICE'}">☑️ Nhiều lựa chọn</c:when>
                                                <c:when test="${q.type eq 'TRUE_FALSE'}">⚖️ Đúng / Sai</c:when>
                                                <c:when test="${q.type eq 'SHORT_ANSWER'}">✍️ Trả lời ngắn</c:when>
                                                <c:otherwise>📝 Tự luận</c:otherwise>
                                            </c:choose>
                                        </span>
                                        <span>⭐ <fmt:formatNumber value="${q.score}" maxFractionDigits="1"/> điểm</span>
                                    </div>

                                    <%-- Options --%>
                                    <c:if test="${not empty q.options}">
                                        <ul class="qb-options">
                                            <c:forEach var="opt" items="${q.options}">
                                                <li class="${opt.correct ? 'correct' : ''}">
                                                    <c:out value="${opt.content}"/>
                                                </li>
                                            </c:forEach>
                                        </ul>
                                    </c:if>

                                    <%-- TRUE_FALSE correct answer --%>
                                    <c:if test="${q.type eq 'TRUE_FALSE' and not empty q.correctAnswer}">
                                        <div style="margin-top:8px;font-size:.85rem;">
                                            Đáp án đúng: <strong style="color:#16A34A;">
                                                <c:choose>
                                                    <c:when test="${q.correctAnswer eq 'true'}">✅ Đúng</c:when>
                                                    <c:otherwise>❌ Sai</c:otherwise>
                                                </c:choose>
                                            </strong>
                                        </div>
                                    </c:if>
                                    <c:if test="${q.type eq 'SHORT_ANSWER' and not empty q.correctAnswer}">
                                        <div style="margin-top:8px;font-size:.85rem;">
                                            Đáp án tham khảo: <strong><c:out value="${q.correctAnswer}"/></strong>
                                        </div>
                                    </c:if>

                                    <%-- Explanation --%>
                                    <c:if test="${not empty q.explanation}">
                                        <div class="qb-explanation">
                                            💡 <strong>Giải thích:</strong> <c:out value="${q.explanation}"/>
                                        </div>
                                    </c:if>
                                </div>
                            </c:forEach>
                        </c:otherwise>
                    </c:choose>

                    <%-- Add question button / form trigger --%>
                    <div style="margin-top:16px;">
                        <button class="qb-btn-primary" onclick="qbShowAddForm()" id="btnAddQuestion">
                            ➕ Thêm câu hỏi mới
                        </button>
                    </div>

                    <%-- Inline Add Question Form --%>
                    <div class="qb-add-form hidden" id="addQuestionForm">
                        <h3 style="margin:0 0 16px;font-size:1rem;">➕ Thêm câu hỏi mới</h3>
                        <form method="post" action="${pageContext.request.contextPath}/instructor/courses/${courseId}/quizzes/${quizId}/questions">
                            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>

                            <%-- Type selector --%>
                            <div style="margin-bottom:16px;">
                                <label style="font-size:.82rem;font-weight:700;color:#475569;display:block;margin-bottom:8px;">
                                    Loại câu hỏi
                                </label>
                                <div class="qb-type-select" id="typeSelectorCards">
                                    <div class="qb-type-card selected" onclick="qbSelectType('SINGLE_CHOICE', this)">
                                        <span class="icon">🔘</span>Một lựa chọn
                                    </div>
                                    <div class="qb-type-card" onclick="qbSelectType('MULTIPLE_CHOICE', this)">
                                        <span class="icon">☑️</span>Nhiều lựa chọn
                                    </div>
                                    <div class="qb-type-card" onclick="qbSelectType('TRUE_FALSE', this)">
                                        <span class="icon">⚖️</span>Đúng / Sai
                                    </div>
                                    <div class="qb-type-card" onclick="qbSelectType('SHORT_ANSWER', this)">
                                        <span class="icon">✍️</span>Trả lời ngắn
                                    </div>
                                    <div class="qb-type-card" onclick="qbSelectType('ESSAY', this)">
                                        <span class="icon">📝</span>Tự luận
                                    </div>
                                </div>
                                <input type="hidden" name="type" id="qbTypeInput" value="SINGLE_CHOICE"/>
                            </div>

                            <div class="qb-grid-2" style="margin-bottom:16px;">
                                <div class="qb-field">
                                    <label>Nội dung câu hỏi <span style="color:red">*</span></label>
                                    <textarea class="qb-input" name="content" rows="3" required
                                              placeholder="Nhập nội dung câu hỏi..."></textarea>
                                </div>
                                <div class="qb-field">
                                    <label>Điểm <span style="color:red">*</span></label>
                                    <input class="qb-input" type="number" name="score" min="0.5" step="0.5" value="1" required style="margin-bottom:8px;">
                                    <label>Giải thích đáp án (tùy chọn)</label>
                                    <textarea class="qb-input" name="explanation" rows="2"
                                              placeholder="Hiển thị cho học viên sau khi nộp bài..."></textarea>
                                </div>
                            </div>

                            <%-- Options box for SINGLE / MULTIPLE --%>
                            <div id="qbOptionsBox" class="qb-options-builder">
                                <label style="font-size:.82rem;font-weight:700;color:#475569;display:block;margin-bottom:8px;">
                                    Các lựa chọn đáp án
                                    <span style="font-weight:400;color:#94A3B8;">(nhấn ✓ để đánh dấu đúng)</span>
                                </label>
                                <div id="qbOptionRows">
                                    <div class="qb-option-row">
                                        <input class="qb-input" type="text" name="optionContents" placeholder="A. Lựa chọn 1">
                                        <input type="hidden" name="optionCorrects" id="correct_0" value="false">
                                        <div class="qb-correct-toggle" onclick="qbToggleCorrect(this, 0)">✓</div>
                                        <button type="button" class="qb-remove-btn" onclick="qbRemoveOption(this)">×</button>
                                    </div>
                                    <div class="qb-option-row">
                                        <input class="qb-input" type="text" name="optionContents" placeholder="B. Lựa chọn 2">
                                        <input type="hidden" name="optionCorrects" id="correct_1" value="false">
                                        <div class="qb-correct-toggle" onclick="qbToggleCorrect(this, 1)">✓</div>
                                        <button type="button" class="qb-remove-btn" onclick="qbRemoveOption(this)">×</button>
                                    </div>
                                    <div class="qb-option-row">
                                        <input class="qb-input" type="text" name="optionContents" placeholder="C. Lựa chọn 3">
                                        <input type="hidden" name="optionCorrects" id="correct_2" value="false">
                                        <div class="qb-correct-toggle" onclick="qbToggleCorrect(this, 2)">✓</div>
                                        <button type="button" class="qb-remove-btn" onclick="qbRemoveOption(this)">×</button>
                                    </div>
                                    <div class="qb-option-row">
                                        <input class="qb-input" type="text" name="optionContents" placeholder="D. Lựa chọn 4">
                                        <input type="hidden" name="optionCorrects" id="correct_3" value="false">
                                        <div class="qb-correct-toggle" onclick="qbToggleCorrect(this, 3)">✓</div>
                                        <button type="button" class="qb-remove-btn" onclick="qbRemoveOption(this)">×</button>
                                    </div>
                                </div>
                                <button type="button" onclick="qbAddOptionRow()" class="qb-btn-outline" style="margin-top:8px;padding:6px 14px;font-size:.82rem;">
                                    + Thêm lựa chọn
                                </button>
                            </div>

                            <%-- TRUE_FALSE box --%>
                            <div id="qbTfBox" style="display:none;" class="qb-field">
                                <label>Đáp án đúng</label>
                                <select class="qb-input" name="correctAnswer" style="max-width:200px;">
                                    <option value="true">✅ Đúng (True)</option>
                                    <option value="false">❌ Sai (False)</option>
                                </select>
                            </div>

                            <%-- SHORT_ANSWER box --%>
                            <div id="qbShortBox" style="display:none;" class="qb-field">
                                <label>Đáp án tham khảo (hệ thống không tự chấm)</label>
                                <input class="qb-input" type="text" name="correctAnswer"
                                       placeholder="Đáp án mẫu để giảng viên tham khảo khi chấm tay...">
                            </div>

                            <div style="display:flex;gap:10px;margin-top:18px;">
                                <button type="submit" class="qb-btn-primary">💾 Lưu câu hỏi</button>
                                <button type="button" class="qb-btn-outline" onclick="qbHideAddForm()">Hủy</button>
                            </div>
                        </form>
                    </div>

                </div><%-- END panel-questions --%>

                <%-- ════ TAB: SETTINGS ════ --%>
                <div class="qb-panel" id="panel-settings">
                    <form method="post" action="${pageContext.request.contextPath}/instructor/courses/${courseId}/quizzes/${quizId}/edit">
                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>

                        <%-- Thông tin chung --%>
                        <div class="qb-card">
                            <p class="qb-card__title">📋 Thông tin chung</p>
                            <div class="qb-field">
                                <label>Tiêu đề bài Quiz <span style="color:red">*</span></label>
                                <input class="qb-input" type="text" name="title" required maxlength="255"
                                       value="<c:out value='${quiz.title}'/>">
                            </div>
                            <div class="qb-field">
                                <label>Mô tả & Hướng dẫn làm bài</label>
                                <textarea class="qb-input" name="description" rows="4" style="resize:vertical"
                                          placeholder="Nêu mục đích, phạm vi kiến thức, hoặc lưu ý cho học viên..."><c:out value="${quiz.description}"/></textarea>
                            </div>
                            <div class="qb-field">
                                <label>Quy định làm bài</label>
                                <textarea class="qb-input" name="rules" rows="3" style="resize:vertical"
                                          placeholder="VD: Không được dùng tài liệu, không được tra Google..."><c:out value="${quiz.rules}"/></textarea>
                            </div>
                        </div>

                        <%-- Thời gian --%>
                        <div class="qb-card">
                            <p class="qb-card__title">⏱ Cài đặt thời gian</p>
                            <div class="qb-grid-2">
                                <div class="qb-field">
                                    <label>Giới hạn thời gian (phút)</label>
                                    <input class="qb-input" type="number" name="timeLimitMinutes" min="1"
                                           value="${quiz.timeLimitMinutes}"
                                           placeholder="Để trống = không giới hạn">
                                    <p class="qb-hint">Ví dụ: 15, 30, 45, 60 phút. Để trống nếu không giới hạn.</p>
                                </div>
                                <div class="qb-field">
                                    <label>Số lần làm tối đa</label>
                                    <input class="qb-input" type="number" name="maxAttempts" min="1"
                                           value="${quiz.maxAttempts != null ? quiz.maxAttempts : 1}">
                                    <p class="qb-hint">Nhập 1 để chỉ cho phép làm 1 lần.</p>
                                </div>
                            </div>
                            <div class="qb-grid-3">
                                <div class="qb-field">
                                    <label>Thời điểm mở bài</label>
                                    <input class="qb-input" type="datetime-local" name="startTime"
                                           value="<c:if test='${quiz.startTime != null}'><c:out value='${quiz.startTime}'/></c:if>">
                                </div>
                                <div class="qb-field">
                                    <label>Hạn làm bài (due date)</label>
                                    <input class="qb-input" type="datetime-local" name="dueDate"
                                           value="<c:if test='${quiz.dueDate != null}'><c:out value='${quiz.dueDate}'/></c:if>">
                                </div>
                                <div class="qb-field">
                                    <label>Thời điểm đóng bài</label>
                                    <input class="qb-input" type="datetime-local" name="endTime"
                                           value="<c:if test='${quiz.endTime != null}'><c:out value='${quiz.endTime}'/></c:if>">
                                </div>
                            </div>
                        </div>

                        <%-- Quy chế --%>
                        <div class="qb-card">
                            <p class="qb-card__title">🎯 Quy chế làm bài</p>
                            <div class="qb-grid-2">
                                <div class="qb-field">
                                    <label>Điểm đạt yêu cầu (%)</label>
                                    <input class="qb-input" type="number" name="passingScore"
                                           min="0" max="100" step="1"
                                           value="${quiz.passingScore}"
                                           placeholder="Để trống = không yêu cầu">
                                    <p class="qb-hint">VD: 50 = phải đạt 50% tổng điểm mới tính hoàn thành.</p>
                                </div>
                                <div>
                                    <div class="qb-field">
                                        <label class="qb-toggle">
                                            <input type="checkbox" name="shuffleQuestions" value="true"
                                                   ${quiz.shuffleQuestions ? 'checked' : ''}/>
                                            🔀 Xáo trộn thứ tự câu hỏi
                                        </label>
                                        <p class="qb-hint" style="margin-left:28px;">Mỗi học viên nhận thứ tự câu hỏi khác nhau.</p>
                                    </div>
                                    <div class="qb-field">
                                        <label class="qb-toggle">
                                            <input type="checkbox" name="shuffleOptions" value="true"
                                                   ${quiz.shuffleOptions ? 'checked' : ''}/>
                                            🔀 Xáo trộn thứ tự đáp án
                                        </label>
                                        <p class="qb-hint" style="margin-left:28px;">Thứ tự A/B/C/D thay đổi ngẫu nhiên cho mỗi học viên.</p>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div style="display:flex;gap:10px;">
                            <button type="submit" class="qb-btn-primary">💾 Lưu cài đặt</button>
                            <button type="button" class="qb-btn-outline" onclick="qbTab('questions')">← Quay lại câu hỏi</button>
                        </div>
                    </form>
                </div><%-- END panel-settings --%>

            </div><%-- END main --%>

            <!-- ══ ASIDE ══ -->
            <aside class="qb-aside">
                <div class="qb-aside-card">
                    <div class="qb-aside-head">📊 Tổng quan Quiz</div>
                    <div class="qb-aside-body">
                        <div class="qb-aside-stat">
                            <span>Số câu hỏi</span>
                            <span>${fn:length(questions)} câu</span>
                        </div>
                        <div class="qb-aside-stat">
                            <span>Trạng thái</span>
                            <span>
                                <c:choose>
                                    <c:when test="${quiz.status eq 'DRAFT'}">📝 Bản nháp</c:when>
                                    <c:when test="${quiz.status eq 'PUBLISHED'}">✅ Đã công bố</c:when>
                                    <c:otherwise>📦 Lưu trữ</c:otherwise>
                                </c:choose>
                            </span>
                        </div>
                        <div class="qb-aside-stat">
                            <span>Thời gian</span>
                            <span>
                                <c:choose>
                                    <c:when test="${quiz.timeLimitMinutes != null}">${quiz.timeLimitMinutes} phút</c:when>
                                    <c:otherwise>Không giới hạn</c:otherwise>
                                </c:choose>
                            </span>
                        </div>
                        <div class="qb-aside-stat">
                            <span>Số lần làm</span>
                            <span>${quiz.maxAttempts} lần</span>
                        </div>
                        <c:if test="${quiz.passingScore != null}">
                            <div class="qb-aside-stat">
                                <span>Điểm qua bài</span>
                                <span>${quiz.passingScore}%</span>
                            </div>
                        </c:if>
                        <div class="qb-aside-stat">
                            <span>Xáo trộn câu hỏi</span>
                            <span>${quiz.shuffleQuestions ? '✅ Có' : '❌ Không'}</span>
                        </div>
                        <div class="qb-aside-stat">
                            <span>Xáo trộn đáp án</span>
                            <span>${quiz.shuffleOptions ? '✅ Có' : '❌ Không'}</span>
                        </div>
                    </div>
                </div>

                <%-- Quick actions --%>
                <div class="qb-aside-card">
                    <div class="qb-aside-head">⚡ Thao tác nhanh</div>
                    <div class="qb-aside-body" style="display:flex;flex-direction:column;gap:8px;">
                        <button class="qb-btn-primary" onclick="qbShowAddForm();qbTab('questions');" style="width:100%;justify-content:center;">
                            ➕ Thêm câu hỏi
                        </button>
                        <button class="qb-btn-outline" onclick="qbTab('settings');" style="width:100%;justify-content:center;">
                            ⚙️ Cài đặt Quiz
                        </button>
                        <a class="qb-btn-outline" style="width:100%;justify-content:center;text-align:center;"
                           href="${pageContext.request.contextPath}/instructor/courses/${courseId}/quizzes/${quizId}/attempts">
                            📋 Xem bài làm
                        </a>
                        <a class="qb-btn-outline" style="width:100%;justify-content:center;text-align:center;"
                           href="${pageContext.request.contextPath}/instructor/courses/${courseId}/quizzes">
                            ← Danh sách Quiz
                        </a>
                    </div>
                </div>

                <%-- Tips --%>
                <div style="background:#FFFBEB;border:1px solid #FDE68A;border-radius:10px;padding:14px 16px;font-size:.82rem;color:#78350F;">
                    <strong>💡 Mẹo:</strong><br/>
                    • Câu <strong>Tự luận</strong> và <strong>Trả lời ngắn</strong> cần chấm tay sau khi học viên nộp.<br/>
                    • Bật <strong>Xáo trộn</strong> để chống gian lận hiệu quả.<br/>
                    • Quiz phải có ít nhất 1 câu hỏi để công bố.
                </div>
            </aside>
        </div>

    </main>
</div>

<script>
// ── Tab switching ──
function qbTab(name) {
    document.querySelectorAll('.qb-tab').forEach(t => t.classList.remove('active'));
    document.querySelectorAll('.qb-panel').forEach(p => p.classList.remove('active'));
    document.getElementById('tab-' + name).classList.add('active');
    document.getElementById('panel-' + name).classList.add('active');
}

// ── Add form toggle ──
function qbShowAddForm() {
    var f = document.getElementById('addQuestionForm');
    f.classList.remove('hidden');
    f.scrollIntoView({ behavior: 'smooth', block: 'start' });
    document.getElementById('btnAddQuestion').style.display = 'none';
}
function qbHideAddForm() {
    document.getElementById('addQuestionForm').classList.add('hidden');
    document.getElementById('btnAddQuestion').style.display = '';
}

// ── Type selector ──
function qbSelectType(type, card) {
    document.querySelectorAll('.qb-type-card').forEach(c => c.classList.remove('selected'));
    card.classList.add('selected');
    document.getElementById('qbTypeInput').value = type;

    var choice = type === 'SINGLE_CHOICE' || type === 'MULTIPLE_CHOICE';
    document.getElementById('qbOptionsBox').style.display = choice ? '' : 'none';
    document.getElementById('qbTfBox').style.display = type === 'TRUE_FALSE' ? '' : 'none';
    document.getElementById('qbShortBox').style.display = type === 'SHORT_ANSWER' ? '' : 'none';
}

// ── Correct toggle ──
var correctStates = {};
function qbToggleCorrect(btn, idx) {
    var hidden = document.getElementById('correct_' + idx);
    if (hidden) {
        var newVal = hidden.value !== 'true';
        hidden.value = newVal ? 'true' : 'false';
        btn.classList.toggle('active', newVal);
    }
}

// ── Add / Remove option rows ──
var optionCount = 4;
function qbAddOptionRow() {
    var rows = document.getElementById('qbOptionRows');
    var idx = optionCount++;
    var row = document.createElement('div');
    row.className = 'qb-option-row';
    row.innerHTML =
        '<input class="qb-input" type="text" name="optionContents" placeholder="Lựa chọn ' + (idx + 1) + '">' +
        '<input type="hidden" name="optionCorrects" id="correct_' + idx + '" value="false">' +
        '<div class="qb-correct-toggle" onclick="qbToggleCorrect(this, ' + idx + ')">✓</div>' +
        '<button type="button" class="qb-remove-btn" onclick="qbRemoveOption(this)">×</button>';
    rows.appendChild(row);
}
function qbRemoveOption(btn) {
    var row = btn.closest('.qb-option-row');
    if (document.querySelectorAll('.qb-option-row').length > 2) {
        row.remove();
    } else {
        alert('Cần ít nhất 2 lựa chọn.');
    }
}

// User menu
function toggleUserMenu(e){e.stopPropagation();e.currentTarget.closest('.hn-user-menu').classList.toggle('open');}
document.addEventListener('click',()=>document.querySelectorAll('.hn-user-menu.open').forEach(m=>m.classList.remove('open')));
</script>
</body>
</html>
