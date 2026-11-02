<%@ page contentType="text/html;charset=UTF-8" language="java" %>
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
            padding: 10px 16px;
            border-top: 1px solid #F1F5F9;
            font-size: .88rem;
            color: #334155;
        }
        .rev-lesson-item__icon { font-size: 1rem; flex-shrink: 0; }
        .rev-lesson-item__title { flex: 1; font-weight: 500; }
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
        .rev-lesson-item--new {
            background: #FFFBEB;
            border-left: 3px solid #F59E0B;
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

        <!-- Back -->
        <a class="rev-back" href="${pageContext.request.contextPath}/admin/courses/review">
            ← Danh sách chờ duyệt
        </a>

        <!-- Page heading -->
        <div style="display:flex; align-items:flex-start; justify-content:space-between; flex-wrap:wrap; gap:12px; margin-bottom:24px;">
            <div>
                <div class="rev-version-badge">🔢 Phiên bản v<c:out value="${course.versionNo}"/> · Chờ duyệt</div>
                <h1 class="rev-page-title"><c:out value="${course.title}"/></h1>
                <p class="rev-page-sub">
                    👤 <strong><c:out value="${course.instructorName}"/></strong>
                    <c:if test="${not empty course.categoryName}"> · 📂 <c:out value="${course.categoryName}"/></c:if>
                    · 📚 <strong>${course.lessonCount}</strong> bài học
                    · 💰
                    <c:choose>
                        <c:when test="${course.price == 0}"><strong>Miễn phí</strong></c:when>
                        <c:otherwise><strong><fmt:formatNumber value="${course.price}" type="number" maxFractionDigits="0"/>đ</strong></c:otherwise>
                    </c:choose>
                    · 🎯 <c:out value="${course.level}"/>
                </p>
            </div>
        </div>

        <!-- Previous rejection note -->
        <c:if test="${not empty course.latestReviewComment}">
            <div class="adm-alert" style="background:#FEF2F2;border:1px solid #FECACA;color:#991B1B;margin-bottom:20px;">
                💬 <strong>Nhận xét lần duyệt trước:</strong> <c:out value="${course.latestReviewComment}"/>
            </div>
        </c:if>

        <!-- Instructor change note -->
        <c:if test="${not empty course.changeNote}">
            <div style="background:#EFF6FF;border:2px solid #3B82F6;border-radius:12px;padding:16px 20px;margin-bottom:20px;display:flex;gap:14px;align-items:flex-start;">
                <span style="font-size:1.4rem;flex-shrink:0;">📋</span>
                <div>
                    <div style="font-weight:800;color:#1D4ED8;font-size:.9rem;margin-bottom:4px;">Chú thích từ Giảng viên về lần cập nhật này:</div>
                    <div style="color:#1E40AF;font-size:.92rem;line-height:1.6;white-space:pre-wrap;"><c:out value="${course.changeNote}"/></div>
                </div>
            </div>
        </c:if>

        <div class="rev-layout">

            <!-- ══ LEFT: Course content ══ -->
            <div>

                <!-- Thumbnail & Promo Video -->
                <div class="rev-section">
                    <p class="rev-section__title">📸 Hình ảnh & Video giới thiệu</p>
                    <div style="display:grid; grid-template-columns:1fr 1fr; gap:16px;">
                        <div>
                            <p style="font-size:.78rem;font-weight:700;color:#64748B;margin:0 0 6px;">Ảnh bìa</p>
                            <c:choose>
                                <c:when test="${not empty course.thumbnailUrl}">
                                    <img src="<c:out value='${course.thumbnailUrl}'/>" alt="Thumbnail" class="rev-thumbnail">
                                </c:when>
                                <c:otherwise>
                                    <div class="rev-thumbnail-placeholder">🖼️</div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                        <div>
                            <p style="font-size:.78rem;font-weight:700;color:#64748B;margin:0 0 6px;">Video giới thiệu</p>
                            <c:choose>
                                <c:when test="${not empty course.promoVideoUrl}">
                                    <c:set var="promoUrlLower" value="${fn:toLowerCase(course.promoVideoUrl)}"/>
                                    <div style="position:relative;padding-bottom:56.25%;height:0;border-radius:8px;overflow:hidden;background:#000;">
                                        <c:choose>
                                            <c:when test="${fn:startsWith(course.promoVideoUrl, '/uploads/') or fn:endsWith(promoUrlLower, '.mp4') or fn:endsWith(promoUrlLower, '.webm') or fn:endsWith(promoUrlLower, '.ogg')}">
                                                <video controls style="position:absolute;top:0;left:0;width:100%;height:100%;background:#000;"><source src="<c:out value='${course.promoVideoUrl}'/>"></video>
                                            </c:when>
                                            <c:otherwise>
                                                <iframe id="promoVideoIframe"
                                                        data-src="<c:out value='${course.promoVideoUrl}'/>"
                                                        style="position:absolute;top:0;left:0;width:100%;height:100%;border:0;"
                                                        allowfullscreen></iframe>
                                                <script>
                                                (function() {
                                                    var iframe = document.getElementById('promoVideoIframe');
                                                    if (!iframe) return;
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
                                                })();
                                                </script>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <div class="rev-thumbnail-placeholder" style="font-size:2rem;">🎬<br/><span style="font-size:.75rem;margin-top:6px;display:block;color:#64748B;">Chưa có video</span></div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>

                <!-- Basic info -->
                <div class="rev-section">
                    <p class="rev-section__title">📋 Thông tin cơ bản</p>
                    <div class="rev-info-grid">
                        <div class="rev-info-item">
                            <div class="rev-info-item__label">Trình độ</div>
                            <div class="rev-info-item__value">
                                <c:choose>
                                    <c:when test="${course.level == 'BEGINNER'}">🟢 Cơ bản</c:when>
                                    <c:when test="${course.level == 'INTERMEDIATE'}">🟡 Trung cấp</c:when>
                                    <c:when test="${course.level == 'ADVANCED'}">🔴 Nâng cao</c:when>
                                    <c:otherwise>⚪ Tất cả trình độ</c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                        <div class="rev-info-item">
                            <div class="rev-info-item__label">Học phí</div>
                            <div class="rev-info-item__value">
                                <c:choose>
                                    <c:when test="${course.price == 0}">🆓 Miễn phí</c:when>
                                    <c:otherwise>💰 <fmt:formatNumber value="${course.price}" type="number" maxFractionDigits="0"/> VNĐ</c:otherwise>
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
                    <p class="rev-section__title">📝 Mô tả khóa học</p>
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
                        <p class="rev-section__title">🎯 Mục tiêu & Yêu cầu</p>
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
                    <p class="rev-section__title">📚 Cấu trúc khóa học & Nội dung bài học</p>

                    <c:choose>
                        <c:when test="${empty course.sections}">
                            <span class="rev-empty">Khóa học chưa có bài học nào.</span>
                        </c:when>
                        <c:otherwise>
                            <c:forEach var="section" items="${course.sections}">
                                <div class="rev-chapter">
                                    <div class="rev-chapter__head">
                                        <div>
                                            <span class="rev-chapter__name">
                                                <c:choose>
                                                    <c:when test="${section.sectionId == null}">📁</c:when>
                                                    <c:otherwise>📂</c:otherwise>
                                                </c:choose>
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
                                                    <li class="rev-lesson-item<c:if test='${lesson.status eq "DRAFT"}'> rev-lesson-item--new</c:if>">
                                                        <span class="rev-lesson-item__icon">
                                                            <c:choose>
                                                                <c:when test="${lesson.lessonType eq 'VIDEO'}">🎥</c:when>
                                                                <c:when test="${lesson.lessonType eq 'QUIZ'}">📝</c:when>
                                                                <c:otherwise>📄</c:otherwise>
                                                            </c:choose>
                                                        </span>
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
                                                        <!-- Trạng thái bài học -->
                                                        <c:choose>
                                                            <c:when test="${lesson.status eq 'DRAFT'}">
                                                                <span class="rev-lesson-item__badge rev-lesson-item__badge--draft">🆕 MỚI — Chờ duyệt</span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="rev-lesson-item__badge rev-lesson-item__badge--published">✅ Đã công bố</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                        <!-- Preview badge -->
                                                        <c:if test="${lesson.isPreview}">
                                                            <span class="rev-lesson-item__badge rev-lesson-item__badge--preview">👁️ Xem thử</span>
                                                        </c:if>
                                                    </li>
                                                    <!-- Nội dung preview cho bài DRAFT -->
                                                    <c:if test="${lesson.status eq 'DRAFT'}">
                                                        <li style="padding:0 16px 12px 42px; background:#FFFBEB; border-top:1px dashed #FDE68A;">
                                                            <c:choose>
                                                                <c:when test="${lesson.lessonType eq 'VIDEO' and not empty lesson.videoUrl}">
                                                                    <div style="font-size:.78rem;color:#92400E;margin-bottom:4px;font-weight:600;">🎥 URL Video:</div>
                                                                    <a href="<c:out value='${lesson.videoUrl}'/>" target="_blank" rel="noopener"
                                                                       style="font-size:.8rem;color:#2563EB;word-break:break-all;"><c:out value="${lesson.videoUrl}"/></a>
                                                                </c:when>
                                                                <c:when test="${not empty lesson.content}">
                                                                    <div style="font-size:.78rem;color:#92400E;margin-bottom:4px;font-weight:600;">📄 Nội dung bài học:</div>
                                                                    <div style="font-size:.82rem;color:#78350F;line-height:1.5;white-space:pre-wrap;overflow:hidden;max-height:80px;text-overflow:ellipsis;">
                                                                        <c:out value="${fn:substring(lesson.content, 0, 300)}"/>
                                                                        <c:if test="${fn:length(lesson.content) > 300}">…</c:if>
                                                                    </div>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <span style="font-size:.78rem;color:#A16207;font-style:italic;">Chưa có nội dung.</span>
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </li>
                                                    </c:if>
                                                </c:forEach>
                                            </ul>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </c:forEach>

                            <!-- Summary: new vs existing -->
                            <c:set var="newLessonCount" value="0"/>
                            <c:set var="publishedLessonCount" value="0"/>
                            <c:forEach var="section" items="${course.sections}">
                                <c:forEach var="lesson" items="${section.lessons}">
                                    <c:if test="${lesson.status eq 'DRAFT'}">
                                        <c:set var="newLessonCount" value="${newLessonCount + 1}"/>
                                    </c:if>
                                    <c:if test="${lesson.status eq 'PUBLISHED'}">
                                        <c:set var="publishedLessonCount" value="${publishedLessonCount + 1}"/>
                                    </c:if>
                                </c:forEach>
                            </c:forEach>
                            <div style="background:#F8FAFC;border:1px solid #E2E8F0;border-radius:8px;padding:12px 16px;margin-top:14px;display:flex;gap:20px;flex-wrap:wrap;font-size:.85rem;">
                                <span>📊 <strong>${course.lessonCount}</strong> bài tổng cộng</span>
                                <c:if test="${publishedLessonCount > 0}">
                                    <span style="color:#166534;">✅ <strong>${publishedLessonCount}</strong> bài đã công bố (học viên đang học)</span>
                                </c:if>
                                <c:if test="${newLessonCount > 0}">
                                    <span style="color:#854D0E;">🆕 <strong>${newLessonCount}</strong> bài mới cần duyệt</span>
                                </c:if>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>

            </div>
            <!-- END LEFT -->

            <!-- ══ RIGHT: Aside actions ══ -->
            <aside class="rev-aside">

                <!-- Decision card -->
                <div class="rev-aside-card">
                    <div class="rev-aside-card__head">⚡ Quyết định kiểm duyệt</div>
                    <div class="rev-aside-card__body">

                        <!-- APPROVE -->
                        <form method="post"
                              action="${pageContext.request.contextPath}/admin/courses/${course.courseId}/review"
                              data-title="<c:out value='${course.title}'/>"
                              onsubmit="return confirm('Xác nhận PHÊ DUYỆT khóa học «' + this.getAttribute('data-title') + '»?')">
                            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                            <input type="hidden" name="decision" value="APPROVED">
                            <button class="rev-btn-approve" type="submit">✅ Phê duyệt khóa học</button>
                        </form>

                        <div style="border-top:1px solid #E2E8F0; padding-top:14px; margin-top:4px;">
                            <!-- REJECT -->
                            <form method="post"
                                  action="${pageContext.request.contextPath}/admin/courses/${course.courseId}/review"
                                  onsubmit="return validateReject(this)">
                                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                <input type="hidden" name="decision" value="REJECTED">
                                <label style="font-size:.8rem;font-weight:700;color:#64748B;display:block;margin-bottom:6px;">❌ Lý do từ chối (bắt buộc)</label>
                                <textarea name="comment" class="rev-textarea" rows="4" maxlength="2000"
                                          placeholder="Mô tả rõ vấn đề để giảng viên có thể chỉnh sửa..."></textarea>
                                <button class="rev-btn-reject" type="submit">Từ chối &amp; Gửi phản hồi</button>
                            </form>
                        </div>
                    </div>
                </div>

                <!-- Course quick info -->
                <div class="rev-aside-card">
                    <div class="rev-aside-card__head">📌 Tóm tắt khóa học</div>
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
                            <span style="color:#64748B;">Trạng thái bài học:</span><br/>
                            <c:set var="draftCount" value="0"/>
                            <c:set var="pubCount" value="0"/>
                            <c:forEach var="sec2" items="${course.sections}">
                                <c:forEach var="l2" items="${sec2.lessons}">
                                    <c:if test="${l2.status eq 'DRAFT'}"><c:set var="draftCount" value="${draftCount + 1}"/></c:if>
                                    <c:if test="${l2.status eq 'PUBLISHED'}"><c:set var="pubCount" value="${pubCount + 1}"/></c:if>
                                </c:forEach>
                            </c:forEach>
                            <c:if test="${pubCount > 0}">
                                <span style="color:#166534; font-weight:600;">✅ ${pubCount} đã công bố</span><br/>
                            </c:if>
                            <c:if test="${draftCount > 0}">
                                <span style="color:#854D0E; font-weight:600;">🆕 ${draftCount} cần duyệt</span>
                            </c:if>
                        </div>
                        <c:if test="${pubCount > 0}">
                            <div style="background:#ECFDF5;border:1px solid #86EFAC;border-radius:6px;padding:8px 10px;color:#166534;font-size:.8rem;font-weight:600;">
                                ℹ️ Đây là cập nhật nội dung. Học viên vẫn đang học bình thường với các bài đã công bố.
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
</script>

</body>
</html>
