<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><c:out value="${study.courseTitle}"/> — Học bài</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app.css?v=restore-0bfd0e1-20261014">
    <!-- Document Viewers for in-browser Word & Excel preview -->
    <script src="${pageContext.request.contextPath}/assets/js/jszip.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/docx-preview.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/xlsx.full.min.js"></script>
    <style>
        /* ── Material Cards & In-Web Preview ── */
        .material-card {
            display: flex; align-items: center; justify-content: space-between;
            flex-wrap: wrap; gap: 14px; padding: 14px 18px; border: 1.5px solid #E2E8F0;
            border-radius: 10px; background: #fff; margin-bottom: 12px; transition: all .18s;
        }
        .material-card:hover { border-color: #93C5FD; box-shadow: 0 4px 14px rgba(37,99,235,.07); }
        .btn-mat-preview {
            display: inline-flex; align-items: center; gap: 6px; padding: 7px 15px;
            font-size: .84rem; font-weight: 700; color: #2563EB; background: #EFF6FF;
            border: 1.5px solid #BFDBFE; border-radius: 6px; cursor: pointer; transition: all .15s;
        }
        .btn-mat-preview:hover { background: #DBEAFE; border-color: #3B82F6; transform: translateY(-1px); }
        .btn-mat-download {
            display: inline-flex; align-items: center; gap: 6px; padding: 7px 15px;
            font-size: .84rem; font-weight: 600; color: #475569; background: #F8FAFC;
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
        .video-container {
            position: relative; padding-bottom: 56.25%; height: 0; overflow: hidden;
            max-width: 100%; background: #000; border-radius: var(--r8); margin-bottom: 20px;
        }
        .video-container iframe, .video-container video {
            position: absolute; top: 0; left: 0; width: 100%; height: 100%; border: 0;
        }
        .preview-banner {
            background: #EFF6FF; border: 1.5px solid #3B82F6; color: #1E40AF; border-radius: var(--r8);
            padding: 12px 18px; margin-bottom: 20px; display: flex; align-items: center; justify-content: space-between;
            flex-wrap: wrap; gap: 10px; font-weight: 600; font-size: .9rem;
        }
        .seek-notice {
            background: #FFFBEB; border: 1px solid #FDE68A; color: #92400E; padding: 6px 12px;
            border-radius: 4px; font-size: .8rem; margin-bottom: 12px; display: inline-block;
        }

        /* ── Lesson / Exercise Tabs ── */
        .lesson-tabs {
            display: flex; gap: 0; border-bottom: 2px solid #E2E8F0; margin-bottom: 20px;
        }
        .lesson-tab {
            padding: 10px 20px; font-weight: 700; font-size: .9rem;
            cursor: pointer; color: #64748B; border-bottom: 2px solid transparent;
            margin-bottom: -2px; transition: color .15s, border-color .15s;
            display: flex; align-items: center; gap: 6px; background: none; border-top: none;
            border-left: none; border-right: none;
        }
        .lesson-tab:hover { color: #0F172A; }
        .lesson-tab.active { color: #2563EB; border-bottom-color: #2563EB; }
        .lesson-tab__badge {
            background: #EFF6FF; color: #2563EB; border-radius: 20px;
            padding: 1px 8px; font-size: .72rem; font-weight: 700;
        }
        .lesson-tab__badge--locked {
            background: #F1F5F9; color: #94A3B8;
        }
        .tab-panel { display: none; }
        .tab-panel.active { display: block; }

        /* ── Assignment cards ── */
        .assignment-gate {
            background: #FFF7ED; border: 1.5px solid #FED7AA;
            border-radius: 12px; padding: 20px 24px; text-align: center; margin-bottom: 20px;
        }
        .assignment-gate__icon { font-size: 2rem; margin-bottom: 8px; }
        .assignment-gate__title { font-weight: 800; color: #92400E; margin: 0 0 6px; font-size: 1rem; }
        .assignment-gate__desc { color: #B45309; font-size: .87rem; margin: 0; }

        .assignment-card {
            border: 1.5px solid #E2E8F0; border-radius: 12px; padding: 18px 20px;
            margin-bottom: 14px; background: #fff;
        }
        .assignment-card__title {
            font-weight: 700; font-size: 1rem; color: #0F172A; margin: 0 0 6px;
            display: flex; align-items: center; gap: 8px;
        }
        .assignment-card__meta {
            font-size: .82rem; color: #64748B; margin-bottom: 10px;
            display: flex; flex-wrap: wrap; gap: 10px;
        }
        .assignment-card__desc {
            font-size: .87rem; color: #475569; line-height: 1.55;
            margin-bottom: 12px; white-space: pre-line;
        }
        .assignment-card__actions { display: flex; gap: 10px; flex-wrap: wrap; align-items: center; }
        .btn-do-assignment {
            display: inline-flex; align-items: center; gap: 6px;
            background: #2563EB; color: #fff; border: none; border-radius: 8px;
            padding: 9px 18px; font-size: .88rem; font-weight: 700;
            text-decoration: none; cursor: pointer; transition: background .15s;
        }
        .btn-do-assignment:hover { background: #1D4ED8; color: #fff; }
        .btn-do-assignment--submitted {
            background: #16A34A;
        }
        .btn-do-assignment--submitted:hover { background: #15803D; }
        .assignment-status-done {
            display: inline-flex; align-items: center; gap: 5px;
            color: #16A34A; font-weight: 700; font-size: .85rem;
        }

        /* ── Submit inline form ── */
        .inline-submit-form {
            background: #F8FAFC; border: 1.5px solid #E2E8F0;
            border-radius: 10px; padding: 16px 18px; margin-top: 12px;
        }
        .inline-submit-form label {
            font-size: .82rem; font-weight: 700; color: #475569;
            display: block; margin-bottom: 6px;
        }
        .inline-submit-form textarea {
            width: 100%; box-sizing: border-box;
            border: 1.5px solid #E2E8F0; border-radius: 8px;
            padding: 10px 12px; font-size: .88rem; font-family: inherit;
            resize: vertical; margin-bottom: 10px; min-height: 100px;
        }
        .inline-submit-form textarea:focus { outline: none; border-color: #3B82F6; }
    </style>
</head>
<body>
<jsp:include page="/WEB-INF/views/common/navbar.jsp"/>
<main class="shell">

    <c:choose>
        <c:when test="${study.previewMode}">
            <div class="preview-banner">
                <div>👁️ <strong>Chế độ xem trước dành cho Giảng viên (Preview Mode)</strong> — Trải nghiệm trực quan góc nhìn học viên.</div>
                <a class="button button--outline" style="padding:4px 12px; font-size:.82rem; background:#fff;"
                   href="${pageContext.request.contextPath}/instructor/courses/${study.courseId}">
                    ← Quay lại Quản lý khóa học
                </a>
            </div>
        </c:when>
        <c:otherwise>
            <a class="back-link" href="${pageContext.request.contextPath}/my-courses">← Khóa học của tôi</a>
        </c:otherwise>
    </c:choose>

    <header class="page-heading">
        <div>
            <p class="eyebrow"><c:choose><c:when test="${study.previewMode}">Xem trước khóa học</c:when><c:otherwise>Không gian học viên</c:otherwise></c:choose></p>
            <h1><c:out value="${study.courseTitle}"/></h1>
            <p>Giảng viên <c:out value="${study.instructorName}"/></p>
        </div>
    </header>

    <c:if test="${not empty success}"><div class="alert alert--success"><c:out value="${success}"/></div></c:if>

    <c:choose>
        <c:when test="${empty study.currentLesson}">
            <div class="empty-state">
                <span class="empty-state__mark">○</span>
                <h2>Chưa có bài học để xem</h2>
                <p>Khóa học hiện chưa có bài học nào được hoàn thiện.</p>
                <c:choose>
                    <c:when test="${study.previewMode}">
                        <a class="button button--primary" href="${pageContext.request.contextPath}/instructor/courses/${study.courseId}/lessons/new">➕ Thêm bài học đầu tiên</a>
                    </c:when>
                    <c:otherwise>
                        <a class="button button--outline" href="${pageContext.request.contextPath}/my-courses">Khóa học của tôi</a>
                    </c:otherwise>
                </c:choose>
            </div>
        </c:when>

        <c:otherwise>
            <div class="study-layout">
                <!-- ══ Sidebar Outline ══ -->
                <aside class="card study-sidebar">
                    <h2>Nội dung khóa học</h2>
                    <c:if test="${not study.previewMode}">
                        <p class="small muted"><c:out value="${study.completedCount}"/> / <c:out value="${study.totalCount}"/> bài đã hoàn thành</p>
                        <progress value="${study.completedCount}" max="${study.totalCount}"></progress>
                    </c:if>

                    <ol class="study-outline" style="list-style:none; padding:0; margin:14px 0 0;">
                        <c:forEach var="item" items="${study.lessons}">
                            <li style="margin-bottom:8px;">
                                <a class="<c:if test='${item.current}'>study-outline__active</c:if>"
                                   href="<c:choose><c:when test='${study.previewMode}'>${pageContext.request.contextPath}/instructor/courses/${study.courseId}/preview/lessons/${item.lessonId}</c:when><c:otherwise>${pageContext.request.contextPath}/courses/${study.courseId}/lessons/${item.lessonId}</c:otherwise></c:choose>"
                                   style="display:flex; align-items:center; justify-content:space-between; gap:8px; padding:8px 12px; border-radius:6px; text-decoration:none;">
                                    <div style="display:flex; align-items:center; gap:6px;">
                                        <span>
                                            <c:choose>
                                                <c:when test="${item.lessonType eq 'VIDEO'}">🎥</c:when>
                                                <c:when test="${item.lessonType eq 'QUIZ'}">📝</c:when>
                                                <c:otherwise>📄</c:otherwise>
                                            </c:choose>
                                        </span>
                                        <span><c:out value="${item.title}"/></span>
                                    </div>
                                    <c:if test="${item.completed}"><span class="pill pill--success">Đã học</span></c:if>
                                    <c:if test="${item.preview}"><span class="pill pill--neutral" style="font-size:.7rem;">Thử</span></c:if>
                                </a>
                            </li>
                        </c:forEach>
                    </ol>

                    <div style="margin-top:16px; padding-top:14px; border-top:1px dashed #E2E8F0;">
                        <a href="${pageContext.request.contextPath}/courses/${study.courseId}/quizzes"
                           class="button button--outline" style="width:100%; display:block; text-align:center; font-size:.85rem; padding:8px 12px; background:#FAF5FF; border-color:#D8B4FE; color:#7E22CE; font-weight:600; text-decoration:none; border-radius:8px;">
                            📝 Danh sách Quiz của khóa
                        </a>
                    </div>
                </aside>

                <!-- ══ Main Content ══ -->
                <article class="card study-content">
                    <p class="eyebrow">
                        Bài <c:out value="${study.currentLesson.orderIndex}"/>
                        <c:if test="${study.currentLessonType eq 'VIDEO'}"> · 🎥 Bài giảng Video</c:if>
                        <c:if test="${study.currentLessonType eq 'QUIZ'}"> · 📝 Bài tập / Quiz</c:if>
                    </p>
                    <h2><c:out value="${study.currentLesson.title}"/></h2>

                    <%-- ── Tab header ── --%>
                    <c:set var="hasAssignments" value="${not empty study.currentLessonAssignments}"/>
                    <c:set var="hasQuizzes" value="${not empty study.currentLessonQuizzes}"/>
                    <c:set var="hasExercises" value="${hasAssignments or hasQuizzes}"/>
                    <div class="lesson-tabs">
                        <button class="lesson-tab active" id="tab-lesson" onclick="switchTab('lesson')">
                            📖 Nội dung bài học
                        </button>
                        <c:if test="${hasExercises}">
                            <button class="lesson-tab" id="tab-exercise" onclick="switchTab('exercise')">
                                ✏️ Bài tập & Quiz
                                <span class="lesson-tab__badge<c:if test='${not study.currentLessonCompleted and not study.previewMode}'> lesson-tab__badge--locked</c:if>">
                                    <c:set var="exerciseCount" value="${study.currentLessonAssignments.size() + study.currentLessonQuizzes.size()}"/>
                                    ${exerciseCount}
                                </span>
                            </button>
                        </c:if>
                    </div>

                    <%-- ════ TAB 1: Bài học ════ --%>
                    <div class="tab-panel active" id="panel-lesson">

                        <!-- Video Player -->
                        <c:if test="${study.currentLessonType eq 'VIDEO' and not empty study.currentVideoUrl}">
                            <c:if test="${not study.currentAllowSeek}">
                                <div class="seek-notice">⚠️ Bài học yêu cầu xem tuần tự để nắm vững kiến thức (Hạn chế tua nhanh).</div>
                            </c:if>
                            <div class="video-container" id="studyPlayerContainer"></div>
                        </c:if>

                        <!-- Text / Article Body -->
                        <c:if test="${not empty study.lessonContent}">
                            <div class="lesson-body" style="white-space:pre-wrap; line-height:1.6; margin-bottom:24px;">
                                <c:out value="${study.lessonContent}"/>
                            </div>
                        </c:if>

                        <!-- Materials -->
                        <h3 style="display:flex; align-items:center; gap:8px;">
                            📁 Tài liệu & Tài nguyên đính kèm
                            <c:if test="${not empty study.materials}">
                                <span style="font-size:.8rem; font-weight:700; background:#EFF6FF; color:#2563EB; padding:2px 8px; border-radius:12px;">
                                    ${study.materials.size()} tệp
                                </span>
                            </c:if>
                        </h3>
                        <c:choose>
                            <c:when test="${empty study.materials}">
                                <p class="muted">Chưa có tài liệu đính kèm cho bài học này.</p>
                            </c:when>
                            <c:otherwise>
                                <div class="material-list">
                                    <c:forEach var="material" items="${study.materials}">
                                        <c:set var="fullMatUrl" value="${material.fileUrl}"/>
                                        <c:if test="${not fn:startsWith(fullMatUrl, 'http://') and not fn:startsWith(fullMatUrl, 'https://') and not fn:startsWith(fullMatUrl, pageContext.request.contextPath)}">
                                            <c:set var="fullMatUrl" value="${pageContext.request.contextPath}${fullMatUrl}"/>
                                        </c:if>

                                        <article class="material-card">
                                            <div style="display:flex; align-items:center; gap:12px; flex:1; min-width:240px;">
                                                <div style="font-size:1.6rem; line-height:1; flex-shrink:0;">
                                                    <c:choose>
                                                        <c:when test="${material.type eq 'VIDEO'}">🎬</c:when>
                                                        <c:when test="${fn:endsWith(fn:toLowerCase(fullMatUrl), '.pdf')}">📕</c:when>
                                                        <c:when test="${fn:endsWith(fn:toLowerCase(fullMatUrl), '.doc') or fn:endsWith(fn:toLowerCase(fullMatUrl), '.docx')}">📘</c:when>
                                                        <c:when test="${fn:endsWith(fn:toLowerCase(fullMatUrl), '.xls') or fn:endsWith(fn:toLowerCase(fullMatUrl), '.xlsx')}">📗</c:when>
                                                        <c:when test="${fn:endsWith(fn:toLowerCase(fullMatUrl), '.ppt') or fn:endsWith(fn:toLowerCase(fullMatUrl), '.pptx')}">📙</c:when>
                                                        <c:when test="${fn:endsWith(fn:toLowerCase(fullMatUrl), '.png') or fn:endsWith(fn:toLowerCase(fullMatUrl), '.jpg') or fn:endsWith(fn:toLowerCase(fullMatUrl), '.jpeg') or fn:endsWith(fn:toLowerCase(fullMatUrl), '.webp')}">🖼️</c:when>
                                                        <c:when test="${fn:endsWith(fn:toLowerCase(fullMatUrl), '.zip') or fn:endsWith(fn:toLowerCase(fullMatUrl), '.rar')}">📦</c:when>
                                                        <c:when test="${material.type eq 'LINK'}">🔗</c:when>
                                                        <c:otherwise>📄</c:otherwise>
                                                    </c:choose>
                                                </div>
                                                <div style="min-width:0;">
                                                    <div style="font-weight:700; color:#0F172A; font-size:.92rem; overflow:hidden; text-overflow:ellipsis; white-space:nowrap; max-width:480px;">
                                                        <c:out value="${material.title}"/>
                                                    </div>
                                                    <div style="font-size:.76rem; color:#64748B; margin-top:2px; display:flex; align-items:center; gap:8px; flex-wrap:wrap;">
                                                        <span class="pill pill--neutral" style="font-size:.68rem; padding:1px 7px;">
                                                            <c:choose>
                                                                <c:when test="${material.type eq 'VIDEO'}">Video</c:when>
                                                                <c:when test="${material.type eq 'DOCUMENT'}">Tài liệu</c:when>
                                                                <c:otherwise>Liên kết</c:otherwise>
                                                            </c:choose>
                                                        </span>
                                                        <c:if test="${not empty material.originalFileName}">
                                                            <span style="overflow:hidden; text-overflow:ellipsis; max-width:220px; white-space:nowrap;"><c:out value="${material.originalFileName}"/></span>
                                                        </c:if>
                                                        <c:if test="${not empty material.sizeBytes and material.sizeBytes > 0}">
                                                            <span>• <fmt:formatNumber value="${material.sizeBytes / 1024 / 1024}" maxFractionDigits="2"/> MB</span>
                                                        </c:if>
                                                    </div>
                                                </div>
                                            </div>

                                            <div style="display:flex; align-items:center; gap:8px; flex-wrap:wrap;">
                                                <c:if test="${not empty fullMatUrl}">
                                                    <!-- Nút 1: Xem trực tiếp trên web -->
                                                    <button type="button" class="btn-mat-preview"
                                                            onclick="openMaterialPreview('<c:out value="${material.title}" escapeXml="true"/>', '<c:out value="${fullMatUrl}" escapeXml="true"/>', '<c:out value="${material.type}"/>', '<c:out value="${material.originalFileName}" escapeXml="true"/>')">
                                                        👁️ Xem trực tiếp
                                                    </button>
                                                    <!-- Nút 2: Tải về máy tính -->
                                                    <a href="<c:out value='${fullMatUrl}'/>" download="<c:out value='${material.title}'/>" target="_blank" rel="noopener noreferrer"
                                                       class="btn-mat-download">
                                                        ⬇️ Tải về
                                                    </a>
                                                </c:if>
                                            </div>
                                        </article>
                                    </c:forEach>
                                </div>
                            </c:otherwise>
                        </c:choose>

                        <!-- Navigation & Complete Actions -->
                        <div class="study-actions" style="margin-top:24px;">
                            <c:choose>
                                <c:when test="${study.previewMode}">
                                    <c:if test="${not empty study.prevLessonId}">
                                        <a class="button button--outline" href="${pageContext.request.contextPath}/instructor/courses/${study.courseId}/preview/lessons/${study.prevLessonId}">← Bài trước</a>
                                    </c:if>
                                    <a class="button button--outline" style="border-color:#2563EB; color:#2563EB;"
                                       href="${pageContext.request.contextPath}/instructor/courses/${study.courseId}/lessons/${study.currentLesson.lessonId}/edit">
                                        ✏️ Chỉnh sửa bài học này
                                    </a>
                                    <c:if test="${not empty study.nextLessonId}">
                                        <a class="button button--outline" href="${pageContext.request.contextPath}/instructor/courses/${study.courseId}/preview/lessons/${study.nextLessonId}">Bài tiếp →</a>
                                    </c:if>
                                </c:when>
                                <c:otherwise>
                                    <c:if test="${not empty study.prevLessonId}">
                                        <a class="button button--outline" href="${pageContext.request.contextPath}/courses/${study.courseId}/lessons/${study.prevLessonId}">← Bài trước</a>
                                    </c:if>
                                    <c:if test="${not study.currentLesson.completed}">
                                        <form method="post" action="${pageContext.request.contextPath}/courses/${study.courseId}/lessons/${study.currentLesson.lessonId}/complete">
                                            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                            <button class="button button--primary" type="submit">✅ Đánh dấu đã học</button>
                                        </form>
                                    </c:if>
                                    <c:if test="${study.currentLesson.completed and hasExercises}">
                                        <button class="button button--outline" style="border-color:#2563EB;color:#2563EB;"
                                                onclick="switchTab('exercise')">
                                            ✏️ Làm bài tập & Quiz →
                                        </button>
                                    </c:if>
                                    <c:if test="${not empty study.nextLessonId}">
                                        <a class="button button--outline" href="${pageContext.request.contextPath}/courses/${study.courseId}/lessons/${study.nextLessonId}">Bài tiếp →</a>
                                    </c:if>
                                </c:otherwise>
                            </c:choose>
                        </div>

                    </div><%-- END panel-lesson --%>

                    <%-- ════ TAB 2: Bài tập & Quiz ════ --%>
                    <c:if test="${hasExercises}">
                        <div class="tab-panel" id="panel-exercise">

                            <c:choose>
                                <%-- Chưa hoàn thành bài học → hiện cảnh báo --%>
                                <c:when test="${not study.currentLessonCompleted and not study.previewMode}">
                                    <div class="assignment-gate">
                                        <div class="assignment-gate__icon">🔒</div>
                                        <p class="assignment-gate__title">Hãy hoàn thành bài học trước</p>
                                        <p class="assignment-gate__desc">
                                            Xem hết nội dung video và văn bản, sau đó nhấn
                                            <strong>"Đánh dấu đã học"</strong> để mở khóa bài tập này.
                                        </p>
                                        <div style="margin-top:14px;">
                                            <button class="button button--outline" onclick="switchTab('lesson')">
                                                ← Quay lại bài học
                                            </button>
                                        </div>
                                    </div>
                                </c:when>

                                <c:otherwise>
                                    <c:if test="${study.currentLessonCompleted and not study.previewMode}">
                                        <div style="background:#ECFDF5;border:1px solid #86EFAC;border-radius:8px;padding:10px 16px;margin-bottom:16px;font-size:.87rem;font-weight:600;color:#166534;">
                                            ✅ Bạn đã hoàn thành bài học. Làm bài tập / quiz bên dưới để củng cố kiến thức!
                                        </div>
                                    </c:if>

                                    <%-- ── QUIZZES ── --%>
                                    <c:forEach var="qv" items="${study.currentLessonQuizzes}">
                                        <div class="assignment-card" style="border-color:#7E22CE20;">
                                            <div class="assignment-card__title">
                                                📝 <c:out value="${qv.title}"/>
                                                <c:if test="${qv.myAttemptCount > 0}">
                                                    <span class="pill pill--neutral" style="font-size:.72rem;background:#F3E8FF;color:#7E22CE;">Đã làm ${qv.myAttemptCount} lần</span>
                                                </c:if>
                                            </div>
                                            <div class="assignment-card__meta">
                                                <span>⏱ <c:choose>
                                                    <c:when test="${qv.timeLimitMinutes != null}">${qv.timeLimitMinutes} phút</c:when>
                                                    <c:otherwise>Không giới hạn</c:otherwise>
                                                </c:choose></span>
                                                <span>🔄 Tối đa ${qv.maxAttempts} lần</span>
                                                <c:if test="${qv.passingScore != null}">
                                                    <span>🎯 Qua bài: ${qv.passingScore}%</span>
                                                </c:if>
                                            </div>
                                            <div class="assignment-card__actions">
                                                <c:choose>
                                                    <c:when test="${qv.inProgressAttemptId != null}">
                                                        <a class="btn-do-assignment"
                                                           href="${pageContext.request.contextPath}/courses/${study.courseId}/quizzes/${qv.quizId}/attempts/${qv.inProgressAttemptId}">
                                                            ▶ Tiếp tục làm bài
                                                        </a>
                                                    </c:when>
                                                    <c:when test="${qv.myAttemptCount >= qv.maxAttempts}">
                                                        <span style="color:#94A3B8;font-size:.88rem;font-weight:600;">🔒 Đã hết lượt làm</span>
                                                        <a class="button button--outline" style="font-size:.83rem;padding:6px 14px;"
                                                           href="${pageContext.request.contextPath}/courses/${study.courseId}/quizzes/${qv.quizId}">
                                                            Xem lịch sử →
                                                        </a>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <a class="btn-do-assignment" style="background:#7E22CE;"
                                                           href="${pageContext.request.contextPath}/courses/${study.courseId}/quizzes/${qv.quizId}">
                                                            📝 <c:choose>
                                                                <c:when test="${qv.myAttemptCount > 0}">Làm lại</c:when>
                                                                <c:otherwise>Vào làm bài</c:otherwise>
                                                            </c:choose>
                                                        </a>
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>
                                        </div>
                                    </c:forEach>

                                    <%-- ── ASSIGNMENTS ── --%>
                                    <c:forEach var="asgn" items="${study.currentLessonAssignments}">
                                        <div class="assignment-card">
                                            <div class="assignment-card__title">
                                                📋 <c:out value="${asgn.title}"/>
                                                <c:if test="${asgn.hasSubmitted}">
                                                    <span class="pill pill--success" style="font-size:.72rem;">Đã nộp</span>
                                                </c:if>
                                            </div>
                                            <div class="assignment-card__meta">
                                                <span>⭐ Điểm tối đa: <strong>${asgn.maxScore}</strong></span>
                                                <c:if test="${not empty asgn.dueDate}">
                                                    <span>⏰ Hạn: <c:out value="${asgn.dueDate}"/></span>
                                                </c:if>
                                                <c:if test="${asgn.allowResubmit}">
                                                    <span>🔄 Cho phép nộp lại (${asgn.maxAttempts} lần)</span>
                                                </c:if>
                                                <c:if test="${asgn.attemptCount > 0}">
                                                    <span>📤 Đã nộp ${asgn.attemptCount} lần</span>
                                                </c:if>
                                            </div>
                                            <c:if test="${not empty asgn.description}">
                                                <div class="assignment-card__desc"><c:out value="${asgn.description}"/></div>
                                            </c:if>
                                            <div class="assignment-card__actions">
                                                <c:choose>
                                                    <c:when test="${asgn.hasSubmitted and not asgn.allowResubmit}">
                                                        <span class="assignment-status-done">✅ Đã nộp bài</span>
                                                        <a class="button button--outline" style="font-size:.83rem;padding:6px 14px;"
                                                           href="${pageContext.request.contextPath}/courses/${study.courseId}/assignments/${asgn.assignmentId}/result">
                                                            Xem kết quả →
                                                        </a>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <button class="btn-do-assignment<c:if test='${asgn.hasSubmitted}'> btn-do-assignment--submitted</c:if>"
                                                                onclick="toggleSubmitForm('form-${asgn.assignmentId}')">
                                                            <c:choose>
                                                                <c:when test="${asgn.hasSubmitted}">🔄 Nộp lại</c:when>
                                                                <c:otherwise>✏️ Làm bài ngay</c:otherwise>
                                                            </c:choose>
                                                        </button>
                                                        <c:if test="${asgn.hasSubmitted}">
                                                            <a class="button button--outline" style="font-size:.83rem;padding:6px 14px;"
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
                                                        <label for="answer-${asgn.assignmentId}">📝 Nội dung trả lời *</label>
                                                        <textarea id="answer-${asgn.assignmentId}" name="answerText" required
                                                                  placeholder="Viết câu trả lời của bạn..."></textarea>
                                                        <label for="file-${asgn.assignmentId}" style="margin-top:6px;">📎 URL file đính kèm (tùy chọn)</label>
                                                        <input type="url" id="file-${asgn.assignmentId}" name="fileUrl"
                                                               style="width:100%;box-sizing:border-box;border:1.5px solid #E2E8F0;border-radius:8px;padding:8px 12px;font-size:.87rem;margin-bottom:10px;"
                                                               placeholder="https://drive.google.com/...">
                                                        <div style="display:flex;gap:10px;">
                                                            <button class="btn-do-assignment" type="submit">📤 Nộp bài</button>
                                                            <button type="button" class="button button--outline"
                                                                    onclick="toggleSubmitForm('form-${asgn.assignmentId}')">Hủy</button>
                                                        </div>
                                                    </form>
                                                </div>
                                            </c:if>
                                        </div>
                                    </c:forEach>

                                </c:otherwise>
                            </c:choose>

                        </div><%-- END panel-exercise --%>
                    </c:if>

                </article>
            </div>
        </c:otherwise>
    </c:choose>

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

</main>
<jsp:include page="/WEB-INF/views/common/footer.jsp"/>

<script>
// ── Material In-Web Preview ──
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
    // Check PowerPoint & other Office formats
    else if (lowerOrig.match(/\.(pptx?|doc)$/) || lowerUrl.match(/\.(pptx?|doc)$/)) {
        iconElem.textContent = '📙';
        contentElem.innerHTML = '<div style="text-align:center;background:#fff;padding:40px;border-radius:14px;max-width:520px;box-shadow:0 12px 35px rgba(0,0,0,.25);margin:20px;">' +
            '<div style="font-size:3.5rem;margin-bottom:12px;">📑</div>' +
            '<h3 style="margin:0 0 8px;color:#0F172A;font-size:1.2rem;">' + (origName || title) + '</h3>' +
            '<p style="color:#64748B;font-size:.88rem;line-height:1.6;margin:0 0 24px;">Tệp trình chiếu PowerPoint / Tài liệu cũ. Trình duyệt không hỗ trợ đọc trực tiếp, bạn vui lòng tải về máy để mở bằng PowerPoint / Word.</p>' +
            '<div style="display:flex;gap:12px;justify-content:center;flex-wrap:wrap;">' +
                '<a href="' + url + '" download="' + (origName || title) + '" style="background:#2563EB;color:#fff;padding:10px 22px;border-radius:8px;font-weight:700;text-decoration:none;display:inline-flex;align-items:center;gap:6px;">⬇️ Tải tệp về máy</a>' +
            '</div>' +
        '</div>';
    }
    // Generic iframe fallback (code, text, html, etc.)
    else {
        iconElem.textContent = '📄';
        contentElem.innerHTML = '<iframe src="' + url + '" width="100%" height="100%" style="border:none;background:#fff;" title="' + title + '"></iframe>';
    }

    modal.classList.add('open');
    document.body.style.overflow = 'hidden';
}

function closeMaterialPreview() {
    var modal = document.getElementById('materialPreviewModal');
    var contentElem = document.getElementById('matModalContent');
    if (contentElem) contentElem.innerHTML = '';
    if (modal) modal.classList.remove('open');
    document.body.style.overflow = '';
}

function toggleMaterialFullscreen() {
    var modal = document.getElementById('materialPreviewModal');
    if (modal) modal.classList.toggle('fullscreen');
}

document.addEventListener('keydown', function(e) {
    if (e.key === 'Escape') closeMaterialPreview();
});
// ── Tab switching ──
function switchTab(name) {
    document.querySelectorAll('.lesson-tab').forEach(function(t) { t.classList.remove('active'); });
    document.querySelectorAll('.tab-panel').forEach(function(p) { p.classList.remove('active'); });
    var btn = document.getElementById('tab-' + name);
    var panel = document.getElementById('panel-' + name);
    if (btn) btn.classList.add('active');
    if (panel) panel.classList.add('active');
}

// Auto-switch tab if requested (e.g. after assignment submit)
(function() {
    var initial = '<c:out value="${initialTab}"/>';
    if (initial === 'exercise') {
        switchTab('exercise');
    }
})();

// ── Toggle inline submit form ──
function toggleSubmitForm(id) {
    var el = document.getElementById(id);
    if (el) el.style.display = el.style.display === 'none' ? 'block' : 'none';
}

// ── Video player ──
(function() {
    var rawUrl = '<c:out value="${study.currentVideoUrl}"/>';
    var container = document.getElementById('studyPlayerContainer');
    var allowSeek = <c:out value="${study.currentAllowSeek}"/>;
    if (!rawUrl || !container) return;

    var url = rawUrl.trim();
    if (url.indexOf('youtube.com') !== -1 || url.indexOf('youtu.be') !== -1) {
        var videoId = '';
        if (url.indexOf('watch?v=') !== -1) {
            videoId = url.split('watch?v=')[1].split('&')[0];
        } else if (url.indexOf('youtu.be/') !== -1) {
            videoId = url.split('youtu.be/')[1].split('?')[0];
        } else {
            videoId = url;
        }
        var embedUrl = videoId.indexOf('http') === 0 ? videoId : 'https://www.youtube.com/embed/' + videoId;
        container.innerHTML = '<iframe src="' + embedUrl + '" allowfullscreen allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"></iframe>';
    } else {
        var seekAttr = (!allowSeek) ? ' onseeking="this.currentTime=0;"' : '';
        container.innerHTML = '<video controls preload="metadata"' + seekAttr + '><source src="' + url + '" type="video/mp4">Trình duyệt không hỗ trợ phát video.</video>';
    }
})();
</script>
</body>
</html>
