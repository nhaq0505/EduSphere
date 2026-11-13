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
<div class="ins-layout">
    <jsp:include page="../courses/ins-sidebar.jsp"/>
    <div class="ins-main-wrapper">
        <jsp:include page="../courses/ins-header.jsp"/>
        <main class="ins-page">

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
                    🔄 Không giới hạn lượt làm ·
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

                    <!-- Fast Action Toolbar -->
                    <div style="background:#fff;border:1.5px solid #E2E8F0;border-radius:12px;padding:14px 18px;margin-bottom:18px;display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:12px;">
                        <div style="font-size:0.9rem;font-weight:700;color:#1e293b;display:flex;align-items:center;gap:8px;">
                            <span>📋 Số câu hỏi trong đề:</span>
                            <span style="font-weight:800;color:#2563EB;">${fn:length(questions)} câu</span>
                        </div>
                        <div style="display:flex;gap:10px;flex-wrap:wrap;">
                            <button type="button" class="qb-btn-primary" style="background:linear-gradient(135deg, #4f46e5, #7c3aed);border:none;box-shadow:0 2px 4px rgba(79,70,229,0.25);" onclick="openAutoGenerateModal()">
                                🎲 Tự động sinh từ Ngân hàng
                            </button>
                            <button type="button" class="qb-btn-primary" style="background:#0284c7;border:none;" onclick="openPickFromBankModal()">
                                📥 Chọn từ Ngân hàng
                            </button>
                            <button type="button" class="qb-btn-primary" onclick="qbShowAddForm()">
                                ➕ Thêm thủ công
                            </button>
                        </div>
                    </div>

                    <c:choose>
                        <c:when test="${empty questions}">
                            <div class="ins-empty" style="padding:40px 20px;text-align:center;">
                                <div style="font-size:2.5rem;margin-bottom:12px;">❓</div>
                                <h3 style="margin:0 0 6px;">Chưa có câu hỏi nào</h3>
                                <p style="color:#64748B;margin:0 0 18px;">Bạn có thể bốc ngẫu nhiên siêu tốc từ ngân hàng câu hỏi hoặc soạn thủ công.</p>
                                <div style="display:flex;justify-content:center;gap:10px;flex-wrap:wrap;">
                                    <button type="button" class="qb-btn-primary" style="background:linear-gradient(135deg, #4f46e5, #7c3aed);border:none;" onclick="openAutoGenerateModal()">
                                        🎲 Tự động sinh ngẫu nhiên
                                    </button>
                                    <button type="button" class="qb-btn-primary" style="background:#0284c7;border:none;" onclick="openPickFromBankModal()">
                                        📥 Chọn từ Ngân hàng
                                    </button>
                                    <button type="button" class="qb-btn-primary" onclick="qbShowAddForm()">➕ Thêm thủ công</button>
                                </div>
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

                                    <c:if test="${not empty q.imageUrl}">
                                        <div style="margin:10px 0;">
                                            <img src="${pageContext.request.contextPath}${q.imageUrl}"
                                                 style="max-height:160px;max-width:320px;border-radius:8px;border:1px solid #E2E8F0;cursor:pointer;object-fit:cover;"
                                                 onclick="zoomImage(this.src)" alt="Minh họa"/>
                                        </div>
                                    </c:if>
                                    <c:if test="${not empty q.videoUrl}">
                                        <div style="margin:6px 0;font-size:0.82rem;color:#4F46E5;">
                                            📹 Video đính kèm: <a href="<c:out value="${q.videoUrl}"/>" target="_blank"><c:out value="${q.videoUrl}"/></a>
                                        </div>
                                    </c:if>
                                    <c:if test="${q.type eq 'ESSAY' and not empty q.sampleEssayAnswer}">
                                        <div style="margin-top:8px;padding:8px 12px;background:#FDF4FF;border-left:3px solid #C026D3;border-radius:4px;font-size:0.83rem;color:#86198F;">
                                            💡 <strong>Gợi ý đáp án / Tiêu chí chấm:</strong> <c:out value="${q.sampleEssayAnswer}"/>
                                        </div>
                                    </c:if>

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
                                        <c:if test="${q.bankQuestion != null}">
                                            <span style="padding:2px 8px;border-radius:12px;background:#E0E7FF;color:#4338CA;font-weight:700;">
                                                📚 Từ Ngân hàng
                                            </span>
                                        </c:if>
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
                                <select class="qb-input" name="correctAnswer" style="max-width:200px;" disabled>
                                    <option value="true">✅ Đúng (True)</option>
                                    <option value="false">❌ Sai (False)</option>
                                </select>
                            </div>

                            <%-- SHORT_ANSWER box --%>
                            <div id="qbShortBox" style="display:none;" class="qb-field">
                                <label>Đáp án tham khảo (hệ thống không tự chấm)</label>
                                <input class="qb-input" type="text" name="correctAnswer" disabled
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
                            <div class="qb-field">
                                <label>Gắn với bài học (tùy chọn)</label>
                                <select name="lessonId" class="qb-input ins-input">
                                    <option value="">-- Không gắn với bài học cụ thể --</option>
                                    <c:forEach var="l" items="${lessons}">
                                        <option value="${l.lessonId}" ${quiz.lesson != null && quiz.lesson.lessonId == l.lessonId ? 'selected' : ''}>
                                            Bài ${l.orderIndex}: <c:out value="${l.title}"/>
                                        </option>
                                    </c:forEach>
                                </select>
                            </div>
                        </div>

                        <%-- Thời gian & Điểm đạt --%>
                        <div class="qb-card">
                            <p class="qb-card__title">⏱ Cài đặt thời gian & Điểm đạt</p>
                            <div class="qb-grid-2">
                                <div class="qb-field">
                                    <label>Giới hạn thời gian (phút)</label>
                                    <input class="qb-input" type="number" name="timeLimitMinutes" min="1"
                                           value="${quiz.timeLimitMinutes}"
                                           placeholder="Để trống = không giới hạn">
                                    <p class="qb-hint">Ví dụ: 15, 30, 45, 60 phút. Để trống nếu không giới hạn.</p>
                                </div>
                                <div class="qb-field">
                                    <label>Điểm đạt yêu cầu (%)</label>
                                    <input class="qb-input" type="number" name="passingScore"
                                           min="0" max="100" step="1"
                                           value="${quiz.passingScore}"
                                           placeholder="Để trống = không yêu cầu">
                                    <p class="qb-hint">VD: 50 = phải đạt 50% tổng điểm mới tính hoàn thành. Học viên được làm lại không giới hạn cho tới khi đạt.</p>
                                </div>
                            </div>
                        </div>
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
                            <span>Lượt làm bài</span>
                            <span>Không giới hạn</span>
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

    document.querySelector('#qbTfBox select[name="correctAnswer"]').disabled = (type !== 'TRUE_FALSE');
    document.querySelector('#qbShortBox input[name="correctAnswer"]').disabled = (type !== 'SHORT_ANSWER');
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
function insToggleMenu(e) {
    e.stopPropagation();
    document.getElementById('insUserMenu').classList.toggle('open');
}
document.addEventListener('click', function() {
    var m = document.getElementById('insUserMenu');
    if (m) m.classList.remove('open');
});

// ── Question Bank Integration ──
function openAutoGenerateModal() {
    var el = document.getElementById('autoGenModal');
    if (el) el.style.display = 'flex';
}
function closeAutoGenerateModal() {
    var el = document.getElementById('autoGenModal');
    if (el) el.style.display = 'none';
}
function openPickFromBankModal() {
    var el = document.getElementById('pickBankModal');
    if (el) {
        el.style.display = 'flex';
        var sel = document.getElementById('pickBankSelect');
        if (sel && sel.value) loadBankQuestionsForPicker(sel.value);
    }
}
function closePickFromBankModal() {
    var el = document.getElementById('pickBankModal');
    if (el) el.style.display = 'none';
}
function zoomImage(src) {
    document.getElementById('zoomedImg').src = src;
    document.getElementById('imageZoomModal').style.display = 'flex';
}
function closeZoomModal() {
    document.getElementById('imageZoomModal').style.display = 'none';
}
var existingBankQuestionIds = [
    <c:forEach var="q" items="${questions}">
        <c:if test="${not empty q.bankQuestion}">
            ${q.bankQuestion.bankQuestionId},
        </c:if>
    </c:forEach>
];

function loadBankQuestionsForPicker(bankId) {
    var cont = document.getElementById('pickerQuestionsContainer');
    if (!bankId) {
        cont.innerHTML = '<div style="text-align:center;color:#64748b;padding:40px 10px">Vui lòng chọn ngân hàng câu hỏi.</div>';
        return;
    }
    cont.innerHTML = '<div style="text-align:center;color:#64748b;padding:40px 10px">⏳ Đang tải danh sách câu hỏi...</div>';
    fetch('${pageContext.request.contextPath}/instructor/question-banks/api/' + bankId + '/questions')
        .then(res => res.json())
        .then(data => {
            if (!data || data.length === 0) {
                cont.innerHTML = '<div style="text-align:center;color:#64748b;padding:40px 10px">Ngân hàng này hiện chưa có câu hỏi nào.</div>';
                updatePickedCount();
                return;
            }
            var html = '';
            data.forEach((q, i) => {
                var isAlreadyInQuiz = existingBankQuestionIds.includes(q.id);
                var typeLabel = q.type === 'SINGLE_CHOICE' ? 'Trắc nghiệm đơn' : (q.type === 'MULTIPLE_CHOICE' ? 'Nhiều đáp án' : (q.type === 'TRUE_FALSE' ? 'Đúng/Sai' : (q.type === 'ESSAY' ? 'Tự luận' : q.type)));
                html += '<div style="background:' + (isAlreadyInQuiz ? '#f8fafc' : '#fff') + ';border:1px solid ' + (isAlreadyInQuiz ? '#cbd5e1' : '#e2e8f0') + ';border-radius:8px;padding:10px 14px;margin-bottom:8px;display:flex;gap:12px;align-items:flex-start;' + (isAlreadyInQuiz ? 'opacity:0.75;' : '') + '">' +
                    '<input type="checkbox" name="bankQuestionIds" value="' + q.id + '" ' + (isAlreadyInQuiz ? 'disabled title="Câu hỏi này đã có trong đề thi"' : 'onchange="updatePickedCount()"') + ' style="margin-top:4px;accent-color:#0284c7;cursor:' + (isAlreadyInQuiz ? 'not-allowed' : 'pointer') + ';"/>' +
                    '<div style="flex:1;">' +
                        '<div style="font-weight:600;font-size:0.9rem;color:' + (isAlreadyInQuiz ? '#64748b' : '#1e293b') + ';line-height:1.4;">#' + (i+1) + '. ' + escapeHtml(q.content) + '</div>' +
                        '<div style="display:flex;gap:8px;margin-top:6px;font-size:0.75rem;color:#64748b;align-items:center;">' +
                            '<span style="background:#e0e7ff;color:#4338ca;padding:1px 6px;border-radius:4px;font-weight:700;">' + typeLabel + '</span>' +
                            '<span style="background:#f1f5f9;color:#475569;padding:1px 6px;border-radius:4px;">' + (q.difficulty || 'MEDIUM') + '</span>' +
                            '<span>' + (q.score || 1) + ' điểm</span>' +
                            (isAlreadyInQuiz ? '<span style="background:#fef3c7;color:#92400e;padding:1px 6px;border-radius:4px;font-weight:700;margin-left:auto;">Đã có trong đề</span>' : '') +
                        '</div>' +
                    '</div>' +
                '</div>';
            });
            cont.innerHTML = html;
            updatePickedCount();
        })
        .catch(err => {
            cont.innerHTML = '<div style="text-align:center;color:#ef4444;padding:40px 10px">Lỗi khi tải câu hỏi: ' + err + '</div>';
        });
}
function selectAllPickerQuestions(checked) {
    document.querySelectorAll('#pickerQuestionsContainer input[type=checkbox]:not([disabled])').forEach(cb => cb.checked = checked);
    updatePickedCount();
}
function updatePickedCount() {
    var cnt = document.querySelectorAll('#pickerQuestionsContainer input[type=checkbox]:checked').length;
    var el = document.getElementById('pickedCountText');
    if (el) el.innerText = 'Đã chọn: ' + cnt + ' câu';
}
function escapeHtml(text) {
    if (!text) return '';
    return text.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;").replace(/'/g, "&#039;");
}
</script>

<%-- MODAL 1: TỰ ĐỘNG SINH CÂU HỎI TỪ NGÂN HÀNG (RANDOM) --%>
<div class="modal-overlay" id="autoGenModal" style="display:none;position:fixed;top:0;left:0;right:0;bottom:0;background:rgba(0,0,0,0.5);z-index:9999;align-items:center;justify-content:center;backdrop-filter:blur(2px)">
    <div style="background:#fff;border-radius:16px;width:100%;max-width:520px;padding:28px;box-shadow:0 20px 25px -5px rgba(0,0,0,0.1)">
        <h2 style="margin:0 0 12px;font-size:1.25rem;font-weight:800;color:#1e293b;display:flex;align-items:center;gap:8px">
            <span>🎲</span> Tự động sinh câu hỏi từ Ngân hàng
        </h2>
        <p style="color:#64748b;font-size:0.88rem;margin:0 0 20px">
            Hệ thống sẽ bốc ngẫu nhiên số lượng câu hỏi từ ngân hàng đã chọn và gắn vào bài quiz chỉ trong 1 giây.
        </p>

        <form method="post" action="${pageContext.request.contextPath}/instructor/courses/${courseId}/quizzes/${quizId}/auto-generate">
            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>

            <div style="margin-bottom:16px">
                <label style="display:block;margin-bottom:6px;font-weight:700;font-size:0.88rem;color:#334155">
                    Chọn ngân hàng câu hỏi nguồn <span style="color:#ef4444">*</span>
                </label>
                <select name="bankId" class="qb-input" required>
                    <c:forEach var="b" items="${questionBanks}">
                        <option value="${b.bankId}"><c:out value="${b.name}"/> (${b.questions != null ? b.questions.size() : 0} câu)</option>
                    </c:forEach>
                </select>
                <c:if test="${empty questionBanks}">
                    <div style="font-size:0.8rem;color:#dc2626;margin-top:4px">
                        Bạn chưa có ngân hàng câu hỏi nào. Hãy <a href="${pageContext.request.contextPath}/instructor/question-banks" target="_blank" style="color:#2563eb">tạo ngân hàng</a> trước.
                    </div>
                </c:if>
            </div>

            <div style="display:grid;grid-template-columns:1fr 1fr;gap:14px;margin-bottom:16px">
                <div>
                    <label style="display:block;margin-bottom:6px;font-weight:700;font-size:0.88rem;color:#334155">
                        Số câu hỏi cần bốc <span style="color:#ef4444">*</span>
                    </label>
                    <input type="number" name="count" class="qb-input" value="10" min="1" max="100" required/>
                </div>
                <div>
                    <label style="display:block;margin-bottom:6px;font-weight:700;font-size:0.88rem;color:#334155">
                        Điểm mỗi câu
                    </label>
                    <input type="number" name="defaultScore" class="qb-input" value="1.0" min="0.25" step="0.25"/>
                </div>
            </div>

            <div style="margin-bottom:20px;padding:12px 14px;background:#fef2f2;border:1px solid #fee2e2;border-radius:8px">
                <label style="display:flex;align-items:center;gap:8px;font-size:0.86rem;color:#991b1b;cursor:pointer">
                    <input type="checkbox" name="replaceExisting" value="true" style="accent-color:#dc2626"/>
                    <strong>Xóa toàn bộ câu hỏi hiện tại trong quiz và tạo mới</strong>
                </label>
                <div style="font-size:0.78rem;color:#b91c1c;margin-top:4px;margin-left:24px">
                    (Nếu bỏ chọn, câu hỏi được bốc sẽ được thêm tiếp vào sau các câu hỏi hiện tại)
                </div>
            </div>

            <div style="display:flex;justify-content:flex-end;gap:10px">
                <button type="button" class="qb-btn-secondary" onclick="closeAutoGenerateModal()">Hủy</button>
                <button type="submit" class="qb-btn-primary" style="background:linear-gradient(135deg, #4f46e5, #7c3aed);border:none"
                        <c:if test="${empty questionBanks}">disabled</c:if>>
                    🚀 Sinh đề siêu tốc
                </button>
            </div>
        </form>
    </div>
</div>

<%-- MODAL 2: CHỌN CÂU HỎI TỪ NGÂN HÀNG --%>
<div class="modal-overlay" id="pickBankModal" style="display:none;position:fixed;top:0;left:0;right:0;bottom:0;background:rgba(0,0,0,0.5);z-index:9999;align-items:center;justify-content:center;backdrop-filter:blur(2px)">
    <div style="background:#fff;border-radius:16px;width:100%;max-width:720px;padding:26px;box-shadow:0 20px 25px -5px rgba(0,0,0,0.1);max-height:90vh;display:flex;flex-direction:column">
        <h2 style="margin:0 0 10px;font-size:1.25rem;font-weight:800;color:#1e293b;display:flex;align-items:center;gap:8px">
            <span>📥</span> Chọn câu hỏi từ Ngân hàng
        </h2>
        
        <form id="pickBankForm" method="post" action="${pageContext.request.contextPath}/instructor/courses/${courseId}/quizzes/${quizId}/import-bank-questions" style="display:flex;flex-direction:column;flex:1;overflow:hidden">
            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>

            <div style="display:flex;gap:12px;align-items:center;margin-bottom:14px;flex-wrap:wrap">
                <label style="font-weight:700;font-size:0.88rem;color:#334155">Ngân hàng:</label>
                <select id="pickBankSelect" name="bankId" class="qb-input" style="flex:1" onchange="loadBankQuestionsForPicker(this.value)">
                    <option value="">-- Chọn ngân hàng câu hỏi --</option>
                    <c:forEach var="b" items="${questionBanks}">
                        <option value="${b.bankId}"><c:out value="${b.name}"/></option>
                    </c:forEach>
                </select>
                <button type="button" class="qb-btn-secondary" style="font-size:0.8rem;padding:6px 12px" onclick="selectAllPickerQuestions(true)">Chọn tất cả</button>
                <button type="button" class="qb-btn-secondary" style="font-size:0.8rem;padding:6px 12px" onclick="selectAllPickerQuestions(false)">Bỏ chọn</button>
            </div>

            <div id="pickerQuestionsContainer" style="flex:1;overflow-y:auto;border:1px solid #e2e8f0;border-radius:10px;padding:12px;background:#f8fafc;min-height:220px;margin-bottom:16px">
                <div style="text-align:center;color:#64748b;padding:40px 10px">
                    Vui lòng chọn ngân hàng câu hỏi phía trên để xem danh sách câu hỏi.
                </div>
            </div>

            <div style="display:flex;justify-content:space-between;align-items:center">
                <span id="pickedCountText" style="font-size:0.85rem;color:#64748b;font-weight:600">Đã chọn: 0 câu</span>
                <div style="display:flex;gap:10px">
                    <button type="button" class="qb-btn-secondary" onclick="closePickFromBankModal()">Hủy</button>
                    <button type="submit" class="qb-btn-primary" style="background:#0284c7;border:none">
                        + Thêm các câu đã chọn vào bài Quiz
                    </button>
                </div>
            </div>
        </form>
    </div>
</div>

<%-- MODAL 3: ZOOM HÌNH ẢNH --%>
<div id="imageZoomModal" style="display:none;position:fixed;top:0;left:0;right:0;bottom:0;background:rgba(0,0,0,0.6);z-index:10000;align-items:center;justify-content:center" onclick="closeZoomModal()">
    <img id="zoomedImg" src="" style="max-width:90vw;max-height:90vh;border-radius:10px;box-shadow:0 25px 50px -12px rgba(0,0,0,0.5)"/>
</div>
</body>
</html>
