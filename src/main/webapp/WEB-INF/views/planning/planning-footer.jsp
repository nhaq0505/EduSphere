<%@ page contentType="text/html;charset=UTF-8" %>
<footer class="hn-footer">
    <div class="hn-footer__inner">
        <div class="hn-footer__brand">
            <a class="hn-logo" href="${pageContext.request.contextPath}/">
                <div class="hn-logo__icon">🎓</div>
                <span>EduSphere</span>
            </a>
            <p>Không gian học tập rõ ràng, tập trung và có định hướng.</p>
        </div>
        <div class="hn-footer__col">
            <h4>Khóa học</h4>
            <a href="${pageContext.request.contextPath}/courses">Tất cả khóa học</a>
            <a href="${pageContext.request.contextPath}/courses?level=BEGINNER">Dành cho người mới</a>
            <a href="${pageContext.request.contextPath}/courses?priceFilter=FREE">Miễn phí</a>
        </div>
        <div class="hn-footer__col">
            <h4>Kế hoạch & Tiến độ</h4>
            <a href="${pageContext.request.contextPath}/study/plans">Kế hoạch học tập</a>
            <a href="${pageContext.request.contextPath}/study/calendar">Lịch học cá nhân</a>
            <a href="${pageContext.request.contextPath}/study/progress">Theo dõi tiến độ</a>
            <a href="${pageContext.request.contextPath}/study/history">Lịch sử hoạt động</a>
        </div>
        <div class="hn-footer__col">
            <h4>Tài khoản</h4>
            <a href="${pageContext.request.contextPath}/profile">Hồ sơ cá nhân</a>
            <a href="${pageContext.request.contextPath}/my-courses">Khóa học của tôi</a>
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