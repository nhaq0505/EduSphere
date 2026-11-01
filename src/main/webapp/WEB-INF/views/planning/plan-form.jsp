<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${isEdit ? 'Chỉnh sửa' : 'Tạo mới'} Kế hoạch học tập — EduSphere</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/home.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/planning.css">
</head>
<body>

<!-- ══════ NAVBAR ══════ -->
<header class="hn-header">
    <div class="hn-header__inner">
        <a class="hn-logo" href="${pageContext.request.contextPath}/">
            <div class="hn-logo__icon">🎓</div>
            <span>EduSphere</span>
        </a>
        <nav class="hn-nav">
            <a class="hn-nav__link" href="${pageContext.request.contextPath}/">Trang chủ</a>
            <a class="hn-nav__link" href="${pageContext.request.contextPath}/courses">Khóa học</a>
            <a class="hn-nav__link" href="${pageContext.request.contextPath}/my-courses">Khóa học của tôi</a>
            <a class="hn-nav__link hn-nav__link--active" href="${pageContext.request.contextPath}/study/plans">Kế hoạch học tập</a>
        </nav>
    </div>
</header>

<main style="max-width: 800px; margin: 40px auto; padding: 0 20px; min-height: 70vh;">

    <div style="margin-bottom: 24px;">
        <a href="${pageContext.request.contextPath}/study/plans" style="color: #64748b; text-decoration: none; font-size: 0.9rem; font-weight: 500;">
            &larr; Quay lại danh sách kế hoạch
        </a>
        <h1 style="font-size: 1.6rem; font-weight: 800; color: #0f172a; margin-top: 8px;">
            ${isEdit ? 'Chỉnh sửa kế hoạch học tập' : 'Tạo kế hoạch học tập mới'}
        </h1>
        <p style="color: #64748b; font-size: 0.9rem;">
            Xác định khoảng thời gian và mục tiêu để xây dựng thói quen học tập kỷ luật (UC34).
        </p>
    </div>

    <c:if test="${not empty error}">
        <div class="alert alert-danger">${error}</div>
    </c:if>

    <div class="form-card">
        <form method="post" action="${pageContext.request.contextPath}/study/plans${isEdit ? '/'.concat(planId).concat('/edit') : ''}">
            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">

            <div class="form-group">
                <label for="title">Tiêu đề kế hoạch *</label>
                <input class="form-control" type="text" id="title" name="title"
                       value="${planForm.title}" required placeholder="VD: Kế hoạch ôn thi Java & SQL tháng 11" maxlength="255">
                <span class="form-hint">Đặt tên rõ ràng theo giai đoạn hoặc mục tiêu khóa học.</span>
            </div>

            <div class="form-group">
                <label for="description">Mục tiêu & Ghi chú</label>
                <textarea class="form-control" id="description" name="description" rows="3"
                          placeholder="VD: Hoàn thành 2 bài học mỗi ngày, nộp tất cả bài tập đúng hạn...">${planForm.description}</textarea>
            </div>

            <div class="form-row">
                <div class="form-group">
                    <label for="startDate">Ngày bắt đầu *</label>
                    <input class="form-control" type="date" id="startDate" name="startDate"
                           value="${planForm.startDate}" required>
                </div>
                <div class="form-group">
                    <label for="endDate">Ngày kết thúc *</label>
                    <input class="form-control" type="date" id="endDate" name="endDate"
                           value="${planForm.endDate}" required>
                </div>
            </div>

            <c:if test="${isEdit}">
                <div class="form-group">
                    <label for="status">Trạng thái kế hoạch</label>
                    <select class="form-control" id="status" name="status">
                        <option value="ACTIVE" ${planForm.status == 'ACTIVE' ? 'selected' : ''}>ACTIVE (Đang thực hiện)</option>
                        <option value="COMPLETED" ${planForm.status == 'COMPLETED' ? 'selected' : ''}>COMPLETED (Đã hoàn thành)</option>
                        <option value="CANCELLED" ${planForm.status == 'CANCELLED' ? 'selected' : ''}>CANCELLED (Đã hủy)</option>
                    </select>
                </div>
            </c:if>

            <div class="form-actions">
                <a class="btn-secondary" href="${pageContext.request.contextPath}/study/plans">Hủy bỏ</a>
                <button class="btn-primary" type="submit">
                    ${isEdit ? 'Lưu thay đổi' : 'Tạo kế hoạch'}
                </button>
            </div>
        </form>
    </div>

</main>
</body>
</html>

