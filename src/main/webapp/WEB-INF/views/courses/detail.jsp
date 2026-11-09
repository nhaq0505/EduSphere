<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
            <%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
                <%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
                    <fmt:setLocale value="vi_VN" />
                    <!DOCTYPE html>
                    <html lang="vi">

                    <head>
                        <meta charset="UTF-8">
                        <meta name="viewport" content="width=device-width, initial-scale=1.0">
                        <title>
                            <c:out value="${course.title}" /> — EduSphere
                        </title>
                        <link rel="preconnect" href="https://fonts.googleapis.com">
                        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
                        <link
                            href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap"
                            rel="stylesheet">
                        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/home.css">
                        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/course-detail.css">
                    </head>

                    <body>
                        <header class="hn-header">
                            <div class="hn-header__inner">
                                <a class="hn-logo" href="${pageContext.request.contextPath}/"
                                    aria-label="EduSphere - Trang chủ"><span class="hn-logo__icon"
                                        aria-hidden="true">🎓</span><span>EduSphere</span></a>
                                <nav class="hn-nav" aria-label="Điều hướng chính">
                                    <a class="hn-nav__link" href="${pageContext.request.contextPath}/">Trang chủ</a>
                                    <a class="hn-nav__link hn-nav__link--active"
                                        href="${pageContext.request.contextPath}/courses" aria-current="page">Khóa
                                        học</a>
                                    <sec:authorize access="hasRole('STUDENT')"><a class="hn-nav__link"
                                            href="${pageContext.request.contextPath}/my-courses">Khóa học của tôi</a>
                                    </sec:authorize>
                                    <sec:authorize access="hasRole('INSTRUCTOR')"><a class="hn-nav__link"
                                            href="${pageContext.request.contextPath}/instructor/courses">Giảng viên</a>
                                    </sec:authorize>
                                    <sec:authorize access="hasRole('ADMINISTRATOR')"><a class="hn-nav__link"
                                            href="${pageContext.request.contextPath}/admin/users">Quản trị</a>
                                    </sec:authorize>
                                </nav>
                                <div class="hn-header__right cd-header-actions">
                                    <form class="cd-header-search" action="${pageContext.request.contextPath}/courses"
                                        method="get" role="search">
                                        <label class="cd-sr-only" for="course-search">Tìm khóa học</label>
                                        <input id="course-search" name="q" type="search"
                                            placeholder="Tìm kiếm khóa học...">
                                        <button type="submit" aria-label="Tìm kiếm">⌕</button>
                                    </form>
                                    <sec:authorize access="isAnonymous()"><a class="hn-btn hn-btn--ghost"
                                            href="${pageContext.request.contextPath}/login">Đăng nhập</a><a
                                            class="hn-btn hn-btn--primary"
                                            href="${pageContext.request.contextPath}/register">Đăng ký</a>
                                    </sec:authorize>
                                    <sec:authorize access="isAuthenticated()"><a class="cd-profile-link"
                                            href="${pageContext.request.contextPath}/profile">Hồ sơ</a></sec:authorize>
                                </div>
                            </div>
                        </header>

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
                                                <div class="cd-hero-meta">
                                                    <p>Giảng viên <strong>
                                                            <c:out value="${course.instructorName}" />
                                                        </strong></p>
                                                    <a href="#course-reviews" class="cd-hero-rating">
                                                        <span>⭐</span>
                                                        <c:choose>
                                                            <c:when test="${ratingSummary.totalRatings > 0}">
                                                                <strong>${ratingSummary.averageRating}/5</strong>
                                                                <span>(${ratingSummary.totalRatings} đánh giá)</span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span>Chưa có đánh giá</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </a>
                                                </div>
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

                                        <%-- ══════ PHẦN ĐÁNH GIÁ & NHẬN XÉT CỦA HỌC VIÊN ══════ --%>
                                        <section class="cd-panel" id="course-reviews" aria-labelledby="course-reviews-heading">
                                            <div class="cd-section-heading">
                                                <div>
                                                    <span class="cd-section-kicker">PHẢN HỒI HỌC VIÊN</span>
                                                    <h2 id="course-reviews-heading">Đánh giá khóa học</h2>
                                                </div>
                                                <span class="cd-count">${ratingSummary.totalRatings} lượt đánh giá</span>
                                            </div>

                                            <c:if test="${not empty ratingSuccess}">
                                                <div class="cd-rating-alert cd-rating-alert--ok">
                                                    ✅ <c:out value="${ratingSuccess}" />
                                                </div>
                                            </c:if>
                                            <c:if test="${not empty ratingError}">
                                                <div class="cd-rating-alert cd-rating-alert--err">
                                                    ⚠️ <c:out value="${ratingError}" />
                                                </div>
                                            </c:if>

                                            <%-- Tổng quan điểm sao (1..5) --%>
                                            <div class="cd-rating-overview">
                                                <div class="cd-rating-score-box">
                                                    <div class="cd-rating-score-num">
                                                        <c:choose>
                                                            <c:when test="${ratingSummary.totalRatings > 0}">${ratingSummary.averageRating}</c:when>
                                                            <c:otherwise>—</c:otherwise>
                                                        </c:choose>
                                                    </div>
                                                    <div class="cd-rating-score-stars" aria-hidden="true">
                                                        <c:forEach begin="1" end="5" var="st">
                                                            <c:choose>
                                                                <c:when test="${st <= ratingSummary.roundedStars}">★</c:when>
                                                                <c:otherwise>☆</c:otherwise>
                                                            </c:choose>
                                                        </c:forEach>
                                                    </div>
                                                    <div class="cd-rating-score-count">
                                                        ${ratingSummary.totalRatings} đánh giá từ học viên
                                                    </div>
                                                </div>

                                                <div class="cd-rating-bars">
                                                    <c:forEach var="starEntry" items="${ratingSummary.starPercents}">
                                                        <div class="cd-rating-bar-row">
                                                            <span>${starEntry.key} ⭐</span>
                                                            <div class="cd-rating-bar-track">
                                                                <div class="cd-rating-bar-fill" style="width:${starEntry.value}%;"></div>
                                                            </div>
                                                            <span style="text-align:right;">${ratingSummary.starCounts[starEntry.key]} (${starEntry.value}%)</span>
                                                        </div>
                                                    </c:forEach>
                                                </div>
                                            </div>

                                            <%-- Form gửi / sửa đánh giá (chỉ mở cho học viên đã ghi danh) --%>
                                            <c:choose>
                                                <c:when test="${ratingSummary.canRate}">
                                                    <c:set var="currentStar" value="${ratingSummary.myRating != null ? ratingSummary.myRating.rating : 5}" />
                                                    <div class="cd-review-form-box">
                                                        <div class="cd-review-form-title">
                                                            <span>
                                                                <c:choose>
                                                                    <c:when test="${ratingSummary.myRating != null}">✏️ Cập nhật đánh giá của bạn</c:when>
                                                                    <c:otherwise>⭐ Gửi đánh giá của bạn về khóa học này</c:otherwise>
                                                                </c:choose>
                                                            </span>
                                                            <c:if test="${ratingSummary.myRating != null}">
                                                                <form method="post"
                                                                      action="${pageContext.request.contextPath}/courses/${course.courseId}/ratings/delete"
                                                                      style="margin:0;"
                                                                      onsubmit="return confirm('Bạn có chắc muốn xóa đánh giá của mình?');">
                                                                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                                                    <button type="submit" class="cd-btn-delete-review">🗑️ Xóa đánh giá</button>
                                                                </form>
                                                            </c:if>
                                                        </div>

                                                        <form method="post" action="${pageContext.request.contextPath}/courses/${course.courseId}/ratings">
                                                            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                                            <input type="hidden" name="rating" id="selectedRatingInput" value="${currentStar}">

                                                            <div class="cd-star-picker" role="radiogroup" aria-label="Chọn số sao đánh giá">
                                                                <c:forEach begin="1" end="5" var="s">
                                                                    <button type="button"
                                                                            class="cd-star-btn ${s <= currentStar ? 'active' : ''}"
                                                                            data-star="${s}"
                                                                            onclick="selectCourseStar(${s})"
                                                                            title="${s} sao">★</button>
                                                                </c:forEach>
                                                                <span class="cd-star-label" id="selectedStarLabel">5 sao — Tuyệt vời!</span>
                                                            </div>

                                                            <textarea name="comment"
                                                                      class="cd-review-textarea"
                                                                      maxlength="2000"
                                                                      placeholder="Chia sẻ trải nghiệm học tập của bạn: nội dung bài giảng, bài tập thực hành, sự hỗ trợ của giảng viên..."><c:out value="${ratingSummary.myRating != null ? ratingSummary.myRating.comment : ''}" /></textarea>

                                                            <div class="cd-review-form-actions">
                                                                <span style="font-size:.78rem; color:#64748B;">
                                                                    Đánh giá của bạn giúp học viên khác hiểu rõ hơn về khóa học.
                                                                </span>
                                                                <button type="submit" class="hn-btn hn-btn--primary">
                                                                    <c:choose>
                                                                        <c:when test="${ratingSummary.myRating != null}">💾 Lưu cập nhật</c:when>
                                                                        <c:otherwise>🚀 Gửi đánh giá</c:otherwise>
                                                                    </c:choose>
                                                                </button>
                                                            </div>
                                                        </form>
                                                    </div>
                                                </c:when>
                                                <c:when test="${not enrolled}">
                                                    <div class="cd-review-hint-box">
                                                        <span>💡 Bạn cần ghi danh và tham gia khóa học để có thể gửi đánh giá sao và nhận xét.</span>
                                                    </div>
                                                </c:when>
                                            </c:choose>

                                            <%-- Danh sách đánh giá của học viên --%>
                                            <c:choose>
                                                <c:when test="${empty ratingSummary.reviews}">
                                                    <p class="cd-empty">Chưa có đánh giá nào cho khóa học này. Hãy là học viên đầu tiên để lại cảm nhận!</p>
                                                </c:when>
                                                <c:otherwise>
                                                    <div class="cd-review-list">
                                                        <c:forEach var="rv" items="${ratingSummary.reviews}">
                                                            <article class="cd-review-card ${ratingSummary.myRating != null and ratingSummary.myRating.ratingId == rv.ratingId ? 'cd-review-card--mine' : ''}">
                                                                <div class="cd-review-head">
                                                                    <div class="cd-review-author">
                                                                        <div class="cd-review-avatar" aria-hidden="true">
                                                                            <c:out value="${rv.studentInitial}" />
                                                                        </div>
                                                                        <div>
                                                                            <div class="cd-review-name">
                                                                                <span><c:out value="${rv.studentName}" /></span>
                                                                                <span class="cd-review-badge">✓ Đã ghi danh</span>
                                                                                <c:if test="${ratingSummary.myRating != null and ratingSummary.myRating.ratingId == rv.ratingId}">
                                                                                    <span style="font-size:.72rem; color:#2563EB; font-weight:700;">(Đánh giá của bạn)</span>
                                                                                </c:if>
                                                                            </div>
                                                                            <div class="cd-review-date">
                                                                                <c:out value="${rv.createdAtFormatted}" />
                                                                                <c:if test="${rv.edited}"> · Đã chỉnh sửa</c:if>
                                                                            </div>
                                                                        </div>
                                                                    </div>
                                                                    <div class="cd-review-stars" aria-label="${rv.rating} trên 5 sao">
                                                                        <c:forEach begin="1" end="5" var="st">
                                                                            <c:choose>
                                                                                <c:when test="${st <= rv.rating}">★</c:when>
                                                                                <c:otherwise>☆</c:otherwise>
                                                                            </c:choose>
                                                                        </c:forEach>
                                                                    </div>
                                                                </div>

                                                                <c:choose>
                                                                    <c:when test="${not empty rv.comment}">
                                                                        <p class="cd-review-comment"><c:out value="${rv.comment}" /></p>
                                                                    </c:when>
                                                                    <c:otherwise>
                                                                        <p class="cd-review-comment" style="color:#94A3B8; font-style:italic;">Học viên đã đánh giá ${rv.rating} sao.</p>
                                                                    </c:otherwise>
                                                                </c:choose>

                                                                <%-- Phản hồi từ giảng viên (nếu có) --%>
                                                                <c:if test="${not empty rv.instructorReply}">
                                                                    <div class="cd-review-reply">
                                                                        <div class="cd-review-reply__head">
                                                                            <span>🎓 Phản hồi từ Giảng viên</span>
                                                                            <c:if test="${not empty rv.repliedAtFormatted}">
                                                                                <span style="font-weight:500; color:#64748B;">· <c:out value="${rv.repliedAtFormatted}" /></span>
                                                                            </c:if>
                                                                        </div>
                                                                        <p class="cd-review-reply__text"><c:out value="${rv.instructorReply}" /></p>
                                                                    </div>
                                                                </c:if>

                                                                <%-- Nếu người xem là Giảng viên sở hữu khóa học hoặc Admin -> cho phép phản hồi --%>
                                                                <c:if test="${ratingSummary.canReply}">
                                                                    <details style="margin-top:10px;">
                                                                        <summary style="cursor:pointer; font-size:.8rem; font-weight:700; color:#2563EB;">
                                                                            💬 ${not empty rv.instructorReply ? 'Sửa phản hồi giảng viên' : 'Phản hồi đánh giá này'}
                                                                        </summary>
                                                                        <form method="post"
                                                                              action="${pageContext.request.contextPath}/courses/${course.courseId}/ratings/${rv.ratingId}/reply"
                                                                              style="margin-top:8px; display:grid; gap:8px;">
                                                                            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                                                            <textarea name="replyText"
                                                                                      class="cd-review-textarea"
                                                                                      style="min-height:64px;"
                                                                                      maxlength="2000"
                                                                                      placeholder="Nhập phản hồi của giảng viên cho học viên..."><c:out value="${rv.instructorReply}" /></textarea>
                                                                            <div style="display:flex; justify-content:flex-end;">
                                                                                <button type="submit" class="hn-btn hn-btn--primary" style="font-size:.8rem; padding:6px 14px;">
                                                                                    Gửi phản hồi
                                                                                </button>
                                                                            </div>
                                                                        </form>
                                                                    </details>
                                                                </c:if>
                                                            </article>
                                                        </c:forEach>
                                                    </div>
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
                        <script>
                            var STAR_LABELS = {
                                1: '1 sao — Rất tệ',
                                2: '2 sao — Chưa tốt',
                                3: '3 sao — Bình thường',
                                4: '4 sao — Hài lòng',
                                5: '5 sao — Tuyệt vời!'
                            };
                            function selectCourseStar(star) {
                                var input = document.getElementById('selectedRatingInput');
                                var label = document.getElementById('selectedStarLabel');
                                if (input) input.value = star;
                                if (label && STAR_LABELS[star]) label.textContent = STAR_LABELS[star];
                                var btns = document.querySelectorAll('.cd-star-btn');
                                btns.forEach(function (btn) {
                                    var s = parseInt(btn.getAttribute('data-star'), 10);
                                    if (s <= star) {
                                        btn.classList.add('active');
                                    } else {
                                        btn.classList.remove('active');
                                    }
                                });
                            }
                            document.addEventListener('DOMContentLoaded', function () {
                                var input = document.getElementById('selectedRatingInput');
                                if (input && input.value) {
                                    selectCourseStar(parseInt(input.value, 10));
                                }
                            });
                        </script>
                    </body>

                    </html>