<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chi tiết bài học: <c:out value="${lesson.title}"/> — EduSphere</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/instructor.css">
    <!-- Document Viewers for in-browser Word & Excel preview -->
    <script src="${pageContext.request.contextPath}/assets/js/jszip.min.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/docx-preview.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/xlsx.full.min.js"></script>
    <style>
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
        .upload-row {
            display: flex; gap: 8px; align-items: center; margin-top: 4px;
        }
        .upload-btn {
            background: #F1F5F9; border: 1.5px solid #CBD5E1; border-radius: var(--r8);
            padding: 8px 14px; font-size: .84rem; font-weight: 700; color: #1E293B;
            cursor: pointer; display: inline-flex; align-items: center; gap: 6px;
            white-space: nowrap; transition: all .2s;
        }
        .upload-btn:hover {
            background: #E2E8F0; border-color: #94A3B8;
        }
        .upload-status {
            font-size: .8rem; margin-top: 4px; font-weight: 600;
        }
        .upload-status--loading { color: #2563EB; }
        .upload-status--success { color: #16A34A; }
        .upload-status--error { color: #DC2626; }
    </style>
</head>
<body>
<div class="ins-layout">
    <jsp:include page="/WEB-INF/views/courses/ins-sidebar.jsp"/>
    <div class="ins-main-wrapper">
        <jsp:include page="/WEB-INF/views/courses/ins-header.jsp"/>
        <main class="ins-page">

        <c:if test="${not empty success}"><div class="ins-alert ins-alert--success">✅ <c:out value="${success}"/></div></c:if>

        <div class="ins-detail-layout">

            <!-- Nội dung bài học -->
            <div>
                <div class="ins-detail-main">
                    <div class="ins-detail-main__header">
                        <div style="display:flex;align-items:center;gap:10px;margin-bottom:6px;flex-wrap:wrap;">
                            <span style="color:rgba(255,255,255,.7);font-size:.8rem;font-weight:600">
                                <c:choose>
                                    <c:when test="${not empty lesson.section}">Chương: <c:out value="${lesson.section.title}"/> · </c:when>
                                    <c:otherwise>Mục chung · </c:otherwise>
                                </c:choose>
                                Bài ${lesson.orderIndex} · <c:out value="${course.title}"/>
                            </span>
                            <span class="ins-status-badge" style="background:#DBEAFE; color:#1D4ED8; font-size:.72rem;">
                                <c:choose>
                                    <c:when test="${lesson.lessonType eq 'VIDEO'}">🎥 Video</c:when>
                                    <c:when test="${lesson.lessonType eq 'QUIZ'}">📝 Quiz</c:when>
                                    <c:otherwise>📄 Văn bản</c:otherwise>
                                </c:choose>
                            </span>
                            <c:if test="${lesson.isPreview}">
                                <span class="ins-status-badge" style="background:#DCFCE7; color:#15803D; font-size:.72rem;">👁️ Xem thử miễn phí</span>
                            </c:if>
                        </div>
                        <h1><c:out value="${lesson.title}"/></h1>
                    </div>
                    <div class="ins-detail-main__body">

                        <!-- Video info if present -->
                        <c:if test="${lesson.lessonType eq 'VIDEO'}">
                            <h2>Video bài giảng</h2>
                            <div style="background:#F8FAFC; border:1px solid #E2E8F0; border-radius:var(--r12); padding:18px 20px; margin-bottom:20px;">

                                <%-- Trường hợp 1: Đã có Bunny Video (player URL từ Bunny) --%>
                                <c:if test="${not empty lesson.videoUrl and fn:startsWith(lesson.videoUrl, 'https://player.mediadelivery.net')}">
                                    <c:choose>
                                        <c:when test="${lesson.videoStatus eq 'READY' or empty lesson.videoStatus}">
                                            <%-- READY — hiển thị player --%>
                                            <div style="position:relative; padding-bottom:56.25%; height:0; border-radius:8px; overflow:hidden; background:#000; margin-bottom:12px;">
                                                <iframe src="<c:out value='${lesson.videoUrl}'/>"
                                                        style="position:absolute;top:0;left:0;width:100%;height:100%;border:0;"
                                                        allowfullscreen allow="autoplay; encrypted-media"></iframe>
                                            </div>
                                            <div style="display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:10px;">
                                                <div style="font-size:.82rem; color:#64748B;">
                                                    <span style="background:#DCFCE7; color:#15803D; font-weight:700; padding:2px 8px; border-radius:4px; font-size:.75rem;">✅ READY</span>
                                                    Thời lượng: <strong>${not empty lesson.videoDuration ? lesson.videoDuration : '—'} phút</strong> ·
                                                    Tua video: <strong>${lesson.allowSeek ? 'Cho phép' : 'Bị khóa'}</strong>
                                                </div>
                                            </div>
                                        </c:when>
                                        <c:when test="${lesson.videoStatus eq 'PROCESSING' or lesson.videoStatus eq 'UPLOADING'}">
                                            <%-- PROCESSING / UPLOADING — thông báo chờ --%>
                                            <div style="background:#EFF6FF; border:1.5px solid #93C5FD; border-radius:8px; padding:20px; text-align:center;" id="processingBanner">
                                                <div style="font-size:2rem; margin-bottom:8px;">⏳</div>
                                                <div style="font-weight:700; color:#1D4ED8; font-size:.95rem; margin-bottom:4px;">
                                                    <c:choose>
                                                        <c:when test="${lesson.videoStatus eq 'UPLOADING'}">Đang upload video lên Bunny Stream...</c:when>
                                                        <c:otherwise>Bunny Stream đang xử lý video...</c:otherwise>
                                                    </c:choose>
                                                </div>
                                                <div style="font-size:.83rem; color:#3B82F6;">Quá trình này thường mất 1–5 phút. Trang sẽ tự cập nhật.</div>
                                            </div>
                                            <%-- Auto-poll trạng thái --%>
                                            <script>
                                            (function() {
                                                var lessonId = '${lesson.lessonId}';
                                                var ctx = '${pageContext.request.contextPath}';
                                                function poll() {
                                                    fetch(ctx + '/instructor/videos/' + lessonId + '/status')
                                                        .then(function(r) { return r.json(); })
                                                        .then(function(d) {
                                                            if (d.videoStatus === 'READY' || d.videoStatus === 'FAILED') {
                                                                location.reload();
                                                            } else {
                                                                setTimeout(poll, 10000);
                                                            }
                                                        })
                                                        .catch(function() { setTimeout(poll, 15000); });
                                                }
                                                setTimeout(poll, 8000);
                                            })();
                                            </script>
                                        </c:when>
                                        <c:otherwise>
                                            <%-- FAILED --%>
                                            <div style="background:#FEF2F2; border:1.5px solid #FCA5A5; border-radius:8px; padding:16px;">
                                                <div style="font-weight:700; color:#DC2626; margin-bottom:4px;">❌ Xử lý video thất bại</div>
                                                <div style="font-size:.83rem; color:#EF4444;">Bunny Stream không thể xử lý video này. Hãy thử upload lại bên dưới.</div>
                                            </div>
                                        </c:otherwise>
                                    </c:choose>
                                </c:if>

                                <%-- Trường hợp 2: Video URL thông thường (YouTube, Vimeo, local) --%>
                                <c:if test="${not empty lesson.videoUrl and not fn:startsWith(lesson.videoUrl, 'https://player.mediadelivery.net')}">
                                    <div style="font-weight:700; color:var(--ink); margin-bottom:6px;">
                                        URL: <a href="<c:out value='${lesson.videoUrl}'/>" target="_blank" style="color:#2563EB;"><c:out value="${lesson.videoUrl}"/> ↗</a>
                                    </div>
                                    <div style="font-size:.82rem; color:#64748B;">
                                        Thời lượng: <strong>${not empty lesson.videoDuration ? lesson.videoDuration : '—'} phút</strong> ·
                                        Tua video: <strong>${lesson.allowSeek ? 'Cho phép' : 'Bị khóa'}</strong>
                                    </div>
                                </c:if>

                                <%-- Trường hợp 3: Chưa có video --%>
                                <c:if test="${empty lesson.videoUrl}">
                                    <div style="color:#94A3B8; font-style:italic;">Chưa có video. Upload bên dưới.</div>
                                </c:if>

                                <%-- Upload video Bunny ngay từ trang này --%>
                                <c:if test="${editable}">
                                    <div style="margin-top:16px; padding-top:14px; border-top:1px solid #E2E8F0;">
                                        <div style="font-size:.84rem; font-weight:700; color:#475569; margin-bottom:8px;">
                                            ☁️ Upload video lên Bunny Stream
                                        </div>
                                        <div class="upload-row">
                                            <button type="button" class="upload-btn" style="background:#EFF6FF; border-color:#93C5FD; color:#1D4ED8;"
                                                    onclick="document.getElementById('bunnyVideoInput').click()">
                                                ☁️ Chọn file video (MP4, WebM, MOV — tối đa 2GB)
                                            </button>
                                        </div>
                                        <input type="file" id="bunnyVideoInput" accept="video/mp4,video/webm,video/quicktime,video/*"
                                               style="display:none;" onchange="uploadBunnyVideo(this, ${lesson.lessonId})"/>
                                        <div id="bunnyUploadStatus" class="upload-status" style="margin-top:8px;"></div>
                                        <div id="bunnyUploadProgress" style="display:none; margin-top:8px;">
                                            <div style="background:#E2E8F0; border-radius:99px; height:8px; overflow:hidden;">
                                                <div id="bunnyProgressBar" style="height:100%; background:#2563EB; width:0%; transition:width .3s; border-radius:99px;"></div>
                                            </div>
                                            <div id="bunnyProgressText" style="font-size:.75rem; color:#64748B; margin-top:4px;"></div>
                                        </div>
                                    </div>
                                </c:if>
                            </div>
                        </c:if>

                        <!-- ======================================================== -->
                        <!-- 🤖 KHU VỰC TÀI LIỆU HỌC TẬP AI (Faster-Whisper + Qwen)  -->
                        <!-- ======================================================== -->
                        <div class="ai-mat-card" id="aiMaterialCard"
                             data-course-id="${course.courseId}"
                             data-lesson-id="${lesson.lessonId}"
                             data-csrf-param="${_csrf.parameterName}"
                             data-csrf-token="${_csrf.token}"
                             data-context-path="${pageContext.request.contextPath}">

                            <div class="ai-mat-header">
                                <div>
                                    <div class="ai-badge">✨ EDUSPHERE AI ASSISTANT</div>
                                    <h2 class="ai-mat-title">
                                        <span>🤖</span> Tài liệu học tập AI
                                    </h2>
                                    <p class="ai-mat-sub">
                                        Tự động trích xuất âm thanh, chuyển giọng nói thành văn bản bằng Faster-Whisper và tổng hợp kiến thức chuyên sâu bằng mô hình Qwen 2.5:3B.
                                    </p>
                                </div>

                                <div class="ai-mat-actions" id="aiActionsArea">
                                    <c:choose>
                                        <%-- Chưa có tài liệu hoặc đã thất bại --%>
                                        <c:when test="${empty aiMaterial or aiMaterial.status eq 'FAILED'}">
                                            <button type="button" class="ai-btn ai-btn--primary" id="btnStartAi" onclick="triggerAiGeneration(false)">
                                                <span>✨</span> Tạo tài liệu bằng AI
                                            </button>
                                        </c:when>

                                        <%-- Đang xử lý --%>
                                        <c:when test="${aiMaterial.status eq 'PENDING' or aiMaterial.status eq 'PROCESSING'}">
                                            <button type="button" class="ai-btn ai-btn--secondary" disabled style="opacity:0.8; cursor:wait;">
                                                <span class="ai-spinner"></span> Đang phân tích...
                                            </button>
                                        </c:when>

                                        <%-- Đã hoàn thành --%>
                                        <c:otherwise>
                                            <button type="button" class="ai-btn ai-btn--outline" onclick="openAiEditModal()">
                                                <span>✏️</span> Chỉnh sửa tài liệu
                                            </button>
                                            <button type="button" class="ai-btn ai-btn--secondary" onclick="confirmRegenerateAi()">
                                                <span>🔄</span> Phân tích lại
                                            </button>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>

                            <!-- ── Khối tiến trình xử lý (Progress Banner) ── -->
                            <div id="aiProgressBanner" class="ai-progress-card" style="${(not empty aiMaterial and (aiMaterial.status eq 'PENDING' or aiMaterial.status eq 'PROCESSING')) ? 'display:block;' : 'display:none;'}">
                                <div class="ai-progress-card__head">
                                    <div style="font-weight:800; color:#0369A1; font-size:.92rem; display:flex; align-items:center; gap:8px;">
                                        <span class="ai-spinner" style="border-top-color:#0284C7;"></span>
                                        <span id="aiProgressStepTitle">Đang xử lý phân tích bài giảng...</span>
                                    </div>
                                    <div style="font-weight:800; color:#0284C7; font-size:.9rem;" id="aiProgressPercent">
                                        ${not empty aiMaterial ? (aiMaterial.status eq 'COMPLETED' ? '100%' : '15%') : '0%'}
                                    </div>
                                </div>

                                <div class="ai-progress-bar-wrap">
                                    <div class="ai-progress-bar-fill" id="aiProgressBarFill" style="width: ${not empty aiMaterial ? (aiMaterial.status eq 'COMPLETED' ? '100%' : '15%') : '0%'};"></div>
                                </div>

                                <div style="font-size:.82rem; color:#475569;" id="aiProgressMessage">
                                    Hệ thống đang khởi chạy các mô hình AI cục bộ, quá trình này có thể mất 1–3 phút tùy độ dài video...
                                </div>

                                <!-- 4 Steps Tracker -->
                                <div class="ai-steps-tracker">
                                    <div class="ai-step-item" id="aiStep1">
                                        <span>1️⃣</span> Trích xuất âm thanh
                                    </div>
                                    <div class="ai-step-item" id="aiStep2">
                                        <span>2️⃣</span> Whisper nhận diện
                                    </div>
                                    <div class="ai-step-item" id="aiStep3">
                                        <span>3️⃣</span> Qwen hiệu đính
                                    </div>
                                    <div class="ai-step-item" id="aiStep4">
                                        <span>4️⃣</span> Tổng hợp tài liệu
                                    </div>
                                </div>
                            </div>

                            <!-- ── Thông báo lỗi nếu thất bại ── -->
                            <div id="aiErrorBanner" class="ins-alert" style="background:#FEF2F2; border:1px solid #FECACA; color:#DC2626; margin-bottom:16px; ${(not empty aiMaterial and aiMaterial.status eq 'FAILED') ? 'display:block;' : 'display:none;'}">
                                <div style="font-weight:700; margin-bottom:4px;">❌ Quá trình tạo tài liệu AI gặp sự cố</div>
                                <div id="aiErrorMessage" style="font-size:.86rem;">
                                    <c:out value="${aiMaterial.errorMessage}"/>
                                </div>
                                <div style="margin-top:10px;">
                                    <button type="button" class="ai-btn ai-btn--secondary" style="padding:6px 14px; font-size:.8rem;" onclick="triggerAiGeneration(true)">
                                        <span>🔄</span> Thử phân tích lại
                                    </button>
                                </div>
                            </div>

                            <!-- ── Vùng hiển thị 4 phần tài liệu AI đã hoàn thành ── -->
                            <div id="aiContentArea" style="${(not empty aiMaterial and aiMaterial.status eq 'COMPLETED') ? 'display:block;' : 'display:none;'}">
                                <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:14px; font-size:.82rem; color:#64748B;">
                                    <div>
                                        🤖 Mô hình: <strong><span id="aiModelBadge"><c:out value="${aiMaterial.aiModel}"/></span></strong>
                                    </div>
                                    <div>
                                        Cập nhật: <strong id="aiUpdatedAt"><c:out value="${aiMaterial.updatedAt}"/></strong>
                                    </div>
                                </div>

                                <div class="ai-sections-grid">
                                    <!-- 1. SUMMARY -->
                                    <div class="ai-sec-box">
                                        <div class="ai-sec-title ai-sec-title--summary">
                                            <span>📝</span> 1. TÓM TẮT BÀI HỌC (SUMMARY)
                                        </div>
                                        <div class="ai-sec-content" id="aiDisplaySummary"><c:out value="${aiMaterial.summary}"/></div>
                                    </div>

                                    <!-- 2. KEY POINTS -->
                                    <div class="ai-sec-box">
                                        <div class="ai-sec-title ai-sec-title--keypoints">
                                            <span>💡</span> 2. KIẾN THỨC TRỌNG TÂM (KEY POINTS)
                                        </div>
                                        <div class="ai-sec-content" id="aiDisplayKeyPoints"><c:out value="${aiMaterial.keyPoints}"/></div>
                                    </div>

                                    <!-- 3. TERMS -->
                                    <div class="ai-sec-box">
                                        <div class="ai-sec-title ai-sec-title--terms">
                                            <span>📖</span> 3. THUẬT NGỮ CHUYÊN NGÀNH (TERMS)
                                        </div>
                                        <div class="ai-sec-content" id="aiDisplayTerms"><c:out value="${aiMaterial.terms}"/></div>
                                    </div>

                                    <!-- 4. CONCLUSION -->
                                    <div class="ai-sec-box">
                                        <div class="ai-sec-title ai-sec-title--conclusion">
                                            <span>🎯</span> 4. TỔNG KẾT BÀI HỌC (CONCLUSION)
                                        </div>
                                        <div class="ai-sec-content" id="aiDisplayConclusion"><c:out value="${aiMaterial.conclusion}"/></div>
                                    </div>
                                </div>

                                <!-- Accordion xem Transcripts (Gốc vs Hiệu đính) -->
                                <details class="ai-transcript-toggle" style="margin-top:20px;">
                                    <summary>
                                        <span>📜</span> Xem chi tiết bản ghi lời thoại (Transcript gốc &amp; Bản hiệu đính có mốc thời gian)
                                    </summary>
                                    <div style="display:grid; grid-template-columns:1fr 1fr; gap:16px; padding:16px; background:#F8FAFC;">
                                        <div>
                                            <div style="font-weight:700; font-size:.82rem; color:#475569; margin-bottom:6px;">
                                                🎙️ Transcript gốc từ Faster-Whisper:
                                            </div>
                                            <div class="ai-transcript-body" id="aiDisplayRawTranscript"><c:out value="${aiMaterial.originalTranscript}"/></div>
                                        </div>
                                        <div>
                                            <div style="font-weight:700; font-size:.82rem; color:#1E40AF; margin-bottom:6px;">
                                                ✨ Transcript sau hiệu đính ngữ cảnh Qwen:
                                            </div>
                                            <div class="ai-transcript-body" id="aiDisplayCorrectedTranscript"><c:out value="${aiMaterial.correctedTranscript}"/></div>
                                        </div>
                                    </div>
                                </details>
                            </div>

                            <!-- ── Trạng thái chưa có tài liệu ── -->
                            <div id="aiEmptyPlaceholder" style="${empty aiMaterial ? 'display:block;' : 'display:none;'} padding:24px 0; text-align:center;">
                                <div style="font-size:2.4rem; margin-bottom:8px;">💡</div>
                                <div style="font-weight:700; color:#334155; font-size:.95rem; margin-bottom:4px;">
                                    Chưa có tài liệu AI cho bài học này
                                </div>
                                <div style="font-size:.84rem; color:#64748B; max-width:480px; margin:0 auto 16px auto;">
                                    Nhấn nút <strong>"Tạo tài liệu bằng AI"</strong> để hệ thống tự động nghe video bài giảng, hiệu đính câu chữ và biên soạn tài liệu học tập toàn diện cho học viên.
                                </div>
                            </div>
                        </div>

                        <h2>Nội dung / Ghi chú bài giảng</h2>
                        <div style="font-size:.92rem;color:var(--ink-2);line-height:1.8;white-space:pre-wrap;overflow-wrap:anywhere;background:var(--bg);padding:18px;border-radius:var(--r8);">
                            <c:choose>
                                <c:when test="${not empty lesson.content}"><c:out value="${lesson.content}"/></c:when>
                                <c:otherwise><em style="color:var(--muted)">Chưa có nội dung chữ.</em></c:otherwise>
                            </c:choose>
                        </div>

                        <!-- Instructor Notes if present -->
                        <c:if test="${not empty lesson.instructorNotes}">
                            <h2 style="margin-top:24px;">Ghi chú nội bộ cho Giảng viên</h2>
                            <div style="background:#FFFBEB; border:1px solid #FDE68A; border-radius:var(--r8); padding:14px 18px; font-size:.88rem; color:#92400E; white-space:pre-line;">
                                <c:out value="${lesson.instructorNotes}"/>
                            </div>
                        </c:if>

                        <!-- Danh sách tài liệu -->
                        <h2 style="margin-top:28px">Tài liệu học tập & Đính kèm
                            <span style="font-size:.8rem;font-weight:500;color:var(--muted);margin-left:6px">
                                (${fn:length(materials)} tài liệu)
                            </span>
                        </h2>

                        <c:choose>
                            <c:when test="${empty materials}">
                                <p style="font-size:.88rem;color:var(--muted);font-style:italic;padding:12px 0">
                                    Chưa có tài liệu đính kèm. Thêm file PDF, Slides hoặc mã nguồn mẫu bên dưới.
                                </p>
                            </c:when>
                            <c:otherwise>
                                <div class="ins-material-list">
                                    <c:forEach var="mat" items="${materials}">
                                        <div class="ins-material-item">
                                            <div class="ins-material-item__icon">
                                                <c:choose>
                                                    <c:when test="${mat.type eq 'VIDEO'}">🎬</c:when>
                                                    <c:when test="${mat.type eq 'DOCUMENT'}">📄</c:when>
                                                    <c:otherwise>🔗</c:otherwise>
                                                </c:choose>
                                            </div>
                                            <div class="ins-material-item__info">
                                                <div class="ins-material-item__title"><c:out value="${mat.title}"/></div>
                                                <div style="margin-top:4px">
                                                    <span class="ins-material-type ins-material-type--${mat.type.toLowerCase()}">
                                                        <c:choose>
                                                            <c:when test="${mat.type eq 'VIDEO'}">Video</c:when>
                                                            <c:when test="${mat.type eq 'DOCUMENT'}">Tài liệu</c:when>
                                                            <c:otherwise>Liên kết</c:otherwise>
                                                        </c:choose>
                                                    </span>
                                                </div>
                                            </div>
                                            <div style="display:flex; align-items:center; gap:8px;">
                                                <c:if test="${fn:startsWith(mat.fileUrl,'http://') || fn:startsWith(mat.fileUrl,'https://') || fn:startsWith(mat.fileUrl,'/')}">
                                                    <c:set var="insMatUrl" value="${mat.fileUrl}"/>
                                                    <c:if test="${not empty insMatUrl and not (fn:startsWith(insMatUrl, 'http://') or fn:startsWith(insMatUrl, 'https://'))}">
                                                        <c:choose>
                                                            <c:when test="${not empty pageContext.request.contextPath and fn:startsWith(insMatUrl, pageContext.request.contextPath)}">
                                                                <%-- Already has context path --%>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <c:set var="insMatUrl" value="${pageContext.request.contextPath}${insMatUrl}"/>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </c:if>
                                                    <button type="button" class="ins-link-btn" style="color:#2563EB; font-weight:700; background:#EFF6FF; border:1px solid #BFDBFE; padding:5px 12px; border-radius:6px; cursor:pointer;"
                                                            onclick="openMaterialPreview('<c:out value="${mat.title}" escapeXml="true"/>', '<c:out value="${insMatUrl}" escapeXml="true"/>', '<c:out value="${mat.type}"/>', '<c:out value="${mat.originalFileName}" escapeXml="true"/>')">
                                                        👁️ Xem trên web
                                                     </button>
                                                    <a class="ins-link-btn" href="<c:out value='${insMatUrl}'/>" download="<c:out value='${mat.title}'/>" target="_blank" rel="noopener noreferrer"
                                                       style="padding:5px 10px; border:1px solid #CBD5E1; border-radius:6px;">
                                                        ⬇️ Tải
                                                    </a>
                                                </c:if>
                                                <c:if test="${editable}">
                                                    <form method="post" action="${pageContext.request.contextPath}/instructor/courses/${course.courseId}/lessons/${lesson.lessonId}/materials/${mat.materialId}/delete"
                                                          style="display:inline;margin:0;" onsubmit="return confirm('Bạn có chắc muốn xóa tài liệu này?');">
                                                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                                        <button class="ins-link-btn" style="color:#DC2626;" type="submit">🗑️</button>
                                                    </form>
                                                </c:if>
                                            </div>
                                        </div>
                                    </c:forEach>
                                </div>
                            </c:otherwise>
                        </c:choose>

                        <!-- Form thêm tài liệu -->
                        <c:if test="${editable}">
                            <div style="margin-top:28px;padding-top:20px;border-top:1px solid var(--line)">
                                <h2 style="margin-top:0;margin-bottom:16px">➕ Đính kèm tài liệu mới (Hỗ trợ tải tệp máy tính hoặc dán URL)</h2>
                                <c:if test="${course.status eq 'PUBLISHED' or course.status eq 'APPROVED'}">
                                    <div class="ins-alert" style="background:#ECFDF5;border:1px solid #86EFAC;color:#166534;margin-bottom:16px">
                                        ✅ <strong>Khóa học đang công bố.</strong> Tài liệu đính kèm sẽ được học viên thấy ngay mà không cần gửi duyệt lại.
                                    </div>
                                </c:if>
                                <form:form method="post" modelAttribute="materialForm"
                                           action="${pageContext.request.contextPath}/instructor/courses/${course.courseId}/lessons/${lesson.lessonId}/materials"
                                           htmlEscape="true">
                                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                    <input type="hidden" name="type" id="mat-type" value="DOCUMENT">
                                    <div class="ins-field" style="margin-bottom:16px">
                                        <label for="mat-title">Tên tài liệu / Tiêu đề file <span style="color:#EF4444">*</span></label>
                                        <form:input path="title" id="mat-title" maxlength="255"
                                                    placeholder="VD: Slide bài giảng (PDF), Source code mẫu (.zip)..."/>
                                        <form:errors path="title" cssClass="ins-field__error"/>
                                    </div>
                                    <div class="ins-field">
                                        <label for="mat-url">Đường dẫn URL hoặc Tải từ máy tính <span style="color:#EF4444">*</span></label>
                                        <div class="upload-row">
                                            <form:input path="fileUrl" id="mat-url" maxlength="2048"
                                                        placeholder="Dán link hoặc bấm nút tải tệp từ máy tính..."/>
                                            <button type="button" class="upload-btn" onclick="document.getElementById('matFileInput').click()">
                                                📤 Tải file từ máy
                                            </button>
                                            <input type="file" id="matFileInput" style="display:none;" onchange="uploadMaterialFile(this)"/>
                                        </div>
                                        <div id="matStatus" class="upload-status"></div>
                                        <span class="ins-field__hint">Hỗ trợ tải trực tiếp tệp từ máy tính hoặc dán link Google Drive, Dropbox, GitHub...</span>
                                        <form:errors path="fileUrl" cssClass="ins-field__error"/>
                                    </div>
                                    <button class="ins-form-btn-primary" style="width:auto; padding:9px 20px; margin-top:8px;" type="submit">
                                        ➕ Thêm tài liệu cho bài học
                                    </button>
                                </form:form>
                            </div>
                        </c:if>
                    </div>
                </div>
            </div>

            <!-- Aside actions -->
            <aside class="ins-aside">
                <div class="ins-aside__header">⚡ Thao tác bài học</div>
                <div class="ins-aside__body">
                    <c:if test="${editable}">
                        <a class="ins-btn-primary" style="margin-bottom:10px;"
                           href="${pageContext.request.contextPath}/instructor/courses/${course.courseId}/lessons/${lesson.lessonId}/edit">
                            ✏️ Chỉnh sửa bài học
                        </a>
                    </c:if>
                    <a class="ins-btn-outline"
                       href="${pageContext.request.contextPath}/instructor/courses/${course.courseId}/preview/lessons/${lesson.lessonId}" target="_blank">
                        👁️ Xem trước bài này
                    </a>
                    <div class="ins-aside__divider" style="margin:14px 0;"></div>
                    <a class="ins-btn-outline"
                       href="${pageContext.request.contextPath}/instructor/courses/${course.courseId}">
                        ← Quay lại Quản lý khóa học
                    </a>
                </div>
            </aside>
        </div>

    </main>
    </div>
</div>
<script>
function insToggleMenu(e){e.stopPropagation();document.getElementById('insUserMenu').classList.toggle('open');}
document.addEventListener('click',function(){var m=document.getElementById('insUserMenu');if(m)m.classList.remove('open');});

// Upload video lên Bunny Stream từ trang chi tiết bài học
function uploadBunnyVideo(inputElem, lessonId) {
    if (!inputElem.files || inputElem.files.length === 0) return;
    var file = inputElem.files[0];
    var statusElem   = document.getElementById('bunnyUploadStatus');
    var progressWrap = document.getElementById('bunnyUploadProgress');
    var progressBar  = document.getElementById('bunnyProgressBar');
    var progressText = document.getElementById('bunnyProgressText');

    var allowed = ['mp4','webm','mov','avi','mkv','mpeg','mpg'];
    var ext = file.name.split('.').pop().toLowerCase();
    if (!allowed.includes(ext)) {
        statusElem.className = 'upload-status upload-status--error';
        statusElem.textContent = '❌ Định dạng không hỗ trợ. Cho phép: MP4, WebM, MOV, AVI, MKV.';
        return;
    }
    if (file.size > 2 * 1024 * 1024 * 1024) {
        statusElem.className = 'upload-status upload-status--error';
        statusElem.textContent = '❌ File quá lớn. Giới hạn 2GB.';
        return;
    }

    statusElem.className = 'upload-status upload-status--loading';
    statusElem.textContent = '⏳ Đang upload lên Bunny Stream (' + (file.size/1024/1024).toFixed(1) + ' MB)...';
    progressWrap.style.display = 'block';
    progressBar.style.width = '0%';

    var csrfToken = document.querySelector('input[name="${_csrf.parameterName}"]').value;
    var formData = new FormData();
    formData.append('file', file);
    formData.append('lessonId', lessonId);

    var xhr = new XMLHttpRequest();
    xhr.open('POST', '${pageContext.request.contextPath}/instructor/videos/upload', true);
    xhr.setRequestHeader('X-CSRF-TOKEN', csrfToken);

    xhr.upload.onprogress = function(e) {
        if (e.lengthComputable) {
            var pct = Math.round(e.loaded * 100 / e.total);
            progressBar.style.width = pct + '%';
            progressText.textContent = pct + '% — ' + (e.loaded/1024/1024).toFixed(1)
                + ' / ' + (e.total/1024/1024).toFixed(1) + ' MB';
        }
    };

    xhr.onload = function() {
        var data;
        try { data = JSON.parse(xhr.responseText); } catch(e) { data = {}; }
        if (data.success) {
            statusElem.className = 'upload-status upload-status--success';
            statusElem.textContent = '✅ Upload xong! Bunny đang xử lý. Trang sẽ tự cập nhật sau vài giây...';
            progressBar.style.width = '100%';
            progressText.textContent = 'Đang xử lý trên Bunny CDN...';
            setTimeout(function() { location.reload(); }, 4000);
        } else {
            statusElem.className = 'upload-status upload-status--error';
            statusElem.textContent = '❌ ' + (data.message || 'Upload thất bại');
            progressWrap.style.display = 'none';
        }
    };

    xhr.onerror = function() {
        statusElem.className = 'upload-status upload-status--error';
        statusElem.textContent = '❌ Lỗi kết nối khi upload.';
        progressWrap.style.display = 'none';
    };

    xhr.send(formData);
}

function uploadMaterialFile(inputElem) {
    if (!inputElem.files || inputElem.files.length === 0) return;
    var file = inputElem.files[0];
    var statusElem = document.getElementById('matStatus');
    statusElem.className = 'upload-status upload-status--loading';
    statusElem.textContent = '⏳ Đang tải tệp lên (' + (file.size / 1024 / 1024).toFixed(1) + ' MB)...';

    var formData = new FormData();
    formData.append('file', file);
    formData.append('category', 'material');

    var csrfToken = document.querySelector('input[name="${_csrf.parameterName}"]').value;

    fetch('${pageContext.request.contextPath}/instructor/upload', {
        method: 'POST',
        headers: {
            'X-CSRF-TOKEN': csrfToken
        },
        body: formData
    })
    .then(function(res) { return res.json(); })
    .then(function(data) {
        if (data.success) {
            document.getElementById('mat-url').value = data.url;
            if (!document.getElementById('mat-title').value.trim()) {
                document.getElementById('mat-title').value = data.originalName;
            }
            if (!document.getElementById('mat-type').value) {
                document.getElementById('mat-type').value = 'DOCUMENT';
            }
            statusElem.className = 'upload-status upload-status--success';
            statusElem.textContent = '✅ Đã tải lên thành công: ' + data.originalName;
        } else {
            statusElem.className = 'upload-status upload-status--error';
            statusElem.textContent = '❌ Lỗi: ' + (data.message || 'Không thể tải tệp lên');
        }
    })
    .catch(function(err) {
        statusElem.className = 'upload-status upload-status--error';
        statusElem.textContent = '❌ Lỗi kết nối: ' + err.message;
    });
}

function openMaterialPreview(title, url, type, origName) {
    if (!url) return;

    // Chuẩn hóa URL tài liệu: khử trùng lặp contextPath và đảm bảo đúng endpoint static /uploads/
    var ctx = '${pageContext.request.contextPath}';
    if (ctx && ctx.length > 0) {
        while (url.indexOf(ctx + ctx + '/') === 0) {
            url = url.substring(ctx.length);
        }
        if (url.indexOf('/') === 0 && url.indexOf(ctx + '/') !== 0 && !url.match(/^https?:\/\//i)) {
            url = ctx + url;
        }
    }

    var modal = document.getElementById('materialPreviewModal');
    var titleElem = document.getElementById('matModalTitle');
    var subElem = document.getElementById('matModalSub');
    var iconElem = document.getElementById('matModalIcon');
    var downloadBtn = document.getElementById('matModalDownloadBtn');
    var contentElem = document.getElementById('matModalContent');

    var cleanFileName = origName;
    if (!cleanFileName && url) {
        var parts = url.split('/');
        var rawName = parts[parts.length - 1].split('?')[0];
        try {
            cleanFileName = decodeURIComponent(rawName).replace(/^\d+_[a-f0-9]+_/i, '');
        } catch (e) {
            cleanFileName = rawName.replace(/^\d+_[a-f0-9]+_/i, '');
        }
    }

    titleElem.textContent = title;
    subElem.textContent = cleanFileName ? ('Tệp: ' + cleanFileName) : url;
    downloadBtn.href = url;
    downloadBtn.setAttribute('download', cleanFileName || origName || title);

    var lowerUrl = url.toLowerCase();
    var lowerOrig = (origName || '').toLowerCase();

    if (lowerUrl.indexOf('.pdf') !== -1 || lowerOrig.indexOf('.pdf') !== -1) {
        iconElem.textContent = '📕';
        contentElem.innerHTML = '<iframe src="' + url + '#toolbar=1&navpanes=1" width="100%" height="100%" style="border:none;background:#fff;" title="' + title + '"></iframe>';
    } else if (lowerOrig.indexOf('.docx') !== -1 || lowerUrl.indexOf('.docx') !== -1) {
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
                contentElem.innerHTML = '<div id="docxContainerIns" style="width:100%;height:100%;overflow:auto;background:#525659;padding:24px 10px;box-sizing:border-box;"></div>';
                var target = document.getElementById('docxContainerIns');
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
    } else if (lowerOrig.match(/\.xlsx?$/) || lowerUrl.match(/\.xlsx?$/)) {
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
    } else if (lowerUrl.match(/\.(png|jpe?g|gif|webp|svg)(\?.*)?$/) || lowerOrig.match(/\.(png|jpe?g|gif|webp|svg)$/)) {
        iconElem.textContent = '🖼️';
        contentElem.innerHTML = '<div style="width:100%;height:100%;display:flex;align-items:center;justify-content:center;padding:20px;box-sizing:border-box;"><img src="' + url + '" style="max-width:100%;max-height:100%;object-fit:contain;border-radius:6px;box-shadow:0 8px 30px rgba(0,0,0,.5);" alt="' + title + '"/></div>';
    } else if (type === 'VIDEO' || lowerUrl.match(/\.(mp4|webm|mov)(\?.*)?$/) || lowerUrl.indexOf('youtube.com') !== -1 || lowerUrl.indexOf('youtu.be') !== -1) {
        iconElem.textContent = '🎬';
        if (lowerUrl.indexOf('youtube.com') !== -1 || lowerUrl.indexOf('youtu.be') !== -1) {
            var vId = '';
            if (lowerUrl.indexOf('watch?v=') !== -1) vId = url.split('watch?v=')[1].split('&')[0];
            else if (lowerUrl.indexOf('youtu.be/') !== -1) vId = url.split('youtu.be/')[1].split('?')[0];
            var embed = 'https://www.youtube.com/embed/' + vId;
            contentElem.innerHTML = '<iframe src="' + embed + '" width="100%" height="100%" frameborder="0" allowfullscreen></iframe>';
        } else {
            contentElem.innerHTML = '<video src="' + url + '" controls autoplay style="max-width:100%;max-height:100%;border-radius:8px;"></video>';
        }
    } else if (lowerUrl.match(/\.(mp3|wav|ogg)(\?.*)?$/)) {
        iconElem.textContent = '🎧';
        contentElem.innerHTML = '<div style="text-align:center;color:#fff;"><div style="font-size:3.5rem;margin-bottom:16px;">🎧</div><div style="font-size:1.1rem;font-weight:700;margin-bottom:14px;">' + title + '</div><audio src="' + url + '" controls autoplay style="width:420px;max-width:90%;"></audio></div>';
    } else {
        iconElem.textContent = '📄';
        contentElem.innerHTML = '<iframe src="' + url + '" width="100%" height="100%" style="border:none;background:#fff;" title="' + title + '"></iframe>';
    }

    modal.style.display = 'flex';
    document.body.style.overflow = 'hidden';
}

function closeMaterialPreview() {
    var modal = document.getElementById('materialPreviewModal');
    var contentElem = document.getElementById('matModalContent');
    if (contentElem) contentElem.innerHTML = '';
    if (modal) modal.style.display = 'none';
    document.body.style.overflow = '';
}

function toggleMaterialFullscreen() {
    var modal = document.getElementById('materialPreviewModal');
    if (modal) {
        var box = modal.firstElementChild;
        if (box.style.width === '100vw') {
            box.style.width = '92vw';
            box.style.height = '88vh';
            box.style.maxWidth = '1150px';
            box.style.borderRadius = '14px';
        } else {
            box.style.width = '100vw';
            box.style.height = '100vh';
            box.style.maxWidth = '100vw';
            box.style.borderRadius = '0';
        }
    }
}

document.addEventListener('keydown', function(e) {
    if (e.key === 'Escape') closeMaterialPreview();
});
</script>

<!-- Modal Preview -->
<div id="materialPreviewModal" style="display:none; position:fixed; inset:0; background:rgba(15,23,42,.75); backdrop-filter:blur(4px); z-index:9999; align-items:center; justify-content:center; padding:16px;">
    <div style="background:#fff; border-radius:14px; width:92vw; max-width:1150px; height:88vh; display:flex; flex-direction:column; overflow:hidden; box-shadow:0 25px 50px -12px rgba(0,0,0,.45); transition:all .2s;">
        <div style="display:flex; align-items:center; justify-content:space-between; padding:12px 20px; border-bottom:1px solid #E2E8F0; background:#F8FAFC; flex-shrink:0;">
            <div style="display:flex; align-items:center; gap:10px; min-width:0;">
                <span id="matModalIcon" style="font-size:1.4rem;">📄</span>
                <div style="min-width:0;">
                    <h3 id="matModalTitle" style="margin:0; font-size:.96rem; font-weight:800; color:#0F172A; white-space:nowrap; overflow:hidden; text-overflow:ellipsis; max-width:560px;">Tiêu đề</h3>
                    <div id="matModalSub" style="font-size:.76rem; color:#64748B; margin-top:2px;"></div>
                </div>
            </div>
            <div style="display:flex; align-items:center; gap:8px;">
                <a id="matModalDownloadBtn" href="#" download target="_blank"
                   style="display:inline-flex; align-items:center; gap:6px; padding:7px 14px; font-size:.82rem; font-weight:700; color:#2563EB; background:#EFF6FF; border:1px solid #BFDBFE; border-radius:6px; text-decoration:none;">
                    ⬇️ Tải về máy
                </a>
                <button type="button" onclick="toggleMaterialFullscreen()"
                        style="padding:7px 11px; font-size:.85rem; font-weight:600; color:#475569; background:#fff; border:1px solid #CBD5E1; border-radius:6px; cursor:pointer;" title="Toàn màn hình">
                    ⛶
                </button>
                <button type="button" onclick="closeMaterialPreview()"
                        style="padding:7px 14px; font-size:.85rem; font-weight:800; color:#DC2626; background:#FEF2F2; border:1px solid #FECACA; border-radius:6px; cursor:pointer;">
                    ✕ Đóng
                </button>
            </div>
        </div>
        <div id="matModalContent" style="flex:1; background:#0F172A; position:relative; overflow:auto; display:flex; align-items:center; justify-content:center;"></div>
    </div>
</div>

<!-- ======================================================== -->
<!-- MODAL CHỈNH SỬA TÀI LIỆU AI CỦA GIẢNG VIÊN               -->
<!-- ======================================================== -->
<div class="ai-modal-backdrop" id="aiEditModal">
    <div class="ai-modal-box">
        <div class="ai-modal-head">
            <h3 style="margin:0; font-size:1.15rem; font-weight:800; color:#0F172A; display:flex; align-items:center; gap:8px;">
                <span>✏️</span> Chỉnh sửa tài liệu học tập AI
            </h3>
            <button type="button" style="background:none; border:none; font-size:1.4rem; cursor:pointer; color:#64748B;" onclick="closeAiEditModal()">&times;</button>
        </div>

        <div class="ai-modal-body">
            <div class="ai-form-group">
                <label class="ai-form-label">📝 1. Tóm tắt nội dung bài học (Summary):</label>
                <textarea class="ai-form-textarea" id="editAiSummary" rows="4"></textarea>
            </div>

            <div class="ai-form-group">
                <label class="ai-form-label">💡 2. Kiến thức trọng tâm (Key Points):</label>
                <textarea class="ai-form-textarea" id="editAiKeyPoints" rows="5"></textarea>
            </div>

            <div class="ai-form-group">
                <label class="ai-form-label">📖 3. Thuật ngữ chuyên ngành (Terms):</label>
                <textarea class="ai-form-textarea" id="editAiTerms" rows="4"></textarea>
            </div>

            <div class="ai-form-group">
                <label class="ai-form-label">🎯 4. Tổng kết bài học (Conclusion):</label>
                <textarea class="ai-form-textarea" id="editAiConclusion" rows="3"></textarea>
            </div>
        </div>

        <div class="ai-modal-foot">
            <button type="button" class="ai-btn ai-btn--secondary" onclick="closeAiEditModal()">Hủy bỏ</button>
            <button type="button" class="ai-btn ai-btn--primary" id="btnSaveAiEdit" onclick="saveAiEditChanges()">
                <span>💾</span> Lưu thay đổi
            </button>
        </div>
    </div>
</div>

<script>
// ══════════════════════════════════════════════════════════
// EDUSPHERE AI MATERIAL CLIENT LOGIC
// ══════════════════════════════════════════════════════════
var aiPollTimer = null;

function resetAiButton() {
    var actArea = document.getElementById('aiActionsArea');
    if (actArea) {
        actArea.innerHTML = '<button type="button" class="ai-btn ai-btn--primary" id="btnStartAi" onclick="triggerAiGeneration(false)">' +
            '<span>✨</span> Tạo tài liệu bằng AI</button>';
    }
}

function setAiButtonRunning() {
    var actArea = document.getElementById('aiActionsArea');
    if (actArea) {
        actArea.innerHTML = '<button type="button" class="ai-btn ai-btn--secondary" disabled style="opacity:0.8; cursor:wait;">' +
            '<span class="ai-spinner"></span> Đang phân tích video...</button>';
    }
}

function triggerAiGeneration(force) {
    var card = document.getElementById('aiMaterialCard');
    if (!card) return;
    var courseId = card.getAttribute('data-course-id');
    var lessonId = card.getAttribute('data-lesson-id');
    var ctx = card.getAttribute('data-context-path');
    var csrfToken = card.getAttribute('data-csrf-token');

    var btn = document.getElementById('btnStartAi');
    if (btn) {
        btn.disabled = true;
        btn.innerHTML = '<span class="ai-spinner"></span> Đang khởi chạy...';
    }

    var url = ctx + '/instructor/courses/' + courseId + '/lessons/' + lessonId + '/ai-materials/generate?force=' + (force ? 'true' : 'false');

    fetch(url, {
        method: 'POST',
        headers: {
            'X-Requested-With': 'XMLHttpRequest',
            'X-CSRF-TOKEN': csrfToken || ''
        }
    })
    .then(function(r) {
        return r.json().then(function(data) {
            return { ok: r.ok, status: r.status, data: data };
        });
    })
    .then(function(res) {
        var data = res.data || {};
        if (!res.ok || data.success === false || data.status === 'FAILED') {
            var errMsg = data.message || data.error || ('Lỗi máy chủ (HTTP ' + res.status + ')');
            showAiError(errMsg);
            resetAiButton();
            return;
        }
        setAiButtonRunning();
        var initPct = (typeof data.progress === 'number') ? data.progress : 15;
        showAiProgressUI(data.currentStep || 'PENDING', initPct, data.message || 'Đã tiếp nhận yêu cầu phân tích.');
        startAiPolling(courseId, lessonId, ctx);
    })
    .catch(function(err) {
        showAiError('Không thể kết nối đến máy chủ: ' + err.message);
        resetAiButton();
    });
}

function startAiPolling(courseId, lessonId, ctx) {
    if (aiPollTimer) clearInterval(aiPollTimer);

    aiPollTimer = setInterval(function() {
        var statusUrl = ctx + '/instructor/courses/' + courseId + '/lessons/' + lessonId + '/ai-materials/status';
        fetch(statusUrl, { headers: { 'X-Requested-With': 'XMLHttpRequest' } })
            .then(function(r) { return r.json(); })
            .then(function(d) {
                if (d.status === 'COMPLETED') {
                    clearInterval(aiPollTimer);
                    aiPollTimer = null;
                    showAiProgressUI('COMPLETED', 100, 'Hoàn thành!');
                    loadAndRenderAiMaterial(courseId, lessonId, ctx);
                } else if (d.status === 'FAILED') {
                    clearInterval(aiPollTimer);
                    aiPollTimer = null;
                    showAiError(d.error || d.message || 'Tác vụ AI thất bại.');
                    resetAiButton();
                } else if (d.status === 'NOT_FOUND') {
                    clearInterval(aiPollTimer);
                    aiPollTimer = null;
                    showAiError(d.message || 'Chưa tìm thấy tác vụ AI.');
                    resetAiButton();
                } else {
                    showAiProgressUI(d.currentStep, d.progress, d.message);
                }
            })
            .catch(function(e) {
                console.warn('AI polling error:', e);
            });
    }, 3500);
}

function showAiProgressUI(step, percent, msg) {
    var pBanner = document.getElementById('aiProgressBanner');
    var cArea = document.getElementById('aiContentArea');
    var eBanner = document.getElementById('aiErrorBanner');
    var emptyPh = document.getElementById('aiEmptyPlaceholder');

    if (pBanner) pBanner.style.display = 'block';
    if (cArea) cArea.style.display = 'none';
    if (eBanner) eBanner.style.display = 'none';
    if (emptyPh) emptyPh.style.display = 'none';

    var pFill = document.getElementById('aiProgressBarFill');
    var pText = document.getElementById('aiProgressPercent');
    var pMsg = document.getElementById('aiProgressMessage');
    var pTitle = document.getElementById('aiProgressStepTitle');

    var pctVal = (typeof percent === 'number') ? percent : 15;
    if (pFill) pFill.style.width = pctVal + '%';
    if (pText) pText.textContent = pctVal + '%';
    if (pMsg && msg) pMsg.textContent = msg;

    var s1 = document.getElementById('aiStep1');
    var s2 = document.getElementById('aiStep2');
    var s3 = document.getElementById('aiStep3');
    var s4 = document.getElementById('aiStep4');

    [s1, s2, s3, s4].forEach(function(el) { if (el) el.className = 'ai-step-item'; });

    if (step === 'EXTRACTING_AUDIO') {
        if (s1) s1.classList.add('active');
        if (pTitle) pTitle.textContent = '1/4: Đang trích xuất âm thanh...';
    } else if (step === 'TRANSCRIBING') {
        if (s1) s1.classList.add('done');
        if (s2) s2.classList.add('active');
        if (pTitle) pTitle.textContent = '2/4: Whisper đang nhận diện giọng nói tiếng Việt...';
    } else if (step === 'CORRECTING') {
        if (s1) s1.classList.add('done');
        if (s2) s2.classList.add('done');
        if (s3) s3.classList.add('active');
        if (pTitle) pTitle.textContent = '3/4: Qwen 2.5:3B đang hiệu đính ngữ cảnh lập trình...';
    } else if (step === 'GENERATING') {
        if (s1) s1.classList.add('done');
        if (s2) s2.classList.add('done');
        if (s3) s3.classList.add('done');
        if (s4) s4.classList.add('active');
        if (pTitle) pTitle.textContent = '4/4: Đang tổng hợp tài liệu học tập toàn diện...';
    } else if (step === 'COMPLETED') {
        [s1, s2, s3, s4].forEach(function(el) { if (el) el.classList.add('done'); });
        if (pTitle) pTitle.textContent = 'Đã hoàn thành phân tích!';
    }
}

function showAiError(msg) {
    var pBanner = document.getElementById('aiProgressBanner');
    var eBanner = document.getElementById('aiErrorBanner');
    var eMsg = document.getElementById('aiErrorMessage');

    if (pBanner) pBanner.style.display = 'none';
    if (eBanner) eBanner.style.display = 'block';
    if (eMsg) eMsg.textContent = msg;

    var actArea = document.getElementById('aiActionsArea');
    if (actArea) {
        actArea.innerHTML = '<button type="button" class="ai-btn ai-btn--primary" onclick="triggerAiGeneration(true)"><span>✨</span> Thử tạo lại bằng AI</button>';
    }
}

function loadAndRenderAiMaterial(courseId, lessonId, ctx) {
    fetch(ctx + '/instructor/courses/' + courseId + '/lessons/' + lessonId + '/ai-materials')
        .then(function(r) { return r.json(); })
        .then(function(data) {
            renderAiMaterialData(data);
        })
        .catch(function(e) {
            console.error('Error loading material:', e);
            location.reload();
        });
}

function renderAiMaterialData(data) {
    var pBanner = document.getElementById('aiProgressBanner');
    var cArea = document.getElementById('aiContentArea');
    var emptyPh = document.getElementById('aiEmptyPlaceholder');
    var eBanner = document.getElementById('aiErrorBanner');

    if (pBanner) pBanner.style.display = 'none';
    if (emptyPh) emptyPh.style.display = 'none';
    if (eBanner) eBanner.style.display = 'none';
    if (cArea) cArea.style.display = 'block';

    document.getElementById('aiDisplaySummary').textContent = data.summary || 'Chưa có tóm tắt.';
    document.getElementById('aiDisplayKeyPoints').textContent = data.keyPoints || 'Chưa có kiến thức trọng tâm.';
    document.getElementById('aiDisplayTerms').textContent = data.terms || 'Chưa có thuật ngữ.';
    document.getElementById('aiDisplayConclusion').textContent = data.conclusion || 'Chưa có kết luận.';

    var rawTr = document.getElementById('aiDisplayRawTranscript');
    if (rawTr) rawTr.textContent = data.originalTranscript || 'Chưa có bản ghi thô.';
    var corTr = document.getElementById('aiDisplayCorrectedTranscript');
    if (corTr) corTr.textContent = data.correctedTranscript || 'Chưa có bản ghi hiệu đính.';

    var mBadge = document.getElementById('aiModelBadge');
    if (mBadge) mBadge.textContent = data.aiModel || 'Qwen 2.5:3B + Whisper';

    var actArea = document.getElementById('aiActionsArea');
    if (actArea) {
        actArea.innerHTML =
            '<button type="button" class="ai-btn ai-btn--outline" onclick="openAiEditModal()"><span>✏️</span> Chỉnh sửa tài liệu</button>' +
            '<button type="button" class="ai-btn ai-btn--secondary" onclick="confirmRegenerateAi()"><span>🔄</span> Phân tích lại</button>';
    }
}

function confirmRegenerateAi() {
    if (confirm('Bạn có chắc muốn phân tích lại video bài giảng bằng AI? Quá trình này sẽ tạo mới bản ghi và tài liệu học tập.')) {
        triggerAiGeneration(true);
    }
}

// ── Modal Chỉnh sửa ──
function openAiEditModal() {
    var sum = document.getElementById('aiDisplaySummary');
    var kp = document.getElementById('aiDisplayKeyPoints');
    var tm = document.getElementById('aiDisplayTerms');
    var cc = document.getElementById('aiDisplayConclusion');

    document.getElementById('editAiSummary').value = sum ? sum.textContent : '';
    document.getElementById('editAiKeyPoints').value = kp ? kp.textContent : '';
    document.getElementById('editAiTerms').value = tm ? tm.textContent : '';
    document.getElementById('editAiConclusion').value = cc ? cc.textContent : '';

    var modal = document.getElementById('aiEditModal');
    if (modal) modal.classList.add('open');
    document.body.style.overflow = 'hidden';
}

function closeAiEditModal() {
    var modal = document.getElementById('aiEditModal');
    if (modal) modal.classList.remove('open');
    document.body.style.overflow = '';
}

function saveAiEditChanges() {
    var card = document.getElementById('aiMaterialCard');
    var courseId = card.getAttribute('data-course-id');
    var lessonId = card.getAttribute('data-lesson-id');
    var ctx = card.getAttribute('data-context-path');
    var csrfToken = card.getAttribute('data-csrf-token');

    var btn = document.getElementById('btnSaveAiEdit');
    if (btn) {
        btn.disabled = true;
        btn.innerHTML = '<span class="ai-spinner"></span> Đang lưu...';
    }

    var payload = {
        summary: document.getElementById('editAiSummary').value,
        keyPoints: document.getElementById('editAiKeyPoints').value,
        terms: document.getElementById('editAiTerms').value,
        conclusion: document.getElementById('editAiConclusion').value
    };

    fetch(ctx + '/instructor/courses/' + courseId + '/lessons/' + lessonId + '/ai-materials/edit', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'X-Requested-With': 'XMLHttpRequest',
            'X-CSRF-TOKEN': csrfToken || ''
        },
        body: JSON.stringify(payload)
    })
    .then(function(r) { return r.json(); })
    .then(function(updated) {
        if (btn) {
            btn.disabled = false;
            btn.innerHTML = '<span>💾</span> Lưu thay đổi';
        }
        closeAiEditModal();
        renderAiMaterialData(updated);
        alert('✅ Đã lưu thay đổi nội dung tài liệu AI thành công!');
    })
    .catch(function(err) {
        if (btn) {
            btn.disabled = false;
            btn.innerHTML = '<span>💾</span> Lưu thay đổi';
        }
        alert('Lỗi khi lưu tài liệu: ' + err.message);
    });
}

// Tự động kích hoạt polling nếu trang được load khi đang xử lý
document.addEventListener('DOMContentLoaded', function() {
    var card = document.getElementById('aiMaterialCard');
    if (!card) return;
    var courseId = card.getAttribute('data-course-id');
    var lessonId = card.getAttribute('data-lesson-id');
    var ctx = card.getAttribute('data-context-path');

    var pBanner = document.getElementById('aiProgressBanner');
    if (pBanner && pBanner.style.display !== 'none') {
        startAiPolling(courseId, lessonId, ctx);
    }
});
</script>
</body></html>
