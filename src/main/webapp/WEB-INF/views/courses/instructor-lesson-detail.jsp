<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chi tiết bài học — EduSphere</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/instructor.css">
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
                        <div style="display:flex;align-items:center;gap:10px;margin-bottom:6px">
                            <span style="color:rgba(255,255,255,.7);font-size:.8rem;font-weight:600">
                                Bài ${lesson.orderIndex} · <c:out value="${course.title}"/>
                            </span>
                            <c:choose>
                                <c:when test="${lesson.status eq 'PUBLISHED'}">
                                    <span class="ins-status-badge ins-status-badge--published">✅ Đã công bố</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="ins-status-badge ins-status-badge--draft">📝 Bản nháp</span>
                                </c:otherwise>
                            </c:choose>
                        </div>
                        <h1><c:out value="${lesson.title}"/></h1>
                    </div>
                    <div class="ins-detail-main__body">
                        <h2>Nội dung bài học</h2>
                        <div style="font-size:.92rem;color:var(--ink-2);line-height:1.8;white-space:pre-wrap;overflow-wrap:anywhere;background:var(--bg);padding:18px;border-radius:var(--r8);">
                            <c:choose>
                                <c:when test="${not empty lesson.content}"><c:out value="${lesson.content}"/></c:when>
                                <c:otherwise><em style="color:var(--muted)">Chưa có nội dung.</em></c:otherwise>
                            </c:choose>
                        </div>

                        <!-- Danh sách tài liệu -->
                        <h2 style="margin-top:28px">Tài liệu học tập
                            <span style="font-size:.8rem;font-weight:500;color:var(--muted);margin-left:6px">
                                (${fn:length(materials)} tài liệu)
                            </span>
                        </h2>

                        <c:choose>
                            <c:when test="${empty materials}">
                                <p style="font-size:.88rem;color:var(--muted);font-style:italic;padding:12px 0">
                                    Chưa có tài liệu. Thêm tài liệu bên dưới.
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
                                            <c:if test="${fn:startsWith(mat.fileUrl,'http://') || fn:startsWith(mat.fileUrl,'https://')}">
                                                <a class="ins-link-btn" href="${mat.fileUrl}" target="_blank" rel="noopener noreferrer">
                                                    Mở ↗
                                                </a>
                                            </c:if>
                                        </div>
                                    </c:forEach>
                                </div>
                            </c:otherwise>
                        </c:choose>

                        <!-- Form thêm tài liệu -->
                        <c:if test="${editable}">
                            <div style="margin-top:28px;padding-top:20px;border-top:1px solid var(--line)">
                                <h2 style="margin-top:0;margin-bottom:16px">Thêm tài liệu mới</h2>
                                <c:if test="${course.status eq 'PUBLISHED' or course.status eq 'APPROVED'}">
                                    <div class="ins-alert ins-alert--warning" style="margin-bottom:16px">
                                        ⚠️ <strong>Lưu ý:</strong> Thêm tài liệu cho bài học sẽ chuyển khóa học về 
                                        <strong>Bản nháp (v${course.versionNo + 1})</strong> để gửi Admin phê duyệt lại.
                                    </div>
                                </c:if>
                                <form:form method="post" modelAttribute="materialForm"
                                           action="${pageContext.request.contextPath}/instructor/courses/${course.courseId}/lessons/${lesson.lessonId}/materials"
                                           htmlEscape="true">
                                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                    <div class="ins-form-grid" style="margin-bottom:16px">
                                        <div class="ins-field">
                                            <label for="mat-title">Tên tài liệu <span style="color:#EF4444">*</span></label>
                                            <form:input path="title" id="mat-title" maxlength="255"
                                                        placeholder="VD: Slide bài giảng..."/>
                                            <form:errors path="title" cssClass="ins-field__error"/>
                                        </div>
                                        <div class="ins-field">
                                            <label for="mat-type">Loại <span style="color:#EF4444">*</span></label>
                                            <form:select path="type" id="mat-type">
                                                <form:option value="" label="Chọn loại"/>
                                                <form:option value="DOCUMENT" label="📄 Tài liệu"/>
                                                <form:option value="LINK"     label="🔗 Liên kết"/>
                                                <form:option value="VIDEO"    label="🎬 Video"/>
                                            </form:select>
                                            <form:errors path="type" cssClass="ins-field__error"/>
                                        </div>
                                    </div>
                                    <div class="ins-field">
                                        <label for="mat-url">Đường dẫn URL <span style="color:#EF4444">*</span></label>
                                        <form:input path="fileUrl" id="mat-url" type="url" maxlength="2048"
                                                    placeholder="https://..."/>
                                        <span class="ins-field__hint">Link đến tài liệu, video YouTube, Google Drive...</span>
                                        <form:errors path="fileUrl" cssClass="ins-field__error"/>
                                    </div>
                                    <button class="ins-form-btn-primary" style="width:auto" type="submit">
                                        ➕ Thêm tài liệu
                                    </button>
                                </form:form>
                            </div>
                        </c:if>
                    </div>
                </div>
            </div>

            <!-- Aside actions -->
            <aside class="ins-aside">
                <div class="ins-aside__header">⚡ Hành động</div>
                <div class="ins-aside__body">
                    <c:if test="${editable}">
                        <a class="ins-btn-outline"
                           href="${pageContext.request.contextPath}/instructor/courses/${course.courseId}/lessons/${lesson.lessonId}/edit">
                            ✏️ Chỉnh sửa bài học
                        </a>
                        <div class="ins-aside__divider"></div>
                    </c:if>
                    <a class="ins-btn-outline"
                       href="${pageContext.request.contextPath}/instructor/courses/${course.courseId}/lessons">
                        📋 Danh sách bài học
                    </a>
                    <a class="ins-btn-outline"
                       href="${pageContext.request.contextPath}/instructor/courses/${course.courseId}">
                        📖 Chi tiết khóa học
                    </a>
                    <c:if test="${not editable}">
                        <div class="ins-aside__divider"></div>
                        <p class="ins-aside__note">⚠️ Khóa học đang ở trạng thái không thể chỉnh sửa.</p>
                    </c:if>
                </div>
            </aside>
        </div>

    </main>
    </div>
</div>
<script>
function insToggleMenu(e){e.stopPropagation();document.getElementById('insUserMenu').classList.toggle('open');}
document.addEventListener('click',function(){var m=document.getElementById('insUserMenu');if(m)m.classList.remove('open');});
</script>
</body></html>
