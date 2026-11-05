<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Course Builder: <c:out value="${course.title}"/> — EduSphere</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/instructor.css">
    <style>
        .builder-topbar {
            display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap;
            gap: 16px; background: #fff; padding: 18px 24px; border-radius: var(--r12);
            border: 1px solid #E2E8F0; margin-bottom: 24px; box-shadow: 0 1px 3px rgba(0,0,0,.04);
        }
        .builder-tabs {
            display: flex; gap: 8px; border-bottom: 2px solid #E2E8F0; margin-bottom: 24px;
        }
        .builder-tab {
            padding: 10px 18px; font-weight: 700; font-size: .88rem; color: #64748B;
            border-bottom: 2px solid transparent; margin-bottom: -2px; cursor: pointer;
            text-decoration: none; display: inline-flex; align-items: center; gap: 8px;
        }
        .builder-tab.active {
            color: #2563EB; border-bottom-color: #2563EB; background: #EFF6FF; border-radius: 6px 6px 0 0;
        }

        /* Section card */
        .section-card {
            background: #fff; border: 1.5px solid #E2E8F0; border-radius: var(--r12);
            margin-bottom: 18px; overflow: hidden; transition: border-color .2s;
        }
        .section-card:hover { border-color: #CBD5E1; }
        .section-header {
            background: #F8FAFC; padding: 14px 20px; display: flex; justify-content: space-between;
            align-items: center; flex-wrap: wrap; gap: 12px; border-bottom: 1px solid #E2E8F0;
        }
        .section-title {
            font-size: 1rem; font-weight: 800; color: #0F172A; display: flex; align-items: center; gap: 10px;
        }
        .section-actions {
            display: flex; align-items: center; gap: 8px;
        }
        .section-body {
            padding: 16px 20px;
        }

        .lesson-row {
            display: flex; align-items: center; justify-content: space-between;
            background: #fff; border: 1px solid #E2E8F0; border-radius: var(--r8);
            padding: 12px 16px; margin-bottom: 10px; transition: all .2s;
        }
        .lesson-row:hover { background: #F8FAFC; border-color: #CBD5E1; }
        .lesson-row__left {
            display: flex; align-items: center; gap: 12px; flex: 1;
        }
        .lesson-type-badge {
            font-size: .72rem; font-weight: 700; padding: 3px 8px; border-radius: 4px; text-transform: uppercase;
        }
        .badge-video { background: #DBEAFE; color: #1D4ED8; }
        .badge-article { background: #FEF3C7; color: #B45309; }
        .badge-quiz { background: #F3E8FF; color: #7E22CE; }
        .badge-preview { background: #DCFCE7; color: #15803D; font-weight: 700; }

        /* Modal */
        .modal-overlay {
            position: fixed; inset: 0; background: rgba(0,0,0,.45); display: none;
            align-items: center; justify-content: center; z-index: 1000;
        }
        .modal-overlay.open { display: flex; }
        .modal-card {
            background: #fff; width: 100%; max-width: 520px; border-radius: var(--r12);
            padding: 24px; box-shadow: 0 10px 25px rgba(0,0,0,.15);
        }
    </style>
</head>
<body>
<div class="ins-layout">
<jsp:include page="/WEB-INF/views/courses/ins-sidebar.jsp"/>
<div class="ins-main-wrapper">
<jsp:include page="/WEB-INF/views/courses/ins-header.jsp"/>
    <main class="ins-page">

        <c:if test="${not empty success}"><div class="ins-alert ins-alert--success">✅ <c:out value="${success}"/></div></c:if>
        <c:if test="${not empty error}"><div class="ins-alert ins-alert--error">❌ <c:out value="${error}"/></div></c:if>

        <!-- Builder Top Bar -->
        <div class="builder-topbar">
            <div>
                <div style="display:flex; align-items:center; gap:10px; margin-bottom:4px;">
                    <c:choose>
                        <c:when test="${course.hidden}">              <span class="ins-status-badge ins-status-badge--hidden">Tạm ẩn</span></c:when>
                        <c:when test="${course.status=='DRAFT'}">     <span class="ins-status-badge ins-status-badge--draft">Bản nháp</span></c:when>
                        <c:when test="${course.status=='SUBMITTED'}"> <span class="ins-status-badge ins-status-badge--submitted">Chờ duyệt</span></c:when>
                        <c:when test="${course.status=='UPDATING'}">  <span class="ins-status-badge ins-status-badge--submitted" style="background:#FEF3C7;color:#92400E;border-color:#FDE68A;">🔄 Đang cập nhật</span></c:when>
                        <c:when test="${course.status=='APPROVED'}">  <span class="ins-status-badge ins-status-badge--approved">Đã duyệt</span></c:when>
                        <c:when test="${course.status=='PUBLISHED'}"> <span class="ins-status-badge ins-status-badge--published">Đã công bố</span></c:when>
                        <c:when test="${course.status=='REJECTED'}">  <span class="ins-status-badge ins-status-badge--rejected">Cần chỉnh sửa</span></c:when>
                        <c:otherwise>                                 <span class="ins-status-badge ins-status-badge--archived">Đã lưu trữ</span></c:otherwise>
                    </c:choose>
                    <span style="font-size:.85rem; color:#64748B; font-weight:600;">Phiên bản v<c:out value="${course.versionNo}"/></span>
                </div>
                <h1 style="margin:0; font-size:1.45rem; font-weight:900; color:var(--ink);"><c:out value="${course.title}"/></h1>
            </div>

            <!-- Preview & Action shortcuts -->
            <div style="display:flex; gap:10px; align-items:center; flex-wrap:wrap;">
                <!-- Bước 5: Xem trước với tư cách học viên -->
                <a class="ins-btn-outline" style="display:inline-flex; align-items:center; gap:6px; background:#F8FAFC;"
                   href="${pageContext.request.contextPath}/instructor/courses/${course.courseId}/preview" target="_blank">
                    👁️ Xem trước với tư cách học viên
                </a>
                <a class="ins-btn-outline" style="display:inline-flex; align-items:center; gap:6px; background:#F8FAFC;"
                   href="${pageContext.request.contextPath}/instructor/courses/${course.courseId}/assignments">
                    📝 Bài tập
                </a>
                <a class="ins-btn-outline" style="display:inline-flex; align-items:center; gap:6px; background:#F8FAFC;"
                   href="${pageContext.request.contextPath}/instructor/courses/${course.courseId}/quizzes">
                    ❓ Quiz
                </a>
                <a class="ins-btn-outline" style="display:inline-flex; align-items:center; gap:6px; background:#F8FAFC;"
                   href="${pageContext.request.contextPath}/instructor/courses/${course.courseId}/results">
                    📊 Kết quả
                </a>
                <a class="ins-btn-outline" style="display:inline-flex; align-items:center; gap:6px; background:#F8FAFC;"
                   href="${pageContext.request.contextPath}/instructor/courses/${course.courseId}/students/progress">
                    👥 Tiến độ học viên
                </a>

                <c:choose>
                    <c:when test="${course.status == 'DRAFT' || course.status == 'REJECTED'}">
                        <c:if test="${course.readyForSubmit}">
                            <form method="post" action="${pageContext.request.contextPath}/instructor/courses/${course.courseId}/submit" style="margin:0;">
                                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                <button class="ins-btn-primary" type="submit" style="padding:9px 18px; font-size:.88rem;">📤 Gửi duyệt cho Admin</button>
                            </form>
                        </c:if>
                    </c:when>
                    <c:when test="${course.status == 'UPDATING'}">
                        <c:if test="${course.readyForSubmit}">
                            <form method="post" action="${pageContext.request.contextPath}/instructor/courses/${course.courseId}/submit" style="margin:0;">
                                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                <input type="text" name="changeNote" maxlength="500"
                                       style="border:1.5px solid #FDE68A;border-radius:6px;padding:6px 10px;font-size:.82rem;width:220px;margin-right:6px;"
                                       placeholder="Chú thích thay đổi (tùy chọn)..."/>
                                <button class="ins-btn-primary" type="submit" style="padding:9px 18px; font-size:.88rem; background:#D97706;">📤 Gửi duyệt nội dung mới</button>
                            </form>
                        </c:if>
                    </c:when>
                    <c:when test="${course.status == 'APPROVED'}">
                        <form method="post" action="${pageContext.request.contextPath}/instructor/courses/${course.courseId}/publish" style="margin:0;">
                            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                            <button class="ins-btn-primary" type="submit" style="padding:9px 18px; font-size:.88rem;">🚀 Công bố khóa học</button>
                        </form>
                    </c:when>
                    <c:when test="${course.status == 'PUBLISHED'}">
                        <c:choose>
                            <c:when test="${course.hidden}">
                                <form method="post" action="${pageContext.request.contextPath}/instructor/courses/${course.courseId}/republish" style="margin:0;">
                                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                    <button class="ins-btn-primary" type="submit" style="padding:8px 16px; font-size:.85rem; background:#16a34a;">🚀 Tái công bố khóa học</button>
                                </form>
                            </c:when>
                            <c:otherwise>
                                <form method="post" action="${pageContext.request.contextPath}/instructor/courses/${course.courseId}/hide" style="margin:0;">
                                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                    <button class="ins-btn-outline" type="submit" style="color:#DC2626; border-color:#FCA5A5; padding:8px 14px; font-size:.85rem;">👁️ Tạm ẩn</button>
                                </form>
                            </c:otherwise>
                        </c:choose>
                    </c:when>
                </c:choose>
            </div>
        </div>

        <c:if test="${course.status == 'REJECTED' && not empty course.latestReviewComment}">
            <div class="ins-alert ins-alert--error" style="margin-bottom:20px;">
                ❌ <strong>Lý do từ chối phê duyệt từ Admin:</strong> <c:out value="${course.latestReviewComment}"/>
            </div>
        </c:if>

        <!-- Builder Tab navigation -->
        <div class="builder-tabs">
            <div class="builder-tab active" onclick="switchTab('curriculum')" id="tabBtn-curriculum">
                📚 Cấu trúc Chương & Bài học (${course.lessonCount})
            </div>
            <div class="builder-tab" onclick="switchTab('info')" id="tabBtn-info">
                📋 Thông tin chung & Media (Bước 1)
            </div>
            <div class="builder-tab" onclick="switchTab('publish')" id="tabBtn-publish">
                🚀 Xem trước & Xuất bản (Bước 5)
            </div>
        </div>

        <!-- ================= TAB 1: CURRICULUM BUILDER (BƯỚC 2, 3, 4) ================= -->
        <div id="tab-curriculum">
            <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:16px;">
                <div>
                    <h2 style="margin:0; font-size:1.15rem; font-weight:800;">Chương mục & Danh sách bài học</h2>
                    <p style="margin:2px 0 0; font-size:.85rem; color:#64748B;">Thiết lập các chương lớn và thêm bài giảng video, bài viết hoặc quiz vào từng chương.</p>
                </div>
                <div style="display:flex; gap:10px;">
                    <button class="ins-btn-primary" style="padding:9px 16px; font-size:.85rem;" onclick="openSectionModal()">
                        ➕ Thêm chương mới
                    </button>
                    <a class="ins-btn-outline" style="padding:9px 16px; font-size:.85rem;"
                       href="${pageContext.request.contextPath}/instructor/courses/${course.courseId}/lessons/new">
                        ➕ Thêm bài học mới
                    </a>
                </div>
            </div>

            <c:choose>
                <c:when test="${empty course.sections and empty lessons}">
                    <div style="background:#FFFBEB; border:1.5px solid #FDE68A; border-radius:var(--r12); padding:24px; text-align:center; margin-bottom:24px;">
                        <div style="font-size:2rem; margin-bottom:8px;">📁</div>
                        <h3 style="margin:0 0 6px; color:#B45309; font-weight:800;">Chưa có cấu trúc chương mục nào!</h3>
                        <p style="margin:0 0 16px; font-size:.88rem; color:#92400E; max-width:480px; margin-inline:auto;">
                            Bắt đầu bằng việc thêm <strong>Chương 1</strong>, sau đó thêm các bài học video, bài viết và tài liệu vào chương đó.
                        </p>
                        <button class="ins-btn-primary" style="display:inline-flex; width:auto; padding:9px 20px;" onclick="openSectionModal()">
                            ➕ Bắt đầu tạo Chương 1
                        </button>
                    </div>
                </c:when>

                <c:otherwise>
                    <!-- Iterate through sections -->
                    <c:forEach var="sec" items="${course.sections}" varStatus="sLoop">
                        <div class="section-card">
                            <div class="section-header">
                                <div class="section-title">
                                    <span style="background:#E2E8F0; width:26px; height:26px; border-radius:50%; display:inline-flex; align-items:center; justify-content:center; font-size:.8rem; font-weight:700;">
                                        ${sLoop.index + 1}
                                    </span>
                                    <span><c:out value="${sec.title}"/></span>
                                    <span style="font-size:.8rem; color:#64748B; font-weight:500;">(${sec.lessonCount} bài)</span>
                                </div>
                                <div class="section-actions">
                                    <c:if test="${not empty sec.sectionId}">
                                        <!-- Reorder section up/down -->
                                        <form method="post" action="${pageContext.request.contextPath}/instructor/courses/${course.courseId}/sections/${sec.sectionId}/move" style="display:inline; margin:0;">
                                            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                            <input type="hidden" name="direction" value="up">
                                            <button class="ins-link-btn" title="Chuyển lên trên" style="padding:4px 8px; font-size:.8rem;">▲</button>
                                        </form>
                                        <form method="post" action="${pageContext.request.contextPath}/instructor/courses/${course.courseId}/sections/${sec.sectionId}/move" style="display:inline; margin:0;">
                                            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                            <input type="hidden" name="direction" value="down">
                                            <button class="ins-link-btn" title="Chuyển xuống dưới" style="padding:4px 8px; font-size:.8rem;">▼</button>
                                        </form>

                                        <!-- Edit section modal trigger -->
                                        <button type="button" class="ins-link-btn" style="padding:4px 8px; font-size:.8rem;"
                                                data-section-id="${sec.sectionId}"
                                                data-section-title="<c:out value='${sec.title}'/>"
                                                data-section-desc="<c:out value='${sec.description}'/>"
                                                onclick="openEditSectionModalFromBtn(this)">
                                            ✏️ Sửa
                                        </button>

                                        <!-- Delete section -->
                                        <form method="post" action="${pageContext.request.contextPath}/instructor/courses/${course.courseId}/sections/${sec.sectionId}/delete"
                                              style="display:inline; margin:0;" onsubmit="return confirm('Bạn có chắc muốn xóa chương này? Các bài học bên trong sẽ không bị mất mà chuyển ra mục chung.');">
                                            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                            <button class="ins-link-btn" style="color:#DC2626; padding:4px 8px; font-size:.8rem;">🗑️ Xóa</button>
                                        </form>

                                        <a class="ins-btn-outline" style="padding:5px 12px; font-size:.8rem; display:inline-flex;"
                                           href="${pageContext.request.contextPath}/instructor/courses/${course.courseId}/lessons/new?sectionId=${sec.sectionId}">
                                            ➕ Thêm bài học
                                        </a>
                                    </c:if>
                                </div>
                            </div>

                            <div class="section-body">
                                <c:if test="${not empty sec.description}">
                                    <p style="margin:0 0 12px; font-size:.85rem; color:#64748B;"><c:out value="${sec.description}"/></p>
                                </c:if>

                                <c:choose>
                                    <c:when test="${empty sec.lessons}">
                                        <div style="background:#F8FAFC; border:1px dashed #CBD5E1; border-radius:6px; padding:12px; text-align:center; font-size:.82rem; color:#64748B;">
                                            Chưa có bài học nào trong chương này.
                                            <a href="${pageContext.request.contextPath}/instructor/courses/${course.courseId}/lessons/new?sectionId=${sec.sectionId}" style="color:#2563EB; font-weight:600; margin-left:4px;">
                                                + Thêm bài học ngay
                                            </a>
                                        </div>
                                    </c:when>
                                    <c:otherwise>
                                        <c:forEach var="les" items="${sec.lessons}">
                                            <div class="lesson-row">
                                                <div class="lesson-row__left">
                                                    <!-- Type Badge -->
                                                    <c:choose>
                                                        <c:when test="${les.lessonType eq 'VIDEO'}">
                                                            <span class="lesson-type-badge badge-video">🎥 Video ${not empty les.videoDuration ? les.videoDuration : ''}m</span>
                                                        </c:when>
                                                        <c:when test="${les.lessonType eq 'QUIZ'}">
                                                            <span class="lesson-type-badge badge-quiz">📝 Quiz</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="lesson-type-badge badge-article">📄 Văn bản</span>
                                                        </c:otherwise>
                                                    </c:choose>

                                                    <!-- Preview badge -->
                                                    <c:if test="${les.isPreview}">
                                                        <span class="lesson-type-badge badge-preview">👁️ Xem thử miễn phí</span>
                                                    </c:if>
                                                    <c:if test="${not empty les.unlockDaysAfterEnroll and les.unlockDaysAfterEnroll > 0}">
                                                        <span class="lesson-type-badge" style="background:#FEF9C3; color:#A16207;">⏳ Sau ${les.unlockDaysAfterEnroll} ngày</span>
                                                    </c:if>

                                                    <div>
                                                        <a href="${pageContext.request.contextPath}/instructor/courses/${course.courseId}/lessons/${les.lessonId}"
                                                           style="font-weight:700; color:var(--ink); text-decoration:none;">
                                                            <c:out value="${les.title}"/>
                                                        </a>
                                                        <c:if test="${les.lessonType ne 'QUIZ' and (empty les.content or les.content.trim().length() == 0) and (empty les.videoUrl or les.videoUrl.trim().length() == 0)}">
                                                            <span style="font-size:.72rem; color:#DC2626; margin-left:6px; font-weight:700;">(Chưa có nội dung)</span>
                                                        </c:if>
                                                    </div>
                                                </div>

                                                <div style="display:flex; align-items:center; gap:8px;">
                                                    <c:choose>
                                                        <c:when test="${les.lessonType eq 'QUIZ'}">
                                                            <%-- Quiz lesson: link to quiz management --%>
                                                            <a class="ins-link-btn ins-link-btn--primary"
                                                               href="${pageContext.request.contextPath}/instructor/courses/${course.courseId}/quizzes?lessonId=${les.lessonId}"
                                                               style="font-size:.8rem; background:#7E22CE; border-color:#7E22CE; color:#fff;">
                                                                📝 Quản lý Quiz →
                                                            </a>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <a class="ins-link-btn" href="${pageContext.request.contextPath}/instructor/courses/${course.courseId}/lessons/${les.lessonId}" style="font-size:.8rem;">
                                                                Chi tiết & File →
                                                            </a>
                                                        </c:otherwise>
                                                    </c:choose>
                                                    <a class="ins-link-btn" href="${pageContext.request.contextPath}/instructor/courses/${course.courseId}/lessons/${les.lessonId}/edit" style="font-size:.8rem;">
                                                        ✏️ Sửa
                                                    </a>
                                                    <form method="post" action="${pageContext.request.contextPath}/instructor/courses/${course.courseId}/lessons/${les.lessonId}/delete"
                                                          style="display:inline; margin:0;" onsubmit="return confirm('Bạn có chắc muốn xóa bài học này?');">
                                                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                                        <button class="ins-link-btn" style="color:#DC2626; font-size:.8rem;" type="submit">🗑️</button>
                                                    </form>
                                                </div>
                                            </div>
                                        </c:forEach>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                    </c:forEach>
                </c:otherwise>
            </c:choose>

            <!-- UC39 Student Progress Banner -->
            <div style="background:#F8FAFC; border:1px solid #E2E8F0; border-radius:var(--r12); padding:18px 22px; display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:12px; margin-top:28px;">
                <div>
                    <div style="font-weight:700; color:var(--ink); font-size:1rem;">Theo dõi tiến độ học viên trong khóa (UC39)</div>
                    <div style="font-size:.85rem; color:#64748B; margin-top:2px;">Xem danh sách học viên, tỷ lệ hoàn thành, số bài học đã học và mốc truy cập.</div>
                </div>
                <a class="ins-btn-primary" style="width:auto; padding:9px 18px; font-size:.88rem; text-decoration:none;"
                   href="${pageContext.request.contextPath}/instructor/courses/${course.courseId}/students">
                    📊 Xem tiến độ học viên →
                </a>
            </div>
        </div>

        <!-- ================= TAB 2: THÔNG TIN CHUNG (BƯỚC 1 REVIEW) ================= -->
        <div id="tab-info" style="display:none;">
            <div class="ins-detail-main__body" style="background:#fff; border-radius:var(--r12); border:1px solid #E2E8F0; padding:24px;">
                <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:16px;">
                    <h2 style="margin:0;">Thông tin chi tiết khóa học</h2>
                    <a class="ins-btn-outline" href="${pageContext.request.contextPath}/instructor/courses/${course.courseId}/edit">
                        ✏️ Chỉnh sửa thông tin cơ bản
                    </a>
                </div>

                <div style="display:grid; grid-template-columns:repeat(auto-fit, minmax(280px, 1fr)); gap:20px; margin-bottom:20px;">
                    <c:if test="${not empty course.thumbnailUrl}">
                        <c:set var="detailThumbSrc" value="${course.thumbnailUrl}"/>
                        <c:if test="${not fn:startsWith(detailThumbSrc, 'http://') and not fn:startsWith(detailThumbSrc, 'https://') and not fn:startsWith(detailThumbSrc, pageContext.request.contextPath)}">
                            <c:set var="detailThumbSrc" value="${pageContext.request.contextPath}${course.thumbnailUrl}"/>
                        </c:if>
                        <div style="border-radius:var(--r8); overflow:hidden; border:1px solid #E2E8F0;">
                            <img src="<c:out value='${detailThumbSrc}'/>" alt="Thumbnail" style="width:100%; height:180px; object-fit:cover; display:block;"/>
                            <div style="padding:8px 12px; font-size:.8rem; color:#64748B; background:#F8FAFC; text-align:center;">Ảnh bìa (Thumbnail)</div>
                        </div>
                    </c:if>

                    <table class="ins-info-table" style="margin:0;">
                        <tr>
                            <th>Danh mục</th>
                            <td><c:out value="${course.categoryName}" default="Chưa phân loại"/></td>
                        </tr>
                        <tr>
                            <th>Trình độ</th>
                            <td><c:choose>
                                <c:when test="${course.level=='BEGINNER'}">Cơ bản</c:when>
                                <c:when test="${course.level=='INTERMEDIATE'}">Trung cấp</c:when>
                                <c:when test="${course.level=='ADVANCED'}">Nâng cao</c:when>
                                <c:otherwise>Mọi trình độ</c:otherwise>
                            </c:choose></td>
                        </tr>
                        <tr>
                            <th>Học phí</th>
                            <td>
                                <c:choose>
                                    <c:when test="${course.price == 0}"><span style="color:#16A34A;font-weight:700">Miễn phí</span></c:when>
                                    <c:otherwise><fmt:formatNumber value="${course.price}" type="number" maxFractionDigits="0"/>đ</c:otherwise>
                                </c:choose>
                            </td>
                        </tr>
                        <tr>
                            <th>Video giới thiệu</th>
                            <td>
                                <c:choose>
                                    <c:when test="${not empty course.promoVideoUrl}"><a href="<c:out value='${course.promoVideoUrl}'/>" target="_blank" style="color:#2563EB;">Xem video trailer ↗</a></c:when>
                                    <c:otherwise><span style="color:#94A3B8;">Chưa có video trailer</span></c:otherwise>
                                </c:choose>
                            </td>
                        </tr>
                    </table>
                </div>

                <h3>Mô tả khóa học</h3>
                <p class="ins-detail-desc"><c:out value="${course.description}" default="Chưa có mô tả."/></p>

                <c:if test="${not empty course.objectives}">
                    <h3 style="margin-top:20px;">Mục tiêu đầu ra (What students will learn)</h3>
                    <div style="background:#F0FDF4; border:1px solid #BBF7D0; border-radius:var(--r8); padding:14px 18px; font-size:.9rem; color:#166534; white-space:pre-line;"><c:out value="${course.objectives}"/></div>
                </c:if>

                <c:if test="${not empty course.requirements}">
                    <h3 style="margin-top:20px;">Yêu cầu đầu vào (Requirements / Prerequisites)</h3>
                    <div style="background:#F8FAFC; border:1px solid #E2E8F0; border-radius:var(--r8); padding:14px 18px; font-size:.9rem; color:#334155; white-space:pre-line;"><c:out value="${course.requirements}"/></div>
                </c:if>
            </div>
        </div>

        <!-- ================= TAB 3: XUẤT BẢN & XEM TRƯỚC (BƯỚC 5) ================= -->
        <div id="tab-publish" style="display:none;">
            <div style="background:#fff; border-radius:var(--r12); border:1px solid #E2E8F0; padding:24px;">
                <h2 style="margin:0 0 8px;">Kiểm tra độ sẵn sàng & Xuất bản (Bước 5)</h2>
                <p style="color:#64748B; font-size:.88rem; margin:0 0 20px;">
                    Trước khi gửi duyệt hoặc công bố khóa học, hãy chắc chắn rằng bạn đã xem trước giao diện học viên và khóa học đáp ứng các tiêu chuẩn chất lượng.
                </p>

                <!-- Readiness Checklist -->
                <div style="background:#F8FAFC; border:1px solid #E2E8F0; border-radius:var(--r8); padding:18px 20px; margin-bottom:24px;">
                    <div style="font-weight:800; font-size:.95rem; margin-bottom:12px; color:var(--ink);">Bảng kiểm tra điều kiện (Readiness Checklist):</div>
                    <ul style="list-style:none; padding:0; margin:0; display:flex; flex-direction:column; gap:8px; font-size:.88rem;">
                        <li>
                            <c:choose>
                                <c:when test="${not empty course.title}">✅ <strong>Tên khóa học:</strong> Đã điền</c:when>
                                <c:otherwise>❌ <strong>Tên khóa học:</strong> Còn trống</c:otherwise>
                            </c:choose>
                        </li>
                        <li>
                            <c:choose>
                                <c:when test="${not empty course.description}">✅ <strong>Mô tả khóa học:</strong> Đã hoàn thiện</c:when>
                                <c:otherwise>❌ <strong>Mô tả khóa học:</strong> Còn trống</c:otherwise>
                            </c:choose>
                        </li>
                        <li>
                            <c:choose>
                                <c:when test="${course.lessonCount > 0}">✅ <strong>Nội dung bài học:</strong> Có ${course.lessonCount} bài học</c:when>
                                <c:otherwise>❌ <strong>Nội dung bài học:</strong> Chưa có bài học nào (cần ít nhất 1 bài)</c:otherwise>
                            </c:choose>
                        </li>
                        <li>
                            <c:choose>
                                <c:when test="${course.readyForSubmit}">✅ <strong>Tính toàn vẹn:</strong> Tất cả bài học đều có nội dung hợp lệ</c:when>
                                <c:otherwise>⚠️ <strong>Tính toàn vẹn:</strong> Cần hoàn thiện tiêu đề hoặc nội dung các bài học</c:otherwise>
                            </c:choose>
                        </li>
                    </ul>
                </div>

                <!-- Preview CTA -->
                <div style="background:#EFF6FF; border:1.5px solid #BFDBFE; border-radius:var(--r12); padding:20px; display:flex; align-items:center; justify-content:space-between; flex-wrap:wrap; gap:16px; margin-bottom:24px;">
                    <div>
                        <div style="font-weight:800; font-size:1.05rem; color:#1E40AF;">👁️ Trải nghiệm thực tế với tư cách học viên (Preview Mode)</div>
                        <div style="font-size:.85rem; color:#1D4ED8; margin-top:2px;">Kiểm tra trực tiếp video phát mượt không, định dạng văn bản code highlight và link tải tài liệu.</div>
                    </div>
                    <a class="ins-btn-primary" style="background:#2563EB; width:auto; padding:10px 22px; font-size:.9rem;"
                       href="${pageContext.request.contextPath}/instructor/courses/${course.courseId}/preview" target="_blank">
                        Xem trước khóa học ↗
                    </a>
                </div>

                <!-- Publishing Actions -->
                <div style="border-top:1px solid #E2E8F0; padding-top:20px;">
                    <h3>Hành động xuất bản</h3>
                    <c:choose>
                        <c:when test="${course.status == 'DRAFT' || course.status == 'REJECTED'}">
                            <p style="font-size:.88rem; color:#64748B;">Khóa học đang ở bản nháp. Sau khi hoàn thiện, hãy gửi lên ban quản trị xét duyệt.</p>
                            <c:choose>
                                <c:when test="${course.readyForSubmit}">
                                    <form method="post" action="${pageContext.request.contextPath}/instructor/courses/${course.courseId}/submit" style="margin:0;">
                                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                        <button class="ins-btn-primary" type="submit" style="width:auto; padding:10px 24px;">📤 Gửi duyệt cho Admin</button>
                                    </form>
                                </c:when>
                                <c:otherwise>
                                    <button class="ins-btn-disabled" type="button" disabled>📤 Gửi duyệt (Chưa đủ điều kiện hoàn thành)</button>
                                </c:otherwise>
                            </c:choose>
                        </c:when>

                        <c:when test="${course.status == 'UPDATING'}">
                            <div class="ins-alert ins-alert--warning" style="margin-bottom:14px;">
                                🔄 <strong>Khóa học đang được cập nhật nội dung mới.</strong><br/>
                                Học viên vẫn đang học bình thường với các bài đã công bố trước đó.<br/>
                                Sau khi hoàn thiện nội dung mới, hãy gửi Admin duyệt để công bố.
                            </div>
                            <c:choose>
                                <c:when test="${course.readyForSubmit}">
                                    <form method="post" action="${pageContext.request.contextPath}/instructor/courses/${course.courseId}/submit" style="margin:0;">
                                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                        <div style="margin-bottom:10px;">
                                            <label style="font-size:.8rem;font-weight:700;color:#92400E;display:block;margin-bottom:4px;">
                                                📝 Chú thích thay đổi cho Admin (tùy chọn)
                                            </label>
                                            <textarea name="changeNote" rows="3" maxlength="500"
                                                      style="width:100%;box-sizing:border-box;border:1.5px solid #FDE68A;border-radius:6px;padding:8px 10px;font-size:.83rem;font-family:inherit;resize:vertical;"
                                                      placeholder="VD: Thêm bài 3 về vòng lặp, cập nhật nội dung bài 1, bổ sung tài liệu..."></textarea>
                                        </div>
                                        <button class="ins-btn-primary" type="submit" style="width:auto; padding:10px 24px; background:#D97706;">📤 Gửi duyệt nội dung mới</button>
                                    </form>
                                </c:when>
                                <c:otherwise>
                                    <button class="ins-btn-disabled" type="button" disabled>📤 Gửi duyệt (Chưa đủ điều kiện)</button>
                                </c:otherwise>
                            </c:choose>
                        </c:when>

                        <c:when test="${course.status == 'SUBMITTED'}">
                            <div class="ins-alert ins-alert--warning">
                                ⏳ Khóa học đang được ban quản trị kiểm duyệt. Vui lòng đợi thông báo phản hồi từ hệ thống.
                            </div>
                        </c:when>

                        <c:when test="${course.status == 'APPROVED'}">
                            <div style="background:#F0FDF4; border:1px solid #86EFAC; border-radius:var(--r8); padding:16px; margin-bottom:16px;">
                                <p style="margin:0 0 10px; font-weight:700; color:#166534;">🎉 Chúc mừng! Khóa học đã được phê duyệt. Bạn có thể công bố ngay để mở bán.</p>
                                <form method="post" action="${pageContext.request.contextPath}/instructor/courses/${course.courseId}/publish" style="margin:0;">
                                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                    <button class="ins-btn-primary" type="submit" style="width:auto; padding:10px 24px;">🚀 Công bố khóa học ngay</button>
                                </form>
                            </div>
                        </c:when>

                        <c:when test="${course.status == 'PUBLISHED'}">
                            <div style="background:#F0FDF4; border:1px solid #86EFAC; border-radius:var(--r8); padding:16px; margin-bottom:16px;">
                                <p style="margin:0 0 10px; font-weight:700; color:#166534;">🌟 Khóa học đang được công bố công khai trên hệ thống.</p>
                                <div style="display:flex; gap:10px;">
                                    <form method="post" action="${pageContext.request.contextPath}/instructor/courses/${course.courseId}/hide" style="margin:0;">
                                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                        <button class="ins-btn-outline" type="submit" style="color:#DC2626; border-color:#FCA5A5;">👁️ Tạm ẩn khóa học</button>
                                    </form>
                                    <form method="post" action="${pageContext.request.contextPath}/instructor/courses/${course.courseId}/archive" style="margin:0;">
                                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                        <button class="ins-btn-outline" type="submit">📦 Lưu trữ khóa học</button>
                                    </form>
                                </div>
                            </div>
                        </c:when>
                    </c:choose>
                </div>
            </div>
        </div>

        <!-- Section Create / Edit Modal -->
        <div class="modal-overlay" id="sectionModal">
            <div class="modal-card">
                <h3 id="modalTitle" style="margin:0 0 14px; font-size:1.15rem; font-weight:800; color:var(--ink);">Thêm chương mới</h3>
                <form id="sectionForm" method="post" action="${pageContext.request.contextPath}/instructor/courses/${course.courseId}/sections">
                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                    <div class="ins-field" style="margin-bottom:14px;">
                        <label for="secTitle">Tên chương <span style="color:#EF4444">*</span></label>
                        <input type="text" name="title" id="secTitle" required maxlength="255" placeholder="VD: Chương 1: Giới thiệu tổng quan & Môi trường lập trình"/>
                    </div>
                    <div class="ins-field" style="margin-bottom:18px;">
                        <label for="secDesc">Mô tả chương (Tùy chọn)</label>
                        <textarea name="description" id="secDesc" rows="3" placeholder="Mô tả tóm tắt nội dung các bài học trong chương..."></textarea>
                    </div>
                    <div style="display:flex; justify-content:flex-end; gap:10px;">
                        <button type="button" class="ins-btn-outline" onclick="closeSectionModal()">Hủy</button>
                        <button type="submit" class="ins-btn-primary" style="width:auto; padding:8px 18px;">Lưu chương</button>
                    </div>
                </form>
            </div>
        </div>

    </main>
</div>
</div>

<script>
function insToggleMenu(e){e.stopPropagation();document.getElementById('insUserMenu').classList.toggle('open');}
document.addEventListener('click',function(){var m=document.getElementById('insUserMenu');if(m)m.classList.remove('open');});

function switchTab(tabId) {
    document.querySelectorAll('.builder-tab').forEach(function(b){ b.classList.remove('active'); });
    document.getElementById('tab-curriculum').style.display = 'none';
    document.getElementById('tab-info').style.display = 'none';
    document.getElementById('tab-publish').style.display = 'none';

    document.getElementById('tabBtn-' + tabId).classList.add('active');
    document.getElementById('tab-' + tabId).style.display = 'block';
}

function openSectionModal() {
    document.getElementById('modalTitle').textContent = 'Thêm chương mới (Bước 2)';
    document.getElementById('secTitle').value = '';
    document.getElementById('secDesc').value = '';
    document.getElementById('sectionForm').action = '${pageContext.request.contextPath}/instructor/courses/${course.courseId}/sections';
    document.getElementById('sectionModal').classList.add('open');
}

function openEditSectionModalFromBtn(btn) {
    if (!btn) return;
    openEditSectionModal(
        btn.getAttribute('data-section-id'),
        btn.getAttribute('data-section-title') || '',
        btn.getAttribute('data-section-desc') || ''
    );
}

function openEditSectionModal(secId, title, desc) {
    if (secId && typeof secId === 'object' && secId.getAttribute) {
        var btn = secId;
        secId = btn.getAttribute('data-section-id');
        title = btn.getAttribute('data-section-title') || '';
        desc = btn.getAttribute('data-section-desc') || '';
    }
    document.getElementById('modalTitle').textContent = 'Chỉnh sửa chương mục';
    document.getElementById('secTitle').value = title;
    document.getElementById('secDesc').value = desc || '';
    document.getElementById('sectionForm').action = '${pageContext.request.contextPath}/instructor/courses/${course.courseId}/sections/' + secId + '/edit';
    document.getElementById('sectionModal').classList.add('open');
}

function closeSectionModal() {
    document.getElementById('sectionModal').classList.remove('open');
}
</script>
</body>
</html>
