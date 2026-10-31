<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${isEdit ? 'Sửa' : 'Thêm'} Nhiệm vụ học tập — EduSphere</title>
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
        <a href="${pageContext.request.contextPath}/study/plans/${plan.planId}" style="color: #64748b; text-decoration: none; font-size: 0.9rem; font-weight: 500;">
            &larr; Quay lại kế hoạch: <strong>${plan.title}</strong>
        </a>
        <h1 style="font-size: 1.6rem; font-weight: 800; color: #0f172a; margin-top: 8px;">
            ${isEdit ? 'Chỉnh sửa nhiệm vụ' : 'Thêm nhiệm vụ cá nhân (Schedule Task)'}
        </h1>
        <p style="color: #64748b; font-size: 0.9rem;">
            Lên lịch học bài, làm bài tập hoặc luyện quiz cho mục tiêu của bạn (UC35).
        </p>
    </div>

    <!-- Official Policy Callout -->
    <div class="callout-info">
        <div style="font-size: 1.3rem;">ℹ️</div>
        <div>
            <strong>Quy tắc quan trọng:</strong> Thời gian bạn đặt ở đây là lịch học cá nhân của riêng bạn. Việc lên lịch này <em>tuyệt đối không làm thay đổi</em> hạn nộp chính thức (Due Date), thời gian mở (Unlock) hay đóng (Lock) do Giảng viên quy định.
        </div>
    </div>

    <c:if test="${not empty error}">
        <div class="alert alert-danger">${error}</div>
    </c:if>

    <div class="form-card">
        <form method="post" action="${pageContext.request.contextPath}/study/plans/${plan.planId}/tasks/${isEdit ? taskId.concat('/edit') : 'new'}">
            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">

            <div class="form-group">
                <label for="title">Tên nhiệm vụ *</label>
                <input class="form-control" type="text" id="title" name="title"
                       value="${taskForm.title}" required placeholder="VD: Học Bài 3 & Làm Quiz chương 1" maxlength="255">
            </div>

            <div class="form-group">
                <label for="notes">Ghi chú cá nhân</label>
                <textarea class="form-control" id="notes" name="notes" rows="2"
                          placeholder="VD: Cần đọc kỹ phần transaction, làm nháp trước khi submit...">${taskForm.notes}</textarea>
            </div>

            <!-- Course Selection -->
            <div class="form-group">
                <label for="courseSelect">Liên kết khóa học (tùy chọn)</label>
                <select class="form-control" id="courseSelect" name="courseId" onchange="onCourseChanged(this.value)">
                    <option value="">-- Không gắn khóa học cụ thể --</option>
                    <c:forEach items="${enrolledCourses}" var="c">
                        <option value="${c.courseId}" ${taskForm.courseId == c.courseId ? 'selected' : ''}>
                            📚 ${c.title} (${c.instructorName})
                        </option>
                    </c:forEach>
                </select>
                <span class="form-hint">Chọn khóa học để liên kết với bài học, bài tập hoặc quiz.</span>
            </div>

            <c:if test="${not empty taskForm.courseId}">
                <!-- Sub-items under selected course -->
                <div style="background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 10px; padding: 18px; margin-bottom: 20px;">
                    <div style="font-size: 0.88rem; font-weight: 700; color: #334155; margin-bottom: 12px;">
                        🎯 Tài nguyên thuộc khóa học đã chọn (tùy chọn liên kết)
                    </div>

                    <div class="form-group">
                        <label for="lessonSelect">Bài học liên quan</label>
                        <select class="form-control" id="lessonSelect" name="relatedLessonId">
                            <option value="">-- Không chọn bài học --</option>
                            <c:forEach items="${availableLessons}" var="l">
                                <option value="${l.lessonId}" ${taskForm.relatedLessonId == l.lessonId ? 'selected' : ''}>
                                    Bài ${l.orderIndex}: ${l.title}
                                </option>
                            </c:forEach>
                        </select>
                    </div>

                    <div class="form-group">
                        <label for="assignmentSelect">Bài tập (Assignment) liên quan</label>
                        <select class="form-control" id="assignmentSelect" name="relatedAssignmentId">
                            <option value="">-- Không chọn bài tập --</option>
                            <c:forEach items="${availableAssignments}" var="a">
                                <option value="${a.assignmentId}" ${taskForm.relatedAssignmentId == a.assignmentId ? 'selected' : ''}>
                                    📝 ${a.title} (Hạn nộp chính thức: ${a.dueDate != null ? a.dueDate : 'Không có'})
                                </option>
                            </c:forEach>
                        </select>
                    </div>

                    <div class="form-group" style="margin-bottom: 0;">
                        <label for="quizSelect">Bài kiểm tra (Quiz) liên quan</label>
                        <select class="form-control" id="quizSelect" name="relatedQuizId">
                            <option value="">-- Không chọn quiz --</option>
                            <c:forEach items="${availableQuizzes}" var="q">
                                <option value="${q.quizId}" ${taskForm.relatedQuizId == q.quizId ? 'selected' : ''}>
                                    📊 ${q.title}
                                </option>
                            </c:forEach>
                        </select>
                    </div>
                </div>
            </c:if>

            <div class="form-row">
                <div class="form-group">
                    <label for="plannedStartAt">Thời điểm bắt đầu cá nhân *</label>
                    <input class="form-control" type="datetime-local" id="plannedStartAt" name="plannedStartAt"
                           value="${taskForm.plannedStartAt}" required>
                </div>
                <div class="form-group">
                    <label for="plannedEndAt">Thời điểm kết thúc cá nhân *</label>
                    <input class="form-control" type="datetime-local" id="plannedEndAt" name="plannedEndAt"
                           value="${taskForm.plannedEndAt}" required>
                </div>
            </div>

            <c:if test="${isEdit}">
                <div class="form-group">
                    <label for="status">Trạng thái nhiệm vụ</label>
                    <select class="form-control" id="status" name="status">
                        <option value="PENDING" ${taskForm.status == 'PENDING' ? 'selected' : ''}>PENDING (Chờ làm)</option>
                        <option value="DONE" ${taskForm.status == 'DONE' ? 'selected' : ''}>DONE (Đã hoàn thành)</option>
                        <option value="SKIPPED" ${taskForm.status == 'SKIPPED' ? 'selected' : ''}>SKIPPED (Bỏ qua)</option>
                    </select>
                </div>
            </c:if>

            <div class="form-actions">
                <a class="btn-secondary" href="${pageContext.request.contextPath}/study/plans/${plan.planId}">Hủy bỏ</a>
                <button class="btn-primary" type="submit">
                    ${isEdit ? 'Lưu thay đổi' : 'Thêm nhiệm vụ'}
                </button>
            </div>
        </form>
    </div>

</main>

<script>
function onCourseChanged(courseId) {
    const currentUrl = new URL(window.location.href);
    if (courseId) {
        currentUrl.searchParams.set('selectedCourseId', courseId);
    } else {
        currentUrl.searchParams.delete('selectedCourseId');
    }
    window.location.href = currentUrl.toString();
}
</script>
</body>
</html>

