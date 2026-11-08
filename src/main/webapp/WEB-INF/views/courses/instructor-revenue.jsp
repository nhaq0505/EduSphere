<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"   uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<c:set var="cp" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Doanh thu &amp; Ví Giảng viên — EduSphere</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${cp}/assets/css/instructor.css">
    <style>
        .rev-stats-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 16px;
            margin-bottom: 24px;
        }
        @media (max-width: 1100px) {
            .rev-stats-grid { grid-template-columns: repeat(2, 1fr); }
        }
        .rev-card-stat {
            background: #fff;
            border: 1px solid #E2E8F0;
            border-radius: 14px;
            padding: 18px 20px;
            box-shadow: 0 1px 3px rgba(15,23,42,.04);
        }
        .rev-card-stat--highlight {
            background: linear-gradient(135deg, #059669 0%, #047857 100%);
            color: #fff;
            border: none;
        }
        .rev-card-stat__label {
            font-size: .8rem;
            font-weight: 600;
            color: #64748B;
            margin-bottom: 6px;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }
        .rev-card-stat--highlight .rev-card-stat__label { color: rgba(255,255,255,.85); }
        .rev-card-stat__val {
            font-size: 1.45rem;
            font-weight: 800;
            color: #0F172A;
            letter-spacing: -.02em;
        }
        .rev-card-stat--highlight .rev-card-stat__val { color: #fff; }
        .rev-card-stat__sub {
            font-size: .75rem;
            color: #64748B;
            margin-top: 6px;
        }
        .rev-card-stat--highlight .rev-card-stat__sub { color: rgba(255,255,255,.85); }
        .rev-table {
            width: 100%;
            border-collapse: collapse;
            font-size: .85rem;
        }
        .rev-table th {
            text-align: left;
            padding: 11px 14px;
            background: #F8FAFC;
            color: #475569;
            font-weight: 700;
            font-size: .76rem;
            text-transform: uppercase;
            letter-spacing: .03em;
            border-bottom: 1px solid #E2E8F0;
        }
        .rev-table td {
            padding: 12px 14px;
            border-bottom: 1px solid #F1F5F9;
            color: #1E293B;
            vertical-align: middle;
        }
        .rev-table tr:hover td { background: #F8FAFC; }
        .rev-form-group { margin-bottom: 14px; }
        .rev-form-group label {
            display: block;
            font-size: .8rem;
            font-weight: 600;
            color: #334155;
            margin-bottom: 5px;
        }
        .rev-input {
            width: 100%;
            padding: 9px 12px;
            border: 1px solid #CBD5E1;
            border-radius: 8px;
            font-size: .86rem;
            font-family: inherit;
            box-sizing: border-box;
        }
        .rev-input:focus {
            outline: none;
            border-color: #2563EB;
            box-shadow: 0 0 0 3px rgba(37,99,235,.12);
        }
        .rev-pill {
            display: inline-flex;
            align-items: center;
            padding: 3px 9px;
            border-radius: 999px;
            font-size: .73rem;
            font-weight: 700;
        }
        .rev-pill--ok { background: #DCFCE7; color: #15803D; }
        .rev-pill--pending { background: #FEF3C7; color: #B45309; }
        .rev-pill--rejected { background: #FEE2E2; color: #B91C1C; }
    </style>
</head>
<body>
<div class="ins-layout">

    <jsp:include page="/WEB-INF/views/courses/ins-sidebar.jsp"/>

    <div class="ins-main-wrapper">
        <jsp:include page="/WEB-INF/views/courses/ins-header.jsp"/>

        <main class="ins-page">

            <c:if test="${not empty success}">
                <div class="ins-alert ins-alert--success" style="margin-bottom:16px;">
                    ✅ <c:out value="${success}"/>
                </div>
            </c:if>
            <c:if test="${not empty error}">
                <div class="ins-alert" style="margin-bottom:16px; background:#FEF2F2; color:#B91C1C; border:1px solid #FECACA; padding:12px 16px; border-radius:10px; font-weight:600;">
                    ⚠️ <c:out value="${error}"/>
                </div>
            </c:if>

            <%-- Page Header --%>
            <div style="display:flex; justify-content:space-between; align-items:flex-end; margin-bottom:20px; flex-wrap:wrap; gap:12px;">
                <div>
                    <h1 style="font-size:1.45rem; font-weight:800; color:#0F172A; margin:0 0 4px 0;">
                        💰 Quản lý Doanh thu &amp; Ví Giảng viên
                    </h1>
                    <p style="font-size:.86rem; color:#64748B; margin:0;">
                        Chính sách chia sẻ doanh thu: Giảng viên nhận <strong>${revenue.instructorSharePercent}%</strong> · Phí vận hành nền tảng EduSphere <strong>${revenue.platformFeePercent}%</strong>.
                    </p>
                </div>
            </div>

            <%-- 1. 4 Thẻ thống kê tài chính --%>
            <div class="rev-stats-grid">
                <div class="rev-card-stat">
                    <div class="rev-card-stat__label">
                        <span>Tổng doanh thu gộp (100%)</span>
                        <span>📊</span>
                    </div>
                    <div class="rev-card-stat__val">
                        <fmt:formatNumber value="${revenue.grossRevenue}" type="number" maxFractionDigits="0"/>đ
                    </div>
                    <div class="rev-card-stat__sub">
                        Từ <strong>${revenue.paidOrdersCount}</strong> đơn hàng thanh toán thành công
                    </div>
                </div>

                <div class="rev-card-stat">
                    <div class="rev-card-stat__label">
                        <span>Phí nền tảng (${revenue.platformFeePercent}%)</span>
                        <span>🏛️</span>
                    </div>
                    <div class="rev-card-stat__val" style="color:#64748B;">
                        -<fmt:formatNumber value="${revenue.platformFee}" type="number" maxFractionDigits="0"/>đ
                    </div>
                    <div class="rev-card-stat__sub">
                        Phí cổng thanh toán, lưu trữ &amp; vận hành hệ thống
                    </div>
                </div>

                <div class="rev-card-stat">
                    <div class="rev-card-stat__label">
                        <span>Thực nhận của bạn (${revenue.instructorSharePercent}%)</span>
                        <span>💎</span>
                    </div>
                    <div class="rev-card-stat__val" style="color:#0284C7;">
                        <fmt:formatNumber value="${revenue.netEarnings}" type="number" maxFractionDigits="0"/>đ
                    </div>
                    <div class="rev-card-stat__sub">
                        Đã rút: <strong><fmt:formatNumber value="${revenue.withdrawnAmount}" type="number" maxFractionDigits="0"/>đ</strong>
                        · Chờ duyệt: <strong><fmt:formatNumber value="${revenue.pendingPayoutAmount}" type="number" maxFractionDigits="0"/>đ</strong>
                    </div>
                </div>

                <div class="rev-card-stat rev-card-stat--highlight">
                    <div class="rev-card-stat__label">
                        <span>Số dư khả dụng (Có thể rút)</span>
                        <span>💳</span>
                    </div>
                    <div class="rev-card-stat__val">
                        <fmt:formatNumber value="${revenue.availableBalance}" type="number" maxFractionDigits="0"/>đ
                    </div>
                    <div class="rev-card-stat__sub">
                        Sẵn sàng rút về tài khoản ngân hàng của bạn
                    </div>
                </div>
            </div>

            <%-- 2. Main Grid --%>
            <div class="ins-dashboard-grid">

                <%-- Cột trái: Doanh thu theo khóa học & Lịch sử đơn hàng --%>
                <div class="ins-dashboard-main">

                    <%-- Bảng 1: Doanh thu theo từng khóa học --%>
                    <div class="ins-card" style="margin-bottom:20px;">
                        <div class="ins-card__head">
                            <div class="ins-card__title">
                                <span class="ins-card__title-icon">📚</span>
                                Doanh thu theo từng khóa học
                            </div>
                        </div>
                        <div class="ins-card__body" style="padding:0; overflow-x:auto;">
                            <table class="rev-table">
                                <thead>
                                <tr>
                                    <th>Khóa học</th>
                                    <th>Giá bán</th>
                                    <th>Lượt mua</th>
                                    <th>Doanh thu gộp (100%)</th>
                                    <th>Phí sàn (${revenue.platformFeePercent}%)</th>
                                    <th>Thực nhận (${revenue.instructorSharePercent}%)</th>
                                </tr>
                                </thead>
                                <tbody>
                                <c:choose>
                                    <c:when test="${empty revenue.courseRevenues}">
                                        <tr>
                                            <td colspan="6" style="text-align:center; padding:24px; color:#64748B;">
                                                Bạn chưa có khóa học nào.
                                            </td>
                                        </tr>
                                    </c:when>
                                    <c:otherwise>
                                        <c:forEach var="cr" items="${revenue.courseRevenues}">
                                            <tr>
                                                <td>
                                                    <a href="${cp}/instructor/courses/${cr.courseId}" style="font-weight:700; color:#1E293B; text-decoration:none;">
                                                        <c:out value="${cr.courseTitle}"/>
                                                    </a>
                                                </td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${cr.coursePrice == 0}">
                                                            <span style="color:#64748B;">Miễn phí</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <fmt:formatNumber value="${cr.coursePrice}" type="number" maxFractionDigits="0"/>đ
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td><strong>${cr.soldCount}</strong> học viên</td>
                                                <td><fmt:formatNumber value="${cr.grossAmount}" type="number" maxFractionDigits="0"/>đ</td>
                                                <td style="color:#64748B;">-<fmt:formatNumber value="${cr.platformFee}" type="number" maxFractionDigits="0"/>đ</td>
                                                <td style="font-weight:700; color:#15803D;">
                                                    +<fmt:formatNumber value="${cr.netAmount}" type="number" maxFractionDigits="0"/>đ
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </c:otherwise>
                                </c:choose>
                                </tbody>
                            </table>
                        </div>
                    </div>

                    <%-- Bảng 2: Lịch sử đơn hàng học viên đã mua --%>
                    <div class="ins-card">
                        <div class="ins-card__head" style="flex-wrap:wrap; gap:10px;">
                            <div class="ins-card__title">
                                <span class="ins-card__title-icon">🧾</span>
                                Chi tiết giao dịch bán khóa học
                            </div>
                            <form method="get" action="${cp}/instructor/revenue" style="display:flex; gap:8px; align-items:center;">
                                <select name="courseId" class="rev-input" style="width:auto; padding:6px 10px; font-size:.8rem;" onchange="this.form.submit()">
                                    <option value="">— Tất cả khóa học —</option>
                                    <c:forEach var="cr" items="${revenue.courseRevenues}">
                                        <option value="${cr.courseId}" ${revenue.filterCourseId == cr.courseId ? 'selected' : ''}>
                                            <c:out value="${cr.courseTitle}"/>
                                        </option>
                                    </c:forEach>
                                </select>
                            </form>
                        </div>
                        <div class="ins-card__body" style="padding:0; overflow-x:auto;">
                            <table class="rev-table">
                                <thead>
                                <tr>
                                    <th>Mã đơn</th>
                                    <th>Học viên</th>
                                    <th>Khóa học</th>
                                    <th>Thanh toán</th>
                                    <th>Thực nhận (${revenue.instructorSharePercent}%)</th>
                                    <th>Thời gian</th>
                                    <th>Trạng thái</th>
                                </tr>
                                </thead>
                                <tbody>
                                <c:choose>
                                    <c:when test="${empty revenue.transactions}">
                                        <tr>
                                            <td colspan="7" style="text-align:center; padding:24px; color:#64748B;">
                                                Chưa có giao dịch thanh toán nào.
                                            </td>
                                        </tr>
                                    </c:when>
                                    <c:otherwise>
                                        <c:forEach var="tx" items="${revenue.transactions}">
                                            <tr>
                                                <td style="font-family:monospace; font-size:.78rem; color:#475569;">
                                                    #<c:out value="${tx.paymentId}"/>
                                                </td>
                                                <td>
                                                    <div style="font-weight:600;"><c:out value="${tx.studentName}"/></div>
                                                    <div style="font-size:.75rem; color:#64748B;"><c:out value="${tx.studentEmail}"/></div>
                                                </td>
                                                <td><c:out value="${tx.courseTitle}"/></td>
                                                <td><fmt:formatNumber value="${tx.grossAmount}" type="number" maxFractionDigits="0"/>đ</td>
                                                <td style="font-weight:700; color:${tx.status == 'SUCCEEDED' ? '#15803D' : '#64748B'};">
                                                    <c:choose>
                                                        <c:when test="${tx.status == 'SUCCEEDED'}">
                                                            +<fmt:formatNumber value="${tx.netAmount}" type="number" maxFractionDigits="0"/>đ
                                                        </c:when>
                                                        <c:otherwise>0đ</c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td style="font-size:.78rem; color:#64748B;"><c:out value="${tx.transactionDate}"/></td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${tx.status == 'SUCCEEDED'}">
                                                            <span class="rev-pill rev-pill--ok">Thành công</span>
                                                        </c:when>
                                                        <c:when test="${tx.status == 'INITIATED'}">
                                                            <span class="rev-pill rev-pill--pending">Chờ thanh toán</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="rev-pill rev-pill--rejected"><c:out value="${tx.status}"/></span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </c:otherwise>
                                </c:choose>
                                </tbody>
                            </table>
                        </div>
                    </div>

                </div>

                <%-- Cột phải: Form Yêu cầu rút tiền & Lịch sử rút tiền --%>
                <div class="ins-dashboard-aside">

                    <div class="ins-card" style="margin-bottom:20px;">
                        <div class="ins-card__head">
                            <div class="ins-card__title">
                                <span class="ins-card__title-icon">🏦</span>
                                Yêu cầu rút tiền
                            </div>
                        </div>
                        <div class="ins-card__body">
                            <form method="post" action="${cp}/instructor/revenue/payouts">
                                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">

                                <div class="rev-form-group">
                                    <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:5px;">
                                        <label style="margin:0;">Số tiền muốn rút (VNĐ) *</label>
                                        <button type="button"
                                                onclick="document.getElementById('payoutAmountInput').value='${revenue.availableBalance.longValue()}'"
                                                style="background:none; border:none; color:#2563EB; font-size:.76rem; font-weight:700; cursor:pointer; padding:0;">
                                            Rút tối đa (<fmt:formatNumber value="${revenue.availableBalance}" type="number" maxFractionDigits="0"/>đ)
                                        </button>
                                    </div>
                                    <input type="number" id="payoutAmountInput" name="amount" class="rev-input"
                                           min="50000" max="${revenue.availableBalance.longValue() > 50000 ? revenue.availableBalance.longValue() : 500000000}"
                                           step="1000" placeholder="Tối thiểu 50,000đ" required>
                                </div>

                                <div class="rev-form-group">
                                    <label>Ngân hàng nhận tiền *</label>
                                    <select name="bankName" class="rev-input" required>
                                        <option value="Vietcombank (VCB)">Vietcombank (VCB)</option>
                                        <option value="MB Bank (Quân Đội)">MB Bank (Quân Đội)</option>
                                        <option value="Techcombank (TCB)">Techcombank (TCB)</option>
                                        <option value="BIDV">BIDV</option>
                                        <option value="VietinBank">VietinBank</option>
                                        <option value="ACB">ACB</option>
                                        <option value="TPBank">TPBank</option>
                                        <option value="VPBank">VPBank</option>
                                    </select>
                                </div>

                                <div class="rev-form-group">
                                    <label>Số tài khoản *</label>
                                    <input type="text" name="accountNumber" class="rev-input"
                                           placeholder="VD: 0123456789" required>
                                </div>

                                <div class="rev-form-group">
                                    <label>Tên chủ tài khoản (Không dấu) *</label>
                                    <input type="text" name="accountHolder" class="rev-input"
                                           placeholder="VD: NGUYEN VAN A" style="text-transform:uppercase;" required>
                                </div>

                                <div class="rev-form-group">
                                    <label>Ghi chú (Tùy chọn)</label>
                                    <input type="text" name="instructorNote" class="rev-input"
                                           placeholder="Nội dung ghi chú cho Admin...">
                                </div>

                                <button type="submit" class="ins-btn ins-btn--primary" style="width:100%; justify-content:center; padding:10px 16px;"
                                        ${revenue.availableBalance < 50000 ? 'disabled title="Số dư khả dụng cần tối thiểu 50,000đ"' : ''}>
                                    💸 Gửi yêu cầu rút tiền
                                </button>
                            </form>
                        </div>
                    </div>

                    <%-- Lịch sử yêu cầu rút tiền --%>
                    <div class="ins-card">
                        <div class="ins-card__head">
                            <div class="ins-card__title">
                                <span class="ins-card__title-icon">📋</span>
                                Lịch sử rút tiền
                            </div>
                        </div>
                        <div class="ins-card__body" style="padding-top:8px;">
                            <c:choose>
                                <c:when test="${empty revenue.payoutRequests}">
                                    <div style="text-align:center; padding:18px 10px; color:#64748B; font-size:.83rem;">
                                        Bạn chưa gửi yêu cầu rút tiền nào.
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <c:forEach var="pr" items="${revenue.payoutRequests}">
                                        <div style="padding:12px 0; border-bottom:1px solid #F1F5F9;">
                                            <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:4px;">
                                                <strong style="font-size:.95rem; color:#0F172A;">
                                                    <fmt:formatNumber value="${pr.amount}" type="number" maxFractionDigits="0"/>đ
                                                </strong>
                                                <c:choose>
                                                    <c:when test="${pr.status == 'APPROVED'}">
                                                        <span class="rev-pill rev-pill--ok">✅ Đã chuyển khoản</span>
                                                    </c:when>
                                                    <c:when test="${pr.status == 'PENDING'}">
                                                        <span class="rev-pill rev-pill--pending">⏳ Chờ duyệt</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="rev-pill rev-pill--rejected">❌ Từ chối</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>
                                            <div style="font-size:.78rem; color:#475569;">
                                                🏦 <c:out value="${pr.bankName}"/> · STK: <strong><c:out value="${pr.accountNumber}"/></strong> (<c:out value="${pr.accountHolder}"/>)
                                            </div>
                                            <div style="font-size:.73rem; color:#94A3B8; margin-top:3px;">
                                                Yêu cầu lúc: <c:out value="${pr.requestedAt}"/>
                                                <c:if test="${not empty pr.processedAt}">
                                                    · Xử lý: <c:out value="${pr.processedAt}"/>
                                                </c:if>
                                            </div>
                                            <c:if test="${not empty pr.adminNote}">
                                                <div style="margin-top:6px; padding:6px 10px; background:#F8FAFC; border-left:3px solid ${pr.status == 'REJECTED' ? '#EF4444' : '#10B981'}; font-size:.76rem; color:#334155; border-radius:4px;">
                                                    <strong>Phản hồi Admin:</strong> <c:out value="${pr.adminNote}"/>
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

        </main>
    </div>
</div>

<script>
function insToggleMenu(e) {
    e.stopPropagation();
    document.getElementById('insUserMenu').classList.toggle('open');
}
document.addEventListener('click', function() {
    var m = document.getElementById('insUserMenu');
    if (m) m.classList.remove('open');
});
</script>
</body>
</html>
