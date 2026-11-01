<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"   uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard Giáo viên — EduSphere</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/instructor.css">
</head>
<body>
<div class="ins-layout">

    <%-- ═══════════════ SIDEBAR ═══════════════ --%>
    <jsp:include page="/WEB-INF/views/courses/ins-sidebar.jsp"/>

    <%-- ═══════════════ MAIN WRAPPER ═══════════════ --%>
    <div class="ins-main-wrapper">

        <%-- ═══════════════ TOPBAR ═══════════════ --%>
        <jsp:include page="/WEB-INF/views/courses/ins-header.jsp"/>

        <%-- ═══════════════ PAGE CONTENT ═══════════════ --%>
        <main class="ins-page">

            <%-- Flash messages --%>
            <c:if test="${not empty success}">
                <div class="ins-alert ins-alert--success">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none"><circle cx="12" cy="12" r="9" stroke="currentColor" stroke-width="1.8"/><path d="M8 12l3 3 5-5" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/></svg>
                    <c:out value="${success}"/>
                </div>
            </c:if>

            <%-- ── 1. WELCOME BANNER ─────────────────────────── --%>
            <div class="ins-welcome-banner">
                <div class="ins-welcome-banner__content">
                    <h1 class="ins-welcome-banner__greeting">
                        Xin chào, <sec:authentication property="principal.fullName"/>!
                        <span class="ins-wave">👋</span>
                    </h1>
                    <p class="ins-welcome-banner__sub">
                        Cùng tạo những khóa học chất lượng, lan tỏa tri thức đến cộng đồng học tập!
                    </p>
                    <div class="ins-welcome-banner__actions">
                        <a class="ins-welcome-banner__btn-primary"
                           href="${pageContext.request.contextPath}/instructor/courses/new">
                            <svg width="14" height="14" viewBox="0 0 24 24" fill="none">
                                <circle cx="12" cy="12" r="9" stroke="currentColor" stroke-width="2"/>
                                <path d="M12 8v8M8 12h8" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
                            </svg>
                            Tạo khóa học mới
                            <span>→</span>
                        </a>
                    </div>
                </div>

                <%-- Illustration (SVG inline) --%>
                <div class="ins-welcome-banner__illustration">
                    <svg width="200" height="130" viewBox="0 0 200 130" fill="none" xmlns="http://www.w3.org/2000/svg">
                        <!-- Book stack -->
                        <rect x="30" y="75" width="70" height="14" rx="4" fill="rgba(255,255,255,.35)"/>
                        <rect x="24" y="63" width="76" height="14" rx="4" fill="rgba(255,255,255,.28)"/>
                        <rect x="18" y="51" width="82" height="14" rx="4" fill="rgba(255,255,255,.22)"/>
                        <!-- Play button circle -->
                        <circle cx="148" cy="48" r="24" fill="rgba(255,255,255,.18)"/>
                        <circle cx="148" cy="48" r="18" fill="rgba(255,255,255,.25)"/>
                        <path d="M144 41l10 7-10 7V41z" fill="white"/>
                        <!-- Stars -->
                        <text x="12" y="30" font-size="14" fill="rgba(255,255,255,.5)">★</text>
                        <text x="168" y="90" font-size="10" fill="rgba(255,255,255,.4)">★</text>
                        <text x="88" y="25" font-size="10" fill="rgba(255,255,255,.35)">✦</text>
                        <!-- Person silhouette (simple) -->
                        <circle cx="148" cy="100" r="10" fill="rgba(255,255,255,.2)"/>
                        <rect x="134" y="110" width="28" height="18" rx="8" fill="rgba(255,255,255,.15)"/>
                    </svg>
                </div>
            </div>

            <%-- ── 2. STATS CARDS ────────────────────────────── --%>
            <div class="ins-stats-grid">
                <div class="ins-stat-card">
                    <div class="ins-stat-card__icon ins-stat-card__icon--blue">
                        <svg width="22" height="22" viewBox="0 0 24 24" fill="none">
                            <path d="M4 19.5A2.5 2.5 0 016.5 17H20" stroke="#1D4ED8" stroke-width="1.8" stroke-linecap="round"/>
                            <path d="M6.5 2H20v20H6.5A2.5 2.5 0 014 19.5v-15A2.5 2.5 0 016.5 2z" stroke="#1D4ED8" stroke-width="1.8"/>
                        </svg>
                    </div>
                    <div class="ins-stat-card__body">
                        <div class="ins-stat-card__label">Tổng khóa học</div>
                        <div class="ins-stat-card__value">${stats.totalCourses}</div>
                    </div>
                </div>

                <div class="ins-stat-card">
                    <div class="ins-stat-card__icon ins-stat-card__icon--green">
                        <svg width="22" height="22" viewBox="0 0 24 24" fill="none">
                            <circle cx="12" cy="12" r="9" stroke="#16A34A" stroke-width="1.8"/>
                            <path d="M8 12l3 3 5-5" stroke="#16A34A" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
                        </svg>
                    </div>
                    <div class="ins-stat-card__body">
                        <div class="ins-stat-card__label">Đã xuất bản</div>
                        <div class="ins-stat-card__value">${stats.publishedCourses}</div>
                    </div>
                </div>

                <div class="ins-stat-card">
                    <div class="ins-stat-card__icon ins-stat-card__icon--yellow">
                        <svg width="22" height="22" viewBox="0 0 24 24" fill="none">
                            <path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8z" stroke="#B45309" stroke-width="1.8"/>
                            <polyline points="14,2 14,8 20,8" stroke="#B45309" stroke-width="1.8"/>
                            <line x1="16" y1="13" x2="8" y2="13" stroke="#B45309" stroke-width="1.8" stroke-linecap="round"/>
                            <line x1="16" y1="17" x2="8" y2="17" stroke="#B45309" stroke-width="1.8" stroke-linecap="round"/>
                        </svg>
                    </div>
                    <div class="ins-stat-card__body">
                        <div class="ins-stat-card__label">Bản nháp</div>
                        <div class="ins-stat-card__value">${stats.draftCourses}</div>
                    </div>
                </div>

                <div class="ins-stat-card">
                    <div class="ins-stat-card__icon ins-stat-card__icon--purple">
                        <svg width="22" height="22" viewBox="0 0 24 24" fill="none">
                            <path d="M17 21v-2a4 4 0 00-4-4H5a4 4 0 00-4 4v2" stroke="#7C3AED" stroke-width="1.8" stroke-linecap="round"/>
                            <circle cx="9" cy="7" r="4" stroke="#7C3AED" stroke-width="1.8"/>
                            <path d="M23 21v-2a4 4 0 00-3-3.87M16 3.13a4 4 0 010 7.75" stroke="#7C3AED" stroke-width="1.8" stroke-linecap="round"/>
                        </svg>
                    </div>
                    <div class="ins-stat-card__body">
                        <div class="ins-stat-card__label">Tổng học viên</div>
                        <div class="ins-stat-card__value">
                            <c:choose>
                                <c:when test="${stats.totalStudents >= 1000}">
                                    <fmt:formatNumber value="${stats.totalStudents / 1000.0}" maxFractionDigits="1"/>K
                                </c:when>
                                <c:otherwise>${stats.totalStudents}</c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>

                <div class="ins-stat-card">
                    <div class="ins-stat-card__icon ins-stat-card__icon--orange">
                        <svg width="22" height="22" viewBox="0 0 24 24" fill="none">
                            <polygon points="23,7 16,12 23,17" fill="none" stroke="#EA580C" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
                            <rect x="1" y="5" width="15" height="14" rx="2" stroke="#EA580C" stroke-width="1.8"/>
                        </svg>
                    </div>
                    <div class="ins-stat-card__body">
                        <div class="ins-stat-card__label">Tổng bài giảng</div>
                        <div class="ins-stat-card__value">${stats.totalLessons}</div>
                    </div>
                </div>
            </div>

            <%-- ── 3. MAIN CONTENT GRID ──────────────────────── --%>
            <div class="ins-dashboard-grid">

                <%-- ─── LEFT COLUMN ─── --%>
                <div class="ins-dashboard-main">

                    <%-- Khóa học của tôi --%>
                    <div class="ins-card">
                        <div class="ins-card__head">
                            <div class="ins-card__title">
                                <span class="ins-card__title-icon">📚</span>
                                Khóa học của tôi
                            </div>
                            <a class="ins-card__view-all" href="${pageContext.request.contextPath}/instructor/courses">
                                Xem tất cả
                                <svg width="12" height="12" viewBox="0 0 24 24" fill="none">
                                    <path d="M5 12h14M13 6l6 6-6 6" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                                </svg>
                            </a>
                        </div>
                        <div class="ins-card__body" style="padding-top:8px; padding-bottom:8px;">
                            <c:choose>
                                <c:when test="${empty stats.recentCourses}">
                                    <div style="text-align:center; padding:32px 20px; color:var(--ins-muted);">
                                        <div style="font-size:2.5rem; margin-bottom:10px;">📖</div>
                                        <div style="font-weight:700; color:var(--ins-ink); margin-bottom:6px;">Bắt đầu với khóa học đầu tiên</div>
                                        <div style="font-size:.83rem; margin-bottom:16px;">Tạo bản nháp, thêm bài học và gửi duyệt để xuất bản.</div>
                                        <a class="ins-btn ins-btn--primary ins-btn--sm"
                                           href="${pageContext.request.contextPath}/instructor/courses/new">+ Tạo khóa học mới</a>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <c:forEach var="course" items="${stats.recentCourses}">
                                        <div class="ins-course-row">
                                            <div class="ins-course-row__thumb">
                                                📖
                                            </div>
                                            <div class="ins-course-row__info">
                                                <a class="ins-course-row__title"
                                                   href="${pageContext.request.contextPath}/instructor/courses/${course.courseId}">
                                                    <c:out value="${course.title}"/>
                                                </a>
                                                <div class="ins-course-row__meta">
                                                    <span class="ins-course-row__meta-item">
                                                        <svg width="11" height="11" viewBox="0 0 24 24" fill="none"><polygon points="23,7 16,12 23,17" fill="none" stroke="currentColor" stroke-width="2"/><rect x="1" y="5" width="15" height="14" rx="2" stroke="currentColor" stroke-width="2"/></svg>
                                                        ${course.lessonCount} bài giảng
                                                    </span>
                                                    <c:choose>
                                                        <c:when test="${course.hidden}">
                                                            <span class="ins-badge ins-badge--hidden">Tạm ẩn</span>
                                                        </c:when>
                                                        <c:when test="${course.status == 'DRAFT'}">
                                                            <span class="ins-badge ins-badge--draft">Bản nháp</span>
                                                        </c:when>
                                                        <c:when test="${course.status == 'UPDATING'}">
                                                            <span class="ins-badge ins-badge--submitted" style="background:#FEF3C7;color:#92400E;border-color:#FDE68A;">🔄 Đang cập nhật</span>
                                                        </c:when>
                                                        <c:when test="${course.status == 'SUBMITTED'}">
                                                            <span class="ins-badge ins-badge--submitted">Chờ duyệt</span>
                                                        </c:when>
                                                        <c:when test="${course.status == 'APPROVED'}">
                                                            <span class="ins-badge ins-badge--approved">Đã duyệt</span>
                                                        </c:when>
                                                        <c:when test="${course.status == 'PUBLISHED'}">
                                                            <span class="ins-badge ins-badge--published">✅ Đã xuất bản</span>
                                                        </c:when>
                                                        <c:when test="${course.status == 'REJECTED'}">
                                                            <span class="ins-badge ins-badge--rejected">Bị từ chối</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="ins-badge ins-badge--archived">Lưu trữ</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </div>
                                            </div>
                                            <div class="ins-course-row__actions">
                                                <c:if test="${course.status == 'PUBLISHED' || course.status == 'SUBMITTED' || course.status == 'APPROVED'}">
                                                    <a class="ins-btn ins-btn--primary ins-btn--sm"
                                                       href="${pageContext.request.contextPath}/instructor/courses/${course.courseId}">
                                                        <svg width="12" height="12" viewBox="0 0 24 24" fill="none"><path d="M12 20h9" stroke="currentColor" stroke-width="2" stroke-linecap="round"/><path d="M16.5 3.5a2.121 2.121 0 013 3L7 19l-4 1 1-4L16.5 3.5z" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg>
                                                        Quản lý
                                                    </a>
                                                </c:if>
                                                <c:if test="${course.status == 'DRAFT' || course.status == 'REJECTED'}">
                                                    <a class="ins-btn ins-btn--outline ins-btn--sm"
                                                       href="${pageContext.request.contextPath}/instructor/courses/${course.courseId}/edit">
                                                        Chỉnh sửa
                                                    </a>
                                                </c:if>
                                                <%-- Dot menu --%>
                                                <div class="ins-dot-menu" onclick="toggleDotMenu(this)">
                                                    <button class="ins-dot-menu__trigger" type="button">•••</button>
                                                    <div class="ins-dot-menu__dropdown">
                                                        <a class="ins-dot-menu__item"
                                                           href="${pageContext.request.contextPath}/instructor/courses/${course.courseId}">
                                                            <svg width="13" height="13" viewBox="0 0 24 24" fill="none"><circle cx="12" cy="12" r="10" stroke="currentColor" stroke-width="1.8"/><line x1="12" y1="8" x2="12" y2="12" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/><circle cx="12" cy="16" r="1" fill="currentColor"/></svg>
                                                            Xem chi tiết
                                                        </a>
                                                        <a class="ins-dot-menu__item"
                                                           href="${pageContext.request.contextPath}/instructor/courses/${course.courseId}/lessons">
                                                            <svg width="13" height="13" viewBox="0 0 24 24" fill="none"><path d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2" stroke="currentColor" stroke-width="1.8"/><rect x="9" y="3" width="6" height="4" rx="1" stroke="currentColor" stroke-width="1.8"/></svg>
                                                            Bài giảng
                                                        </a>
                                                        <a class="ins-dot-menu__item"
                                                           href="${pageContext.request.contextPath}/instructor/courses/${course.courseId}/students">
                                                            <svg width="13" height="13" viewBox="0 0 24 24" fill="none"><path d="M17 21v-2a4 4 0 00-4-4H5a4 4 0 00-4 4v2" stroke="currentColor" stroke-width="1.8"/><circle cx="9" cy="7" r="4" stroke="currentColor" stroke-width="1.8"/><path d="M23 21v-2a4 4 0 00-3-3.87M16 3.13a4 4 0 010 7.75" stroke="currentColor" stroke-width="1.8"/></svg>
                                                            Học viên
                                                        </a>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </c:forEach>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>

                    <%-- Quy trình quản lý khóa học --%>
                    <div class="ins-card">
                        <div class="ins-card__head">
                            <div class="ins-card__title">
                                <span class="ins-card__title-icon">🚀</span>
                                Quy trình quản lý khóa học
                            </div>
                        </div>
                        <div class="ins-card__body">
                            <div class="ins-workflow">
                                <div class="ins-workflow-step">
                                    <div class="ins-workflow-step__icon">➕</div>
                                    <div class="ins-workflow-step__label">Tạo<br>khóa học</div>
                                </div>
                                <div class="ins-workflow-step">
                                    <div class="ins-workflow-step__icon">📋</div>
                                    <div class="ins-workflow-step__label">Tạo<br>chương học</div>
                                </div>
                                <div class="ins-workflow-step">
                                    <div class="ins-workflow-step__icon">📝</div>
                                    <div class="ins-workflow-step__label">Thêm<br>bài học</div>
                                </div>
                                <div class="ins-workflow-step">
                                    <div class="ins-workflow-step__icon">📤</div>
                                    <div class="ins-workflow-step__label">Upload video<br>&amp; tài liệu</div>
                                </div>
                                <div class="ins-workflow-step">
                                    <div class="ins-workflow-step__icon">📨</div>
                                    <div class="ins-workflow-step__label">Gửi<br>duyệt</div>
                                </div>
                                <div class="ins-workflow-step">
                                    <div class="ins-workflow-step__icon" style="background:linear-gradient(135deg,#DCFCE7,#BBF7D0);border-color:#16A34A;color:#16A34A;">✅</div>
                                    <div class="ins-workflow-step__label">Xuất<br>bản</div>
                                </div>
                            </div>
                            <div style="text-align:center; margin-top:18px; padding:12px 20px; background:linear-gradient(135deg,#EFF6FF,#DBEAFE); border-radius:var(--ins-r12);">
                                <span style="font-size:.82rem; font-weight:700; color:#1D4ED8;">
                                    🎓 Cùng EduSphere phát triển sự nghiệp giảng dạy!
                                </span>
                            </div>
                        </div>
                    </div>

                </div>

                <%-- ─── RIGHT COLUMN ─── --%>
                <div class="ins-dashboard-aside">

                    <%-- Thao tác nhanh --%>
                    <div class="ins-card">
                        <div class="ins-card__head">
                            <div class="ins-card__title">
                                <span class="ins-card__title-icon">⚡</span>
                                Thao tác nhanh
                            </div>
                        </div>
                        <div class="ins-card__body">
                            <div class="ins-quick-grid">
                                <a class="ins-quick-item"
                                   href="${pageContext.request.contextPath}/instructor/courses/new">
                                    <div class="ins-quick-item__icon">
                                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none">
                                            <circle cx="12" cy="12" r="9" stroke="white" stroke-width="2"/>
                                            <path d="M12 8v8M8 12h8" stroke="white" stroke-width="2" stroke-linecap="round"/>
                                        </svg>
                                    </div>
                                    <span class="ins-quick-item__label">Tạo khóa học mới</span>
                                </a>

                                <a class="ins-quick-item"
                                   href="${pageContext.request.contextPath}/instructor/courses">
                                    <div class="ins-quick-item__icon">
                                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none">
                                            <polygon points="23,7 16,12 23,17" fill="none" stroke="white" stroke-width="2"/>
                                            <rect x="1" y="5" width="15" height="14" rx="2" stroke="white" stroke-width="2"/>
                                        </svg>
                                    </div>
                                    <span class="ins-quick-item__label">Quản lý video</span>
                                </a>

                                <a class="ins-quick-item"
                                   href="${pageContext.request.contextPath}/instructor/courses">
                                    <div class="ins-quick-item__icon" style="background:linear-gradient(135deg,#7C3AED,#6D28D9);">
                                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none">
                                            <path d="M17 21v-2a4 4 0 00-4-4H5a4 4 0 00-4 4v2" stroke="white" stroke-width="2"/>
                                            <circle cx="9" cy="7" r="4" stroke="white" stroke-width="2"/>
                                            <path d="M23 21v-2a4 4 0 00-3-3.87M16 3.13a4 4 0 010 7.75" stroke="white" stroke-width="2"/>
                                        </svg>
                                    </div>
                                    <span class="ins-quick-item__label">Quản lý học viên</span>
                                </a>

                                <a class="ins-quick-item"
                                   href="${pageContext.request.contextPath}/instructor/courses">
                                    <div class="ins-quick-item__icon" style="background:linear-gradient(135deg,#0891B2,#0E7490);">
                                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none">
                                            <line x1="18" y1="20" x2="18" y2="10" stroke="white" stroke-width="2" stroke-linecap="round"/>
                                            <line x1="12" y1="20" x2="12" y2="4" stroke="white" stroke-width="2" stroke-linecap="round"/>
                                            <line x1="6" y1="20" x2="6" y2="14" stroke="white" stroke-width="2" stroke-linecap="round"/>
                                        </svg>
                                    </div>
                                    <span class="ins-quick-item__label">Thống kê khóa học</span>
                                </a>
                            </div>
                        </div>
                    </div>

                    <%-- Hoạt động gần đây --%>
                    <div class="ins-card">
                        <div class="ins-card__head">
                            <div class="ins-card__title">
                                <span class="ins-card__title-icon">🕐</span>
                                Hoạt động gần đây
                            </div>
                            <a class="ins-card__view-all" href="${pageContext.request.contextPath}/instructor/courses">
                                Xem tất cả →
                            </a>
                        </div>
                        <div class="ins-card__body" style="padding-top:8px;">
                            <c:choose>
                                <c:when test="${not empty stats.recentCourses}">
                                    <div class="ins-activity-list">
                                        <c:forEach var="course" items="${stats.recentCourses}" varStatus="loop">
                                            <c:if test="${loop.index < 4}">
                                                <div class="ins-activity-item">
                                                    <c:choose>
                                                        <c:when test="${course.status == 'PUBLISHED'}">
                                                            <div class="ins-activity-item__dot ins-activity-item__dot--green"></div>
                                                            <div class="ins-activity-item__text">
                                                                Khóa học <strong>"<c:out value="${course.title}"/>"</strong> đã được xuất bản
                                                            </div>
                                                        </c:when>
                                                        <c:when test="${course.status == 'SUBMITTED'}">
                                                            <div class="ins-activity-item__dot ins-activity-item__dot--orange"></div>
                                                            <div class="ins-activity-item__text">
                                                                Khóa học <strong>"<c:out value="${course.title}"/>"</strong> đang chờ Admin duyệt
                                                            </div>
                                                        </c:when>
                                                        <c:when test="${course.status == 'REJECTED'}">
                                                            <div class="ins-activity-item__dot ins-activity-item__dot--red"></div>
                                                            <div class="ins-activity-item__text">
                                                                Khóa học <strong>"<c:out value="${course.title}"/>"</strong> bị từ chối — hãy xem lý do và chỉnh sửa
                                                            </div>
                                                        </c:when>
                                                        <c:when test="${course.status == 'APPROVED'}">
                                                            <div class="ins-activity-item__dot ins-activity-item__dot--blue"></div>
                                                            <div class="ins-activity-item__text">
                                                                Khóa học <strong>"<c:out value="${course.title}"/>"</strong> đã được duyệt — sẵn sàng để xuất bản
                                                            </div>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <div class="ins-activity-item__dot ins-activity-item__dot--blue"></div>
                                                            <div class="ins-activity-item__text">
                                                                Khóa học <strong>"<c:out value="${course.title}"/>"</strong> đang được soạn thảo
                                                            </div>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </div>
                                            </c:if>
                                        </c:forEach>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <div style="text-align:center; padding:20px; color:var(--ins-muted); font-size:.83rem;">
                                        Chưa có hoạt động nào gần đây.
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>

                </div>
            </div>

        </main>
    </div>
</div>

<script>
/* User menu toggle */
function insToggleMenu(e) {
    e.stopPropagation();
    document.getElementById('insUserMenu').classList.toggle('open');
}
document.addEventListener('click', function() {
    var m = document.getElementById('insUserMenu');
    if (m) m.classList.remove('open');
});

/* Dot menu toggle */
function toggleDotMenu(el) {
    // close all others
    document.querySelectorAll('.ins-dot-menu.open').forEach(function(dm) {
        if (dm !== el) dm.classList.remove('open');
    });
    el.classList.toggle('open');
    event.stopPropagation();
}
document.addEventListener('click', function() {
    document.querySelectorAll('.ins-dot-menu.open').forEach(function(dm) {
        dm.classList.remove('open');
    });
});
</script>
</body>
</html>
