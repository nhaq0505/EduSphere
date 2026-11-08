<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Bước 3 & 4: Thiết lập Bài học & Cấu hình nâng cao — EduSphere</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/instructor.css">
    <style>
        .type-selector {
            display: grid; grid-template-columns: repeat(auto-fit, minmax(160px, 1fr));
            gap: 12px; margin-bottom: 20px;
        }
        .type-card {
            border: 2px solid #E2E8F0; border-radius: var(--r8); padding: 14px 16px;
            cursor: pointer; transition: all .2s; background: #fff; text-align: center;
        }
        .type-card:hover { border-color: #93C5FD; }
        .type-card.active { border-color: #2563EB; background: #EFF6FF; }
        .type-card input { display: none; }
        .type-card__icon { font-size: 1.5rem; margin-bottom: 6px; }
        .type-card__title { font-weight: 700; font-size: .88rem; color: #1E293B; }
        .type-card__desc { font-size: .75rem; color: #64748B; margin-top: 2px; }

        .editor-toolbar {
            display: flex; gap: 6px; background: #F1F5F9; border: 1px solid #CBD5E1;
            border-bottom: none; border-radius: var(--r8) var(--r8) 0 0; padding: 6px 10px;
        }
        .editor-btn {
            background: #fff; border: 1px solid #CBD5E1; border-radius: 4px;
            padding: 4px 10px; font-size: .8rem; font-weight: 600; cursor: pointer; color: #334155;
        }
        .editor-btn:hover { background: #E2E8F0; }

        .advanced-box {
            background: #F8FAFC; border: 1.5px solid #E2E8F0; border-radius: var(--r12);
            padding: 20px 22px; margin-top: 28px;
        }
        .advanced-box__title {
            font-size: 1rem; font-weight: 800; color: #0F172A; display: flex; align-items: center; gap: 8px;
            margin-bottom: 16px;
        }
        .switch-label {
            display: flex; align-items: center; gap: 10px; cursor: pointer; font-weight: 600; font-size: .88rem;
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

        <div class="ins-form-card">
            <div class="ins-form-card__header">
                <div class="ins-form-card__eyebrow">📚 Khóa học: <c:out value="${course.title}"/></div>
                <h1>
                    <c:choose>
                        <c:when test="${empty lessonId}">Thêm bài học mới (Bước 3 & 4)</c:when>
                        <c:otherwise>Chỉnh sửa bài học</c:otherwise>
                    </c:choose>
                </h1>
                <p>Chọn loại nội dung (Video, Văn bản, Bài tập), nhập tài nguyên học tập và cấu hình điều kiện truy cập.</p>
            </div>
            <div class="ins-form-card__body">
                <c:if test="${course.status eq 'PUBLISHED' or course.status eq 'APPROVED'}">
                    <div class="ins-alert ins-alert--warning" style="margin-bottom:20px">
                        ⚠️ <strong>Lưu ý:</strong> Khóa học hiện đang ở trạng thái
                        <strong>${course.status eq 'PUBLISHED' ? 'Đã công bố' : 'Tạm ẩn'}</strong>.
                        Khi bạn lưu bài học này, khóa học sẽ được chuyển về <strong>Bản nháp (phiên bản v${course.versionNo + 1})</strong>
                        và cần được gửi Admin phê duyệt lại trước khi công bố.
                    </div>
                </c:if>

                <form:form method="post" modelAttribute="lessonForm"
                           action="${pageContext.request.contextPath}${formAction}" htmlEscape="true" id="lessonForm">
                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">

                    <!-- Bước 2: Chọn chương mục -->
                    <div class="ins-field">
                        <label for="sectionId">Chương mục (Section / Module)</label>
                        <form:select path="sectionId" id="sectionId">
                            <form:option value="" label="-- Chọn chương mục hoặc để mục chung --"/>
                            <c:forEach var="sec" items="${sections}">
                                <c:if test="${not empty sec.sectionId}">
                                    <form:option value="${sec.sectionId}" label="Chương ${sec.orderIndex}: ${sec.title}"/>
                                </c:if>
                            </c:forEach>
                        </form:select>
                        <span class="ins-field__hint">Xếp bài học vào đúng chương mục giúp học viên học có hệ thống.</span>
                    </div>

                    <div class="ins-field">
                        <label for="title">Tên bài học <span style="color:#EF4444">*</span></label>
                        <form:input path="title" id="title" maxlength="255"
                                    placeholder="VD: Bài 1: Cài đặt môi trường & Cấu trúc dự án"/>
                        <form:errors path="title" cssClass="ins-field__error"/>
                    </div>

                    <!-- Bước 3: Content Type Selector -->
                    <label style="display:block; font-weight:700; font-size:.88rem; margin-bottom:8px; color:var(--ink);">
                        Loại nội dung bài học (Content Type) <span style="color:#EF4444">*</span>
                    </label>
                    <div class="type-selector">
                        <div class="type-card <c:if test='${lessonForm.lessonType eq "VIDEO"}'>active</c:if>' id="cardVideo" onclick="setType('VIDEO')">
                            <input type="radio" name="lessonType" value="VIDEO" <c:if test='${lessonForm.lessonType eq "VIDEO"}'>checked</c:if> id="typeVideo"/>
                            <div class="type-card__icon">🎥</div>
                            <div class="type-card__title">Bài giảng Video</div>
                            <div class="type-card__desc">Tải video từ máy, link YouTube, Vimeo</div>
                        </div>

                        <div class="type-card <c:if test='${empty lessonForm.lessonType or lessonForm.lessonType eq "ARTICLE"}'>active</c:if>' id="cardArticle" onclick="setType('ARTICLE')">
                            <input type="radio" name="lessonType" value="ARTICLE" <c:if test='${empty lessonForm.lessonType or lessonForm.lessonType eq "ARTICLE"}'>checked</c:if> id="typeArticle"/>
                            <div class="type-card__icon">📄</div>
                            <div class="type-card__title">Bài viết / Văn bản</div>
                            <div class="type-card__desc">Tài liệu, Code snippet & Markdown</div>
                        </div>

                        <div class="type-card <c:if test='${lessonForm.lessonType eq "QUIZ"}'>active</c:if>' id="cardQuiz" onclick="setType('QUIZ')">
                            <input type="radio" name="lessonType" value="QUIZ" <c:if test='${lessonForm.lessonType eq "QUIZ"}'>checked</c:if> id="typeQuiz"/>
                            <div class="type-card__icon">📝</div>
                            <div class="type-card__title">Bài tập / Quiz</div>
                            <div class="type-card__desc">Trắc nghiệm, tự luận & đánh giá</div>
                        </div>
                    </div>

                    <!-- 3.1: Video Fields (Hỗ trợ cả tải file từ máy tính lẫn dán URL) -->
                    <div id="videoFields" style="<c:if test='${lessonForm.lessonType ne "VIDEO"}'>display:none;</c:if>">
                        <div class="ins-form-grid">
                            <div class="ins-field">
                                <label for="videoUrl">Đường dẫn Video (Video URL)</label>
                                <div class="upload-row">
                                    <form:input path="videoUrl" id="videoUrl"
                                                placeholder="Hoặc tải video từ máy lên Bunny Stream →"/>
                                    <button type="button" class="upload-btn" onclick="document.getElementById('lessonVideoFileInput').click()">
                                        ☁️ Upload lên Bunny
                                    </button>
                                    <input type="file" id="lessonVideoFileInput" accept="video/mp4,video/webm,video/quicktime,video/*" style="display:none;" onchange="uploadLessonVideo(this)"/>
                                </div>
                                <div id="lessonVideoStatus" class="upload-status"></div>
                                <div id="lessonVideoProgress" style="display:none; margin-top:8px;">
                                    <div style="background:#E2E8F0; border-radius:99px; height:8px; overflow:hidden;">
                                        <div id="lessonVideoProgressBar" style="height:100%; background:#2563EB; width:0%; transition:width .3s; border-radius:99px;"></div>
                                    </div>
                                    <div id="lessonVideoProgressText" style="font-size:.75rem; color:#64748B; margin-top:4px;"></div>
                                </div>
                                <%-- Hiển thị player preview nếu đã có bunnyVideoId --%>
                                <c:if test="${not empty lessonForm.videoUrl and fn:startsWith(lessonForm.videoUrl, 'https://player.mediadelivery.net')}">
                                    <div id="currentVideoPreview" style="margin-top:12px;">
                                        <div style="font-size:.8rem; font-weight:700; color:#64748B; margin-bottom:6px;">Video hiện tại:</div>
                                        <div style="position:relative; padding-bottom:56.25%; height:0; border-radius:8px; overflow:hidden; background:#000; max-width:480px;">
                                            <iframe src="<c:out value='${lessonForm.videoUrl}'/>"
                                                    style="position:absolute;top:0;left:0;width:100%;height:100%;border:0;"
                                                    allowfullscreen></iframe>
                                        </div>
                                    </div>
                                </c:if>
                                <span class="ins-field__hint">
                                    Tải video từ máy → tự động upload lên <strong>Bunny Stream CDN</strong>. 
                                    Hoặc dán link YouTube/Vimeo vào ô trên. Định dạng: MP4, WebM, MOV (tối đa 2GB).
                                </span>
                                <form:errors path="videoUrl" cssClass="ins-field__error"/>
                            </div>
                            <div class="ins-field">
                                <label for="videoDuration">Thời lượng video (Số phút)</label>
                                <form:input path="videoDuration" id="videoDuration" type="number" min="1" placeholder="VD: 15"/>
                                <span class="ins-field__hint">Thời lượng ước tính để học viên phân bổ thời gian.</span>
                            </div>
                        </div>
                        <div class="ins-field" style="margin-top:8px;">
                            <label class="switch-label">
                                <form:checkbox path="allowSeek" id="allowSeek"/>
                                <span>Cho phép học viên tua video tới đoạn chưa xem (Tắt để bắt buộc xem tuần tự)</span>
                            </label>
                            <span class="ins-field__hint" style="margin-left:26px;">Học viên vẫn có thể tua lui xem lại dù tắt tùy chọn này.</span>
                        </div>

                        <div class="ins-field" style="margin-top:12px;">
                            <label class="switch-label">
                                <form:checkbox path="quizRequiresVideo" id="quizRequiresVideo"
                                               onchange="toggleMinWatch(this.checked)"/>
                                <span>🔒 Bắt buộc xem video đủ % mới được làm Quiz</span>
                            </label>
                            <span class="ins-field__hint" style="margin-left:26px;">Nếu bật, học viên phải xem đủ số % video bên dưới thì nút làm Quiz mới mở khóa.</span>
                        </div>

                        <div class="ins-field" id="minWatchField"
                             style="margin-top:8px; max-width:260px; <c:if test='${not lessonForm.quizRequiresVideo}'>display:none;</c:if>">
                            <label for="minWatchPercent">🎯 Ngưỡng % video tối thiểu phải xem (0–100)</label>
                            <form:input path="minWatchPercent" id="minWatchPercent"
                                        type="number" min="0" max="100" placeholder="VD: 80"/>
                            <span class="ins-field__hint">100 = phải xem hết video. 80 = xem 80% trở lên.</span>
                        </div>
                    </div>

                    <!-- 3.2: Text / Article / Notes Content -->
                    <div class="ins-field" style="margin-top:16px;">
                        <label for="content">
                            <span id="contentLabel">Nội dung chi tiết bài học</span>
                        </label>
                        <div class="editor-toolbar">
                            <button type="button" class="editor-btn" onclick="insertTag('**', '**')"><b>B</b></button>
                            <button type="button" class="editor-btn" onclick="insertTag('*', '*')"><i>I</i></button>
                            <button type="button" class="editor-btn" onclick="insertTag('### ', '')">H3</button>
                            <button type="button" class="editor-btn" onclick="insertTag('```java\n', '\n```')">Mã code</button>
                            <button type="button" class="editor-btn" onclick="insertTag('> ', '')">Trích dẫn</button>
                            <button type="button" class="editor-btn" onclick="insertTag('- ', '')">Gạch đầu dòng</button>
                        </div>
                        <form:textarea path="content" id="content" rows="12" style="border-radius:0 0 var(--r8) var(--r8);"
                                       placeholder="Viết nội dung bài giảng, tài liệu hướng dẫn hoặc giải thích chi tiết ở đây..."/>
                        <form:errors path="content" cssClass="ins-field__error"/>
                    </div>

                    <!-- 3.3: Đính kèm tài liệu học tập (Hỗ trợ tải tệp máy tính hoặc dán URL) -->
                    <div style="margin-top:24px; padding:22px; background:#F8FAFC; border:1.5px dashed #CBD5E1; border-radius:var(--r12);">
                        <h2 style="margin-top:0; margin-bottom:14px; font-size:1.05rem; font-weight:800; color:#1E293B; display:flex; align-items:center; gap:8px;">
                            ➕ Đính kèm tài liệu mới (Hỗ trợ tải tệp máy tính hoặc dán URL)
                        </h2>

                        <c:if test="${course.status eq 'PUBLISHED' or course.status eq 'APPROVED'}">
                            <div class="ins-alert" style="background:#ECFDF5; border:1px solid #86EFAC; color:#166534; margin-bottom:16px; font-size:.86rem; padding:10px 14px; border-radius:8px;">
                                ✅ <strong>Khóa học đang công bố.</strong> Tài liệu đính kèm sẽ được học viên thấy ngay mà không cần gửi duyệt lại.
                            </div>
                        </c:if>

                        <c:if test="${not empty materials}">
                            <div style="margin-bottom:16px;">
                                <div style="font-size:.85rem; font-weight:700; color:#475569; margin-bottom:8px;">📁 Tài liệu hiện có của bài học:</div>
                                <div style="display:flex; flex-direction:column; gap:6px;">
                                    <c:forEach var="mat" items="${materials}">
                                        <div style="display:flex; justify-content:space-between; align-items:center; background:#fff; border:1px solid #E2E8F0; border-radius:6px; padding:8px 12px; font-size:.85rem;">
                                            <div>
                                                <span style="display:inline-block; padding:2px 8px; border-radius:4px; font-size:.72rem; font-weight:700; background:#E2E8F0; color:#334155; margin-right:6px;">${mat.type}</span>
                                                <strong><c:out value="${mat.title}"/></strong>
                                                <c:if test="${not empty mat.originalFileName}">
                                                    <span style="color:#64748B; font-size:.8rem; margin-left:6px;">(<c:out value="${mat.originalFileName}"/>)</span>
                                                </c:if>
                                            </div>
                                            <a href="<c:out value='${mat.fileUrl}'/>" target="_blank" style="color:#2563EB; font-size:.82rem; font-weight:600; text-decoration:none;">Mở file ↗</a>
                                        </div>
                                    </c:forEach>
                                </div>
                            </div>
                        </c:if>

                        <div class="ins-form-grid" style="margin-bottom:16px;">
                            <div class="ins-field">
                                <label for="mat-title">Tên tài liệu / Tiêu đề file</label>
                                <form:input path="materialTitle" id="mat-title" maxlength="255"
                                            placeholder="VD: Slide bài giảng (PDF), Source code mẫu (.zip)..."/>
                                <span class="ins-field__hint">Để trống sẽ tự động lấy theo tên file bạn tải lên.</span>
                            </div>
                            <div class="ins-field">
                                <label for="mat-type">Loại tài liệu</label>
                                <form:select path="materialType" id="mat-type">
                                    <form:option value="" label="Chọn loại"/>
                                    <form:option value="DOCUMENT" label="📄 Tài liệu (PDF, Word, Slides, ZIP)"/>
                                    <form:option value="LINK"     label="🔗 Liên kết ngoài / GitHub"/>
                                    <form:option value="VIDEO"    label="🎬 Video bổ trợ"/>
                                </form:select>
                            </div>
                        </div>

                        <div class="ins-field">
                            <label for="mat-url">Đường dẫn URL hoặc Tải từ máy tính</label>
                            <div class="upload-row">
                                <form:input path="materialUrl" id="mat-url" maxlength="2048"
                                            placeholder="Dán link hoặc bấm nút tải tệp từ máy tính..."/>
                                <button type="button" class="upload-btn" onclick="document.getElementById('matFileInput').click()">
                                    📤 Tải file từ máy
                                </button>
                                <input type="file" id="matFileInput" style="display:none;" onchange="uploadMaterialFile(this)"/>
                            </div>
                            <form:hidden path="materialOriginalName" id="mat-original-name"/>
                            <form:hidden path="materialSizeBytes" id="mat-size-bytes"/>

                            <div id="matStatus" class="upload-status" style="margin-top:6px;"></div>
                            <span class="ins-field__hint">Hỗ trợ tải trực tiếp tệp từ máy tính hoặc dán link Google Drive, Dropbox, GitHub... Tài liệu sẽ được lưu cùng bài học.</span>
                        </div>
                    </div>

                    <c:if test="${not empty lessonId}">
                        <div class="ins-field" style="max-width:220px; margin-top:16px;">
                            <label for="orderIndex">Vị trí bài học trong khóa</label>
                            <form:input path="orderIndex" id="orderIndex" type="number"
                                        min="1" max="${maxOrder}"/>
                            <span class="ins-field__hint">Từ 1 đến ${maxOrder}</span>
                            <form:errors path="orderIndex" cssClass="ins-field__error"/>
                        </div>
                    </c:if>

                    <!-- Bước 4: Cấu hình Nâng cao (Lesson Settings) -->
                    <div class="advanced-box">
                        <div class="advanced-box__title">⚙️ Bước 4: Cấu hình Nâng cao cho Bài học</div>

                        <div class="ins-field" style="margin-bottom:14px;">
                            <label class="switch-label">
                                <form:checkbox path="isPreview" id="isPreview"/>
                                <span>👁️ Cho phép xem trước miễn phí (Free Preview) trước khi mua khóa học</span>
                            </label>
                            <span class="ins-field__hint" style="margin-left:26px;">Học viên chưa đăng ký/mua khóa học vẫn có thể xem bài này để trải nghiệm chất lượng giảng dạy.</span>
                        </div>

                        <div class="ins-form-grid" style="margin-top:14px;">
                            <div class="ins-field">
                                <label for="unlockDaysAfterEnroll">⏳ Mở khóa tuần tự (Drip Content - Số ngày sau ghi danh)</label>
                                <form:input path="unlockDaysAfterEnroll" id="unlockDaysAfterEnroll" type="number" min="0" placeholder="VD: 3"/>
                                <span class="ins-field__hint">Bỏ trống hoặc nhập 0 nếu mở ngay lập tức khi đăng ký.</span>
                            </div>

                            <div class="ins-field">
                                <label for="prerequisiteLessonId">🔗 Điều kiện tiên quyết (Prerequisite Lesson)</label>
                                <form:select path="prerequisiteLessonId" id="prerequisiteLessonId">
                                    <form:option value="" label="-- Không yêu cầu bài trước --"/>
                                    <c:forEach var="exist" items="${existingLessons}">
                                        <form:option value="${exist.lessonId}" label="Bài ${exist.orderIndex}: ${exist.title}"/>
                                    </c:forEach>
                                </form:select>
                                <span class="ins-field__hint">Học viên phải hoàn thành bài này trước khi mở bài học hiện tại.</span>
                            </div>
                        </div>

                        <div class="ins-field" style="margin-top:14px;">
                            <label for="instructorNotes">🗒️ Ghi chú riêng cho Giảng viên (Instructor Notes)</label>
                            <form:textarea path="instructorNotes" id="instructorNotes" rows="2"
                                           placeholder="Ghi chú kế hoạch giảng dạy, câu hỏi thảo luận, tài liệu tham khảo nội bộ (học viên không thấy)..."/>
                        </div>
                    </div>

                    <div class="ins-form-actions" style="margin-top:24px;">
                        <button class="ins-form-btn-primary" type="submit">💾 Lưu bài học</button>
                        <a class="ins-form-btn-cancel"
                           href="${pageContext.request.contextPath}/instructor/courses/${courseId}">
                            Quay lại
                        </a>
                    </div>
                </form:form>
            </div>
        </div>

        </main>
    </div>
</div>

<script>
function insToggleMenu(e){e.stopPropagation();document.getElementById('insUserMenu').classList.toggle('open');}
document.addEventListener('click',function(){var m=document.getElementById('insUserMenu');if(m)m.classList.remove('open');});

function setType(type) {
    document.querySelectorAll('.type-card').forEach(function(c){ c.classList.remove('active'); });
    var r = document.getElementById('type' + type.charAt(0) + type.slice(1).toLowerCase());
    if (r) r.checked = true;
    var card = document.getElementById('card' + type.charAt(0) + type.slice(1).toLowerCase());
    if (card) card.classList.add('active');

    var videoFields = document.getElementById('videoFields');
    var contentLabel = document.getElementById('contentLabel');
    if (type === 'VIDEO') {
        videoFields.style.display = 'block';
        contentLabel.textContent = 'Ghi chú & Tóm tắt bài giảng Video';
    } else if (type === 'QUIZ') {
        videoFields.style.display = 'none';
        contentLabel.textContent = 'Mô tả bài tập / Hướng dẫn làm Quiz & Điểm đạt';
    } else {
        videoFields.style.display = 'none';
        contentLabel.textContent = 'Nội dung chi tiết bài học (Văn bản / Markdown)';
    }
}

function toggleMinWatch(checked) {
    var field = document.getElementById('minWatchField');
    if (field) field.style.display = checked ? 'block' : 'none';
}

function insertTag(open, close) {
    var ta = document.getElementById('content');
    var start = ta.selectionStart;
    var end = ta.selectionEnd;
    var text = ta.value;
    var sel = text.substring(start, end);
    ta.value = text.substring(0, start) + open + sel + close + text.substring(end);
    ta.focus();
    ta.selectionStart = start + open.length;
    ta.selectionEnd = end + open.length;
}

// Upload video lên Bunny Stream qua /instructor/videos/upload
function uploadLessonVideo(inputElem) {
    if (!inputElem.files || inputElem.files.length === 0) return;
    var file = inputElem.files[0];
    var statusElem   = document.getElementById('lessonVideoStatus');
    var progressWrap = document.getElementById('lessonVideoProgress');
    var progressBar  = document.getElementById('lessonVideoProgressBar');
    var progressText = document.getElementById('lessonVideoProgressText');

    // Kiểm tra định dạng phía client
    var allowed = ['mp4','webm','mov','avi','mkv','mpeg','mpg'];
    var ext = file.name.split('.').pop().toLowerCase();
    if (!allowed.includes(ext)) {
        statusElem.className = 'upload-status upload-status--error';
        statusElem.textContent = '❌ Định dạng không hỗ trợ. Cho phép: MP4, WebM, MOV, AVI, MKV.';
        return;
    }
    // Kiểm tra dung lượng (2GB)
    if (file.size > 2 * 1024 * 1024 * 1024) {
        statusElem.className = 'upload-status upload-status--error';
        statusElem.textContent = '❌ File quá lớn. Giới hạn tối đa 2GB.';
        return;
    }

    var lessonId = '${lessonId}'; // có thể rỗng khi tạo mới
    if (!lessonId || lessonId === '') {
        statusElem.className = 'upload-status upload-status--error';
        statusElem.textContent = '⚠️ Vui lòng lưu bài học trước, sau đó tải video từ trang chi tiết bài học.';
        return;
    }

    statusElem.className = 'upload-status upload-status--loading';
    statusElem.textContent = '⏳ Đang upload lên Bunny Stream (' + (file.size / 1024 / 1024).toFixed(1) + ' MB)...';
    progressWrap.style.display = 'block';
    progressBar.style.width = '0%';
    progressText.textContent = '0%';

    var csrfToken = document.querySelector('input[name="${_csrf.parameterName}"]').value;
    var formData = new FormData();
    formData.append('file', file);
    formData.append('lessonId', lessonId);
    formData.append('title', document.getElementById('title').value || file.name);

    // Dùng XMLHttpRequest để hiển thị progress
    var xhr = new XMLHttpRequest();
    xhr.open('POST', '${pageContext.request.contextPath}/instructor/videos/upload', true);
    xhr.setRequestHeader('X-CSRF-TOKEN', csrfToken);

    xhr.upload.onprogress = function(e) {
        if (e.lengthComputable) {
            var pct = Math.round(e.loaded * 100 / e.total);
            progressBar.style.width = pct + '%';
            progressText.textContent = pct + '% — ' + (e.loaded / 1024 / 1024).toFixed(1) + ' / ' + (e.total / 1024 / 1024).toFixed(1) + ' MB';
        }
    };

    xhr.onload = function() {
        var data;
        try { data = JSON.parse(xhr.responseText); } catch(e) { data = {}; }
        if (data.success) {
            document.getElementById('videoUrl').value = data.playerUrl || '';
            statusElem.className = 'upload-status upload-status--success';
            statusElem.textContent = '✅ Upload xong! Bunny đang xử lý video, vui lòng chờ vài phút trước khi xuất bản.';
            progressBar.style.width = '100%';
            progressText.textContent = 'Hoàn tất — đang xử lý trên Bunny CDN';
            // Tự động poll trạng thái sau 10s
            setTimeout(function() { pollVideoStatus(lessonId, statusElem); }, 10000);
        } else {
            statusElem.className = 'upload-status upload-status--error';
            statusElem.textContent = '❌ ' + (data.message || 'Upload thất bại');
            progressWrap.style.display = 'none';
        }
    };

    xhr.onerror = function() {
        statusElem.className = 'upload-status upload-status--error';
        statusElem.textContent = '❌ Lỗi kết nối khi upload video.';
        progressWrap.style.display = 'none';
    };

    xhr.send(formData);
}

// Poll trạng thái video từ Bunny sau khi upload
function pollVideoStatus(lessonId, statusElem) {
    if (!lessonId) return;
    fetch('${pageContext.request.contextPath}/instructor/videos/' + lessonId + '/status', {
        headers: { 'Accept': 'application/json' }
    })
    .then(function(r) { return r.json(); })
    .then(function(data) {
        if (data.videoStatus === 'READY') {
            statusElem.className = 'upload-status upload-status--success';
            statusElem.textContent = '✅ Video đã sẵn sàng phát! Bạn có thể lưu bài học.';
        } else if (data.videoStatus === 'FAILED') {
            statusElem.className = 'upload-status upload-status--error';
            statusElem.textContent = '❌ Bunny xử lý video thất bại. Hãy thử upload lại.';
        } else {
            statusElem.textContent = '⏳ Video đang xử lý trên Bunny CDN... Kiểm tra lại sau vài phút.';
            // Poll lại sau 15s
            setTimeout(function() { pollVideoStatus(lessonId, statusElem); }, 15000);
        }
    })
    .catch(function() {
        // Im lặng nếu poll thất bại
    });
}

// Upload lesson material asynchronously
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
            var origInput = document.getElementById('mat-original-name');
            if (origInput) origInput.value = data.originalName;
            var sizeInput = document.getElementById('mat-size-bytes');
            if (sizeInput) sizeInput.value = data.size;

            statusElem.className = 'upload-status upload-status--success';
            statusElem.textContent = '✅ Đã tải lên thành công: ' + data.originalName + ' (' + (data.size / 1024 / 1024).toFixed(2) + ' MB). Tệp sẽ được đính kèm khi bạn lưu bài học.';
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
</body>
</html>
