<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<c:set var="cp" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý Doanh thu &amp; Rút tiền — EduSphere Admin</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${cp}/assets/css/home.css">
    <link rel="stylesheet" href="${cp}/assets/css/admin.css">
    <style>
        .adm-rev-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 16px;
            margin-bottom: 24px;
        }
        @media (max-width: 1100px) {
            .adm-rev-grid { grid-template-columns: repeat(2, 1fr); }
        }
        .adm-rev-card {
            background: #fff;
            border: 1px solid #E2E8F0;
            border-radius: 14px;
            padding: 18px 20px;
            box-shadow: 0 1px 3px rgba(15,23,42,.04);
        }
        .adm-rev-card--primary {
            background: linear-gradient(135deg, #1E40AF 0%, #1D4ED8 100%);
            color: #fff;
            border: none;
        }
        .adm-rev-card__label {
            font-size: .8rem;
            font-weight: 600;
            color: #64748B;
            margin-bottom: 6px;
        }
        .adm-rev-card--primary .adm-rev-card__label { color: rgba(255,255,255,.85); }
        .adm-rev-card__val {
            font-size: 1.45rem;
            font-weight: 800;
            color: #0F172A;
        }
        .adm-rev-card--primary .adm-rev-card__val { color: #fff; }
        .adm-rev-card__sub {
            font-size: .75rem;
            color: #64748B;
            margin-top: 6px;
        }
        .adm-rev-card--primary .adm-rev-card__sub { color: rgba(255,255,255,.85); }
        .adm-box {
            background: #fff;
            border: 1px solid #E2E8F0;
            border-radius: 14px;
            margin-bottom: 24px;
            overflow: hidden;
        }
        .adm-box__head {
            padding: 16px 20px;
            border-bottom: 1px solid #E2E8F0;
            font-weight: 800;
            font-size: 1rem;
            color: #0F172A;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .adm-table {
            width: 100%;
            border-collapse: collapse;
            font-size: .85rem;
        }
        .adm-table th {
            text-align: left;
            padding: 11px 16px;
            background: #F8FAFC;
            color: #475569;
            font-weight: 700;
            font-size: .75rem;
            text-transform: uppercase;
            border-bottom: 1px solid #E2E8F0;
        }
        .adm-table td {
            padding: 12px 16px;
            border-bottom: 1px solid #F1F5F9;
            vertical-align: middle;
        }
        .adm-badge {
            display: inline-flex;
            padding: 3px 9px;
            border-radius: 999px;
            font-size: .73rem;
            font-weight: 700;
        }
        .adm-badge--ok { background: #DCFCE7; color: #15803D; }
        .adm-badge--pending { background: #FEF3C7; color: #B45309; }
        .adm-badge--rejected { background: #FEE2E2; color: #B91C1C; }
    </style>
</head>
<body>

<jsp:include page="/WEB-INF/views/admin/header.jsp"/>

<div class="adm-shell">
    <jsp:include page="/WEB-INF/views/admin/sidebar.jsp"/>

    <main class="adm-content">

        <div class="adm-page-head">
            <div>
                <span class="adm-page-head__eyebrow">💰 Tài chính &amp; Đối soát</span>
                <h1 class="adm-page-head__title">Quản lý Doanh thu &amp; Duyệt Rút tiền</h1>
                <p class="adm-page-head__sub">
                    Theo dõi tổng doanh thu khóa học toàn hệ thống, phí nền tảng (${revenue.platformFeePercent}%) và phê duyệt yêu cầu rút tiền (${revenue.instructorSharePercent}%) của Giảng viên.
                </p>
            </div>
        </div>

        <c:if test="${not empty success}">
            <div class="adm-alert adm-alert--success" style="margin-bottom:16px;">✅ <c:out value="${success}"/></div>
        </c:if>
        <c:if test="${not empty error}">
            <div class="adm-alert" style="margin-bottom:16px; background:#FEF2F2; color:#B91C1C; border:1px solid #FECACA; padding:12px 16px; border-radius:10px; font-weight:600;">
                ⚠️ <c:out value="${error}"/>
            </div>
        </c:if>

        <%-- 4 Thẻ thống kê toàn sàn --%>
        <div class="adm-rev-grid">
            <div class="adm-rev-card">
                <div class="adm-rev-card__label">Tổng doanh thu toàn sàn (100%)</div>
                <div class="adm-rev-card__val">
                    <fmt:formatNumber value="${revenue.grossRevenue}" type="number" maxFractionDigits="0"/>đ
                </div>
                <div class="adm-rev-card__sub">
                    Từ <strong>${revenue.paidOrdersCount}</strong> giao dịch thành công
                </div>
            </div>

            <div class="adm-rev-card adm-rev-card--primary">
                <div class="adm-rev-card__label">Doanh thu nền tảng EduSphere (${revenue.platformFeePercent}%)</div>
                <div class="adm-rev-card__val">
                    <fmt:formatNumber value="${revenue.platformFeeEarned}" type="number" maxFractionDigits="0"/>đ
                </div>
                <div class="adm-rev-card__sub">
                    Phí dịch vụ nền tảng thu về
                </div>
            </div>

            <div class="adm-rev-card">
                <div class="adm-rev-card__label">Tổng phần chia Giảng viên (${revenue.instructorSharePercent}%)</div>
                <div class="adm-rev-card__val" style="color:#0284C7;">
                    <fmt:formatNumber value="${revenue.instructorNetTotal}" type="number" maxFractionDigits="0"/>đ
                </div>
                <div class="adm-rev-card__sub">
                    Đã chi trả: <strong><fmt:formatNumber value="${revenue.totalPaidOut}" type="number" maxFractionDigits="0"/>đ</strong>
                </div>
            </div>

            <div class="adm-rev-card">
                <div class="adm-rev-card__label">Yêu cầu rút tiền chờ duyệt</div>
                <div class="adm-rev-card__val" style="color:${revenue.pendingPayoutCount > 0 ? '#D97706' : '#16A34A'};">
                    ${revenue.pendingPayoutCount} yêu cầu
                </div>
                <div class="adm-rev-card__sub">
                    Tổng chờ chi: <strong><fmt:formatNumber value="${revenue.totalPendingPayout}" type="number" maxFractionDigits="0"/>đ</strong>
                </div>
            </div>
        </div>

        <%-- 1. Bảng Duyệt Yêu cầu Rút tiền của Giảng viên --%>
        <div class="adm-box">
            <div class="adm-box__head">
                <span>🏦 Yêu cầu rút tiền từ Giảng viên</span>
                <span style="font-size:.8rem; font-weight:600; color:#64748B;">${revenue.payoutRequests.size()} yêu cầu</span>
            </div>
            <div style="overflow-x:auto;">
                <table class="adm-table">
                    <thead>
                    <tr>
                        <th>Mã</th>
                        <th>Giảng viên</th>
                        <th>Số tiền rút</th>
                        <th>Thông tin Ngân hàng nhận</th>
                        <th>Thời gian</th>
                        <th>Trạng thái</th>
                        <th>Thao tác / Phản hồi</th>
                    </tr>
                    </thead>
                    <tbody>
                    <c:choose>
                        <c:when test="${empty revenue.payoutRequests}">
                            <tr>
                                <td colspan="7" style="text-align:center; padding:24px; color:#64748B;">
                                    Chưa có yêu cầu rút tiền nào từ giảng viên.
                                </td>
                            </tr>
                        </c:when>
                        <c:otherwise>
                            <c:forEach var="pr" items="${revenue.payoutRequests}">
                                <tr>
                                    <td style="font-family:monospace; font-weight:700;">#${pr.payoutId}</td>
                                    <td>
                                        <div style="font-weight:700; color:#0F172A;"><c:out value="${pr.instructorName}"/></div>
                                        <div style="font-size:.76rem; color:#64748B;"><c:out value="${pr.instructorEmail}"/></div>
                                    </td>
                                    <td style="font-weight:800; font-size:.95rem; color:#15803D;">
                                        <fmt:formatNumber value="${pr.amount}" type="number" maxFractionDigits="0"/>đ
                                    </td>
                                    <td>
                                        <div style="font-weight:600;"><c:out value="${pr.bankName}"/></div>
                                        <div style="font-size:.8rem; color:#334155;">
                                            STK: <strong><c:out value="${pr.accountNumber}"/></strong> · Chủ TK: <strong><c:out value="${pr.accountHolder}"/></strong>
                                        </div>
                                        <c:if test="${not empty pr.instructorNote}">
                                            <div style="font-size:.75rem; color:#64748B; margin-top:2px;">
                                                Ghi chú GV: "<c:out value="${pr.instructorNote}"/>"
                                            </div>
                                        </c:if>
                                    </td>
                                    <td style="font-size:.78rem; color:#64748B;">
                                        <div>Gửi: <c:out value="${pr.requestedAt}"/></div>
                                        <c:if test="${not empty pr.processedAt}">
                                            <div>Xử lý: <c:out value="${pr.processedAt}"/></div>
                                        </c:if>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${pr.status == 'APPROVED'}">
                                                <span class="adm-badge adm-badge--ok">✅ Đã chuyển khoản</span>
                                            </c:when>
                                            <c:when test="${pr.status == 'PENDING'}">
                                                <span class="adm-badge adm-badge--pending">⏳ Chờ duyệt</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="adm-badge adm-badge--rejected">❌ Đã từ chối</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td style="min-width:260px;">
                                        <c:choose>
                                            <c:when test="${pr.status == 'PENDING'}">
                                                <div style="display:flex; flex-direction:column; gap:6px;">
                                                    <form method="post" action="${cp}/admin/revenue/payouts/${pr.payoutId}/approve" style="display:flex; gap:6px;">
                                                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                                        <input type="text" name="adminNote" placeholder="Mã GD chuyển khoản / Ghi chú..."
                                                               style="flex:1; padding:6px 8px; border:1px solid #CBD5E1; border-radius:6px; font-size:.78rem;">
                                                        <button type="submit" style="background:#16A34A; color:#fff; border:none; border-radius:6px; padding:6px 10px; font-size:.78rem; font-weight:700; cursor:pointer; white-space:nowrap;">
                                                            ✅ Duyệt chi
                                                        </button>
                                                    </form>
                                                    <form method="post" action="${cp}/admin/revenue/payouts/${pr.payoutId}/reject" style="display:flex; gap:6px;">
                                                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                                        <input type="text" name="adminNote" placeholder="Lý do từ chối (bắt buộc)..." required
                                                               style="flex:1; padding:6px 8px; border:1px solid #FECACA; border-radius:6px; font-size:.78rem;">
                                                        <button type="submit" style="background:#DC2626; color:#fff; border:none; border-radius:6px; padding:6px 10px; font-size:.78rem; font-weight:700; cursor:pointer; white-space:nowrap;">
                                                            ❌ Từ chối
                                                        </button>
                                                    </form>
                                                </div>
                                            </c:when>
                                            <c:otherwise>
                                                <div style="font-size:.78rem; color:#475569;">
                                                    <c:if test="${not empty pr.adminNote}">
                                                        <div><strong>Ghi chú:</strong> <c:out value="${pr.adminNote}"/></div>
                                                    </c:if>
                                                    <c:if test="${not empty pr.processedByName}">
                                                        <div style="color:#94A3B8;">Bởi: <c:out value="${pr.processedByName}"/></div>
                                                    </c:if>
                                                </div>
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

        <%-- 2. Bảng Thống kê Doanh thu theo Khóa học & Giảng viên --%>
        <div class="adm-box">
            <div class="adm-box__head">
                <span>📚 Thống kê Doanh thu theo Khóa học</span>
            </div>
            <div style="overflow-x:auto;">
                <table class="adm-table">
                    <thead>
                    <tr>
                        <th>Khóa học</th>
                        <th>Giảng viên</th>
                        <th>Giá niêm yết</th>
                        <th>Số lượt bán</th>
                        <th>Tổng thu (100%)</th>
                        <th>Phí sàn (${revenue.platformFeePercent}%)</th>
                        <th>Giảng viên nhận (${revenue.instructorSharePercent}%)</th>
                    </tr>
                    </thead>
                    <tbody>
                    <c:choose>
                        <c:when test="${empty revenue.courseRevenues}">
                            <tr>
                                <td colspan="7" style="text-align:center; padding:24px; color:#64748B;">
                                    Chưa có khóa học nào phát sinh doanh thu.
                                </td>
                            </tr>
                        </c:when>
                        <c:otherwise>
                            <c:forEach var="cr" items="${revenue.courseRevenues}">
                                <tr>
                                    <td style="font-weight:700; color:#0F172A;"><c:out value="${cr.courseTitle}"/></td>
                                    <td><c:out value="${cr.instructorName}"/></td>
                                    <td><fmt:formatNumber value="${cr.coursePrice}" type="number" maxFractionDigits="0"/>đ</td>
                                    <td><strong>${cr.soldCount}</strong> đơn</td>
                                    <td style="font-weight:700;"><fmt:formatNumber value="${cr.grossAmount}" type="number" maxFractionDigits="0"/>đ</td>
                                    <td style="font-weight:700; color:#1D4ED8;">+<fmt:formatNumber value="${cr.platformFee}" type="number" maxFractionDigits="0"/>đ</td>
                                    <td style="font-weight:700; color:#15803D;"><fmt:formatNumber value="${cr.netAmount}" type="number" maxFractionDigits="0"/>đ</td>
                                </tr>
                            </c:forEach>
                        </c:otherwise>
                    </c:choose>
                    </tbody>
                </table>
            </div>
        </div>

        <%-- 3. Lịch sử Giao dịch Toàn hệ thống --%>
        <div class="adm-box">
            <div class="adm-box__head">
                <span>🧾 Lịch sử Giao dịch Thanh toán Toàn sàn</span>
            </div>
            <div style="overflow-x:auto;">
                <table class="adm-table">
                    <thead>
                    <tr>
                        <th>Mã GD</th>
                        <th>Học viên</th>
                        <th>Khóa học</th>
                        <th>Giảng viên</th>
                        <th>Số tiền</th>
                        <th>Phí sàn (20%)</th>
                        <th>GV nhận (80%)</th>
                        <th>Thời gian</th>
                        <th>Trạng thái</th>
                    </tr>
                    </thead>
                    <tbody>
                    <c:choose>
                        <c:when test="${empty revenue.transactions}">
                            <tr>
                                <td colspan="9" style="text-align:center; padding:24px; color:#64748B;">
                                    Chưa có giao dịch thanh toán nào.
                                </td>
                            </tr>
                        </c:when>
                        <c:otherwise>
                            <c:forEach var="tx" items="${revenue.transactions}">
                                <tr>
                                    <td style="font-family:monospace;">#${tx.paymentId}</td>
                                    <td>
                                        <div style="font-weight:600;"><c:out value="${tx.studentName}"/></div>
                                        <div style="font-size:.75rem; color:#64748B;"><c:out value="${tx.studentEmail}"/></div>
                                    </td>
                                    <td><c:out value="${tx.courseTitle}"/></td>
                                    <td><c:out value="${tx.instructorName}"/></td>
                                    <td><fmt:formatNumber value="${tx.grossAmount}" type="number" maxFractionDigits="0"/>đ</td>
                                    <td style="color:#1D4ED8;"><fmt:formatNumber value="${tx.platformFee}" type="number" maxFractionDigits="0"/>đ</td>
                                    <td style="color:#15803D; font-weight:700;"><fmt:formatNumber value="${tx.netAmount}" type="number" maxFractionDigits="0"/>đ</td>
                                    <td style="font-size:.78rem; color:#64748B;"><c:out value="${tx.transactionDate}"/></td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${tx.status == 'SUCCEEDED'}">
                                                <span class="adm-badge adm-badge--ok">Thành công</span>
                                            </c:when>
                                            <c:when test="${tx.status == 'INITIATED'}">
                                                <span class="adm-badge adm-badge--pending">Chờ TT</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="adm-badge adm-badge--rejected"><c:out value="${tx.status}"/></span>
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

    </main>
</div>

</body>
</html>
