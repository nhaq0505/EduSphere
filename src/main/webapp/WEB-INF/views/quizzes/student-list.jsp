<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Danh sách bài kiểm tra Quiz — EduSphere</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/home.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/quiz.css?v=2.0">
  <style>
    .qsl-hero {
      background: linear-gradient(135deg, #0f172a 0%, #1d4ed8 60%, #3b82f6 100%);
      border-radius: 20px;
      padding: 30px 34px;
      color: #ffffff;
      margin-bottom: 24px;
      box-shadow: 0 12px 28px rgba(29, 78, 216, 0.18);
      display: flex;
      flex-wrap: wrap;
      align-items: center;
      justify-content: space-between;
      gap: 20px;
    }

    .qsl-hero__eyebrow {
      display: inline-block;
      font-size: 0.76rem;
      font-weight: 800;
      text-transform: uppercase;
      letter-spacing: 0.08em;
      background: rgba(255, 255, 255, 0.2);
      padding: 5px 12px;
      border-radius: 999px;
      margin-bottom: 8px;
    }

    .qsl-hero__title {
      font-size: 1.8rem;
      font-weight: 800;
      margin: 0 0 6px;
    }

    .qsl-hero__sub {
      font-size: 0.94rem;
      margin: 0;
      opacity: 0.9;
    }

    .qsl-toolbar {
      background: #ffffff;
      border: 1px solid #e2e8f0;
      border-radius: 14px;
      padding: 14px 18px;
      margin-bottom: 20px;
      display: flex;
      flex-wrap: wrap;
      align-items: center;
      justify-content: space-between;
      gap: 12px;
    }

    .qsl-search {
      padding: 9px 14px;
      border: 1px solid #cbd5e1;
      border-radius: 10px;
      font-size: 0.88rem;
      min-width: 260px;
      outline: none;
    }

    .qsl-search:focus {
      border-color: #2563eb;
      box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.12);
    }

    .qsl-grid {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(340px, 1fr));
      gap: 20px;
    }

    .qsl-card {
      background: #ffffff;
      border: 1px solid #e2e8f0;
      border-radius: 16px;
      padding: 22px;
      display: flex;
      flex-direction: column;
      justify-content: space-between;
      box-shadow: 0 2px 8px rgba(15, 23, 42, 0.04);
      transition: transform 0.18s ease, box-shadow 0.18s ease, border-color 0.18s ease;
    }

    .qsl-card:hover {
      transform: translateY(-3px);
      box-shadow: 0 10px 24px rgba(15, 23, 42, 0.08);
      border-color: #93c5fd;
    }

    .qsl-meta-list {
      display: flex;
      flex-wrap: wrap;
      gap: 8px;
      margin: 12px 0 18px;
    }

    .qsl-meta-pill {
      display: inline-flex;
      align-items: center;
      gap: 4px;
      background: #f8fafc;
      border: 1px solid #e2e8f0;
      color: #475569;
      font-size: 0.8rem;
      font-weight: 600;
      padding: 4px 10px;
      border-radius: 999px;
    }
  </style>
</head>
<body>
<jsp:include page="/WEB-INF/views/common/navbar.jsp"/>

<div class="quiz-page-wrap">
  <main class="quiz-shell">
    <a class="quiz-back-link" href="${pageContext.request.contextPath}/courses/${courseId}/learn">
      <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
        <path d="M19 12H5M12 19l-7-7 7-7"/>
      </svg>
      Quay lại khóa học
    </a>

    <!-- Hero Banner -->
    <section class="qsl-hero">
      <div>
        <span class="qsl-hero__eyebrow">❓ Không gian học viên · UC26</span>
        <h1 class="qsl-hero__title">Danh sách bài kiểm tra &amp; đánh giá</h1>
        <p class="qsl-hero__sub">
          Các bài kiểm tra trắc nghiệm và tự luận giúp củng cố kiến thức đã học trong khóa học.
        </p>
      </div>
      <div style="text-align:right">
        <div style="font-size:0.8rem;opacity:0.85">Tổng số bài kiểm tra</div>
        <div style="font-size:2rem;font-weight:800">${fn:length(quizzes)}</div>
      </div>
    </section>

    <c:choose>
      <c:when test="${empty quizzes}">
        <div class="quiz-card" style="text-align:center; padding:48px 20px;">
          <div style="font-size:3rem; margin-bottom:12px;">📚</div>
          <h3 style="font-size:1.2rem; font-weight:700; color:#0F172A; margin-bottom:8px;">
            Chưa có bài kiểm tra
          </h3>
          <p style="color:#64748B; font-size:.92rem; max-width:460px; margin:0 auto 20px;">
            Giảng viên chưa công bố bài kiểm tra nào cho khóa học này. Vui lòng quay lại sau!
          </p>
          <a class="quiz-btn quiz-btn--primary" href="${pageContext.request.contextPath}/courses/${courseId}/learn">
            Tiếp tục học bài giảng
          </a>
        </div>
      </c:when>

      <c:otherwise>
        <div class="qsl-toolbar">
          <div style="font-size:0.88rem;font-weight:600;color:#475569">
            Hiển thị <strong>${fn:length(quizzes)}</strong> bài kiểm tra đang mở
          </div>
          <input type="text" id="qslSearchInput" class="qsl-search"
                 placeholder="Tìm theo tên bài kiểm tra..."
                 oninput="filterStudentQuizzes()">
        </div>

        <div class="qsl-grid" id="qslQuizGrid">
          <c:forEach var="q" items="${quizzes}">
            <div class="qsl-card" data-title="${fn:toLowerCase(q.title)}">
              <div>
                <div style="display:flex; align-items:center; justify-content:space-between; margin-bottom:12px;">
                  <span class="quiz-badge quiz-badge--submitted">📝 Bài kiểm tra</span>
                  <c:if test="${q.timeLimitMinutes != null}">
                    <span style="font-size:.8rem; font-weight:600; color:#64748B;">⏱ ${q.timeLimitMinutes} phút</span>
                  </c:if>
                </div>

                <h3 style="font-size:1.15rem; font-weight:800; color:#0F172A; margin:0 0 8px; line-height:1.4;">
                  <a href="${pageContext.request.contextPath}/courses/${courseId}/quizzes/${q.quizId}"
                     style="color:#0F172A; text-decoration:none;">
                    <c:out value="${q.title}"/>
                  </a>
                </h3>

                <div class="qsl-meta-list">
                  <span class="qsl-meta-pill">🔢 <strong>${q.questionCount}</strong> câu hỏi</span>
                  <span class="qsl-meta-pill">
                    🎯 Tối đa <strong><fmt:formatNumber value="${q.maxScore}" maxFractionDigits="1"/></strong> điểm
                  </span>
                  <span class="qsl-meta-pill">🔄 Không giới hạn lượt làm</span>
                </div>
              </div>

              <div style="padding-top:14px; border-top:1px solid #F1F5F9;">
                <a class="quiz-btn quiz-btn--primary" style="width:100%;"
                   href="${pageContext.request.contextPath}/courses/${courseId}/quizzes/${q.quizId}">
                  Vào xem &amp; làm bài →
                </a>
              </div>
            </div>
          </c:forEach>
        </div>
      </c:otherwise>
    </c:choose>
  </main>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>

<script>
  function filterStudentQuizzes() {
    var input = document.getElementById('qslSearchInput');
    var q = input ? input.value.trim().toLowerCase() : '';
    var cards = document.querySelectorAll('#qslQuizGrid .qsl-card');
    for (var i = 0; i < cards.length; i++) {
      var title = cards[i].getAttribute('data-title') || '';
      cards[i].style.display = (!q || title.indexOf(q) !== -1) ? '' : 'none';
    }
  }
</script>
</body>
</html>
