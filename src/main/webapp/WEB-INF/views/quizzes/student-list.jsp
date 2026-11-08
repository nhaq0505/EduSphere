<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Danh sách bài kiểm tra — EduSphere</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/home.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/quiz.css?v=2.0">
</head>
<body>
<jsp:include page="/WEB-INF/views/common/navbar.jsp"/>

<div class="quiz-page-wrap">
    <main class="quiz-shell">
        <a class="quiz-back-link" href="${pageContext.request.contextPath}/courses/${courseId}/learn">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><path d="M19 12H5M12 19l-7-7 7-7"/></svg>
            Quay lại bài học
        </a>

        <!-- Page Header -->
        <div style="margin-bottom:28px;">
            <p style="font-size:.82rem; font-weight:800; color:#1B9AF5; text-transform:uppercase; letter-spacing:.08em; margin-bottom:6px;">
                KHÔNG GIAN HỌC VIÊN
            </p>
            <h1 style="font-size:1.85rem; font-weight:800; color:#0F172A; margin:0;">
                Danh sách bài kiểm tra & đánh giá
            </h1>
            <p style="font-size:.95rem; color:#64748B; margin-top:6px;">
                Các bài kiểm tra trắc nghiệm và tự luận giúp củng cố kiến thức đã học trong khóa học.
            </p>
        </div>

        <c:choose>
            <c:when test="${empty quizzes}">
                <div class="quiz-card" style="text-align:center; padding:48px 20px;">
                    <div style="font-size:3rem; margin-bottom:12px;">📚</div>
                    <h3 style="font-size:1.2rem; font-weight:700; color:#0F172A; margin-bottom:8px;">Chưa có bài kiểm tra</h3>
                    <p style="color:#64748B; font-size:.92rem; max-width:460px; margin:0 auto 20px;">
                        Giảng viên chưa công bố bài kiểm tra nào cho khóa học này. Vui lòng quay lại sau!
                    </p>
                    <a class="quiz-btn quiz-btn--primary" href="${pageContext.request.contextPath}/courses/${courseId}/learn">
                        Tiếp tục học bài giảng
                    </a>
                </div>
            </c:when>

            <c:otherwise>
                <div style="display:grid; grid-template-columns:repeat(auto-fill, minmax(340px, 1fr)); gap:20px;">
                    <c:forEach var="q" items="${quizzes}">
                        <div class="quiz-card" style="display:flex; flex-direction:column; justify-content:space-between; margin-bottom:0; transition:all .2s ease;">
                            <div>
                                <div style="display:flex; align-items:center; justify-content:space-between; margin-bottom:12px;">
                                    <span class="quiz-badge quiz-badge--submitted">📝 Bài kiểm tra</span>
                                    <c:if test="${q.timeLimitMinutes != null}">
                                        <span style="font-size:.8rem; font-weight:600; color:#64748B;">⏱ ${q.timeLimitMinutes} phút</span>
                                    </c:if>
                                </div>

                                <h3 style="font-size:1.15rem; font-weight:800; color:#0F172A; margin:0 0 10px; line-height:1.4;">
                                    <a href="${pageContext.request.contextPath}/courses/${courseId}/quizzes/${q.quizId}" style="color:#0F172A; text-decoration:none;">
                                        <c:out value="${q.title}"/>
                                    </a>
                                </h3>

                                <div style="display:flex; flex-wrap:wrap; gap:10px; font-size:.84rem; color:#64748B; margin-bottom:18px;">
                                    <span>🔢 <strong>${q.questionCount}</strong> câu hỏi</span>
                                    <span>·</span>
                                    <span>🎯 Tối đa <strong><fmt:formatNumber value="${q.maxScore}" maxFractionDigits="1"/></strong> điểm</span>
                                    <span>·</span>
                                    <span>🔄 <strong>${q.maxAttempts}</strong> lần làm</span>
                                </div>
                            </div>

                            <div style="padding-top:14px; border-top:1px solid #F1F5F9;">
                                <a class="quiz-btn quiz-btn--primary" style="width:100%;"
                                   href="${pageContext.request.contextPath}/courses/${courseId}/quizzes/${q.quizId}">
                                    Vào xem & làm bài →
                                </a>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </c:otherwise>
        </c:choose>
    </main>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</body>
</html>
