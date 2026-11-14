<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Kết quả bài tập — <c:out value="${assignment.title}"/> — EduSphere</title>
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

    .asr-wrap {
      max-width: 860px;
      margin: 0 auto;
      padding: 28px 20px 64px;
    }

    .asr-back {
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

    .asr-score-banner {
      background: linear-gradient(135deg, #065f46 0%, #059669 60%, #10b981 100%);
      color: #ffffff;
      border-radius: 20px;
      padding: 28px 32px;
      margin-bottom: 20px;
      display: flex;
      flex-wrap: wrap;
      align-items: center;
      justify-content: space-between;
      gap: 20px;
      box-shadow: 0 12px 28px rgba(5, 150, 105, 0.2);
    }

    .asr-score-value {
      font-size: 2.5rem;
      font-weight: 800;
      line-height: 1.1;
    }

    .asr-feedback-card {
      background: #ffffff;
      border: 1px solid #e2e8f0;
      border-radius: 16px;
      padding: 24px 28px;
      box-shadow: 0 2px 10px rgba(15, 23, 42, 0.04);
    }

    .asr-feedback-text {
      background: #f8fafc;
      border-left: 4px solid #059669;
      padding: 16px 18px;
      border-radius: 10px;
      white-space: pre-wrap;
      font-size: 0.95rem;
      line-height: 1.6;
      color: #1e293b;
      margin: 12px 0 0;
    }
  </style>
</head>
<body>
  <jsp:include page="/WEB-INF/views/common/navbar.jsp"/>

  <main class="asr-wrap">
    <a class="asr-back" href="${pageContext.request.contextPath}/courses/${courseId}/assignments/${assignmentId}">
      ← Chi tiết bài tập
    </a>

    <header class="page-heading" style="margin-bottom:18px">
      <div>
        <p class="eyebrow">Kết quả bài tập · UC31</p>
        <h1><c:out value="${assignment.title}"/></h1>
      </div>
    </header>

    <c:choose>
      <c:when test="${empty grade}">
        <div class="empty-state">
          <span class="empty-state__mark">○</span>
          <h2>Chưa có kết quả chính thức</h2>
          <p>Giảng viên chưa chấm hoặc chưa công bố điểm cho bài tập của bạn.</p>
        </div>
      </c:when>
      <c:otherwise>
        <section class="asr-score-banner">
          <div>
            <div style="font-size:0.8rem;text-transform:uppercase;letter-spacing:0.06em;opacity:0.9">
              Điểm số đã công bố
            </div>
            <div class="asr-score-value">
              <fmt:formatNumber value="${grade.score}" maxFractionDigits="2"/>
              <span style="font-size:1.3rem;opacity:0.85">/ <fmt:formatNumber value="${grade.maxScore}" maxFractionDigits="2"/></span>
            </div>
            <c:if test="${grade.gradedAt != null}">
              <div style="font-size:0.85rem;margin-top:6px;opacity:0.9">
                Chấm lúc ${fn:replace(fn:substring(grade.gradedAt, 0, 16), 'T', ' ')}
              </div>
            </c:if>
          </div>
          <c:if test="${scorePercent != null}">
            <div style="text-align:right">
              <div style="font-size:1.6rem;font-weight:800">
                <fmt:formatNumber value="${scorePercent}" maxFractionDigits="1"/>%
              </div>
              <div style="font-size:0.86rem;background:rgba(255,255,255,0.2);padding:4px 12px;border-radius:999px;margin-top:4px">
                <c:out value="${standingLabel}"/>
              </div>
            </div>
          </c:if>
        </section>

        <article class="asr-feedback-card">
          <h3 style="margin:0;font-size:1.1rem">💬 Nhận xét chi tiết của giảng viên</h3>
          <p class="asr-feedback-text">
            <c:out value="${grade.feedback}" default="Không có nhận xét."/>
          </p>
        </article>
      </c:otherwise>
    </c:choose>
  </main>

  <jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</body>
</html>
