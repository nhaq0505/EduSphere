<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Bước 1: Khởi tạo thông tin khóa học — EduSphere</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/instructor.css">
    <style>
        .ins-step-tracker {
            display: flex; gap: 8px; margin-bottom: 24px; overflow-x: auto; padding-bottom: 4px;
        }
        .ins-step-item {
            flex: 1; min-width: 130px; background: #fff; border: 1.5px solid #E2E8F0;
            border-radius: var(--r8); padding: 10px 14px; display: flex; align-items: center; gap: 10px;
            font-size: .82rem; font-weight: 600; color: #64748B;
        }
        .ins-step-item--active {
            border-color: #2563EB; background: #EFF6FF; color: #1E40AF;
        }
        .ins-step-item__num {
            width: 24px; height: 24px; border-radius: 50%; background: #E2E8F0;
            display: flex; align-items: center; justify-content: center; font-size: .78rem; font-weight: 700;
        }
        .ins-step-item--active .ins-step-item__num {
            background: #2563EB; color: #fff;
        }
        .ins-preview-box {
            margin-top: 10px; border-radius: var(--r8); overflow: hidden; background: #F8FAFC;
            border: 1px dashed #CBD5E1; padding: 12px; text-align: center;
        }
        .ins-preview-box img {
            max-width: 100%; max-height: 200px; border-radius: 6px; object-fit: cover; display: none; margin: 0 auto;
        }
        .upload-row {
            display: flex; gap: 8px; align-items: center; margin-top: 6px;
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

        <!-- 5-Step Progress Tracker -->
        <div class="ins-step-tracker">
            <div class="ins-step-item ins-step-item--active">
                <span class="ins-step-item__num">1</span>
                <span>Thông tin cơ bản</span>
            </div>
            <div class="ins-step-item">
                <span class="ins-step-item__num">2</span>
                <span>Cấu trúc chương</span>
            </div>
            <div class="ins-step-item">
                <span class="ins-step-item__num">3</span>
                <span>Bài học & Nội dung</span>
            </div>
            <div class="ins-step-item">
                <span class="ins-step-item__num">4</span>
                <span>Cài đặt bài học</span>
            </div>
            <div class="ins-step-item">
                <span class="ins-step-item__num">5</span>
                <span>Xem trước & Duyệt</span>
            </div>
        </div>

        <div class="ins-form-card">
            <div class="ins-form-card__header">
                <div class="ins-form-card__eyebrow">🧑‍🏫 Bước 1: Khởi tạo thông tin khóa học</div>
                <h1><c:choose><c:when test="${not empty course}">Chỉnh sửa khóa học (v${course.versionNo})</c:when><c:otherwise>Tạo khóa học mới</c:otherwise></c:choose></h1>
                <p>Điền tiêu đề, mô tả, ảnh bìa, video giới thiệu và các yêu cầu để khởi tạo khóa học chất lượng cao.</p>
            </div>
            <div class="ins-form-card__body">
                <c:if test="${not empty course && (course.status == 'APPROVED' || course.status == 'PUBLISHED')}">
                    <div style="background:#EFF6FF; border:1.5px solid #BFDBFE; border-radius:var(--r8); padding:12px 16px; margin-bottom:20px; font-size:.85rem; color:#1E40AF;">
                        💡 <strong>Lưu ý:</strong> Khóa học này hiện đang ở trạng thái <strong>${course.status == 'PUBLISHED' ? 'Đã công bố' : 'Đã duyệt / Tạm ẩn'}</strong>.
                        Khi bạn lưu thay đổi, hệ thống sẽ nâng lên phiên bản <strong>v${course.versionNo + 1}</strong> và đưa về <strong>Bản nháp</strong> để bạn hoàn thiện trước khi gửi Admin duyệt lại.
                    </div>
                </c:if>

                <form:form method="post" modelAttribute="courseForm"
                           action="${pageContext.request.contextPath}${formAction}" htmlEscape="true">
                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">

                    <div class="ins-field">
                        <label for="title">Tên khóa học <span style="color:#EF4444">*</span></label>
                        <form:input path="title" id="title" maxlength="255" placeholder="VD: Lập trình Java từ Zero đến Hero — Spring Boot & Microservices"/>
                        <form:errors path="title" cssClass="ins-field__error"/>
                    </div>

                    <div class="ins-field">
                        <label for="description">Mô tả khóa học <span style="color:#EF4444">*</span></label>
                        <form:textarea path="description" id="description" rows="5"
                                       placeholder="Mô tả chi tiết và hấp dẫn về nội dung, đối tượng người học và giá trị cốt lõi của khóa học..."/>
                        <form:errors path="description" cssClass="ins-field__error"/>
                    </div>

                    <div class="ins-form-grid">
                        <div class="ins-field">
                            <label for="categoryId">Danh mục</label>
                            <form:select path="categoryId" id="categoryId">
                                <form:option value="" label="Chưa phân loại"/>
                                <form:options items="${categories}" itemValue="categoryId" itemLabel="name"/>
                            </form:select>
                            <form:errors path="categoryId" cssClass="ins-field__error"/>
                        </div>
                        <div class="ins-field">
                            <label for="level">Trình độ <span style="color:#EF4444">*</span></label>
                            <form:select path="level" id="level">
                                <form:option value="ALL_LEVELS" label="Mọi trình độ"/>
                                <form:option value="BEGINNER"   label="Cơ bản"/>
                                <form:option value="INTERMEDIATE" label="Trung cấp"/>
                                <form:option value="ADVANCED"   label="Nâng cao"/>
                            </form:select>
                            <form:errors path="level" cssClass="ins-field__error"/>
                        </div>
                    </div>

                    <div class="ins-field">
                        <label for="price">Học phí (VND) <span style="color:#EF4444">*</span></label>
                        <form:input path="price" id="price" type="number" min="0" step="1000"/>
                        <span class="ins-field__hint">Nhập 0 nếu khóa học hoàn toàn miễn phí.</span>
                        <form:errors path="price" cssClass="ins-field__error"/>
                    </div>

                    <!-- Bước 1 Media: Thumbnail & Promo Video (Hỗ trợ cả tải file từ máy tính lẫn dán link URL) -->
                    <div class="ins-form-grid" style="margin-top:16px;">

                        <!-- Thumbnail -->
                        <div class="ins-field">
                            <label for="thumbnailUrl">Ảnh bìa khóa học (Thumbnail)</label>
                            <div class="upload-row">
                                <form:input path="thumbnailUrl" id="thumbnailUrl" placeholder="Dán link ảnh hoặc bấm nút tải file..." oninput="updateThumbPreview()"/>
                                <button type="button" class="upload-btn" onclick="document.getElementById('thumbFileInput').click()">
                                    📤 Tải ảnh từ máy
                                </button>
                                <input type="file" id="thumbFileInput" accept="image/*" style="display:none;" onchange="uploadFileAsync(this, 'thumbnail', 'thumbnailUrl', 'thumbStatus', updateThumbPreview)"/>
                            </div>
                            <div id="thumbStatus" class="upload-status"></div>
                            <span class="ins-field__hint">Hỗ trợ tải trực tiếp ảnh từ máy tính (.jpg, .png, .webp) hoặc dán link ảnh từ bên ngoài.</span>
                            <div class="ins-preview-box" id="thumbBox">
                                <img id="thumbImg" src="" alt="Thumbnail Preview" onload="this.style.display='block'" onerror="this.style.display='none'"/>
                                <span id="thumbPlaceholder" style="font-size:.8rem; color:#94A3B8;">Chưa có ảnh xem trước</span>
                            </div>
                        </div>

                        <!-- Promo Video -->
                        <div class="ins-field">
                            <label for="promoVideoUrl">Video giới thiệu (Promo Video / Trailer)</label>
                            <div class="upload-row">
                                <form:input path="promoVideoUrl" id="promoVideoUrl" placeholder="Dán link YouTube hoặc tải video MP4..."/>
                                <button type="button" class="upload-btn" onclick="document.getElementById('videoFileInput').click()">
                                    📤 Tải video từ máy
                                </button>
                                <input type="file" id="videoFileInput" accept="video/mp4,video/webm,video/mov" style="display:none;" onchange="uploadFileAsync(this, 'video', 'promoVideoUrl', 'videoStatus', null)"/>
                            </div>
                            <div id="videoStatus" class="upload-status"></div>
                            <span class="ins-field__hint">Hỗ trợ tải video MP4 từ máy tính hoặc dán link YouTube/Vimeo giới thiệu khóa học.</span>
                        </div>
                    </div>

                    <div class="ins-field" style="margin-top:16px;">
                        <label for="objectives">Mục tiêu đầu ra (What students will learn)</label>
                        <form:textarea path="objectives" id="objectives" rows="3"
                                       placeholder="VD:&#10;- Nắm vững cấu trúc dữ liệu và giải thuật trong Java&#10;- Xây dựng ứng dụng RESTful API với Spring Boot&#10;- Triển khai ứng dụng lên cloud"/>
                        <span class="ins-field__hint">Liệt kê các kỹ năng và kiến thức học viên sẽ đạt được sau khi hoàn thành khóa học.</span>
                    </div>

                    <div class="ins-field">
                        <label for="requirements">Yêu cầu đầu vào (Requirements / Prerequisites)</label>
                        <form:textarea path="requirements" id="requirements" rows="3"
                                       placeholder="VD:&#10;- Có kiến thức lập trình cơ bản bất kỳ&#10;- Máy tính cài đặt sẵn JDK 17 và IDE"/>
                        <span class="ins-field__hint">Những điều kiện cần chuẩn bị trước khi tham gia khóa học.</span>
                    </div>

                    <div class="ins-form-actions" style="margin-top:24px;">
                        <button class="ins-form-btn-primary" type="submit">💾 Lưu & Tiếp tục Bước 2 (Chương mục) →</button>
                        <a class="ins-form-btn-cancel" href="${pageContext.request.contextPath}/instructor/courses">Hủy</a>
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

function updateThumbPreview() {
    var val = document.getElementById('thumbnailUrl').value.trim();
    var img = document.getElementById('thumbImg');
    var placeholder = document.getElementById('thumbPlaceholder');
    if (val) {
        img.src = val;
        img.style.display = 'block';
        if (placeholder) placeholder.style.display = 'none';
    } else {
        img.style.display = 'none';
        if (placeholder) placeholder.style.display = 'inline';
    }
}
window.addEventListener('DOMContentLoaded', updateThumbPreview);

// AJAX File Upload Handler
function uploadFileAsync(inputElem, category, targetInputId, statusElemId, callback) {
    if (!inputElem.files || inputElem.files.length === 0) return;
    var file = inputElem.files[0];
    var statusElem = document.getElementById(statusElemId);
    statusElem.className = 'upload-status upload-status--loading';
    statusElem.textContent = '⏳ Đang tải tệp lên (' + (file.size / 1024 / 1024).toFixed(1) + ' MB)...';

    var formData = new FormData();
    formData.append('file', file);
    formData.append('category', category);

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
            document.getElementById(targetInputId).value = data.url;
            statusElem.className = 'upload-status upload-status--success';
            statusElem.textContent = '✅ Đã tải lên thành công: ' + data.originalName;
            if (callback) callback();
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
