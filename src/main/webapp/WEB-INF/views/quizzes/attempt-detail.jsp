<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Chi tiết bài làm Quiz — <c:out value="${attempt.student.fullName}"/> — EduSphere</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/home.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/instructor.css">
  <style>
    .qad-summary-bar {
      background: #ffffff;
      border: 1px solid #e5e7eb;
      border-radius: 14px;
      padding: 18px 22px;
      margin-bottom: 20px;
      display: flex;
      flex-wrap: wrap;
      align-items: center;
      justify-content: space-between;
      gap: 16px;
    }

    .qad-score-big {
      font-size: 1.75rem;
      font-weight: 800;
      color: #1d4ed8;
    }

    .qad-answer-card {
      background: #ffffff;
      border: 1px solid #e5e7eb;
      border-radius: 14px;
      padding: 18px 22px;
      margin-bottom: 14px;
      box-shadow: 0 2px 6px rgba(15, 23, 42, 0.03);
    }

    .qad-answer-head {
      display: flex;
      flex-wrap: wrap;
      align-items: center;
      justify-content: space-between;
      gap: 10px;
      margin-bottom: 10px;
    }

    .qad-answer-box {
      background: #f8fafc;
      border: 1px solid #e2e8f0;
      border-radius: 10px;
      padding: 12px 14px;
      margin: 8px 0 12px;
    }
  </style>
</head>
<body>
<div class="ins-layout">
  <jsp:include page="../courses/ins-sidebar.jsp"/>
  <div class="ins-main-wrapper">
    <jsp:include page="../courses/ins-header.jsp"/>
    <main class="ins-page">
      <a class="ins-back-link" href="${pageContext.request.contextPath}/instructor/courses/${courseId}/quizzes/${quizId}/attempts">
        ← Danh sách bài làm
      </a>

      <div class="ins-page-head">
        <div>
          <span class="ins-page-head__eyebrow">❓ Chấm bài Quiz · Lần ${attempt.attemptNumber} · ${attempt.status}</span>
          <h1 class="ins-page-head__title"><c:out value="${attempt.student.fullName}"/></h1>
        </div>
        <div>
          <c:if test="${attempt.status eq 'SCORED' && attempt.resultStatus ne 'PUBLISHED'}">
            <form method="post" action="${pageContext.request.contextPath}/instructor/courses/${courseId}/quizzes/${quizId}/attempts/${attempt.attemptId}/publish">
              <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
              <button type="submit" class="ins-btn-primary" style="width:auto;padding:10px 22px">
                🚀 Công bố kết quả
              </button>
            </form>
          </c:if>
        </div>
      </div>

      <c:if test="${not empty success}">
        <div class="ins-alert ins-alert--success">✅ <c:out value="${success}"/></div>
      </c:if>

      <section class="qad-summary-bar">
        <div>
          <div style="font-size:0.82rem;color:#64748b;font-weight:600">Tổng điểm đạt được</div>
          <div class="qad-score-big">
            <c:choose>
              <c:when test="${attempt.score != null}">
                <fmt:formatNumber value="${attempt.score}" maxFractionDigits="2"/>
              </c:when>
              <c:otherwise>—</c:otherwise>
            </c:choose>
            <span style="font-size:1.05rem;color:#64748b;font-weight:600">
              / <fmt:formatNumber value="${attempt.maxScore}" maxFractionDigits="2"/> điểm
            </span>
          </div>
        </div>

        <div>
          <div style="font-size:0.82rem;color:#64748b;font-weight:600">Trạng thái công bố</div>
          <div style="font-size:0.98rem;font-weight:700;margin-top:4px">
            <c:choose>
              <c:when test="${attempt.status eq 'SCORED' or attempt.resultStatus eq 'PUBLISHED'}">
                <span style="color:#059669">✅ Đã công bố cho học viên</span>
              </c:when>
              <c:when test="${attempt.status eq 'SUBMITTED'}">
                <span style="color:#d97706">📝 Đã chấm trắc nghiệm (Chờ chấm câu tự luận)</span>
              </c:when>
              <c:otherwise>Chưa công bố</c:otherwise>
            </c:choose>
          </div>
        </div>
      </section>

      <c:if test="${attempt.status eq 'SUBMITTED'}">
        <div class="ins-alert" style="margin-bottom:18px">
          💡 Bài làm còn câu hỏi tự luận chưa chấm điểm. Sau khi bạn chấm hết các câu tự luận bên dưới, điểm tổng kết sẽ tự động được cập nhật và công bố.
        </div>
      </c:if>

      <div>
        <c:forEach var="a" items="${answers}" varStatus="st">
          <div class="qad-answer-card">
            <div class="qad-answer-head">
              <div style="font-weight:800;font-size:1rem;color:#0f172a">
                Câu ${st.count}. <c:out value="${a.questionContentSnapshot}"/>
              </div>
              <span style="font-size:0.78rem;font-weight:700;background:#f1f5f9;color:#475569;padding:4px 10px;border-radius:999px">
                ${a.questionTypeSnapshot} · Tối đa <fmt:formatNumber value="${a.maxScore}" maxFractionDigits="1"/> điểm
              </span>
            </div>

            <div class="qad-answer-box">
              <c:choose>
                <c:when test="${not empty a.selectedOptions}">
                  <div style="font-size:0.8rem;font-weight:700;color:#64748b;margin-bottom:4px">Lựa chọn của học viên:</div>
                  <ul style="margin:0 0 0 18px;padding:0">
                    <c:forEach var="so" items="${a.selectedOptions}">
                      <li><c:out value="${so.optionContentSnapshot}"/></li>
                    </c:forEach>
                  </ul>
                </c:when>
                <c:otherwise>
                  <div style="font-size:0.8rem;font-weight:700;color:#64748b;margin-bottom:4px">Bài trả lời của học viên:</div>
                  <p style="white-space:pre-wrap;margin:0;color:#1e293b">
                    <c:out value="${a.answerText}" default="(Học viên bỏ trống câu này)"/>
                  </p>
                </c:otherwise>
              </c:choose>
            </div>

            <div>
              <c:choose>
                <c:when test="${a.questionTypeSnapshot eq 'SHORT_ANSWER' || a.questionTypeSnapshot eq 'ESSAY'}">
                  <c:if test="${a.question != null and not empty a.question.sampleEssayAnswer}">
                    <div style="margin-bottom:10px;padding:10px 14px;background:#fdf4ff;border-left:4px solid #c026d3;border-radius:6px;font-size:0.85rem;color:#86198f">
                      💡 <strong>Gợi ý đáp án / Tiêu chí chấm:</strong> <c:out value="${a.question.sampleEssayAnswer}"/>
                    </div>
                  </c:if>
                  <form method="post" style="display:flex;gap:10px;align-items:center;flex-wrap:wrap"
                        action="${pageContext.request.contextPath}/instructor/courses/${courseId}/quizzes/${quizId}/attempts/${attempt.attemptId}/answers/${a.answerId}/grade">
                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                    <label style="font-weight:700;font-size:0.88rem">Điểm chấm (tối đa ${a.maxScore}):</label>
                    <input class="ins-input" type="number" name="score" min="0" max="${a.maxScore}" step="0.25" required
                           value="${a.awardedScore}" style="width:110px">
                    <button type="submit" class="ins-link-btn ins-link-btn--primary">💾 Lưu điểm câu này</button>
                  </form>
                </c:when>
                <c:otherwise>
                  <div style="font-size:0.88rem;color:#334155">
                    Điểm tự động: <strong><fmt:formatNumber value="${a.awardedScore}" maxFractionDigits="2"/> / <fmt:formatNumber value="${a.maxScore}" maxFractionDigits="1"/></strong>
                  </div>
                </c:otherwise>
              </c:choose>
            </div>
          </div>
        </c:forEach>
      </div>
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
