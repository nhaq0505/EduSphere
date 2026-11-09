<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Kiểm duyệt câu hỏi AI (RAG) — <c:out value="${bank.name}"/></title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/home.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/instructor.css">
    <style>
        .rag-banner {
            background: linear-gradient(135deg, #EEF2FF 0%, #F5F3FF 100%);
            border: 1.5px solid #C7D2FE;
            border-radius: 14px;
            padding: 20px 24px;
            margin-bottom: 20px;
        }
        .rag-chunks-box {
            background: #FFFFFF;
            border: 1px solid #E2E8F0;
            border-radius: 12px;
            padding: 16px 20px;
            margin-bottom: 22px;
        }
        .rag-chunk-item {
            background: #F8FAFC;
            border: 1px solid #E2E8F0;
            border-left: 4px solid #6366F1;
            border-radius: 8px;
            padding: 12px 14px;
            margin-top: 10px;
            font-size: 0.85rem;
            color: #334155;
            line-height: 1.55;
            white-space: pre-line;
        }
        .draft-card {
            background: #FFFFFF;
            border: 2px solid #A5B4FC;
            border-radius: 14px;
            padding: 20px 24px;
            margin-bottom: 18px;
            box-shadow: 0 2px 6px rgba(15, 23, 42, 0.04);
            transition: all 0.15s;
        }
        .draft-card.unchecked {
            border-color: #E2E8F0;
            background: #F8FAFC;
            opacity: 0.65;
        }
        .draft-head {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 12px;
            flex-wrap: wrap;
            padding-bottom: 12px;
            margin-bottom: 14px;
            border-bottom: 1px solid #F1F5F9;
        }
        .draft-citation {
            background: #EFF6FF;
            border: 1px solid #BFDBFE;
            color: #1E40AF;
            border-radius: 8px;
            padding: 8px 12px;
            font-size: 0.8rem;
            margin-bottom: 14px;
        }
        .rv-label {
            display: block;
            font-size: 0.8rem;
            font-weight: 700;
            color: #334155;
            margin-bottom: 4px;
        }
        .rv-input {
            width: 100%;
            box-sizing: border-box;
            padding: 8px 12px;
            border: 1px solid #CBD5E1;
            border-radius: 8px;
            font: inherit;
            font-size: 0.88rem;
            color: #0F172A;
            background: #FFFFFF;
        }
        .rv-input:focus {
            outline: none;
            border-color: #4F46E5;
            box-shadow: 0 0 0 3px rgba(79, 70, 229, 0.12);
        }
        .sticky-approve-bar {
            position: sticky;
            bottom: 16px;
            background: #0F172A;
            color: #FFFFFF;
            border-radius: 14px;
            padding: 14px 22px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 16px;
            flex-wrap: wrap;
            box-shadow: 0 12px 28px rgba(15, 23, 42, 0.25);
            z-index: 50;
        }
    </style>
</head>
<body>
<div class="ins-layout">
    <jsp:include page="../courses/ins-sidebar.jsp"/>
    <div class="ins-main-wrapper">
        <jsp:include page="../courses/ins-header.jsp"/>
        <main class="ins-page">
            <div style="margin-bottom:12px">
                <a href="${pageContext.request.contextPath}/instructor/question-banks/${bank.bankId}"
                   style="color:#6366f1;text-decoration:none;font-weight:600;font-size:0.9rem">
                    ← Hủy &amp; Quay lại ngân hàng câu hỏi (<c:out value="${bank.name}"/>)
                </a>
            </div>

            <%-- Banner thông báo cơ chế Kiểm duyệt cuối của Giảng viên --%>
            <div class="rag-banner">
                <div style="display:flex;justify-content:space-between;align-items:flex-start;gap:16px;flex-wrap:wrap">
                    <div>
                        <span style="display:inline-block;padding:3px 10px;border-radius:999px;background:#4F46E5;color:#fff;font-size:0.72rem;font-weight:800;letter-spacing:0.06em;margin-bottom:6px">
                            🤖 AI RAG + GIẢNG VIÊN KIỂM DUYỆT CUỐI
                        </span>
                        <h1 style="margin:0 0 6px;font-size:1.45rem;font-weight:800;color:#0F172A">
                            Kiểm duyệt &amp; Chỉnh sửa câu hỏi do AI đề xuất
                        </h1>
                        <p style="margin:0;font-size:0.88rem;color:#475569;line-height:1.55">
                            Model <strong><c:out value="${ragResult.modelUsed}"/></strong> đã sinh <strong>${ragResult.draftQuestions.size()} câu hỏi nháp</strong> dựa trên <strong>${ragResult.retrievedChunks.size()} đoạn ngữ cảnh RAG</strong>.
                            Các câu hỏi này <strong>chưa được lưu vào Ngân hàng</strong> — bạn có toàn quyền chỉnh sửa nội dung, đáp án hoặc loại bỏ câu chưa đạt trước khi phê duyệt.
                        </p>
                    </div>
                </div>
            </div>

            <%-- Khối hiển thị các đoạn ngữ cảnh RAG đã được truy xuất (Retrieved Context Chunks) --%>
            <div class="rag-chunks-box">
                <details>
                    <summary style="cursor:pointer;font-weight:800;font-size:0.92rem;color:#1E293B;display:flex;align-items:center;justify-content:space-between">
                        <span>🔍 Xem ${ragResult.retrievedChunks.size()} đoạn ngữ cảnh RAG đã truy xuất từ bài giảng/tài liệu (Bấm để mở rộng)</span>
                        <span style="font-size:0.78rem;color:#4F46E5;font-weight:700">Top-K BM25 Context</span>
                    </summary>
                    <div style="margin-top:10px">
                        <c:forEach var="chunk" items="${ragResult.retrievedChunks}" varStatus="cs">
                            <div class="rag-chunk-item">
                                <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:4px;font-weight:700;color:#1E40AF;font-size:0.8rem">
                                    <span>[Nguồn #${cs.index + 1}] <c:out value="${chunk.sourceTitle}"/></span>
                                    <span>Điểm khớp RAG: ${chunk.relevanceScore}</span>
                                </div>
                                <div><c:out value="${chunk.content}"/></div>
                            </div>
                        </c:forEach>
                    </div>
                </details>
            </div>

            <%-- FORM KIỂM DUYỆT VÀ LƯU CÂU HỎI --%>
            <form method="post" action="${pageContext.request.contextPath}/instructor/question-banks/${bank.bankId}/ai-approve" id="approveForm">
                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>

                <%-- Chọn chuyên đề lưu trữ và nút chọn/bỏ chọn nhanh --%>
                <div style="background:#fff;border:1px solid #E2E8F0;border-radius:12px;padding:14px 20px;margin-bottom:18px;display:flex;align-items:center;justify-content:space-between;gap:14px;flex-wrap:wrap">
                    <div style="display:flex;align-items:center;gap:10px;flex-wrap:wrap">
                        <span style="font-size:0.86rem;font-weight:700;color:#334155">📁 Lưu vào chuyên đề:</span>
                        <select name="categoryId" class="rv-input" style="width:auto;min-width:200px">
                            <option value="">-- Chung toàn bộ ngân hàng --</option>
                            <c:forEach var="cat" items="${categories}">
                                <option value="${cat.categoryId}" ${ragResult.targetCategoryId == cat.categoryId ? 'selected' : ''}>
                                    <c:out value="${cat.name}"/>
                                </option>
                            </c:forEach>
                        </select>
                        <input type="text" name="newCategoryName" class="rv-input"
                               style="width:220px"
                               value="<c:out value='${ragResult.newCategoryName}'/>"
                               placeholder="Hoặc tạo chuyên đề mới..."/>
                    </div>

                    <div style="display:flex;gap:8px">
                        <button type="button" class="ins-link-btn" onclick="toggleAllApprove(true)">☑️ Chọn duyệt tất cả</button>
                        <button type="button" class="ins-link-btn" onclick="toggleAllApprove(false)">⬜ Bỏ chọn tất cả</button>
                    </div>
                </div>

                <%-- Danh sách từng câu hỏi nháp để Giảng viên chỉnh sửa & phê duyệt --%>
                <c:forEach var="q" items="${ragResult.draftQuestions}" varStatus="st">
                    <div class="draft-card" id="draftCard-${st.index}">
                        <div class="draft-head">
                            <label style="display:flex;align-items:center;gap:10px;cursor:pointer;font-weight:800;font-size:1rem;color:#0F172A">
                                <input type="checkbox" name="approvedIndices" value="${st.index}"
                                       class="approve-checkbox" checked
                                       style="width:18px;height:18px;accent-color:#4F46E5"
                                       onchange="updateDraftCardState(${st.index}, this.checked)"/>
                                <span>Câu đề xuất #${st.index + 1}</span>
                                <span style="font-size:0.75rem;padding:2px 8px;border-radius:999px;background:#DCFCE7;color:#15803D;font-weight:700"
                                      id="draftStatusBadge-${st.index}">Sẽ lưu vào ngân hàng</span>
                            </label>

                            <button type="button" class="ins-link-btn ins-link-btn--danger"
                                    onclick="rejectSingleDraft(${st.index})">
                                ✕ Loại bỏ câu này
                            </button>
                        </div>

                        <c:if test="${not empty q.sourceExcerpt}">
                            <div class="draft-citation">
                                <strong>📌 Nguồn trích dẫn RAG:</strong> <c:out value="${q.sourceExcerpt}"/>
                            </div>
                        </c:if>

                        <div style="margin-bottom:12px">
                            <label class="rv-label">Nội dung câu hỏi *</label>
                            <textarea name="contents" class="rv-input" rows="2" required><c:out value="${q.content}"/></textarea>
                        </div>

                        <div style="display:grid;grid-template-columns:1.2fr 1fr 0.8fr 1fr;gap:12px;margin-bottom:12px">
                            <div>
                                <label class="rv-label">Loại câu hỏi</label>
                                <select name="types" class="rv-input" onchange="handleDraftTypeChange(${st.index}, this.value)">
                                    <option value="SINGLE_CHOICE" ${q.type == 'SINGLE_CHOICE' ? 'selected' : ''}>Trắc nghiệm 1 đáp án</option>
                                    <option value="MULTIPLE_CHOICE" ${q.type == 'MULTIPLE_CHOICE' ? 'selected' : ''}>Nhiều đáp án đúng</option>
                                    <option value="TRUE_FALSE" ${q.type == 'TRUE_FALSE' ? 'selected' : ''}>Đúng / Sai</option>
                                    <option value="ESSAY" ${q.type == 'ESSAY' ? 'selected' : ''}>Tự luận</option>
                                </select>
                            </div>
                            <div>
                                <label class="rv-label">Độ khó</label>
                                <select name="difficulties" class="rv-input">
                                    <option value="EASY" ${q.difficultyLevel == 'EASY' ? 'selected' : ''}>Dễ (Easy)</option>
                                    <option value="MEDIUM" ${q.difficultyLevel == 'MEDIUM' ? 'selected' : ''}>Trung bình (Medium)</option>
                                    <option value="HARD" ${q.difficultyLevel == 'HARD' ? 'selected' : ''}>Khó (Hard)</option>
                                </select>
                            </div>
                            <div>
                                <label class="rv-label">Điểm mặc định</label>
                                <input type="number" name="scores" class="rv-input" step="0.25" min="0.25" value="${q.defaultScore}"/>
                            </div>
                            <div>
                                <label class="rv-label">Đáp án đúng (A/B/C/D hoặc TRUE/FALSE)</label>
                                <input type="text" name="correctAnswers" class="rv-input"
                                       style="font-weight:800;color:#15803D;background:#F0FDF4"
                                       value="<c:out value='${q.correctAnswer}'/>"/>
                            </div>
                        </div>

                        <%-- 4 Phương án lựa chọn A, B, C, D --%>
                        <div id="optionsGrid-${st.index}" style="display:${q.type == 'ESSAY' or q.type == 'TRUE_FALSE' ? 'none' : 'grid'};grid-template-columns:1fr 1fr;gap:10px;margin-bottom:12px">
                            <div>
                                <label class="rv-label">Phương án A</label>
                                <input type="text" name="optionAs" class="rv-input" value="<c:out value='${q.optionA}'/>"/>
                            </div>
                            <div>
                                <label class="rv-label">Phương án B</label>
                                <input type="text" name="optionBs" class="rv-input" value="<c:out value='${q.optionB}'/>"/>
                            </div>
                            <div>
                                <label class="rv-label">Phương án C</label>
                                <input type="text" name="optionCs" class="rv-input" value="<c:out value='${q.optionC}'/>"/>
                            </div>
                            <div>
                                <label class="rv-label">Phương án D</label>
                                <input type="text" name="optionDs" class="rv-input" value="<c:out value='${q.optionD}'/>"/>
                            </div>
                        </div>

                        <div style="display:grid;grid-template-columns:1fr 1fr;gap:12px">
                            <div>
                                <label class="rv-label">📖 Giải thích đáp án (Explanation)</label>
                                <textarea name="explanations" class="rv-input" rows="2"
                                          placeholder="Giải thích vì sao đáp án đúng..."><c:out value="${q.explanation}"/></textarea>
                            </div>
                            <div>
                                <label class="rv-label">💡 Đáp án mẫu / Tiêu chí chấm (Dành cho câu Tự luận)</label>
                                <textarea name="sampleEssayAnswers" class="rv-input" rows="2"
                                          placeholder="Gợi ý đáp án mẫu cho câu tự luận..."><c:out value="${q.sampleEssayAnswer}"/></textarea>
                            </div>
                        </div>
                    </div>
                </c:forEach>

                <%-- Thanh công cụ phê duyệt cố định phía dưới --%>
                <div class="sticky-approve-bar">
                    <div>
                        <div style="font-weight:800;font-size:0.95rem">
                            Đã chọn phê duyệt: <span id="approvedCountLabel">${ragResult.draftQuestions.size()}</span> / ${ragResult.draftQuestions.size()} câu hỏi
                        </div>
                        <div style="font-size:0.78rem;color:#94A3B8">
                            Chỉ các câu hỏi được tick chọn mới được lưu chính thức vào Ngân hàng câu hỏi.
                        </div>
                    </div>
                    <div style="display:flex;gap:10px">
                        <a href="${pageContext.request.contextPath}/instructor/question-banks/${bank.bankId}"
                           class="ins-link-btn" style="background:#1E293B;color:#E2E8F0;border-color:#334155">
                            Hủy bỏ
                        </a>
                        <button type="submit" class="ins-btn-primary"
                                style="background:#10B981;border-color:#10B981;width:auto;padding:10px 22px;font-size:0.92rem">
                            ✅ Phê duyệt &amp; Lưu vào Ngân hàng câu hỏi
                        </button>
                    </div>
                </div>
            </form>
        </main>
    </div>
</div>

<script>
    function updateDraftCardState(idx, checked) {
        var card = document.getElementById('draftCard-' + idx);
        var badge = document.getElementById('draftStatusBadge-' + idx);
        if (card) {
            if (checked) card.classList.remove('unchecked');
            else card.classList.add('unchecked');
        }
        if (badge) {
            badge.textContent = checked ? 'Sẽ lưu vào ngân hàng' : 'Đã loại bỏ (Không lưu)';
            badge.style.background = checked ? '#DCFCE7' : '#FEE2E2';
            badge.style.color = checked ? '#15803D' : '#B91C1C';
        }
        recalcApprovedCount();
    }

    function rejectSingleDraft(idx) {
        var checkboxes = document.querySelectorAll('.approve-checkbox');
        checkboxes.forEach(function(cb) {
            if (parseInt(cb.value, 10) === idx) {
                cb.checked = false;
                updateDraftCardState(idx, false);
            }
        });
    }

    function toggleAllApprove(state) {
        var checkboxes = document.querySelectorAll('.approve-checkbox');
        checkboxes.forEach(function(cb) {
            cb.checked = state;
            updateDraftCardState(parseInt(cb.value, 10), state);
        });
    }

    function recalcApprovedCount() {
        var checkedCount = document.querySelectorAll('.approve-checkbox:checked').length;
        var lbl = document.getElementById('approvedCountLabel');
        if (lbl) lbl.textContent = checkedCount;
    }

    function handleDraftTypeChange(idx, typeVal) {
        var grid = document.getElementById('optionsGrid-' + idx);
        if (!grid) return;
        if (typeVal === 'ESSAY' || typeVal === 'TRUE_FALSE') {
            grid.style.display = 'none';
        } else {
            grid.style.display = 'grid';
        }
    }
</script>
</body>
</html>
