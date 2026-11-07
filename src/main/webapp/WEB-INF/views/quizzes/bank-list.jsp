<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Ngân hàng câu hỏi — EduSphere</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/home.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/instructor.css">
    <style>
        .bank-card {
            background: #fff;
            border: 1px solid #e5e7eb;
            border-radius: 12px;
            padding: 20px 24px;
            margin-bottom: 16px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            box-shadow: 0 1px 3px rgba(0,0,0,0.04);
            transition: transform 0.15s, box-shadow 0.15s;
        }
        .bank-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(0,0,0,0.08);
            border-color: #6366f1;
        }
        .bank-info h3 {
            margin: 0 0 6px;
            font-size: 1.15rem;
            font-weight: 700;
            color: #1f2937;
        }
        .bank-meta {
            font-size: 0.875rem;
            color: #6b7280;
            display: flex;
            gap: 16px;
            align-items: center;
            flex-wrap: wrap;
        }
        .bank-badge {
            display: inline-flex;
            align-items: center;
            padding: 3px 10px;
            border-radius: 9999px;
            font-size: 0.775rem;
            font-weight: 600;
            background: #e0e7ff;
            color: #4338ca;
        }
        .bank-actions {
            display: flex;
            gap: 10px;
            align-items: center;
        }
        /* Modal styling */
        .modal-overlay {
            display: none;
            position: fixed;
            top: 0; left: 0; right: 0; bottom: 0;
            background: rgba(0,0,0,0.45);
            z-index: 9999;
            align-items: center;
            justify-content: center;
            backdrop-filter: blur(2px);
        }
        .modal-overlay.active {
            display: flex;
        }
        .modal-box {
            background: #fff;
            border-radius: 16px;
            width: 100%;
            max-width: 520px;
            padding: 28px;
            box-shadow: 0 20px 25px -5px rgba(0,0,0,0.1), 0 10px 10px -5px rgba(0,0,0,0.04);
        }
        .form-group {
            margin-bottom: 16px;
        }
        .form-group label {
            display: block;
            margin-bottom: 6px;
            font-weight: 600;
            font-size: 0.9rem;
            color: #374151;
        }
        .form-control {
            width: 100%;
            padding: 10px 14px;
            border: 1px solid #d1d5db;
            border-radius: 8px;
            font-size: 0.95rem;
            box-sizing: border-box;
            outline: none;
            transition: border-color 0.2s;
        }
        .form-control:focus {
            border-color: #6366f1;
            box-shadow: 0 0 0 3px rgba(99,102,241,0.15);
        }
    </style>
</head>
<body>
<div class="ins-layout">
    <jsp:include page="../courses/ins-sidebar.jsp"/>
    <div class="ins-main-wrapper">
        <jsp:include page="../courses/ins-header.jsp"/>
        <main class="ins-page">
            <div class="ins-page-head">
                <div>
                    <span class="ins-page-head__eyebrow">📚 Ngân hàng đề & câu hỏi</span>
                    <h1 class="ins-page-head__title">Ngân hàng câu hỏi của tôi</h1>
                    <p style="color:#6b7280;margin:4px 0 0;font-size:0.92rem">
                        Tập trung quản lý kho câu hỏi, import từ Word/Excel/CSV, bốc ngẫu nhiên sinh đề siêu tốc.
                    </p>
                </div>
                <div>
                    <button type="button" class="ins-btn-primary" style="width:auto;padding:10px 22px" onclick="openCreateModal()">
                        + Tạo ngân hàng mới
                    </button>
                </div>
            </div>

            <c:if test="${not empty success}">
                <div class="ins-alert ins-alert--success" style="margin-bottom:20px">✅ <c:out value="${success}"/></div>
            </c:if>
            <c:if test="${not empty error}">
                <div class="ins-alert ins-alert--danger" style="margin-bottom:20px">❌ <c:out value="${error}"/></div>
            </c:if>

            <c:choose>
                <c:when test="${empty banks}">
                    <div class="ins-empty" style="padding:60px 20px;text-align:center">
                        <div class="ins-empty__icon" style="font-size:3rem">📑</div>
                        <h3 style="margin:16px 0 8px;font-size:1.25rem">Bạn chưa có ngân hàng câu hỏi nào</h3>
                        <p style="color:#6b7280;max-width:480px;margin:0 auto 20px">
                            Tạo một ngân hàng câu hỏi để lưu trữ các câu hỏi trắc nghiệm, tự luận, hình ảnh và tái sử dụng cho các bài kiểm tra.
                        </p>
                        <button type="button" class="ins-btn-primary" style="width:auto;margin:0 auto" onclick="openCreateModal()">
                            Tạo ngân hàng đầu tiên
                        </button>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="bank-list">
                        <c:forEach var="b" items="${banks}">
                            <div class="bank-card">
                                <div class="bank-info">
                                    <h3>
                                        <a href="${pageContext.request.contextPath}/instructor/question-banks/${b.bankId}" style="text-decoration:none;color:inherit">
                                            <c:out value="${b.name}"/>
                                        </a>
                                    </h3>
                                    <div class="bank-meta">
                                        <span class="bank-badge">
                                            📊 ${b.questionCount} câu hỏi
                                        </span>
                                        <c:if test="${b.course != null}">
                                            <span>Khóa học: <strong><c:out value="${b.course.title}"/></strong></span>
                                        </c:if>
                                        <c:if test="${not empty b.description}">
                                            <span style="max-width:300px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap">
                                                <c:out value="${b.description}"/>
                                            </span>
                                        </c:if>
                                    </div>
                                </div>
                                <div class="bank-actions">
                                    <a class="ins-link-btn ins-link-btn--primary"
                                       href="${pageContext.request.contextPath}/instructor/question-banks/${b.bankId}">
                                        Quản lý câu hỏi
                                    </a>
                                    <form method="post" action="${pageContext.request.contextPath}/instructor/question-banks/${b.bankId}/delete"
                                          onsubmit="return confirm('Bạn có chắc chắn muốn xóa ngân hàng này và toàn bộ câu hỏi bên trong?');" style="margin:0">
                                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                                        <button type="submit" class="ins-link-btn ins-link-btn--danger">Xóa</button>
                                    </form>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                </c:otherwise>
            </c:choose>
        </main>
    </div>
</div>

<%-- MODAL TẠO NGÂN HÀNG MỚI --%>
<div class="modal-overlay" id="createBankModal">
    <div class="modal-box">
        <h2 style="margin:0 0 16px;font-size:1.25rem;font-weight:700">Tạo Ngân hàng câu hỏi mới</h2>
        <form method="post" action="${pageContext.request.contextPath}/instructor/question-banks">
            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
            
            <div class="form-group">
                <label>Tên ngân hàng câu hỏi <span style="color:#ef4444">*</span></label>
                <input type="text" name="name" class="form-control" placeholder="VD: Ngân hàng Trắc nghiệm Lập trình Java..." required/>
            </div>

            <div class="form-group">
                <label>Liên kết khóa học (không bắt buộc)</label>
                <select name="courseId" class="form-control">
                    <option value="">-- Dùng chung cho mọi khóa học --</option>
                    <c:forEach var="c" items="${courses}">
                        <option value="${c.courseId}"><c:out value="${c.title}"/></option>
                    </c:forEach>
                </select>
            </div>

            <div class="form-group">
                <label>Mô tả ngân hàng</label>
                <textarea name="description" class="form-control" rows="3" placeholder="Ghi chú về phạm vi kiến thức, bộ câu hỏi..."></textarea>
            </div>

            <div style="display:flex;justify-content:flex-end;gap:12px;margin-top:24px">
                <button type="button" class="ins-link-btn" onclick="closeCreateModal()">Hủy bỏ</button>
                <button type="submit" class="ins-btn-primary" style="width:auto">Tạo ngân hàng</button>
            </div>
        </form>
    </div>
</div>

<script>
    function insToggleMenu(e) {
        e.stopPropagation();
        var m = document.getElementById('insUserMenu');
        if (m) m.classList.toggle('open');
    }
    document.addEventListener('click', function() {
        var m = document.getElementById('insUserMenu');
        if (m) m.classList.remove('open');
    });

    document.addEventListener('DOMContentLoaded', function() {
        var navItem = document.getElementById('nav-question-banks');
        if (navItem) navItem.classList.add('active');
    });

    function openCreateModal() {
        document.getElementById('createBankModal').classList.add('active');
    }
    function closeCreateModal() {
        document.getElementById('createBankModal').classList.remove('active');
    }
    document.getElementById('createBankModal').addEventListener('click', function(e) {
        if (e.target === this) closeCreateModal();
    });
</script>
</body>
</html>

