<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<fmt:setLocale value="vi_VN" />
<c:set var="cp" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><c:out value="${course.title}" /> — EduSphere</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${cp}/assets/css/home.css">
    <link rel="stylesheet" href="${cp}/assets/css/course-detail.css?v=2.3">
</head>
<body>

<jsp:include page="/WEB-INF/views/common/navbar.jsp"/>

<main class="cd-main-page">
    <div class="cd-container">
        <!-- ═════════ 1. BREADCRUMB ═════════ -->
        <nav class="cd-breadcrumb" aria-label="Đường dẫn trang">
            <a href="${cp}/courses" class="cd-breadcrumb-link">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/>
                    <polyline points="9 22 9 12 15 12 15 22"/>
                </svg>
                <span>Khóa học</span>
            </a>
            <span class="cd-breadcrumb-sep">&gt;</span>
            <span class="cd-breadcrumb-current"><c:out value="${course.title}" /></span>
        </nav>

        <!-- ═════════ 2. MAIN 2-COLUMN LAYOUT ═════════ -->
        <div class="cd-layout-grid">
            <!-- LEFT MAIN COLUMN -->
            <div class="cd-content-col">
                <!-- HERO CARD -->
                <c:choose>
                    <c:when test="${not empty course.thumbnailUrl}">
                        <!-- Khi đã có ảnh bìa: ảnh chiếm trọn 100% khung hình banner, không hiện text bên trái -->
                        <section class="cd-hero-cover-card" aria-label="<c:out value='${course.title}' />">
                            <h1 class="cd-sr-only"><c:out value="${course.title}" /></h1>
                            <c:choose>
                                <c:when test="${fn:startsWith(course.thumbnailUrl, 'http://') or fn:startsWith(course.thumbnailUrl, 'https://') or fn:startsWith(course.thumbnailUrl, cp)}">
                                    <img src="<c:out value='${course.thumbnailUrl}'/>" alt="<c:out value='${course.title}' />" class="cd-hero-full-img" />
                                </c:when>
                                <c:otherwise>
                                    <img src="${cp}<c:out value='${course.thumbnailUrl}'/>" alt="<c:out value='${course.title}' />" class="cd-hero-full-img" />
                                </c:otherwise>
                            </c:choose>
                        </section>
                    </c:when>
                    <c:otherwise>
                        <!-- Fallback khi khóa học chưa tải ảnh bìa lên -->
                        <section class="cd-hero-card" aria-labelledby="course-hero-heading">
                            <div class="cd-hero-body">
                                <div class="cd-category-badge">
                                    <span class="code-icon">&lt;/&gt;</span>
                                    <span><c:out value="${course.categoryName}" /></span>
                                </div>

                                <h1 id="course-hero-heading" class="cd-hero-title">
                                    <c:out value="${course.title}" />
                                </h1>

                                <p class="cd-hero-summary">
                                    <c:out value="${not empty course.summary ? course.summary : course.description}" />
                                </p>

                                <div class="cd-meta-chips">
                                    <div class="cd-chip">
                                        <svg width="15" height="15" viewBox="0 0 24 24" fill="#0284c7">
                                            <polygon points="5 3 19 12 5 21 5 3"/>
                                        </svg>
                                        <span><c:out value="${fn:length(lessonTitles)}" /> bài học</span>
                                    </div>

                                    <c:if test="${not empty course.formattedDuration}">
                                        <div class="cd-chip">
                                            <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="#0284c7" stroke-width="2">
                                                <circle cx="12" cy="12" r="10"/>
                                                <polyline points="12 6 12 12 16 14"/>
                                            </svg>
                                            <span><c:out value="${course.formattedDuration}" /></span>
                                        </div>
                                    </c:if>

                                    <div class="cd-chip">
                                        <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="#0284c7" stroke-width="2">
                                            <line x1="18" y1="20" x2="18" y2="10"/>
                                            <line x1="12" y1="20" x2="12" y2="4"/>
                                            <line x1="6" y1="20" x2="6" y2="14"/>
                                        </svg>
                                        <span><c:out value="${course.levelLabel}" /></span>
                                    </div>

                                    <c:choose>
                                        <c:when test="${course.free}">
                                            <div class="cd-chip cd-chip--free">
                                                <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="#059669" stroke-width="2">
                                                    <polyline points="20 12 20 22 4 22 4 12"/>
                                                    <rect x="2" y="7" width="20" height="5"/>
                                                    <line x1="12" y1="22" x2="12" y2="7"/>
                                                </svg>
                                                <span>Miễn phí</span>
                                            </div>
                                        </c:when>
                                        <c:otherwise>
                                            <div class="cd-chip cd-chip--paid">
                                                <span>💳</span>
                                                <fmt:formatNumber value="${course.price}" type="number" maxFractionDigits="0" var="fPrice" />
                                                <span><c:out value="${fn:replace(fPrice, ',', '.')}" /> <c:out value="${course.currency}" /></span>
                                            </div>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>

                            <div class="cd-hero-art" aria-hidden="true">
                                <div class="cd-hero-art-illustration">
                                    <svg width="210" height="160" viewBox="0 0 240 180" fill="none" xmlns="http://www.w3.org/2000/svg">
                                        <rect x="30" y="25" width="160" height="100" rx="12" fill="#1e293b" />
                                        <rect x="38" y="33" width="144" height="84" rx="8" fill="#0f172a" />
                                        <path d="M50 50h40M50 62h60M50 74h30" stroke="#38bdf8" stroke-width="4" stroke-linecap="round"/>
                                        <path d="M125 55l12 12-12 12M155 55l-12 12 12 12" stroke="#60a5fa" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"/>
                                        <path d="M15 125h190a10 10 0 0 1 10 10v6H5v-6a10 10 0 0 1 10-10z" fill="#94a3b8"/>
                                        <rect x="85" y="126" width="50" height="5" rx="2.5" fill="#64748b"/>
                                        <path d="M140 105l70-15 15 8-70 15-15-8z" fill="#3b82f6"/>
                                        <path d="M140 113l70-15v8l-70 15v-8z" fill="#1d4ed8"/>
                                        <path d="M140 123l70-15 15 8-70 15-15-8z" fill="#60a5fa"/>
                                        <path d="M140 131l70-15v8l-70 15v-8z" fill="#2563eb"/>
                                    </svg>
                                </div>
                            </div>
                        </section>
                    </c:otherwise>
                </c:choose>

                <!-- TAB NAVIGATION BAR (Pill Buttons) -->
                <div class="cd-tab-nav" role="tablist">
                    <button type="button" class="cd-tab-btn active" data-tab="about" role="tab" aria-selected="true">
                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z"/>
                            <path d="M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z"/>
                        </svg>
                        <span>Giới thiệu</span>
                    </button>
                    <button type="button" class="cd-tab-btn" data-tab="curriculum" role="tab" aria-selected="false">
                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <line x1="8" y1="6" x2="21" y2="6"/>
                            <line x1="8" y1="12" x2="21" y2="12"/>
                            <line x1="8" y1="18" x2="21" y2="18"/>
                            <line x1="3" y1="6" x2="3.01" y2="6"/>
                            <line x1="3" y1="12" x2="3.01" y2="12"/>
                            <line x1="3" y1="18" x2="3.01" y2="18"/>
                        </svg>
                        <span>Chương trình học</span>
                    </button>
                    <button type="button" class="cd-tab-btn" data-tab="reviews" role="tab" aria-selected="false">
                        <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor" stroke="none">
                            <polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/>
                        </svg>
                        <span>Đánh giá <c:if test="${ratingSummary != null && ratingSummary.totalRatings > 0}">(<c:out value="${ratingSummary.averageRating}"/> ★)</c:if></span>
                    </button>
                    <button type="button" class="cd-tab-btn" data-tab="qa" role="tab" aria-selected="false">
                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <circle cx="12" cy="12" r="10"/>
                            <path d="M9.09 9a3 3 0 0 1 5.83 1c0 2-3 3-3 3"/>
                            <line x1="12" y1="17" x2="12.01" y2="17"/>
                        </svg>
                        <span>Hỏi đáp</span>
                    </button>
                </div>

                <!-- ═════════ TAB 1: GIỚI THIỆU (ABOUT) ═════════ -->
                <div class="cd-tab-panel active" data-tab-content="about">
                    <div class="cd-panel-card">
                        <h2 class="cd-section-title">
                            <span class="cd-accent-bar"></span>
                            <span>Về khóa học</span>
                        </h2>
                        <div class="cd-about-text">
                            <c:out value="${course.description}" default="Chưa có thông tin mô tả chi tiết cho khóa học này." />
                        </div>

                        <!-- Mục tiêu khóa học (CHỈ HIỂN THỊ NẾU CÓ DỮ LIỆU THỰC TẾ) -->
                        <c:if test="${not empty course.objectiveList}">
                            <div class="cd-objectives-box">
                                <div class="cd-objectives-header">
                                    <span class="cd-target-icon">🎯</span>
                                    <h3>Mục tiêu khóa học</h3>
                                </div>
                                <ul class="cd-objectives-list">
                                    <c:forEach var="item" items="${course.objectiveList}">
                                        <li>
                                            <span class="cd-check-icon">✓</span>
                                            <span><c:out value="${item}" /></span>
                                        </li>
                                    </c:forEach>
                                </ul>
                            </div>
                        </c:if>

                        <!-- Yêu cầu đầu vào (CHỈ HIỂN THỊ NẾU CÓ DỮ LIỆU THỰC TẾ) -->
                        <c:if test="${not empty course.requirementList}">
                            <div class="cd-requirements-box">
                                <div class="cd-requirements-header">
                                    <span class="cd-req-icon">📋</span>
                                    <h3>Yêu cầu khóa học</h3>
                                </div>
                                <ul class="cd-requirements-list">
                                    <c:forEach var="req" items="${course.requirementList}">
                                        <li>
                                            <span class="cd-bullet-icon">•</span>
                                            <span><c:out value="${req}" /></span>
                                        </li>
                                    </c:forEach>
                                </ul>
                            </div>
                        </c:if>
                    </div>
                </div>

                <!-- ═════════ TAB 2: CHƯƠNG TRÌNH HỌC (CURRICULUM) ═════════ -->
                <div class="cd-tab-panel" data-tab-content="curriculum">
                    <div class="cd-panel-card">
                        <div class="cd-curriculum-header">
                            <h2 class="cd-section-title" style="margin-bottom:0;">
                                <span class="cd-accent-bar"></span>
                                <span>Lộ trình khóa học</span>
                            </h2>
                            <span class="cd-curriculum-count"><c:out value="${fn:length(lessonTitles)}" /> bài học</span>
                        </div>

                        <c:choose>
                            <c:when test="${empty lessonTitles}">
                                <p style="color:var(--cd-ink-muted); margin-top:20px;">Nội dung bài học sẽ được giảng viên cập nhật sớm.</p>
                            </c:when>
                            <c:when test="${not empty sections}">
                                <div class="cd-curriculum-list">
                                    <c:forEach var="sec" items="${sections}" varStatus="secStat">
                                        <div class="cd-curriculum-sec ${secStat.first ? 'open' : ''}">
                                            <div class="cd-curriculum-sec-header">
                                                <h4><c:out value="${sec.title}" /></h4>
                                                <div class="cd-curriculum-sec-meta">
                                                    <span><c:out value="${fn:length(sec.lessons)}" /> bài học</span>
                                                    <svg class="cd-curriculum-sec-chevron" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                                        <polyline points="6 9 12 15 18 9"/>
                                                    </svg>
                                                </div>
                                            </div>
                                            <div class="cd-curriculum-sec-body">
                                                <c:forEach var="les" items="${sec.lessons}" varStatus="lesStat">
                                                    <div class="cd-lesson-row">
                                                        <div class="cd-lesson-icon">
                                                            <c:choose>
                                                                <c:when test="${les.lessonType == 'VIDEO'}">▶</c:when>
                                                                <c:otherwise>📄</c:otherwise>
                                                            </c:choose>
                                                        </div>
                                                        <span class="cd-lesson-title"><c:out value="${les.title}" /></span>
                                                        <c:if test="${les.videoDuration != null && les.videoDuration > 0}">
                                                            <span class="cd-lesson-duration">
                                                                <fmt:formatNumber value="${les.videoDuration / 60}" maxFractionDigits="0"/> phút
                                                            </span>
                                                        </c:if>
                                                    </div>
                                                </c:forEach>
                                            </div>
                                        </div>
                                    </c:forEach>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div class="cd-curriculum-list">
                                    <c:forEach var="lessonTitle" items="${lessonTitles}" varStatus="item">
                                        <div class="cd-lesson-row">
                                            <div class="cd-lesson-icon">▶</div>
                                            <span class="cd-lesson-title"><c:out value="${lessonTitle}" /></span>
                                            <span class="cd-lesson-duration">Bài <fmt:formatNumber value="${item.count}" minIntegerDigits="2"/></span>
                                        </div>
                                    </c:forEach>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>

                <!-- ═════════ TAB 3: ĐÁNH GIÁ (REVIEWS) ═════════ -->
                <div class="cd-tab-panel" data-tab-content="reviews" id="course-reviews">
                    <div class="cd-panel-card">
                        <h2 class="cd-section-title">
                            <span class="cd-accent-bar"></span>
                            <span>Đánh giá từ học viên</span>
                        </h2>

                        <!-- Rating Overview Box -->
                        <c:if test="${not empty ratingSummary}">
                            <div class="cd-rating-overview">
                                <div class="cd-rating-score-box">
                                    <div class="cd-rating-score-num">
                                        <c:out value="${ratingSummary.totalRatings > 0 ? ratingSummary.averageRating : '5.0'}"/>
                                    </div>
                                    <div class="cd-rating-score-stars">★★★★★</div>
                                    <div class="cd-rating-score-count">
                                        <c:out value="${ratingSummary.totalRatings}"/> đánh giá
                                    </div>
                                </div>
                                <div class="cd-rating-bars">
                                    <div class="cd-rating-bar-row">
                                        <span>5 sao</span>
                                        <div class="cd-rating-bar-track"><div class="cd-rating-bar-fill" style="width:${ratingSummary.starPercents != null && ratingSummary.starPercents[5] != null ? ratingSummary.starPercents[5] : 0}%"></div></div>
                                        <span>${ratingSummary.starPercents != null && ratingSummary.starPercents[5] != null ? ratingSummary.starPercents[5] : 0}%</span>
                                    </div>
                                    <div class="cd-rating-bar-row">
                                        <span>4 sao</span>
                                        <div class="cd-rating-bar-track"><div class="cd-rating-bar-fill" style="width:${ratingSummary.starPercents != null && ratingSummary.starPercents[4] != null ? ratingSummary.starPercents[4] : 0}%"></div></div>
                                        <span>${ratingSummary.starPercents != null && ratingSummary.starPercents[4] != null ? ratingSummary.starPercents[4] : 0}%</span>
                                    </div>
                                    <div class="cd-rating-bar-row">
                                        <span>3 sao</span>
                                        <div class="cd-rating-bar-track"><div class="cd-rating-bar-fill" style="width:${ratingSummary.starPercents != null && ratingSummary.starPercents[3] != null ? ratingSummary.starPercents[3] : 0}%"></div></div>
                                        <span>${ratingSummary.starPercents != null && ratingSummary.starPercents[3] != null ? ratingSummary.starPercents[3] : 0}%</span>
                                    </div>
                                    <div class="cd-rating-bar-row">
                                        <span>2 sao</span>
                                        <div class="cd-rating-bar-track"><div class="cd-rating-bar-fill" style="width:${ratingSummary.starPercents != null && ratingSummary.starPercents[2] != null ? ratingSummary.starPercents[2] : 0}%"></div></div>
                                        <span>${ratingSummary.starPercents != null && ratingSummary.starPercents[2] != null ? ratingSummary.starPercents[2] : 0}%</span>
                                    </div>
                                    <div class="cd-rating-bar-row">
                                        <span>1 sao</span>
                                        <div class="cd-rating-bar-track"><div class="cd-rating-bar-fill" style="width:${ratingSummary.starPercents != null && ratingSummary.starPercents[1] != null ? ratingSummary.starPercents[1] : 0}%"></div></div>
                                        <span>${ratingSummary.starPercents != null && ratingSummary.starPercents[1] != null ? ratingSummary.starPercents[1] : 0}%</span>
                                    </div>
                                </div>
                            </div>
                        </c:if>

                        <!-- Student Rating Form -->
                        <c:choose>
                            <c:when test="${enrolled}">
                                <form method="post" action="${cp}/courses/${course.courseId}/ratings" class="cd-review-form">
                                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                    <input type="hidden" name="rating" value="${ratingSummary.myRating != null ? ratingSummary.myRating.rating : 5}">
                                    
                                    <div class="cd-star-picker">
                                        <span style="font-weight:700; color:var(--cd-ink-dark); font-size:0.9rem;">Đánh giá của bạn:</span>
                                        <button type="button" class="cd-star-btn" data-star="1">★</button>
                                        <button type="button" class="cd-star-btn" data-star="2">★</button>
                                        <button type="button" class="cd-star-btn" data-star="3">★</button>
                                        <button type="button" class="cd-star-btn" data-star="4">★</button>
                                        <button type="button" class="cd-star-btn" data-star="5">★</button>
                                        <span class="cd-star-label">5 sao - Tuyệt vời!</span>
                                    </div>

                                    <textarea name="comment" class="cd-textarea" placeholder="Chia sẻ cảm nhận chân thật của bạn về khóa học này...">${ratingSummary.myRating != null ? ratingSummary.myRating.comment : ''}</textarea>
                                    
                                    <div style="display:flex; justify-content:flex-end; gap:10px; margin-top:12px;">
                                        <button type="submit" class="cd-cta-btn cd-cta-btn--primary" style="width:auto; min-height:40px; padding:8px 24px; font-size:0.88rem;">
                                            ${ratingSummary.myRating != null ? 'Cập nhật đánh giá' : 'Gửi đánh giá'}
                                        </button>
                                    </div>
                                </form>
                            </c:when>
                            <c:otherwise>
                                <div style="background:#f8fafc; border:1px dashed #cbd5e1; border-radius:12px; padding:16px 20px; color:var(--cd-ink-muted); font-size:0.88rem; margin-bottom:24px;">
                                    💡 Bạn cần ghi danh tham gia khóa học này để có thể gửi đánh giá &amp; nhận xét.
                                </div>
                            </c:otherwise>
                        </c:choose>

                        <!-- Review Cards List -->
                        <div class="cd-review-cards">
                            <c:choose>
                                <c:when test="${empty ratingSummary.reviews}">
                                    <p style="color:var(--cd-ink-muted); text-align:center; padding:20px 0;">Chưa có đánh giá nào cho khóa học này. Hãy là người đầu tiên để lại đánh giá!</p>
                                </c:when>
                                <c:otherwise>
                                    <c:forEach var="rev" items="${ratingSummary.reviews}">
                                        <div class="cd-review-item">
                                            <div class="cd-review-head">
                                                <div class="cd-review-author">
                                                    <div class="cd-review-avatar">
                                                        <span><c:out value="${not empty rev.studentInitial ? rev.studentInitial : fn:substring(rev.studentName, 0, 1)}"/></span>
                                                    </div>
                                                    <div>
                                                        <div class="cd-review-author-name"><c:out value="${rev.studentName}"/></div>
                                                        <div class="cd-review-author-meta"><c:out value="${rev.createdAtFormatted}"/></div>
                                                    </div>
                                                </div>
                                                <div class="cd-review-stars">
                                                    <c:forEach begin="1" end="${rev.rating}">★</c:forEach>
                                                </div>
                                            </div>
                                            <c:if test="${not empty rev.comment}">
                                                <div class="cd-review-text"><c:out value="${rev.comment}"/></div>
                                            </c:if>

                                            <!-- Instructor Reply if present -->
                                            <c:if test="${not empty rev.instructorReply}">
                                                <div class="cd-review-reply-box">
                                                    <div class="cd-review-reply-author">Phản hồi từ giảng viên <c:out value="${course.instructorName}"/>:</div>
                                                    <div class="cd-review-reply-text"><c:out value="${rev.instructorReply}"/></div>
                                                </div>
                                            </c:if>
                                        </div>
                                    </c:forEach>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>

                <!-- ═════════ TAB 4: HỎI ĐÁP (Q&A) ═════════ -->
                <div class="cd-tab-panel" data-tab-content="qa" id="course-qa">
                    <div class="cd-panel-card">
                        <h2 class="cd-section-title">
                            <span class="cd-accent-bar"></span>
                            <span>Hỏi đáp &amp; Thảo luận</span>
                        </h2>

                        <!-- Q&A Comment Form -->
                        <sec:authorize access="isAuthenticated()">
                            <form method="post" action="${cp}/courses/${course.courseId}/comments" class="cd-review-form">
                                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                <textarea name="content" class="cd-textarea" placeholder="Đặt câu hỏi hoặc thảo luận cùng giảng viên và các học viên khác..."></textarea>
                                <div style="display:flex; justify-content:flex-end; margin-top:10px;">
                                    <button type="submit" class="cd-cta-btn cd-cta-btn--primary" style="width:auto; min-height:40px; padding:8px 24px; font-size:0.88rem;">
                                        Gửi câu hỏi
                                    </button>
                                </div>
                            </form>
                        </sec:authorize>
                        <sec:authorize access="isAnonymous()">
                            <div style="background:#f8fafc; border:1px dashed #cbd5e1; border-radius:12px; padding:16px 20px; color:var(--cd-ink-muted); font-size:0.88rem; margin-bottom:24px;">
                                💬 Vui lòng <a href="${cp}/login?courseId=${course.courseId}" style="color:var(--cd-primary); font-weight:700;">đăng nhập</a> để tham gia đặt câu hỏi và thảo luận.
                            </div>
                        </sec:authorize>

                        <!-- Comments list -->
                        <div class="cd-review-cards">
                            <c:choose>
                                <c:when test="${empty courseComments}">
                                    <p style="color:var(--cd-ink-muted); text-align:center; padding:20px 0;">Chưa có câu hỏi nào. Bạn có thắc mắc gì về khóa học này không?</p>
                                </c:when>
                                <c:otherwise>
                                    <c:forEach var="c" items="${courseComments}">
                                        <div class="cd-review-item">
                                            <div class="cd-review-head">
                                                <div class="cd-review-author">
                                                    <div class="cd-review-avatar">
                                                        <c:choose>
                                                            <c:when test="${not empty c.authorAvatarUrl}">
                                                                <img src="<c:out value='${c.authorAvatarUrl}'/>" alt="Avatar"/>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span>${fn:substring(c.authorName, 0, 1)}</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </div>
                                                    <div>
                                                        <div class="cd-review-author-name"><c:out value="${c.authorName}"/></div>
                                                        <div class="cd-review-author-meta"><c:out value="${c.timeAgo}"/></div>
                                                    </div>
                                                </div>
                                            </div>
                                            <div class="cd-review-text" style="margin-left:0; margin-top:10px;"><c:out value="${c.content}"/></div>

                                            <!-- Replies -->
                                            <c:if test="${not empty c.replies}">
                                                <div style="margin-top:12px; padding-left:16px; border-left:2px solid #e2e8f0; display:flex; flex-direction:column; gap:10px;">
                                                    <c:forEach var="rep" items="${c.replies}">
                                                        <div style="background:#f8fafc; border-radius:8px; padding:10px 14px;">
                                                            <div style="font-weight:700; font-size:0.85rem; color:var(--cd-ink-dark); margin-bottom:4px;">
                                                                <c:out value="${rep.authorName}"/>
                                                            </div>
                                                            <div style="font-size:0.88rem; color:var(--cd-ink-body);"><c:out value="${rep.content}"/></div>
                                                        </div>
                                                    </c:forEach>
                                                </div>
                                            </c:if>
                                        </div>
                                    </c:forEach>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>
            </div>

            <!-- RIGHT SIDEBAR COLUMN -->
            <aside class="cd-sidebar-col">
                <!-- CARD 1: GIẢNG VIÊN (INSTRUCTOR CARD) -->
                <div class="cd-side-card">
                    <div class="cd-side-card-title">
                        <span style="color:#eab308; font-size:1.15rem;">👑</span>
                        <span>Giảng viên</span>
                    </div>
                    <div class="cd-instructor-profile">
                        <div class="cd-instructor-avatar-wrap">
                            <c:choose>
                                <c:when test="${not empty course.instructorAvatarUrl}">
                                    <c:choose>
                                        <c:when test="${fn:startsWith(course.instructorAvatarUrl, 'http://') or fn:startsWith(course.instructorAvatarUrl, 'https://') or fn:startsWith(course.instructorAvatarUrl, cp)}">
                                            <img src="<c:out value='${course.instructorAvatarUrl}'/>" alt="Avatar giảng viên" />
                                        </c:when>
                                        <c:otherwise>
                                            <img src="${cp}<c:out value='${course.instructorAvatarUrl}'/>" alt="Avatar giảng viên" />
                                        </c:otherwise>
                                    </c:choose>
                                </c:when>
                                <c:otherwise>
                                    <span>${fn:substring(course.instructorName, 0, 1)}</span>
                                </c:otherwise>
                            </c:choose>
                        </div>
                        <div class="cd-instructor-info">
                            <div class="cd-instructor-name">
                                <c:out value="${course.instructorName}" />
                            </div>
                            <c:choose>
                                <c:when test="${not empty course.instructorEmail}">
                                    <div class="cd-instructor-subtitle"><c:out value="${course.instructorEmail}" /></div>
                                </c:when>
                                <c:otherwise>
                                    <div class="cd-instructor-subtitle">Giảng viên tại EduSphere</div>
                                </c:otherwise>
                            </c:choose>
                            <c:if test="${ratingSummary != null && ratingSummary.totalRatings > 0}">
                                <div class="cd-instructor-rating-pill">
                                    <span>⭐</span>
                                    <span><c:out value="${ratingSummary.averageRating}" /></span>
                                    <span style="color:var(--cd-ink-muted); font-weight:normal;">(<c:out value="${ratingSummary.totalRatings}" /> đánh giá)</span>
                                </div>
                            </c:if>
                        </div>
                    </div>
                </div>

                <!-- CARD 2: THÔNG TIN KHÓA HỌC (COURSE INFO CARD) -->
                <div class="cd-side-card">
                    <div class="cd-side-card-title">
                        <span style="color:var(--cd-primary); font-size:1.15rem;">📊</span>
                        <span>Thông tin khóa học</span>
                    </div>

                    <div class="cd-info-list">
                        <!-- Danh mục -->
                        <div class="cd-info-row">
                            <span class="cd-info-label">
                                <span>📁</span>
                                <span>Danh mục</span>
                            </span>
                            <span class="cd-info-value"><c:out value="${course.categoryName}" /></span>
                        </div>

                        <!-- Cấp độ -->
                        <div class="cd-info-row">
                            <span class="cd-info-label">
                                <span>📶</span>
                                <span>Cấp độ</span>
                            </span>
                            <span class="cd-info-value">
                                <span class="cd-level-pill"><c:out value="${course.levelLabel}" /></span>
                            </span>
                        </div>

                        <!-- Thời lượng (CHỈ HIỂN THỊ NẾU CÓ DỮ LIỆU) -->
                        <c:if test="${not empty course.formattedDuration}">
                            <div class="cd-info-row">
                                <span class="cd-info-label">
                                    <span>🕒</span>
                                    <span>Thời lượng</span>
                                </span>
                                <span class="cd-info-value"><c:out value="${course.formattedDuration}" /></span>
                            </div>
                        </c:if>

                        <!-- Số chương (CHỈ HIỂN THỊ NẾU CÓ DỮ LIỆU) -->
                        <c:if test="${course.sectionCount > 0}">
                            <div class="cd-info-row">
                                <span class="cd-info-label">
                                    <span>📑</span>
                                    <span>Số chương</span>
                                </span>
                                <span class="cd-info-value"><c:out value="${course.sectionCount}" /> chương</span>
                            </div>
                        </c:if>

                        <!-- Số bài học -->
                        <div class="cd-info-row">
                            <span class="cd-info-label">
                                <span>▶</span>
                                <span>Số bài học</span>
                            </span>
                            <span class="cd-info-value"><c:out value="${fn:length(lessonTitles)}" /> bài học</span>
                        </div>

                        <!-- Giá khóa học -->
                        <div class="cd-info-row">
                            <span class="cd-info-label">
                                <span>💳</span>
                                <span>Giá khóa học</span>
                            </span>
                            <span class="cd-info-value">
                                <c:choose>
                                    <c:when test="${course.free}">
                                        <span class="cd-price-green">🎁 Miễn phí</span>
                                    </c:when>
                                    <c:otherwise>
                                        <fmt:formatNumber value="${course.price}" type="number" maxFractionDigits="0" var="formattedPrice" />
                                        <span class="cd-price-bold">
                                            <c:out value="${fn:replace(formattedPrice, ',', '.')}" /> <c:out value="${course.currency}" />
                                        </span>
                                    </c:otherwise>
                                </c:choose>
                            </span>
                        </div>
                    </div>

                    <!-- Call To Action Buttons -->
                    <div class="cd-cta-group">
                        <c:choose>
                            <c:when test="${enrolled}">
                                <a class="cd-cta-btn cd-cta-btn--primary" href="${cp}/courses/${course.courseId}/learn">
                                    <span>▶ Bắt đầu học ngay</span>
                                    <span aria-hidden="true">→</span>
                                </a>
                                <c:if test="${not empty myCertificateId}">
                                    <a class="cd-cta-btn cd-cta-btn--outline" href="${cp}/certificates/${myCertificateId}" style="border-color:#2563eb;color:#2563eb;font-weight:700;">
                                        <span>🎓 Xem Chứng chỉ đạt được</span>
                                    </a>
                                    <a class="cd-cta-btn cd-cta-btn--outline" href="${cp}/certificates/${myCertificateId}/download" style="border-color:#059669;color:#059669;font-weight:700;">
                                        <span>🖼️ Tải ảnh Chứng chỉ (PNG)</span>
                                    </a>
                                </c:if>
                                <a class="cd-cta-btn cd-cta-btn--outline" href="${cp}/my-courses">
                                    <span>🔖 Xem khóa học của tôi</span>
                                </a>
                            </c:when>
                            <c:when test="${course.free}">
                                <sec:authorize access="isAuthenticated()">
                                    <a class="cd-cta-btn cd-cta-btn--primary" href="${cp}/courses/${course.courseId}/learn">
                                        <span>▶ Bắt đầu học ngay</span>
                                        <span aria-hidden="true">→</span>
                                    </a>
                                    <a class="cd-cta-btn cd-cta-btn--outline" href="${cp}/courses">
                                        <span>🔍 Khám phá khóa học khác</span>
                                    </a>
                                </sec:authorize>
                                <sec:authorize access="isAnonymous()">
                                    <a class="cd-cta-btn cd-cta-btn--primary" href="${cp}/login?courseId=${course.courseId}">
                                        <span>▶ Đăng nhập để vào học</span>
                                        <span aria-hidden="true">→</span>
                                    </a>
                                    <a class="cd-cta-btn cd-cta-btn--outline" href="${cp}/courses">
                                        <span>🔍 Khám phá khóa học khác</span>
                                    </a>
                                </sec:authorize>
                            </c:when>
                            <c:otherwise>
                                <sec:authorize access="isAuthenticated()">
                                    <form method="post" action="${cp}/courses/${course.courseId}/checkout" style="width:100%;">
                                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                        <button class="cd-cta-btn cd-cta-btn--primary" type="submit">
                                            <span>💳 Đăng ký khóa học</span>
                                            <span aria-hidden="true">→</span>
                                        </button>
                                    </form>
                                    <a class="cd-cta-btn cd-cta-btn--outline" href="${cp}/courses">
                                        <span>🔍 Khám phá khóa học khác</span>
                                    </a>
                                </sec:authorize>
                                <sec:authorize access="isAnonymous()">
                                    <a class="cd-cta-btn cd-cta-btn--primary" href="${cp}/login?courseId=${course.courseId}">
                                        <span>💳 Đăng nhập để đăng ký</span>
                                        <span aria-hidden="true">→</span>
                                    </a>
                                    <a class="cd-cta-btn cd-cta-btn--outline" href="${cp}/courses">
                                        <span>🔍 Khám phá khóa học khác</span>
                                    </a>
                                </sec:authorize>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </aside>
        </div>
    </div>
</main>

<script src="${cp}/assets/js/course-detail.js?v=2.0"></script>
</body>
</html>
