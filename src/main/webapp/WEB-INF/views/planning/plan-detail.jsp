<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html><html lang="vi"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1.0">
<title><c:out value="${plan.title}"/> — EduSphere</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/home.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/planning-new.css">
</head><body>
<jsp:include page="/WEB-INF/views/common/navbar.jsp"/>
<div class="pl-shell">
<a href="${pageContext.request.contextPath}/study/plans" style="color:#64748b;text-decoration:none;font-size:.87rem;font-weight:600;display:inline-flex;align-items:center;gap:5px;margin-bottom:20px;">← Danh sách kế hoạch</a>
<c:if test="${not empty success}"><div class="pl-alert pl-alert--success">✅ <c:out value="${success}"/></div></c:if>

<!-- Plan header card -->
<div style="background:#fff;border:1px solid #e2e8f0;border-radius:20px;padding:28px;margin-bottom:28px;box-shadow:0 2px 8px rgba(0,0,0,.04);">
    <div style="display:flex;justify-content:space-between;align-items:flex-start;flex-wrap:wrap;gap:16px;">
        <div>
            <div style="display:flex;align-items:center;gap:10px;margin-bottom:8px;">
                <h1 style="font-size:1.6rem;font-weight:800;color:#0f172a;margin:0;"><c:out value="${plan.title}"/></h1>
                <span class="pl-badge pl-badge--${plan.status.toLowerCase()}"><c:out value="${plan.status}"/></span>
            </div>
            <c:if test="${not empty plan.description}">
                <p style="color:#475569;font-size:.9rem;margin:0 0 10px;line-height:1.5;"><c:out value="${plan.description}"/></p>
            </c:if>
            <div style="font-size:.82rem;color:#64748b;font-weight:500;">
                📅 <c:out value="${plan.startDate}"/> → <c:out value="${plan.endDate}"/>
            </div>
        </div>
        <div style="display:flex;gap:8px;flex-wrap:wrap;">
            <a class="pl-btn pl-btn--outline pl-btn--sm" href="${pageContext.request.contextPath}/study/plans/${plan.planId}/edit">✏️ Sửa kế hoạch</a>
            <form method="post" action="${pageContext.request.contextPath}/study/plans/${plan.planId}/delete" onsubmit="return confirm('Xóa kế hoạch này?');" style="margin:0;">
                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                <button class="pl-btn pl-btn--danger pl-btn--sm" type="submit">🗑️ Xóa</button>
            </form>
        </div>
    </div>
    <div style="margin-top:22px;padding-top:18px;border-top:1px solid #f1f5f9;">
        <div class="pl-prog-labels" style="margin-bottom:8px;">
            <span>Tiến độ: <strong>${plan.doneTasks} / ${plan.totalTasks}</strong> nhiệm vụ hoàn thành</span>
            <span style="font-size:1.05rem;color:#009bf2;font-weight:800;">${plan.progressPercent}%</span>
        </div>
        <div class="pl-prog-track" style="height:10px;">
            <div class="pl-prog-fill ${plan.progressPercent >= 100 ? 'pl-prog-fill--done' : ''}" style="width:${plan.progressPercent}%;"></div>
        </div>
    </div>
</div>

<!-- Tasks header -->
<div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:18px;flex-wrap:wrap;gap:12px;">
    <div>
        <h2 style="font-size:1.15rem;font-weight:700;color:#0f172a;margin:0;">Nhiệm vụ trong kế hoạch</h2>
        <p style="color:#64748b;font-size:.82rem;margin:4px 0 0;">Lịch cá nhân – không ảnh hưởng hạn nộp chính thức của giảng viên (UC35)</p>
    </div>
    <a class="pl-btn pl-btn--primary" href="${pageContext.request.contextPath}/study/plans/${plan.planId}/tasks/new">➕ Thêm nhiệm vụ</a>
</div>

<c:choose>
    <c:when test="${empty tasks}">
        <div class="pl-empty">
            <div class="pl-empty__icon">📌</div>
            <h3>Chưa có nhiệm vụ nào</h3>
            <p>Lên lịch học bài hoặc làm bài kiểm tra để theo dõi tiến độ!</p>
            <a class="pl-btn pl-btn--primary" href="${pageContext.request.contextPath}/study/plans/${plan.planId}/tasks/new">➕ Thêm nhiệm vụ đầu tiên</a>
        </div>
    </c:when>
    <c:otherwise>
        <div class="pl-table-wrap">
            <table class="pl-table">
                <thead><tr>
                    <th style="width:32%;">Nhiệm vụ</th>
                    <th style="width:24%;">Khóa học & Tài nguyên</th>
                    <th style="width:20%;">Lịch cá nhân</th>
                    <th style="width:12%;">Trạng thái</th>
                    <th style="width:12%;text-align:right;">Thao tác</th>
                </tr></thead>
                <tbody>
                <c:forEach items="${tasks}" var="task">
                    <tr>
                        <td>
                            <div class="pl-task-title ${task.status == 'DONE' ? 'pl-task-title--done' : ''}"><c:out value="${task.title}"/></div>
                            <c:if test="${not empty task.notes}"><div class="pl-task-notes"><c:out value="${task.notes}"/></div></c:if>
                        </td>
                        <td>
                            <c:if test="${not empty task.courseTitle}"><div style="font-weight:600;color:#1e293b;font-size:.82rem;">📚 <c:out value="${task.courseTitle}"/></div></c:if>
                            <c:if test="${not empty task.lessonTitle}"><div class="pl-resource-tag">📖 <c:out value="${task.lessonTitle}"/></div></c:if>
                            <c:if test="${not empty task.assignmentTitle}"><div class="pl-resource-tag">📝 <c:out value="${task.assignmentTitle}"/></div></c:if>
                            <c:if test="${not empty task.quizTitle}"><div class="pl-resource-tag">📊 <c:out value="${task.quizTitle}"/></div></c:if>
                            <c:if test="${empty task.courseTitle and empty task.lessonTitle and empty task.assignmentTitle and empty task.quizTitle}">
                                <span style="color:#94a3b8;font-size:.78rem;font-style:italic;">Mục tiêu tự do</span>
                            </c:if>
                        </td>
                        <td style="font-size:.82rem;">
                            <div style="font-weight:600;color:#1e293b;"><c:out value="${task.plannedStartAt}"/></div>
                            <div style="color:#64748b;">đến <c:out value="${task.plannedEndAt}"/></div>
                        </td>
                        <td><span class="pl-badge pl-badge--${task.status.toLowerCase()}"><c:out value="${task.status}"/></span></td>
                        <td style="text-align:right;">
                            <div style="display:inline-flex;gap:5px;align-items:center;">
                                <c:choose>
                                    <c:when test="${task.status != 'DONE'}">
                                        <form method="post" action="${pageContext.request.contextPath}/study/plans/${plan.planId}/tasks/${task.taskId}/done" style="margin:0;">
                                            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                            <button class="pl-btn pl-btn--sm" type="submit" style="background:#f0fdf4;color:#16a34a;border:1.5px solid #bbf7d0;border-radius:8px;padding:6px 10px;cursor:pointer;font-weight:700;font-size:.75rem;" title="Hoàn thành">✓</button>
                                        </form>
                                    </c:when>
                                    <c:otherwise>
                                        <form method="post" action="${pageContext.request.contextPath}/study/plans/${plan.planId}/tasks/${task.taskId}/reopen" style="margin:0;">
                                            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                            <button class="pl-btn pl-btn--outline pl-btn--sm pl-btn--icon" type="submit" title="Mở lại">↩</button>
                                        </form>
                                    </c:otherwise>
                                </c:choose>
                                <a class="pl-btn pl-btn--outline pl-btn--sm pl-btn--icon" href="${pageContext.request.contextPath}/study/plans/${plan.planId}/tasks/${task.taskId}/edit">✏️</a>
                                <form method="post" action="${pageContext.request.contextPath}/study/plans/${plan.planId}/tasks/${task.taskId}/delete" onsubmit="return confirm('Xóa nhiệm vụ?');" style="margin:0;">
                                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                    <button class="pl-btn pl-btn--danger pl-btn--sm pl-btn--icon" type="submit">🗑️</button>
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
</div>
<jsp:include page="/WEB-INF/views/planning/planning-footer.jsp"/>
</body></html>