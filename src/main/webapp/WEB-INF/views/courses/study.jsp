<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"   uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn"  uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><c:out value="${study.courseTitle}"/> — Học bài</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/home.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/study.css?v=1.1">

    <!-- Document Viewers for in-browser Word & Excel preview -->
    <script src="${pageContext.request.contextPath}/assets/js/jszip.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/docx-preview.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/xlsx.full.min.js"></script>

    <style>
        /* ── Material Cards & In-Web Preview ── */
        .btn-mat-preview {
            display: inline-flex; align-items: center; gap: 6px; padding: 6px 12px;
            font-size: .8rem; font-weight: 700; color: #2563EB; background: #EFF6FF;
            border: 1.5px solid #BFDBFE; border-radius: 6px; cursor: pointer; transition: all .15s;
        }
        .btn-mat-preview:hover { background: #DBEAFE; border-color: #3B82F6; transform: translateY(-1px); }
        .btn-mat-download {
            display: inline-flex; align-items: center; gap: 6px; padding: 6px 12px;
            font-size: .8rem; font-weight: 600; color: #475569; background: #F8FAFC;
            border: 1.5px solid #CBD5E1; border-radius: 6px; text-decoration: none; transition: all .15s;
        }
        .btn-mat-download:hover { background: #E2E8F0; color: #1E293B; transform: translateY(-1px); }

        #materialPreviewModal.open {
            display: flex !important;
        }
        #materialPreviewModal.fullscreen > div {
            width: 100vw !important; height: 100vh !important; max-width: 100vw !important; border-radius: 0 !important;
        }

        .mat-spinner {
            width: 32px; height: 32px; border: 3.5px solid rgba(255,255,255,.2);
            border-radius: 50%; border-top-color: #3B82F6; animation: matSpin .8s linear infinite;
        }
        @keyframes matSpin { to { transform: rotate(360deg); } }

        /* Docx Preview Styling */
        .docx-wrapper {
            background: transparent !important; padding: 0 !important;
        }
        .docx-wrapper > section.docx {
            background: #fff !important;
            box-shadow: 0 4px 24px rgba(0,0,0,.35) !important;
            margin: 0 auto 24px auto !important;
            padding: 40px 50px !important;
            border-radius: 4px !important;
            max-width: 850px !important;
            box-sizing: border-box !important;
        }

        /* Excel Styling */
        .excel-table-wrapper table {
            border-collapse: collapse; width: 100%; font-size: .88rem;
        }
        .excel-table-wrapper th, .excel-table-wrapper td {
            border: 1px solid #CBD5E1; padding: 6px 12px; text-align: left;
        }
        .excel-table-wrapper tr:first-child td, .excel-table-wrapper th {
            background: #F1F5F9; font-weight: 700; color: #1E293B;
        }

        /* Assignment Card in Tab 2 */
        .assignment-card {
            background: #fff; border: 1.5px solid #E2E8F0; border-radius: 12px;
            padding: 18px 20px; margin-bottom: 14px; transition: all .18s;
        }
        .assignment-card:hover { border-color: #CBD5E1; box-shadow: 0 4px 12px rgba(0,0,0,.04); }
        .assignment-card__title {
            font-size: 1rem; font-weight: 800; color: #0F172A; margin-bottom: 6px;
            display: flex; align-items: center; justify-content: space-between;
        }
        .assignment-card__meta {
            display: flex; flex-wrap: wrap; gap: 14px; font-size: .8rem; color: #64748B; margin-bottom: 10px;
        }
        .assignment-card__desc {
            font-size: .88rem; color: #334155; line-height: 1.55; margin-bottom: 12px;
        }
        .inline-submit-form {
            background: #F8FAFC; border: 1px solid #E2E8F0; border-radius: 10px;
            padding: 16px; margin-top: 12px;
        }
        .inline-submit-form textarea {
            width: 100%; box-sizing: border-box; border: 1.5px solid #CBD5E1; border-radius: 8px;
            padding: 10px 12px; font-size: .88rem; font-family: inherit; resize: vertical; min-height: 100px; margin-bottom: 10px;
        }
        .inline-submit-form textarea:focus { outline: none; border-color: #3B82F6; }
        .btn-do-assignment {
            background: #2563EB; color: #fff; border: none; padding: 8px 18px;
            border-radius: 8px; font-weight: 700; font-size: .85rem; cursor: pointer; transition: all .15s;
        }
        .btn-do-assignment:hover { background: #1D4ED8; }
        .btn-do-assignment--submitted { background: #059669; }
        .btn-do-assignment--submitted:hover { background: #047857; }
        .assignment-status-done {
            display: inline-flex; align-items: center; gap: 4px; font-weight: 700;
            font-size: .85rem; color: #059669; background: #ECFDF5; padding: 6px 12px; border-radius: 6px;
        }
    </style>
</head>
<body>
<jsp:include page="/WEB-INF/views/common/navbar.jsp"/>

<c:set var="curWatchPct" value="${study.currentWatchPercent >= 0 ? study.currentWatchPercent : 0}"/>
<c:set var="isQuizUnlocked" value="${study.currentQuizUnlocked or curWatchPct >= 80}"/>

<div class="study-page-wrapper"
     id="studyApp"
     data-course-id="${study.courseId}"
     data-lesson-id="${study.currentLesson.lessonId}"
     data-video-url="<c:out value='${study.currentVideoUrl}'/>"
     data-video-status="<c:out value='${study.currentVideoStatus}'/>"
     data-last-pos="${study.currentLastPosition}"
     data-watch-pct="${curWatchPct}"
     data-quiz-unlocked="${isQuizUnlocked}"
     data-csrf-param="${_csrf.parameterName}"
     data-csrf-token="${_csrf.token}"
     data-context-path="${pageContext.request.contextPath}">

    <%-- ════ 1. COURSE HERO BANNER ════ --%>
    <div class="course-hero-banner">
        <div class="hero-banner__left">
            <div class="hero-banner__icon">
                <svg width="68" height="68" viewBox="0 0 80 80" fill="none" xmlns="http://www.w3.org/2000/svg">
                    <path d="M40 58L14 45V20L40 33L66 20V45L40 58Z" fill="#1D4ED8"/>
                    <path d="M40 60L12 46V22L40 36L68 22V46L40 60Z" fill="#2563EB"/>
                    <path d="M40 34L14 21L17 44L40 56V34Z" fill="#F8FAFC"/>
                    <path d="M20 28L35 36" stroke="#93C5FD" stroke-width="2" stroke-linecap="round"/>
                    <path d="M20 34L35 42" stroke="#93C5FD" stroke-width="2" stroke-linecap="round"/>
                    <path d="M20 40L32 46" stroke="#93C5FD" stroke-width="2" stroke-linecap="round"/>
                    <path d="M40 34L66 21L63 44L40 56V34Z" fill="#FFFFFF"/>
                    <path d="M45 36L60 28" stroke="#93C5FD" stroke-width="2" stroke-linecap="round"/>
                    <path d="M45 42L60 34" stroke="#93C5FD" stroke-width="2" stroke-linecap="round"/>
                    <path d="M45 48L57 42" stroke="#93C5FD" stroke-width="2" stroke-linecap="round"/>
                    <path d="M40 34V46L37 43L34 46V35" fill="#F59E0B"/>
                </svg>
            </div>
            <div class="hero-banner__titles">
                <h1 class="hero-banner__title">Khóa học: <c:out value="${study.courseTitle}"/></h1>
                <p class="hero-banner__subtitle">Học tập hôm nay – Kiến tạo tương lai ngày mai</p>
            </div>
        </div>

        <div class="hero-banner__right">
            <div class="hero-progress-pill">
                <div class="hero-progress-header">
                    <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="#2563EB" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round">
                        <path d="M18 20V10M12 20V4M6 20v-6"/>
                    </svg>
                    <span>Tiến độ khóa học</span>
                </div>
                <div class="hero-progress-bar-wrap">
                    <div class="hero-progress-track">
                        <div class="hero-progress-fill" style="width: ${study.progressPercent}%;"></div>
                    </div>
                    <span class="hero-progress-pct">${study.progressPercent}%</span>
                </div>
            </div>
        </div>

        <%-- Watermark Graduation Cap --%>
        <div class="hero-banner__watermark">
            <svg width="120" height="120" viewBox="0 0 24 24" fill="currentColor">
                <path d="M12 3L1 9l11 6 9-4.91V17h2V9L12 3zM5 13.18v4L12 21l7-3.82v-4L12 17l-7-3.82z"/>
            </svg>
        </div>
    </div>

    <%-- ════ 2. BREADCRUMBS ════ --%>
    <div class="study-breadcrumbs">
        <a href="${pageContext.request.contextPath}/">
            <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><polyline points="9 22 9 12 15 12 15 22"/></svg>
        </a>
        <span class="breadcrumb-sep">&gt;</span>
        <a href="${pageContext.request.contextPath}/my-courses">Khóa học của tôi</a>
        <span class="breadcrumb-sep">&gt;</span>
        <a href="${pageContext.request.contextPath}/courses/${study.courseId}"><c:out value="${study.courseTitle}"/></a>
        <c:if test="${not empty study.currentLesson.sectionTitle}">
            <span class="breadcrumb-sep">&gt;</span>
            <span><c:out value="${study.currentLesson.sectionTitle}"/></span>
        </c:if>
        <span class="breadcrumb-sep">&gt;</span>
        <span class="breadcrumb-active">Bài ${study.currentLesson.orderIndex}: <c:out value="${study.currentLesson.title}"/></span>
    </div>

    <c:choose>
        <c:when test="${empty study.currentLesson}">
            <div style="background:#fff;border-radius:18px;border:1px solid #E2E8F0;padding:60px 32px;text-align:center;">
                <div style="font-size:3rem;margin-bottom:14px;">📚</div>
                <h2 style="font-size:1.1rem;font-weight:800;color:#0F172A;margin:0 0 8px;">Chưa có bài học nào</h2>
                <p style="color:#64748B;margin:0 0 20px;">Khóa học hiện chưa có bài học nào được công bố.</p>
                <a class="study-btn study-btn--outline" href="${pageContext.request.contextPath}/my-courses">← Khóa học của tôi</a>
            </div>
        </c:when>

        <c:otherwise>
            <%-- ════ 3. MAIN 3-COLUMN LAYOUT ════ --%>
            <div class="study-grid">

                <%-- ── COL 1: LEFT SIDEBAR (Nội dung khóa học) ── --%>
                <aside class="study-left-sidebar">
                    <div class="sidebar-course-card">
                        <div class="sidebar-header">
                            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2">
                                <path d="M12 2L2 7l10 5 10-5-10-5zM2 17l10 5 10-5M2 12l10 5 10-5"/>
                            </svg>
                            <span>Nội dung khóa học</span>
                        </div>
                        <div class="sidebar-accordion-wrap">
                            <c:forEach var="sec" items="${study.sections}">
                                <div class="chapter-accordion ${sec.active ? 'open' : ''}">
                                    <div class="chapter-head" onclick="toggleChapter(this)">
                                        <span><c:out value="${sec.title}"/></span>
                                        <span class="chapter-head-arrow">${sec.active ? '▲' : '▼'}</span>
                                    </div>
                                    <ul class="chapter-lessons-list">
                                        <c:forEach var="item" items="${sec.lessons}">
                                            <li class="sidebar-lesson-item ${item.current ? 'sidebar-lesson-item--active' : ''}">
                                                <a class="sidebar-lesson-link"
                                                   href="<c:choose><c:when test='${study.previewMode}'>${pageContext.request.contextPath}/instructor/courses/${study.courseId}/preview/lessons/${item.lessonId}</c:when><c:otherwise>${pageContext.request.contextPath}/courses/${study.courseId}/lessons/${item.lessonId}</c:otherwise></c:choose>">
                                                    <span class="sidebar-lesson-icon">
                                                        <c:choose>
                                                            <c:when test="${item.current}">
                                                                <svg width="10" height="10" viewBox="0 0 24 24" fill="currentColor"><path d="M8 5v14l11-7z"/></svg>
                                                            </c:when>
                                                            <c:when test="${item.lessonType eq 'VIDEO'}">
                                                                <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="2" y="4" width="20" height="16" rx="2.18"/><polygon points="10 8 16 12 10 16 10 8"/></svg>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/></svg>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </span>
                                                    <div class="sidebar-lesson-info">
                                                        <div class="sidebar-lesson-title"><c:out value="${item.title}"/></div>
                                                        <div class="sidebar-lesson-duration">⏱ ${item.videoDuration != null ? item.videoDuration : 5} phút</div>
                                                    </div>
                                                    <div class="sidebar-lesson-status">
                                                        <c:choose>
                                                            <c:when test="${item.completed or item.current}">
                                                                <span class="status-check-blue">✔</span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="status-empty-circle"></span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </div>
                                                </a>
                                            </li>

                                            <%-- Nếu là bài đang xem và có Quizzes, hiển thị item Quiz ngay bên dưới bài học --%>
                                            <c:if test="${item.current and not empty study.currentLessonQuizzes}">
                                                <c:forEach var="qv" items="${study.currentLessonQuizzes}">
                                                    <li class="sidebar-lesson-item">
                                                        <a class="sidebar-lesson-link"
                                                           href="${pageContext.request.contextPath}/courses/${study.courseId}/quizzes/${qv.quizId}"
                                                           id="sidebarQuizLink-${qv.quizId}"
                                                           ${isQuizUnlocked ? '' : 'onclick="return handleLockedQuizClick(event);"'}
                                                           style="background: #FAFAFC;">
                                                            <span class="sidebar-quiz-icon">❓</span>
                                                            <div class="sidebar-lesson-info">
                                                                <div class="sidebar-lesson-title"><c:out value="${qv.title}"/></div>
                                                            </div>
                                                            <div class="sidebar-lesson-status">
                                                                <span class="sidebar-lock-badge" id="sidebarQuizLock-${qv.quizId}">
                                                                    ${isQuizUnlocked ? '🔓' : '🔒'}
                                                                </span>
                                                            </div>
                                                        </a>
                                                    </li>
                                                </c:forEach>
                                            </c:if>
                                        </c:forEach>
                                    </ul>
                                </div>
                            </c:forEach>
                        </div>
                    </div>

                    <%-- Bottom cheer card & link to course quiz list --%>
                    <div class="sidebar-cheer-card">
                        <div class="cheer-icon">🏆</div>
                        <div class="cheer-content">
                            <div class="cheer-title">Cố gắng học tập nhé!</div>
                            <div class="cheer-subtitle">Bạn đang tiến bộ rất tốt!</div>
                        </div>
                    </div>

                    <div style="margin-top:14px;">
                        <a href="${pageContext.request.contextPath}/courses/${study.courseId}/quizzes"
                           style="width:100%; display:flex; align-items:center; justify-content:center; gap:8px; font-size:.84rem; padding:10px 14px; background:#FAF5FF; border:1.5px solid #D8B4FE; color:#7E22CE; font-weight:700; text-decoration:none; border-radius:10px; transition:all .15s;">
                            <span>📝</span> Danh sách Quiz của khóa học
                        </a>
                    </div>
                </aside>

                <%-- ── COL 2: CENTER (Video Player & Progress) ── --%>
                <main class="study-center-col">

                    <%-- Header above video --%>
                    <div class="video-header-bar">
                        <div class="video-header-title">
                            <span class="video-play-indicator">▶</span>
                            <span>Bài ${study.currentLesson.orderIndex}: <c:out value="${study.currentLesson.title}"/></span>
                        </div>
                        <div class="video-header-badge">
                            <svg width="15" height="15" viewBox="0 0 24 24" fill="currentColor">
                                <path d="M17 10.5V7c0-.55-.45-1-1-1H4c-.55 0-1 .45-1 1v10c0 .55.45 1 1 1h12c.55 0 1-.45 1-1v-3.5l4 4v-11l-4 4z"/>
                            </svg>
                            <span>Video bài giảng</span>
                        </div>
                    </div>

                    <%-- 16:9 Video container --%>
                    <div class="video-frame-wrap" id="studyPlayerContainer"></div>

                    <%-- Watch Progress Card (Circular ring + horizontal bar) --%>
                    <div class="watch-progress-card">
                        <div class="watch-circular-meter">
                            <svg class="circular-chart" viewBox="0 0 36 36">
                                <path class="circle-bg"
                                      d="M18 2.0845
                                         a 15.9155 15.9155 0 0 1 0 31.831
                                         a 15.9155 15.9155 0 0 1 0 -31.831" />
                                <path class="circle-fill" id="circularProgressFill"
                                      stroke-dasharray="${curWatchPct}, 100"
                                      d="M18 2.0845
                                         a 15.9155 15.9155 0 0 1 0 31.831
                                         a 15.9155 15.9155 0 0 1 0 -31.831" />
                            </svg>
                            <div class="circular-meter__text" id="circWatchPct">${curWatchPct}%</div>
                        </div>

                        <div class="watch-progress-details">
                            <div class="watch-progress-title">Tiến độ xem video</div>
                            <div class="watch-progress-subtitle ${isQuizUnlocked ? 'unlocked-text' : ''}" id="watchProgressSubtitle">
                                <c:choose>
                                    <c:when test="${isQuizUnlocked}">
                                        🎉 Chúc mừng! Bạn đã mở khóa bài kiểm tra
                                    </c:when>
                                    <c:otherwise>
                                        Bạn cần xem ít nhất 80% video để mở khóa bài kiểm tra
                                    </c:otherwise>
                                </c:choose>
                            </div>
                            <div class="watch-bar-row">
                                <div class="watch-bar-track">
                                    <div class="watch-bar-fill" id="watchBarFill" style="width: ${curWatchPct}%;"></div>
                                </div>
                                <span class="watch-bar-badge" id="barPctBadge">${curWatchPct}%</span>
                            </div>
                        </div>
                    </div>

                    <%-- Lesson content tabs (Notes, Materials, Quizzes & Exercises) --%>
                    <div class="lesson-content-card">
                        <c:set var="hasAssignments" value="${not empty study.currentLessonAssignments}"/>
                        <c:set var="hasQuizzes"     value="${not empty study.currentLessonQuizzes}"/>
                        <c:set var="hasExercises"   value="${hasAssignments or hasQuizzes}"/>

                        <div class="lesson-tabs">
                            <button class="lesson-tab active" id="tab-lesson" onclick="switchTab('lesson')">
                                📖 Nội dung &amp; Tài liệu
                            </button>
                            <c:if test="${hasExercises}">
                                <button class="lesson-tab" id="tab-exercise" onclick="switchTab('exercise')">
                                    ✏️ Bài tập &amp; Quiz
                                    <span class="lesson-tab__badge${not study.currentLessonCompleted and not study.previewMode and not isQuizUnlocked ? ' lesson-tab__badge--locked' : ''}">
                                        ${(study.currentLessonAssignments != null ? study.currentLessonAssignments.size() : 0) + (study.currentLessonQuizzes != null ? study.currentLessonQuizzes.size() : 0)}
                                    </span>
                                </button>
                            </c:if>
                        </div>

                        <%-- TAB 1: Notes & Materials --%>
                        <div class="tab-panel active" id="panel-lesson">
                            <c:if test="${not empty study.lessonContent}">
                                <div class="lesson-body"><c:out value="${study.lessonContent}"/></div>
                            </c:if>

                            <c:if test="${empty study.lessonContent and empty study.materials}">
                                <p style="color:#64748B;font-size:0.88rem;margin:8px 0 16px;">
                                    Hãy theo dõi trọn vẹn video bài giảng ở trên để nắm vững kiến thức trọng tâm!
                                </p>
                            </c:if>

                            <c:if test="${not empty study.materials}">
                                <div class="materials-section" style="margin-top:20px;">
                                    <h3 style="display:flex; align-items:center; gap:8px; font-size:.98rem; font-weight:800; color:#0F172A; margin-bottom:14px;">
                                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/></svg>
                                        Tài liệu &amp; Tệp tin đính kèm
                                        <span style="font-size:.78rem; font-weight:700; background:#EFF6FF; color:#2563EB; padding:2px 8px; border-radius:12px;">
                                            ${study.materials.size()} tệp
                                        </span>
                                    </h3>
                                    <div class="material-list">
                                        <c:forEach var="mat" items="${study.materials}">
                                            <c:set var="fullMatUrl" value="${mat.fileUrl}"/>
                                            <c:if test="${not empty fullMatUrl and not (fn:startsWith(fullMatUrl, 'http://') or fn:startsWith(fullMatUrl, 'https://'))}">
                                                <c:set var="fullMatUrl" value="${pageContext.request.contextPath}${fullMatUrl}"/>
                                            </c:if>
                                            <div class="material-item" style="display:flex; align-items:center; justify-content:space-between; flex-wrap:wrap; gap:12px; padding:12px 16px; border:1px solid #E2E8F0; border-radius:10px; margin-bottom:10px; background:#fff;">
                                                <div style="display:flex; align-items:center; gap:12px; min-width:0;">
                                                    <div class="material-item__icon" style="font-size:1.4rem; flex-shrink:0;">
                                                        <c:choose>
                                                            <c:when test="${mat.type eq 'VIDEO'}">🎬</c:when>
                                                            <c:when test="${mat.type eq 'DOCUMENT'}">📄</c:when>
                                                            <c:otherwise>🔗</c:otherwise>
                                                        </c:choose>
                                                    </div>
                                                    <div class="material-item__info" style="min-width:0;">
                                                        <div class="material-item__name" style="font-weight:700; font-size:.9rem; color:#0F172A; white-space:nowrap; overflow:hidden; text-overflow:ellipsis; max-width:480px;"><c:out value="${mat.title}"/></div>
                                                        <div class="material-item__type" style="margin-top:2px;">
                                                            <span class="material-pill material-pill--${mat.type.toLowerCase()}" style="font-size:.72rem; padding:1px 6px; border-radius:4px;">
                                                                <c:choose>
                                                                    <c:when test="${mat.type eq 'VIDEO'}">Video</c:when>
                                                                    <c:when test="${mat.type eq 'DOCUMENT'}">Tài liệu</c:when>
                                                                    <c:otherwise>Liên kết</c:otherwise>
                                                                </c:choose>
                                                            </span>
                                                        </div>
                                                    </div>
                                                </div>
                                                <div style="display:flex; align-items:center; gap:8px; flex-shrink:0;">
                                                    <c:if test="${not empty fullMatUrl}">
                                                        <button type="button" class="btn-mat-preview"
                                                                onclick="openMaterialPreview('<c:out value="${mat.title}" escapeXml="true"/>', '<c:out value="${fullMatUrl}" escapeXml="true"/>', '<c:out value="${mat.type}"/>', '<c:out value="${mat.originalFileName}" escapeXml="true"/>')">
                                                            👁️ Xem trực tiếp
                                                        </button>
                                                        <a class="btn-mat-download"
                                                           href="<c:out value='${fullMatUrl}'/>" target="_blank" rel="noopener noreferrer">
                                                            <c:choose>
                                                                <c:when test="${mat.type eq 'LINK'}">Mở link ↗</c:when>
                                                                <c:otherwise>⬇️ Tải về</c:otherwise>
                                                            </c:choose>
                                                        </a>
                                                    </c:if>
                                                </div>
                                            </div>
                                        </c:forEach>
                                    </div>
                                </div>
                            </c:if>

                            <div class="study-actions" style="margin-top:24px;">
                                <c:if test="${not empty study.prevLessonId}">
                                    <a class="study-btn study-btn--outline"
                                       href="${pageContext.request.contextPath}/courses/${study.courseId}/lessons/${study.prevLessonId}">
                                        ← Bài trước
                                    </a>
                                </c:if>
                                <c:if test="${not study.currentLesson.completed and not study.previewMode}">
                                    <form method="post" style="margin:0;"
                                          action="${pageContext.request.contextPath}/courses/${study.courseId}/lessons/${study.currentLesson.lessonId}/complete">
                                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                        <button class="study-btn study-btn--success" type="submit">
                                            <svg width="15" height="15" viewBox="0 0 24 24" fill="none"><circle cx="12" cy="12" r="9" stroke="white" stroke-width="1.8"/><path d="M8 12l3 3 5-5" stroke="white" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/></svg>
                                            Đánh dấu đã học
                                        </button>
                                    </form>
                                </c:if>
                                <c:if test="${study.currentLesson.completed}">
                                    <div class="completed-banner" style="margin:0; padding:8px 14px;">
                                        ✅ Đã hoàn thành bài học
                                    </div>
                                </c:if>
                                <c:if test="${not empty study.nextLessonId}">
                                    <a class="study-btn study-btn--outline"
                                       href="${pageContext.request.contextPath}/courses/${study.courseId}/lessons/${study.nextLessonId}">
                                        Bài tiếp →
                                    </a>
                                </c:if>
                            </div>
                        </div>

                        <%-- TAB 2: Exercises & Quizzes --%>
                        <c:if test="${hasExercises}">
                            <div class="tab-panel" id="panel-exercise">
                                <c:set var="isVideoLesson" value="${study.currentLessonType eq 'VIDEO' or not empty study.currentVideoUrl}"/>
                                <c:set var="tabQuizUnlocked" value="${study.currentQuizUnlocked or curWatchPct >= 80 or study.previewMode or not isVideoLesson}"/>

                                <c:choose>
                                    <c:when test="${isVideoLesson and not tabQuizUnlocked and not study.previewMode}">
                                        <div class="widget-cond-alert widget-cond-alert--locked" id="exerciseTabGate" style="padding: 24px; text-align: center; display: block; margin-bottom: 20px;">
                                            <div style="font-size: 2.4rem; margin-bottom: 10px;">🔒</div>
                                            <p style="font-weight: 800; font-size: 1.05rem; margin: 0 0 6px; color:#991B1B;">Bài kiểm tra đang bị khóa</p>
                                            <p style="font-size: 0.88rem; margin: 0 0 16px; color:#4B5563;">
                                                Bạn cần xem ít nhất <strong>80%</strong> video bài giảng để mở khóa bài kiểm tra.
                                                <br><span style="color:#2563EB;font-weight:700;">Tiến độ hiện tại: <span id="gateWatchPct">${curWatchPct}</span>% / 80%</span>
                                            </p>
                                            <button class="study-btn study-btn--outline" onclick="switchTab('lesson')">← Quay lại xem video</button>
                                        </div>
                                    </c:when>

                                    <c:otherwise>
                                        <c:if test="${isVideoLesson and tabQuizUnlocked and not study.previewMode}">
                                            <div class="completed-banner" id="quizUnlockedBanner" style="margin-bottom:16px;">
                                                🎉 Chúc mừng! Bạn đã mở khóa bài kiểm tra.
                                            </div>
                                        </c:if>

                                        <%-- Danh sách Quiz của bài học --%>
                                        <c:if test="${not empty study.currentLessonQuizzes}">
                                            <div style="font-size:.9rem; font-weight:800; color:#475569; text-transform:uppercase; letter-spacing:.5px; margin-bottom:10px;">
                                                📝 Bài kiểm tra trắc nghiệm (Quiz)
                                            </div>
                                            <c:forEach var="qv" items="${study.currentLessonQuizzes}">
                                                <div style="background:#fff;border:1.5px solid #E2E8F0;border-radius:12px;padding:16px 20px;margin-bottom:14px;box-shadow:0 2px 6px rgba(0,0,0,.03);">
                                                    <div style="font-weight:800;font-size:1rem;color:#0F172A;margin-bottom:6px;">
                                                        📝 <c:out value="${qv.title}"/>
                                                    </div>
                                                    <div style="font-size:.82rem;color:#64748B;margin-bottom:12px;">
                                                        ⏱ ${qv.timeLimitMinutes != null ? qv.timeLimitMinutes : 'Không giới hạn'} phút &bull; Tối đa ${qv.maxAttempts} lần
                                                        <c:if test="${qv.myAttemptCount > 0}"> &bull; <strong>Đã làm ${qv.myAttemptCount} lần</strong></c:if>
                                                    </div>
                                                    <a class="study-btn study-btn--primary" href="${pageContext.request.contextPath}/courses/${study.courseId}/quizzes/${qv.quizId}">
                                                        📝 Vào làm bài
                                                    </a>
                                                </div>
                                            </c:forEach>
                                        </c:if>

                                        <%-- Danh sách Bài tập tự luận (Assignments) --%>
                                        <c:if test="${not empty study.currentLessonAssignments}">
                                            <div style="font-size:.9rem; font-weight:800; color:#475569; text-transform:uppercase; letter-spacing:.5px; margin:20px 0 10px;">
                                                📋 Bài tập thực hành &amp; Tự luận
                                            </div>
                                            <c:forEach var="asgn" items="${study.currentLessonAssignments}">
                                                <div class="assignment-card">
                                                    <div class="assignment-card__title">
                                                        <span>📋 <c:out value="${asgn.title}"/></span>
                                                        <c:if test="${asgn.hasSubmitted}">
                                                            <span class="assignment-status-done" style="font-size:.76rem;">Đã nộp bài</span>
                                                        </c:if>
                                                    </div>
                                                    <div class="assignment-card__meta">
                                                        <span>⭐ Điểm tối đa: <strong>${asgn.maxScore}</strong></span>
                                                        <c:if test="${not empty asgn.dueDate}">
                                                            <span>⏰ Hạn: <c:out value="${asgn.dueDate}"/></span>
                                                        </c:if>
                                                        <c:if test="${asgn.allowResubmit}">
                                                            <span>🔄 Nộp lại (${asgn.maxAttempts} lần)</span>
                                                        </c:if>
                                                        <c:if test="${asgn.attemptCount > 0}">
                                                            <span>📤 Đã nộp ${asgn.attemptCount} lần</span>
                                                        </c:if>
                                                    </div>
                                                    <c:if test="${not empty asgn.description}">
                                                        <div class="assignment-card__desc"><c:out value="${asgn.description}"/></div>
                                                    </c:if>
                                                    <div style="display:flex; gap:10px; align-items:center; flex-wrap:wrap;">
                                                        <c:choose>
                                                            <c:when test="${asgn.hasSubmitted and not asgn.allowResubmit}">
                                                                <span class="assignment-status-done">✅ Đã hoàn thành nộp</span>
                                                                <a class="study-btn study-btn--outline" style="font-size:.83rem;padding:6px 14px;"
                                                                   href="${pageContext.request.contextPath}/courses/${study.courseId}/assignments/${asgn.assignmentId}/result">
                                                                    Xem kết quả →
                                                                </a>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <button class="btn-do-assignment<c:if test='${asgn.hasSubmitted}'> btn-do-assignment--submitted</c:if>"
                                                                        onclick="toggleSubmitForm('form-${asgn.assignmentId}')">
                                                                    <c:choose>
                                                                        <c:when test="${asgn.hasSubmitted}">🔄 Nộp lại bài</c:when>
                                                                        <c:otherwise>✏️ Làm bài tập</c:otherwise>
                                                                    </c:choose>
                                                                </button>
                                                                <c:if test="${asgn.hasSubmitted}">
                                                                    <a class="study-btn study-btn--outline" style="font-size:.83rem;padding:6px 14px;"
                                                                       href="${pageContext.request.contextPath}/courses/${study.courseId}/assignments/${asgn.assignmentId}/result">
                                                                        Xem kết quả →
                                                                    </a>
                                                                </c:if>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </div>
                                                    <c:if test="${not (asgn.hasSubmitted and not asgn.allowResubmit) and not study.previewMode}">
                                                        <div class="inline-submit-form" id="form-${asgn.assignmentId}" style="display:none;">
                                                            <form method="post"
                                                                  action="${pageContext.request.contextPath}/courses/${study.courseId}/assignments/${asgn.assignmentId}/submit">
                                                                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                                                <label for="answer-${asgn.assignmentId}" style="display:block;font-weight:700;font-size:.86rem;margin-bottom:6px;">📝 Nội dung câu trả lời *</label>
                                                                <textarea id="answer-${asgn.assignmentId}" name="answerText" required
                                                                          placeholder="Viết nội dung bài làm của bạn vào đây..."></textarea>
                                                                <label for="file-${asgn.assignmentId}" style="display:block;font-weight:700;font-size:.86rem;margin-bottom:6px;">📎 Đường dẫn file đính kèm (Google Drive / OneDrive - tùy chọn)</label>
                                                                <input type="url" id="file-${asgn.assignmentId}" name="fileUrl"
                                                                       style="width:100%;box-sizing:border-box;border:1.5px solid #CBD5E1;border-radius:8px;padding:8px 12px;font-size:.87rem;margin-bottom:12px;"
                                                                       placeholder="https://drive.google.com/...">
                                                                <div style="display:flex;gap:10px;">
                                                                    <button class="btn-do-assignment" type="submit">📤 Xác nhận nộp bài</button>
                                                                    <button type="button" class="study-btn study-btn--outline"
                                                                            onclick="toggleSubmitForm('form-${asgn.assignmentId}')">Hủy</button>
                                                                </div>
                                                            </form>
                                                        </div>
                                                    </c:if>
                                                </div>
                                            </c:forEach>
                                        </c:if>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </c:if>
                    </div>
                </main>

                <%-- ── COL 3: RIGHT SIDEBAR ── --%>
                <aside class="study-right-col">

                    <%-- Card 1: Thông tin bài học --%>
                    <div class="right-widget-card">
                        <div class="right-widget-head">
                            <svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor">
                                <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm1 15h-2v-6h2v6zm0-8h-2V7h2v2z"/>
                            </svg>
                            <span>Thông tin bài học</span>
                        </div>
                        <div class="widget-row">
                            <span class="widget-row__label">
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/>
                                </svg>
                                Thời lượng
                            </span>
                            <span class="widget-row__val">${study.currentVideoDuration != null ? study.currentVideoDuration : 5} phút</span>
                        </div>
                        <div class="widget-row">
                            <span class="widget-row__label">
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <path d="M18 20V10M12 20V4M6 20v-6"/>
                                </svg>
                                Trạng thái
                            </span>
                            <span class="status-pill-badge" id="rightStatusBadge">
                                ✔ Đã xem ${curWatchPct}%
                            </span>
                        </div>

                        <div class="widget-cond-title">
                            <svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor">
                                <path d="M18 8h-1V6c0-2.76-2.24-5-5-5S7 3.24 7 6v2H6c-1.1 0-2 .9-2 2v10c0 1.1.9 2 2 2h12c1.1 0 2-.9 2-2V10c0-1.1-.9-2-2-2zm-6 9c-1.1 0-2-.9-2-2s.9-2 2-2 2 .9 2 2-.9 2-2 2zm3.1-9H8.9V6c0-1.71 1.39-3.1 3.1-3.1 1.71 0 3.1 1.39 3.1 3.1v2z"/>
                            </svg>
                            <span>Điều kiện mở Quiz</span>
                        </div>

                        <div class="widget-cond-alert ${isQuizUnlocked ? 'widget-cond-alert--unlocked' : 'widget-cond-alert--locked'}" id="rightConditionBox">
                            <span class="widget-cond-alert__icon" id="rightConditionIcon">${isQuizUnlocked ? '🎉' : '🔒'}</span>
                            <span id="rightConditionText">
                                <c:choose>
                                    <c:when test="${isQuizUnlocked}">
                                        Đã đủ điều kiện mở khóa bài kiểm tra!
                                    </c:when>
                                    <c:otherwise>
                                        Xem ít nhất 80% video để mở khóa bài kiểm tra
                                    </c:otherwise>
                                </c:choose>
                            </span>
                        </div>
                    </div>

                    <%-- Card 2: Motivation & Quiz CTA --%>
                    <div class="motivation-card">
                        <div class="motivation-trophy-wrap">
                            🏆
                        </div>
                        <div class="motivation-title" id="rightMotivationTitle">
                            <c:choose>
                                <c:when test="${isQuizUnlocked}">Chúc mừng!</c:when>
                                <c:otherwise>Cố lên!</c:otherwise>
                            </c:choose>
                        </div>
                        <div class="motivation-desc" id="rightMotivationDesc">
                            <c:choose>
                                <c:when test="${isQuizUnlocked}">
                                    Chúc mừng bạn đã mở khóa bài Quiz! Bạn có thể làm bài ngay bây giờ.
                                </c:when>
                                <c:otherwise>
                                    Bạn chỉ cần xem thêm ${80 - curWatchPct > 0 ? (80 - curWatchPct) : 0}% nữa là có thể làm bài Quiz rồi!
                                </c:otherwise>
                            </c:choose>
                        </div>

                        <div class="motivation-action-wrap">
                            <c:set var="firstQuiz" value="${not empty study.currentLessonQuizzes ? study.currentLessonQuizzes[0] : null}"/>
                            <c:choose>
                                <c:when test="${not empty firstQuiz}">
                                    <a href="${pageContext.request.contextPath}/courses/${study.courseId}/quizzes/${firstQuiz.quizId}"
                                       id="rightQuizBtn"
                                       class="btn-quiz-cta ${isQuizUnlocked ? 'btn-quiz-cta--active' : 'btn-quiz-cta--locked'}"
                                       ${isQuizUnlocked ? '' : 'aria-disabled="true" onclick="return handleLockedQuizClick(event);"'}
                                       data-quiz-url="${pageContext.request.contextPath}/courses/${study.courseId}/quizzes/${firstQuiz.quizId}">
                                        <span id="rightQuizBtnIcon">${isQuizUnlocked ? '📝' : '🔒'}</span>
                                        <span id="rightQuizBtnLabel">${isQuizUnlocked ? 'Làm bài Quiz ngay' : 'Làm bài Quiz'}</span>
                                    </a>
                                </c:when>
                                <c:otherwise>
                                    <a href="${pageContext.request.contextPath}/courses/${study.courseId}/quizzes"
                                       id="rightQuizBtn"
                                       class="btn-quiz-cta ${isQuizUnlocked ? 'btn-quiz-cta--active' : 'btn-quiz-cta--locked'}"
                                       ${isQuizUnlocked ? '' : 'aria-disabled="true" onclick="return handleLockedQuizClick(event);"'}
                                       data-quiz-url="${pageContext.request.contextPath}/courses/${study.courseId}/quizzes">
                                        <span id="rightQuizBtnIcon">${isQuizUnlocked ? '📝' : '🔒'}</span>
                                        <span id="rightQuizBtnLabel">${isQuizUnlocked ? 'Làm bài Quiz ngay' : 'Làm bài Quiz'}</span>
                                    </a>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>

                </aside>

            </div><%-- END study-grid --%>
        </c:otherwise>
    </c:choose>
</div>

<!-- ══ Modal Xem trước tài liệu trực tiếp trên Web ══ -->
<div id="materialPreviewModal" style="display:none; position:fixed; inset:0; background:rgba(15,23,42,.75); backdrop-filter:blur(4px); z-index:9999; align-items:center; justify-content:center; padding:16px;">
    <div style="background:#fff; border-radius:14px; width:92vw; max-width:1150px; height:88vh; display:flex; flex-direction:column; overflow:hidden; box-shadow:0 25px 50px -12px rgba(0,0,0,.45);">
        <!-- Modal Top Bar -->
        <div style="display:flex; align-items:center; justify-content:space-between; padding:12px 20px; border-bottom:1px solid #E2E8F0; background:#F8FAFC; flex-shrink:0;">
            <div style="display:flex; align-items:center; gap:10px; min-width:0;">
                <span id="matModalIcon" style="font-size:1.4rem;">📄</span>
                <div style="min-width:0;">
                    <h3 id="matModalTitle" style="margin:0; font-size:.96rem; font-weight:800; color:#0F172A; white-space:nowrap; overflow:hidden; text-overflow:ellipsis; max-width:560px;">
                        Tiêu đề tài liệu
                    </h3>
                    <div id="matModalSub" style="font-size:.76rem; color:#64748B; margin-top:2px;"></div>
                </div>
            </div>
            <div style="display:flex; align-items:center; gap:8px;">
                <a id="matModalDownloadBtn" href="#" download target="_blank"
                   style="display:inline-flex; align-items:center; gap:6px; padding:7px 14px; font-size:.82rem; font-weight:700; color:#2563EB; background:#EFF6FF; border:1px solid #BFDBFE; border-radius:6px; text-decoration:none;">
                    ⬇️ Tải về máy
                </a>
                <button type="button" onclick="toggleMaterialFullscreen()"
                        style="padding:7px 11px; font-size:.85rem; font-weight:600; color:#475569; background:#fff; border:1px solid #CBD5E1; border-radius:6px; cursor:pointer;" title="Phóng to toàn màn hình">
                    ⛶
                </button>
                <button type="button" onclick="closeMaterialPreview()"
                        style="padding:7px 14px; font-size:.85rem; font-weight:800; color:#DC2626; background:#FEF2F2; border:1px solid #FECACA; border-radius:6px; cursor:pointer;">
                    ✕ Đóng
                </button>
            </div>
        </div>

        <!-- Modal Viewer Container -->
        <div id="matModalContent" style="flex:1; background:#0F172A; position:relative; overflow:auto; display:flex; align-items:center; justify-content:center;">
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>

<script>
// ── Material In-Web Preview Script ──
function openMaterialPreview(title, url, type, origName) {
    var modal = document.getElementById('materialPreviewModal');
    var titleElem = document.getElementById('matModalTitle');
    var subElem = document.getElementById('matModalSub');
    var iconElem = document.getElementById('matModalIcon');
    var downloadBtn = document.getElementById('matModalDownloadBtn');
    var contentElem = document.getElementById('matModalContent');

    titleElem.textContent = title;
    subElem.textContent = origName ? ('Tệp: ' + origName) : url;
    downloadBtn.href = url;
    downloadBtn.setAttribute('download', origName || title);

    var lowerUrl = url.toLowerCase();
    var lowerOrig = (origName || '').toLowerCase();

    // Check PDF
    if (lowerUrl.indexOf('.pdf') !== -1 || lowerOrig.indexOf('.pdf') !== -1) {
        iconElem.textContent = '📕';
        contentElem.innerHTML = '<iframe src="' + url + '#toolbar=1&navpanes=1" width="100%" height="100%" style="border:none;background:#fff;" title="' + title + '"></iframe>';
    }
    // Check Image
    else if (lowerUrl.match(/\.(png|jpe?g|gif|webp|svg)(\?.*)?$/) || lowerOrig.match(/\.(png|jpe?g|gif|webp|svg)$/)) {
        iconElem.textContent = '🖼️';
        contentElem.innerHTML = '<div style="width:100%;height:100%;display:flex;align-items:center;justify-content:center;padding:20px;box-sizing:border-box;"><img src="' + url + '" style="max-width:100%;max-height:100%;object-fit:contain;border-radius:6px;box-shadow:0 8px 30px rgba(0,0,0,.5);" alt="' + title + '"/></div>';
    }
    // Check Video
    else if (type === 'VIDEO' || lowerUrl.match(/\.(mp4|webm|mov)(\?.*)?$/) || lowerUrl.indexOf('youtube.com') !== -1 || lowerUrl.indexOf('youtu.be') !== -1) {
        iconElem.textContent = '🎬';
        if (lowerUrl.indexOf('youtube.com') !== -1 || lowerUrl.indexOf('youtu.be') !== -1) {
            var vId = '';
            if (lowerUrl.indexOf('watch?v=') !== -1) vId = url.split('watch?v=')[1].split('&')[0];
            else if (lowerUrl.indexOf('youtu.be/') !== -1) vId = url.split('youtu.be/')[1].split('?')[0];
            var embed = 'https://www.youtube.com/embed/' + vId;
            contentElem.innerHTML = '<iframe src="' + embed + '" width="100%" height="100%" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>';
        } else {
            contentElem.innerHTML = '<video src="' + url + '" controls autoplay style="max-width:100%;max-height:100%;border-radius:8px;"></video>';
        }
    }
    // Check Audio
    else if (lowerUrl.match(/\.(mp3|wav|ogg)(\?.*)?$/)) {
        iconElem.textContent = '🎧';
        contentElem.innerHTML = '<div style="text-align:center;color:#fff;"><div style="font-size:3.5rem;margin-bottom:16px;">🎧</div><div style="font-size:1.1rem;font-weight:700;margin-bottom:14px;">' + title + '</div><audio src="' + url + '" controls autoplay style="width:420px;max-width:90%;"></audio></div>';
    }
    // Check Microsoft Word (.docx)
    else if (lowerOrig.indexOf('.docx') !== -1 || lowerUrl.indexOf('.docx') !== -1) {
        iconElem.textContent = '📘';
        contentElem.innerHTML = '<div style="display:flex;flex-direction:column;align-items:center;justify-content:center;height:100%;color:#fff;gap:12px;">' +
            '<div class="mat-spinner"></div>' +
            '<div style="font-size:.95rem;font-weight:600;">⏳ Đang đọc và hiển thị tài liệu Word trực tiếp...</div>' +
        '</div>';

        fetch(url)
            .then(function(res) {
                if (!res.ok) throw new Error('Không thể tải tệp (HTTP ' + res.status + ')');
                return res.blob();
            })
            .then(function(blob) {
                contentElem.innerHTML = '<div id="docxContainer" style="width:100%;height:100%;overflow:auto;background:#525659;padding:24px 10px;box-sizing:border-box;"></div>';
                var target = document.getElementById('docxContainer');
                if (window.docx && window.docx.renderAsync) {
                    return window.docx.renderAsync(blob, target, null, {
                        className: 'docx-preview-paper',
                        inWrapper: true,
                        breakPages: true
                    });
                } else {
                    throw new Error('Thư viện hiển thị Word chưa tải xong.');
                }
            })
            .catch(function(err) {
                contentElem.innerHTML = '<div style="text-align:center;background:#fff;padding:36px;border-radius:12px;max-width:520px;box-shadow:0 12px 30px rgba(0,0,0,.25);margin:20px;">' +
                    '<div style="font-size:3rem;margin-bottom:12px;">📘</div>' +
                    '<h3 style="margin:0 0 8px;color:#0F172A;font-size:1.15rem;">' + (origName || title) + '</h3>' +
                    '<p style="color:#64748B;font-size:.88rem;line-height:1.6;margin:0 0 20px;">' + (err.message || 'Không thể hiển thị xem trước tệp Word') + '</p>' +
                    '<div style="display:flex;gap:10px;justify-content:center;">' +
                        '<a href="' + url + '" download="' + (origName || title) + '" style="background:#2563EB;color:#fff;padding:9px 20px;border-radius:8px;font-weight:700;text-decoration:none;">⬇️ Tải tệp về máy</a>' +
                    '</div>' +
                '</div>';
            });
    }
    // Check Microsoft Excel (.xlsx, .xls)
    else if (lowerOrig.match(/\.xlsx?$/) || lowerUrl.match(/\.xlsx?$/)) {
        iconElem.textContent = '📗';
        contentElem.innerHTML = '<div style="display:flex;flex-direction:column;align-items:center;justify-content:center;height:100%;color:#fff;gap:12px;">' +
            '<div class="mat-spinner"></div>' +
            '<div style="font-size:.95rem;font-weight:600;">⏳ Đang mở bảng tính Excel...</div>' +
        '</div>';

        fetch(url)
            .then(function(res) {
                if (!res.ok) throw new Error('Không thể tải tệp (HTTP ' + res.status + ')');
                return res.arrayBuffer();
            })
            .then(function(buf) {
                if (!window.XLSX) throw new Error('Thư viện hiển thị Excel chưa tải xong.');
                var wb = XLSX.read(buf, { type: 'array' });
                var sheetName = wb.SheetNames[0];
                var ws = wb.Sheets[sheetName];
                var html = XLSX.utils.sheet_to_html(ws, { id: 'excelTable', editable: false });
                contentElem.innerHTML = '<div style="width:100%;height:100%;overflow:auto;background:#fff;padding:20px;box-sizing:border-box;">' +
                    '<div style="display:flex;align-items:center;justify-content:space-between;padding-bottom:12px;margin-bottom:14px;border-bottom:2px solid #E2E8F0;">' +
                        '<div style="font-weight:800;font-size:1rem;color:#0F172A;">📊 Sheet: ' + sheetName + '</div>' +
                        '<div style="font-size:.8rem;color:#64748B;">Tổng cộng ' + wb.SheetNames.length + ' sheet</div>' +
                    '</div>' +
                    '<div class="excel-table-wrapper" style="overflow:auto;">' + html + '</div>' +
                '</div>';
            })
            .catch(function(err) {
                contentElem.innerHTML = '<div style="text-align:center;background:#fff;padding:36px;border-radius:12px;max-width:520px;box-shadow:0 12px 30px rgba(0,0,0,.25);margin:20px;">' +
                    '<div style="font-size:3rem;margin-bottom:12px;">📗</div>' +
                    '<h3 style="margin:0 0 8px;color:#0F172A;font-size:1.15rem;">' + (origName || title) + '</h3>' +
                    '<p style="color:#64748B;font-size:.88rem;line-height:1.6;margin:0 0 20px;">' + (err.message || 'Không thể hiển thị xem trước tệp Excel') + '</p>' +
                    '<div style="display:flex;gap:10px;justify-content:center;">' +
                        '<a href="' + url + '" download="' + (origName || title) + '" style="background:#2563EB;color:#fff;padding:9px 20px;border-radius:8px;font-weight:700;text-decoration:none;">⬇️ Tải tệp về máy</a>' +
                    '</div>' +
                '</div>';
            });
    }
    // Check PowerPoint & other formats
    else if (lowerOrig.match(/\.(pptx?|doc)$/) || lowerUrl.match(/\.(pptx?|doc)$/)) {
        iconElem.textContent = '📙';
        contentElem.innerHTML = '<div style="text-align:center;background:#fff;padding:40px;border-radius:14px;max-width:520px;box-shadow:0 12px 35px rgba(0,0,0,.25);margin:20px;">' +
            '<div style="font-size:3.5rem;margin-bottom:12px;">📑</div>' +
            '<h3 style="margin:0 0 8px;color:#0F172A;font-size:1.2rem;">' + (origName || title) + '</h3>' +
            '<p style="color:#64748B;font-size:.88rem;line-height:1.6;margin:0 0 24px;">Tệp trình chiếu PowerPoint / Tài liệu cũ. Bạn vui lòng tải về máy để mở bằng phần mềm chuyên dụng.</p>' +
            '<div style="display:flex;gap:12px;justify-content:center;flex-wrap:wrap;">' +
                '<a href="' + url + '" download="' + (origName || title) + '" style="background:#2563EB;color:#fff;padding:10px 22px;border-radius:8px;font-weight:700;text-decoration:none;display:inline-flex;align-items:center;gap:6px;">⬇️ Tải tệp về máy</a>' +
            '</div>' +
        '</div>';
    }
    // Generic fallback
    else {
        iconElem.textContent = '📄';
        contentElem.innerHTML = '<iframe src="' + url + '" width="100%" height="100%" style="border:none;background:#fff;" title="' + title + '"></iframe>';
    }

    modal.classList.add('open');
    document.body.style.overflow = 'hidden';
}

function closeMaterialPreview() {
    var modal = document.getElementById('materialPreviewModal');
    if (!modal) return;
    modal.classList.remove('open');
    modal.classList.remove('fullscreen');
    document.getElementById('matModalContent').innerHTML = '';
    document.body.style.overflow = '';
}

function toggleMaterialFullscreen() {
    var modal = document.getElementById('materialPreviewModal');
    if (modal) modal.classList.toggle('fullscreen');
}

function toggleSubmitForm(id) {
    var el = document.getElementById(id);
    if (el) el.style.display = el.style.display === 'none' ? 'block' : 'none';
}

document.addEventListener('keydown', function(e) {
    if (e.key === 'Escape') closeMaterialPreview();
});

// Auto-switch tab if requested
(function() {
    var initial = '<c:out value="${initialTab}"/>';
    if (initial === 'exercise') {
        if (typeof switchTab === 'function') switchTab('exercise');
    }
})();
</script>

<%-- Script riêng cho trang học: video player, anti-seeking, watch progress, auto quiz unlock --%>
<script src="${pageContext.request.contextPath}/assets/js/study.js?v=1.1"></script>
</body>
</html>
