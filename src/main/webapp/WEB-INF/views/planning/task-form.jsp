<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html><html lang="vi"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1.0">
<title>${isEdit ? 'Sửa' : 'Thêm'} nhiệm vụ — EduSphere</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/home.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/planning-new.css">
</head><body>
<jsp:include page="/WEB-INF/views/planning/planning-navbar.jsp"/>
<div class="pl-shell" style="max-width:820px;">
<a href="${pageContext.request.contextPath}/study/plans/${plan.planId}" style="color:#64748b;text-decoration:none;font-size:.87rem;font-weight:600;display:inline-flex;align-items:center;gap:5px;margin-bottom:20px;">
    ← Quay lại: <strong><c:out value="${plan.title}"/></strong>
</a>
<div style="margin-bottom:24px;">
    <h1 style="font-size:1.55rem;font-weight:800;color:#0f172a;margin:0 0 5px;">${isEdit ? 'Chỉnh sửa nhiệm vụ' : 'Thêm nhiệm vụ học tập'}</h1>
    <p style="color:#64748b;font-size:.87rem;margin:0;">Lên lịch học bài, làm bài tập hoặc quiz theo kế hoạch cá nhân (UC35).</p>
</div>

<div class="pl-callout-info">
    <div style="font-size:1.2rem;flex-shrink:0;">ℹ️</div>
    <div><strong>Quan trọng:</strong> Thời gian bạn đặt ở đây là lịch học cá nhân và <em>tuyệt đối không làm thay đổi</em> hạn nộp chính thức do giảng viên quy định.</div>
</div>

<c:if test="${not empty error}"><div class="pl-alert pl-alert--danger">⚠️ <c:out value="${error}"/></div></c:if>

<div class="pl-form-card">
    <form method="post" action="${pageContext.request.contextPath}/study/plans/${plan.planId}/tasks/${isEdit ? taskId : 'new'}${isEdit ? '/edit' : ''}">
        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">

        <div class="pl-field">
            <label class="pl-label" for="title">Tên nhiệm vụ <span style="color:#ef4444">*</span></label>
            <input class="pl-input" type="text" id="title" name="title" value="<c:out value='${taskForm.title}'/>" required maxlength="255" placeholder="VD: Học Bài 3 — Lập trình OOP & Làm Quiz chương 1">
        </div>

        <div class="pl-field">
            <label class="pl-label" for="notes">Ghi chú cá nhân</label>
            <textarea class="pl-input" id="notes" name="notes" rows="2" placeholder="VD: Đọc kỹ phần inheritance trước, xem lại slide bài 2..."><c:out value="${taskForm.notes}"/></textarea>
        </div>

        <!-- Course picker -->
        <div class="pl-field">
            <label class="pl-label" for="courseSelect">Liên kết khóa học (tùy chọn)</label>
            <select class="pl-input" id="courseSelect" name="courseId" onchange="onCourseChanged(this.value)">
                <option value="">-- Không gắn khóa học cụ thể --</option>
                <c:forEach items="${enrolledCourses}" var="c">
                    <option value="${c.courseId}" ${taskForm.courseId == c.courseId ? 'selected' : ''}>
                        📚 <c:out value="${c.title}"/>
                    </option>
                </c:forEach>
            </select>
            <div class="pl-hint">Chọn để liên kết với bài học, bài tập hoặc quiz thuộc khóa đó.</div>
        </div>

        <c:if test="${not empty taskForm.courseId}">
            <div style="background:#f8fafc;border:1.5px solid #e2e8f0;border-radius:14px;padding:20px;margin-bottom:20px;">
                <div style="font-size:.82rem;font-weight:700;color:#334155;margin-bottom:14px;display:flex;align-items:center;gap:6px;">
                    🎯 Tài nguyên liên kết <span style="font-weight:400;color:#94a3b8;">(chọn tối đa 1 loại)</span>
                </div>
                <div class="pl-field">
                    <label class="pl-label" for="lessonSelect">Bài học</label>
                    <select class="pl-input" id="lessonSelect" name="relatedLessonId" onchange="clearOthers('lesson')">
                        <option value="">-- Không chọn --</option>
                        <c:forEach items="${availableLessons}" var="l">
                            <option value="${l.lessonId}" ${taskForm.relatedLessonId == l.lessonId ? 'selected' : ''}>
                                Bài ${l.orderIndex}: <c:out value="${l.title}"/>
                            </option>
                        </c:forEach>
                    </select>
                </div>
                <div class="pl-field">
                    <label class="pl-label" for="assignmentSelect">Bài tập (Assignment)</label>
                    <select class="pl-input" id="assignmentSelect" name="relatedAssignmentId" onchange="clearOthers('assignment')">
                        <option value="">-- Không chọn --</option>
                        <c:forEach items="${availableAssignments}" var="a">
                            <option value="${a.assignmentId}" ${taskForm.relatedAssignmentId == a.assignmentId ? 'selected' : ''}>
                                📝 <c:out value="${a.title}"/>
                            </option>
                        </c:forEach>
                    </select>
                </div>
                <div class="pl-field" style="margin-bottom:0;">
                    <label class="pl-label" for="quizSelect">Bài kiểm tra (Quiz)</label>
                    <select class="pl-input" id="quizSelect" name="relatedQuizId" onchange="clearOthers('quiz')">
                        <option value="">-- Không chọn --</option>
                        <c:forEach items="${availableQuizzes}" var="q">
                            <option value="${q.quizId}" ${taskForm.relatedQuizId == q.quizId ? 'selected' : ''}>
                                📊 <c:out value="${q.title}"/>
                            </option>
                        </c:forEach>
                    </select>
                </div>
            </div>
        </c:if>

        <div class="pl-grid-2">
            <div class="pl-field">
                <label class="pl-label" for="plannedStartAt">Bắt đầu cá nhân <span style="color:#ef4444">*</span></label>
                <input class="pl-input" type="datetime-local" id="plannedStartAt" name="plannedStartAt" value="<c:out value='${taskForm.plannedStartAt}'/>" required>
            </div>
            <div class="pl-field">
                <label class="pl-label" for="plannedEndAt">Kết thúc cá nhân <span style="color:#ef4444">*</span></label>
                <input class="pl-input" type="datetime-local" id="plannedEndAt" name="plannedEndAt" value="<c:out value='${taskForm.plannedEndAt}'/>" required>
            </div>
        </div>

        <c:if test="${isEdit}">
            <div class="pl-field">
                <label class="pl-label" for="status">Trạng thái</label>
                <select class="pl-input" id="status" name="status">
                    <option value="PENDING" ${taskForm.status == 'PENDING' ? 'selected' : ''}>⏳ PENDING — Chờ làm</option>
                    <option value="DONE" ${taskForm.status == 'DONE' ? 'selected' : ''}>✅ DONE — Hoàn thành</option>
                    <option value="SKIPPED" ${taskForm.status == 'SKIPPED' ? 'selected' : ''}>⏭️ SKIPPED — Bỏ qua</option>
                </select>
            </div>
        </c:if>

        <div class="pl-form-actions">
            <a class="pl-btn pl-btn--outline" href="${pageContext.request.contextPath}/study/plans/${plan.planId}">Hủy</a>
            <button class="pl-btn pl-btn--primary" type="submit">${isEdit ? '💾 Lưu thay đổi' : '➕ Thêm nhiệm vụ'}</button>
        </div>
    </form>
</div>
</div>
<jsp:include page="/WEB-INF/views/planning/planning-footer.jsp"/>
<script>
function onCourseChanged(courseId) {
    const u = new URL(window.location.href);
    if (courseId) u.searchParams.set('selectedCourseId', courseId);
    else u.searchParams.delete('selectedCourseId');
    window.location.href = u.toString();
}
function clearOthers(changed) {
    if (changed !== 'lesson') { const s = document.getElementById('lessonSelect'); if(s) s.value = ''; }
    if (changed !== 'assignment') { const s = document.getElementById('assignmentSelect'); if(s) s.value = ''; }
    if (changed !== 'quiz') { const s = document.getElementById('quizSelect'); if(s) s.value = ''; }
}
</script>
</body></html>