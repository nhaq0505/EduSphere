<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"><title>Không thể thực hiện — EduSphere</title><link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/main.css"><link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/courses.css"></head>
<body>
<nav class="navbar"><a class="brand" href="${pageContext.request.contextPath}/">EduSphere</a><div class="nav-links"><a href="${pageContext.request.contextPath}/courses">Khóa học</a><a href="${pageContext.request.contextPath}/dashboard">Trang cá nhân</a></div></nav>
<main class="course-container"><div class="course-empty"><h1>Không thể thực hiện thao tác</h1><p><c:out value="${errorMessage}"/></p><a class="btn btn-secondary" href="${pageContext.request.contextPath}/dashboard">Về trang cá nhân</a></div></main>
</body>
</html>
