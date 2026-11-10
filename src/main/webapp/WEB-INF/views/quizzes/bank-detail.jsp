<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><c:out value="${bank.name}"/> — Ngân hàng câu hỏi</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/home.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/instructor.css">
    <style>
        .bank-header-box {
            background: #fff;
            border-radius: 12px;
            padding: 24px;
            border: 1px solid #e5e7eb;
            margin-bottom: 24px;
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            flex-wrap: wrap;
            gap: 16px;
        }
        .filter-bar {
            background: #fff;
            border-radius: 10px;
            padding: 14px 20px;
            border: 1px solid #e5e7eb;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 12px;
            flex-wrap: wrap;
        }
        .q-card {
            background: #fff;
            border-radius: 12px;
            border: 1px solid #e5e7eb;
            padding: 20px 24px;
            margin-bottom: 16px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.03);
            transition: border-color 0.15s;
        }
        .q-card:hover {
            border-color: #cbd5e1;
        }
        .q-top {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            margin-bottom: 12px;
            gap: 12px;
        }
        .q-badges {
            display: flex;
            gap: 8px;
            align-items: center;
            flex-wrap: wrap;
        }
        .badge {
            font-size: 0.75rem;
            font-weight: 700;
            padding: 3px 8px;
            border-radius: 6px;
            text-transform: uppercase;
        }
        .badge-type { background: #e0e7ff; color: #4338ca; }
        .badge-diff-EASY { background: #dcfce7; color: #15803d; }
        .badge-diff-MEDIUM { background: #fef9c3; color: #a16207; }
        .badge-diff-HARD { background: #fee2e2; color: #b91c1c; }
        .badge-score { background: #f1f5f9; color: #475569; }

        .q-content {
            font-size: 1.02rem;
            color: #1e293b;
            font-weight: 600;
            line-height: 1.5;
            margin-bottom: 14px;
        }
        .q-media-preview {
            max-width: 320px;
            max-height: 180px;
            border-radius: 8px;
            border: 1px solid #e2e8f0;
            margin-bottom: 12px;
            cursor: pointer;
            object-fit: cover;
        }
        .opt-list {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 8px 16px;
            margin-top: 10px;
        }
        @media (max-width: 768px) {
            .opt-list { grid-template-columns: 1fr; }
        }
        .opt-item {
            display: flex;
            align-items: center;
            gap: 8px;
            padding: 8px 12px;
            border-radius: 8px;
            background: #f8fafc;
            border: 1px solid #f1f5f9;
            font-size: 0.92rem;
            color: #334155;
        }
        .opt-item.correct {
            background: #ecfdf5;
            border-color: #a7f3d0;
            color: #065f46;
            font-weight: 600;
        }
        .q-explanation {
            margin-top: 12px;
            padding: 10px 14px;
            background: #f0f9ff;
            border-left: 4px solid #0284c7;
            border-radius: 4px;
            font-size: 0.88rem;
            color: #0369a1;
        }
        .q-essay-sample {
            margin-top: 12px;
            padding: 10px 14px;
            background: #fdf4ff;
            border-left: 4px solid #c026d3;
            border-radius: 4px;
            font-size: 0.88rem;
            color: #86198f;
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
        .modal-overlay.active { display: flex; }
        .modal-box {
            background: #fff;
            border-radius: 16px;
            width: 100%;
            max-width: 600px;
            padding: 28px;
            box-shadow: 0 20px 25px -5px rgba(0,0,0,0.1);
            max-height: 90vh;
            overflow-y: auto;
        }
        .form-group { margin-bottom: 16px; }
        .form-group label { display: block; margin-bottom: 6px; font-weight: 600; font-size: 0.9rem; color: #374151; }
        .form-control {
            width: 100%; padding: 10px 14px; border: 1px solid #d1d5db; border-radius: 8px; font-size: 0.95rem; box-sizing: border-box; outline: none;
        }
        .form-control:focus { border-color: #6366f1; box-shadow: 0 0 0 3px rgba(99,102,241,0.15); }
        .format-card {
            background: #f8fafc;
            border: 1px dashed #cbd5e1;
            border-radius: 10px;
            padding: 14px 16px;
            font-size: 0.85rem;
            color: #475569;
            margin-bottom: 16px;
        }
    </style>
</head>
<body>
<div class="ins-layout">
    <jsp:include page="../courses/ins-sidebar.jsp"/>
    <div class="ins-main-wrapper">
        <jsp:include page="../courses/ins-header.jsp"/>
        <main class="ins-page">
            <%-- Back link --%>
            <div style="margin-bottom:12px">
                <a href="${pageContext.request.contextPath}/instructor/question-banks" style="color:#6366f1;text-decoration:none;font-weight:600;font-size:0.9rem">
                    ← Quay lại danh sách ngân hàng
                </a>
            </div>

            <c:if test="${not empty success}">
                <div class="ins-alert ins-alert--success" style="margin-bottom:20px">✅ <c:out value="${success}"/></div>
            </c:if>
            <c:if test="${not empty warning}">
                <div class="ins-alert" style="background:#fffbeb;border:1px solid #fde68a;color:#b45309;margin-bottom:20px">
                    ⚠️ <c:out value="${warning}"/>
                </div>
            </c:if>
            <c:if test="${not empty error}">
                <div class="ins-alert ins-alert--danger" style="margin-bottom:20px">❌ <c:out value="${error}"/></div>
            </c:if>

            <%-- Bank Summary Header --%>
            <div class="bank-header-box">
                <div>
                    <span class="ins-page-head__eyebrow">📚 Ngân hàng câu hỏi</span>
                    <h1 style="margin:4px 0 8px;font-size:1.6rem;font-weight:800;color:#0f172a">
                        <c:out value="${bank.name}"/>
                    </h1>
                    <c:if test="${not empty bank.description}">
                        <p style="color:#64748b;margin:0 0 8px;font-size:0.95rem"><c:out value="${bank.description}"/></p>
                    </c:if>
                    <div style="display:flex;gap:16px;font-size:0.875rem;color:#64748b;align-items:center">
                        <span>Tổng số câu hỏi: <strong>${questions != null ? questions.size() : 0}</strong></span>
                        <c:if test="${bank.course != null}">
                            <span>Khóa học: <strong><c:out value="${bank.course.title}"/></strong></span>
                        </c:if>
                    </div>
                </div>
                <div style="display:flex;gap:10px;flex-wrap:wrap">
                    <c:if test="${bank.course != null}">
                        <a class="ins-btn-primary" style="background:#7e22ce;border-color:#7e22ce;width:auto;padding:9px 18px"
                           href="${pageContext.request.contextPath}/instructor/courses/${bank.course.courseId}/quizzes/new">
                            🚀 Tạo Quiz cho khóa này
                        </a>
                    </c:if>
                    <button type="button" class="ins-btn-primary" style="background:linear-gradient(135deg,#4f46e5,#7c3aed);border-color:#4f46e5" onclick="openAiRagModal()">
                        🤖 Tạo bằng AI (RAG)
                    </button>
                    <button type="button" class="ins-btn-primary" style="background:#059669;border-color:#059669" onclick="openImportModal()">
                        📥 Nhập từ tệp (Word/Excel/CSV)
                    </button>
                    <a class="ins-btn-primary" style="width:auto;padding:9px 18px"
                       href="${pageContext.request.contextPath}/instructor/question-banks/${bank.bankId}/questions/new">
                        + Thêm câu hỏi thủ công
                    </a>
                    <button type="button" class="ins-link-btn" onclick="openCategoryModal()">
                        + Thêm chuyên đề
                    </button>
                </div>
            </div>

            <%-- Filter Bar --%>
            <div class="filter-bar">
                <div style="display:flex;align-items:center;gap:12px">
                    <span style="font-weight:600;font-size:0.9rem;color:#475569">Chuyên đề:</span>
                    <select class="form-control" style="width:auto;padding:6px 12px;font-size:0.9rem"
                            onchange="location.href='${pageContext.request.contextPath}/instructor/question-banks/${bank.bankId}' + (this.value ? '?categoryId=' + this.value : '')">
                        <option value="">-- Tất cả chuyên đề --</option>
                        <c:forEach var="cat" items="${categories}">
                            <option value="${cat.categoryId}" <c:if test="${selectedCategoryId == cat.categoryId}">selected</c:if>>
                                <c:out value="${cat.name}"/>
                            </option>
                        </c:forEach>
                    </select>
                </div>
                <div style="font-size:0.875rem;color:#64748b">
                    Hiển thị <strong>${questions != null ? questions.size() : 0}</strong> câu hỏi
                </div>
            </div>

            <%-- Question List --%>
            <c:choose>
                <c:when test="${empty questions}">
                    <div class="ins-empty" style="padding:50px 20px;text-align:center">
                        <div class="ins-empty__icon" style="font-size:3rem">📝</div>
                        <h3 style="margin:16px 0 8px;font-size:1.2rem">Chưa có câu hỏi nào trong ngân hàng</h3>
                        <p style="color:#64748b;max-width:460px;margin:0 auto 20px">
                            Bạn có thể tải lên tệp Word (.docx) chứa câu hỏi có hình ảnh, bảng Excel (.xlsx), CSV hoặc tự soạn thảo thủ công.
                        </p>
                        <div style="display:flex;justify-content:center;gap:12px;flex-wrap:wrap">
                            <button type="button" class="ins-btn-primary" style="background:linear-gradient(135deg,#4f46e5,#7c3aed);border-color:#4f46e5;width:auto" onclick="openAiRagModal()">
                                🤖 Tạo câu hỏi bằng AI (RAG)
                            </button>
                            <button type="button" class="ins-btn-primary" style="background:#059669;border-color:#059669;width:auto" onclick="openImportModal()">
                                📥 Tải lên tệp Word / Excel / CSV
                            </button>
                            <a class="ins-btn-primary" style="width:auto"
                               href="${pageContext.request.contextPath}/instructor/question-banks/${bank.bankId}/questions/new">
                                + Thêm câu hỏi
                            </a>
                        </div>
                    </div>
                </c:when>
                <c:otherwise>
                    <c:forEach var="q" items="${questions}" varStatus="status">
                        <div class="q-card">
                            <div class="q-top">
                                <div class="q-badges">
                                    <span class="badge badge-score">#${status.index + 1}</span>
                                    <span class="badge badge-type">
                                        <c:choose>
                                            <c:when test="${q.type eq 'SINGLE_CHOICE'}">Trắc nghiệm đơn</c:when>
                                            <c:when test="${q.type eq 'MULTIPLE_CHOICE'}">Nhiều đáp án</c:when>
                                            <c:when test="${q.type eq 'TRUE_FALSE'}">Đúng / Sai</c:when>
                                            <c:when test="${q.type eq 'SHORT_ANSWER'}">Điền từ ngắn</c:when>
                                            <c:when test="${q.type eq 'ESSAY'}">Tự luận</c:when>
                                            <c:otherwise>${q.type}</c:otherwise>
                                        </c:choose>
                                    </span>
                                    <span class="badge badge-diff-${q.difficultyLevel}">
                                        <c:choose>
                                            <c:when test="${q.difficultyLevel eq 'EASY'}">Dễ</c:when>
                                            <c:when test="${q.difficultyLevel eq 'MEDIUM'}">Trung bình</c:when>
                                            <c:when test="${q.difficultyLevel eq 'HARD'}">Khó</c:when>
                                            <c:otherwise>${q.difficultyLevel}</c:otherwise>
                                        </c:choose>
                                    </span>
                                    <span class="badge badge-score"><fmt:formatNumber value="${q.defaultScore}" maxFractionDigits="2"/> điểm</span>
                                    <c:if test="${q.category != null}">
                                        <span class="badge" style="background:#f3e8ff;color:#7e22ce">📂 <c:out value="${q.category.name}"/></span>
                                    </c:if>
                                </div>
                                <div style="display:flex;gap:8px">
                                    <a class="ins-link-btn"
                                       href="${pageContext.request.contextPath}/instructor/question-banks/${bank.bankId}/questions/${q.bankQuestionId}/edit">
                                        Sửa
                                    </a>
                                    <form method="post" action="${pageContext.request.contextPath}/instructor/question-banks/${bank.bankId}/questions/${q.bankQuestionId}/delete"
                                          onsubmit="return confirm('Bạn có chắc muốn xóa câu hỏi này?');" style="margin:0">
                                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                                        <c:if test="${selectedCategoryId != null}">
                                            <input type="hidden" name="categoryId" value="${selectedCategoryId}"/>
                                        </c:if>
                                        <button type="submit" class="ins-link-btn ins-link-btn--danger">Xóa</button>
                                    </form>
                                </div>
                            </div>

                            <%-- Question Content --%>
                            <div class="q-content">
                                <c:out value="${q.content}"/>
                            </div>

                            <%-- Image thumbnail if present --%>
                            <c:if test="${not empty q.imageUrl}">
                                <div>
                                    <img src="${pageContext.request.contextPath}${q.imageUrl}" class="q-media-preview"
                                         alt="Hình ảnh câu hỏi" onclick="zoomImage(this.src)"/>
                                </div>
                            </c:if>

                            <%-- Video URL if present --%>
                            <c:if test="${not empty q.videoUrl}">
                                <div style="margin-bottom:10px;font-size:0.875rem">
                                    📹 Video đính kèm: <a href="<c:out value="${q.videoUrl}"/>" target="_blank" style="color:#6366f1"><c:out value="${q.videoUrl}"/></a>
                                </div>
                            </c:if>

                            <%-- Options for choice questions --%>
                            <c:if test="${q.type ne 'ESSAY' and q.type ne 'SHORT_ANSWER'}">
                                <div class="opt-list">
                                    <c:forEach var="opt" items="${q.options}" varStatus="optStatus">
                                        <div class="opt-item <c:if test="${opt.correct}">correct</c:if>">
                                            <strong>${optStatus.index == 0 ? 'A' : (optStatus.index == 1 ? 'B' : (optStatus.index == 2 ? 'C' : (optStatus.index == 3 ? 'D' : (optStatus.index == 4 ? 'E' : 'F'))))}.</strong>
                                            <span><c:out value="${opt.content}"/></span>
                                            <c:if test="${opt.correct}">
                                                <span style="margin-left:auto;font-size:1rem">✓</span>
                                            </c:if>
                                        </div>
                                    </c:forEach>
                                </div>
                            </c:if>

                            <%-- Essay sample answer --%>
                            <c:if test="${q.type eq 'ESSAY' and not empty q.sampleEssayAnswer}">
                                <div class="q-essay-sample">
                                    <strong>💡 Gợi ý chấm bài / Đáp án mẫu:</strong><br/>
                                    <c:out value="${q.sampleEssayAnswer}"/>
                                </div>
                            </c:if>

                            <%-- Explanation --%>
                            <c:if test="${not empty q.explanation}">
                                <div class="q-explanation">
                                    <strong>📖 Giải thích đáp án:</strong> <c:out value="${q.explanation}"/>
                                </div>
                            </c:if>
                        </div>
                    </c:forEach>
                </c:otherwise>
            </c:choose>
        </main>
    </div>
</div>

<%-- MODAL IMPORT TỆP (WORD / EXCEL / CSV) --%>
<div class="modal-overlay" id="importModal">
    <div class="modal-box">
        <h2 style="margin:0 0 12px;font-size:1.3rem;font-weight:700">Tải lên tệp câu hỏi</h2>
        <p style="color:#64748b;font-size:0.88rem;margin:0 0 16px">
            Hỗ trợ định dạng Word (<strong>.docx</strong>), Excel (<strong>.xlsx, .xls</strong>), và <strong>.csv</strong>. Tự động nhận diện câu hỏi, đáp án, giải thích và trích xuất hình ảnh nhúng.
        </p>

        <div class="format-card">
            <strong>📋 Quy cách soạn thảo được hỗ trợ:</strong>
            <ul style="margin:6px 0 0 18px;padding:0;line-height:1.6">
                <li><strong>Word (.docx):</strong> Soạn dạng <code>Câu 1: Nội dung...</code>, các dòng <code>A. ...</code>, <code>B. ...</code>, dòng đáp án <code>Đáp án: A</code>, lời giải <code>Lời giải: ...</code>. Đối với tự luận ghi <code>[Tự luận]</code> ở đầu câu. Hình ảnh dán trực tiếp vào file Word sẽ tự động được tải lên.</li>
                <li><strong>Excel / CSV:</strong> Các cột <code>Content</code>, <code>OptionA</code>, <code>OptionB</code>, <code>OptionC</code>, <code>OptionD</code>, <code>CorrectAnswer</code>, <code>Explanation</code>, <code>Type</code>, <code>Difficulty</code>, <code>Score</code>.</li>
            </ul>
            <div style="margin-top:10px;display:flex;gap:16px;flex-wrap:wrap">
                <a href="${pageContext.request.contextPath}/instructor/question-banks/sample/word" style="color:#2563eb;font-weight:700;text-decoration:none">
                    📄 Tải tệp mẫu Word chuẩn (.docx)
                </a>
                <a href="${pageContext.request.contextPath}/instructor/question-banks/sample/csv" style="color:#6366f1;font-weight:600;text-decoration:none">
                    📊 Tải tệp mẫu CSV chuẩn (.csv)
                </a>
            </div>
        </div>

        <form method="post" action="${pageContext.request.contextPath}/instructor/question-banks/${bank.bankId}/import" enctype="multipart/form-data">
            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>

            <%-- CHỌN HOẶC TẠO CHUYÊN ĐỀ ĐỂ LƯU CÂU HỎI VÀO --%>
            <div class="form-group" style="margin-top:16px;margin-bottom:16px">
                <label style="display:flex;align-items:center;justify-content:space-between;font-size:0.88rem;font-weight:700;color:#1e293b;margin-bottom:6px">
                    <span>📁 Lưu vào Chuyên đề (Tùy chọn):</span>
                    <button type="button" id="btnToggleNewCat" onclick="toggleNewCategoryInput()"
                            style="background:none;border:none;color:#2563eb;font-size:0.82rem;font-weight:700;cursor:pointer;padding:0;text-decoration:none;display:inline-flex;align-items:center;gap:4px">
                        ➕ Tạo chuyên đề mới
                    </button>
                </label>

                <!-- Dropdown chọn chuyên đề có sẵn -->
                <div id="existingCategoryGroup">
                    <select name="categoryId" id="importCategorySelect" class="form-control" style="font-size:0.9rem;padding:9px 12px;background:#f8fafc">
                        <option value="">-- Để trống (Lưu vào chung toàn bộ ngân hàng) --</option>
                        <c:forEach var="cat" items="${categories}">
                            <option value="${cat.categoryId}" ${selectedCategoryId == cat.categoryId ? 'selected' : ''}>
                                📁 <c:out value="${cat.name}"/>
                            </option>
                        </c:forEach>
                    </select>
                </div>

                <!-- Input nhập chuyên đề mới khi cần -->
                <div id="newCategoryGroup" style="display:none;margin-top:6px">
                    <div style="display:flex;gap:8px;align-items:center">
                        <input type="text" name="newCategoryName" id="newCategoryNameInput" class="form-control"
                               placeholder="Nhập tên chuyên đề mới (VD: Chương 2: Động học chất điểm)..."
                               style="font-size:0.9rem;padding:9px 12px;border-color:#2563eb;background:#eff6ff"/>
                        <button type="button" onclick="cancelNewCategoryInput()" class="ins-link-btn" style="padding:9px 12px;white-space:nowrap;font-size:0.84rem">
                            ✕ Hủy
                        </button>
                    </div>
                    <span style="font-size:0.78rem;color:#2563eb;margin-top:4px;display:block">
                        ✨ Hệ thống sẽ tự động tạo mới chuyên đề này và gán toàn bộ câu hỏi tải lên vào đó.
                    </span>
                </div>

                <span style="font-size:0.78rem;color:#64748b;margin-top:4px;display:block">
                    💡 Giúp bạn tự động phân loại kiến thức theo chuyên đề để dễ dàng trích xuất đề thi sau này.
                </span>
            </div>

            <div class="form-group">
                <label style="font-weight:700;font-size:0.88rem;color:#1e293b;margin-bottom:6px">Chọn tệp từ máy tính <span style="color:#ef4444">*</span></label>
                <input type="file" name="file" class="form-control" accept=".docx,.xlsx,.xls,.csv" required/>
            </div>

            <div style="display:flex;justify-content:flex-end;gap:12px;margin-top:24px">
                <button type="button" class="ins-link-btn" onclick="closeImportModal()">Hủy</button>
                <button type="submit" class="ins-btn-primary" style="background:#059669;border-color:#059669;width:auto">
                    Bắt đầu tải lên & Lưu
                </button>
            </div>
        </form>
    </div>
</div>

<%-- MODAL THÊM CHUYÊN ĐỀ --%>
<div class="modal-overlay" id="categoryModal">
    <div class="modal-box" style="max-width:440px">
        <h2 style="margin:0 0 16px;font-size:1.2rem;font-weight:700">Thêm Chuyên đề mới</h2>
        <form method="post" action="${pageContext.request.contextPath}/instructor/question-banks/${bank.bankId}/categories">
            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>

            <div class="form-group">
                <label>Tên chuyên đề <span style="color:#ef4444">*</span></label>
                <input type="text" name="name" class="form-control" placeholder="VD: Chương 1 - Biến và Kiểu dữ liệu" required/>
            </div>

            <div class="form-group">
                <label>Mô tả ngắn</label>
                <textarea name="description" class="form-control" rows="2" placeholder="Ghi chú về chuyên đề..."></textarea>
            </div>

            <div style="display:flex;justify-content:flex-end;gap:12px;margin-top:20px">
                <button type="button" class="ins-link-btn" onclick="closeCategoryModal()">Hủy</button>
                <button type="submit" class="ins-btn-primary" style="width:auto">Thêm chuyên đề</button>
            </div>
        </form>
    </div>
</div>

<%-- MODAL TẠO CÂU HỎI BẰNG AI (RAG) & KIỂM DUYỆT CỦA GIẢNG VIÊN --%>
<div class="modal-overlay" id="aiRagModal">
    <div class="modal-box" style="max-width:740px">
        <div style="display:flex;justify-content:space-between;align-items:flex-start;gap:12px;margin-bottom:10px">
            <div>
                <h2 style="margin:0 0 4px;font-size:1.3rem;font-weight:800;color:#0f172a">
                    🤖 Tạo câu hỏi bằng AI theo cơ chế RAG
                </h2>
                <p style="color:#64748b;font-size:0.86rem;margin:0">
                    Hệ thống tự động phân đoạn (Chunking) &amp; truy xuất các đoạn kiến thức liên quan nhất (Top-K Retrieval) từ bài giảng/tài liệu, sau đó gọi Model AI qua API Key để sinh bản nháp cho <strong>Giảng viên kiểm duyệt cuối cùng</strong>.
                </p>
            </div>
        </div>

        <form method="post"
              action="${pageContext.request.contextPath}/instructor/question-banks/${bank.bankId}/ai-generate"
              enctype="multipart/form-data"
              onsubmit="document.getElementById('aiSubmitBtn').disabled=true; document.getElementById('aiSubmitBtn').textContent='⏳ Đang truy xuất RAG & gọi Model AI...';">
            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>

            <%-- KHỐI 1: CẤU HÌNH MODEL & API KEY --%>
            <div style="background:#f8fafc;border:1px solid #e2e8f0;border-radius:12px;padding:14px 16px;margin-bottom:16px">
                <div style="font-size:0.84rem;font-weight:800;color:#334155;margin-bottom:10px;text-transform:uppercase;letter-spacing:0.04em">
                    🔑 1. Cấu hình Model AI &amp; API Key
                </div>
                <div style="display:grid;grid-template-columns:1fr 1.4fr;gap:12px">
                    <div>
                        <label style="display:block;font-size:0.82rem;font-weight:700;color:#374151;margin-bottom:4px">Model AI</label>
                        <select name="aiModel" class="form-control" style="padding:8px 10px;font-size:0.88rem">
                            <option value="gemini-2.5-flash" ${empty savedAiModel or savedAiModel == 'gemini-2.5-flash' or savedAiModel == 'gemini-2.0-flash' ? 'selected' : ''}>Google Gemini 2.5 Flash (Khuyên dùng)</option>
                            <option value="gemini-3-flash-preview" ${savedAiModel == 'gemini-3-flash-preview' ? 'selected' : ''}>Google Gemini 3 Flash Preview</option>
                            <option value="gpt-4o-mini" ${savedAiModel == 'gpt-4o-mini' ? 'selected' : ''}>OpenAI GPT-4o mini</option>
                            <option value="llama-3.3-70b-versatile" ${savedAiModel == 'llama-3.3-70b-versatile' ? 'selected' : ''}>Groq Llama 3.3 70B</option>
                        </select>
                    </div>
                    <div>
                        <label style="display:block;font-size:0.82rem;font-weight:700;color:#374151;margin-bottom:4px">
                            🔒 API Key (Đã khóa cứng mặc định hệ thống)
                        </label>
                        <input type="password" name="apiKey" class="form-control"
                               style="padding:8px 10px;font-size:0.88rem;background:#f1f5f9;color:#475569;cursor:not-allowed"
                               value="AIzaSyD1oB9-36bcsb463dN8q7JFSl5tMVvdM04"
                               readonly/>
                    </div>
                </div>
                <div style="font-size:0.76rem;color:#64748b;margin-top:6px">
                    💡 Hệ thống đã khóa cứng API Key Google Gemini mặc định trên server — giảng viên có thể bấm sinh câu hỏi ngay mà không cần nhập key.
                </div>
            </div>

            <%-- KHỐI 2: NGUỒN TRI THỨC ĐẦU VÀO CHO RAG --%>
            <div style="background:#eff6ff;border:1px solid #bfdbfe;border-radius:12px;padding:14px 16px;margin-bottom:16px">
                <div style="font-size:0.84rem;font-weight:800;color:#1e40af;margin-bottom:10px;text-transform:uppercase;letter-spacing:0.04em">
                    📚 2. Nguồn tri thức RAG (Chọn 1 hoặc kết hợp nhiều nguồn)
                </div>

                <div class="form-group" style="margin-bottom:12px">
                    <label style="font-size:0.84rem">Nguồn A — Trích xuất từ Khóa học &amp; Bài giảng trong hệ thống:</label>
                    <select name="sourceCourseId" id="ragCourseSelect" class="form-control"
                            style="padding:8px 12px;font-size:0.88rem;background:#fff"
                            onchange="loadLessonsForRagCourse(this.value)">
                        <option value="">-- Không lấy từ khóa học (Chỉ dùng tệp / văn bản bên dưới) --</option>
                        <c:forEach var="c" items="${courses}">
                            <option value="${c.courseId}" ${bank.course != null and bank.course.courseId == c.courseId ? 'selected' : ''}>
                                📘 <c:out value="${c.title}"/>
                            </option>
                        </c:forEach>
                    </select>

                    <div id="ragLessonsBox" style="margin-top:8px;max-height:130px;overflow-y:auto;background:#fff;border:1px solid #cbd5e1;border-radius:8px;padding:8px 12px;font-size:0.84rem">
                        <c:choose>
                            <c:when test="${not empty bankLessons}">
                                <div style="font-weight:700;color:#334155;margin-bottom:4px">Chọn bài học làm ngữ cảnh RAG (Để trống = Lấy toàn bộ khóa học):</div>
                                <c:forEach var="ls" items="${bankLessons}">
                                    <label style="display:flex;align-items:center;gap:8px;font-weight:500;margin:4px 0;cursor:pointer">
                                        <input type="checkbox" name="lessonIds" value="${ls.lessonId}" checked/>
                                        <span>Bài ${ls.orderIndex}: <c:out value="${ls.title}"/></span>
                                    </label>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <span style="color:#64748b">Chọn một khóa học ở trên để hiển thị danh sách bài giảng.</span>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>

                <div class="form-group" style="margin-bottom:12px">
                    <label style="font-size:0.84rem">Nguồn B — Đính kèm tệp giáo trình / tài liệu (.docx, .txt, .md):</label>
                    <input type="file" name="documentFile" class="form-control" accept=".docx,.txt,.md,.csv"
                           style="padding:7px 10px;font-size:0.85rem;background:#fff"/>
                </div>

                <div class="form-group" style="margin-bottom:0">
                    <label style="font-size:0.84rem">Nguồn C — Dán trực tiếp nội dung bài giảng / kiến thức trọng tâm:</label>
                    <textarea name="customContext" class="form-control" rows="3"
                              style="font-size:0.86rem;background:#fff"
                              placeholder="Dán nội dung giáo trình, định nghĩa, công thức hoặc đoạn văn bản cần tạo câu hỏi vào đây..."></textarea>
                </div>
            </div>

            <%-- KHỐI 3: TRUY VẤN RAG & CẤU HÌNH CÂU HỎI --%>
            <div style="background:#fff;border:1px solid #e2e8f0;border-radius:12px;padding:14px 16px;margin-bottom:16px">
                <div style="font-size:0.84rem;font-weight:800;color:#334155;margin-bottom:10px;text-transform:uppercase;letter-spacing:0.04em">
                    🎯 3. Truy vấn trọng tâm (RAG Query) &amp; Cấu hình câu hỏi
                </div>

                <div class="form-group" style="margin-bottom:12px">
                    <label style="font-size:0.84rem">Chủ đề / Trọng tâm cần tập trung (Dùng để RAG xếp hạng &amp; lọc Top-K đoạn văn bản sát nhất):</label>
                    <input type="text" name="topicPrompt" class="form-control"
                           style="padding:8px 12px;font-size:0.88rem"
                           placeholder="VD: Tập trung vào Dependency Injection, @Transactional và phân quyền Spring Security..."/>
                </div>

                <div style="display:grid;grid-template-columns:1fr 1fr 1fr;gap:10px;margin-bottom:12px">
                    <div>
                        <label style="display:block;font-size:0.8rem;font-weight:700;color:#374151;margin-bottom:4px">Số lượng câu</label>
                        <input type="number" name="questionCount" class="form-control" value="5" min="1" max="20"
                               style="padding:8px 10px;font-size:0.88rem" required/>
                    </div>
                    <div>
                        <label style="display:block;font-size:0.8rem;font-weight:700;color:#374151;margin-bottom:4px">Loại câu hỏi</label>
                        <select name="questionType" class="form-control" style="padding:8px 10px;font-size:0.88rem">
                            <option value="SINGLE_CHOICE">Trắc nghiệm 1 đáp án</option>
                            <option value="MIXED">Kết hợp đa dạng</option>
                            <option value="MULTIPLE_CHOICE">Nhiều đáp án đúng</option>
                            <option value="TRUE_FALSE">Đúng / Sai</option>
                            <option value="ESSAY">Tự luận kèm đáp án mẫu</option>
                        </select>
                    </div>
                    <div>
                        <label style="display:block;font-size:0.8rem;font-weight:700;color:#374151;margin-bottom:4px">Độ khó</label>
                        <select name="difficulty" class="form-control" style="padding:8px 10px;font-size:0.88rem">
                            <option value="MIXED">Phân bổ Dễ - TB - Khó</option>
                            <option value="EASY">Dễ (Easy)</option>
                            <option value="MEDIUM">Trung bình (Medium)</option>
                            <option value="HARD">Khó (Hard)</option>
                        </select>
                    </div>
                </div>

                <div>
                    <label style="display:block;font-size:0.82rem;font-weight:700;color:#374151;margin-bottom:4px">Lưu vào Chuyên đề sau khi duyệt:</label>
                    <div style="display:grid;grid-template-columns:1fr 1fr;gap:10px">
                        <select name="categoryId" class="form-control" style="padding:8px 10px;font-size:0.86rem">
                            <option value="">-- Chung toàn bộ ngân hàng --</option>
                            <c:forEach var="cat" items="${categories}">
                                <option value="${cat.categoryId}" ${selectedCategoryId == cat.categoryId ? 'selected' : ''}>
                                    📁 <c:out value="${cat.name}"/>
                                </option>
                            </c:forEach>
                        </select>
                        <input type="text" name="newCategoryName" class="form-control"
                               style="padding:8px 10px;font-size:0.86rem"
                               placeholder="Hoặc nhập tên chuyên đề mới..."/>
                    </div>
                </div>
            </div>

            <div style="display:flex;justify-content:space-between;align-items:center;gap:12px;margin-top:16px">
                <span style="font-size:0.8rem;color:#475569">
                    🛡️ <strong>An toàn:</strong> Câu hỏi sinh ra sẽ mở ở màn hình <strong>Kiểm duyệt nháp</strong> để bạn sửa và duyệt trước khi lưu.
                </span>
                <div style="display:flex;gap:10px">
                    <button type="button" class="ins-link-btn" onclick="closeAiRagModal()">Hủy</button>
                    <button type="submit" id="aiSubmitBtn" class="ins-btn-primary"
                            style="background:linear-gradient(135deg,#4f46e5,#7c3aed);border-color:#4f46e5;width:auto;white-space:nowrap">
                        ✨ Sinh câu hỏi nháp &amp; Kiểm duyệt
                    </button>
                </div>
            </div>
        </form>
    </div>
</div>

<%-- ZOOM IMAGE MODAL --%>
<div class="modal-overlay" id="imageZoomModal" onclick="closeZoomModal()">
    <div style="position:relative;max-width:90vw;max-height:90vh">
        <img id="zoomedImg" src="" style="max-width:90vw;max-height:90vh;border-radius:12px;box-shadow:0 25px 50px -12px rgba(0,0,0,0.5)"/>
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
        if (window.location.search.indexOf('openAi=true') !== -1) {
            openAiRagModal();
        }
    });

    function openImportModal() { document.getElementById('importModal').classList.add('active'); }
    function closeImportModal() { 
        document.getElementById('importModal').classList.remove('active'); 
        cancelNewCategoryInput();
    }
    function openCategoryModal() { document.getElementById('categoryModal').classList.add('active'); }
    function closeCategoryModal() { document.getElementById('categoryModal').classList.remove('active'); }
    function openAiRagModal() { document.getElementById('aiRagModal').classList.add('active'); }
    function closeAiRagModal() { document.getElementById('aiRagModal').classList.remove('active'); }

    function loadLessonsForRagCourse(courseId) {
        var box = document.getElementById('ragLessonsBox');
        if (!box) return;
        if (!courseId) {
            box.innerHTML = '<span style="color:#64748b">Chọn một khóa học ở trên để hiển thị danh sách bài giảng.</span>';
            return;
        }
        box.innerHTML = '<span style="color:#6366f1">Đang tải danh sách bài giảng...</span>';
        fetch('${pageContext.request.contextPath}/instructor/question-banks/api/courses/' + courseId + '/lessons')
            .then(function(r) { return r.json(); })
            .then(function(list) {
                if (!list || list.length === 0) {
                    box.innerHTML = '<span style="color:#64748b">Khóa học này chưa có bài giảng nào.</span>';
                    return;
                }
                var html = '<div style="font-weight:700;color:#334155;margin-bottom:4px">Chọn bài học làm ngữ cảnh RAG:</div>';
                list.forEach(function(ls, idx) {
                    html += '<label style="display:flex;align-items:center;gap:8px;font-weight:500;margin:4px 0;cursor:pointer">'
                        + '<input type="checkbox" name="lessonIds" value="' + ls.lessonId + '" checked/>'
                        + '<span>Bài ' + (idx + 1) + ': ' + ls.title + '</span>'
                        + '</label>';
                });
                box.innerHTML = html;
            })
            .catch(function() {
                box.innerHTML = '<span style="color:#ef4444">Không thể tải danh sách bài học.</span>';
            });
    }

    function toggleNewCategoryInput() {
        var newGrp = document.getElementById('newCategoryGroup');
        var existGrp = document.getElementById('existingCategoryGroup');
        var select = document.getElementById('importCategorySelect');
        var input = document.getElementById('newCategoryNameInput');
        var btn = document.getElementById('btnToggleNewCat');

        if (newGrp.style.display === 'none') {
            newGrp.style.display = 'block';
            existGrp.style.display = 'none';
            if (select) select.value = '';
            btn.textContent = '◀ Chọn chuyên đề có sẵn';
            input.focus();
        } else {
            cancelNewCategoryInput();
        }
    }

    function cancelNewCategoryInput() {
        var newGrp = document.getElementById('newCategoryGroup');
        var existGrp = document.getElementById('existingCategoryGroup');
        var input = document.getElementById('newCategoryNameInput');
        var btn = document.getElementById('btnToggleNewCat');

        if (newGrp) newGrp.style.display = 'none';
        if (existGrp) existGrp.style.display = 'block';
        if (input) input.value = '';
        if (btn) btn.textContent = '➕ Tạo chuyên đề mới';
    }

    function zoomImage(src) {
        document.getElementById('zoomedImg').src = src;
        document.getElementById('imageZoomModal').classList.add('active');
    }
    function closeZoomModal() {
        document.getElementById('imageZoomModal').classList.remove('active');
    }

    document.querySelectorAll('.modal-overlay').forEach(modal => {
        modal.addEventListener('click', function(e) {
            if (e.target === this) this.classList.remove('active');
        });
    });
</script>
</body>
</html>

