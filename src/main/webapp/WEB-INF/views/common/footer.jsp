<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<%--
    EduSphere Common Footer Fragment
    Footer chuẩn theo phong cách giao diện của EduSphere
--%>

<style>
/* ===== EduSphere Common Footer Styles ===== */
.site-footer.edusphere-footer {
    background: #ffffff;
    border-top: 1px solid #e5e7eb;
    margin-top: 56px;
    font-size: 0.9rem;
    color: #4b5563;
    box-shadow: 0 -2px 10px rgba(0, 0, 0, 0.02);
}

.edusphere-footer .footer-container {
    max-width: 1140px;
    margin: 0 auto;
    padding: 48px 24px 28px;
}

.edusphere-footer .footer-grid {
    display: grid;
    grid-template-columns: 2fr 1fr 1fr 1.3fr;
    gap: 40px;
    margin-bottom: 36px;
}

.edusphere-footer .footer-col-brand {
    padding-right: 20px;
}

.edusphere-footer .footer-brand-title {
    font-size: 1.5rem;
    font-weight: 800;
    color: #667eea;
    text-decoration: none;
    letter-spacing: -0.3px;
    display: inline-block;
    margin-bottom: 12px;
}

.edusphere-footer .footer-brand-title:hover {
    color: #5365c8;
}

.edusphere-footer .footer-tagline {
    color: #6b7280;
    font-size: 0.88rem;
    line-height: 1.6;
    margin-bottom: 16px;
}

.edusphere-footer .footer-pills {
    display: flex;
    gap: 8px;
    flex-wrap: wrap;
}

.edusphere-footer .footer-pill {
    display: inline-flex;
    align-items: center;
    gap: 4px;
    background: #f3f4f6;
    color: #4b5563;
    font-size: 0.78rem;
    font-weight: 600;
    padding: 4px 10px;
    border-radius: 12px;
}

.edusphere-footer .footer-heading {
    font-size: 0.92rem;
    font-weight: 700;
    color: #1f2937;
    margin-bottom: 16px;
    text-transform: uppercase;
    letter-spacing: 0.5px;
}

.edusphere-footer .footer-nav-list {
    list-style: none;
    padding: 0;
    margin: 0;
    display: flex;
    flex-direction: column;
    gap: 10px;
}

.edusphere-footer .footer-nav-list a {
    color: #4b5563;
    text-decoration: none;
    font-size: 0.88rem;
    font-weight: 500;
    transition: color 0.15s ease, transform 0.15s ease;
    display: inline-block;
}

.edusphere-footer .footer-nav-list a:hover {
    color: #667eea;
    transform: translateX(3px);
}

.edusphere-footer .footer-contact-list {
    list-style: none;
    padding: 0;
    margin: 0;
    display: flex;
    flex-direction: column;
    gap: 10px;
    font-size: 0.88rem;
    color: #4b5563;
}

.edusphere-footer .footer-contact-list li {
    display: flex;
    align-items: flex-start;
    gap: 8px;
    line-height: 1.5;
}

.edusphere-footer .footer-contact-icon {
    font-size: 0.95rem;
    flex-shrink: 0;
}

.edusphere-footer .footer-divider {
    height: 1px;
    background: #f0f2f5;
    margin-bottom: 24px;
}

.edusphere-footer .footer-bottom {
    display: flex;
    justify-content: space-between;
    align-items: center;
    font-size: 0.84rem;
    color: #9ca3af;
}

.edusphere-footer .footer-copyright {
    margin: 0;
}

.edusphere-footer .footer-legal-links {
    display: flex;
    align-items: center;
    gap: 12px;
}

.edusphere-footer .footer-legal-links a {
    color: #6b7280;
    text-decoration: none;
    font-size: 0.84rem;
    transition: color 0.15s ease;
}

.edusphere-footer .footer-legal-links a:hover {
    color: #667eea;
}

.edusphere-footer .legal-sep {
    color: #d1d5db;
    font-size: 0.75rem;
}
</style>

<footer class="site-footer edusphere-footer" aria-label="Chân trang">
    <div class="footer-container">
        <div class="footer-grid">
            <%-- Cột 1: Thông tin thương hiệu EduSphere --%>
            <div class="footer-col footer-col-brand">
                <a href="${pageContext.request.contextPath}/" class="footer-brand-title">EduSphere</a>
                <p class="footer-tagline">
                    Nền tảng học trực tuyến chất lượng cao, cung cấp các khóa học đa dạng từ cơ bản đến chuyên sâu. Đồng hành cùng bạn trên hành trình phát triển tri thức và sự nghiệp tương lai.
                </p>
                <div class="footer-pills">
                    <span class="footer-pill">🎓 Học mọi lúc mọi nơi</span>
                    <span class="footer-pill">⚡ Giảng viên chất lượng</span>
                </div>
            </div>

            <%-- Cột 2: Khám phá & Học tập --%>
            <div class="footer-col">
                <h4 class="footer-heading">Học tập</h4>
                <ul class="footer-nav-list">
                    <li><a href="${pageContext.request.contextPath}/courses">Khám phá khóa học</a></li>
                    <li><a href="${pageContext.request.contextPath}/courses/my-courses">Khóa học của tôi</a></li>
                    <li><a href="${pageContext.request.contextPath}/dashboard">Bảng điều khiển</a></li>
                </ul>
            </div>

            <%-- Cột 3: Tài khoản & Hỗ trợ --%>
            <div class="footer-col">
                <h4 class="footer-heading">Tài khoản</h4>
                <ul class="footer-nav-list">
                    <li><a href="${pageContext.request.contextPath}/profile">Hồ sơ cá nhân</a></li>
                    <li><a href="${pageContext.request.contextPath}/change-password">Đổi mật khẩu</a></li>
                    <li><a href="${pageContext.request.contextPath}/login">Đăng nhập</a></li>
                    <li><a href="${pageContext.request.contextPath}/register">Đăng ký tài khoản</a></li>
                </ul>
            </div>

            <%-- Cột 4: Liên hệ --%>
            <div class="footer-col">
                <h4 class="footer-heading">Liên hệ</h4>
                <ul class="footer-contact-list">
                    <li><span class="footer-contact-icon">📍</span> Hà Nội &amp; TP. Hồ Chí Minh</li>
                    <li><span class="footer-contact-icon">✉️</span> support@edusphere.vn</li>
                    <li><span class="footer-contact-icon">📞</span> Hotline: 1900 6868</li>
                    <li><span class="footer-contact-icon">⏰</span> 08:00 - 21:00 (Thứ 2 - Thứ 7)</li>
                </ul>
            </div>
        </div>

        <div class="footer-divider"></div>

        <%-- Chân trang cuối --%>
        <div class="footer-bottom">
            <p class="footer-copyright">
                &copy; 2026 EduSphere. Tất cả các quyền được bảo lưu.
            </p>
            <div class="footer-legal-links">
                <a href="#">Điều khoản dịch vụ</a>
                <span class="legal-sep">•</span>
                <a href="#">Chính sách bảo mật</a>
                <span class="legal-sep">•</span>
                <a href="#">Quy chế hoạt động</a>
            </div>
        </div>
    </div>
</footer>
