<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>403 — Không có quyền truy cập</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/main.css?v=restore-0bfd0e1-20261014">
</head>
<body>
<div class="page-container" style="text-align:center; padding-top:80px;">
    <h1 style="font-size:5rem; color:#e25c4a; margin:0;">403</h1>
    <h2>Không có quyền truy cập</h2>
    <p><c:out value="${errorMessage != null ? errorMessage : 'Bạn không có quyền xem trang này.'}"/></p>
    <div style="margin-top:20px; display:flex; gap:10px; justify-content:center;">
        <a href="${pageContext.request.contextPath}/courses" class="btn btn-primary" style="background:#2563eb; color:#fff; padding:10px 20px; border-radius:6px; text-decoration:none;">Xem danh sách khóa học</a>
        <a href="${pageContext.request.contextPath}/login" class="btn btn-secondary" style="background:#f1f5f9; color:#334155; padding:10px 20px; border-radius:6px; text-decoration:none;">Đăng nhập</a>
    </div>
</div>
</body>
</html>
