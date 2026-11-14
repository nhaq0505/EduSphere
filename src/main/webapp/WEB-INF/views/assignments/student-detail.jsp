<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title><c:out value="${assignment.title}"/> — Bài tập — EduSphere</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app.css?v=restore-0bfd0e1-20261014">
  <style>
    body {
      background: #f8fafc;
      color: #0f172a;
      font-family: 'Inter', system-ui, -apple-system, sans-serif;
    }

    .asd-wrap {
      max-width: 1040px;
      margin: 0 auto;
      padding: 28px 20px 64px;
    }

    .asd-back {
      display: inline-flex;
      align-items: center;
      gap: 6px;
      padding: 8px 14px;
      border-radius: 999px;
      background: #eff6ff;
      color: #2563eb;
      font-size: 0.88rem;
      font-weight: 600;
      text-decoration: none;
      margin-bottom: 18px;
    }

    .asd-header {
      background: #ffffff;
      border: 1px solid #e2e8f0;
      border-radius: 18px;
      padding: 24px 28px;
      margin-bottom: 20px;
      box-shadow: 0 2px 10px rgba(15, 23, 42, 0.04);
    }

    .asd-header__eyebrow {
      font-size: 0.76rem;
      font-weight: 700;
      text-transform: uppercase;
      letter-spacing: 0.08em;
      color: #2563eb;
      margin-bottom: 6px;
      display: block;
    }

    .asd-header__title {
      font-size: 1.6rem;
      font-weight: 800;
      margin: 0 0 12px;
      color: #0f172a;
    }

    .asd-meta-row {
      display: flex;
      flex-wrap: wrap;
      gap: 10px;
    }

    .asd-chip {
      display: inline-flex;
      align-items: center;
      gap: 6px;
      padding: 6px 12px;
      border-radius: 999px;
      background: #f1f5f9;
      color: #334155;
      font-size: 0.82rem;
      font-weight: 600;
    }

    .asd-card {
      background: #ffffff;
      border: 1px solid #e2e8f0;
      border-radius: 16px;
      padding: 22px 26px;
      margin-bottom: 20px;
      box-shadow: 0 2px 8px rgba(15, 23, 42, 0.03);
    }

    .asd-card__title {
      font-size: 1.1rem;
      font-weight: 800;
      margin: 0 0 12px;
      color: #0f172a;
      display: flex;
      align-items: center;
      justify-content: space-between;
    }

    .asd-prompt {
      background: #f8fafc;
      border-left: 4px solid #2563eb;
      padding: 16px 18px;
      border-radius: 10px;
      white-space: pre-wrap;
      font-size: 0.94rem;
      line-height: 1.6;
      color: #1e293b;
      margin: 0;
    }

    .asd-sub-item {
      border: 1px solid #e2e8f0;
      border-radius: 12px;
      padding: 14px 16px;
      margin-bottom: 12px;
      background: #fafcff;
    }

    .asd-sub-head {
      display: flex;
      flex-wrap: wrap;
      align-items: center;
      justify-content: space-between;
      gap: 8px;
      margin-bottom: 8px;
    }

    .asd-textarea {
      width: 100%;
      padding: 12px 14px;
      border: 1px solid #cbd5e1;
      border-radius: 10px;
      font-family: inherit;
      font-size: 0.92rem;
      resize: vertical;
      box-sizing: border-box;
    }

    .asd-input {
      width: 100%;
      padding: 10px 14px;
      border: 1px solid #cbd5e1;
      border-radius: 10px;
      font-family: inherit;
      font-size: 0.92rem;
      box-sizing: border-box;
    }

    .asd-textarea:focus, .asd-input:focus {
      border-color: #2563eb;
      outline: none;
      box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.12);
    }
  </style>
</head>
<body>
  <jsp:include page="/WEB-INF/views/common/navbar.jsp"/>

  <main class="asd-wrap">
    <a class="asd-back" href="${pageContext.request.contextPath}/courses/${courseId}/assignments">
      ← Danh sách bài tập
    </a>

    <header class="asd-header">
      <span class="asd-header__eyebrow">📝 Chi tiết bài tập · UC29</span>
      <h1 class="asd-header__title"><c:out value="${assignment.title}"/></h1>
      <div class="asd-meta-row">
        <span class="asd-chip">
          🏆 Điểm tối đa: <strong><fmt:formatNumber value="${assignment.maxScore}" maxFractionDigits="1"/></strong>
        </span>
        <c:if test="${assignment.dueDate != null}">
          <span class="asd-chip">
            ⏰ Hạn nộp: <strong>${fn:replace(fn:substring(assignment.dueDate, 0, 16), 'T', ' ')}</strong>
          </span>
        </c:if>
        <span class="asd-chip">
          🔄 Số lần nộp tối đa: <strong>${assignment.maxAttempts}</strong>
        </span>
        <span class="asd-chip">
          📤 Đã nộp: <strong>${fn:length(mySubmissions)} / ${assignment.maxAttempts}</strong>
        </span>
      </div>
    </header>

    <c:if test="${not empty success}">
      <div class="alert alert--success" style="margin-bottom:18px"><c:out value="${success}"/></div>
    </c:if>

    <article class="asd-card">
      <h3 class="asd-card__title">📋 Nội dung đề bài &amp; Yêu cầu</h3>
      <p class="asd-prompt"><c:out value="${assignment.description}" default="Không có mô tả."/></p>
    </article>

    <article class="asd-card">
      <div class="asd-card__title">
        <span>🗂️ Lịch sử bài đã nộp (${fn:length(mySubmissions)}/${assignment.maxAttempts})</span>
        <c:if test="${not empty mySubmissions}">
          <a class="button button--outline"
             href="${pageContext.request.contextPath}/courses/${courseId}/assignments/${assignmentId}/result">
            Xem kết quả đã công bố →
          </a>
        </c:if>
      </div>

      <c:choose>
        <c:when test="${empty mySubmissions}">
          <p class="muted" style="margin:0">Bạn chưa nộp bài cho bài tập này.</p>
        </c:when>
        <c:otherwise>
          <c:forEach var="s" items="${mySubmissions}">
            <div class="asd-sub-item">
              <div class="asd-sub-head">
                <div>
                  <strong>Lần nộp thứ ${s.attemptNumber}</strong>
                  <span class="small muted"> · ${fn:replace(fn:substring(s.submittedAt, 0, 16), 'T', ' ')}</span>
                </div>
                <div style="display:flex;gap:6px;align-items:center">
                  <c:if test="${s.late}">
                    <span class="pill pill--neutral">⚠️ Nộp trễ hạn</span>
                  </c:if>
                  <span class="pill ${s.status eq 'GRADED' ? 'pill--success' : 'pill--neutral'}">
                    ${s.status eq 'GRADED' ? '✓ Đã chấm' : '⏳ Chờ chấm'}
                  </span>
                </div>
              </div>
              <c:if test="${not empty s.fileUrl}">
                <div style="margin-bottom:6px">
                  <a href="<c:out value='${s.fileUrl}'/>" target="_blank" rel="noopener noreferrer"
                     style="color:#2563eb;font-weight:600">
                    📎 Mở liên kết tệp đính kèm ↗
                  </a>
                </div>
              </c:if>
              <c:if test="${not empty s.answerText}">
                <p style="white-space:pre-wrap;margin:6px 0 0;font-size:0.9rem;color:#334155">
                  <c:out value="${s.answerText}"/>
                </p>
              </c:if>
            </div>
          </c:forEach>
        </c:otherwise>
      </c:choose>
    </article>

    <c:if test="${fn:length(mySubmissions) < assignment.maxAttempts}">
      <article class="asd-card">
        <h3 class="asd-card__title">🚀 Gửi bài nộp mới</h3>
        <form method="post" action="${pageContext.request.contextPath}/courses/${courseId}/assignments/${assignmentId}/submit">
          <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
          <div style="margin-bottom:14px">
            <label for="answerText" style="display:block;font-weight:700;margin-bottom:6px">
              Nội dung bài làm trực tiếp
            </label>
            <textarea id="answerText" name="answerText" rows="7" class="asd-textarea"
                      placeholder="Nhập câu trả lời, giải thích hoặc mã nguồn của bạn tại đây..."></textarea>
          </div>
          <div style="margin-bottom:14px">
            <label for="fileUrl" style="display:block;font-weight:700;margin-bottom:6px">
              Liên kết tệp bài làm (Google Drive / GitHub / OneDrive - http/https)
            </label>
            <input id="fileUrl" type="url" name="fileUrl" class="asd-input" placeholder="https://...">
          </div>
          <p class="small muted" style="margin:0 0 14px">
            Lưu ý: Cần nhập ít nhất nội dung bài làm hoặc đường dẫn liên kết tệp hợp lệ.
          </p>
          <button class="button button--primary" type="submit">📤 Nộp bài ngay</button>
        </form>
      </article>
    </c:if>
  </main>

  <jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</body>
</html>
