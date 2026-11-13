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
    <title>Lịch sử thay đổi khóa học — EduSphere Admin</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/home.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/admin.css">
    <style>
        .ccl-filter-card {
            background: #fff;
            border: 1px solid #E2E8F0;
            border-radius: 12px;
            padding: 18px 20px;
            margin-bottom: 20px;
        }
        .ccl-filter-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
            gap: 12px;
            align-items: end;
        }
        .ccl-field label {
            display: block;
            font-size: .76rem;
            font-weight: 700;
            color: #475569;
            margin-bottom: 4px;
        }
        .ccl-field input, .ccl-field select {
            width: 100%;
            box-sizing: border-box;
            padding: 8px 10px;
            border: 1.5px solid #CBD5E1;
            border-radius: 8px;
            font-size: .84rem;
            font-family: inherit;
            background: #fff;
            color: #0F172A;
        }
        .ccl-log-card {
            background: #fff;
            border: 1px solid #E2E8F0;
            border-radius: 12px;
            padding: 18px 22px;
            margin-bottom: 16px;
            transition: border-color .15s, box-shadow .15s;
        }
        .ccl-log-card:hover {
            border-color: #93C5FD;
            box-shadow: 0 4px 12px rgba(15, 23, 42, .05);
        }
        .ccl-badge {
            display: inline-flex;
            align-items: center;
            gap: 4px;
            font-size: .72rem;
            font-weight: 700;
            padding: 3px 10px;
            border-radius: 20px;
        }
        .ccl-badge--entity { background: #F1F5F9; color: #0F172A; border: 1px solid #CBD5E1; }
        .ccl-badge--create { background: #DCFCE7; color: #166534; border: 1px solid #86EFAC; }
        .ccl-badge--update { background: #DBEAFE; color: #1E40AF; border: 1px solid #93C5FD; }
        .ccl-badge--delete { background: #FEE2E2; color: #991B1B; border: 1px solid #FCA5A5; }
        .ccl-badge--type { background: #EEF2FF; color: #3730A3; border: 1px solid #C7D2FE; }
        .ccl-diff-table {
            width: 100%;
            border-collapse: collapse;
            font-size: .82rem;
            margin-top: 12px;
            border: 1px solid #E2E8F0;
            border-radius: 8px;
            overflow: hidden;
        }
        .ccl-diff-table th, .ccl-diff-table td {
            padding: 9px 12px;
            border-bottom: 1px solid #F1F5F9;
            text-align: left;
            vertical-align: top;
        }
        .ccl-diff-table th { background: #F8FAFC; color: #334155; font-weight: 700; }
        .ccl-before { background: #FEF2F2; color: #991B1B; white-space: pre-wrap; word-break: break-word; max-height: 160px; overflow-y: auto; }
        .ccl-after { background: #F0FDF4; color: #166534; white-space: pre-wrap; word-break: break-word; max-height: 160px; overflow-y: auto; }
        .ccl-new-lesson-box {
            margin-top: 12px;
            background: #F8FAFC;
            border: 1px solid #CBD5E1;
            border-radius: 10px;
            padding: 14px 16px;
        }
        .ccl-new-lesson-meta {
            display: flex;
            flex-wrap: wrap;
            gap: 16px;
            font-size: .84rem;
            color: #334155;
            padding-bottom: 10px;
            margin-bottom: 12px;
            border-bottom: 1px dashed #CBD5E1;
        }
        .ccl-thumb-preview {
            display: block;
            max-width: 180px;
            max-height: 105px;
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

        <!-- Page head -->
        <div class="adm-page-head">
            <div>
                <span class="adm-page-head__eyebrow">Giám sát nội dung</span>
                <h1 class="adm-page-head__title">Lịch sử thay đổi khóa học</h1>
                <p class="adm-page-head__sub">
                    Chỉ hiển thị các phần đã chỉnh sửa và bài học mới bổ sung ở các đợt cập nhật sau khi khóa học đã được phê duyệt lần đầu.
                </p>
            </div>
            <div class="adm-page-head__stats">
                <div class="adm-stat">
                    <span class="adm-stat__num">${logsPage.totalElements}</span>
                    <span class="adm-stat__label">Mục thay đổi</span>
                </div>
            </div>
        </div>

        <!-- Focused Course or Teacher Banner -->
        <c:if test="${not empty focusedCourse or not empty focusedTeacher}">
            <div style="background:#EFF6FF; border:1.5px solid #93C5FD; border-radius:12px; padding:14px 18px; margin-bottom:18px; display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:10px;">
                <div style="font-size:.88rem; color:#1E3A8A;">
                    <c:if test="${not empty focusedCourse}">
                        Đang lọc theo khóa học: <strong><c:out value="${focusedCourse.title}"/></strong>
                        (Trạng thái: <strong><c:out value="${focusedCourse.status}"/></strong>)
                    </c:if>
                    <c:if test="${not empty focusedTeacher}">
                        Đang lọc theo giảng viên: <strong><c:out value="${focusedTeacher.fullName}"/></strong> (<c:out value="${focusedTeacher.email}"/>)
                    </c:if>
                </div>
                <div style="display:flex; gap:8px;">
                    <c:if test="${not empty focusedCourse and focusedCourse.status eq 'SUBMITTED'}">
                        <a href="${pageContext.request.contextPath}/admin/courses/${focusedCourse.courseId}/review"
                           style="font-size:.8rem; font-weight:700; background:#2563EB; color:#fff; padding:6px 12px; border-radius:6px; text-decoration:none;">
                            Đi tới trang Duyệt khóa học
                        </a>
                    </c:if>
                    <a href="${pageContext.request.contextPath}/admin/course-change-logs"
                       style="font-size:.8rem; font-weight:700; background:#fff; color:#475569; border:1px solid #CBD5E1; padding:6px 12px; border-radius:6px; text-decoration:none;">
                        Bỏ bộ lọc
                    </a>
                </div>
            </div>
        </c:if>

        <!-- Filter Form -->
        <div class="ccl-filter-card">
            <form method="get" action="${pageContext.request.contextPath}/admin/course-change-logs">
                <div class="ccl-filter-grid">
                    <div class="ccl-field">
                        <label for="courseId">Khóa học</label>
                        <select name="courseId" id="courseId">
                            <option value="">-- Tất cả khóa học --</option>
                            <c:forEach var="cItem" items="${allCourses}">
                                <option value="${cItem.courseId}" <c:if test="${selectedCourseId == cItem.courseId}">selected</c:if>>
                                    #<c:out value="${cItem.courseId}"/> - <c:out value="${cItem.title}"/>
                                </option>
                            </c:forEach>
                        </select>
                    </div>

                    <div class="ccl-field">
                        <label for="teacherId">Giảng viên</label>
                        <select name="teacherId" id="teacherId">
                            <option value="">-- Tất cả giảng viên --</option>
                            <c:forEach var="ins" items="${instructors}">
                                <option value="${ins.userId}" <c:if test="${selectedTeacherId == ins.userId}">selected</c:if>>
                                    <c:out value="${ins.fullName}"/> (<c:out value="${ins.email}"/>)
                                </option>
                            </c:forEach>
                        </select>
                    </div>

                    <div class="ccl-field">
                        <label for="entityType">Loại nội dung</label>
                        <select name="entityType" id="entityType">
                            <option value="">-- Tất cả loại --</option>
                            <option value="COURSE" <c:if test="${selectedEntityType eq 'COURSE'}">selected</c:if>>Khóa học</option>
                            <option value="CHAPTER" <c:if test="${selectedEntityType eq 'CHAPTER'}">selected</c:if>>Chương học</option>
                            <option value="LESSON" <c:if test="${selectedEntityType eq 'LESSON'}">selected</c:if>>Bài học</option>
                            <option value="VIDEO" <c:if test="${selectedEntityType eq 'VIDEO'}">selected</c:if>>Video</option>
                            <option value="DOCUMENT" <c:if test="${selectedEntityType eq 'DOCUMENT'}">selected</c:if>>Tài liệu</option>
                            <option value="QUIZ" <c:if test="${selectedEntityType eq 'QUIZ'}">selected</c:if>>Bài Quiz</option>
                            <option value="QUESTION" <c:if test="${selectedEntityType eq 'QUESTION'}">selected</c:if>>Câu hỏi Quiz</option>
                        </select>
                    </div>

                    <div class="ccl-field">
                        <label for="actionType">Thao tác</label>
                        <select name="actionType" id="actionType">
                            <option value="">-- Tất cả thao tác --</option>
                            <option value="CREATE" <c:if test="${selectedActionType eq 'CREATE'}">selected</c:if>>Tạo mới (Bổ sung bài/chương mới)</option>
                            <option value="UPDATE" <c:if test="${selectedActionType eq 'UPDATE'}">selected</c:if>>Chỉnh sửa nội dung</option>
                            <option value="DELETE" <c:if test="${selectedActionType eq 'DELETE'}">selected</c:if>>Xóa nội dung</option>
                            <option value="REORDER" <c:if test="${selectedActionType eq 'REORDER'}">selected</c:if>>Đổi thứ tự</option>
                            <option value="VIDEO_REPLACE" <c:if test="${selectedActionType eq 'VIDEO_REPLACE'}">selected</c:if>>Thay thế video</option>
                        </select>
                    </div>

                    <div class="ccl-field">
                        <label for="fromDate">Từ ngày</label>
                        <input type="date" name="fromDate" id="fromDate" value="<c:out value='${fromDate}'/>"/>
                    </div>

                    <div class="ccl-field">
                        <label for="toDate">Đến ngày</label>
                        <input type="date" name="toDate" id="toDate" value="<c:out value='${toDate}'/>"/>
                    </div>

                    <div class="ccl-field">
                        <label for="q">Từ khóa tìm kiếm</label>
                        <input type="text" name="q" id="q" value="<c:out value='${q}'/>" placeholder="Tên bài học, khóa học, GV..."/>
                    </div>

                    <div style="display:flex; gap:8px;">
                        <button type="submit" class="hn-btn hn-btn--primary adm-btn-sm" style="height:36px;">Lọc</button>
                        <a href="${pageContext.request.contextPath}/admin/course-change-logs"
                           class="hn-btn hn-btn--outline adm-btn-sm" style="height:36px; display:inline-flex; align-items:center;">Đặt lại</a>
                    </div>
                </div>
            </form>
        </div>

        <!-- Logs List -->
        <c:choose>
            <c:when test="${empty logs}">
                <div class="adm-empty">
                    <h3>Chưa có thay đổi hoặc bổ sung mới nào sau khi phê duyệt</h3>
                    <p>Các phần giữ nguyên hoặc khóa học gửi duyệt lần đầu tiên sẽ không hiển thị tại đây để tránh gây rối mắt cho Quản trị viên.</p>
                </div>
            </c:when>
            <c:otherwise>
                <c:forEach var="log" items="${logs}">
                    <div class="ccl-log-card">
                        <div style="display:flex; justify-content:space-between; align-items:flex-start; flex-wrap:wrap; gap:12px;">
                            <div style="flex:1; min-width:260px;">
                                <div style="display:flex; align-items:center; gap:8px; flex-wrap:wrap; margin-bottom:8px;">
                                    <span class="ccl-badge ccl-badge--entity"><c:out value="${log.entityTypeLabel}"/></span>
                                    <c:choose>
                                        <c:when test="${log.actionType eq 'CREATE' or log.actionType eq 'VIDEO_UPLOAD'}">
                                            <span class="ccl-badge ccl-badge--create">Bổ sung mới</span>
                                        </c:when>
                                        <c:when test="${log.actionType eq 'DELETE' or log.actionType eq 'VIDEO_REMOVE'}">
                                            <span class="ccl-badge ccl-badge--delete"><c:out value="${log.actionTypeLabel}"/></span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="ccl-badge ccl-badge--update">Phần đã chỉnh sửa</span>
                                        </c:otherwise>
                                    </c:choose>
                                    <c:if test="${not empty log.lessonTypeLabel}">
                                        <span class="ccl-badge ccl-badge--type">Thể loại: <c:out value="${log.lessonTypeLabel}"/></span>
                                    </c:if>
                                    <span style="font-size:.8rem; color:#64748B;">
                                        Thời gian: <strong><c:out value="${log.formattedCreatedAt}"/></strong>
                                    </span>
                                    <span style="font-size:.8rem; color:#475569;">
                                        · Giảng viên:
                                        <a href="${pageContext.request.contextPath}/admin/course-change-logs/teacher/${log.actorId}"
                                           style="color:#1E40AF; font-weight:600; text-decoration:none;"><c:out value="${log.actorName}"/></a>
                                    </span>
                                    <span style="font-size:.8rem; color:#475569;">
                                        · Khóa học:
                                        <a href="${pageContext.request.contextPath}/admin/course-change-logs/course/${log.courseId}"
                                           style="color:#2563EB; font-weight:700; text-decoration:none;"><c:out value="${log.courseTitle}"/></a>
                                    </span>
                                </div>

                                <div style="font-size:.96rem; font-weight:800; color:#0F172A; margin-bottom:4px;">
                                    <c:out value="${log.summary}"/>
                                </div>
                            </div>

                            <div style="display:flex; gap:8px; align-items:center;">
                                <a href="${pageContext.request.contextPath}/admin/course-change-logs/${log.logId}"
                                   class="hn-btn hn-btn--outline adm-btn-sm">
                                    Xem chi tiết
                                </a>
                            </div>
                        </div>

                        <c:choose>
                            <%-- TRƯỜNG HỢP 2: BÀI HỌC MỚI (Ví dụ Bài 2, Bài 3, Bài 4...) --%>
                            <c:when test="${log.entityType eq 'LESSON' and log.actionType eq 'CREATE' and not empty log.newLessonDetail}">
                                <c:set var="nl" value="${log.newLessonDetail}"/>
                                <div class="ccl-new-lesson-box">
                                    <div class="ccl-new-lesson-meta">
                                        <div><strong>Bài học mới:</strong> Bài <c:out value="${nl.orderIndex}"/> — <c:out value="${nl.title}"/></div>
                                        <div><strong>Thuộc chương:</strong> <c:out value="${nl.sectionTitle}"/></div>
                                        <div>
                                            <strong>Thể loại giảng viên chọn (1 trong 3):</strong>
                                            <span style="font-weight:800; color:#1E40AF;"><c:out value="${log.lessonTypeLabel}"/></span>
                                        </div>
                                    </div>

                                    <div style="font-size:.85rem; color:#0F172A;">
                                        <div style="font-weight:800; color:#166534; margin-bottom:8px;">
                                            Nội dung mới trong thể loại <c:out value="${log.lessonTypeLabel}"/> để Quản trị viên kiểm duyệt:
                                        </div>

                                        <c:choose>
                                            <%-- Thể loại 1: VIDEO --%>
                                            <c:when test="${nl.lessonType eq 'VIDEO'}">
                                                <div style="background:#fff; border:1px solid #E2E8F0; border-radius:8px; padding:12px;">
                                                    <div style="margin-bottom:8px;">
                                                        <strong>Đường dẫn Video:</strong>
                                                        <c:choose>
                                                            <c:when test="${not empty nl.videoUrl}">
                                                                <a href="<c:out value='${nl.videoUrl}'/>" target="_blank" rel="noopener" style="color:#2563EB; font-weight:600;"><c:out value="${nl.videoUrl}"/></a>
                                                            </c:when>
                                                            <c:otherwise><span style="color:#DC2626;">Chưa đính kèm đường dẫn video</span></c:otherwise>
                                                        </c:choose>
                                                        <c:if test="${not empty nl.bunnyVideoId}">
                                                            · <strong>Bunny ID:</strong> <code><c:out value="${nl.bunnyVideoId}"/></code>
                                                        </c:if>
                                                        <c:if test="${not empty nl.videoDuration}">
                                                            · <strong>Thời lượng:</strong> <c:out value="${nl.videoDuration}"/> phút
                                                        </c:if>
                                                        · <strong>Chế độ xem:</strong> <c:out value="${nl.allowSeek ? 'Cho phép tua video' : 'Bắt buộc xem tuần tự (Cấm tua)'}"/>
                                                    </div>
                                                    <c:if test="${not empty nl.videoUrl}">
                                                        <c:choose>
                                                            <c:when test="${fn:contains(nl.videoUrl, 'mediadelivery.net/embed/') or fn:contains(nl.videoUrl, 'youtube.com/embed/')}">
                                                                <div style="position:relative; padding-top:42%; background:#000; border-radius:8px; overflow:hidden; max-width:640px;">
                                                                    <iframe src="<c:out value='${nl.videoUrl}'/>"
                                                                            style="position:absolute; top:0; left:0; width:100%; height:100%; border:0;"
                                                                            allow="accelerometer; gyroscope; encrypted-media; picture-in-picture;"
                                                                            allowfullscreen="true"></iframe>
                                                                </div>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <video controls preload="metadata" style="width:100%; max-width:560px; max-height:300px; border-radius:8px; background:#000;"
                                                                       src="<c:out value='${nl.videoUrl}'/>"></video>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </c:if>
                                                    <c:if test="${not empty nl.content}">
                                                        <div style="margin-top:10px; padding-top:8px; border-top:1px solid #F1F5F9;">
                                                            <strong>Mô tả / Ghi chú bài giảng video:</strong>
                                                            <div style="white-space:pre-wrap; margin-top:4px; color:#334155;"><c:out value="${nl.content}"/></div>
                                                        </div>
                                                    </c:if>
                                                </div>
                                            </c:when>

                                            <%-- Thể loại 2: QUIZ --%>
                                            <c:when test="${nl.lessonType eq 'QUIZ'}">
                                                <div style="background:#fff; border:1px solid #E2E8F0; border-radius:8px; padding:12px;">
                                                    <c:choose>
                                                        <c:when test="${not empty nl.quizzes}">
                                                            <c:forEach var="qz" items="${nl.quizzes}">
                                                                <div style="margin-bottom:10px;">
                                                                    <div style="display:flex; justify-content:space-between; flex-wrap:wrap; gap:8px; margin-bottom:8px;">
                                                                        <div>
                                                                            <strong>Đề Quiz: <c:out value="${qz.title}"/></strong>
                                                                            <span style="color:#64748B; font-size:.8rem; margin-left:6px;">
                                                                                (${qz.questions.size()} câu hỏi · Thời gian: ${qz.timeLimitMinutes} phút · Tối đa ${qz.maxAttempts} lần làm · Điểm đạt: ${qz.passingScore}%)
                                                                            </span>
                                                                        </div>
                                                                    </div>
                                                                    <c:if test="${not empty qz.questions}">
                                                                        <div style="display:flex; flex-direction:column; gap:8px;">
                                                                            <c:forEach var="ques" items="${qz.questions}">
                                                                                <div style="background:#F8FAFC; border:1px solid #E2E8F0; border-radius:6px; padding:8px 12px;">
                                                                                    <div style="font-weight:700; color:#0F172A;">
                                                                                        Câu ${ques.orderIndex}: <c:out value="${ques.content}"/>
                                                                                        <span style="font-weight:500; color:#64748B; font-size:.78rem;">(${ques.score} điểm)</span>
                                                                                    </div>
                                                                                    <c:if test="${not empty ques.options}">
                                                                                        <div style="margin-top:4px; padding-left:10px; font-size:.8rem;">
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
                                                                    </c:if>
                                                                </div>
                                                            </c:forEach>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <div style="color:#64748B; font-style:italic;">Bài học thuộc thể loại Quiz (Chưa có câu hỏi nào được tạo hoặc câu hỏi lưu trong phần mô tả bài học).</div>
                                                            <c:if test="${not empty nl.content}">
                                                                <div style="white-space:pre-wrap; margin-top:6px; color:#334155;"><c:out value="${nl.content}"/></div>
                                                            </c:if>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </div>
                                            </c:when>

                                            <%-- Thể loại 3: VĂN BẢN (ARTICLE) --%>
                                            <c:otherwise>
                                                <div style="background:#fff; border:1px solid #E2E8F0; border-radius:8px; padding:12px;">
                                                    <strong>Nội dung văn bản của bài học mới:</strong>
                                                    <div style="white-space:pre-wrap; margin-top:6px; color:#1E293B; max-height:240px; overflow-y:auto;"><c:out value="${not empty nl.content ? nl.content : '(Chưa có nội dung văn bản)'}"/></div>
                                                </div>
                                            </c:otherwise>
                                        </c:choose>

                                        <%-- Tài liệu đính kèm trong bài học mới (nếu có) --%>
                                        <c:if test="${not empty nl.materials}">
                                            <div style="margin-top:10px; background:#fff; border:1px solid #E2E8F0; border-radius:8px; padding:10px 12px;">
                                                <strong>Tài liệu đính kèm trong bài học mới (${nl.materials.size()}):</strong>
                                                <c:forEach var="m" items="${nl.materials}">
                                                    <div style="margin-top:4px; font-size:.82rem;">
                                                        - [<c:out value="${m.type}"/>] <strong><c:out value="${m.title}"/></strong> —
                                                        <c:choose>
                                                            <c:when test="${m.fileExists}">
                                                                <a href="<c:out value='${m.fileUrl}'/>" target="_blank" rel="noopener" style="color:#2563EB; font-weight:700;">Xem / Tải tài liệu</a>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span style="color:#DC2626; font-weight:700;">Tài nguyên không còn tồn tại</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </div>
                                                </c:forEach>
                                            </div>
                                        </c:if>
                                    </div>
                                </div>
                            </c:when>

                            <%-- TRƯỜNG HỢP CHỈNH SỬA KHÓA HỌC / CHƯƠNG HỌC / CẬP NHẬT BỔ SUNG BÀI HỌC ĐÃ CÓ: CHỈ HIỂN THỊ "PHẦN ĐÃ CHỈNH SỬA" --%>
                            <c:when test="${not empty log.fieldDiffs}">
                                <table class="ccl-diff-table">
                                    <thead>
                                        <tr>
                                            <th style="width:22%;">Phần đã chỉnh sửa</th>
                                            <th style="width:39%;">Trước khi sửa</th>
                                            <th style="width:39%;">Sau khi sửa</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="diff" items="${log.fieldDiffs}">
                                            <c:if test="${diff.changed}">
                                                <tr>
                                                    <td style="font-weight:700; color:#1E293B;"><c:out value="${diff.fieldLabel}"/></td>
                                                    <td class="ccl-before">
                                                        <c:if test="${diff.fieldKey eq 'thumbnailUrl' and not empty diff.beforeValue}">
                                                            <img src="<c:out value='${diff.beforeValue}'/>" alt="Ảnh bìa cũ" class="ccl-thumb-preview" onerror="this.style.display='none'"/>
                                                        </c:if>
                                                        <c:out value="${not empty diff.beforeValue ? diff.beforeValue : '(Trống)'}"/>
                                                    </td>
                                                    <td class="ccl-after">
                                                        <c:if test="${diff.fieldKey eq 'thumbnailUrl' and not empty diff.afterValue}">
                                                            <img src="<c:out value='${diff.afterValue}'/>" alt="Ảnh bìa mới" class="ccl-thumb-preview" onerror="this.style.display='none'"/>
                                                        </c:if>
                                                        <c:out value="${not empty diff.afterValue ? diff.afterValue : '(Đã xóa)'}"/>
                                                    </td>
                                                </tr>
                                            </c:if>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </c:when>
                        </c:choose>
                    </div>
                </c:forEach>

                <!-- Pagination -->
                <c:if test="${logsPage.totalPages > 1}">
                    <div style="display:flex; justify-content:center; gap:8px; margin-top:20px; flex-wrap:wrap;">
                        <c:forEach begin="0" end="${logsPage.totalPages - 1}" var="p">
                            <a href="${pageContext.request.contextPath}/admin/course-change-logs?page=${p}&amp;size=${logsPage.size}&amp;courseId=${selectedCourseId}&amp;teacherId=${selectedTeacherId}&amp;entityType=${selectedEntityType}&amp;actionType=${selectedActionType}&amp;fromDate=${fromDate}&amp;toDate=${toDate}&amp;q=${fn:escapeXml(q)}"
                               style="padding:6px 12px; border-radius:6px; font-size:.84rem; font-weight:700; text-decoration:none; border:1px solid ${p == logsPage.number ? '#2563EB' : '#CBD5E1'}; background:${p == logsPage.number ? '#2563EB' : '#fff'}; color:${p == logsPage.number ? '#fff' : '#334155'};">
                                ${p + 1}
                            </a>
                        </c:forEach>
                    </div>
                </c:if>
            </c:otherwise>
        </c:choose>

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
</script>
</body>
</html>
