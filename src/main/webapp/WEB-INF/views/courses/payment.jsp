<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"   uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn"  uri="jakarta.tags.functions" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<c:set var="cp" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Thanh toán khóa học — EduSphere</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${cp}/assets/css/home.css">
    <style>
        .pm-page {
            background: linear-gradient(180deg, #F0F8FF 0%, #E6F3FD 100%);
            min-height: calc(100vh - 66px);
            padding: 36px 16px 60px;
            position: relative;
            overflow-x: hidden;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        /* Decorative Background Elements */
        .pm-bg-circle {
            position: absolute;
            border-radius: 50%;
            pointer-events: none;
            z-index: 0;
        }
        .pm-bg-circle--1 {
            width: 380px; height: 380px;
            background: rgba(56, 189, 248, 0.12);
            top: -100px; left: -100px;
            filter: blur(60px);
        }
        .pm-bg-circle--2 {
            width: 420px; height: 420px;
            background: rgba(37, 99, 235, 0.08);
            bottom: -120px; right: -100px;
            filter: blur(70px);
        }
        .pm-bg-art {
            position: absolute;
            bottom: 20px;
            right: 40px;
            width: 220px;
            opacity: 0.18;
            pointer-events: none;
            z-index: 0;
        }

        /* Main Container Card */
        .pm-card {
            max-width: 1040px;
            width: 100%;
            background: #ffffff;
            border-radius: 24px;
            box-shadow: 0 12px 40px rgba(27, 154, 245, 0.09);
            border: 1.5px solid #BAE0FD;
            padding: 32px 36px;
            display: grid;
            grid-template-columns: 1fr 380px;
            gap: 32px;
            position: relative;
            z-index: 1;
        }

        /* Left Column */
        .pm-left {
            display: flex;
            flex-direction: column;
            gap: 18px;
        }

        /* Back Link */
        .pm-back-link {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            font-size: 0.88rem;
            font-weight: 600;
            color: #0284C7;
            text-decoration: none;
            transition: color 0.18s;
            width: fit-content;
        }
        .pm-back-link:hover {
            color: #0369A1;
            text-decoration: underline;
        }

        /* Course Summary Top */
        .pm-course-box {
            display: flex;
            align-items: center;
            gap: 18px;
            background: #F8FAFC;
            border: 1px solid #E2E8F0;
            border-radius: 16px;
            padding: 14px 18px;
        }
        .pm-course-thumb {
            width: 120px;
            height: 78px;
            border-radius: 10px;
            object-fit: cover;
            flex-shrink: 0;
            box-shadow: 0 2px 8px rgba(0,0,0,0.06);
            background: #E2E8F0;
        }
        .pm-course-info {
            flex: 1;
            min-width: 0;
        }
        .pm-course-title {
            font-size: 1.05rem;
            font-weight: 800;
            color: #0F172A;
            margin: 0 0 4px;
            line-height: 1.35;
        }
        .pm-course-desc {
            font-size: 0.8rem;
            color: #64748B;
            margin: 0 0 6px;
            line-height: 1.4;
            display: -webkit-box;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
            overflow: hidden;
        }
        .pm-course-meta {
            display: flex;
            align-items: center;
            gap: 8px;
            font-size: 0.78rem;
            color: #475569;
            font-weight: 600;
        }
        .pm-star { color: #F59E0B; }

        /* QR Payment Section */
        .pm-qr-section {
            border: 1.5px solid #BAE0FD;
            border-radius: 18px;
            overflow: hidden;
            background: #ffffff;
            box-shadow: 0 4px 16px rgba(27,154,245,0.04);
        }
        .pm-qr-header {
            background: linear-gradient(90deg, #F0F8FF 0%, #E6F3FD 100%);
            padding: 12px 20px;
            border-bottom: 1px solid #BAE0FD;
            text-align: center;
        }
        .pm-qr-badge {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            font-weight: 700;
            color: #0284C7;
            font-size: 0.95rem;
        }
        .pm-qr-sub {
            font-size: 0.8rem;
            color: #64748B;
            margin: 2px 0 0;
        }
        .pm-qr-body {
            padding: 32px 24px;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
        }

        /* QR Code Container with Frame */
        .pm-qr-frame {
            position: relative;
            padding: 12px;
            background: #ffffff;
            border: 2px solid #BAE0FD;
            border-radius: 20px;
            box-shadow: 0 8px 28px rgba(27, 154, 245, 0.08);
            display: flex;
            align-items: center;
            justify-content: center;
            max-width: 380px;
            width: 100%;
            transition: transform 0.2s ease, box-shadow 0.2s ease;
        }
        .pm-qr-frame:hover {
            transform: translateY(-2px);
            box-shadow: 0 12px 32px rgba(27, 154, 245, 0.12);
        }
        .pm-qr-img {
            width: 100%;
            height: auto;
            border-radius: 12px;
            display: block;
        }

        /* Right Column (Thông tin đơn hàng) */
        .pm-right {
            background: #F8FAFC;
            border: 1.5px solid #E2E8F0;
            border-radius: 20px;
            padding: 24px;
            display: flex;
            flex-direction: column;
            gap: 18px;
            height: fit-content;
        }

        .pm-order-head {
            display: flex;
            align-items: center;
            gap: 12px;
        }
        .pm-cart-badge {
            width: 36px;
            height: 36px;
            background: #1B9AF5;
            border-radius: 50%;
            color: #ffffff;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.1rem;
            flex-shrink: 0;
            box-shadow: 0 4px 10px rgba(27,154,245,0.3);
        }
        .pm-order-title {
            margin: 0;
            font-size: 1.1rem;
            font-weight: 800;
            color: #0F172A;
        }

        /* Mini Course Item */
        .pm-mini-course {
            background: #ffffff;
            border: 1px solid #E2E8F0;
            border-radius: 12px;
            padding: 12px;
            display: flex;
            align-items: center;
            gap: 12px;
            box-shadow: 0 2px 6px rgba(0,0,0,0.02);
        }
        .pm-mini-thumb {
            width: 58px;
            height: 38px;
            border-radius: 8px;
            object-fit: cover;
            flex-shrink: 0;
            background: #E2E8F0;
        }
        .pm-mini-info {
            flex: 1;
            min-width: 0;
        }
        .pm-mini-name {
            font-size: 0.84rem;
            font-weight: 700;
            color: #0F172A;
            margin: 0 0 2px;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }
        .pm-mini-type {
            font-size: 0.74rem;
            color: #64748B;
            margin: 0;
        }
        .pm-mini-price {
            font-size: 0.95rem;
            font-weight: 800;
            color: #0284C7;
            white-space: nowrap;
        }

        /* Details list */
        .pm-details-list {
            display: flex;
            flex-direction: column;
            gap: 12px;
            font-size: 0.85rem;
        }
        .pm-detail-row {
            display: flex;
            align-items: center;
            justify-content: space-between;
        }
        .pm-detail-label {
            color: #64748B;
            font-weight: 500;
        }
        .pm-detail-val {
            font-weight: 700;
            color: #0F172A;
        }
        .pm-timer-badge {
            display: inline-flex;
            align-items: center;
            gap: 4px;
            color: #0284C7;
            font-weight: 700;
        }

        .pm-divider {
            height: 1px;
            background: #E2E8F0;
            margin: 4px 0;
        }

        .pm-total-label {
            font-size: 0.95rem;
            font-weight: 700;
            color: #0F172A;
        }
        .pm-total-val {
            font-size: 1.35rem;
            font-weight: 900;
            color: #0284C7;
        }

        /* Success / Info Note Alert */
        .pm-note-box {
            background: #EFF6FF;
            border: 1px solid #BAE0FD;
            border-radius: 12px;
            padding: 12px 14px;
            color: #1E40AF;
            font-size: 0.8rem;
            line-height: 1.45;
            display: flex;
            gap: 10px;
            align-items: flex-start;
        }
        .pm-note-icon {
            font-size: 1.05rem;
            line-height: 1;
            color: #0284C7;
            flex-shrink: 0;
        }

        /* Live status polling indicator */
        .pm-status-pill {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            font-size: 0.78rem;
            color: #64748B;
            font-weight: 600;
            text-align: center;
            padding: 6px 12px;
            background: #ffffff;
            border: 1px dashed #CBD5E1;
            border-radius: 99px;
        }
        .pm-pulse-dot {
            width: 8px;
            height: 8px;
            border-radius: 50%;
            background: #10B981;
            animation: pmPulse 1.6s infinite ease-in-out;
        }
        @keyframes pmPulse {
            0% { transform: scale(0.9); opacity: 0.7; }
            50% { transform: scale(1.3); opacity: 1; box-shadow: 0 0 10px rgba(16, 185, 129, 0.6); }
            100% { transform: scale(0.9); opacity: 0.7; }
        }

        /* Toast notification */
        .pm-toast {
            position: fixed;
            bottom: 24px;
            right: 24px;
            background: #0F172A;
            color: #ffffff;
            padding: 10px 18px;
            border-radius: 10px;
            font-size: 0.84rem;
            font-weight: 600;
            box-shadow: 0 6px 20px rgba(0,0,0,0.15);
            display: none;
            z-index: 9999;
        }

        /* Responsive */
        @media (max-width: 960px) {
            .pm-card {
                grid-template-columns: 1fr;
                gap: 24px;
                padding: 24px;
            }
            .pm-course-box {
                flex-direction: column;
                align-items: flex-start;
            }
            .pm-course-thumb {
                width: 100%;
                height: 140px;
            }
        }
    </style>
</head>
<body>

<%-- ══════ HEADER DÙNG CHUNG ══════ --%>
<jsp:include page="/WEB-INF/views/common/navbar.jsp"/>

<main class="pm-page">
    <%-- Background decorative shapes --%>
    <div class="pm-bg-circle pm-bg-circle--1"></div>
    <div class="pm-bg-circle pm-bg-circle--2"></div>
    
    <!-- Watermark illustrations -->
    <svg class="pm-bg-art" viewBox="0 0 200 200" fill="none" xmlns="http://www.w3.org/2000/svg">
        <path d="M20 70 L100 30 L180 70 L100 110 Z" fill="#0284C7" />
        <path d="M40 85 V125 C40 145 160 145 160 125 V85" stroke="#0284C7" stroke-width="8" fill="none"/>
        <path d="M175 75 V140" stroke="#0284C7" stroke-width="5"/>
        <circle cx="175" cy="145" r="8" fill="#0284C7"/>
    </svg>

    <div class="pm-card">
        <%-- ── CỘT TRÁI: KHÓA HỌC & QR CODE ── --%>
        <div class="pm-left">
            <%-- Nút quay lại --%>
            <a href="${cp}/courses/${course.courseId}" class="pm-back-link">
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none"><path d="M19 12H5M12 19l-7-7 7-7" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"/></svg>
                <span>Quay lại khóa học</span>
            </a>

            <%-- Thông tin khóa học trên cùng --%>
            <div class="pm-course-box">
                <c:choose>
                    <c:when test="${not empty course.thumbnailUrl}">
                        <img src="${fn:startsWith(course.thumbnailUrl, 'http') or fn:startsWith(course.thumbnailUrl, cp) ? course.thumbnailUrl : cp.concat(course.thumbnailUrl)}"
                             alt="<c:out value='${course.title}'/>" class="pm-course-thumb">
                    </c:when>
                    <c:otherwise>
                        <div class="pm-course-thumb" style="display:flex;align-items:center;justify-content:center;font-size:2rem;background:#E0F2FE;">📚</div>
                    </c:otherwise>
                </c:choose>
                <div class="pm-course-info">
                    <h2 class="pm-course-title"><c:out value="${course.title}"/></h2>
                    <p class="pm-course-desc"><c:out value="${course.summary}"/></p>
                    <div class="pm-course-meta">
                        <span class="pm-star">★</span>
                        <span>
                            <c:choose>
                                <c:when test="${course.ratingCount > 0}">${course.averageRating} (${course.ratingCount} đánh giá)</c:when>
                                <c:otherwise>5.0 (Mới)</c:otherwise>
                            </c:choose>
                        </span>
                        <span>|</span>
                        <span>▶ ${not empty course.formattedDuration ? course.formattedDuration : '24 giờ học'}</span>
                    </div>
                </div>
            </div>

            <%-- Khung Quét mã QR --%>
            <div class="pm-qr-section">
                <div class="pm-qr-header">
                    <div class="pm-qr-badge">
                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none"><path d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg>
                        <span>Quét mã QR để thanh toán</span>
                    </div>
                    <p class="pm-qr-sub">Sử dụng ứng dụng ngân hàng hoặc ví điện tử để quét mã</p>
                </div>

                <div class="pm-qr-body">
                    <%-- Ảnh mã QR VietQR PRO to rõ, tích hợp sẵn toàn bộ thông tin ngân hàng và số tiền --%>
                    <div class="pm-qr-frame">
                        <img src="${vietQrUrl}" alt="Mã thanh toán QR" class="pm-qr-img" id="qrImg"
                             onerror="if(!this.dataset.fallback){this.dataset.fallback='1';this.src='https://api.qrserver.com/v1/create-qr-code/?size=380x380&data=' + encodeURIComponent('${checkoutUrl}');}">
                    </div>
                </div>
            </div>
        </div>

        <%-- ── CỘT PHẢI: THÔNG TIN ĐƠN HÀNG ── --%>
        <div class="pm-right">
            <%-- Header đơn hàng --%>
            <div class="pm-order-head">
                <div class="pm-cart-badge">
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none"><path d="M3 3h2l.4 2M7 13h10l4-8H5.4M7 13L5.4 5M7 13l-2.293 2.293c-.63.63-.184 1.707.707 1.707H17m0 0a2 2 0 100 4 2 2 0 000-4zm-8 2a2 2 0 11-4 0 2 2 0 014 0z" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg>
                </div>
                <h3 class="pm-order-title">Thông tin đơn hàng</h3>
            </div>

            <%-- Khóa học mini --%>
            <div class="pm-mini-course">
                <c:choose>
                    <c:when test="${not empty course.thumbnailUrl}">
                        <img src="${fn:startsWith(course.thumbnailUrl, 'http') or fn:startsWith(course.thumbnailUrl, cp) ? course.thumbnailUrl : cp.concat(course.thumbnailUrl)}"
                             alt="<c:out value='${course.title}'/>" class="pm-mini-thumb">
                    </c:when>
                    <c:otherwise>
                        <div class="pm-mini-thumb" style="display:flex;align-items:center;justify-content:center;font-size:1.2rem;">📚</div>
                    </c:otherwise>
                </c:choose>
                <div class="pm-mini-info">
                    <h4 class="pm-mini-name"><c:out value="${course.title}"/></h4>
                    <p class="pm-mini-type">Khóa học trực tuyến</p>
                </div>
                <span class="pm-mini-price"><fmt:formatNumber value="${amount}" type="number"/> đ</span>
            </div>

            <%-- Chi tiết đơn hàng --%>
            <div class="pm-details-list">
                <div class="pm-detail-row">
                    <span class="pm-detail-label">Phương thức thanh toán</span>
                    <span class="pm-detail-val">Chuyển khoản qua QR</span>
                </div>
                <div class="pm-detail-row">
                    <span class="pm-detail-label">Thời gian thanh toán</span>
                    <span class="pm-detail-val pm-timer-badge">
                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none"><circle cx="12" cy="12" r="10" stroke="currentColor" stroke-width="2"/><path d="M12 6v6l4 2" stroke="currentColor" stroke-width="2" stroke-linecap="round"/></svg>
                        <span id="countdown">15:00</span>
                    </span>
                </div>

                <div class="pm-divider"></div>

                <div class="pm-detail-row">
                    <span class="pm-total-label">Tổng thanh toán</span>
                    <span class="pm-total-val"><fmt:formatNumber value="${amount}" type="number"/> đ</span>
                </div>
            </div>

            <%-- Thông báo lưu ý --%>
            <div class="pm-note-box">
                <span class="pm-note-icon">ℹ</span>
                <span>Sau khi thanh toán thành công, bạn sẽ được truy cập khóa học ngay lập tức!</span>
            </div>

            <%-- Trạng thái chờ thanh toán động --%>
            <div class="pm-status-pill">
                <div class="pm-pulse-dot"></div>
                <span>Hệ thống đang chờ giao dịch...</span>
            </div>

            <%-- LƯU Ý: Đã loại bỏ phần "Cần hỗ trợ?" ở cuối theo đúng yêu cầu của người dùng --%>
        </div>
    </div>
</main>

<div class="pm-toast" id="toast">Đã sao chép vào bộ nhớ tạm!</div>

<script>
// 1. Sao chép nhanh văn bản
function copyText(text) {
    if (!text) return;
    navigator.clipboard.writeText(text).then(function() {
        showToast("Đã sao chép: " + text);
    }).catch(function() {
        showToast("Đã sao chép!");
    });
}

function showToast(msg) {
    var toast = document.getElementById('toast');
    toast.innerText = msg;
    toast.style.display = 'block';
    setTimeout(function() {
        toast.style.display = 'none';
    }, 2200);
}

// 2. Bộ đếm ngược 15 phút
(function initTimer() {
    var totalSeconds = 15 * 60;
    var timerEl = document.getElementById('countdown');
    var timer = setInterval(function() {
        totalSeconds--;
        if (totalSeconds <= 0) {
            clearInterval(timer);
            timerEl.innerText = "00:00 (Hết hạn)";
            return;
        }
        var m = Math.floor(totalSeconds / 60);
        var s = totalSeconds % 60;
        timerEl.innerText = (m < 10 ? '0' + m : m) + ':' + (s < 10 ? '0' + s : s);
    }, 1000);
})();

// 3. Polling kiểm tra trạng thái thanh toán tự động mỗi 3 giây
(function pollPaymentStatus() {
    var orderCode = '${orderCode}';
    if (!orderCode) return;

    var interval = setInterval(function() {
        fetch('${cp}/payments/status?orderCode=' + orderCode)
            .then(function(res) { return res.json(); })
            .then(function(data) {
                if (data && (data.status === 'PAID' || data.status === 'COMPLETED' || data.status === 'SUCCEEDED')) {
                    clearInterval(interval);
                    showToast("🎉 Thanh toán thành công! Đang chuyển hướng...");
                    setTimeout(function() {
                        window.location.href = '${cp}/payments/result?orderCode=' + orderCode;
                    }, 1200);
                }
            })
            .catch(function(err) {
                console.log("Checking payment status...", err);
            });
    }, 3000);
})();
</script>

</body>
</html>

