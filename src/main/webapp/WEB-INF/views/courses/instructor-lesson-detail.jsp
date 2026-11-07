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
    <style>
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
                                                    <a class="ins-link-btn" href="${mat.fileUrl}" target="_blank" rel="noopener noreferrer">
                                                        Mở / Tải ↗
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
                                    <div class="ins-form-grid" style="margin-bottom:16px">
                                        <div class="ins-field">
                                            <label for="mat-title">Tên tài liệu / Tiêu đề file <span style="color:#EF4444">*</span></label>
                                            <form:input path="title" id="mat-title" maxlength="255"
                                                        placeholder="VD: Slide bài giảng (PDF), Source code mẫu (.zip)..."/>
                                            <form:errors path="title" cssClass="ins-field__error"/>
                                        </div>
                                        <div class="ins-field">
                                            <label for="mat-type">Loại tài liệu <span style="color:#EF4444">*</span></label>
                                            <form:select path="type" id="mat-type">
                                                <form:option value="" label="Chọn loại"/>
                                                <form:option value="DOCUMENT" label="📄 Tài liệu (PDF, Word, Slides, ZIP)"/>
                                                <form:option value="LINK"     label="🔗 Liên kết ngoài / GitHub"/>
                                                <form:option value="VIDEO"    label="🎬 Video bổ trợ"/>
                                            </form:select>
                                            <form:errors path="type" cssClass="ins-field__error"/>
                                        </div>
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
</script>
</body></html>
