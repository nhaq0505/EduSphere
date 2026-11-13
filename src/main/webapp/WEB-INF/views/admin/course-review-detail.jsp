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
    <title>Chi tiết duyệt: <c:out value="${course.title}"/> — EduSphere Admin</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/home.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/admin.css">
    <style>
        /* ── Layout ── */
        .rev-layout {
            display: grid;
            grid-template-columns: 1fr 320px;
            gap: 24px;
            align-items: start;
        }
        @media (max-width: 960px) {
            .rev-layout { grid-template-columns: 1fr; }
        }

        /* ── Section block ── */
        .rev-section {
            background: #fff;
            border: 1px solid #E2E8F0;
            border-radius: 12px;
            padding: 20px 24px;
            margin-bottom: 20px;
        }
        .rev-section__title {
            font-size: .78rem;
            font-weight: 700;
            color: #94A3B8;
            text-transform: uppercase;
            letter-spacing: .06em;
            margin: 0 0 14px;
        }

        /* ── Info grid ── */
        .rev-info-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 14px 24px;
        }
        @media (max-width: 640px) {
            .rev-info-grid { grid-template-columns: 1fr; }
        }
        .rev-info-item__label {
            font-size: .75rem;
            font-weight: 600;
            color: #94A3B8;
            margin-bottom: 2px;
        }
        .rev-info-item__value {
            font-size: .9rem;
            font-weight: 600;
            color: #0F172A;
        }

        /* ── Curriculum ── */
        .rev-chapter {
            border: 1px solid #E2E8F0;
            border-radius: 10px;
            overflow: hidden;
            margin-bottom: 14px;
        }
        .rev-chapter__head {
            background: #F8FAFC;
            padding: 12px 16px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 10px;
        }
        .rev-chapter__name {
            font-weight: 700;
            font-size: .92rem;
            color: #0F172A;
        }
        .rev-chapter__count {
            font-size: .78rem;
            color: #64748B;
            font-weight: 500;
            white-space: nowrap;
        }
        .rev-lesson-list {
            list-style: none;
            margin: 0;
            padding: 0;
        }
        .rev-lesson-item {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 12px 16px;
            border-top: 1px solid #F1F5F9;
            font-size: .88rem;
            color: #334155;
            cursor: pointer;
            transition: background .15s;
        }
        .rev-lesson-item:hover {
            background: #F8FAFC;
        }
        .rev-lesson-item__icon { font-size: 1rem; flex-shrink: 0; }
        .rev-lesson-item__title { flex: 1; font-weight: 600; color: #0F172A; }
        .rev-lesson-item__badge {
            font-size: .7rem;
            font-weight: 700;
            padding: 2px 8px;
            border-radius: 20px;
            white-space: nowrap;
        }
        .rev-lesson-item__badge--draft {
            background: #FEF9C3;
            color: #854D0E;
            border: 1px solid #FDE047;
        }
        .rev-lesson-item__badge--updated {
            background: #DBEAFE;
            color: #1E40AF;
            border: 1px solid #93C5FD;
        }
        .rev-lesson-item--new {
            background: #FFFBEB;
            border-left: 3px solid #F59E0B;
        }
        .rev-lesson-item--updated {
            background: #EFF6FF;
            border-left: 3px solid #2563EB;
        }
        .rev-lesson-item__badge--published {
            background: #DCFCE7;
            color: #166534;
            border: 1px solid #86EFAC;
        }
        .rev-lesson-item__badge--preview {
            background: #EFF6FF;
            color: #1D4ED8;
            border: 1px solid #BFDBFE;
        }
        .rev-lesson-item__type {
            font-size: .72rem;
            color: #94A3B8;
            font-weight: 500;
        }
        .rev-lesson-toggle-btn {
            font-size: .75rem;
            font-weight: 700;
            color: #2563EB;
            background: #EFF6FF;
            border: 1px solid #BFDBFE;
            border-radius: 6px;
            padding: 4px 10px;
            cursor: pointer;
            white-space: nowrap;
        }
        .rev-lesson-detail-panel {
            display: none;
            padding: 16px 20px;
            background: #F8FAFC;
            border-top: 1px dashed #CBD5E1;
            font-size: .86rem;
            color: #1E293B;
        }
        .rev-lesson-detail-panel.open {
            display: block;
        }
        .rev-diff-table {
            width: 100%;
            border-collapse: collapse;
            font-size: .8rem;
            margin-top: 8px;
            background: #fff;
            border: 1px solid #E2E8F0;
            border-radius: 8px;
            overflow: hidden;
        }
        .rev-diff-table th, .rev-diff-table td {
            padding: 8px 10px;
            border-bottom: 1px solid #F1F5F9;
            text-align: left;
            vertical-align: top;
        }
        .rev-diff-table th {
            background: #F1F5F9;
            font-weight: 700;
            color: #475569;
        }
        .rev-diff-before {
            background: #FEF2F2;
            color: #991B1B;
            white-space: pre-wrap;
            word-break: break-word;
        }
        .rev-diff-after {
            background: #F0FDF4;
            color: #166534;
            white-space: pre-wrap;
            word-break: break-word;
        }

        /* ── Aside sticky ── */
        .rev-aside {
            position: sticky;
            top: 24px;
        }
        .rev-aside-card {
            background: #fff;
            border: 1px solid #E2E8F0;
            border-radius: 12px;
            overflow: hidden;
            margin-bottom: 16px;
        }
        .rev-aside-card__head {
            background: #0F172A;
            color: #fff;
            padding: 14px 18px;
            font-weight: 700;
            font-size: .88rem;
        }
        .rev-aside-card__body { padding: 16px 18px; }

        /* ── Buttons ── */
        .rev-btn-approve {
            display: block; width: 100%;
            background: #16A34A; color: #fff;
            border: none; border-radius: 8px;
            padding: 11px 18px; font-size: .9rem; font-weight: 700;
            cursor: pointer; text-align: center; margin-bottom: 10px;
            transition: background .15s;
        }
        .rev-btn-approve:hover { background: #15803D; }
        .rev-btn-reject {
            display: block; width: 100%;
            background: #DC2626; color: #fff;
            border: none; border-radius: 8px;
            padding: 11px 18px; font-size: .9rem; font-weight: 700;
            cursor: pointer; text-align: center;
            transition: background .15s;
        }
        .rev-btn-reject:hover { background: #B91C1C; }
        .rev-textarea {
            width: 100%; box-sizing: border-box;
            border: 1.5px solid #E2E8F0; border-radius: 8px;
            padding: 10px 12px; font-size: .87rem;
            font-family: inherit; resize: vertical;
            margin-bottom: 10px;
        }
        .rev-textarea:focus { outline: none; border-color: #3B82F6; }

        /* ── Thumbnail ── */
        .rev-thumbnail {
            width: 100%; aspect-ratio: 16/9;
            object-fit: cover; border-radius: 8px;
            background: #F1F5F9; display: block;
        }
        .rev-thumbnail-placeholder {
            width: 100%; aspect-ratio: 16/9;
            background: linear-gradient(135deg, #E0F2FE, #BAE6FD);
            border-radius: 8px; display: flex;
            align-items: center; justify-content: center;
            font-size: 2.5rem; color: #0369A1;
        }

        /* ── Content text ── */
        .rev-text-block {
            font-size: .88rem; line-height: 1.7;
            color: #334155; white-space: pre-wrap;
            overflow-wrap: anywhere;
        }
        .rev-empty { color: #94A3B8; font-style: italic; font-size: .85rem; }

        /* ── Version badge ── */
        .rev-version-badge {
            display: inline-flex; align-items: center; gap: 6px;
            background: #FEF3C7; color: #92400E;
            border: 1px solid #FDE68A; border-radius: 20px;
            padding: 3px 12px; font-size: .78rem; font-weight: 700;
            margin-bottom: 10px;
        }

        /* ── Back link ── */
        .rev-back {
            display: inline-flex; align-items: center; gap: 6px;
            color: #64748B; font-size: .85rem; font-weight: 600;
            text-decoration: none; margin-bottom: 20px;
        }
        .rev-back:hover { color: #0F172A; }

        /* ── Heading ── */
        .rev-page-title {
            font-size: 1.5rem; font-weight: 900;
            color: #0F172A; margin: 0 0 4px;
        }
        .rev-page-sub { font-size: .88rem; color: #64748B; margin: 0 0 20px; }
    </style>
</head>
<body>

<jsp:include page="/WEB-INF/views/admin/header.jsp"/>

<div class="adm-shell">
    <jsp:include page="/WEB-INF/views/admin/sidebar.jsp"/>

    <main class="adm-content">

        <c:set var="isResubmission" value="${isUpdateSubmission eq true}"/>

        <!-- Back -->
        <a class="rev-back" href="${pageContext.request.contextPath}/admin/courses/review">
            ← Danh sách chờ duyệt
        </a>

        <!-- Page heading -->
        <div style="display:flex; align-items:flex-start; justify-content:space-between; flex-wrap:wrap; gap:12px; margin-bottom:24px;">
            <div>
                <div class="rev-version-badge">
                    <c:choose>
                        <c:when test="${isResubmission}">Phiên bản v<c:out value="${course.versionNo}"/> · Cập nhật nội dung chờ duyệt</c:when>
                        <c:otherwise>Phiên bản v<c:out value="${course.versionNo}"/> · Chờ duyệt lần đầu</c:otherwise>
                    </c:choose>
                </div>
                <h1 class="rev-page-title"><c:out value="${course.title}"/></h1>
                <p class="rev-page-sub">
                    Giảng viên: <strong><c:out value="${course.instructorName}"/></strong>
                    <c:if test="${not empty course.categoryName}"> · Danh mục: <c:out value="${course.categoryName}"/></c:if>
                    · <strong>${course.lessonCount}</strong> bài học
                    · Học phí:
                    <c:choose>
                        <c:when test="${course.price == null or course.price <= 0}"><strong>Miễn phí</strong></c:when>
                        <c:otherwise><strong><fmt:formatNumber value="${course.price}" type="number" maxFractionDigits="0"/> VNĐ</strong></c:otherwise>
                    </c:choose>
                </p>
            </div>
            <c:if test="${isResubmission}">
                <div>
                    <a href="${pageContext.request.contextPath}/admin/course-change-logs/course/${course.courseId}"
                       style="display:inline-flex;align-items:center;gap:6px;background:#EFF6FF;color:#1D4ED8;border:1.5px solid #93C5FD;border-radius:8px;padding:9px 14px;font-size:.85rem;font-weight:700;text-decoration:none;">
                        Xem toàn bộ lịch sử thay đổi khóa học →
                    </a>
                </div>
            </c:if>
        </div>

        <!-- Previous rejection note -->
        <c:if test="${not empty course.latestReviewComment}">
            <div class="adm-alert" style="background:#FEF2F2;border:1px solid #FECACA;color:#991B1B;margin-bottom:20px;">
                <strong>Nhận xét lần duyệt trước:</strong> <c:out value="${course.latestReviewComment}"/>
            </div>
        </c:if>

        <!-- Instructor change note -->
        <c:if test="${not empty course.changeNote}">
            <div style="background:#EFF6FF;border:2px solid #3B82F6;border-radius:12px;padding:16px 20px;margin-bottom:20px;display:flex;gap:14px;align-items:flex-start;">
                <div>
                    <div style="font-weight:800;color:#1D4ED8;font-size:.9rem;margin-bottom:4px;">Chú thích từ Giảng viên về lần cập nhật này:</div>
                    <div style="color:#1E40AF;font-size:.92rem;line-height:1.6;white-space:pre-wrap;"><c:out value="${course.changeNote}"/></div>
                </div>
            </div>
        </c:if>

        <div class="rev-layout">

            <!-- ══ LEFT: Course content ══ -->
            <div>

                <!-- Thumbnail -->
                <div class="rev-section">
                    <p class="rev-section__title">Ảnh bìa khóa học</p>
                    <div style="max-width: 480px;">
                        <c:choose>
                            <c:when test="${not empty course.thumbnailUrl}">
                                <img src="<c:out value='${course.thumbnailUrl}'/>" alt="Thumbnail" class="rev-thumbnail">
                            </c:when>
                            <c:otherwise>
                                <div class="rev-thumbnail-placeholder" style="font-size:1rem;font-weight:600;">Chưa có ảnh bìa</div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>

                <!-- Basic info -->
                <div class="rev-section">
                    <p class="rev-section__title">Thông tin cơ bản</p>
                    <div class="rev-info-grid">
                        <div class="rev-info-item">
                            <div class="rev-info-item__label">Trình độ</div>
                            <div class="rev-info-item__value">
                                <c:choose>
                                    <c:when test="${course.level == 'BEGINNER'}">Cơ bản</c:when>
                                    <c:when test="${course.level == 'INTERMEDIATE'}">Trung cấp</c:when>
                                    <c:when test="${course.level == 'ADVANCED'}">Nâng cao</c:when>
                                    <c:otherwise>Tất cả trình độ</c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                        <div class="rev-info-item">
                            <div class="rev-info-item__label">Học phí</div>
                            <div class="rev-info-item__value">
                                <c:choose>
                                    <c:when test="${course.price == null or course.price <= 0}">Miễn phí</c:when>
                                    <c:otherwise><fmt:formatNumber value="${course.price}" type="number" maxFractionDigits="0"/> VNĐ</c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                        <div class="rev-info-item">
                            <div class="rev-info-item__label">Danh mục</div>
                            <div class="rev-info-item__value"><c:out value="${course.categoryName}"/></div>
                        </div>
                        <div class="rev-info-item">
                            <div class="rev-info-item__label">Số bài học</div>
                            <div class="rev-info-item__value">${course.lessonCount} bài</div>
                        </div>
                    </div>
                </div>

                <!-- Description -->
                <div class="rev-section">
                    <p class="rev-section__title">Mô tả khóa học</p>
                    <c:choose>
                        <c:when test="${not empty course.description}">
                            <div class="rev-text-block"><c:out value="${course.description}"/></div>
                        </c:when>
                        <c:otherwise><span class="rev-empty">Chưa có mô tả.</span></c:otherwise>
                    </c:choose>
                </div>

                <!-- Objectives & Requirements -->
                <c:if test="${not empty course.objectives or not empty course.requirements}">
                    <div class="rev-section">
                        <p class="rev-section__title">Mục tiêu &amp; Yêu cầu</p>
                        <div style="display:grid; grid-template-columns:1fr 1fr; gap:20px;">
                            <div>
                                <p style="font-size:.8rem;font-weight:700;color:#64748B;margin:0 0 6px;">Học viên sẽ học được</p>
                                <c:choose>
                                    <c:when test="${not empty course.objectives}">
                                        <div class="rev-text-block"><c:out value="${course.objectives}"/></div>
                                    </c:when>
                                    <c:otherwise><span class="rev-empty">Chưa điền.</span></c:otherwise>
                                </c:choose>
                            </div>
                            <div>
                                <p style="font-size:.8rem;font-weight:700;color:#64748B;margin:0 0 6px;">Yêu cầu đầu vào</p>
                                <c:choose>
                                    <c:when test="${not empty course.requirements}">
                                        <div class="rev-text-block"><c:out value="${course.requirements}"/></div>
                                    </c:when>
                                    <c:otherwise><span class="rev-empty">Chưa điền.</span></c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                    </div>
                </c:if>

                <!-- Curriculum -->
                <div class="rev-section">
                    <div style="display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:10px; margin-bottom:14px;">
                        <p class="rev-section__title" style="margin:0;">Cấu trúc khóa học &amp; Nội dung bài học (Bấm vào bài học để xem chi tiết)</p>
                        <button type="button" onclick="toggleAllLessons()" class="rev-lesson-toggle-btn" id="toggleAllLessonsBtn">
                            Mở rộng tất cả bài học
                        </button>
                    </div>

                    <c:choose>
                        <c:when test="${empty course.sections}">
                            <span class="rev-empty">Khóa học chưa có bài học nào.</span>
                        </c:when>
                        <c:otherwise>
                            <c:set var="newLessonCount" value="0"/>
                            <c:set var="updatedLessonCount" value="0"/>
                            <c:set var="publishedLessonCount" value="0"/>

                            <c:forEach var="section" items="${course.sections}">
                                <div class="rev-chapter">
                                    <div class="rev-chapter__head">
                                        <div>
                                            <span class="rev-chapter__name">
                                                <c:out value="${section.title}"/>
                                            </span>
                                            <c:if test="${not empty section.description}">
                                                <div style="font-size:.78rem;color:#64748B;margin-top:2px;"><c:out value="${section.description}"/></div>
                                            </c:if>
                                        </div>
                                        <span class="rev-chapter__count">${section.lessonCount} bài</span>
                                    </div>

                                    <c:choose>
                                        <c:when test="${empty section.lessons}">
                                            <div style="padding:12px 16px; font-size:.84rem; color:#94A3B8; font-style:italic;">Chưa có bài học trong chương này.</div>
                                        </c:when>
                                        <c:otherwise>
                                            <ul class="rev-lesson-list">
                                                <c:forEach var="lesson" items="${section.lessons}" varStatus="ls">
                                                    <c:set var="lRev" value="${lessonReviewMap[lesson.lessonId]}"/>
                                                    <c:set var="isNewLesson" value="${isResubmission and not empty lRev and lRev.changeState eq 'NEW'}"/>
                                                    <c:set var="isUpdatedLesson" value="${isResubmission and not isNewLesson and not empty lRev and lRev.changeState eq 'UPDATED'}"/>

                                                    <c:if test="${isNewLesson}"><c:set var="newLessonCount" value="${newLessonCount + 1}"/></c:if>
                                                    <c:if test="${isUpdatedLesson}"><c:set var="updatedLessonCount" value="${updatedLessonCount + 1}"/></c:if>
                                                    <c:if test="${isResubmission and not isNewLesson and not isUpdatedLesson}"><c:set var="publishedLessonCount" value="${publishedLessonCount + 1}"/></c:if>

                                                    <li class="rev-lesson-item<c:if test='${isNewLesson}'> rev-lesson-item--new</c:if><c:if test='${isUpdatedLesson}'> rev-lesson-item--updated</c:if>"
                                                        onclick="toggleLessonDetail(${lesson.lessonId})">
                                                        <span class="rev-lesson-item__title">
                                                            <strong>${lesson.orderIndex}.</strong>
                                                            <c:out value="${lesson.title}"/>
                                                        </span>
                                                        <span class="rev-lesson-item__type">
                                                            <c:choose>
                                                                <c:when test="${lesson.lessonType eq 'VIDEO'}">Video</c:when>
                                                                <c:when test="${lesson.lessonType eq 'QUIZ'}">Quiz</c:when>
                                                                <c:otherwise>Bài viết</c:otherwise>
                                                            </c:choose>
                                                            <c:if test="${lesson.videoDuration != null}"> · ${lesson.videoDuration} phút</c:if>
                                                        </span>

                                                        <!-- Chỉ hiển thị trạng thái mục thay đổi từ lần cập nhật thứ 2 trở đi (sau khi khóa học đã được duyệt lần đầu) -->
                                                        <c:if test="${isResubmission}">
                                                            <c:choose>
                                                                <c:when test="${isNewLesson}">
                                                                    <span class="rev-lesson-item__badge rev-lesson-item__badge--draft">Mới bổ sung</span>
                                                                </c:when>
                                                                <c:when test="${isUpdatedLesson}">
                                                                    <span class="rev-lesson-item__badge rev-lesson-item__badge--updated">Đã chỉnh sửa</span>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <span class="rev-lesson-item__badge rev-lesson-item__badge--published">Đã duyệt trước đó</span>
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </c:if>

                                                        <!-- Preview badge -->
                                                        <c:if test="${lesson.isPreview}">
                                                            <span class="rev-lesson-item__badge rev-lesson-item__badge--preview">Xem thử</span>
                                                        </c:if>
                                                        <span class="rev-lesson-toggle-btn" id="lessonToggleBtn-${lesson.lessonId}">
                                                            Xem nội dung
                                                        </span>
                                                    </li>

                                                    <!-- Khung chi tiết đầy đủ của bài học -->
                                                    <li id="lessonDetailPanel-${lesson.lessonId}"
                                                        class="rev-lesson-detail-panel <c:if test='${isNewLesson or isUpdatedLesson}'>open</c:if>">

                                                        <!-- Thông báo nếu là bài học mới được bổ sung ở lần cập nhật thứ 2+ -->
                                                        <c:if test="${isNewLesson}">
                                                            <div style="margin-bottom:12px; padding:8px 12px; border-radius:8px; background:#FEF9C3; border:1px solid #FDE047; color:#854D0E; font-size:.8rem; font-weight:700;">
                                                                Bài học này mới được giảng viên bổ sung thêm trong đợt cập nhật hiện tại.
                                                            </div>
                                                        </c:if>

                                                        <!-- 1. Thông tin cấu hình bài học -->
                                                        <div style="display:flex; flex-wrap:wrap; gap:12px; margin-bottom:12px; font-size:.78rem; color:#475569; background:#fff; padding:8px 12px; border-radius:8px; border:1px solid #E2E8F0;">
                                                            <span><strong>Loại bài:</strong> <c:out value="${lesson.lessonType}"/></span>
                                                            <c:if test="${lesson.videoDuration != null}">
                                                                <span>· <strong>Thời lượng:</strong> ${lesson.videoDuration} phút</span>
                                                            </c:if>
                                                            <c:if test="${lesson.lessonType eq 'VIDEO'}">
                                                                <span>· <strong>Tua video:</strong> ${lesson.allowSeek ? 'Cho phép tua' : 'Bắt buộc xem tuần tự (Cấm tua)'}</span>
                                                                <span>· <strong>Khóa Quiz theo Video:</strong> ${lesson.quizRequiresVideo ? ('Bắt buộc xem đủ ' += lesson.minWatchPercent += '%') : 'Không'}</span>
                                                            </c:if>
                                                            <c:if test="${not empty lesson.bunnyVideoId}">
                                                                <span>· <strong>Bunny ID:</strong> <code><c:out value="${lesson.bunnyVideoId}"/></code></span>
                                                            </c:if>
                                                            <c:if test="${lesson.unlockDaysAfterEnroll != null and lesson.unlockDaysAfterEnroll > 0}">
                                                                <span>· <strong>Mở sau:</strong> ${lesson.unlockDaysAfterEnroll} ngày</span>
                                                            </c:if>
                                                        </div>

                                                        <!-- 2. Video bài giảng (nếu có) -->
                                                        <c:if test="${not empty lesson.videoUrl}">
                                                            <div style="margin-bottom:14px; background:#fff; padding:12px; border-radius:8px; border:1px solid #E2E8F0;">
                                                                <div style="font-weight:700; color:#0F172A; margin-bottom:8px; display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:8px;">
                                                                    <span>Video bài giảng</span>
                                                                    <a href="<c:out value='${lesson.videoUrl}'/>" target="_blank" rel="noopener"
                                                                       style="font-size:.78rem; color:#2563EB; text-decoration:none;">Mở link video gốc ↗</a>
                                                                </div>
                                                                <c:if test="${not empty lRev and not lRev.videoExists}">
                                                                    <div style="background:#FEF2F2; color:#991B1B; border:1px solid #FECACA; padding:8px 12px; border-radius:6px; font-size:.8rem; margin-bottom:8px;">
                                                                        File video này hiện không còn tồn tại trên máy chủ lưu trữ.
                                                                    </div>
                                                                </c:if>
                                                                <c:set var="vUrlLower" value="${fn:toLowerCase(lesson.videoUrl)}"/>
                                                                <div style="position:relative; padding-bottom:56.25%; height:0; border-radius:8px; overflow:hidden; background:#000; max-width:640px;">
                                                                    <c:choose>
                                                                        <c:when test="${fn:contains(lesson.videoUrl, '/uploads/') or fn:endsWith(vUrlLower, '.mp4') or fn:endsWith(vUrlLower, '.webm') or fn:endsWith(vUrlLower, '.mov')}">
                                                                            <video controls style="position:absolute;top:0;left:0;width:100%;height:100%;background:#000;">
                                                                                <source src="<c:out value='${lesson.videoUrl}'/>">
                                                                            </video>
                                                                        </c:when>
                                                                        <c:otherwise>
                                                                            <iframe class="admin-lesson-video-iframe"
                                                                                    data-src="<c:out value='${lesson.videoUrl}'/>"
                                                                                    style="position:absolute;top:0;left:0;width:100%;height:100%;border:0;"
                                                                                    allowfullscreen></iframe>
                                                                        </c:otherwise>
                                                                    </c:choose>
                                                                </div>
                                                            </div>
                                                        </c:if>

                                                        <!-- 3. Nội dung văn bản / Bài viết của bài học -->
                                                        <div style="margin-bottom:14px; background:#fff; padding:12px 14px; border-radius:8px; border:1px solid #E2E8F0;">
                                                            <div style="font-weight:700; color:#0F172A; margin-bottom:6px;">Nội dung chi tiết bài học:</div>
                                                            <c:choose>
                                                                <c:when test="${not empty lesson.content}">
                                                                    <div style="font-size:.85rem; color:#334155; line-height:1.65; white-space:pre-wrap; max-height:320px; overflow-y:auto;"><c:out value="${lesson.content}"/></div>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <span style="font-size:.82rem; color:#94A3B8; font-style:italic;">Bài học này không có nội dung văn bản.</span>
                                                                </c:otherwise>
                                                            </c:choose>
                                                            <c:if test="${not empty lesson.instructorNotes}">
                                                                <div style="margin-top:10px; padding-top:8px; border-top:1px dashed #E2E8F0; font-size:.8rem; color:#475569;">
                                                                    <strong>Ghi chú giảng viên:</strong> <c:out value="${lesson.instructorNotes}"/>
                                                                </div>
                                                            </c:if>
                                                        </div>

                                                        <!-- 4. Tài liệu đính kèm (Materials) -->
                                                        <c:if test="${not empty lRev and not empty lRev.materials}">
                                                            <div style="margin-bottom:14px; background:#fff; padding:12px 14px; border-radius:8px; border:1px solid #E2E8F0;">
                                                                <div style="font-weight:700; color:#0F172A; margin-bottom:8px;">Tài liệu đính kèm (${lRev.materials.size()}):</div>
                                                                <div style="display:flex; flex-direction:column; gap:6px;">
                                                                    <c:forEach var="mat" items="${lRev.materials}">
                                                                        <div style="display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:8px; padding:8px 10px; background:#F8FAFC; border:1px solid #E2E8F0; border-radius:6px;">
                                                                            <div>
                                                                                <span style="font-size:.7rem; font-weight:700; padding:2px 6px; border-radius:4px; background:#E2E8F0; color:#334155; margin-right:6px;"><c:out value="${mat.type}"/></span>
                                                                                <strong><c:out value="${mat.title}"/></strong>
                                                                                <c:if test="${not empty mat.originalFileName}">
                                                                                    <span style="color:#64748B; font-size:.78rem;"> (<c:out value="${mat.originalFileName}"/>)</span>
                                                                                </c:if>
                                                                                <c:if test="${not mat.fileExists}">
                                                                                    <span style="color:#DC2626; font-size:.75rem; font-weight:700; margin-left:6px;">(File không còn tồn tại)</span>
                                                                                </c:if>
                                                                            </div>
                                                                            <c:if test="${mat.fileExists}">
                                                                                <a href="<c:out value='${mat.fileUrl}'/>" target="_blank" rel="noopener"
                                                                                   style="font-size:.8rem; font-weight:700; color:#2563EB; text-decoration:none;">
                                                                                    Xem / Tải tài liệu ↗
                                                                                </a>
                                                                            </c:if>
                                                                        </div>
                                                                    </c:forEach>
                                                                </div>
                                                            </div>
                                                        </c:if>

                                                        <!-- 5. Danh sách Quiz & Câu hỏi của bài học -->
                                                        <c:if test="${not empty lRev and not empty lRev.quizzes}">
                                                            <div style="margin-bottom:14px; background:#fff; padding:12px 14px; border-radius:8px; border:1px solid #E2E8F0;">
                                                                <div style="font-weight:700; color:#0F172A; margin-bottom:8px;">Bài tập Quiz gắn với bài học (${lRev.quizzes.size()}):</div>
                                                                <c:forEach var="qz" items="${lRev.quizzes}">
                                                                    <div style="border:1px solid #E2E8F0; border-radius:8px; padding:10px 12px; margin-bottom:8px; background:#F8FAFC;">
                                                                        <div style="display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:6px; margin-bottom:6px;">
                                                                            <strong><c:out value="${qz.title}"/></strong>
                                                                            <span style="font-size:.75rem; color:#475569;">
                                                                                Thời gian: ${qz.timeLimitMinutes != null ? qz.timeLimitMinutes : 'Không giới hạn'} phút ·
                                                                                Tối đa ${qz.maxAttempts} lần ·
                                                                                Điểm đạt: ${qz.passingScore != null ? qz.passingScore : 0}% ·
                                                                                ${qz.questions.size()} câu hỏi
                                                                            </span>
                                                                        </div>
                                                                        <c:if test="${not empty qz.questions}">
                                                                            <div style="display:flex; flex-direction:column; gap:6px; margin-top:8px;">
                                                                                <c:forEach var="qItem" items="${qz.questions}">
                                                                                    <div style="background:#fff; border:1px solid #E2E8F0; border-radius:6px; padding:8px 10px; font-size:.8rem;">
                                                                                        <div style="font-weight:700; color:#0F172A;">
                                                                                            Câu ${qItem.orderIndex} [${qItem.type} - ${qItem.score}đ]: <c:out value="${qItem.content}"/>
                                                                                        </div>
                                                                                        <c:if test="${not empty qItem.options}">
                                                                                            <ul style="margin:4px 0 0 18px; padding:0;">
                                                                                                <c:forEach var="opt" items="${qItem.options}">
                                                                                                    <li style="${opt.correct ? 'color:#15803D;font-weight:700;' : 'color:#475569;'}">
                                                                                                        <c:out value="${opt.content}"/>
                                                                                                        <c:if test="${opt.correct}"> (Đáp án đúng)</c:if>
                                                                                                    </li>
                                                                                                </c:forEach>
                                                                                            </ul>
                                                                                        </c:if>
                                                                                        <c:if test="${empty qItem.options and not empty qItem.correctAnswer}">
                                                                                            <div style="color:#15803D; font-weight:600; margin-top:4px;">
                                                                                                Đáp án đúng: <c:out value="${qItem.correctAnswer}"/>
                                                                                            </div>
                                                                                        </c:if>
                                                                                    </div>
                                                                                </c:forEach>
                                                                            </div>
                                                                        </c:if>
                                                                    </div>
                                                                </c:forEach>
                                                            </div>
                                                        </c:if>

                                                        <!-- 6. Lịch sử thay đổi (So sánh Trước & Sau khi cập nhật) của bài học này — Chỉ hiển thị ở lần cập nhật thứ 2+ -->
                                                        <c:if test="${isResubmission and not empty lRev and not empty lRev.changeLogs}">
                                                            <div style="background:#EFF6FF; padding:12px 14px; border-radius:8px; border:1px solid #BFDBFE;">
                                                                <div style="font-weight:800; color:#1E40AF; margin-bottom:8px;">
                                                                    Các thay đổi của bài học trong lần cập nhật này (${lRev.changeLogs.size()} mục):
                                                                </div>
                                                                <c:forEach var="cLog" items="${lRev.changeLogs}" end="4">
                                                                    <div style="background:#fff; border:1px solid #DBEAFE; border-radius:6px; padding:10px 12px; margin-bottom:8px;">
                                                                        <div style="display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:6px; font-size:.78rem;">
                                                                            <span>
                                                                                <strong><c:out value="${cLog.actionTypeLabel}"/></strong> ·
                                                                                <c:out value="${cLog.summary}"/>
                                                                            </span>
                                                                            <span style="color:#64748B;">
                                                                                <c:out value="${cLog.formattedCreatedAt}"/> ·
                                                                                <a href="${pageContext.request.contextPath}/admin/course-change-logs/${cLog.logId}"
                                                                                   style="color:#2563EB; font-weight:700; text-decoration:none;">Chi tiết #${cLog.logId}</a>
                                                                            </span>
                                                                        </div>
                                                                        <c:if test="${not empty cLog.beforeData and not empty cLog.fieldDiffs}">
                                                                            <table class="rev-diff-table">
                                                                                <thead>
                                                                                    <tr>
                                                                                        <th style="width:22%;">Phần đã chỉnh sửa</th>
                                                                                        <th style="width:39%;">Trước khi sửa</th>
                                                                                        <th style="width:39%;">Sau khi sửa</th>
                                                                                    </tr>
                                                                                </thead>
                                                                                <tbody>
                                                                                    <c:forEach var="diff" items="${cLog.fieldDiffs}">
                                                                                        <c:if test="${diff.changed}">
                                                                                            <tr>
                                                                                                <td style="font-weight:700;"><c:out value="${diff.fieldLabel}"/></td>
                                                                                                <td class="rev-diff-before"><c:out value="${not empty diff.beforeValue ? diff.beforeValue : '(Trống)'}"/></td>
                                                                                                <td class="rev-diff-after"><c:out value="${not empty diff.afterValue ? diff.afterValue : '(Đã xóa)'}"/></td>
                                                                                            </tr>
                                                                                        </c:if>
                                                                                    </c:forEach>
                                                                                </tbody>
                                                                            </table>
                                                                        </c:if>
                                                                    </div>
                                                                </c:forEach>
                                                            </div>
                                                        </c:if>
                                                    </li>
                                                </c:forEach>
                                            </ul>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </c:forEach>

                            <div style="background:#F8FAFC;border:1px solid #E2E8F0;border-radius:8px;padding:12px 16px;margin-top:14px;display:flex;gap:20px;flex-wrap:wrap;font-size:.85rem;">
                                <span>Tổng cộng: <strong>${course.lessonCount}</strong> bài học</span>
                                <c:if test="${isResubmission}">
                                    <c:if test="${publishedLessonCount > 0}">
                                        <span style="color:#166534;">· <strong>${publishedLessonCount}</strong> bài đã duyệt trước đó</span>
                                    </c:if>
                                    <c:if test="${updatedLessonCount > 0}">
                                        <span style="color:#1E40AF;">· <strong>${updatedLessonCount}</strong> bài vừa chỉnh sửa nội dung</span>
                                    </c:if>
                                    <c:if test="${newLessonCount > 0}">
                                        <span style="color:#854D0E;">· <strong>${newLessonCount}</strong> bài mới bổ sung</span>
                                    </c:if>
                                </c:if>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>

                <!-- Các mục thay đổi trong lần cập nhật này (Chỉ hiển thị từ lần thay đổi thứ 2 trở đi sau khi đã duyệt lần 1) -->
                <c:if test="${isResubmission}">
                    <div class="rev-section">
                        <div style="display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:10px; margin-bottom:14px;">
                            <p class="rev-section__title" style="margin:0;">Các nội dung thay đổi / bổ sung kể từ lần duyệt trước</p>
                            <a href="${pageContext.request.contextPath}/admin/course-change-logs/course/${course.courseId}"
                               style="font-size:.8rem; font-weight:700; color:#2563EB; text-decoration:none;">
                                Xem tất cả lịch sử thay đổi
                            </a>
                        </div>
                        <c:choose>
                            <c:when test="${empty courseChangeLogs}">
                                <span class="rev-empty">Chưa có bản ghi thay đổi mới nào kể từ lần phê duyệt trước.</span>
                            </c:when>
                            <c:otherwise>
                                <div style="display:flex; flex-direction:column; gap:10px;">
                                    <c:forEach var="logItem" items="${courseChangeLogs}" end="14">
                                        <div style="border:1px solid #E2E8F0; border-radius:8px; padding:12px 14px; background:#F8FAFC;">
                                            <div style="display:flex; justify-content:space-between; align-items:flex-start; gap:12px; flex-wrap:wrap;">
                                                <div style="flex:1; min-width:240px;">
                                                    <div style="display:flex; align-items:center; gap:8px; flex-wrap:wrap; margin-bottom:4px;">
                                                        <span style="font-size:.72rem; font-weight:700; padding:2px 8px; border-radius:4px; background:#E2E8F0; color:#0F172A;">
                                                            <c:out value="${logItem.entityTypeLabel}"/>
                                                        </span>
                                                        <span style="font-size:.72rem; font-weight:700; padding:2px 8px; border-radius:4px; background:#DBEAFE; color:#1E40AF;">
                                                            <c:out value="${logItem.actionType eq 'CREATE' ? 'Bổ sung mới' : 'Phần đã chỉnh sửa'}"/>
                                                        </span>
                                                        <c:if test="${not empty logItem.lessonTypeLabel}">
                                                            <span style="font-size:.72rem; font-weight:700; padding:2px 8px; border-radius:4px; background:#DCFCE7; color:#166534;">
                                                                Thể loại: <c:out value="${logItem.lessonTypeLabel}"/>
                                                            </span>
                                                        </c:if>
                                                        <span style="font-size:.78rem; color:#64748B;">
                                                            <c:out value="${logItem.formattedCreatedAt}"/> · <c:out value="${logItem.actorName}"/>
                                                        </span>
                                                    </div>
                                                    <div style="font-size:.86rem; font-weight:700; color:#1E293B;">
                                                        <c:out value="${logItem.summary}"/>
                                                    </div>
                                                </div>
                                                <a href="${pageContext.request.contextPath}/admin/course-change-logs/${logItem.logId}"
                                                   style="font-size:.78rem; font-weight:700; color:#2563EB; background:#fff; border:1px solid #BFDBFE; border-radius:6px; padding:6px 10px; text-decoration:none; white-space:nowrap;">
                                                    Chi tiết
                                                </a>
                                            </div>
                                            <c:if test="${not empty logItem.beforeData and not empty logItem.fieldDiffs}">
                                                <table class="rev-diff-table">
                                                    <thead>
                                                        <tr>
                                                            <th style="width:22%;">Phần đã chỉnh sửa</th>
                                                            <th style="width:39%;">Trước khi sửa</th>
                                                            <th style="width:39%;">Sau khi sửa</th>
                                                        </tr>
                                                    </thead>
                                                    <tbody>
                                                        <c:forEach var="diff" items="${logItem.fieldDiffs}">
                                                            <c:if test="${diff.changed}">
                                                                <tr>
                                                                    <td style="font-weight:700;"><c:out value="${diff.fieldLabel}"/></td>
                                                                    <td class="rev-diff-before"><c:out value="${not empty diff.beforeValue ? diff.beforeValue : '(Trống)'}"/></td>
                                                                    <td class="rev-diff-after"><c:out value="${not empty diff.afterValue ? diff.afterValue : '(Đã xóa)'}"/></td>
                                                                </tr>
                                                            </c:if>
                                                        </c:forEach>
                                                    </tbody>
                                                </table>
                                            </c:if>
                                        </div>
                                    </c:forEach>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </c:if>

            </div>
            <!-- END LEFT -->

            <!-- ══ RIGHT: Aside actions ══ -->
            <aside class="rev-aside">

                <!-- Decision card -->
                <div class="rev-aside-card">
                    <div class="rev-aside-card__head">Quyết định kiểm duyệt</div>
                    <div class="rev-aside-card__body">

                        <!-- APPROVE -->
                        <form method="post"
                              action="${pageContext.request.contextPath}/admin/courses/${course.courseId}/review"
                              data-title="<c:out value='${course.title}'/>"
                              onsubmit="return confirm('Xác nhận PHÊ DUYỆT khóa học «' + this.getAttribute('data-title') + '»?')">
                            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                            <input type="hidden" name="decision" value="APPROVED">
                            <button class="rev-btn-approve" type="submit">Phê duyệt khóa học</button>
                        </form>

                        <div style="border-top:1px solid #E2E8F0; padding-top:14px; margin-top:4px;">
                            <!-- REJECT -->
                            <form method="post"
                                  action="${pageContext.request.contextPath}/admin/courses/${course.courseId}/review"
                                  onsubmit="return validateReject(this)">
                                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                <input type="hidden" name="decision" value="REJECTED">
                                <label style="font-size:.8rem;font-weight:700;color:#64748B;display:block;margin-bottom:6px;">Lý do từ chối (bắt buộc)</label>
                                <textarea name="comment" class="rev-textarea" rows="4" maxlength="2000"
                                          placeholder="Mô tả rõ vấn đề để giảng viên có thể chỉnh sửa..."></textarea>
                                <button class="rev-btn-reject" type="submit">Từ chối &amp; Gửi phản hồi</button>
                            </form>
                        </div>
                    </div>
                </div>

                <!-- Course quick info -->
                <div class="rev-aside-card">
                    <div class="rev-aside-card__head">Tóm tắt khóa học</div>
                    <div class="rev-aside-card__body" style="font-size:.85rem; display:flex; flex-direction:column; gap:10px;">
                        <div>
                            <span style="color:#64748B;">Giảng viên:</span><br/>
                            <strong><c:out value="${course.instructorName}"/></strong>
                        </div>
                        <div>
                            <span style="color:#64748B;">Phiên bản:</span>
                            <strong> v<c:out value="${course.versionNo}"/></strong>
                        </div>
                        <div>
                            <span style="color:#64748B;">Tổng số bài học:</span>
                            <strong> ${course.lessonCount} bài</strong>
                        </div>
                        <c:if test="${isResubmission}">
                            <div>
                                <span style="color:#64748B;">Trạng thái cập nhật bài học:</span><br/>
                                <c:if test="${publishedLessonCount > 0}">
                                    <span style="color:#166534; font-weight:600;">• ${publishedLessonCount} bài giữ nguyên</span><br/>
                                </c:if>
                                <c:if test="${updatedLessonCount > 0}">
                                    <span style="color:#1E40AF; font-weight:600;">• ${updatedLessonCount} bài đã chỉnh sửa</span><br/>
                                </c:if>
                                <c:if test="${newLessonCount > 0}">
                                    <span style="color:#854D0E; font-weight:600;">• ${newLessonCount} bài mới bổ sung</span>
                                </c:if>
                            </div>
                            <div style="background:#ECFDF5;border:1px solid #86EFAC;border-radius:6px;padding:8px 10px;color:#166534;font-size:.8rem;font-weight:600;">
                                Đây là bản cập nhật bổ sung sau khi khóa học đã được phê duyệt trước đó.
                            </div>
                        </c:if>
                    </div>
                </div>

                <!-- Back button -->
                <a href="${pageContext.request.contextPath}/admin/courses/review"
                   style="display:block;text-align:center;padding:10px;border:1.5px solid #E2E8F0;border-radius:8px;color:#64748B;font-size:.85rem;font-weight:600;text-decoration:none;">
                    ← Quay lại danh sách
                </a>
            </aside>

        </div>
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

function validateReject(form) {
    const comment = form.querySelector('textarea[name="comment"]');
    if (!comment || comment.value.trim().length === 0) {
        alert('Vui lòng nhập lý do từ chối trước khi gửi.');
        comment.focus();
        return false;
    }
    return confirm('Xác nhận TỪ CHỐI khóa học này?');
}

function normalizeEmbedVideoUrl(url) {
    if (!url) return '';
    url = url.trim();
    if (url.indexOf('youtube.com') !== -1 || url.indexOf('youtu.be') !== -1) {
        var videoId = '';
        if (url.indexOf('watch?v=') !== -1) {
            videoId = url.split('watch?v=')[1].split('&')[0];
        } else if (url.indexOf('youtu.be/') !== -1) {
            videoId = url.split('youtu.be/')[1].split('?')[0];
        } else {
            return url;
        }
        return videoId.indexOf('http') === 0 ? videoId : 'https://www.youtube.com/embed/' + videoId;
    }
    return url;
}

function initLessonVideoIframes(container) {
    var root = container || document;
    root.querySelectorAll('.admin-lesson-video-iframe').forEach(function(iframe) {
        if (!iframe.getAttribute('src')) {
            var rawUrl = iframe.getAttribute('data-src');
            if (rawUrl) {
                iframe.setAttribute('src', normalizeEmbedVideoUrl(rawUrl));
            }
        }
    });
}

function toggleLessonDetail(lessonId) {
    var panel = document.getElementById('lessonDetailPanel-' + lessonId);
    var btn = document.getElementById('lessonToggleBtn-' + lessonId);
    if (!panel) return;
    var isOpen = panel.classList.toggle('open');
    if (isOpen) {
        initLessonVideoIframes(panel);
    }
    if (btn) {
        btn.textContent = isOpen ? 'Thu gọn' : 'Xem nội dung';
    }
}

var allLessonsExpanded = false;
function toggleAllLessons() {
    allLessonsExpanded = !allLessonsExpanded;
    document.querySelectorAll('.rev-lesson-detail-panel').forEach(function(panel) {
        if (allLessonsExpanded) {
            panel.classList.add('open');
            initLessonVideoIframes(panel);
        } else {
            panel.classList.remove('open');
        }
    });
    var btn = document.getElementById('toggleAllLessonsBtn');
    if (btn) {
        btn.textContent = allLessonsExpanded ? 'Thu gọn tất cả bài học' : 'Mở rộng tất cả bài học';
    }
}

document.addEventListener('DOMContentLoaded', function() {
    document.querySelectorAll('.rev-lesson-detail-panel.open').forEach(function(panel) {
        initLessonVideoIframes(panel);
    });
});
</script>

</body>
</html>
