<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Danh sách bài tập khóa học — EduSphere</title>
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

    .asl-wrap {
      max-width: 1080px;
      margin: 0 auto;
      padding: 28px 20px 64px;
    }

    .asl-back {
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

    .asl-back:hover {
      background: #dbeafe;
    }

    .asl-hero {
      background: linear-gradient(135deg, #0f172a 0%, #1e40af 60%, #2563eb 100%);
      color: #ffffff;
      border-radius: 18px;
      padding: 28px 32px;
      margin-bottom: 22px;
      box-shadow: 0 12px 28px rgba(30, 64, 175, 0.18);
      display: flex;
      flex-wrap: wrap;
      align-items: center;
      justify-content: space-between;
      gap: 20px;
    }

    .asl-hero__eyebrow {
      font-size: 0.76rem;
      font-weight: 700;
      text-transform: uppercase;
      letter-spacing: 0.08em;
      background: rgba(255, 255, 255, 0.18);
      padding: 4px 12px;
      border-radius: 999px;
      display: inline-block;
      margin-bottom: 8px;
    }

    .asl-hero__title {
      font-size: 1.7rem;
      font-weight: 800;
      margin: 0 0 6px;
    }

    .asl-hero__sub {
      margin: 0;
      font-size: 0.92rem;
      opacity: 0.88;
    }

    .asl-toolbar {
      background: #ffffff;
      border: 1px solid #e2e8f0;
      border-radius: 14px;
      padding: 12px 16px;
      margin-bottom: 18px;
      display: flex;
      flex-wrap: wrap;
      align-items: center;
      justify-content: space-between;
      gap: 12px;
    }

    .asl-search {
      padding: 8px 14px;
      border: 1px solid #cbd5e1;
      border-radius: 10px;
      font-size: 0.88rem;
      min-width: 260px;
      outline: none;
    }

    .asl-search:focus {
      border-color: #2563eb;
      box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.12);
    }

    .asl-grid {
      display: flex;
      flex-direction: column;
      gap: 14px;
    }

    .asl-card {
      background: #ffffff;
      border: 1px solid #e2e8f0;
      border-radius: 16px;
      padding: 20px 24px;
      box-shadow: 0 2px 8px rgba(15, 23, 42, 0.04);
      display: flex;
      flex-wrap: wrap;
      align-items: center;
      justify-content: space-between;
      gap: 16px;
      transition: transform 0.16s ease, box-shadow 0.16s ease;
    }

    .asl-card:hover {
      transform: translateY(-2px);
      box-shadow: 0 8px 20px rgba(15, 23, 42, 0.08);
      border-color: #93c5fd;
    }

    .asl-card__title {
      font-size: 1.12rem;
      font-weight: 800;
      margin: 0 0 8px;
    }

    .asl-card__title a {
      color: #0f172a;
      text-decoration: none;
    }

    .asl-card__title a:hover {
      color: #2563eb;
    }

    .asl-card__meta {
      display: flex;
      flex-wrap: wrap;
      gap: 12px;
      font-size: 0.84rem;
      color: #64748b;
    }

    .asl-meta-chip {
      display: inline-flex;
      align-items: center;
      gap: 5px;
      background: #f1f5f9;
      color: #334155;
      padding: 4px 10px;
      border-radius: 999px;
      font-weight: 600;
      font-size: 0.78rem;
    }

    .asl-card__actions {
      display: flex;
      flex-wrap: wrap;
      gap: 10px;
    }

    .asl-btn {
      display: inline-flex;
      align-items: center;
      gap: 6px;
      padding: 9px 16px;
      border-radius: 10px;
      font-size: 0.86rem;
      font-weight: 700;
      text-decoration: none;
      transition: all 0.15s ease;
    }

    .asl-btn--primary {
      background: #2563eb;
      color: #ffffff;
    }

    .asl-btn--primary:hover {
      background: #1d4ed8;
    }

    .asl-btn--outline {
      border: 1px solid #cbd5e1;
      background: #ffffff;
      color: #334155;
    }

    .asl-btn--outline:hover {
      border-color: #2563eb;
      color: #2563eb;
    }
  </style>
</head>
<body>
  <jsp:include page="/WEB-INF/views/common/navbar.jsp"/>

  <main class="asl-wrap">
    <a class="asl-back" href="${pageContext.request.contextPath}/courses/${courseId}/learn">
      ← Quay lại bài học
    </a>

    <header class="asl-hero">
      <div>
        <span class="asl-hero__eyebrow">📝 Không gian học viên · UC29</span>
        <h1 class="asl-hero__title">Bài tập thực hành của khóa học</h1>
        <p class="asl-hero__sub">
          Hoàn thành các bài tập thực hành đúng hạn để củng cố kiến thức và nhận đánh giá chi tiết từ giảng viên.
        </p>
      </div>
      <div style="text-align:right">
        <div style="font-size:0.8rem;opacity:0.85">Tổng số bài tập đã mở</div>
        <div style="font-size:2rem;font-weight:800">${fn:length(assignments)}</div>
      </div>
    </header>

    <c:if test="${not empty success}">
      <div class="alert alert--success" style="margin-bottom:18px"><c:out value="${success}"/></div>
    </c:if>

    <c:choose>
      <c:when test="${empty assignments}">
        <div class="empty-state">
          <span class="empty-state__mark">○</span>
          <h2>Chưa có bài tập</h2>
          <p>Giảng viên chưa công bố bài tập nào cho khóa học này.</p>
        </div>
      </c:when>
      <c:otherwise>
        <div class="asl-toolbar">
          <div style="font-size:0.88rem;font-weight:600;color:#475569">
            Hiển thị <strong>${fn:length(assignments)}</strong> bài tập thực hành
          </div>
          <input type="text" id="aslSearchInput" class="asl-search"
                 placeholder="Tìm theo tên bài tập hoặc bài học..."
                 oninput="filterStudentAssignments()">
        </div>

        <div class="asl-grid" id="aslAssignmentList">
          <c:forEach var="a" items="${assignments}">
            <article class="asl-card"
                     data-search="${fn:toLowerCase(a.title)} ${fn:toLowerCase(a.lessonTitle)}">
              <div>
                <h3 class="asl-card__title">
                  <a href="${pageContext.request.contextPath}/courses/${courseId}/assignments/${a.assignmentId}">
                    <c:out value="${a.title}"/>
                  </a>
                </h3>
                <div class="asl-card__meta">
                  <span class="asl-meta-chip">
                    🏆 Điểm tối đa: <strong><fmt:formatNumber value="${a.maxScore}" maxFractionDigits="1"/></strong>
                  </span>
                  <c:if test="${a.dueDate != null}">
                    <span class="asl-meta-chip">
                      ⏰ Hạn nộp: <strong>${fn:replace(fn:substring(a.dueDate, 0, 16), 'T', ' ')}</strong>
                    </span>
                  </c:if>
                  <c:if test="${not empty a.lessonTitle}">
                    <span class="asl-meta-chip">
                      📖 Bài học: <c:out value="${a.lessonTitle}"/>
                    </span>
                  </c:if>
                </div>
              </div>

              <div class="asl-card__actions">
                <a class="asl-btn asl-btn--primary"
                   href="${pageContext.request.contextPath}/courses/${courseId}/assignments/${a.assignmentId}">
                  Xem &amp; nộp bài →
                </a>
                <a class="asl-btn asl-btn--outline"
                   href="${pageContext.request.contextPath}/courses/${courseId}/assignments/${a.assignmentId}/result">
                  Xem kết quả
                </a>
              </div>
            </article>
          </c:forEach>
        </div>
      </c:otherwise>
    </c:choose>
  </main>

  <jsp:include page="/WEB-INF/views/common/footer.jsp"/>

  <script>
    function filterStudentAssignments() {
      var input = document.getElementById('aslSearchInput');
      var q = input ? input.value.trim().toLowerCase() : '';
      var cards = document.querySelectorAll('#aslAssignmentList .asl-card');
      for (var i = 0; i < cards.length; i++) {
        var text = cards[i].getAttribute('data-search') || '';
        cards[i].style.display = (!q || text.indexOf(q) !== -1) ? '' : 'none';
      }
    }
  </script>
</body>
</html>
