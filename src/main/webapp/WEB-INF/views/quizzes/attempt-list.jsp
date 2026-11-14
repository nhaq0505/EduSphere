<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Danh sách bài làm Quiz — <c:out value="${quiz.title}"/> — EduSphere</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/home.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/instructor.css">
  <style>
    .qal-toolbar {
      background: #ffffff;
      border: 1px solid #e5e7eb;
      border-radius: 14px;
      padding: 14px 18px;
      margin-bottom: 18px;
      display: flex;
      flex-wrap: wrap;
      align-items: center;
      justify-content: space-between;
      gap: 12px;
    }

    .qal-chips {
      display: flex;
      flex-wrap: wrap;
      gap: 8px;
    }

    .qal-chip {
      border: 1px solid #d1d5db;
      background: #f9fafb;
      color: #4b5563;
      padding: 6px 13px;
      border-radius: 999px;
      font-size: 0.82rem;
      font-weight: 600;
      cursor: pointer;
    }

    .qal-chip.active {
      background: #2563eb;
      border-color: #2563eb;
      color: #ffffff;
    }

    .qal-search {
      padding: 8px 14px;
      border: 1px solid #d1d5db;
      border-radius: 10px;
      font-size: 0.86rem;
      min-width: 240px;
      outline: none;
    }

    .qal-table-wrap {
      background: #ffffff;
      border: 1px solid #e5e7eb;
      border-radius: 14px;
      overflow: hidden;
      box-shadow: 0 2px 8px rgba(15, 23, 42, 0.04);
    }

    .qal-table {
      width: 100%;
      border-collapse: collapse;
    }

    .qal-table th {
      background: #f8fafc;
      color: #475569;
      font-size: 0.78rem;
      font-weight: 700;
      text-transform: uppercase;
      padding: 12px 16px;
      text-align: left;
      border-bottom: 1px solid #e2e8f0;
    }

    .qal-table td {
      padding: 14px 16px;
      border-bottom: 1px solid #f1f5f9;
      font-size: 0.9rem;
    }
  </style>
</head>
<body>
<div class="ins-layout">
  <jsp:include page="../courses/ins-sidebar.jsp"/>
  <div class="ins-main-wrapper">
    <jsp:include page="../courses/ins-header.jsp"/>
    <main class="ins-page">
      <a class="ins-back-link" href="${pageContext.request.contextPath}/instructor/courses/${courseId}/quizzes/${quizId}">
        ← Chi tiết quiz
      </a>

      <div class="ins-page-head">
        <div>
          <span class="ins-page-head__eyebrow">❓ Quản lý bài làm Quiz · UC28</span>
          <h1 class="ins-page-head__title"><c:out value="${quiz.title}"/></h1>
          <p class="ins-page-head__sub">Tổng số lượt nộp bài: <strong>${fn:length(attempts)}</strong></p>
        </div>
      </div>

      <c:choose>
        <c:when test="${empty attempts}">
          <div class="ins-empty">
            <div class="ins-empty__icon">📋</div>
            <h3>Chưa có bài làm nào</h3>
            <p>Khi học viên hoàn thành bài kiểm tra quiz này, danh sách bài làm sẽ hiển thị tại đây.</p>
          </div>
        </c:when>
        <c:otherwise>
          <div class="qal-toolbar">
            <div class="qal-chips" id="qalFilterChips">
              <button type="button" class="qal-chip active" onclick="filterQuizAttempts('ALL', this)">
                Tất cả (${fn:length(attempts)})
              </button>
              <button type="button" class="qal-chip" onclick="filterQuizAttempts('SUBMITTED', this)">
                📝 Chờ chấm tự luận
              </button>
              <button type="button" class="qal-chip" onclick="filterQuizAttempts('PUBLISHED', this)">
                ✅ Đã công bố
              </button>
            </div>
            <input type="text" id="qalSearchInput" class="qal-search"
                   placeholder="Tìm theo tên học viên..."
                   oninput="applyQuizAttemptFilter()">
          </div>

          <div class="qal-table-wrap">
            <table class="qal-table" id="qalTable">
              <thead>
                <tr>
                  <th>Học viên</th>
                  <th>Lần làm</th>
                  <th>Thời gian nộp</th>
                  <th>Điểm số</th>
                  <th>Trạng thái</th>
                  <th>Thao tác</th>
                </tr>
              </thead>
              <tbody>
                <c:forEach var="a" items="${attempts}">
                  <tr class="qal-row"
                      data-status="${a.status}"
                      data-result="${a.resultStatus}"
                      data-student="${fn:toLowerCase(a.studentName)}">
                    <td><strong><c:out value="${a.studentName}"/></strong></td>
                    <td>Lần ${a.attemptNumber}</td>
                    <td>
                      <c:if test="${a.submittedAt != null}">
                        ${fn:replace(fn:substring(a.submittedAt, 0, 16), 'T', ' ')}
                      </c:if>
                    </td>
                    <td>
                      <c:choose>
                        <c:when test="${a.score != null}">
                          <strong><fmt:formatNumber value="${a.score}" maxFractionDigits="2"/></strong>
                          / <fmt:formatNumber value="${a.maxScore}" maxFractionDigits="2"/>
                        </c:when>
                        <c:otherwise>—</c:otherwise>
                      </c:choose>
                    </td>
                    <td>
                      <c:choose>
                        <c:when test="${a.status eq 'SCORED' or a.resultStatus eq 'PUBLISHED'}">
                          <span style="color:#10B981;font-weight:700;">✅ Đã công bố</span>
                        </c:when>
                        <c:when test="${a.status eq 'SUBMITTED'}">
                          <span style="color:#2563EB;font-weight:700;">📝 Chờ chấm tự luận</span>
                        </c:when>
                        <c:otherwise>${a.status} · Chưa nộp</c:otherwise>
                      </c:choose>
                    </td>
                    <td>
                      <a class="ins-link-btn ins-link-btn--primary"
                         href="${pageContext.request.contextPath}/instructor/courses/${courseId}/quizzes/${quizId}/attempts/${a.attemptId}">
                        Xem / Chấm điểm
                      </a>
                    </td>
                  </tr>
                </c:forEach>
              </tbody>
            </table>
          </div>
        </c:otherwise>
      </c:choose>
    </main>
  </div>
</div>
<script>
  var currentAttemptFilter = 'ALL';

  function filterQuizAttempts(mode, btn) {
    currentAttemptFilter = mode;
    var chips = document.querySelectorAll('#qalFilterChips .qal-chip');
    for (var i = 0; i < chips.length; i++) {
      chips[i].classList.remove('active');
    }
    if (btn) {
      btn.classList.add('active');
    }
    applyQuizAttemptFilter();
  }

  function applyQuizAttemptFilter() {
    var input = document.getElementById('qalSearchInput');
    var q = input ? input.value.trim().toLowerCase() : '';
    var rows = document.querySelectorAll('#qalTable tbody .qal-row');
    for (var i = 0; i < rows.length; i++) {
      var tr = rows[i];
      var st = tr.getAttribute('data-status') || '';
      var res = tr.getAttribute('data-result') || '';
      var student = tr.getAttribute('data-student') || '';

      var matchMode = true;
      if (currentAttemptFilter === 'SUBMITTED') {
        matchMode = (st === 'SUBMITTED');
      } else if (currentAttemptFilter === 'PUBLISHED') {
        matchMode = (st === 'SCORED' || res === 'PUBLISHED');
      }
      var matchSearch = !q || student.indexOf(q) !== -1;
      tr.style.display = (matchMode && matchSearch) ? '' : 'none';
    }
  }

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
