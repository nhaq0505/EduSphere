<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${plan.title} — Chi tiết kế hoạch</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/home.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app.css?v=planning">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/planning.css">
</head>
<body>

<jsp:include page="/WEB-INF/views/common/navbar.jsp"/>

<main style="max-width: 1200px; margin: 32px auto; padding: 0 24px; min-height: 70vh;">

    <!-- Breadcrumb -->
    <div style="margin-bottom: 20px;">
        <a href="${pageContext.request.contextPath}/study/plans" style="color: #64748b; text-decoration: none; font-size: 0.9rem; font-weight: 500;">
            &larr; Quay lại danh sách kế hoạch
        </a>
    </div>

    <c:if test="${not empty success}">
        <div class="alert alert-success">${success}</div>
    </c:if>

    <!-- Plan Header Card -->
    <div style="background: #ffffff; border: 1px solid #e2e8f0; border-radius: 14px; padding: 28px; margin-bottom: 28px; box-shadow: 0 1px 3px rgba(0,0,0,0.03);">
        <div style="display: flex; justify-content: space-between; align-items: flex-start; flex-wrap: wrap; gap: 16px;">
            <div>
                <div style="display: flex; align-items: center; gap: 10px;">
                    <h1 style="font-size: 1.65rem; font-weight: 800; color: #0f172a; margin: 0;">${plan.title}</h1>
                    <span class="badge badge--${plan.status.toLowerCase()}">${plan.status}</span>
                </div>
                <c:if test="${not empty plan.description}">
                    <p style="color: #475569; font-size: 0.95rem; margin: 10px 0 0; line-height: 1.5;">${plan.description}</p>
                </c:if>
                <div style="display: flex; gap: 18px; margin-top: 14px; font-size: 0.88rem; color: #64748b; font-weight: 500;">
                    <span>📅 Thời gian: <strong>${plan.startDate}</strong> &rarr; <strong>${plan.endDate}</strong></span>
                    <span>🌐 Múi giờ: ${plan.timezone}</span>
                </div>
            </div>

            <div style="display: flex; gap: 8px;">
                <a class="btn-secondary btn-sm" href="${pageContext.request.contextPath}/study/plans/${plan.planId}/edit">
                    ✏️ Sửa kế hoạch
                </a>
                <form method="post" action="${pageContext.request.contextPath}/study/plans/${plan.planId}/delete"
                      onsubmit="return confirm('Bạn có chắc chắn muốn xóa kế hoạch này và toàn bộ nhiệm vụ liên quan?');" style="margin:0;">
                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                    <button class="btn-secondary btn-danger btn-sm" type="submit">🗑️ Xóa</button>
                </form>
            </div>
        </div>

        <!-- Progress Overview -->
        <div style="margin-top: 24px; padding-top: 20px; border-top: 1px solid #f1f5f9;">
            <div class="progress-bar-labels">
                <span>Tiến độ hoàn thành: ${plan.doneTasks} / ${plan.totalTasks} nhiệm vụ</span>
                <span style="font-size: 1rem; color: #2563eb;">${plan.progressPercent}%</span>
            </div>
            <div class="progress-bar-track" style="height: 10px;">
                <div class="progress-bar-fill ${plan.progressPercent == 100 ? 'progress-bar-fill--green' : ''}"
                     style="width: ${plan.progressPercent}%;"></div>
            </div>
        </div>
    </div>

    <!-- Tasks Section (UC35) -->
    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
        <div>
            <h2 style="font-size: 1.35rem; font-weight: 700; color: #0f172a; margin: 0;">
                Nhiệm vụ trong kế hoạch (Tasks)
            </h2>
            <p style="color: #64748b; font-size: 0.88rem; margin: 4px 0 0;">
                Lịch cá nhân cho từng bài học, quiz hoặc bài tập (UC35 - không thay đổi hạn nộp chính thức).
            </p>
        </div>
        <a class="btn-primary" href="${pageContext.request.contextPath}/study/plans/${plan.planId}/tasks/new">
            + Thêm nhiệm vụ cá nhân
        </a>
    </div>

    <c:choose>
        <c:when test="${empty tasks}">
            <div style="text-align: center; padding: 48px 20px; background: #fff; border: 1px dashed #cbd5e1; border-radius: 12px;">
                <div style="font-size: 2.5rem; margin-bottom: 12px;">📌</div>
                <h3 style="color: #1e293b; margin: 0 0 6px;">Chưa có nhiệm vụ nào trong kế hoạch này</h3>
                <p style="color: #64748b; margin-bottom: 20px;">Hãy lên lịch học tập chi tiết cho từng bài học hoặc bài kiểm tra!</p>
                <a class="btn-primary" href="${pageContext.request.contextPath}/study/plans/${plan.planId}/tasks/new">
                    + Thêm nhiệm vụ đầu tiên
                </a>
            </div>
        </c:when>
        <c:otherwise>
            <div class="task-table-card">
                <table class="task-table">
                    <thead>
                        <tr>
                            <th style="width: 35%;">Nhiệm vụ</th>
                            <th style="width: 25%;">Khóa học & Tài nguyên liên kết</th>
                            <th style="width: 18%;">Lịch dự kiến cá nhân</th>
                            <th style="width: 10%;">Trạng thái</th>
                            <th style="width: 12%; text-align: right;">Thao tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${tasks}" var="task">
                            <tr>
                                <td>
                                    <div class="task-title ${task.status == 'DONE' ? 'task-title--done' : ''}">
                                        ${task.title}
                                    </div>
                                    <c:if test="${not empty task.notes}">
                                        <div style="font-size: 0.82rem; color: #64748b; margin-top: 3px;">${task.notes}</div>
                                    </c:if>
                                </td>
                                <td>
                                    <c:if test="${not empty task.courseTitle}">
                                        <div style="font-weight: 600; color: #1e293b;">📚 ${task.courseTitle}</div>
                                    </c:if>
                                    <c:if test="${not empty task.lessonTitle}">
                                        <div class="task-resource">📖 Bài: ${task.lessonTitle}</div>
                                    </c:if>
                                    <c:if test="${not empty task.assignmentTitle}">
                                        <div class="task-resource">📝 Bài tập: ${task.assignmentTitle}</div>
                                    </c:if>
                                    <c:if test="${not empty task.quizTitle}">
                                        <div class="task-resource">📊 Quiz: ${task.quizTitle}</div>
                                    </c:if>
                                    <c:if test="${empty task.courseTitle and empty task.lessonTitle and empty task.assignmentTitle and empty task.quizTitle}">
                                        <span style="color: #94a3b8; font-style: italic;">(Mục tiêu tự do)</span>
                                    </c:if>
                                </td>
                                <td>
                                    <div style="font-size: 0.85rem; font-weight: 600; color: #1e293b;">
                                        ${task.plannedStartAt}
                                    </div>
                                    <div style="font-size: 0.78rem; color: #64748b;">
                                        đến ${task.plannedEndAt}
                                    </div>
                                </td>
                                <td>
                                    <span class="badge badge--${task.status.toLowerCase()}">${task.status}</span>
                                </td>
                                <td style="text-align: right;">
                                    <div style="display: inline-flex; gap: 6px; align-items: center;">
                                        <c:choose>
                                            <c:when test="${task.status != 'DONE'}">
                                                <form method="post" action="${pageContext.request.contextPath}/study/plans/${plan.planId}/tasks/${task.taskId}/done" style="margin:0;">
                                                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                                    <button class="btn-secondary btn-sm" type="submit" title="Đánh dấu hoàn thành" style="background: #f0fdf4; color: #16a34a; border-color: #bbf7d0;">
                                                        ✓ Xong
                                                    </button>
                                                </form>
                                            </c:when>
                                            <c:otherwise>
                                                <form method="post" action="${pageContext.request.contextPath}/study/plans/${plan.planId}/tasks/${task.taskId}/reopen" style="margin:0;">
                                                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                                    <button class="btn-secondary btn-sm" type="submit" title="Mở lại nhiệm vụ">
                                                        ↩ Mở lại
                                                    </button>
                                                </form>
                                            </c:otherwise>
                                        </c:choose>

                                        <a class="btn-secondary btn-sm" href="${pageContext.request.contextPath}/study/plans/${plan.planId}/tasks/${task.taskId}/edit" title="Sửa">
                                            ✏️
                                        </a>

                                        <form method="post" action="${pageContext.request.contextPath}/study/plans/${plan.planId}/tasks/${task.taskId}/delete"
                                              onsubmit="return confirm('Xóa nhiệm vụ này?');" style="margin:0;">
                                            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                            <button class="btn-secondary btn-danger btn-sm" type="submit" title="Xóa">🗑️</button>
                                        </form>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
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

