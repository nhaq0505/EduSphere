<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<c:set var="cp" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard Học Viên — EduSphere</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${cp}/assets/css/home.css">
    <style>
        .sd-main {
            background: #f4f7fb;
            min-height: calc(100vh - 66px);
            padding: 28px 0 56px;
        }
        .sd-container {
            max-width: 1180px;
            margin: 0 auto;
            padding: 0 24px;
            display: flex;
            flex-direction: column;
            gap: 20px;
        }

        /* Welcome Banner */
        .sd-banner {
            position: relative;
            overflow: hidden;
            border-radius: 18px;
            padding: 28px 36px;
            background: linear-gradient(125deg, #e0f2fe 0%, #bae6fd 45%, #7dd3fc 100%);
            border: 1px solid rgba(56, 189, 248, 0.35);
            box-shadow: 0 10px 28px rgba(14, 165, 233, 0.12);
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 24px;
        }
        .sd-banner__content {
            position: relative;
            z-index: 2;
        }
        .sd-banner__title {
            margin: 0 0 6px;
            font-size: 1.75rem;
            font-weight: 800;
            color: #0f172a;
            letter-spacing: -0.02em;
        }
        .sd-banner__sub {
            margin: 0;
            font-size: 0.96rem;
            color: #1e3a5f;
            font-weight: 500;
        }
        .sd-banner__art {
            position: relative;
            z-index: 2;
            flex-shrink: 0;
            display: flex;
            align-items: center;
        }
        .sd-banner__bg-circle {
            position: absolute;
            border-radius: 50%;
            background: rgba(255, 255, 255, 0.35);
            pointer-events: none;
        }

        /* Stat Cards (3 cards: Số giờ học, Khóa học đã tham gia, Đánh giá trung bình) */
        .sd-stats-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 16px;
        }
        .sd-stat-card {
            background: #ffffff;
            border-radius: 16px;
            padding: 18px 20px;
            border: 1.5px solid #e2e8f0;
            box-shadow: 0 4px 14px rgba(15, 23, 42, 0.04);
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            gap: 12px;
            text-decoration: none;
            color: inherit;
            transition: transform 0.15s ease, box-shadow 0.15s ease, border-color 0.15s ease;
        }
        .sd-stat-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 22px rgba(15, 23, 42, 0.08);
        }
        .sd-stat-card--primary {
            border-color: #60a5fa;
            background: linear-gradient(180deg, #f8fbff 0%, #ffffff 100%);
        }
        .sd-stat-card__top {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 14px;
        }
        .sd-stat-card__left {
            display: flex;
            align-items: center;
            gap: 14px;
        }
        .sd-stat-card__icon {
            width: 44px;
            height: 44px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            flex-shrink: 0;
        }
        .sd-stat-card__icon--blue { background: #eff6ff; color: #1d4ed8; }
        .sd-stat-card__icon--sky { background: #e0f2fe; color: #0284c7; }
        .sd-stat-card__icon--amber { background: #fef3c7; color: #d97706; }

        .sd-stat-card__label {
            font-size: 0.85rem;
            color: #64748b;
            font-weight: 600;
            margin-bottom: 3px;
        }
        .sd-stat-card__val {
            font-size: 1.32rem;
            font-weight: 800;
            color: #0f172a;
            letter-spacing: -0.01em;
        }
        .sd-stat-card__val span {
            font-size: 0.92rem;
            font-weight: 600;
            color: #475569;
        }
        .sd-stat-card__arrow {
            width: 28px;
            height: 28px;
            border-radius: 50%;
            background: #f1f5f9;
            color: #475569;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 0.9rem;
            font-weight: 700;
            flex-shrink: 0;
        }
        .sd-goal-bar-wrap {
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .sd-progress-track {
            flex: 1;
            height: 8px;
            border-radius: 999px;
            background: #e2e8f0;
            overflow: hidden;
        }
        .sd-progress-fill {
            height: 100%;
            border-radius: 999px;
            background: linear-gradient(90deg, #2563eb, #38bdf8);
            transition: width 0.35s ease;
        }
        .sd-goal-pct {
            font-size: 0.8rem;
            font-weight: 700;
            color: #334155;
            min-width: 34px;
            text-align: right;
        }

        /* Section Card */
        .sd-card {
            background: #ffffff;
            border-radius: 16px;
            padding: 20px 24px;
            border: 1px solid #e2e8f0;
            box-shadow: 0 4px 14px rgba(15, 23, 42, 0.04);
        }
        .sd-card__head {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 12px;
            margin-bottom: 18px;
        }
        .sd-card__title {
            display: flex;
            align-items: center;
            gap: 10px;
            font-size: 1.08rem;
            font-weight: 800;
            color: #0f172a;
            margin: 0;
        }
        .sd-link-pill {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 6px 14px;
            border-radius: 999px;
            border: 1px solid #e2e8f0;
            background: #ffffff;
            color: #334155;
            font-size: 0.84rem;
            font-weight: 600;
            text-decoration: none;
            transition: all 0.15s ease;
        }
        .sd-link-pill:hover {
            background: #f8fafc;
            border-color: #cbd5e1;
            color: #0f172a;
        }

        /* Active Course Row */
        .sd-course-list {
            display: flex;
            flex-direction: column;
            gap: 16px;
        }
        .sd-course-item {
            display: flex;
            align-items: center;
            gap: 20px;
            padding: 14px;
            border-radius: 14px;
            border: 1px solid #f1f5f9;
            background: #fafcff;
        }
        .sd-course-thumb {
            position: relative;
            width: 210px;
            height: 122px;
            border-radius: 12px;
            overflow: hidden;
            flex-shrink: 0;
            background: linear-gradient(135deg, #0f172a, #1d4ed8);
            display: flex;
            align-items: center;
            justify-content: center;
            color: #fff;
            font-weight: 800;
            font-size: 1.5rem;
        }
        .sd-course-thumb img {
            width: 100%;
            height: 100%;
            object-fit: cover;
            display: block;
        }
        .sd-course-badge {
            position: absolute;
            top: 10px;
            left: 10px;
            background: #2563eb;
            color: #ffffff;
            font-size: 0.72rem;
            font-weight: 700;
            padding: 4px 10px;
            border-radius: 999px;
            box-shadow: 0 2px 8px rgba(37, 99, 235, 0.35);
        }
        .sd-course-badge--done {
            background: #16a34a;
        }
        .sd-course-info {
            flex: 1;
            min-width: 0;
        }
        .sd-course-title {
            margin: 0 0 6px;
            font-size: 1.1rem;
            font-weight: 800;
            color: #0f172a;
        }
        .sd-course-desc {
            margin: 0 0 12px;
            font-size: 0.88rem;
            color: #64748b;
            display: -webkit-box;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
            overflow: hidden;
        }
        .sd-course-meta {
            font-size: 0.86rem;
            color: #334155;
            margin-bottom: 8px;
        }
        .sd-course-meta strong {
            color: #0f172a;
        }
        .sd-course-actions {
            flex-shrink: 0;
        }
        .sd-btn-continue {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 11px 20px;
            border-radius: 999px;
            background: linear-gradient(135deg, #2563eb, #1d4ed8);
            color: #ffffff;
            font-size: 0.9rem;
            font-weight: 700;
            text-decoration: none;
            box-shadow: 0 6px 16px rgba(37, 99, 235, 0.25);
            transition: transform 0.15s ease, box-shadow 0.15s ease;
        }
        .sd-btn-continue:hover {
            transform: translateY(-1px);
            box-shadow: 0 8px 20px rgba(37, 99, 235, 0.35);
        }

        /* Bottom 2 Columns */
        .sd-bottom-grid {
            display: grid;
            grid-template-columns: 1.6fr 1fr;
            gap: 20px;
            align-items: stretch;
        }

        /* Range filter pills */
        .sd-range-pills {
            display: inline-flex;
            background: #f1f5f9;
            padding: 3px;
            border-radius: 999px;
            gap: 2px;
        }
        .sd-range-btn {
            border: none;
            background: transparent;
            color: #475569;
            font-family: inherit;
            font-size: 0.82rem;
            font-weight: 600;
            padding: 6px 14px;
            border-radius: 999px;
            cursor: pointer;
            transition: all 0.15s ease;
        }
        .sd-range-btn.active {
            background: #2563eb;
            color: #ffffff;
            box-shadow: 0 2px 6px rgba(37, 99, 235, 0.25);
        }

        /* Chart container */
        .sd-chart-wrap {
            position: relative;
            width: 100%;
            height: 220px;
        }
        .sd-chart-tooltip {
            position: absolute;
            display: none;
            pointer-events: none;
            background: #0f172a;
            color: #ffffff;
            font-size: 0.78rem;
            font-weight: 600;
            padding: 6px 10px;
            border-radius: 8px;
            box-shadow: 0 6px 14px rgba(15, 23, 42, 0.2);
            white-space: nowrap;
            z-index: 10;
        }

        /* Achievement card */
        .sd-achievement-body {
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            text-align: center;
            padding: 18px 12px;
            min-height: 196px;
        }
        .sd-achievement-title {
            margin: 14px 0 4px;
            font-size: 1.12rem;
            font-weight: 800;
            color: #0f172a;
        }
        .sd-achievement-sub {
            margin: 0;
            font-size: 0.9rem;
            color: #64748b;
            font-weight: 500;
        }

        .sd-empty {
            text-align: center;
            padding: 28px 16px;
            color: #64748b;
        }

        @media (max-width: 960px) {
            .sd-stats-grid { grid-template-columns: 1fr; }
            .sd-bottom-grid { grid-template-columns: 1fr; }
            .sd-course-item { flex-direction: column; align-items: stretch; }
            .sd-course-thumb { width: 100%; height: 170px; }
        }
    </style>
</head>
<body>

<header class="hn-header">
    <div class="hn-header__inner">
        <a class="hn-logo" href="${cp}/">
            <div class="hn-logo__icon">🎓</div>
            <span>EduSphere</span>
        </a>
        <nav class="hn-nav">
            <a class="hn-nav__link" href="${cp}/">Trang chủ</a>
            <a class="hn-nav__link" href="${cp}/courses">Khóa học</a>
            <a class="hn-nav__link" href="#">Về chúng tôi</a>
            <a class="hn-nav__link" href="#">Liên hệ</a>
            <sec:authorize access="hasRole('STUDENT')">
                <a class="hn-nav__link hn-nav__link--active" href="${cp}/student/dashboard">Dashboard</a>
                <a class="hn-nav__link" href="${cp}/study/plans">Kế Hoạch &amp; Tiến Độ</a>
            </sec:authorize>
        </nav>
        <div class="hn-header__right">
            <div class="hn-search">
                <svg class="hn-search__icon" width="16" height="16" viewBox="0 0 20 20" fill="none">
                    <circle cx="9" cy="9" r="6" stroke="#94a3b8" stroke-width="1.8"/>
                    <path d="M14 14l3 3" stroke="#94a3b8" stroke-width="1.8" stroke-linecap="round"/>
                </svg>
                <input class="hn-search__input" type="text" placeholder="Tìm kiếm khóa học..."
                       onkeydown="if(event.key==='Enter') window.location='${cp}/courses?q='+encodeURIComponent(this.value)">
            </div>
            <button class="hn-icon-btn" aria-label="Thông báo">
                <svg viewBox="0 0 24 24" fill="none" width="20" height="20">
                    <path d="M15 17h5l-1.4-1.4A2 2 0 0118 14V11a6 6 0 00-4-5.66V5a2 2 0 10-4 0v.34A6 6 0 006 11v3a2 2 0 01-.6 1.4L4 17h5m6 0v1a3 3 0 01-6 0v-1m6 0H9" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"/>
                </svg>
            </button>
            <sec:authorize access="isAuthenticated()">
                <div class="hn-user-menu">
                    <button class="hn-user-btn" onclick="toggleUserMenu(event)">
                        <div class="hn-user-btn__avatar">
                            <svg viewBox="0 0 24 24" fill="none" width="18" height="18">
                                <circle cx="12" cy="8" r="4" stroke="currentColor" stroke-width="1.8"/>
                                <path d="M4 20c0-4 3.6-7 8-7s8 3 8 7" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/>
                            </svg>
                        </div>
                        <span class="hn-user-btn__name"><sec:authentication property="principal.fullName"/></span>
                        <svg class="hn-user-btn__arrow" viewBox="0 0 12 8" fill="none" width="10" height="10">
                            <path d="M1 1l5 5 5-5" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"/>
                        </svg>
                    </button>
                    <div class="hn-user-dropdown" id="userDropdown">
                        <div class="hn-user-dropdown__head">
                            <div class="hn-user-dropdown__avatar-icon">
                                <svg viewBox="0 0 24 24" fill="none" width="20" height="20">
                                    <circle cx="12" cy="8" r="4" stroke="white" stroke-width="1.8"/>
                                    <path d="M4 20c0-4 3.6-7 8-7s8 3 8 7" stroke="white" stroke-width="1.8" stroke-linecap="round"/>
                                </svg>
                            </div>
                            <span><sec:authentication property="principal.fullName"/></span>
                        </div>
                        <div class="hn-user-dropdown__body">
                            <a class="hn-user-dropdown__item" href="${cp}/profile">Thông tin cá nhân</a>
                            <a class="hn-user-dropdown__item" href="${cp}/student/dashboard">Dashboard</a>
                            <a class="hn-user-dropdown__item" href="${cp}/my-courses">Khóa học của tôi</a>
                            <a class="hn-user-dropdown__item" href="${cp}/change-password">Đổi mật khẩu</a>
                            <div class="hn-user-dropdown__divider"></div>
                            <form method="post" action="${cp}/logout" style="margin:0">
                                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                <button class="hn-user-dropdown__item hn-user-dropdown__item--danger" type="submit">Đăng xuất</button>
                            </form>
                        </div>
                    </div>
                </div>
            </sec:authorize>
        </div>
    </div>
</header>

<main class="sd-main">
    <div class="sd-container">

        <%-- 1. WELCOME BANNER --%>
        <section class="sd-banner">
            <div class="sd-banner__bg-circle" style="width:220px;height:220px;top:-90px;right:140px;"></div>
            <div class="sd-banner__bg-circle" style="width:140px;height:140px;bottom:-60px;right:20px;"></div>

            <div class="sd-banner__content">
                <h1 class="sd-banner__title">Xin chào, <c:out value="${dashboard.studentName}"/>! 👋</h1>
                <p class="sd-banner__sub">Cùng EduSphere khám phá tri thức và phát triển bản thân mỗi ngày!</p>
            </div>

            <div class="sd-banner__art" aria-hidden="true">
                <svg width="160" height="92" viewBox="0 0 160 92" fill="none">
                    <!-- Paper plane -->
                    <path d="M10 34L44 20L32 48L24 38L10 34Z" fill="#ffffff" fill-opacity="0.9"/>
                    <path d="M24 38L44 20L29 44" stroke="#60a5fa" stroke-width="1.5"/>
                    <path d="M18 52C28 60 44 58 54 46" stroke="#ffffff" stroke-opacity="0.6" stroke-width="1.8" stroke-dasharray="3 4"/>
                    <!-- Book -->
                    <rect x="66" y="54" width="76" height="24" rx="5" fill="#1d4ed8"/>
                    <rect x="70" y="57" width="68" height="18" rx="3" fill="#eff6ff"/>
                    <rect x="66" y="50" width="76" height="8" rx="3" fill="#3b82f6"/>
                    <!-- Graduation Cap -->
                    <path d="M104 10L142 26L104 42L66 26L104 10Z" fill="#1e3a8a"/>
                    <path d="M82 33V48C82 52 92 56 104 56C116 56 126 52 126 48V33L104 42L82 33Z" fill="#1e40af"/>
                    <path d="M134 29V48" stroke="#f59e0b" stroke-width="2.5" stroke-linecap="round"/>
                    <circle cx="134" cy="50" r="3.5" fill="#fbbf24"/>
                </svg>
            </div>
        </section>

        <%-- 2. SUMMARY STATS (3 CARDS — KHÔNG CÓ CHỨNG CHỈ, TẬP TRUNG SỐ GIỜ HỌC) --%>
        <section class="sd-stats-grid">
            <%-- Số giờ học --%>
            <div class="sd-stat-card sd-stat-card--primary">
                <div class="sd-stat-card__top">
                    <div class="sd-stat-card__left">
                        <div class="sd-stat-card__icon sd-stat-card__icon--blue">
                            <svg width="22" height="22" viewBox="0 0 24 24" fill="none">
                                <circle cx="12" cy="12" r="9" stroke="currentColor" stroke-width="2"/>
                                <path d="M12 7v5l3.5 2" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
                            </svg>
                        </div>
                        <div>
                            <div class="sd-stat-card__label">Số giờ học</div>
                            <div class="sd-stat-card__val">
                                <c:out value="${dashboard.totalStudyHoursFormatted}"/>
                                <span>/ <c:out value="${dashboard.targetStudyHoursFormatted}"/> giờ</span>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="sd-goal-bar-wrap">
                    <div class="sd-progress-track">
                        <div class="sd-progress-fill" style="width:${dashboard.studyGoalPercent}%;"></div>
                    </div>
                    <span class="sd-goal-pct"><c:out value="${dashboard.studyGoalPercent}"/>%</span>
                </div>
            </div>

            <%-- Khóa học đã tham gia --%>
            <a class="sd-stat-card" href="${cp}/my-courses">
                <div class="sd-stat-card__top">
                    <div class="sd-stat-card__left">
                        <div class="sd-stat-card__icon sd-stat-card__icon--sky">
                            <svg width="22" height="22" viewBox="0 0 24 24" fill="none">
                                <path d="M4 19.5A2.5 2.5 0 016.5 17H20" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
                                <path d="M6.5 2H20v20H6.5A2.5 2.5 0 014 19.5v-15A2.5 2.5 0 016.5 2z" stroke="currentColor" stroke-width="2"/>
                            </svg>
                        </div>
                        <div>
                            <div class="sd-stat-card__label">Khóa học đã tham gia</div>
                            <div class="sd-stat-card__val">
                                <c:out value="${dashboard.enrolledCoursesCount}"/> <span>khóa học</span>
                            </div>
                        </div>
                    </div>
                    <span class="sd-stat-card__arrow">&gt;</span>
                </div>
            </a>

            <%-- Đánh giá trung bình --%>
            <a class="sd-stat-card" href="${cp}/courses">
                <div class="sd-stat-card__top">
                    <div class="sd-stat-card__left">
                        <div class="sd-stat-card__icon sd-stat-card__icon--amber">
                            <svg width="22" height="22" viewBox="0 0 24 24" fill="currentColor">
                                <path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z"/>
                            </svg>
                        </div>
                        <div>
                            <div class="sd-stat-card__label">Đánh giá trung bình</div>
                            <div class="sd-stat-card__val">
                                <c:choose>
                                    <c:when test="${dashboard.hasRatings}">
                                        <c:out value="${dashboard.averageRatingFormatted}"/><span>/5</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span>Chưa có</span>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                    </div>
                    <span class="sd-stat-card__arrow">&gt;</span>
                </div>
            </a>
        </section>

        <%-- 3. KHÓA HỌC ĐANG HỌC --%>
        <section class="sd-card">
            <div class="sd-card__head">
                <h2 class="sd-card__title">
                    <span style="color:#2563eb;">📘</span>
                    <span>Khóa học đang học</span>
                </h2>
                <a class="sd-link-pill" href="${cp}/my-courses">Xem tất cả →</a>
            </div>

            <c:choose>
                <c:when test="${empty dashboard.activeCourses}">
                    <div class="sd-empty">
                        <p style="margin:0 0 14px;font-size:.96rem;">Bạn chưa ghi danh khóa học nào.</p>
                        <a class="sd-btn-continue" href="${cp}/courses">Khám phá khóa học →</a>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="sd-course-list">
                        <c:forEach var="course" items="${dashboard.activeCourses}" begin="0" end="2">
                            <article class="sd-course-item">
                                <div class="sd-course-thumb">
                                    <c:if test="${not empty course.thumbnailUrl}">
                                        <img src="${course.thumbnailUrl}" alt="<c:out value='${course.title}'/>">
                                    </c:if>
                                    <c:if test="${empty course.thumbnailUrl}">
                                        <span>🎓</span>
                                    </c:if>
                                    <span class="sd-course-badge ${course.completed ? 'sd-course-badge--done' : ''}">
                                        <c:out value="${course.completed ? 'Đã hoàn thành' : 'Đang học'}"/>
                                    </span>
                                </div>

                                <div class="sd-course-info">
                                    <h3 class="sd-course-title"><c:out value="${course.title}"/></h3>
                                    <p class="sd-course-desc"><c:out value="${course.description}"/></p>
                                    <div class="sd-course-meta">
                                        Tiến độ: <strong><c:out value="${course.progressPercent}"/>%</strong>
                                        &bull;
                                        Đã học <strong><c:out value="${course.studiedHoursFormatted}"/> / <c:out value="${course.targetHoursFormatted}"/> giờ</strong>
                                    </div>
                                    <div class="sd-progress-track" style="max-width:460px;">
                                        <div class="sd-progress-fill" style="width:${course.progressPercent}%;"></div>
                                    </div>
                                </div>

                                <div class="sd-course-actions">
                                    <a class="sd-btn-continue" href="${cp}/courses/${course.courseId}/learn">
                                        <span>▶</span>
                                        <span>Tiếp tục học</span>
                                    </a>
                                </div>
                            </article>
                        </c:forEach>
                    </div>
                </c:otherwise>
            </c:choose>
        </section>

        <%-- 4. THỐNG KÊ HỌC TẬP & THÀNH TÍCH --%>
        <section class="sd-bottom-grid">
            <div class="sd-card">
                <div class="sd-card__head">
                    <h2 class="sd-card__title">
                        <span style="color:#2563eb;">📊</span>
                        <span>Thống kê học tập</span>
                    </h2>
                    <div class="sd-range-pills" role="tablist">
                        <button type="button" class="sd-range-btn active" onclick="switchChartRange('7d', this)">7 ngày</button>
                        <button type="button" class="sd-range-btn" onclick="switchChartRange('30d', this)">30 ngày</button>
                        <button type="button" class="sd-range-btn" onclick="switchChartRange('3m', this)">3 tháng</button>
                    </div>
                </div>
                <div class="sd-chart-wrap" id="studyChartWrap">
                    <canvas id="studyChartCanvas" style="width:100%;height:100%;display:block;"></canvas>
                    <div id="studyChartTooltip" class="sd-chart-tooltip"></div>
                </div>
            </div>

            <div class="sd-card">
                <div class="sd-card__head" style="margin-bottom:8px;">
                    <h2 class="sd-card__title">
                        <span style="color:#d97706;">🏆</span>
                        <span>Thành tích của bạn</span>
                    </h2>
                </div>
                <div class="sd-achievement-body">
                    <svg width="96" height="96" viewBox="0 0 96 96" fill="none" aria-hidden="true">
                        <!-- Confetti dots -->
                        <circle cx="14" cy="30" r="3" fill="#ef4444"/>
                        <circle cx="82" cy="26" r="3" fill="#3b82f6"/>
                        <circle cx="18" cy="64" r="2.5" fill="#10b981"/>
                        <circle cx="78" cy="68" r="2.5" fill="#f59e0b"/>
                        <!-- Ribbons -->
                        <path d="M36 56L26 84L40 76L48 86V56H36Z" fill="#2563eb"/>
                        <path d="M60 56L70 84L56 76L48 86V56H60Z" fill="#1d4ed8"/>
                        <!-- Medal outer -->
                        <circle cx="48" cy="40" r="26" fill="#fbbf24"/>
                        <circle cx="48" cy="40" r="20" fill="#f59e0b"/>
                        <circle cx="48" cy="40" r="16" fill="#fde68a"/>
                        <!-- Star -->
                        <path d="M48 28l3.5 7.2 7.9 1.1-5.7 5.5 1.3 7.8L48 45.9l-7 3.7 1.3-7.8-5.7-5.5 7.9-1.1L48 28z" fill="#f59e0b"/>
                    </svg>
                    <h3 class="sd-achievement-title"><c:out value="${dashboard.achievementTitle}"/></h3>
                    <p class="sd-achievement-sub"><c:out value="${dashboard.achievementSubtitle}"/></p>
                </div>
            </div>
        </section>

    </div>
</main>

<script>
function toggleUserMenu(e) {
    e.stopPropagation();
    document.getElementById('userDropdown').closest('.hn-user-menu').classList.toggle('open');
}
document.addEventListener('click', function() {
    document.querySelectorAll('.hn-user-menu.open').forEach(function(m) { m.classList.remove('open'); });
});

var chartDatasets = {
    '7d': {
        labels: ${dashboard.chart7dLabelsJson},
        values: ${dashboard.chart7dValuesJson}
    },
    '30d': {
        labels: ${dashboard.chart30dLabelsJson},
        values: ${dashboard.chart30dValuesJson}
    },
    '3m': {
        labels: ${dashboard.chart3mLabelsJson},
        values: ${dashboard.chart3mValuesJson}
    }
};

var currentRange = '7d';
var chartPoints = [];

function switchChartRange(range, btn) {
    currentRange = range;
    document.querySelectorAll('.sd-range-btn').forEach(function(b) { b.classList.remove('active'); });
    if (btn) btn.classList.add('active');
    drawStudyChart();
}

function drawStudyChart() {
    var canvas = document.getElementById('studyChartCanvas');
    var wrap = document.getElementById('studyChartWrap');
    if (!canvas || !wrap) return;

    var dpr = window.devicePixelRatio || 1;
    var width = wrap.clientWidth;
    var height = wrap.clientHeight;
    canvas.width = width * dpr;
    canvas.height = height * dpr;

    var ctx = canvas.getContext('2d');
    ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
    ctx.clearRect(0, 0, width, height);

    var ds = chartDatasets[currentRange] || { labels: [], values: [] };
    var labels = ds.labels || [];
    var values = ds.values || [];
    if (labels.length === 0) return;

    var padLeft = 42;
    var padRight = 18;
    var padTop = 18;
    var padBottom = 32;
    var plotW = Math.max(40, width - padLeft - padRight);
    var plotH = Math.max(40, height - padTop - padBottom);

    var maxVal = Math.max.apply(null, values);
    var yMax = Math.max(4, Math.ceil(maxVal));
    var ySteps = 4;

    ctx.font = '12px Inter, sans-serif';
    ctx.fillStyle = '#64748b';
    ctx.strokeStyle = '#e2e8f0';
    ctx.lineWidth = 1;

    for (var i = 0; i <= ySteps; i++) {
        var yVal = (yMax / ySteps) * i;
        var yPos = padTop + plotH - (i / ySteps) * plotH;
        ctx.beginPath();
        ctx.moveTo(padLeft, yPos);
        ctx.lineTo(padLeft + plotW, yPos);
        ctx.stroke();
        ctx.textAlign = 'right';
        ctx.textBaseline = 'middle';
        ctx.fillText((Number.isInteger(yVal) ? yVal : yVal.toFixed(1)) + 'h', padLeft - 8, yPos);
    }

    chartPoints = [];
    var n = labels.length;
    for (var j = 0; j < n; j++) {
        var x = n === 1 ? padLeft + plotW / 2 : padLeft + (j / (n - 1)) * plotW;
        var v = Number(values[j] || 0);
        var y = padTop + plotH - Math.min(1, v / yMax) * plotH;
        chartPoints.push({ x: x, y: y, label: labels[j], value: v });
    }

    // Area fill
    var grad = ctx.createLinearGradient(0, padTop, 0, padTop + plotH);
    grad.addColorStop(0, 'rgba(37, 99, 235, 0.22)');
    grad.addColorStop(1, 'rgba(37, 99, 235, 0.01)');

    ctx.beginPath();
    ctx.moveTo(chartPoints[0].x, padTop + plotH);
    for (var k = 0; k < chartPoints.length; k++) {
        ctx.lineTo(chartPoints[k].x, chartPoints[k].y);
    }
    ctx.lineTo(chartPoints[chartPoints.length - 1].x, padTop + plotH);
    ctx.closePath();
    ctx.fillStyle = grad;
    ctx.fill();

    // Line
    ctx.beginPath();
    for (var k2 = 0; k2 < chartPoints.length; k2++) {
        if (k2 === 0) ctx.moveTo(chartPoints[k2].x, chartPoints[k2].y);
        else ctx.lineTo(chartPoints[k2].x, chartPoints[k2].y);
    }
    ctx.strokeStyle = '#1d4ed8';
    ctx.lineWidth = 2.4;
    ctx.stroke();

    // Points & X-axis labels
    var labelStep = n > 10 ? Math.ceil(n / 7) : 1;
    for (var p = 0; p < chartPoints.length; p++) {
        var pt = chartPoints[p];
        if (n <= 12 || p === n - 1 || p % labelStep === 0) {
            ctx.fillStyle = '#475569';
            ctx.textAlign = 'center';
            ctx.textBaseline = 'top';
            ctx.fillText(pt.label, pt.x, padTop + plotH + 10);
        }
        if (n <= 15 || pt.value > 0) {
            ctx.beginPath();
            ctx.arc(pt.x, pt.y, 4, 0, Math.PI * 2);
            ctx.fillStyle = '#ffffff';
            ctx.fill();
            ctx.lineWidth = 2.2;
            ctx.strokeStyle = '#1d4ed8';
            ctx.stroke();
        }
    }
}

document.addEventListener('DOMContentLoaded', function() {
    drawStudyChart();
    window.addEventListener('resize', drawStudyChart);

    var canvas = document.getElementById('studyChartCanvas');
    var tooltip = document.getElementById('studyChartTooltip');
    if (canvas && tooltip) {
        canvas.addEventListener('mousemove', function(e) {
            var rect = canvas.getBoundingClientRect();
            var mx = e.clientX - rect.left;
            var best = null;
            var bestDist = 24;
            for (var i = 0; i < chartPoints.length; i++) {
                var d = Math.abs(chartPoints[i].x - mx);
                if (d < bestDist) {
                    bestDist = d;
                    best = chartPoints[i];
                }
            }
            if (best) {
                tooltip.style.display = 'block';
                tooltip.textContent = best.label + ': ' + best.value.toFixed(2) + ' giờ';
                tooltip.style.left = Math.min(rect.width - 130, Math.max(8, best.x - 45)) + 'px';
                tooltip.style.top = Math.max(4, best.y - 34) + 'px';
            } else {
                tooltip.style.display = 'none';
            }
        });
        canvas.addEventListener('mouseleave', function() {
            tooltip.style.display = 'none';
        });
    }
});
</script>
</body>
</html>
