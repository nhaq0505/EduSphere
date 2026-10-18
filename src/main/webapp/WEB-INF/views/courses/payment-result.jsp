<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Kết quả thanh toán — EduSphere</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app.css">
</head>
<body>
<jsp:include page="/WEB-INF/views/common/navbar.jsp"/>
<main class="shell">
    <section class="card" style="max-width:640px;margin:48px auto;padding:32px">
        <h1>Kết quả thanh toán</h1>
        <c:choose>
            <c:when test="${paymentStatus == 'SUCCEEDED'}">
                <p>Thanh toán thành công. Bạn đã được ghi danh khóa học.</p>
                <a class="button button--primary" href="${pageContext.request.contextPath}/courses/${courseId}/learn">Vào học</a>
            </c:when>
            <c:when test="${paymentStatus == 'CANCELLED'}">
                <p>Giao dịch đã được hủy. Bạn chưa được ghi danh.</p>
                <a class="button button--primary" href="${pageContext.request.contextPath}/courses/${courseId}">Quay lại khóa học</a>
            </c:when>
            <c:when test="${paymentStatus == 'FAILED'}">
                <p>Giao dịch chưa thành công. Bạn có thể thử thanh toán lại.</p>
                <a class="button button--primary" href="${pageContext.request.contextPath}/courses/${courseId}">Thử lại</a>
            </c:when>
            <c:otherwise>
                <p>PayOS chưa xác nhận thanh toán. Vui lòng kiểm tra lại sau ít phút.</p>
                <a class="button button--primary" href="${pageContext.request.contextPath}/payments/result?orderCode=${orderCode}">Kiểm tra lại</a>
            </c:otherwise>
        </c:choose>
    </section>
</main>
<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</body>
</html>
