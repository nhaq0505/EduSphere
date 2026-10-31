<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chi tiết khóa học — EduSphere</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/home.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/instructor.css">
</head>
<body>
<jsp:include page="/WEB-INF/views/courses/ins-header.jsp"/>
<div class="ins-shell">
    <jsp:include page="/WEB-INF/views/courses/ins-sidebar.jsp"/>
    <main class="ins-content">

        <a class="ins-back-link" href="${pageContext.request.contextPath}/instructor/courses">← Danh sách khóa học</a>

        <c:if test="${not empty success}"><div class="ins-alert ins-alert--success">✅ <c:out value="${success}"/></div></c:if>

        <div class="ins-detail-layout">
            <!-- Main info -->
            <div class="ins-detail-main">
                <div class="ins-detail-main__header">
                    <c:choose>
                        <c:when test="${course.hidden}">              <span class="ins-status-badge ins-status-badge--hidden">Tạm ẩn</span></c:when>
                        <c:when test="${course.status=='DRAFT'}">     <span class="ins-status-badge ins-status-badge--draft">Bản nháp</span></c:when>
                        <c:when test="${course.status=='SUBMITTED'}"> <span class="ins-status-badge ins-status-badge--submitted">Chờ duyệt</span></c:when>
                        <c:when test="${course.status=='APPROVED'}">  <span class="ins-status-badge ins-status-badge--approved">Đã duyệt</span></c:when>
                        <c:when test="${course.status=='PUBLISHED'}"> <span class="ins-status-badge ins-status-badge--published">Đã công bố</span></c:when>
                        <c:when test="${course.status=='REJECTED'}">  <span class="ins-status-badge ins-status-badge--rejected">Cần chỉnh sửa</span></c:when>
                        <c:otherwise>                                 <span class="ins-status-badge ins-status-badge--archived">Đã lưu trữ</span></c:otherwise>
                    </c:choose>
                    <h1><c:out value="${course.title}"/></h1>
                </div>
                <div class="ins-detail-main__body">

                    <c:if test="${course.status == 'REJECTED' && not empty course.latestReviewComment}">
                        <div class="ins-alert ins-alert--error">
                            ❌ <strong>Lý do từ chối:</strong> <c:out value="${course.latestReviewComment}"/>
                        </div>
                    </c:if>

                    <h2>Thông tin chung</h2>
                    <table class="ins-info-table">
                        <tr>
                            <th>Danh mục</th>
                            <td><c:out value="${course.categoryName}" default="Chưa phân loại"/></td>
                        </tr>
                        <tr>
                            <th>Trình độ</th>
                            <td><c:choose>
                                <c:when test="${course.level=='BEGINNER'}">Cơ bản</c:when>
                                <c:when test="${course.level=='INTERMEDIATE'}">Trung cấp</c:when>
                                <c:when test="${course.level=='ADVANCED'}">Nâng cao</c:when>
                                <c:otherwise>Mọi trình độ</c:otherwise>
                            </c:choose></td>
                        </tr>
                        <tr>
                            <th>Học phí</th>
                            <td>
                                <c:choose>
                                    <c:when test="${course.price == 0}"><span style="color:#16A34A;font-weight:700">Miễn phí</span></c:when>
                                    <c:otherwise><fmt:formatNumber value="${course.price}" type="number" maxFractionDigits="0"/>đ</c:otherwise>
                                </c:choose>
                            </td>
                        </tr>
                        <tr>
                            <th>Phiên bản</th>
                            <td>v<c:out value="${course.versionNo}"/></td>
                        </tr>
                        <tr>
                            <th>Số bài học</th>
                            <td><strong>${course.lessonCount}</strong> bài học</td>
                        </tr>
                    </table>

                    <h2>Mô tả khóa học</h2>
                    <p class="ins-detail-desc"><c:out value="${course.description}" default="Chưa có mô tả."/></p>

                    <h2>Danh sách bài học (${course.lessonCount})</h2>
                    <c:choose>
                        <c:when test="${empty lessons}">
                            <div style="background:#FFFBEB; border:1.5px solid #FDE68A; border-radius:var(--r12); padding:16px 20px; margin-bottom:16px;">
                                <p style="margin:0 0 8px; font-weight:700; color:#B45309;">⚠️ Khóa học chưa có bài học nào!</p>
                                <p style="margin:0 0 12px; font-size:.85rem; color:#92400E;">Để gửi duyệt lên Admin, khóa học cần được tạo hoàn chỉnh và có ít nhất một bài học.</p>
                                <a class="ins-btn-primary" style="width:auto; display:inline-flex; padding:8px 16px; font-size:.85rem;"
                                   href="${pageContext.request.contextPath}/instructor/courses/${course.courseId}/lessons/new">
                                    ➕ Thêm bài học đầu tiên
                                </a>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="ins-lesson-list" style="margin-bottom:16px;">
                                <c:forEach var="les" items="${lessons}" varStatus="loop">
                                    <div class="ins-lesson-item" style="padding:12px 16px;">
                                        <div style="width:28px; height:28px; border-radius:50%; background:#DCFCE7; color:#15803D; display:flex; align-items:center; justify-content:center; font-weight:700; font-size:.8rem;">
                                            ${loop.index + 1}
                                        </div>
                                        <div style="flex:1;">
                                            <a href="${pageContext.request.contextPath}/instructor/courses/${course.courseId}/lessons/${les.lessonId}"
                                               style="font-weight:600; color:var(--ink); text-decoration:none;">
                                                <c:out value="${les.title}"/>
                                            </a>
                                            <c:if test="${empty les.content || les.content.trim().length() == 0}">
                                                <span style="font-size:.72rem; color:#DC2626; margin-left:8px; font-weight:600;">(Chưa có nội dung)</span>
                                            </c:if>
                                        </div>
                                        <a class="ins-link-btn" href="${pageContext.request.contextPath}/instructor/courses/${course.courseId}/lessons/${les.lessonId}" style="font-size:.8rem;">
                                            Chi tiết →
                                        </a>
                                    </div>
                                </c:forEach>
                            </div>
                            <div style="display:flex; gap:12px; flex-wrap:wrap;">
                                <a class="ins-btn-outline" style="width:auto; display:inline-flex;"
                                   href="${pageContext.request.contextPath}/instructor/courses/${course.courseId}/lessons">
                                    📋 Quản lý tất cả bài học →
                                </a>
                                <c:if test="${course.status == 'DRAFT' || course.status == 'REJECTED' || course.status == 'APPROVED' || course.status == 'PUBLISHED'}">
                                    <a class="ins-btn-outline" style="width:auto; display:inline-flex; color:#15803D; border-color:#86EFAC;"
                                       href="${pageContext.request.contextPath}/instructor/courses/${course.courseId}/lessons/new">
                                        ➕ Thêm bài học mới
                                    </a>
                                </c:if>
                            </div>
                        </c:otherwise>
                    </c:choose>

                    <!-- UC39 Link -->
                    <h2 style="margin-top:28px;">Học viên & Tiến độ học tập (UC39)</h2>
                    <div style="background:#F8FAFC; border:1px solid #E2E8F0; border-radius:var(--r12); padding:18px 22px; display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:12px; margin-bottom:16px;">
                        <div>
                            <div style="font-weight:700; color:var(--ink); font-size:1rem;">Theo dõi tiến độ học viên trong khóa</div>
                            <div style="font-size:.85rem; color:#64748B; margin-top:2px;">Xem danh sách học viên, tỷ lệ phần trăm hoàn thành, số bài học đã học và mốc truy cập.</div>
                        </div>
                        <a class="ins-btn-primary" style="width:auto; padding:9px 18px; font-size:.88rem; text-decoration:none;"
                           href="${pageContext.request.contextPath}/instructor/courses/${course.courseId}/students">
                            📊 Xem tiến độ học viên →
                        </a>
                    </div>

                </div>
            </div>

            <!-- Action aside -->
            <aside class="ins-aside">
                <div class="ins-aside__header">⚡ Bước tiếp theo</div>
                <div class="ins-aside__body">
                    <c:choose>
                        <c:when test="${course.status == 'DRAFT' || course.status == 'REJECTED'}">
                            <c:choose>
                                <c:when test="${course.readyForSubmit}">
                                    <p class="ins-aside__note" style="color:#15803D;">✅ Khóa học đã hoàn chỉnh (${course.lessonCount} bài học) và sẵn sàng gửi duyệt.</p>
                                    <form method="post" action="${pageContext.request.contextPath}/instructor/courses/${course.courseId}/submit" style="margin:0 0 12px 0;">
                                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                        <button class="ins-btn-primary" type="submit">📤 Gửi duyệt cho Admin</button>
                                    </form>
                                </c:when>
                                <c:otherwise>
                                    <p class="ins-aside__note" style="color:#B45309;">⚠️ Khóa học chưa hoàn chỉnh (${course.lessonCount == 0 ? 'chưa có bài học nào' : 'cần kiểm tra mô tả hoặc nội dung bài học'}). Hãy hoàn thiện trước khi gửi duyệt.</p>
                                    <button class="ins-btn-disabled" type="button" title="Cần có mô tả và ít nhất một bài học hoàn chỉnh để gửi duyệt" disabled>
                                        📤 Gửi duyệt (Chưa đủ điều kiện)
                                    </button>
                                    <div style="margin-top:10px;">
                                        <a class="ins-btn-outline" style="font-size:.82rem;"
                                           href="${pageContext.request.contextPath}/instructor/courses/${course.courseId}/lessons/new">
                                           ➕ Thêm bài học mới
                                        </a>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                            <div class="ins-aside__divider" style="margin:16px 0;"></div>
                            <a class="ins-btn-outline"
                               href="${pageContext.request.contextPath}/instructor/courses/${course.courseId}/edit">
                                ✏️ Chỉnh sửa thông tin
                            </a>
                        </c:when>

                        <c:when test="${course.status == 'SUBMITTED'}">
                            <p class="ins-aside__note">⏳ Đang chờ quản trị viên xem xét (${course.lessonCount} bài học). Bạn không thể chỉnh sửa lúc này.</p>
                        </c:when>

                        <c:when test="${course.status == 'APPROVED'}">
                            <c:choose>
                                <c:when test="${course.hidden}">
                                    <p class="ins-aside__note" style="color:#4B5563;">👁️ Khóa học đang <strong>tạm ẩn</strong> khỏi danh mục công khai. Học viên mới sẽ không tìm thấy khóa học này. Bạn có thể công bố lại bất cứ khi nào.</p>
                                    <form method="post" action="${pageContext.request.contextPath}/instructor/courses/${course.courseId}/publish" style="margin:0 0 12px 0;">
                                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                        <button class="ins-btn-primary" type="submit">🚀 Công bố lại khóa học</button>
                                    </form>
                                </c:when>
                                <c:otherwise>
                                    <p class="ins-aside__note" style="color:#15803D;">✅ Khóa học đã được duyệt! Hãy công bố để học viên có thể tìm thấy và đăng ký.</p>
                                    <form method="post" action="${pageContext.request.contextPath}/instructor/courses/${course.courseId}/publish" style="margin:0 0 12px 0;">
                                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                        <button class="ins-btn-primary" type="submit">🚀 Công bố khóa học</button>
                                    </form>
                                </c:otherwise>
                            </c:choose>
                            <div class="ins-aside__divider" style="margin:12px 0;"></div>
                            <a class="ins-btn-outline"
                               href="${pageContext.request.contextPath}/instructor/courses/${course.courseId}/edit">
                                ✏️ Chỉnh sửa thông tin
                            </a>
                        </c:when>

                        <c:when test="${course.status == 'PUBLISHED'}">
                            <p class="ins-aside__note">🌐 Khóa học đang được công khai cho học viên.</p>
                            <form method="post" action="${pageContext.request.contextPath}/instructor/courses/${course.courseId}/hide" style="margin:0 0 12px 0;">
                                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                <button class="ins-btn-warning" type="submit">👁️ Ẩn khóa học</button>
                            </form>
                            <div class="ins-aside__divider" style="margin:12px 0;"></div>
                            <a class="ins-btn-outline" style="margin-bottom:12px;"
                               href="${pageContext.request.contextPath}/instructor/courses/${course.courseId}/edit">
                                ✏️ Chỉnh sửa khóa học
                            </a>
                            <div class="ins-aside__divider" style="margin:12px 0;"></div>
                            <form method="post" action="${pageContext.request.contextPath}/instructor/courses/${course.courseId}/archive" style="margin:0;">
                                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                <button class="ins-btn-danger" type="submit">📦 Lưu trữ khóa học</button>
                            </form>
                        </c:when>

                        <c:otherwise>
                            <p class="ins-aside__note">📦 Khóa học đã được lưu trữ.</p>
                        </c:otherwise>
                    </c:choose>
                </div>
            </aside>
        </div>
    </main>
</div>
<script>
function toggleUserMenu(e){e.stopPropagation();e.currentTarget.closest('.hn-user-menu').classList.toggle('open');}
document.addEventListener('click',()=>document.querySelectorAll('.hn-user-menu.open').forEach(m=>m.classList.remove('open')));
</script>
</body></html>
