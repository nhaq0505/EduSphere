<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<c:set var="cp" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Khóa học &amp; Kho tín chỉ của tôi — EduSphere</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${cp}/assets/css/home.css">
    <link rel="stylesheet" href="${cp}/assets/css/my-courses.css">
    <style>
        /* Coursera-style Tabs & Certificates Repository (Image 1) */
        .mc-credit-banner {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(210px, 1fr));
            gap: 16px;
            margin-bottom: 28px;
        }
        .mc-stat-card {
            background: #ffffff;
            border: 1px solid #e2e8f0;
            border-radius: 12px;
            padding: 18px 22px;
            display: flex;
            align-items: center;
            gap: 16px;
            box-shadow: 0 2px 6px rgba(15, 23, 42, 0.04);
        }
        .mc-stat-card--highlight {
            background: linear-gradient(135deg, #eff6ff 0%, #dbeafe 100%);
            border-color: #93c5fd;
        }
        .mc-stat-card__icon {
            width: 48px;
            height: 48px;
            border-radius: 12px;
            background: #f1f5f9;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.5rem;
            flex-shrink: 0;
        }
        .mc-stat-card--highlight .mc-stat-card__icon {
            background: #2563eb;
            color: #ffffff;
        }
        .mc-stat-card__val {
            font-size: 1.55rem;
            font-weight: 800;
            color: #0f172a;
            line-height: 1.1;
        }
        .mc-stat-card__lbl {
            font-size: 0.82rem;
            color: #64748b;
            font-weight: 500;
            margin-top: 3px;
        }

        /* Coursera Navigation Tabs */
        .cs-tabs {
            display: flex;
            align-items: center;
            gap: 32px;
            border-bottom: 1px solid #e2e8f0;
            margin-bottom: 28px;
            overflow-x: auto;
        }
        .cs-tab {
            background: none;
            border: none;
            border-bottom: 3px solid transparent;
            padding: 12px 2px 14px;
            font-family: inherit;
            font-size: 0.95rem;
            font-weight: 500;
            color: #64748b;
            cursor: pointer;
            white-space: nowrap;
            transition: color 0.15s ease, border-color 0.15s ease;
            display: inline-flex;
            align-items: center;
            gap: 8px;
        }
        .cs-tab:hover {
            color: #0f172a;
        }
        .cs-tab.active {
            color: #0f172a;
            font-weight: 700;
            border-bottom-color: #0f172a;
        }
        .cs-tab__badge {
            background: #e2e8f0;
            color: #334155;
            font-size: 0.74rem;
            font-weight: 700;
            padding: 2px 8px;
            border-radius: 999px;
        }
        .cs-tab.active .cs-tab__badge {
            background: #0056d2;
            color: #ffffff;
        }

        .cs-panel {
            display: none;
        }
        .cs-panel.active {
            display: block;
        }

        /* Section Title inside Certificates & Badges */
        .cb-section-title {
            font-size: 1.35rem;
            font-weight: 700;
            color: #1f1f1f;
            margin: 0 0 22px;
        }

        /* 3-Column Grid matching Image 1 */
        .cb-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 24px;
        }
        .cb-card {
            background: #ffffff;
            border: 1px solid #e2e8f0;
            border-radius: 10px;
            padding: 20px;
            display: flex;
            flex-direction: column;
            transition: box-shadow 0.2s ease, transform 0.2s ease;
        }
        .cb-card:hover {
            box-shadow: 0 10px 24px rgba(15, 23, 42, 0.08);
            transform: translateY(-2px);
        }
        .cb-card__preview {
            height: 185px;
            background: #d8dee9;
            border: 1px solid #cbd5e1;
            border-radius: 4px;
            margin-bottom: 18px;
            position: relative;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            padding: 16px;
            text-align: center;
            text-decoration: none;
            overflow: hidden;
        }
        .cb-card__preview-inner {
            background: rgba(255, 255, 255, 0.92);
            border: 1px solid #cbd5e1;
            border-radius: 4px;
            width: 88%;
            height: 82%;
            padding: 12px 14px;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            text-align: left;
            box-shadow: 0 4px 12px rgba(15, 23, 42, 0.06);
            position: relative;
        }
        .cb-card__preview-ribbon {
            position: absolute;
            top: 0;
            right: 14px;
            width: 34px;
            height: 78%;
            background: #e2e8f0;
            border-left: 1px solid #cbd5e1;
            border-right: 1px solid #cbd5e1;
            display: flex;
            align-items: center;
            justify-content: center;
            clip-path: polygon(0 0, 100% 0, 100% 100%, 50% 86%, 0 100%);
        }
        .cb-card__preview-seal {
            width: 22px;
            height: 22px;
            border-radius: 50%;
            border: 1.5px solid #475569;
            background: #ffffff;
            font-size: 8px;
            font-weight: 800;
            color: #1e293b;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .cb-card__preview-brand {
            display: flex;
            align-items: center;
            gap: 6px;
            font-size: 0.62rem;
            font-weight: 800;
            color: #00274c;
            letter-spacing: 0.05em;
        }
        .cb-card__preview-brand span.box {
            background: #00274c;
            color: #ffcb05;
            width: 16px;
            height: 16px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            border-radius: 2px;
            font-size: 0.6rem;
        }
        .cb-card__preview-course {
            font-size: 0.72rem;
            font-weight: 700;
            color: #1e293b;
            line-height: 1.3;
            max-width: 72%;
            display: -webkit-box;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
            overflow: hidden;
        }
        .cb-card__preview-footer {
            display: flex;
            align-items: center;
            justify-content: space-between;
            font-size: 0.65rem;
            color: #64748b;
        }
        .cb-card__credits-tag {
            background: #0056d2;
            color: #ffffff;
            font-weight: 700;
            padding: 2px 8px;
            border-radius: 999px;
            font-size: 0.65rem;
        }
        .cb-card__title {
            font-size: 1.05rem;
            font-weight: 700;
            color: #1f1f1f;
            line-height: 1.4;
            margin: 0 0 12px;
        }
        .cb-card__title a {
            color: inherit;
            text-decoration: none;
        }
        .cb-card__title a:hover {
            color: #0056d2;
        }
        .cb-card__links {
            display: flex;
            align-items: center;
            gap: 18px;
            margin-bottom: 12px;
            flex-wrap: wrap;
        }
        .cb-card__link {
            color: #0056d2;
            font-size: 0.88rem;
            font-weight: 700;
            text-decoration: none;
            cursor: pointer;
            background: none;
            border: none;
            padding: 0;
            font-family: inherit;
        }
        .cb-card__link:hover {
            text-decoration: underline;
            color: #00419e;
        }
        .cb-card__provider {
            font-size: 0.86rem;
            color: #5f6368;
            margin: 0 0 6px;
        }
        .cb-card__completed {
            font-size: 0.86rem;
            color: #5f6368;
            margin: 0;
        }

        /* Progress & Credit bar inside regular course cards */
        .mc-card__credit-pill {
            position: absolute;
            top: 12px;
            left: 12px;
            background: rgba(15, 23, 42, 0.78);
            color: #fde047;
            font-size: 0.75rem;
            font-weight: 700;
            padding: 4px 10px;
            border-radius: 999px;
            backdrop-filter: blur(4px);
        }
        .mc-card__progress-wrap {
            margin: 10px 0 14px;
        }
        .mc-card__progress-head {
            display: flex;
            justify-content: space-between;
            font-size: 0.78rem;
            color: #64748b;
            font-weight: 600;
            margin-bottom: 5px;
        }
        .mc-card__progress-bar {
            height: 7px;
            background: #e2e8f0;
            border-radius: 999px;
            overflow: hidden;
        }
        .mc-card__progress-fill {
            height: 100%;
            background: linear-gradient(90deg, #2563eb, #10b981);
            border-radius: 999px;
        }

        @media (max-width: 992px) {
            .cb-grid {
                grid-template-columns: repeat(2, 1fr);
            }
        }
        @media (max-width: 640px) {
            .cb-grid {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>

<jsp:include page="/WEB-INF/views/common/navbar.jsp"/>

<!-- ══════ MAIN ══════ -->
<main class="mc-main">
    <div class="hn-container">

        <!-- Page header -->
        <div class="mc-page-head">
            <div>
                <span class="mc-page-head__eyebrow">Không gian học viên &amp; Tích lũy tín chỉ</span>
                <h1 class="mc-page-head__title">Khóa học &amp; Kho tín chỉ của tôi</h1>
                <p class="mc-page-head__sub">Theo dõi tiến độ học tập, nhận tín chỉ và quản lý chứng chỉ hoàn thành khóa học.</p>
            </div>
            <a class="hn-btn hn-btn--primary" href="${cp}/courses">
                + Khám phá thêm khóa học
            </a>
        </div>

        <!-- Flash messages -->
        <c:if test="${not empty success}">
            <div class="mc-alert mc-alert--success">✅ <c:out value="${success}"/></div>
        </c:if>

        <!-- Compute counts for tabs -->
        <c:set var="inProgressCount" value="0"/>
        <c:set var="completedCount" value="0"/>
        <c:forEach var="cItem" items="${courses}">
            <c:choose>
                <c:when test="${cItem.completed}">
                    <c:set var="completedCount" value="${completedCount + 1}"/>
                </c:when>
                <c:when test="${cItem.enrollmentStatus == 'ACTIVE'}">
                    <c:set var="inProgressCount" value="${inProgressCount + 1}"/>
                </c:when>
            </c:choose>
        </c:forEach>
        <c:set var="certCount" value="${not empty certificates ? fn:length(certificates) : 0}"/>

        <!-- Credit & Progress Summary Cards -->
        <div class="mc-credit-banner">
            <div class="mc-stat-card mc-stat-card--highlight">
                <div class="mc-stat-card__icon">🎓</div>
                <div>
                    <div class="mc-stat-card__val"><c:out value="${not empty totalCreditsEarned ? totalCreditsEarned : 0}"/> Tín chỉ</div>
                    <div class="mc-stat-card__lbl">Tổng tín chỉ đã tích lũy</div>
                </div>
            </div>
            <div class="mc-stat-card">
                <div class="mc-stat-card__icon">📜</div>
                <div>
                    <div class="mc-stat-card__val"><c:out value="${certCount}"/></div>
                    <div class="mc-stat-card__lbl">Chứng chỉ đã cấp</div>
                </div>
            </div>
            <div class="mc-stat-card">
                <div class="mc-stat-card__icon">📖</div>
                <div>
                    <div class="mc-stat-card__val"><c:out value="${inProgressCount}"/></div>
                    <div class="mc-stat-card__lbl">Khóa học đang học</div>
                </div>
            </div>
            <div class="mc-stat-card">
                <div class="mc-stat-card__icon">✅</div>
                <div>
                    <div class="mc-stat-card__val"><c:out value="${completedCount}"/></div>
                    <div class="mc-stat-card__lbl">Khóa học đã hoàn thành</div>
                </div>
            </div>
        </div>

        <!-- Coursera-style Horizontal Tabs (matching Screenshot 1) -->
        <c:set var="currentTab" value="${not empty activeTab ? activeTab : 'all'}"/>
        <div class="cs-tabs" role="tablist">
            <button type="button" class="cs-tab ${currentTab == 'in-progress' ? 'active' : ''}"
                    onclick="switchTab('in-progress', this)">
                In Progress
                <span class="cs-tab__badge"><c:out value="${inProgressCount}"/></span>
            </button>
            <button type="button" class="cs-tab ${currentTab == 'completed' ? 'active' : ''}"
                    onclick="switchTab('completed', this)">
                Completed
                <span class="cs-tab__badge"><c:out value="${completedCount}"/></span>
            </button>
            <button type="button" class="cs-tab ${currentTab == 'all' ? 'active' : ''}"
                    onclick="switchTab('all', this)">
                Saved / All
                <span class="cs-tab__badge"><c:out value="${not empty courses ? fn:length(courses) : 0}"/></span>
            </button>
            <button type="button" class="cs-tab ${currentTab == 'certificates' ? 'active' : ''}"
                    onclick="switchTab('certificates', this)">
                Certificates &amp; Badges
                <span class="cs-tab__badge"><c:out value="${certCount}"/></span>
            </button>
        </div>

        <!-- ══════ TAB 1: IN PROGRESS ══════ -->
        <div id="panel-in-progress" class="cs-panel ${currentTab == 'in-progress' ? 'active' : ''}">
            <c:choose>
                <c:when test="${inProgressCount == 0}">
                    <div class="mc-empty">
                        <div class="mc-empty__icon">📚</div>
                        <h2>Không có khóa học nào đang học dở</h2>
                        <p>Khám phá thêm khóa học mới hoặc xem các chứng chỉ bạn đã đạt được ở mục Certificates &amp; Badges.</p>
                        <a class="hn-btn hn-btn--primary" href="${cp}/courses">Khám phá khóa học</a>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="mc-grid">
                        <c:forEach var="course" items="${courses}">
                            <c:if test="${not course.completed and course.enrollmentStatus == 'ACTIVE'}">
                                <article class="mc-card">
                                    <div class="mc-card__thumb">
                                        <span class="mc-card__credit-pill">🎓 <c:out value="${course.credits}"/> Tín chỉ</span>
                                        <span class="mc-card__thumb-icon">📖</span>
                                        <span class="mc-card__status mc-card__status--active">▶ Đang học</span>
                                    </div>
                                    <div class="mc-card__body">
                                        <h3 class="mc-card__title">
                                            <a href="${cp}/courses/${course.courseId}"><c:out value="${course.title}"/></a>
                                        </h3>
                                        <p class="mc-card__instructor">👤 <c:out value="${course.instructorName}"/></p>
                                        <div class="mc-card__progress-wrap">
                                            <div class="mc-card__progress-head">
                                                <span>Tiến độ (<c:out value="${course.completedLessons}/${course.totalLessons}"/> bài)</span>
                                                <span><c:out value="${course.progressPercent}"/>%</span>
                                            </div>
                                            <div class="mc-card__progress-bar">
                                                <div class="mc-card__progress-fill" style="width:${course.progressPercent}%"></div>
                                            </div>
                                        </div>
                                        <div class="mc-card__actions">
                                            <a class="hn-btn hn-btn--primary mc-btn-sm" href="${cp}/courses/${course.courseId}/learn">
                                                Tiếp tục học →
                                            </a>
                                            <a class="hn-btn mc-btn-outline mc-btn-sm" href="${cp}/courses/${course.courseId}/results">
                                                📊 Kết quả
                                            </a>
                                        </div>
                                    </div>
                                </article>
                            </c:if>
                        </c:forEach>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>

        <!-- ══════ TAB 2: COMPLETED ══════ -->
        <div id="panel-completed" class="cs-panel ${currentTab == 'completed' ? 'active' : ''}">
            <c:choose>
                <c:when test="${completedCount == 0}">
                    <div class="mc-empty">
                        <div class="mc-empty__icon">🎓</div>
                        <h2>Chưa có khóa học nào hoàn thành</h2>
                        <p>Hoàn thành 100% các bài giảng trong khóa học để nhận tín chỉ và chứng chỉ điện tử.</p>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="mc-grid">
                        <c:forEach var="course" items="${courses}">
                            <c:if test="${course.completed}">
                                <article class="mc-card">
                                    <div class="mc-card__thumb">
                                        <span class="mc-card__credit-pill">🎓 +<c:out value="${course.credits}"/> Tín chỉ</span>
                                        <span class="mc-card__thumb-icon">🏆</span>
                                        <span class="mc-card__status mc-card__status--done">✅ Hoàn thành</span>
                                    </div>
                                    <div class="mc-card__body">
                                        <h3 class="mc-card__title">
                                            <a href="${cp}/courses/${course.courseId}"><c:out value="${course.title}"/></a>
                                        </h3>
                                        <p class="mc-card__instructor">
                                            👤 <c:out value="${course.instructorName}"/> • Completed <c:out value="${course.formattedCompletedMonthYear}"/>
                                        </p>
                                        <div class="mc-card__progress-wrap">
                                            <div class="mc-card__progress-head">
                                                <span>Đã hoàn thành 100%</span>
                                                <span>+<c:out value="${course.credits}"/> Tín chỉ</span>
                                            </div>
                                            <div class="mc-card__progress-bar">
                                                <div class="mc-card__progress-fill" style="width:100%"></div>
                                            </div>
                                        </div>
                                        <div class="mc-card__actions">
                                            <c:choose>
                                                <c:when test="${not empty course.certificateId}">
                                                    <a class="hn-btn hn-btn--primary mc-btn-sm"
                                                       href="${cp}/certificates/${course.certificateId}">
                                                        🎓 Xem Chứng chỉ
                                                    </a>
                                                </c:when>
                                                <c:otherwise>
                                                    <a class="hn-btn hn-btn--primary mc-btn-sm"
                                                       href="${cp}/courses/${course.courseId}/certificate">
                                                        🎓 Nhận Chứng chỉ &amp; Tín chỉ
                                                    </a>
                                                </c:otherwise>
                                            </c:choose>
                                            <a class="hn-btn mc-btn-outline mc-btn-sm"
                                               href="${cp}/courses/${course.courseId}/learn">
                                                Ôn tập lại
                                            </a>
                                        </div>
                                    </div>
                                </article>
                            </c:if>
                        </c:forEach>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>

        <!-- ══════ TAB 3: SAVED / ALL COURSES ══════ -->
        <div id="panel-all" class="cs-panel ${currentTab == 'all' ? 'active' : ''}">
            <c:choose>
                <c:when test="${empty courses}">
                    <div class="mc-empty">
                        <div class="mc-empty__icon">📚</div>
                        <h2>Chưa có khóa học nào</h2>
                        <p>Khám phá thư viện và chọn khóa học đầu tiên dành cho bạn.</p>
                        <a class="hn-btn hn-btn--primary hn-btn--lg" href="${cp}/courses">
                            Khám phá khóa học
                        </a>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="mc-grid">
                        <c:forEach var="course" items="${courses}">
                            <article class="mc-card">
                                <div class="mc-card__thumb">
                                    <span class="mc-card__credit-pill">🎓 <c:out value="${course.credits}"/> Tín chỉ</span>
                                    <span class="mc-card__thumb-icon">📖</span>
                                    <c:choose>
                                        <c:when test="${course.completed}">
                                            <span class="mc-card__status mc-card__status--done">✅ Hoàn thành</span>
                                        </c:when>
                                        <c:when test="${course.enrollmentStatus == 'ACTIVE'}">
                                            <span class="mc-card__status mc-card__status--active">▶ Đang học</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="mc-card__status mc-card__status--dropped">Đã rời</span>
                                        </c:otherwise>
                                    </c:choose>
                                </div>

                                <div class="mc-card__body">
                                    <h3 class="mc-card__title">
                                        <a href="${cp}/courses/${course.courseId}">
                                            <c:out value="${course.title}"/>
                                        </a>
                                    </h3>
                                    <p class="mc-card__instructor">
                                        👤 <c:out value="${course.instructorName}"/>
                                    </p>

                                    <div class="mc-card__progress-wrap">
                                        <div class="mc-card__progress-head">
                                            <span>Tiến độ: <c:out value="${course.completedLessons}/${course.totalLessons}"/> bài</span>
                                            <span><c:out value="${course.progressPercent}"/>%</span>
                                        </div>
                                        <div class="mc-card__progress-bar">
                                            <div class="mc-card__progress-fill" style="width:${course.progressPercent}%"></div>
                                        </div>
                                    </div>

                                    <div class="mc-card__actions">
                                        <c:if test="${course.enrollmentStatus ne 'DROPPED'}">
                                            <a class="hn-btn hn-btn--primary mc-btn-sm"
                                               href="${cp}/courses/${course.courseId}/learn">
                                                Vào học →
                                            </a>
                                        </c:if>
                                        <c:if test="${course.completed}">
                                            <a class="hn-btn mc-btn-outline mc-btn-sm"
                                               style="border-color:#2563eb;color:#2563eb;font-weight:700;"
                                               href="${cp}/courses/${course.courseId}/certificate">
                                                🎓 Chứng chỉ
                                            </a>
                                        </c:if>
                                        <a class="hn-btn mc-btn-outline mc-btn-sm"
                                           href="${cp}/courses/${course.courseId}/results">
                                            📊 Kết quả
                                        </a>
                                    </div>
                                </div>
                            </article>
                        </c:forEach>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>

        <!-- ══════ TAB 4: CERTIFICATES & BADGES (Coursera Layout - Image 1) ══════ -->
        <div id="panel-certificates" class="cs-panel ${currentTab == 'certificates' ? 'active' : ''}">
            <h2 class="cb-section-title">Specialization &amp; Course Certificates</h2>
            <c:choose>
                <c:when test="${empty certificates}">
                    <div class="mc-empty">
                        <div class="mc-empty__icon">🏅</div>
                        <h2>Chưa có chứng chỉ hay tín chỉ nào trong kho</h2>
                        <p>Khi bạn hoàn thành 100% các bài học trong một khóa học, chứng chỉ và số tín chỉ tương ứng sẽ tự động xuất hiện tại đây.</p>
                        <button type="button" class="hn-btn hn-btn--primary" onclick="switchTab('in-progress', document.querySelector('.cs-tab'))">
                            Xem các khóa đang học
                        </button>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="cb-grid">
                        <c:forEach var="cert" items="${certificates}">
                            <article class="cb-card">
                                <!-- Certificate Graphic Preview Box -->
                                <a class="cb-card__preview" href="${cp}/certificates/${cert.certificateId}" title="Xem chi tiết chứng chỉ">
                                    <div class="cb-card__preview-inner">
                                        <div class="cb-card__preview-ribbon">
                                            <div class="cb-card__preview-seal">E</div>
                                        </div>
                                        <div class="cb-card__preview-brand">
                                            <span class="box">E</span>
                                            <span>EDUSPHERE ACADEMY</span>
                                        </div>
                                        <div class="cb-card__preview-course">
                                            <c:out value="${cert.courseTitle}"/>
                                        </div>
                                        <div class="cb-card__preview-footer">
                                            <span>Verified • <c:out value="${cert.gradePercent}"/>%</span>
                                            <span class="cb-card__credits-tag">+<c:out value="${cert.creditsEarned}"/> Tín chỉ</span>
                                        </div>
                                    </div>
                                </a>

                                <!-- Course / Specialization Title -->
                                <h3 class="cb-card__title">
                                    <a href="${cp}/certificates/${cert.certificateId}">
                                        <c:out value="${cert.courseTitle}"/>
                                    </a>
                                </h3>

                                <!-- Blue Action Links: Add to LinkedIn | View certificate -->
                                <div class="cb-card__links">
                                    <a class="cb-card__link"
                                       target="_blank"
                                       rel="noopener"
                                       href="https://www.linkedin.com/profile/add?startTask=CERTIFICATION_NAME&amp;name=${fn:escapeXml(cert.courseTitle)}&amp;organizationName=EduSphere+Academy&amp;certId=${cert.verificationCode}">
                                        Add to LinkedIn
                                    </a>
                                    <a class="cb-card__link" href="${cp}/certificates/${cert.certificateId}">
                                        View certificate
                                    </a>
                                </div>

                                <!-- Organization / Provider & Completed Month Year -->
                                <p class="cb-card__provider">
                                    EduSphere Academy • GV: <c:out value="${cert.instructorName}"/> (<c:out value="${cert.creditsEarned}"/> tín chỉ)
                                </p>
                                <p class="cb-card__completed">
                                    Completed <c:out value="${cert.formattedIssuedMonthYearEn}"/>
                                </p>
                            </article>
                        </c:forEach>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>

    </div>
</main>

<!-- ══════ FOOTER ══════ -->
<footer class="hn-footer">
    <div class="hn-footer__inner">
        <div class="hn-footer__brand">
            <a class="hn-logo" href="${cp}/">
                <div class="hn-logo__icon">🎓</div>
                <span>EduSphere</span>
            </a>
            <p>Nền tảng học tập trực tuyến &amp; tích lũy tín chỉ chất lượng cao dành cho mọi người.</p>
        </div>
        <div class="hn-footer__col">
            <h4>Khóa học</h4>
            <a href="${cp}/courses">Tất cả khóa học</a>
            <a href="${cp}/my-courses">Khóa học của tôi</a>
            <a href="${cp}/certificates">Kho tín chỉ &amp; Chứng chỉ</a>
        </div>
        <div class="hn-footer__col">
            <h4>Tài khoản</h4>
            <a href="${cp}/profile">Hồ sơ</a>
            <a href="${cp}/change-password">Đổi mật khẩu</a>
        </div>
        <div class="hn-footer__col">
            <h4>Liên hệ</h4>
            <span>📧 support@edusphere.vn</span>
            <span>📞 1800-1234</span>
        </div>
    </div>
    <div class="hn-footer__bottom">
        <p>© 2026 EduSphere. Bản quyền thuộc về EduSphere.</p>
    </div>
</footer>

<script>
function switchTab(tabName, btnEl) {
    document.querySelectorAll('.cs-tab').forEach(b => b.classList.remove('active'));
    document.querySelectorAll('.cs-panel').forEach(p => p.classList.remove('active'));
    if (btnEl) {
        btnEl.classList.add('active');
    } else {
        const tabs = document.querySelectorAll('.cs-tab');
        if (tabName === 'in-progress' && tabs[0]) tabs[0].classList.add('active');
        if (tabName === 'completed' && tabs[1]) tabs[1].classList.add('active');
        if (tabName === 'all' && tabs[2]) tabs[2].classList.add('active');
        if (tabName === 'certificates' && tabs[3]) tabs[3].classList.add('active');
    }
    const panel = document.getElementById('panel-' + tabName);
    if (panel) panel.classList.add('active');

    if (history.replaceState) {
        const url = new URL(window.location.href);
        url.searchParams.set('tab', tabName);
        history.replaceState(null, '', url.toString());
    }
}
</script>
</body>
</html>
