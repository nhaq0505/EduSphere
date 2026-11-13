<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>EduSphere — Nền tảng học trực tuyến</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/home.css">
</head>
<body>

<jsp:include page="/WEB-INF/views/common/navbar.jsp"/>

<!-- ══════════════════════════════════════════════
     HERO BANNER
══════════════════════════════════════════════ -->
<section class="hn-hero">
    <!-- Background image trải full width -->
    <div class="hn-hero__bg"></div>
    <!-- Overlay nhẹ để chữ dễ đọc bên trái -->
    <div class="hn-hero__overlay"></div>

    <div class="hn-hero__inner">
        <!-- Chữ đè lên ảnh, căn trái -->
        <div class="hn-hero__content">
            <p class="hn-hero__welcome">Chào mừng bạn đến với EduSphere 👋</p>
            <h1 class="hn-hero__title">
                Học mọi lúc, mọi nơi<br>
                <span class="hn-hero__title--blue">Kiến tạo tương lai</span>
            </h1>
            <p class="hn-hero__desc">
                EduSphere là nền tảng học trực tuyến giúp bạn tiếp cận
                kiến thức chất lượng, nâng cao kỹ năng và chinh phục
                những mục tiêu trong học tập và công việc.
            </p>
            <div class="hn-hero__actions">
                <a class="hn-btn hn-btn--primary hn-btn--lg" href="${pageContext.request.contextPath}/courses">
                    Khám phá khóa học →
                </a>
                <a class="hn-btn hn-btn--outline hn-btn--lg" href="#">
                    <span class="hn-play-icon">▶</span>
                    Xem video giới thiệu
                </a>
            </div>
        </div>

        <!-- Floating cards đã bỏ theo yêu cầu -->
        <div class="hn-hero__cards"></div>
    </div>
</section>

<!-- ══════════════════════════════════════════════
     FEATURES BAR
══════════════════════════════════════════════ -->
<section class="hn-features-bar">
    <div class="hn-features-bar__inner">

        <div class="hn-feat-item">
            <div class="hn-feat-item__icon hn-feat-item__icon--blue">
                <svg viewBox="0 0 24 24" fill="none" width="22" height="22">
                    <rect x="3" y="3" width="18" height="18" rx="3" stroke="currentColor" stroke-width="1.8"/>
                    <path d="M8 12l3 3 5-5" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
                </svg>
            </div>
            <div>
                <div class="hn-feat-item__title">Khóa học đa dạng</div>
                <div class="hn-feat-item__sub">Từ cơ bản đến nâng cao,<br>phù hợp mọi nhu cầu.</div>
            </div>
        </div>

        <div class="hn-feat-item__divider"></div>

        <div class="hn-feat-item">
            <div class="hn-feat-item__icon hn-feat-item__icon--blue">
                <svg viewBox="0 0 24 24" fill="none" width="22" height="22">
                    <circle cx="12" cy="8" r="4" stroke="currentColor" stroke-width="1.8"/>
                    <path d="M4 20c0-4 3.6-7 8-7s8 3 8 7" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/>
                </svg>
            </div>
            <div>
                <div class="hn-feat-item__title">Giảng viên chất lượng</div>
                <div class="hn-feat-item__sub">Đội ngũ giảng viên giàu kinh nghiệm,<br>tận tâm.</div>
            </div>
        </div>

        <div class="hn-feat-item__divider"></div>

        <div class="hn-feat-item">
            <div class="hn-feat-item__icon hn-feat-item__icon--blue">
                <svg viewBox="0 0 24 24" fill="none" width="22" height="22">
                    <rect x="2" y="5" width="20" height="14" rx="3" stroke="currentColor" stroke-width="1.8"/>
                    <path d="M8 5V3M16 5V3" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/>
                </svg>
            </div>
            <div>
                <div class="hn-feat-item__title">Học mọi lúc, mọi nơi</div>
                <div class="hn-feat-item__sub">Trên mọi thiết bị: máy tính,<br>điện thoại, tablet.</div>
            </div>
        </div>

        <div class="hn-feat-item__divider"></div>

        <div class="hn-feat-item">
            <div class="hn-feat-item__icon hn-feat-item__icon--blue">
                <svg viewBox="0 0 24 24" fill="none" width="22" height="22">
                    <path d="M12 2l2.4 7.4H22l-6.2 4.5 2.4 7.4L12 17l-6.2 4.3 2.4-7.4L2 9.4h7.6L12 2z" stroke="currentColor" stroke-width="1.8" stroke-linejoin="round"/>
                </svg>
            </div>
            <div>
                <div class="hn-feat-item__title">Thanh toán an toàn</div>
                <div class="hn-feat-item__sub">Nhiều phương thức thanh toán<br>linh hoạt, bảo mật.</div>
            </div>
        </div>

        <div class="hn-feat-item__divider"></div>

        <div class="hn-feat-item">
            <div class="hn-feat-item__icon hn-feat-item__icon--blue">
                <svg viewBox="0 0 24 24" fill="none" width="22" height="22">
                    <path d="M3 5a2 2 0 012-2h14a2 2 0 012 2v10a2 2 0 01-2 2H5a2 2 0 01-2-2V5z" stroke="currentColor" stroke-width="1.8"/>
                    <path d="M3 9h18M9 9v10" stroke="currentColor" stroke-width="1.8"/>
                </svg>
            </div>
            <div>
                <div class="hn-feat-item__title">Hỗ trợ 24/7</div>
                <div class="hn-feat-item__sub">Luôn sẵn sàng giải đáp<br>mọi thắc mắc của bạn.</div>
            </div>
        </div>

    </div>
</section>

<!-- ══════════════════════════════════════════════
     FEATURED COURSES
══════════════════════════════════════════════ -->
<section class="hn-courses-section">
    <div class="hn-container">
        <div class="hn-courses-wrapper">

            <!-- Header: tiêu đề banner + subtitle -->
            <div class="hn-courses-header">
                <div class="hn-courses-header__title-wrap">
                    <span class="hn-courses-header__badge">🔥 Khóa học nổi bật 🔥</span>
                </div>
                <p class="hn-courses-header__sub">• Những khóa học được nhiều người quan tâm nhất •</p>
            </div>

            <!-- Grid courses (sẽ thêm data sau) -->
            <div class="hn-courses-body">
                <div class="hn-course-grid">
                    <!-- Khóa học sẽ được thêm sau -->
                </div>
            </div><!-- /hn-courses-body -->

            <!-- Link xem tất cả -->
            <div class="hn-courses-footer">
                <a class="hn-link-more" href="${pageContext.request.contextPath}/courses">Xem tất cả khóa học →</a>
            </div>

        </div><!-- /hn-courses-wrapper -->
    </div>
</section>

<!-- ══════════════════════════════════════════════
     DANH MỤC KHÓA HỌC
══════════════════════════════════════════════ -->
<section class="hn-cat-section">
    <div class="hn-container">
        <div class="hn-cat-wrapper">

            <!-- Header -->
            <div class="hn-cat-header">
                <div class="hn-cat-header__left">
                    <h2 class="hn-cat-header__title">Danh mục khoá học</h2>
                    <p class="hn-cat-header__sub">Khám phá khoá học theo lĩnh vực bạn quan tâm</p>
                </div>
                <a class="hn-link-more" href="${pageContext.request.contextPath}/courses">Xem tất cả →</a>
            </div>

            <!-- Danh mục sẽ được thêm sau -->
            <div class="hn-cat-grid">
                <!-- items sẽ thêm sau -->
            </div>

        </div>
    </div>
</section>
<footer class="hn-footer">
    <div class="hn-footer__inner">
        <div class="hn-footer__brand">
            <a class="hn-logo" href="${pageContext.request.contextPath}/">
                <div class="hn-logo__icon">🎓</div>
                <span>EduSphere</span>
            </a>
            <p>Nền tảng học tập trực tuyến chất lượng cao dành cho mọi người.</p>
        </div>
        <div class="hn-footer__col">
            <h4>Khóa học</h4>
            <a href="${pageContext.request.contextPath}/courses">Tất cả khóa học</a>
            <a href="${pageContext.request.contextPath}/courses?level=BEGINNER">Dành cho người mới</a>
            <a href="${pageContext.request.contextPath}/courses?priceFilter=FREE">Miễn phí</a>
        </div>
        <div class="hn-footer__col">
            <h4>Tài khoản</h4>
            <a href="${pageContext.request.contextPath}/register">Đăng ký</a>
            <a href="${pageContext.request.contextPath}/login">Đăng nhập</a>
            <a href="${pageContext.request.contextPath}/profile">Hồ sơ</a>
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
function toggleUserMenu(e) {
    e.stopPropagation();
    const menu = e.currentTarget.closest('.hn-user-menu');
    menu.classList.toggle('open');
}
document.addEventListener('click', function() {
    document.querySelectorAll('.hn-user-menu.open').forEach(m => m.classList.remove('open'));
});
</script>
</body>
</html>