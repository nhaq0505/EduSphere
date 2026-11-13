<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chi tiết thay đổi #${log.logId} — EduSphere Admin</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/home.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/admin.css">
    <style>
        .ccld-section {
            background: #fff;
            border: 1px solid #E2E8F0;
            border-radius: 12px;
            padding: 20px 24px;
            margin-bottom: 20px;
        }
        .ccld-section__title {
            font-size: .82rem;
            font-weight: 800;
            color: #64748B;
            text-transform: uppercase;
            letter-spacing: .05em;
            margin: 0 0 14px;
        }
        .ccld-meta-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 14px;
        }
        .ccld-meta-item__label { font-size: .75rem; color: #94A3B8; font-weight: 600; }
        .ccld-meta-item__val { font-size: .9rem; color: #0F172A; font-weight: 700; margin-top: 2px; }
        .ccld-diff-table {
            width: 100%;
            border-collapse: collapse;
            font-size: .85rem;
            border: 1px solid #E2E8F0;
            border-radius: 8px;
            overflow: hidden;
        }
        .ccld-diff-table th, .ccld-diff-table td {
            padding: 10px 14px;
            border-bottom: 1px solid #E2E8F0;
            text-align: left;
            vertical-align: top;
        }
        .ccld-diff-table th { background: #F8FAFC; font-weight: 700; color: #334155; }
        .ccld-before { background: #FEF2F2; color: #991B1B; white-space: pre-wrap; word-break: break-word; }
        .ccld-after { background: #F0FDF4; color: #166534; white-space: pre-wrap; word-break: break-word; }
        .ccld-thumb-preview {
            display: block;
            max-width: 220px;
            max-height: 130px;
            object-fit: cover;
            border-radius: 6px;
            border: 1px solid #CBD5E1;
            margin-bottom: 6px;
        }
    </style>
</head>
<body>

<jsp:include page="/WEB-INF/views/admin/header.jsp"/>

<div class="adm-shell">
    <jsp:include page="/WEB-INF/views/admin/sidebar.jsp"/>

    <main class="adm-content">

        <div style="margin-bottom:16px; display:flex; gap:12px; align-items:center; flex-wrap:wrap;">
            <a href="${pageContext.request.contextPath}/admin/course-change-logs"
               style="color:#64748B; font-size:.85rem; font-weight:600; text-decoration:none;">
                Quay lại Danh sách lịch sử thay đổi
            </a>
            <c:if test="${not empty log.courseId}">
                <span style="color:#CBD5E1;">|</span>
                <a href="${pageContext.request.contextPath}/admin/course-change-logs/course/${log.courseId}"
                   style="color:#2563EB; font-size:.85rem; font-weight:600; text-decoration:none;">
                    Lịch sử khóa học: <c:out value="${log.courseTitle}"/>
                </a>
            </c:if>
        </div>

        <div class="adm-page-head">
            <div>
                <span class="adm-page-head__eyebrow">Chi tiết bản ghi #${log.logId}</span>
                <h1 class="adm-page-head__title"><c:out value="${log.summary}"/></h1>
                <p class="adm-page-head__sub">
                    <c:out value="${log.entityTypeLabel}"/> · <c:out value="${log.actionTypeLabel}"/> · Thực hiện lúc <c:out value="${log.formattedCreatedAt}"/>
                </p>
            </div>
        </div>

        <!-- Cảnh báo nếu tài nguyên gốc đã bị xóa -->
        <c:if test="${not log.resourceExists and not empty log.resourceStatusMessage}">
            <div style="background:#FFFBEB; border:1.5px solid #F59E0B; color:#92400E; padding:14px 18px; border-radius:10px; margin-bottom:20px; font-size:.88rem; font-weight:600;">
                <strong>Thông báo tài nguyên:</strong> <c:out value="${log.resourceStatusMessage}"/>
            </div>
        </c:if>

        <!-- 1. Thông tin chung -->
        <div class="ccld-section">
            <p class="ccld-section__title">Thông tin thao tác</p>
            <div class="ccld-meta-grid">
                <div>
                    <div class="ccld-meta-item__label">Khóa học</div>
                    <div class="ccld-meta-item__val">
                        <a href="${pageContext.request.contextPath}/admin/course-change-logs/course/${log.courseId}" style="color:#2563EB; text-decoration:none;">
                            #<c:out value="${log.courseId}"/> — <c:out value="${log.courseTitle}"/>
                        </a>
                    </div>
                </div>
                <div>
                    <div class="ccld-meta-item__label">Người thực hiện</div>
                    <div class="ccld-meta-item__val">
                        <a href="${pageContext.request.contextPath}/admin/course-change-logs/teacher/${log.actorId}" style="color:#1E40AF; text-decoration:none;">
                            <c:out value="${log.actorName}"/>
                        </a>
                        <c:if test="${not empty log.actorEmail}">
                            <div style="font-size:.78rem; color:#64748B; font-weight:500;"><c:out value="${log.actorEmail}"/></div>
                        </c:if>
                    </div>
                </div>
                <div>
                    <div class="ccld-meta-item__label">Đối tượng tác động</div>
                    <div class="ccld-meta-item__val">
                        <c:out value="${log.entityTypeLabel}"/>
                        <c:if test="${not empty log.entityTitle}">: <c:out value="${log.entityTitle}"/></c:if>
                    </div>
                </div>
                <div>
                    <div class="ccld-meta-item__label">Loại hành động</div>
                    <div class="ccld-meta-item__val"><c:out value="${log.actionTypeLabel}"/></div>
                </div>
                <div>
                    <div class="ccld-meta-item__label">Thời gian ghi nhận</div>
                    <div class="ccld-meta-item__val"><c:out value="${log.formattedCreatedAt}"/></div>
                </div>
            </div>
        </div>

        <!-- 2. Nội dung bài học mới hoặc Bảng đối chiếu Phần đã chỉnh sửa -->
        <c:choose>
            <c:when test="${log.entityType eq 'LESSON' and log.actionType eq 'CREATE' and not empty log.newLessonDetail}">
                <c:set var="nl" value="${log.newLessonDetail}"/>
                <div class="ccld-section">
                    <p class="ccld-section__title">Chi tiết Bài học mới bổ sung</p>
                    <div style="display:flex; flex-wrap:wrap; gap:20px; margin-bottom:14px; padding-bottom:12px; border-bottom:1px solid #E2E8F0; font-size:.9rem;">
                        <div><strong>Bài học mới:</strong> Bài <c:out value="${nl.orderIndex}"/> — <c:out value="${nl.title}"/></div>
                        <div><strong>Thuộc chương:</strong> <c:out value="${nl.sectionTitle}"/></div>
                        <div><strong>Thể loại giảng viên chọn (1 trong 3):</strong> <span style="color:#1E40AF; font-weight:800;"><c:out value="${log.lessonTypeLabel}"/></span></div>
                    </div>

                    <c:choose>
                        <c:when test="${nl.lessonType eq 'VIDEO'}">
                            <div style="margin-bottom:12px; font-size:.88rem;">
                                <strong>Đường dẫn Video:</strong> <c:out value="${nl.videoUrl}"/>
                                <c:if test="${not empty nl.bunnyVideoId}"> · <strong>Bunny ID:</strong> <code><c:out value="${nl.bunnyVideoId}"/></code></c:if>
                                <c:if test="${not empty nl.videoDuration}"> · <strong>Thời lượng:</strong> <c:out value="${nl.videoDuration}"/> phút</c:if>
                                · <strong>Chế độ xem:</strong> <c:out value="${nl.allowSeek ? 'Cho phép tua video' : 'Bắt buộc xem tuần tự (Cấm tua)'}"/>
                            </div>
                        </c:when>
                        <c:when test="${nl.lessonType eq 'QUIZ'}">
                            <c:if test="${not empty nl.quizzes}">
                                <c:forEach var="qz" items="${nl.quizzes}">
                                    <div style="margin-bottom:14px;">
                                        <div style="font-weight:800; color:#0F172A; margin-bottom:8px;">
                                            Đề Quiz: <c:out value="${qz.title}"/> (${qz.questions.size()} câu hỏi · Thời gian: ${qz.timeLimitMinutes} phút · Tối đa ${qz.maxAttempts} lần làm · Điểm đạt: ${qz.passingScore}%)
                                        </div>
                                        <c:forEach var="ques" items="${qz.questions}">
                                            <div style="background:#F8FAFC; border:1px solid #E2E8F0; border-radius:8px; padding:10px 14px; margin-bottom:8px;">
                                                <div style="font-weight:700; color:#0F172A;">Câu ${ques.orderIndex}: <c:out value="${ques.content}"/> (${ques.score} điểm)</div>
                                                <c:if test="${not empty ques.options}">
                                                    <div style="margin-top:6px; padding-left:10px; font-size:.84rem;">
                                                        <c:forEach var="opt" items="${ques.options}">
                                                            <div style="color:${opt.correct ? '#166534' : '#475569'}; font-weight:${opt.correct ? '700' : '400'};">
                                                                ${opt.correct ? '[Đáp án đúng] ' : '- '} <c:out value="${opt.content}"/>
                                                            </div>
                                                        </c:forEach>
                                                    </div>
                                                </c:if>
                                            </div>
                                        </c:forEach>
                                    </div>
                                </c:forEach>
                            </c:if>
                        </c:when>
                        <c:otherwise>
                            <div>
                                <strong>Nội dung văn bản bài học mới:</strong>
                                <div style="white-space:pre-wrap; margin-top:6px; background:#F8FAFC; border:1px solid #E2E8F0; border-radius:8px; padding:12px;"><c:out value="${not empty nl.content ? nl.content : '(Chưa có nội dung văn bản)'}"/></div>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </c:when>
            <c:otherwise>
                <div class="ccld-section">
                    <p class="ccld-section__title">Bảng đối chiếu Phần đã chỉnh sửa</p>
                    <c:choose>
                        <c:when test="${empty log.fieldDiffs}">
                            <span style="color:#94A3B8; font-style:italic; font-size:.86rem;">Không có dữ liệu trường thay đổi chi tiết.</span>
                        </c:when>
                        <c:otherwise>
                            <table class="ccld-diff-table">
                                <thead>
                                    <tr>
                                        <th style="width:22%;">Phần đã chỉnh sửa</th>
                                        <th style="width:39%;">Trước khi sửa</th>
                                        <th style="width:39%;">Sau khi sửa</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="diff" items="${log.fieldDiffs}">
                                        <tr>
                                            <td style="font-weight:700; color:#0F172A;">
                                                <c:out value="${diff.fieldLabel}"/>
                                            </td>
                                            <td class="ccld-before">
                                                <c:if test="${diff.fieldKey eq 'thumbnailUrl' and not empty diff.beforeValue}">
                                                    <img src="<c:out value='${diff.beforeValue}'/>" alt="Ảnh bìa cũ" class="ccld-thumb-preview" onerror="this.style.display='none'"/>
                                                </c:if>
                                                <c:out value="${not empty diff.beforeValue ? diff.beforeValue : '(Trống)'}"/>
                                            </td>
                                            <td class="ccld-after">
                                                <c:if test="${diff.fieldKey eq 'thumbnailUrl' and not empty diff.afterValue}">
                                                    <img src="<c:out value='${diff.afterValue}'/>" alt="Ảnh bìa mới" class="ccld-thumb-preview" onerror="this.style.display='none'"/>
                                                </c:if>
                                                <c:out value="${not empty diff.afterValue ? diff.afterValue : '(Trống / Đã xóa)'}"/>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </c:otherwise>
                    </c:choose>
                </div>
            </c:otherwise>
        </c:choose>

        <!-- 3. Xem trực tiếp Video (Video mới & Video cũ nếu thay thế) -->
        <c:if test="${not empty log.videoUrl or not empty log.oldVideoUrl}">
            <div class="ccld-section">
                <p class="ccld-section__title">Kiểm tra &amp; Xem Video bài giảng</p>
                <div style="display:grid; grid-template-columns: repeat(auto-fit, minmax(320px, 1fr)); gap:20px;">
                    <c:if test="${not empty log.oldVideoUrl and log.oldVideoUrl ne log.videoUrl}">
                        <div style="border:1px solid #FECACA; background:#FEF2F2; border-radius:10px; padding:14px;">
                            <div style="font-weight:700; color:#991B1B; margin-bottom:6px;">
                                Video trước khi thay đổi
                                <c:if test="${not empty log.oldBunnyVideoId}">(Bunny ID: <code><c:out value="${log.oldBunnyVideoId}"/></code>)</c:if>
                            </div>
                            <c:choose>
                                <c:when test="${log.oldVideoResourceExists}">
                                    <div style="position:relative; padding-bottom:56.25%; height:0; border-radius:8px; overflow:hidden; background:#000;">
                                        <iframe class="ccld-video-iframe" data-src="<c:out value='${log.oldVideoUrl}'/>"
                                                style="position:absolute;top:0;left:0;width:100%;height:100%;border:0;" allowfullscreen></iframe>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <div style="font-size:.82rem; color:#991B1B;">Video cũ không còn tồn tại trên hệ thống lưu trữ (<c:out value="${log.oldVideoUrl}"/>).</div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </c:if>

                    <c:if test="${not empty log.videoUrl}">
                        <div style="border:1px solid #86EFAC; background:#F0FDF4; border-radius:10px; padding:14px;">
                            <div style="font-weight:700; color:#166534; margin-bottom:6px; display:flex; justify-content:space-between;">
                                <span>Video bài giảng <c:if test="${not empty log.bunnyVideoId}">(Bunny ID: <code><c:out value="${log.bunnyVideoId}"/></code>)</c:if></span>
                                <a href="<c:out value='${log.videoUrl}'/>" target="_blank" rel="noopener" style="font-size:.8rem; color:#2563EB;">Mở tab mới</a>
                            </div>
                            <c:choose>
                                <c:when test="${log.videoResourceExists}">
                                    <c:set var="vLower" value="${fn:toLowerCase(log.videoUrl)}"/>
                                    <div style="position:relative; padding-bottom:56.25%; height:0; border-radius:8px; overflow:hidden; background:#000;">
                                        <c:choose>
                                            <c:when test="${fn:contains(log.videoUrl, '/uploads/') or fn:endsWith(vLower, '.mp4') or fn:endsWith(vLower, '.webm')}">
                                                <video controls style="position:absolute;top:0;left:0;width:100%;height:100%;background:#000;">
                                                    <source src="<c:out value='${log.videoUrl}'/>">
                                                </video>
                                            </c:when>
                                            <c:otherwise>
                                                <iframe class="ccld-video-iframe" data-src="<c:out value='${log.videoUrl}'/>"
                                                        style="position:absolute;top:0;left:0;width:100%;height:100%;border:0;" allowfullscreen></iframe>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <div style="font-size:.82rem; color:#991B1B;">Tài nguyên video không còn tồn tại trên máy chủ (<c:out value="${log.videoUrl}"/>).</div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </c:if>
                </div>
            </div>
        </c:if>

        <!-- 4. Xem hoặc tải Tài liệu (Document) -->
        <c:if test="${not empty log.fileUrl or not empty log.oldFileUrl}">
            <div class="ccld-section">
                <p class="ccld-section__title">Kiểm tra &amp; Tải tài liệu đính kèm</p>
                <c:if test="${not empty log.oldFileUrl and log.oldFileUrl ne log.fileUrl}">
                    <div style="padding:12px 14px; background:#FEF2F2; border:1px solid #FECACA; border-radius:8px; margin-bottom:10px; display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap;">
                        <div>
                            <strong>File trước khi thay đổi:</strong> <c:out value="${log.oldFileName}"/>
                            <div style="font-size:.78rem; color:#64748B;"><c:out value="${log.oldFileUrl}"/></div>
                        </div>
                        <c:choose>
                            <c:when test="${log.oldFileResourceExists}">
                                <a href="<c:out value='${log.oldFileUrl}'/>" target="_blank" rel="noopener" class="hn-btn hn-btn--outline adm-btn-sm">Xem / Tải file cũ</a>
                            </c:when>
                            <c:otherwise>
                                <span style="color:#DC2626; font-size:.8rem; font-weight:700;">File cũ đã bị xóa khỏi hệ thống lưu trữ</span>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </c:if>

                <c:if test="${not empty log.fileUrl}">
                    <div style="padding:12px 14px; background:#F0FDF4; border:1px solid #86EFAC; border-radius:8px; display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap;">
                        <div>
                            <strong>File tài liệu:</strong> <c:out value="${log.fileName}"/>
                            <c:if test="${not empty log.fileType}"> [<c:out value="${log.fileType}"/>]</c:if>
                            <div style="font-size:.78rem; color:#64748B;"><c:out value="${log.fileUrl}"/></div>
                        </div>
                        <c:choose>
                            <c:when test="${log.fileResourceExists}">
                                <a href="<c:out value='${log.fileUrl}'/>" target="_blank" rel="noopener" class="hn-btn hn-btn--primary adm-btn-sm">Xem / Tải tài liệu</a>
                            </c:when>
                            <c:otherwise>
                                <span style="color:#DC2626; font-size:.8rem; font-weight:700;">Tài nguyên file không còn tồn tại trên máy chủ</span>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </c:if>
            </div>
        </c:if>

        <!-- 5. Danh sách câu hỏi Quiz (nếu log liên quan đến Quiz / Question) -->
        <c:if test="${not empty log.quizQuestions}">
            <div class="ccld-section">
                <p class="ccld-section__title">Danh sách câu hỏi hiện tại trong bài Quiz (${log.quizQuestions.size()} câu)</p>
                <div style="display:flex; flex-direction:column; gap:10px;">
                    <c:forEach var="qMap" items="${log.quizQuestions}">
                        <div style="border:1px solid #E2E8F0; border-radius:8px; padding:12px 14px; background:#F8FAFC;">
                            <div style="font-weight:700; color:#0F172A; margin-bottom:6px;">
                                Câu <c:out value="${qMap['orderIndex']}"/> [<c:out value="${qMap['type']}"/> — <c:out value="${qMap['score']}"/>đ]:
                                <c:out value="${qMap['content']}"/>
                            </div>
                            <c:if test="${not empty qMap['options']}">
                                <div style="white-space:pre-wrap; font-size:.83rem; color:#334155; background:#fff; padding:8px 10px; border-radius:6px; border:1px solid #E2E8F0;"><c:out value="${qMap['options']}"/></div>
                            </c:if>
                            <c:if test="${not empty qMap['correctAnswer']}">
                                <div style="font-size:.82rem; color:#15803D; font-weight:700; margin-top:6px;">
                                    Đáp án đúng: <c:out value="${qMap['correctAnswer']}"/>
                                </div>
                            </c:if>
                        </div>
                    </c:forEach>
                </div>
            </div>
        </c:if>

    </main>
</div>

<script>
function toggleUserMenu(e) {
    e.stopPropagation();
    e.currentTarget.closest('.hn-user-menu').classList.toggle('open');
}
document.addEventListener('click', () => {
    document.querySelectorAll('.hn-user-menu.open').forEach(m => m.classList.remove('open'));
});

document.addEventListener('DOMContentLoaded', function() {
    document.querySelectorAll('.ccld-video-iframe').forEach(function(iframe) {
        var url = (iframe.getAttribute('data-src') || '').trim();
        if (!url) return;
        if (url.indexOf('youtube.com') !== -1 || url.indexOf('youtu.be') !== -1) {
            var videoId = '';
            if (url.indexOf('watch?v=') !== -1) {
                videoId = url.split('watch?v=')[1].split('&')[0];
            } else if (url.indexOf('youtu.be/') !== -1) {
                videoId = url.split('youtu.be/')[1].split('?')[0];
            } else {
                videoId = url;
            }
            url = videoId.indexOf('http') === 0 ? videoId : 'https://www.youtube.com/embed/' + videoId;
        }
        iframe.src = url;
    });
});
</script>
</body>
</html>
