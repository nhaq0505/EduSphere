<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><c:choose><c:when test="${not empty quizId}">Cài đặt Quiz: <c:out value="${quizForm.title}"/></c:when><c:otherwise>Tạo Quiz mới</c:otherwise></c:choose> — EduSphere</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/instructor.css">
    <style>
        .qf-container {
            max-width: 860px;
            margin: 0 auto;
            padding-bottom: 40px;
        }
        .qf-card {
            background: #fff;
            border: 1px solid #E2E8F0;
            border-radius: 16px;
            overflow: hidden;
            box-shadow: 0 4px 20px rgba(0,0,0,0.05);
            margin-top: 14px;
        }
        .qf-header {
            background: linear-gradient(135deg, #7E22CE 0%, #4C1D95 100%);
            padding: 28px 32px;
            color: #fff;
        }
        .qf-header__eyebrow {
            font-size: .75rem;
            font-weight: 800;
            letter-spacing: .08em;
            text-transform: uppercase;
            display: inline-flex;
            align-items: center;
            gap: 6px;
            background: rgba(255,255,255,.18);
            padding: 4px 12px;
            border-radius: 20px;
            margin-bottom: 8px;
        }
        .qf-header__title {
            font-size: 1.45rem;
            font-weight: 900;
            margin: 0 0 6px 0;
            color: #fff;
        }
        .qf-header__desc {
            font-size: .88rem;
            opacity: .88;
            margin: 0;
            line-height: 1.5;
        }
        .qf-body {
            padding: 30px 32px;
        }
        .qf-section {
            margin-bottom: 28px;
            padding-bottom: 24px;
            border-bottom: 1px solid #F1F5F9;
        }
        .qf-section:last-of-type {
            margin-bottom: 0;
            padding-bottom: 0;
            border-bottom: none;
        }
        .qf-section-title {
            font-size: 1.02rem;
            font-weight: 800;
            color: #0F172A;
            margin: 0 0 16px 0;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        .qf-grid-2 {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 18px;
        }
        @media(max-width: 640px) {
            .qf-grid-2 { grid-template-columns: 1fr; }
            .qf-body { padding: 20px; }
            .qf-header { padding: 20px; }
        }
        .qf-field {
            margin-bottom: 16px;
        }
        .qf-label {
            display: block;
            font-size: .86rem;
            font-weight: 700;
            color: #334155;
            margin-bottom: 6px;
        }
        .qf-input {
            width: 100%;
            box-sizing: border-box;
            padding: 10px 14px;
            font-size: .92rem;
            font-family: inherit;
            color: #0F172A;
            background: #F8FAFC;
            border: 1.5px solid #CBD5E1;
            border-radius: 8px;
            transition: all .15s ease;
        }
        .qf-input:focus {
            outline: none;
            background: #fff;
            border-color: #7E22CE;
            box-shadow: 0 0 0 3px rgba(126, 34, 206, 0.15);
        }
        .qf-hint {
            font-size: .78rem;
            color: #64748B;
            margin-top: 5px;
            line-height: 1.4;
        }
        .qf-toggle-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 14px;
            margin-bottom: 16px;
        }
        @media(max-width: 640px) {
            .qf-toggle-grid { grid-template-columns: 1fr; }
        }
        .qf-toggle-card {
            display: flex;
            align-items: flex-start;
            gap: 12px;
            padding: 14px 16px;
            background: #FAF5FF;
            border: 1.5px solid #E9D5FF;
            border-radius: 10px;
            cursor: pointer;
            transition: all .15s ease;
        }
        .qf-toggle-card:hover {
            background: #F3E8FF;
            border-color: #C084FC;
        }
        .qf-toggle-card input[type="checkbox"] {
            width: 18px;
            height: 18px;
            margin-top: 2px;
            accent-color: #7E22CE;
            cursor: pointer;
        }
        .qf-toggle-title {
            font-size: .88rem;
            font-weight: 700;
            color: #581C87;
        }
        .qf-toggle-desc {
            font-size: .78rem;
            color: #7E22CE;
            margin-top: 2px;
            line-height: 1.4;
            opacity: .9;
        }
        .qf-actions {
            display: flex;
            align-items: center;
            gap: 12px;
            margin-top: 28px;
            padding-top: 20px;
            border-top: 1px solid #E2E8F0;
        }
        .qf-btn-primary {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            background: #7E22CE;
            color: #fff;
            font-weight: 800;
            font-size: .95rem;
            padding: 11px 32px;
            border-radius: 8px;
            border: none;
            cursor: pointer;
            box-shadow: 0 2px 8px rgba(126, 34, 206, 0.3);
            transition: all .18s ease;
            text-decoration: none;
        }
        .qf-btn-primary:hover {
            background: #6B21A8;
            transform: translateY(-1px);
            box-shadow: 0 4px 14px rgba(126, 34, 206, 0.4);
        }
        .qf-btn-cancel {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            background: #fff;
            color: #64748B;
            font-weight: 600;
            font-size: .92rem;
            padding: 10px 22px;
            border-radius: 8px;
            border: 1px solid #CBD5E1;
            text-decoration: none;
            transition: all .15s ease;
        }
        .qf-btn-cancel:hover {
            background: #F1F5F9;
            color: #0F172A;
        }
        .ins-field-error {
            color: #DC2626;
            font-size: .8rem;
            font-weight: 600;
            margin-top: 4px;
            display: block;
        }
    </style>
</head>
<body>
<div class="ins-layout">
    <jsp:include page="../courses/ins-sidebar.jsp"/>
    <div class="ins-main-wrapper">
        <jsp:include page="../courses/ins-header.jsp"/>
        <main class="ins-page">

        <div class="qf-container">
            <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:14px; flex-wrap:wrap; gap:8px;">
                <nav style="display:flex; align-items:center; gap:8px; font-size:.85rem; color:#64748B;">
                    <a href="${pageContext.request.contextPath}/instructor/courses/${courseId}" style="color:#64748B; text-decoration:none; font-weight:600; display:inline-flex; align-items:center; gap:4px;">
                        📘 Khóa học
                    </a>
                    <span>/</span>
                    <a href="${pageContext.request.contextPath}/instructor/courses/${courseId}/quizzes" style="color:#64748B; text-decoration:none; font-weight:600; display:inline-flex; align-items:center; gap:4px;">
                        📝 Quản lý Quiz
                    </a>
                    <span>/</span>
                    <span style="color:#0F172A; font-weight:700;">
                        <c:choose>
                            <c:when test="${not empty quizId}">Cài đặt</c:when>
                            <c:otherwise>Tạo mới</c:otherwise>
                        </c:choose>
                    </span>
                </nav>
                <a href="${pageContext.request.contextPath}/instructor/courses/${courseId}/quizzes"
                   style="display:inline-flex; align-items:center; gap:6px; font-weight:600; color:#475569; text-decoration:none; font-size:.84rem; padding:6px 14px; background:#fff; border:1px solid #CBD5E1; border-radius:6px; transition:all .15s;">
                    ← Quay lại danh sách Quiz
                </a>
            </div>

            <div class="qf-card">
                <!-- Header Banner -->
                <div class="qf-header">
                    <span class="qf-header__eyebrow">📝 BÀI KIỂM TRA & ĐÁNH GIÁ</span>
                    <h1 class="qf-header__title">
                        <c:choose>
                            <c:when test="${not empty quizId}">⚙️ Cài đặt bài Quiz</c:when>
                            <c:otherwise>➕ Tạo bài Quiz mới</c:otherwise>
                        </c:choose>
                    </h1>
                    <p class="qf-header__desc">
                        Thiết lập thông tin chung, thời gian làm bài, số lần thử và cấu hình liên kết bài học.
                    </p>
                </div>

                <!-- Form Body -->
                <div class="qf-body">
                    <form method="post" action="${not empty quizId ? pageContext.request.contextPath.concat('/instructor/courses/').concat(courseId).concat('/quizzes/').concat(quizId).concat('/edit') : pageContext.request.contextPath.concat('/instructor/courses/').concat(courseId).concat('/quizzes')}">
                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>

                        <!-- ══ SECTION 1: THÔNG TIN CHUNG ══ -->
                        <div class="qf-section">
                            <h2 class="qf-section-title">📋 1. Thông tin cơ bản</h2>

                            <div class="qf-field">
                                <label class="qf-label" for="title">Tiêu đề bài Quiz <span style="color:#EF4444">*</span></label>
                                <input class="qf-input" type="text" id="title" name="title" maxlength="255" required
                                       style="font-size:1rem; font-weight:600;"
                                       placeholder="VD: Kiểm tra trắc nghiệm Chương 1, Đề thi giữa kỳ..."
                                       value="<c:out value='${quizForm.title}'/>">
                                <c:if test="${not empty errors && errors.hasFieldErrors('title')}">
                                    <span class="ins-field-error"><c:out value="${errors.getFieldError('title').defaultMessage}"/></span>
                                </c:if>
                            </div>

                            <div class="qf-field">
                                <label class="qf-label" for="description">Mô tả & Hướng dẫn làm bài</label>
                                <textarea class="qf-input" id="description" name="description" rows="3" style="resize:vertical"
                                          placeholder="Tóm tắt phạm vi kiến thức cần nắm, lời dặn dò trước khi học viên bắt đầu..."><c:out value="${quizForm.description}"/></textarea>
                            </div>

                            <div class="qf-field">
                                <label class="qf-label" for="lessonId">Liên kết với bài học (Tùy chọn)</label>
                                <c:choose>
                                    <c:when test="${not empty lessons}">
                                        <select class="qf-input" id="lessonId" name="lessonId">
                                            <option value="">-- Quiz chung của cả khóa học (Không gắn bài riêng) --</option>
                                            <c:forEach var="les" items="${lessons}">
                                                <option value="${les.lessonId}" ${quizForm.lessonId == les.lessonId ? 'selected' : ''}>
                                                    Bài ${les.orderIndex}: <c:out value="${les.title}"/> <c:if test="${les.lessonType eq 'QUIZ'}">(Loại Quiz)</c:if>
                                                </option>
                                            </c:forEach>
                                        </select>
                                        <p class="qf-hint">
                                            💡 Nếu liên kết với bài học, bài Quiz sẽ xuất hiện trực tiếp trong tab <strong>"Bài tập & Quiz"</strong> khi học viên học bài đó.
                                        </p>
                                    </c:when>
                                    <c:otherwise>
                                        <select class="qf-input" id="lessonId" name="lessonId">
                                            <option value="">-- Quiz chung của cả khóa học --</option>
                                        </select>
                                        <p class="qf-hint" style="color:#94A3B8;">Khóa học chưa có bài học nào được tạo.</p>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>

                        <!-- ══ SECTION 2: CẤU HÌNH LÀM BÀI ══ -->
                        <div class="qf-section">
                            <h2 class="qf-section-title">⏱️ 2. Thời gian & Lượt làm bài</h2>

                            <div class="qf-grid-2">
                                <div class="qf-field">
                                    <label class="qf-label" for="timeLimitMinutes">Thời gian làm bài (Phút)</label>
                                    <input class="qf-input" type="number" min="1" id="timeLimitMinutes" name="timeLimitMinutes"
                                           placeholder="VD: 15, 30, 45..."
                                           value="${quizForm.timeLimitMinutes}">
                                    <p class="qf-hint">Bỏ trống nếu muốn cho học viên làm thoải mái không giới hạn thời gian.</p>
                                </div>

                                <div class="qf-field">
                                    <label class="qf-label" for="maxAttempts">Số lần làm tối đa</label>
                                    <input class="qf-input" type="number" min="1" id="maxAttempts" name="maxAttempts"
                                           placeholder="1"
                                           value="${quizForm.maxAttempts != null ? quizForm.maxAttempts : 1}">
                                    <p class="qf-hint">Mặc định là 1 lần. Nhập số lớn hơn nếu cho phép thi lại cải thiện điểm.</p>
                                </div>
                            </div>

                            <div class="qf-grid-2">
                                <div class="qf-field">
                                    <label class="qf-label" for="startTime">Thời điểm mở đề thi</label>
                                    <input class="qf-input" type="datetime-local" id="startTime" name="startTime"
                                           value="<c:out value='${quizForm.startTime}'/>">
                                    <p class="qf-hint">Bỏ trống nếu cho phép học viên bắt đầu làm ngay khi công bố.</p>
                                </div>

                                <div class="qf-field">
                                    <label class="qf-label" for="passingScore">Điểm đạt yêu cầu (%)</label>
                                    <input class="qf-input" type="number" id="passingScore" name="passingScore" min="0" max="100" step="1"
                                           placeholder="VD: 50 (đạt 50% tổng điểm)"
                                           value="${quizForm.passingScore}">
                                    <p class="qf-hint">Bỏ trống nếu không bắt buộc điểm sàn để qua bài.</p>
                                </div>
                            </div>
                        </div>

                        <!-- ══ SECTION 3: TÙY CHỌN NÂNG CAO & NỘI QUY ══ -->
                        <div class="qf-section">
                            <h2 class="qf-section-title">🔀 3. Chống gian lận & Nội quy thi</h2>

                            <div class="qf-toggle-grid">
                                <label class="qf-toggle-card">
                                    <input type="checkbox" name="shuffleQuestions" value="true" ${quizForm.shuffleQuestions ? 'checked' : ''}/>
                                    <div>
                                        <div class="qf-toggle-title">🔀 Xáo trộn câu hỏi</div>
                                        <div class="qf-toggle-desc">Mỗi học sinh sẽ nhận thứ tự câu hỏi ngẫu nhiên khác nhau.</div>
                                    </div>
                                </label>

                                <label class="qf-toggle-card">
                                    <input type="checkbox" name="shuffleOptions" value="true" ${quizForm.shuffleOptions ? 'checked' : ''}/>
                                    <div>
                                        <div class="qf-toggle-title">🔀 Xáo trộn đáp án</div>
                                        <div class="qf-toggle-desc">Đảo ngẫu nhiên vị trí các lựa chọn A, B, C, D của câu hỏi.</div>
                                    </div>
                                </label>
                            </div>

                            <div class="qf-field" style="margin-bottom:0;">
                                <label class="qf-label" for="rules">Quy định & Lời nhắc nhở (Tùy chọn)</label>
                                <textarea class="qf-input" id="rules" name="rules" rows="3" style="resize:vertical"
                                          placeholder="VD: Học sinh không được chuyển tab trong khi làm bài, hệ thống sẽ tự động nộp bài khi hết giờ..."><c:out value="${quizForm.rules}"/></textarea>
                            </div>
                        </div>

                        <!-- ══ ACTION BUTTONS ══ -->
                        <div class="qf-actions">
                            <button type="submit" class="qf-btn-primary">
                                💾 <c:choose><c:when test="${not empty quizId}">Lưu thay đổi</c:when><c:otherwise>Lưu & Tiếp tục soạn câu hỏi</c:otherwise></c:choose>
                            </button>
                            <a href="${not empty quizId ? pageContext.request.contextPath.concat('/instructor/courses/').concat(courseId).concat('/quizzes/').concat(quizId) : pageContext.request.contextPath.concat('/instructor/courses/').concat(courseId).concat('/quizzes')}" class="qf-btn-cancel">
                                Hủy bỏ
                            </a>
                        </div>

                    </form>
                </div>
            </div>
        </div>

        </main>
    </div>
</div>

<script>
function insToggleMenu(e) {
    e.stopPropagation();
    document.getElementById('insUserMenu').classList.toggle('open');
}
document.addEventListener('click', function() {
    var m = document.getElementById('insUserMenu');
    if (m) m.classList.remove('open');
});
var navCourses = document.getElementById('nav-courses');
if (navCourses) navCourses.classList.add('active');
</script>
</body>
</html>
