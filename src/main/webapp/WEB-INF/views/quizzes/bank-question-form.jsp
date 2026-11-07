<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${isEdit ? 'Chỉnh sửa' : 'Thêm'} câu hỏi — ${bank.name}</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/home.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/instructor.css">
    <style>
        .form-card {
            background: #fff;
            border-radius: 12px;
            border: 1px solid #e5e7eb;
            padding: 28px;
            max-width: 860px;
            margin: 0 auto;
            box-shadow: 0 1px 3px rgba(0,0,0,0.04);
        }
        .form-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
            margin-bottom: 18px;
        }
        @media (max-width: 640px) {
            .form-row { grid-template-columns: 1fr; }
        }
        .form-group {
            margin-bottom: 20px;
        }
        .form-group label {
            display: block;
            margin-bottom: 7px;
            font-weight: 600;
            font-size: 0.92rem;
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
            transition: border-color 0.15s, box-shadow 0.15s;
        }
        .form-control:focus {
            border-color: #6366f1;
            box-shadow: 0 0 0 3px rgba(99,102,241,0.15);
        }
        .options-section {
            background: #f8fafc;
            border: 1px solid #e2e8f0;
            border-radius: 10px;
            padding: 20px;
            margin-top: 10px;
        }
        .option-row {
            display: flex;
            align-items: center;
            gap: 12px;
            margin-bottom: 12px;
        }
        .option-row:last-child {
            margin-bottom: 0;
        }
        .option-label {
            width: 32px;
            height: 32px;
            border-radius: 50%;
            background: #e2e8f0;
            color: #334155;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 700;
            font-size: 0.9rem;
            flex-shrink: 0;
        }
        .img-preview-box {
            margin-top: 8px;
            max-width: 240px;
            border-radius: 8px;
            overflow: hidden;
            border: 1px solid #e2e8f0;
        }
        .img-preview-box img {
            width: 100%;
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
            <div style="margin-bottom:16px">
                <a href="${pageContext.request.contextPath}/instructor/question-banks/${bank.bankId}" style="color:#6366f1;text-decoration:none;font-weight:600;font-size:0.9rem">
                    ← Quay lại ngân hàng: <c:out value="${bank.name}"/>
                </a>
            </div>

            <div class="form-card">
                <h1 style="margin:0 0 8px;font-size:1.4rem;font-weight:800;color:#0f172a">
                    ${isEdit ? 'Chỉnh sửa câu hỏi' : 'Thêm câu hỏi mới vào ngân hàng'}
                </h1>
                <p style="color:#64748b;margin:0 0 24px;font-size:0.9rem">
                    Ngân hàng: <strong><c:out value="${bank.name}"/></strong>
                </p>

                <form method="post" enctype="multipart/form-data"
                      action="${pageContext.request.contextPath}/instructor/question-banks/${bank.bankId}/questions<c:if test="${isEdit}">/${questionId}/edit</c:if>">
                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>

                    <div class="form-row">
                        <div class="form-group">
                            <label>Chuyên đề / Chủ đề</label>
                            <select name="categoryId" class="form-control">
                                <option value="">-- Không phân loại --</option>
                                <c:forEach var="cat" items="${categories}">
                                    <option value="${cat.categoryId}" <c:if test="${questionForm.categoryId == cat.categoryId}">selected</c:if>>
                                        <c:out value="${cat.name}"/>
                                    </option>
                                </c:forEach>
                            </select>
                        </div>
                        <div class="form-group">
                            <label>Loại câu hỏi <span style="color:#ef4444">*</span></label>
                            <select name="type" id="questionTypeSelect" class="form-control" onchange="handleTypeChange(this.value)">
                                <option value="SINGLE_CHOICE" <c:if test="${questionForm.type eq 'SINGLE_CHOICE'}">selected</c:if>>Trắc nghiệm một lựa chọn (Radio)</option>
                                <option value="MULTIPLE_CHOICE" <c:if test="${questionForm.type eq 'MULTIPLE_CHOICE'}">selected</c:if>>Trắc nghiệm nhiều lựa chọn (Checkbox)</option>
                                <option value="TRUE_FALSE" <c:if test="${questionForm.type eq 'TRUE_FALSE'}">selected</c:if>>Đúng / Sai</option>
                                <option value="SHORT_ANSWER" <c:if test="${questionForm.type eq 'SHORT_ANSWER'}">selected</c:if>>Điền từ ngắn</option>
                                <option value="ESSAY" <c:if test="${questionForm.type eq 'ESSAY'}">selected</c:if>>Tự luận (Giáo viên chấm điểm)</option>
                            </select>
                        </div>
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <label>Mức độ khó</label>
                            <select name="difficultyLevel" class="form-control">
                                <option value="EASY" <c:if test="${questionForm.difficultyLevel eq 'EASY'}">selected</c:if>>Dễ</option>
                                <option value="MEDIUM" <c:if test="${questionForm.difficultyLevel eq 'MEDIUM'}">selected</c:if>>Trung bình</option>
                                <option value="HARD" <c:if test="${questionForm.difficultyLevel eq 'HARD'}">selected</c:if>>Khó</option>
                            </select>
                        </div>
                        <div class="form-group">
                            <label>Điểm mặc định</label>
                            <input type="number" step="0.25" min="0.25" max="100" name="defaultScore" class="form-control"
                                   value="${questionForm.defaultScore != null ? questionForm.defaultScore : 1.0}"/>
                        </div>
                    </div>

                    <div class="form-group">
                        <label>Nội dung câu hỏi <span style="color:#ef4444">*</span></label>
                        <textarea name="content" class="form-control" rows="4" placeholder="Nhập câu hỏi tại đây..." required><c:out value="${questionForm.content}"/></textarea>
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <label>Hình ảnh đính kèm (cho câu hỏi có hình minh họa)</label>
                            <input type="file" name="imageFile" class="form-control" accept="image/*" onchange="previewImg(this)"/>
                            <input type="hidden" name="imageUrl" value="${questionForm.imageUrl}"/>
                            <c:if test="${not empty questionForm.imageUrl}">
                                <div class="img-preview-box" id="existingImgBox">
                                    <img src="${pageContext.request.contextPath}${questionForm.imageUrl}" alt="Preview"/>
                                </div>
                            </c:if>
                            <div class="img-preview-box" id="clientImgPreview" style="display:none">
                                <img id="previewImgEl" src="" alt="Client preview"/>
                            </div>
                        </div>
                        <div class="form-group">
                            <label>Đường dẫn Video (Video URL nếu có)</label>
                            <input type="url" name="videoUrl" class="form-control" placeholder="https://..." value="<c:out value="${questionForm.videoUrl}"/>"/>
                            <span style="font-size:0.8rem;color:#64748b">Hỗ trợ liên kết video hoặc lưu trữ cloud</span>
                        </div>
                    </div>

                    <%-- KHỐI ĐÁP ÁN CHO TRẮC NGHIỆM ĐƠN / NHIỀU --%>
                    <div id="choiceOptionsSection" class="options-section">
                        <div style="font-weight:700;margin-bottom:12px;color:#1e293b;display:flex;justify-content:space-between">
                            <span>Các lựa chọn đáp án:</span>
                            <span style="font-size:0.82rem;font-weight:normal;color:#64748b" id="choiceNotice">
                                Tích chọn đáp án đúng
                            </span>
                        </div>

                        <%-- 4 options --%>
                        <c:forEach var="optIdx" begin="0" end="3">
                            <c:set var="lbl" value="${optIdx == 0 ? 'A' : (optIdx == 1 ? 'B' : (optIdx == 2 ? 'C' : 'D'))}"/>
                            <div class="option-row">
                                <span class="option-label">${lbl}</span>
                                <input type="text" name="optionTexts[${optIdx}]" class="form-control" placeholder="Nội dung đáp án ${lbl}"
                                       value="<c:out value="${questionForm.optionTexts[optIdx]}"/>"/>
                                
                                <%-- Radio for SINGLE_CHOICE --%>
                                <div class="single-choice-indicator" style="display:flex;align-items:center;gap:6px;padding:0 8px">
                                    <input type="radio" name="singleCorrectIndex" value="${optIdx}" id="radio_${optIdx}"
                                           <c:if test="${questionForm.singleCorrectIndex == optIdx}">checked</c:if>/>
                                    <label for="radio_${optIdx}" style="margin:0;font-size:0.85rem;cursor:pointer">Đúng</label>
                                </div>

                                <%-- Checkbox for MULTIPLE_CHOICE --%>
                                <div class="multiple-choice-indicator" style="display:none;align-items:center;gap:6px;padding:0 8px">
                                    <input type="checkbox" name="optionCorrects[${optIdx}]" value="true" id="chk_${optIdx}"
                                           <c:if test="${questionForm.optionCorrects[optIdx]}">checked</c:if>/>
                                    <label for="chk_${optIdx}" style="margin:0;font-size:0.85rem;cursor:pointer">Đúng</label>
                                </div>
                            </div>
                        </c:forEach>
                    </div>

                    <%-- KHỐI ĐÁP ÁN ĐÚNG/SAI --%>
                    <div id="tfSection" class="options-section" style="display:none">
                        <label style="font-weight:700;color:#1e293b;display:block;margin-bottom:8px">Đáp án đúng:</label>
                        <div style="display:flex;gap:24px">
                            <label style="display:flex;align-items:center;gap:6px;cursor:pointer">
                                <input type="radio" name="tfCorrect" value="Đúng" onchange="setTfVal(this.value)"
                                       <c:if test="${questionForm.correctAnswer eq 'Đúng'}">checked</c:if>/>
                                Đúng
                            </label>
                            <label style="display:flex;align-items:center;gap:6px;cursor:pointer">
                                <input type="radio" name="tfCorrect" value="Sai" onchange="setTfVal(this.value)"
                                       <c:if test="${questionForm.correctAnswer eq 'Sai'}">checked</c:if>/>
                                Sai
                            </label>
                        </div>
                    </div>

                    <%-- KHỐI TỰ LUẬN --%>
                    <div id="essaySection" class="options-section" style="display:none">
                        <div class="form-group" style="margin-bottom:0">
                            <label>Gợi ý đáp án / Tiêu chí chấm điểm (Rubric):</label>
                            <textarea name="sampleEssayAnswer" class="form-control" rows="4" placeholder="Nhập các ý chính cần có trong bài làm của học sinh để chấm điểm..."><c:out value="${questionForm.sampleEssayAnswer}"/></textarea>
                        </div>
                    </div>

                    <%-- KHỐI ĐIỀN TỪ NGẮN --%>
                    <div id="shortAnswerSection" class="options-section" style="display:none">
                        <div class="form-group" style="margin-bottom:0">
                            <label>Từ hoặc cụm từ chính xác cần điền:</label>
                            <input type="text" name="correctAnswer" id="shortAnswerInput" class="form-control" placeholder="Từ khóa đáp án..."
                                   value="<c:out value="${questionForm.correctAnswer}"/>"/>
                        </div>
                    </div>

                    <div class="form-group" style="margin-top:20px">
                        <label>Lời giải thích chi tiết (Hiển thị sau khi học viên nộp bài)</label>
                        <textarea name="explanation" class="form-control" rows="3" placeholder="Giải thích vì sao đáp án đúng..."><c:out value="${questionForm.explanation}"/></textarea>
                    </div>

                    <div style="display:flex;justify-content:flex-end;gap:12px;margin-top:30px">
                        <a href="${pageContext.request.contextPath}/instructor/question-banks/${bank.bankId}" class="ins-link-btn">Hủy bỏ</a>
                        <button type="submit" class="ins-btn-primary" style="width:auto;padding:10px 28px">
                            ${isEdit ? 'Lưu thay đổi' : 'Thêm vào ngân hàng'}
                        </button>
                    </div>
                </form>
            </div>
        </main>
    </div>
</div>

<script>
    function previewImg(input) {
        if (input.files && input.files[0]) {
            const reader = new FileReader();
            reader.onload = function(e) {
                document.getElementById('previewImgEl').src = e.target.result;
                document.getElementById('clientImgPreview').style.display = 'block';
                const ex = document.getElementById('existingImgBox');
                if (ex) ex.style.display = 'none';
            };
            reader.readAsDataURL(input.files[0]);
        }
    }

    function setTfVal(val) {
        document.getElementById('shortAnswerInput').value = val;
    }

    function handleTypeChange(type) {
        const choiceSec = document.getElementById('choiceOptionsSection');
        const tfSec = document.getElementById('tfSection');
        const essaySec = document.getElementById('essaySection');
        const shortSec = document.getElementById('shortAnswerSection');
        const singleInds = document.querySelectorAll('.single-choice-indicator');
        const multiInds = document.querySelectorAll('.multiple-choice-indicator');

        choiceSec.style.display = 'none';
        tfSec.style.display = 'none';
        essaySec.style.display = 'none';
        shortSec.style.display = 'none';

        if (type === 'SINGLE_CHOICE') {
            choiceSec.style.display = 'block';
            singleInds.forEach(el => el.style.display = 'flex');
            multiInds.forEach(el => el.style.display = 'none');
            document.getElementById('choiceNotice').innerText = 'Chọn 1 đáp án đúng bằng nút tròn';
        } else if (type === 'MULTIPLE_CHOICE') {
            choiceSec.style.display = 'block';
            singleInds.forEach(el => el.style.display = 'none');
            multiInds.forEach(el => el.style.display = 'flex');
            document.getElementById('choiceNotice').innerText = 'Chọn các đáp án đúng bằng ô vuông';
        } else if (type === 'TRUE_FALSE') {
            tfSec.style.display = 'block';
        } else if (type === 'ESSAY') {
            essaySec.style.display = 'block';
        } else if (type === 'SHORT_ANSWER') {
            shortSec.style.display = 'block';
        }
    }

    function insToggleMenu(e) {
        e.stopPropagation();
        var m = document.getElementById('insUserMenu');
        if (m) m.classList.toggle('open');
    }
    document.addEventListener('click', function() {
        var m = document.getElementById('insUserMenu');
        if (m) m.classList.remove('open');
    });

    // Initialize on load
    document.addEventListener('DOMContentLoaded', function() {
        var navItem = document.getElementById('nav-question-banks');
        if (navItem) navItem.classList.add('active');
        handleTypeChange(document.getElementById('questionTypeSelect').value);
    });
</script>
</body>
</html>

