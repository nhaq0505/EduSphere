<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Lịch sử hoạt động học tập — EduSphere</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/home.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app.css?v=planning">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/planning.css">
</head>
<body>

<jsp:include page="/WEB-INF/views/common/navbar.jsp"/>

<main style="max-width: 900px; margin: 32px auto; padding: 0 20px; min-height: 70vh;">

    <!-- Subnav Tabs -->
    <nav class="plan-tabs">
        <a class="plan-tab" href="${pageContext.request.contextPath}/study/plans">
            📋 Kế hoạch
        </a>
        <a class="plan-tab" href="${pageContext.request.contextPath}/study/calendar">
            📅 Lịch học (Calendar)
        </a>
        <a class="plan-tab" href="${pageContext.request.contextPath}/study/progress">
            📈 Tiến độ khóa học
        </a>
        <a class="plan-tab plan-tab--active" href="${pageContext.request.contextPath}/study/history">
            ⏱️ Lịch sử hoạt động
        </a>
    </nav>

    <!-- Header -->
    <div class="plan-header">
        <div>
            <h1 class="plan-header__title">Lịch sử hoạt động học tập (Learning History)</h1>
            <p class="plan-header__subtitle">Ghi nhận các sự kiện: hoàn thành bài học, nộp bài tập, làm quiz và ghi danh (UC38)</p>
        </div>
    </div>

    <!-- History Timeline Feed -->
    <c:choose>
        <c:when test="${empty historyPage.content}">
            <div style="text-align: center; padding: 60px 20px; background: #fff; border: 1px dashed #cbd5e1; border-radius: 14px;">
                <div style="font-size: 3rem; margin-bottom: 16px;">⏱️</div>
                <h3 style="color: #1e293b; margin: 0 0 8px;">Chưa có hoạt động nào được ghi nhận</h3>
                <p style="color: #64748b; margin-bottom: 24px;">Khi bạn học bài, làm bài tập hoặc kiểm tra quiz, mọi hoạt động sẽ hiển thị tại đây!</p>
                <a class="btn-primary" href="${pageContext.request.contextPath}/my-courses">
                    Đến khóa học của tôi &rarr;
                </a>
            </div>
        </c:when>
        <c:otherwise>
            <div class="history-feed">
                <c:forEach items="${historyPage.content}" var="h">
                    <div class="history-item">
                        <c:choose>
                            <c:when test="${h.activityType == 'LESSON_COMPLETED'}">
                                <div class="history-icon-box history-icon--lesson">📖</div>
                            </c:when>
                            <c:when test="${h.activityType == 'ASSIGNMENT_SUBMITTED'}">
                                <div class="history-icon-box history-icon--assignment">📝</div>
                            </c:when>
                            <c:when test="${h.activityType == 'QUIZ_SUBMITTED'}">
                                <div class="history-icon-box history-icon--quiz">📊</div>
                            </c:when>
                            <c:otherwise>
                                <div class="history-icon-box history-icon--course">🎓</div>
                            </c:otherwise>
                        </c:choose>

                        <div class="history-content">
                            <span class="history-course-badge">📚 ${h.courseTitle}</span>
                            <h4 class="history-title">${h.activityLabel}</h4>
                            <p class="history-details">
                                <c:if test="${not empty h.details}">
                                    ${h.details}
                                </c:if>
                                <c:if test="${empty h.details}">
                                    <c:if test="${not empty h.lessonTitle}">Bài học: ${h.lessonTitle}</c:if>
                                    <c:if test="${not empty h.assignmentTitle}">Bài tập: ${h.assignmentTitle}</c:if>
                                    <c:if test="${not empty h.quizTitle}">Quiz: ${h.quizTitle}</c:if>
                                </c:if>
                            </p>
                        </div>

                        <div class="history-time">
                            ${h.occurredAt}
                        </div>
                    </div>
                </c:forEach>
            </div>

            <!-- Pagination -->
            <c:if test="${totalPages > 1}">
                <div class="pagination">
                    <a class="pagination-btn ${currentPage == 0 ? 'pagination-btn--disabled' : ''}"
                       href="${pageContext.request.contextPath}/study/history?page=${currentPage - 1}">
                        &larr; Trang trước
                    </a>
                    <span style="font-size: 0.88rem; color: #64748b; font-weight: 600;">
                        Trang ${currentPage + 1} / ${totalPages}
                    </span>
                    <a class="pagination-btn ${currentPage + 1 >= totalPages ? 'pagination-btn--disabled' : ''}"
                       href="${pageContext.request.contextPath}/study/history?page=${currentPage + 1}">
                        Trang sau &rarr;
                    </a>
                </div>
            </c:if>
        </c:otherwise>
    </c:choose>

</main>

<script>
function toggleUserMenu(e) {
    e.stopPropagation();
    const menu = e.currentTarget.closest('.hn-user-menu');
    menu.classList.toggle('open');
}
document.addEventListener('click', function() {
    document.querySelectorAll('.hn-user-menu.open').forEach(m => m.classList.remove('open'));
});
</script>
<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</body>
</html>

