<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html><html lang="vi"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1.0">
<title>Lịch sử hoạt động — EduSphere</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/home.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/planning-new.css">
</head><body>
<jsp:include page="/WEB-INF/views/common/navbar.jsp"/>
<div class="pl-shell" style="max-width:900px;">
<nav class="pl-tabs">
    <a class="pl-tab" href="${pageContext.request.contextPath}/study/plans">📋 Kế hoạch học tập</a>
    <a class="pl-tab" href="${pageContext.request.contextPath}/study/calendar">📅 Lịch học cá nhân</a>
    <a class="pl-tab" href="${pageContext.request.contextPath}/study/progress">📈 Theo dõi tiến độ</a>
    <a class="pl-tab active" href="${pageContext.request.contextPath}/study/history">⏱️ Lịch sử hoạt động</a>
</nav>

<div class="pl-page-head">
    <div>
        <h1>Lịch sử hoạt động học tập</h1>
        <p>Ghi nhận hoàn thành bài học, nộp bài tập, làm quiz và ghi danh (UC38)</p>
    </div>
</div>

<c:choose>
    <c:when test="${empty historyPage.content}">
        <div class="pl-empty">
            <div class="pl-empty__icon">⏱️</div>
            <h3>Chưa có hoạt động nào</h3>
            <p>Khi bạn học bài, làm bài tập hay quiz, mọi hoạt động sẽ hiển thị tại đây!</p>
            <a class="pl-btn pl-btn--primary" href="${pageContext.request.contextPath}/my-courses">Đến khóa học của tôi →</a>
        </div>
    </c:when>
    <c:otherwise>
        <div class="pl-history-feed">
            <c:forEach items="${historyPage.content}" var="h">
                <div class="pl-history-item">
                    <c:choose>
                        <c:when test="${h.activityType == 'LESSON_COMPLETED'}"><div class="pl-history-icon pl-history-icon--lesson">📖</div></c:when>
                        <c:when test="${h.activityType == 'ASSIGNMENT_SUBMITTED'}"><div class="pl-history-icon pl-history-icon--assignment">📝</div></c:when>
                        <c:when test="${h.activityType == 'QUIZ_SUBMITTED'}"><div class="pl-history-icon pl-history-icon--quiz">📊</div></c:when>
                        <c:otherwise><div class="pl-history-icon pl-history-icon--course">🎓</div></c:otherwise>
                    </c:choose>
                    <div class="pl-history-body">
                        <div class="pl-history-badge">📚 <c:out value="${h.courseTitle}"/></div>
                        <div class="pl-history-title"><c:out value="${h.activityLabel}"/></div>
                        <div class="pl-history-detail">
                            <c:choose>
                                <c:when test="${not empty h.details}"><c:out value="${h.details}"/></c:when>
                                <c:otherwise>
                                    <c:if test="${not empty h.lessonTitle}">Bài học: <c:out value="${h.lessonTitle}"/></c:if>
                                    <c:if test="${not empty h.assignmentTitle}">Bài tập: <c:out value="${h.assignmentTitle}"/></c:if>
                                    <c:if test="${not empty h.quizTitle}">Quiz: <c:out value="${h.quizTitle}"/></c:if>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                    <div class="pl-history-time"><c:out value="${h.occurredAt}"/></div>
                </div>
            </c:forEach>
        </div>
        <c:if test="${totalPages > 1}">
            <div class="pl-pagination">
                <a class="pl-page-btn ${currentPage == 0 ? 'pl-page-btn--disabled' : ''}" href="${pageContext.request.contextPath}/study/history?page=${currentPage - 1}">← Trang trước</a>
                <span style="font-size:.85rem;color:#64748b;font-weight:600;">Trang ${currentPage + 1} / ${totalPages}</span>
                <a class="pl-page-btn ${currentPage + 1 >= totalPages ? 'pl-page-btn--disabled' : ''}" href="${pageContext.request.contextPath}/study/history?page=${currentPage + 1}">Trang sau →</a>
            </div>
        </c:if>
    </c:otherwise>
</c:choose>
</div>
<jsp:include page="/WEB-INF/views/planning/planning-footer.jsp"/>
</body></html>