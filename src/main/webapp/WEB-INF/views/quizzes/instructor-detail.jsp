<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Chi tiết Quiz — <c:out value="${quiz.title}"/> — EduSphere</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/home.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/instructor.css">
  <style>
    .qid-meta-cards {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
      gap: 14px;
      margin-bottom: 20px;
    }

    .qid-meta-card {
      background: #ffffff;
      border: 1px solid #e5e7eb;
      border-radius: 12px;
      padding: 14px 18px;
    }

    .qid-meta-label {
      font-size: 0.78rem;
      font-weight: 600;
      color: #6b7280;
      margin-bottom: 4px;
    }

    .qid-meta-value {
      font-size: 1.15rem;
      font-weight: 800;
      color: #111827;
    }

    .qid-question-card {
      background: #ffffff;
      border: 1px solid #e5e7eb;
      border-radius: 14px;
      padding: 18px 20px;
      margin-bottom: 12px;
    }
  </style>
</head>
<body>
<div class="ins-layout">
  <jsp:include page="/WEB-INF/views/courses/ins-sidebar.jsp"/>
  <div class="ins-main-wrapper">
    <jsp:include page="/WEB-INF/views/courses/ins-header.jsp"/>
    <main class="ins-page">
      <a class="ins-back-link" href="${pageContext.request.contextPath}/instructor/courses/${courseId}/quizzes">
        ← Danh sách quiz
      </a>

      <div class="ins-page-head">
        <div>
          <span class="ins-page-head__eyebrow">❓ Quản lý đề Quiz · ${quiz.status}</span>
          <h1 class="ins-page-head__title"><c:out value="${quiz.title}"/></h1>
        </div>
        <div style="display:flex;gap:8px;flex-wrap:wrap">
          <c:if test="${quiz.status eq 'DRAFT'}">
            <a class="ins-btn-primary" style="width:auto;padding:10px 22px"
               href="${pageContext.request.contextPath}/instructor/courses/${courseId}/quizzes/${quizId}/questions/new">
              + Thêm câu hỏi
            </a>
            <form method="post" action="${pageContext.request.contextPath}/instructor/courses/${courseId}/quizzes/${quizId}/publish">
              <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
              <button type="submit" class="ins-link-btn ins-link-btn--success" style="padding:10px 20px">
                🚀 Công bố
              </button>
            </form>
          </c:if>
          <a class="ins-link-btn" style="padding:10px 20px"
             href="${pageContext.request.contextPath}/instructor/courses/${courseId}/quizzes/${quizId}/attempts">
            📋 Danh sách bài làm
          </a>
        </div>
      </div>

      <c:if test="${not empty success}">
        <div class="ins-alert ins-alert--success">✅ <c:out value="${success}"/></div>
      </c:if>

      <section class="qid-meta-cards">
        <div class="qid-meta-card">
          <div class="qid-meta-label">Tổng số câu hỏi</div>
          <div class="qid-meta-value">${fn:length(questions)} câu</div>
        </div>
        <div class="qid-meta-card">
          <div class="qid-meta-label">Số lượt làm bài</div>
          <div class="qid-meta-value">Không giới hạn</div>
        </div>
        <div class="qid-meta-card">
          <div class="qid-meta-label">Thời gian làm bài</div>
          <div class="qid-meta-value">
            <c:choose>
              <c:when test="${quiz.timeLimitMinutes != null}">${quiz.timeLimitMinutes} phút</c:when>
              <c:otherwise>Không giới hạn</c:otherwise>
            </c:choose>
          </div>
        </div>
      </section>

      <c:if test="${not empty quiz.description}">
        <div style="background:#ffffff;border:1px solid #e5e7eb;border-radius:12px;padding:14px 18px;margin-bottom:18px;white-space:pre-wrap">
          <c:out value="${quiz.description}"/>
        </div>
      </c:if>

      <c:choose>
        <c:when test="${empty questions}">
          <div class="ins-empty">
            <div class="ins-empty__icon">❓</div>
            <h3>Chưa có câu hỏi</h3>
            <p>Thêm câu hỏi trước khi công bố quiz cho học viên.</p>
          </div>
        </c:when>
        <c:otherwise>
          <div>
            <c:forEach var="q" items="${questions}">
              <div class="qid-question-card">
                <div style="display:flex;justify-content:space-between;align-items:flex-start;gap:12px;margin-bottom:8px">
                  <div style="font-weight:800;font-size:1rem;color:#0f172a">
                    Câu ${q.orderIndex}. <c:out value="${q.content}"/>
                  </div>
                  <span style="font-size:0.78rem;font-weight:700;background:#eff6ff;color:#2563eb;padding:4px 10px;border-radius:999px">
                    ${q.type} · <fmt:formatNumber value="${q.score}" maxFractionDigits="1"/> điểm
                  </span>
                </div>

                <c:if test="${not empty q.options}">
                  <ul style="margin:8px 0 0 18px">
                    <c:forEach var="o" items="${q.options}">
                      <li style="margin-bottom:4px">
                        <c:out value="${o.content}"/>
                        <c:if test="${o.correct}">
                          <strong style="color:#16a34a"> ✔ Đáp án đúng</strong>
                        </c:if>
                      </li>
                    </c:forEach>
                  </ul>
                </c:if>

                <c:if test="${q.type eq 'TRUE_FALSE' || q.type eq 'SHORT_ANSWER'}">
                  <div class="small" style="margin-top:6px">
                    Đáp án chuẩn: <strong><c:out value="${q.correctAnswer}"/></strong>
                  </div>
                </c:if>

                <c:if test="${not empty q.explanation}">
                  <div class="small" style="margin-top:6px;color:#475569">
                    💡 Giải thích: <c:out value="${q.explanation}"/>
                  </div>
                </c:if>
              </div>
            </c:forEach>
          </div>
        </c:otherwise>
      </c:choose>
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
</script>
</body>
</html>
