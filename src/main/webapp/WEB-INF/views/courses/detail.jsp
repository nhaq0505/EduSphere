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
    <link rel="stylesheet" href="${cp}/assets/css/course-detail.css">
    <style>
        /* Credit Badge & VietJack-style Q&A / Comment Section */
        .cd-tag--credit {
            background: #eff6ff !important;
            color: #1d4ed8 !important;
            border: 1px solid #bfdbfe;
            font-weight: 700;
        }
        .cd-credit-box {
            background: #f0f7ff;
            border: 1px solid #bfdbfe;
            border-radius: 10px;
            padding: 12px 14px;
            margin: 12px 0 16px;
            font-size: 0.85rem;
            color: #1e3a8a;
            display: flex;
            align-items: center;
            gap: 10px;
            font-weight: 600;
        }

        /* VietJack-inspired Q&A & Comments Panel */
        .vj-comments-panel {
            margin-top: 28px;
        }
        .vj-rating-overview {
            display: grid;
            grid-template-columns: 180px 1fr;
            gap: 28px;
            background: #f8fafc;
            border: 1px solid #e2e8f0;
            border-radius: 12px;
            padding: 20px 24px;
            margin-bottom: 24px;
            align-items: center;
        }
        .vj-rating-score {
            text-align: center;
            border-right: 1px solid #e2e8f0;
            padding-right: 20px;
        }
        .vj-rating-score__num {
            font-size: 2.6rem;
            font-weight: 800;
            color: #0f172a;
            line-height: 1;
        }
        .vj-rating-score__stars {
            color: #f59e0b;
            font-size: 1.1rem;
            margin: 6px 0 4px;
            letter-spacing: 2px;
        }
        .vj-rating-score__count {
            font-size: 0.8rem;
            color: #64748b;
        }
        .vj-rating-bars {
            display: flex;
            flex-direction: column;
            gap: 6px;
        }
        .vj-bar-row {
            display: flex;
            align-items: center;
            gap: 10px;
            font-size: 0.8rem;
            color: #475569;
        }
        .vj-bar-row__label {
            width: 48px;
            font-weight: 600;
        }
        .vj-bar-row__track {
            flex: 1;
            height: 8px;
            background: #e2e8f0;
            border-radius: 999px;
            overflow: hidden;
        }
        .vj-bar-row__fill {
            height: 100%;
            background: #f59e0b;
            border-radius: 999px;
        }
        .vj-bar-row__pct {
            width: 36px;
            text-align: right;
            color: #64748b;
        }

        /* Comment Form */
        .vj-form-box {
            background: #ffffff;
            border: 1.5px solid #cbd5e1;
            border-radius: 12px;
            padding: 18px 20px;
            margin-bottom: 24px;
            transition: border-color 0.2s ease, box-shadow 0.2s ease;
        }
        .vj-form-box:focus-within {
            border-color: #2563eb;
            box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.12);
        }
        .vj-star-picker {
            display: flex;
            align-items: center;
            gap: 10px;
            margin-bottom: 12px;
            padding-bottom: 10px;
            border-bottom: 1px dashed #e2e8f0;
            font-size: 0.86rem;
            font-weight: 600;
            color: #334155;
        }
        .vj-star-picker__stars {
            display: inline-flex;
            flex-direction: row-reverse;
            gap: 4px;
        }
        .vj-star-picker__stars input {
            display: none;
        }
        .vj-star-picker__stars label {
            font-size: 1.35rem;
            color: #cbd5e1;
            cursor: pointer;
            transition: color 0.15s ease;
        }
        .vj-star-picker__stars input:checked ~ label,
        .vj-star-picker__stars label:hover,
        .vj-star-picker__stars label:hover ~ label {
            color: #f59e0b;
        }
        .vj-textarea {
            width: 100%;
            border: none;
            outline: none;
            resize: vertical;
            min-height: 76px;
            font-family: inherit;
            font-size: 0.92rem;
            color: #0f172a;
            line-height: 1.5;
            box-sizing: border-box;
        }
        .vj-form-foot {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-top: 10px;
            padding-top: 10px;
            border-top: 1px solid #f1f5f9;
        }
        .vj-form-hint {
            font-size: 0.78rem;
            color: #64748b;
        }
        .vj-submit-btn {
            background: #2563eb;
            color: #ffffff;
            border: none;
            border-radius: 8px;
            padding: 9px 20px;
            font-family: inherit;
            font-size: 0.88rem;
            font-weight: 700;
            cursor: pointer;
            transition: background 0.15s ease;
        }
        .vj-submit-btn:hover {
            background: #1d4ed8;
        }

        /* Filter / Sort Bar */
        .vj-filter-bar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 18px;
            padding-bottom: 12px;
            border-bottom: 1px solid #e2e8f0;
            flex-wrap: wrap;
            gap: 10px;
        }
        .vj-filter-count {
            font-size: 1rem;
            font-weight: 700;
            color: #0f172a;
        }
        .vj-sort-links {
            display: flex;
            gap: 8px;
        }
        .vj-sort-link {
            font-size: 0.82rem;
            font-weight: 600;
            color: #475569;
            padding: 5px 12px;
            border-radius: 999px;
            background: #f1f5f9;
            text-decoration: none;
        }
        .vj-sort-link.active {
            background: #2563eb;
            color: #ffffff;
        }

        /* Comment Items */
        .vj-comment-list {
            display: flex;
            flex-direction: column;
            gap: 18px;
        }
        .vj-comment-item {
            background: #ffffff;
            border: 1px solid #e2e8f0;
            border-radius: 12px;
            padding: 16px 18px;
        }
        .vj-comment-item--pinned {
            background: #fffbeb;
            border-color: #fde68a;
        }
        .vj-pinned-banner {
            font-size: 0.75rem;
            font-weight: 700;
            color: #b45309;
            margin-bottom: 8px;
            display: flex;
            align-items: center;
            gap: 6px;
        }
        .vj-comment-head {
            display: flex;
            align-items: center;
            gap: 12px;
            margin-bottom: 8px;
        }
        .vj-avatar {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            background: linear-gradient(135deg, #2563eb, #1e40af);
            color: #ffffff;
            font-weight: 700;
            font-size: 0.95rem;
            display: flex;
            align-items: center;
            justify-content: center;
            flex-shrink: 0;
            overflow: hidden;
        }
        .vj-avatar img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }
        .vj-author-meta {
            display: flex;
            flex-wrap: wrap;
            align-items: center;
            gap: 8px;
        }
        .vj-author-name {
            font-size: 0.92rem;
            font-weight: 700;
            color: #0f172a;
        }
        .vj-role-badge {
            font-size: 0.7rem;
            font-weight: 700;
            padding: 2px 8px;
            border-radius: 999px;
        }
        .vj-role-badge--COURSE_INSTRUCTOR {
            background: #dbeafe;
            color: #1d4ed8;
            border: 1px solid #93c5fd;
        }
        .vj-role-badge--INSTRUCTOR {
            background: #d1fae5;
            color: #047857;
        }
        .vj-role-badge--ADMINISTRATOR {
            background: #fae8ff;
            color: #a21caf;
        }
        .vj-role-badge--STUDENT {
            background: #f1f5f9;
            color: #475569;
        }
        .vj-comment-time {
            font-size: 0.78rem;
            color: #94a3b8;
        }
        .vj-comment-stars {
            color: #f59e0b;
            font-size: 0.85rem;
        }
        .vj-comment-body {
            font-size: 0.92rem;
            line-height: 1.55;
            color: #1e293b;
            white-space: pre-line;
            margin: 6px 0 10px 52px;
        }
        .vj-comment-actions {
            display: flex;
            align-items: center;
            gap: 16px;
            margin-left: 52px;
            flex-wrap: wrap;
        }
        .vj-act-btn {
            background: none;
            border: none;
            padding: 0;
            font-family: inherit;
            font-size: 0.8rem;
            font-weight: 600;
            color: #64748b;
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            gap: 4px;
        }
        .vj-act-btn:hover {
            color: #2563eb;
        }
        .vj-act-btn.liked {
            color: #2563eb;
            font-weight: 700;
        }
        .vj-act-btn--danger:hover {
            color: #dc2626;
        }

        /* Nested Replies */
        .vj-replies {
            margin-left: 52px;
            margin-top: 12px;
            padding-left: 16px;
            border-left: 2.5px solid #cbd5e1;
            display: flex;
            flex-direction: column;
            gap: 12px;
        }
        .vj-reply-item {
            background: #f8fafc;
            border-radius: 10px;
            padding: 12px 14px;
        }
        .vj-reply-box {
            display: none;
            margin-left: 52px;
            margin-top: 12px;
            background: #f8fafc;
            border: 1px solid #cbd5e1;
            border-radius: 10px;
            padding: 12px;
        }
        .vj-reply-box.open {
            display: block;
        }
        @media (max-width: 640px) {
            .vj-rating-overview {
                grid-template-columns: 1fr;
            }
            .vj-rating-score {
                border-right: none;
                border-bottom: 1px solid #e2e8f0;
                padding-right: 0;
                padding-bottom: 14px;
            }
            .vj-comment-body, .vj-comment-actions, .vj-replies, .vj-reply-box {
                margin-left: 0;
            }
        }
    </style>
</head>
<body>

<jsp:include page="/WEB-INF/views/common/navbar.jsp"/>

                        <main class="cd-main">
                            <div class="hn-container">
                                <nav class="cd-breadcrumb" aria-label="Đường dẫn trang"><a
                                        href="${pageContext.request.contextPath}/courses">Khóa học</a><span
                                        aria-hidden="true">/</span><span aria-current="page">
                                        <c:out value="${course.title}" />
                                    </span></nav>
                                <div class="cd-layout">
                                    <div class="cd-content">
                                        <section class="cd-hero" aria-labelledby="course-title">
                                            <div><span class="cd-eyebrow">KHÁM PHÁ KHÓA HỌC</span>
                                                <div class="cd-tags"><span class="cd-tag">
                                                        <c:out value="${course.categoryName}" />
                                                    </span><span class="cd-tag">
                                                        <c:out value="${course.levelLabel}" />
                                                    </span></div>
                                                <h1 id="course-title">
                                                    <c:out value="${course.title}" />
                                                </h1>
                                                <p>Giảng viên <strong>
                                                        <c:out value="${course.instructorName}" />
                                                    </strong></p>
                                            </div>
                                            <div class="cd-hero__art" aria-hidden="true">
                                                <c:choose>
                                                    <c:when test="${not empty course.thumbnailUrl}">
                                                        <c:choose>
                                                            <c:when test="${fn:startsWith(course.thumbnailUrl, 'http://') or fn:startsWith(course.thumbnailUrl, 'https://') or fn:startsWith(course.thumbnailUrl, pageContext.request.contextPath)}">
                                                                <img src="<c:out value='${course.thumbnailUrl}'/>" alt="Thumbnail" style="width:100%; height:100%; object-fit:cover; border-radius:12px;" />
                                                            </c:when>
                                                            <c:otherwise>
                                                                <img src="${pageContext.request.contextPath}<c:out value='${course.thumbnailUrl}'/>" alt="Thumbnail" style="width:100%; height:100%; object-fit:cover; border-radius:12px;" />
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </c:when>
                                                    <c:otherwise>📚</c:otherwise>
                                                </c:choose>
                                            </div>
                                        </section>
                                        <section class="cd-panel" aria-labelledby="course-about"><span
                                                class="cd-section-kicker">TỔNG QUAN</span>
                                            <h2 id="course-about">Về khóa học này</h2>
                                            <p class="cd-description">
                                                <c:out value="${course.description}"
                                                    default="Khóa học hiện chưa có mô tả." />
                                            </p>
                                        </section>
                                        <section class="cd-panel" aria-labelledby="course-lessons">
                                            <div class="cd-section-heading">
                                                <div><span class="cd-section-kicker">LỘ TRÌNH HỌC</span>
                                                    <h2 id="course-lessons">Nội dung khóa học</h2>
                                                </div>
                                                <c:if test="${not empty lessonTitles}"><span
                                                        class="cd-count">${lessonTitles.size()} bài học</span></c:if>
                                            </div>
                                            <c:choose>
                                                <c:when test="${empty lessonTitles}">
                                                    <p class="cd-empty">Nội dung bài học sẽ được cập nhật sớm.</p>
                                                </c:when>
                                                <c:otherwise>
                                                    <ol class="cd-lessons">
                                                        <c:forEach var="lessonTitle" items="${lessonTitles}"
                                                            varStatus="item">
                                                            <li><span class="cd-lesson-number">
                                                                    <fmt:formatNumber value="${item.count}"
                                                                        minIntegerDigits="2" />
                                                                </span><span>
                                                                    <c:out value="${lessonTitle}" />
                                                                </span><span class="cd-lesson-label">Bài học</span></li>
                                                        </c:forEach>
                                                    </ol>
                                                </c:otherwise>
                                            </c:choose>
                                        </section>
                                    </div>
                                    <aside class="cd-enroll" aria-labelledby="enroll-heading">
                                        <div class="cd-enroll__top"><span aria-hidden="true">🎓</span><span>ĐĂNG KÝ KHÓA
                                                HỌC</span></div>
                                        <h2 id="enroll-heading">Bắt đầu học hôm nay</h2>
                                        <p class="cd-enroll__intro">Học theo lộ trình và truy cập nội dung ngay khi ghi
                                            danh thành công.</p>
                                        <div class="cd-price-block"><span>Học phí khóa học</span><strong>
                                                <c:choose>
                                                    <c:when test="${course.free}">Miễn phí</c:when>
                                                    <c:otherwise>
                                                        <fmt:formatNumber value="${course.price}" type="number"
                                                            maxFractionDigits="0" var="formattedPrice" />
                                                        <c:out value="${fn:replace(formattedPrice, ',', '.')}" />
                                                        <c:out value="${course.currency}" />
                                                    </c:otherwise>
                                                </c:choose>
                                            </strong></div>
                                        <c:choose>
                                            <c:when test="${enrolled}">
                                                <p class="cd-enroll__notice">Bạn đã ghi danh khóa học này.</p>
                                                <a class="hn-btn hn-btn--primary hn-btn--block cd-enroll__button"
                                                    href="${pageContext.request.contextPath}/courses/${course.courseId}/learn">Vào
                                                    học ngay <span aria-hidden="true">→</span></a>
                                                <a class="cd-secondary-link"
                                                    href="${pageContext.request.contextPath}/my-courses">Xem khóa học
                                                    của tôi</a>
                                            </c:when>
                                            <c:when test="${course.free}">
                                                <sec:authorize access="isAuthenticated()">
                                                    <a class="hn-btn hn-btn--primary hn-btn--block cd-enroll__button"
                                                        href="${pageContext.request.contextPath}/courses/${course.courseId}/learn">
                                                        Vào học miễn phí ngay <span aria-hidden="true">→</span>
                                                    </a>
                                                </sec:authorize>
                                                <sec:authorize access="isAnonymous()">
                                                    <p class="cd-enroll__hint">Đăng nhập bằng tài khoản học viên để tiếp
                                                        tục.</p>
                                                    <a class="hn-btn hn-btn--primary hn-btn--block cd-enroll__button"
                                                        href="${pageContext.request.contextPath}/login?courseId=${course.courseId}">
                                                        Đăng nhập để vào học <span aria-hidden="true">→</span>
                                                    </a>
                                                </sec:authorize>
                                            </c:when>
                                            <c:otherwise>
                                                <sec:authorize access="isAuthenticated()">
                                                    <form method="post"
                                                        action="${pageContext.request.contextPath}/courses/${course.courseId}/checkout">
                                                        <input type="hidden" name="${_csrf.parameterName}"
                                                            value="${_csrf.token}">
                                                        <button
                                                            class="hn-btn hn-btn--primary hn-btn--block cd-enroll__button"
                                                            type="submit">
                                                            Đăng ký khóa học <span aria-hidden="true">→</span>
                                                        </button>
                                                    </form>
                                                    <p class="cd-enroll__hint">Bạn sẽ được chuyển sang PayOS. Quyền học
                                                        mở sau khi thanh toán được xác nhận.</p>
                                                </sec:authorize>
                                                <sec:authorize access="isAnonymous()">
                                                    <p class="cd-enroll__hint">Đăng nhập bằng tài khoản học viên để
                                                        thanh toán.</p>
                                                    <a class="hn-btn hn-btn--primary hn-btn--block cd-enroll__button"
                                                        href="${pageContext.request.contextPath}/login?courseId=${course.courseId}">
                                                        Đăng nhập để đăng ký <span aria-hidden="true">→</span>
                                                    </a>
                                                </sec:authorize>
                                            </c:otherwise>
                                        </c:choose>
                                        <div class="cd-enroll__foot"><span aria-hidden="true">✓</span> Học trên
                                            EduSphere theo tiến độ của bạn</div>
                                    </aside>
                                </div>
                            </div>
                        </main>
                        <footer class="cd-footer">
                            <div class="hn-container"><strong>EduSphere</strong><span>Học tập theo cách của
                                    bạn.</span><a href="${pageContext.request.contextPath}/courses">Khám phá khóa
                                    học</a></div>
                        </footer>
                    </body>

                    </html>