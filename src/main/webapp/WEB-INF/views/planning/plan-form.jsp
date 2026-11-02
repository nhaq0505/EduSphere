<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html><html lang="vi"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1.0">
    <title>${isEdit ? 'Sửa' : 'Tạo'} kế hoạch — EduSphere</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/home.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/planning-new.css">
</head><body>
<jsp:include page="/WEB-INF/views/planning/planning-navbar.jsp"/>
<div class="pl-shell" style="max-width:760px;">
    <a href="${pageContext.request.contextPath}/study/plans" style="color:#64748b;text-decoration:none;font-size:.87rem;font-weight:600;display:inline-flex;align-items:center;gap:5px;margin-bottom:20px;">← Danh sách kế hoạch</a>
    <div style="margin-bottom:28px;">
        <h1 style="font-size:1.6rem;font-weight:800;color:#0f172a;margin:0 0 5px;">${isEdit ? 'Chỉnh sửa kế hoạch học tập' : 'Tạo kế hoạch học tập mới'}</h1>
        <p style="color:#64748b;font-size:.87rem;margin:0;">Xác định khoảng thời gian và mục tiêu để xây dựng thói quen học tập (UC34).</p>
    </div>
    <c:if test="${not empty error}"><div class="pl-alert pl-alert--danger">⚠️ <c:out value="${error}"/></div></c:if>
    <div class="pl-form-card">
        <form method="post" action="${pageContext.request.contextPath}/study/plans${isEdit ? '/' : ''}${isEdit ? planId : ''}${isEdit ? '/edit' : ''}">
            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
            <div class="pl-field">
                <label class="pl-label" for="title">Tiêu đề kế hoạch <span style="color:#ef4444">*</span></label>
                <input class="pl-input" type="text" id="title" name="title" value="<c:out value='${planForm.title}'/>" required maxlength="255" placeholder="VD: Ôn thi Java & SQL tháng 11">
                <div class="pl-hint">Đặt tên rõ theo giai đoạn hoặc mục tiêu cụ thể.</div>
            </div>
            <div class="pl-field">
                <label class="pl-label" for="description">Mục tiêu & Ghi chú</label>
                <textarea class="pl-input" id="description" name="description" rows="3" placeholder="VD: Hoàn thành 2 bài học mỗi ngày, nộp bài tập đúng hạn..."><c:out value="${planForm.description}"/></textarea>
            </div>
            <div class="pl-grid-2">
                <div class="pl-field">
                    <label class="pl-label" for="startDate">Ngày bắt đầu <span style="color:#ef4444">*</span></label>
                    <input class="pl-input" type="date" id="startDate" name="startDate" value="<c:out value='${planForm.startDate}'/>" required>
                </div>
                <div class="pl-field">
                    <label class="pl-label" for="endDate">Ngày kết thúc <span style="color:#ef4444">*</span></label>
                    <input class="pl-input" type="date" id="endDate" name="endDate" value="<c:out value='${planForm.endDate}'/>" required>
                </div>
            </div>
            <c:if test="${isEdit}">
                <div class="pl-field">
                    <label class="pl-label" for="status">Trạng thái</label>
                    <select class="pl-input" id="status" name="status">
                        <option value="ACTIVE" ${planForm.status == 'ACTIVE' ? 'selected' : ''}>🟢 ACTIVE — Đang thực hiện</option>
                        <option value="COMPLETED" ${planForm.status == 'COMPLETED' ? 'selected' : ''}>✅ COMPLETED — Hoàn thành</option>
                        <option value="CANCELLED" ${planForm.status == 'CANCELLED' ? 'selected' : ''}>❌ CANCELLED — Đã hủy</option>
                    </select>
                </div>
            </c:if>
            <div class="pl-form-actions">
                <a class="pl-btn pl-btn--outline" href="${pageContext.request.contextPath}/study/plans">Hủy</a>
                <button class="pl-btn pl-btn--primary" type="submit">${isEdit ? '💾 Lưu thay đổi' : '➕ Tạo kế hoạch'}</button>
            </div>
        </form>
    </div>
</div>
<jsp:include page="/WEB-INF/views/planning/planning-footer.jsp"/>
</body></html>