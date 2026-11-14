<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Công bố kết quả học tập — <c:out value="${course.title}"/> — EduSphere</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/home.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/instructor.css">
  <style>
    .ir-stats-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
      gap: 16px;
      margin-bottom: 24px;
    }

    .ir-stat-card {
      background: #ffffff;
      border: 1px solid #e5e7eb;
      border-radius: 14px;
      padding: 18px 20px;
      box-shadow: 0 2px 6px rgba(15, 23, 42, 0.03);
    }

    .ir-stat-card__label {
      font-size: 0.82rem;
      font-weight: 600;
      color: #6b7280;
      margin-bottom: 6px;
      display: flex;
      align-items: center;
      justify-content: space-between;
    }

    .ir-stat-card__value {
      font-size: 1.6rem;
      font-weight: 800;
      color: #111827;
      line-height: 1.2;
    }

    .ir-stat-card__sub {
      font-size: 0.78rem;
      color: #6b7280;
      margin-top: 4px;
    }

    .ir-actions-bar {
      display: flex;
      flex-wrap: wrap;
      align-items: center;
      justify-content: space-between;
      gap: 12px;
      background: #ffffff;
      border: 1px solid #e5e7eb;
      border-radius: 14px;
      padding: 14px 18px;
      margin-bottom: 20px;
    }

    .ir-filter-group {
      display: flex;
      flex-wrap: wrap;
      align-items: center;
      gap: 8px;
    }

    .ir-chip {
      border: 1px solid #d1d5db;
      background: #f9fafb;
      color: #4b5563;
      padding: 7px 13px;
      border-radius: 999px;
      font-size: 0.83rem;
      font-weight: 600;
      cursor: pointer;
      transition: all 0.15s ease;
    }

    .ir-chip:hover {
      border-color: #9ca3af;
      color: #111827;
    }

    .ir-chip.active {
      background: #2563eb;
      border-color: #2563eb;
      color: #ffffff;
    }

    .ir-search-input {
      padding: 8px 14px;
      border: 1px solid #d1d5db;
      border-radius: 10px;
      font-size: 0.86rem;
      min-width: 240px;
      outline: none;
    }

    .ir-search-input:focus {
      border-color: #2563eb;
      box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.12);
    }

    .ir-table-card {
      background: #ffffff;
      border: 1px solid #e5e7eb;
      border-radius: 14px;
      overflow: hidden;
      box-shadow: 0 2px 8px rgba(15, 23, 42, 0.04);
      margin-bottom: 28px;
    }

    .ir-table {
      width: 100%;
      border-collapse: collapse;
    }

    .ir-table th {
      background: #f8fafc;
      color: #475569;
      font-size: 0.78rem;
      font-weight: 700;
      text-transform: uppercase;
      letter-spacing: 0.04em;
      padding: 12px 16px;
      text-align: left;
      border-bottom: 1px solid #e2e8f0;
    }

    .ir-table td {
      padding: 14px 16px;
      border-bottom: 1px solid #f1f5f9;
      font-size: 0.9rem;
      color: #1e293b;
      vertical-align: middle;
    }

    .ir-table tbody tr:hover {
      background: #f8fafc;
    }

    .ir-kind-badge {
      display: inline-flex;
      align-items: center;
      gap: 5px;
      padding: 4px 10px;
      border-radius: 999px;
      font-size: 0.76rem;
      font-weight: 700;
    }

    .ir-kind-badge--quiz {
      background: #f5f3ff;
      color: #7c3aed;
    }

    .ir-kind-badge--assignment {
      background: #eff6ff;
      color: #2563eb;
    }

    .ir-score-pill {
      font-weight: 700;
      color: #0f172a;
    }

    .ir-score-pct {
      display: inline-block;
      margin-left: 6px;
      font-size: 0.76rem;
      font-weight: 600;
      color: #64748b;
    }

    .ir-btn-outline {
      display: inline-flex;
      align-items: center;
      gap: 6px;
      padding: 8px 14px;
      border-radius: 10px;
      border: 1px solid #d1d5db;
      background: #ffffff;
      color: #374151;
      font-size: 0.84rem;
      font-weight: 600;
      text-decoration: none;
      cursor: pointer;
    }

    .ir-btn-outline:hover {
      background: #f9fafb;
      border-color: #9ca3af;
    }

    .ir-leaderboard-card {
      background: #ffffff;
      border: 1px solid #e5e7eb;
      border-radius: 14px;
      padding: 20px;
      margin-top: 24px;
    }

    .ir-leaderboard-title {
      font-size: 1.05rem;
      font-weight: 800;
      margin: 0 0 14px;
      color: #111827;
    }
  </style>
</head>
<body>
<div class="ins-layout">
  <jsp:include page="/WEB-INF/views/courses/ins-sidebar.jsp"/>
  <div class="ins-main-wrapper">
    <jsp:include page="/WEB-INF/views/courses/ins-header.jsp"/>
    <main class="ins-page">
      <a class="ins-back-link" href="${pageContext.request.contextPath}/instructor/courses/${courseId}/lessons">
        ← Quản lý bài học
      </a>

      <div class="ins-page-head">
        <div>
          <span class="ins-page-head__eyebrow">📊 Kết quả học tập · UC32</span>
          <h1 class="ins-page-head__title">Quản lý &amp; Công bố kết quả</h1>
          <p class="ins-page-head__sub"><c:out value="${course.title}"/></p>
        </div>
        <div style="display:flex;flex-wrap:wrap;gap:10px;align-items:center">
          <a class="ir-btn-outline"
             href="${pageContext.request.contextPath}/instructor/courses/${courseId}/results/export-csv">
            📥 Xuất bảng điểm CSV
          </a>
          <form method="post"
                action="${pageContext.request.contextPath}/instructor/courses/${courseId}/results/publish-all"
                onsubmit="return confirm('Công bố tất cả kết quả đã chấm xong?')">
            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
            <button type="submit" class="ins-btn-primary" style="width:auto;padding:10px 22px">
              🚀 Công bố tất cả đã chấm
            </button>
          </form>
        </div>
      </div>

      <c:if test="${not empty success}">
        <div class="ins-alert ins-alert--success">✅ <c:out value="${success}"/></div>
      </c:if>

      <!-- Gradebook Analytics Summary Cards -->
      <c:if test="${not empty gradebookStats}">
        <section class="ir-stats-grid">
          <div class="ir-stat-card">
            <div class="ir-stat-card__label">
              <span>Tổng bài làm</span>
              <span>📋</span>
            </div>
            <div class="ir-stat-card__value">${gradebookStats.totalCount}</div>
            <div class="ir-stat-card__sub">
              Quiz: <strong>${gradebookStats.quizCount}</strong> · Bài tập: <strong>${gradebookStats.assignmentCount}</strong>
            </div>
          </div>

          <div class="ir-stat-card">
            <div class="ir-stat-card__label">
              <span>Đã công bố</span>
              <span>✅</span>
            </div>
            <div class="ir-stat-card__value" style="color:#059669">${gradebookStats.publishedCount}</div>
            <div class="ir-stat-card__sub">
              Sẵn sàng công bố: <strong>${gradebookStats.readyCount}</strong> · Chưa chấm: <strong>${gradebookStats.notGradedCount}</strong>
            </div>
          </div>

          <div class="ir-stat-card">
            <div class="ir-stat-card__label">
              <span>Điểm trung bình lớp</span>
              <span>📈</span>
            </div>
            <div class="ir-stat-card__value" style="color:#2563eb">
              <fmt:formatNumber value="${gradebookStats.averagePercent}" maxFractionDigits="1"/>%
            </div>
            <div class="ir-stat-card__sub">
              Tỷ lệ đạt (≥50%): <strong><fmt:formatNumber value="${gradebookStats.passRatePercent}" maxFractionDigits="1"/>%</strong>
            </div>
          </div>

          <div class="ir-stat-card">
            <div class="ir-stat-card__label">
              <span>Phân bố học lực</span>
              <span>🎓</span>
            </div>
            <div class="ir-stat-card__value">${gradebookStats.excellentCount} <span style="font-size:0.85rem;font-weight:600;color:#6b7280">Xuất sắc</span></div>
            <div class="ir-stat-card__sub">
              Khá giỏi: <strong>${gradebookStats.goodCount}</strong> · Đạt: <strong>${gradebookStats.averageTierCount}</strong> · Chưa đạt: <strong>${gradebookStats.belowAverageCount}</strong>
            </div>
          </div>
        </section>
      </c:if>

      <c:choose>
        <c:when test="${empty rows}">
          <div class="ins-empty">
            <div class="ins-empty__icon">📊</div>
            <h3>Chưa có bài nộp hay bài làm nào</h3>
            <p>Khi học viên nộp bài tập hoặc hoàn thành quiz, kết quả sẽ hiển thị tại đây để bạn duyệt và công bố.</p>
          </div>
        </c:when>
        <c:otherwise>
          <!-- Interactive Filter & Search Bar -->
          <div class="ir-actions-bar">
            <div class="ir-filter-group" id="irFilterChips">
              <button type="button" class="ir-chip active" onclick="filterInstructorRows('ALL', this)">
                Tất cả (${fn:length(rows)})
              </button>
              <button type="button" class="ir-chip" onclick="filterInstructorRows('READY', this)">
                ⏳ Sẵn sàng công bố
              </button>
              <button type="button" class="ir-chip" onclick="filterInstructorRows('NOT_GRADED', this)">
                ✏️ Cần chấm điểm
              </button>
              <button type="button" class="ir-chip" onclick="filterInstructorRows('PUBLISHED', this)">
                ✅ Đã công bố
              </button>
              <button type="button" class="ir-chip" onclick="filterInstructorRows('QUIZ', this)">
                ❓ Chỉ Quiz
              </button>
              <button type="button" class="ir-chip" onclick="filterInstructorRows('ASSIGNMENT', this)">
                📝 Chỉ Bài tập
              </button>
            </div>
            <div>
              <input type="text" id="irSearchBox" class="ir-search-input"
                     placeholder="Tìm học viên hoặc tên bài..."
                     oninput="applyInstructorTableFilter()">
            </div>
          </div>

          <div class="ir-table-card">
            <table class="ir-table" id="irResultsTable">
              <thead>
                <tr>
                  <th>Loại</th>
                  <th>Nội dung đánh giá</th>
                  <th>Học viên</th>
                  <th>Lần nộp</th>
                  <th>Điểm số</th>
                  <th>Thời gian nộp</th>
                  <th>Trạng thái</th>
                  <th>Thao tác</th>
                </tr>
              </thead>
              <tbody>
                <c:forEach var="r" items="${rows}">
                  <tr class="ir-row"
                      data-kind="${r.kind}"
                      data-state="${r.state}"
                      data-search="${fn:toLowerCase(r.title)} ${fn:toLowerCase(r.studentName)}">
                    <td>
                      <span class="ir-kind-badge ${r.kind eq 'QUIZ' ? 'ir-kind-badge--quiz' : 'ir-kind-badge--assignment'}">
                        ${r.kind eq 'QUIZ' ? '❓ Quiz' : '📝 Bài tập'}
                      </span>
                    </td>
                    <td>
                      <strong><c:out value="${r.title}"/></strong>
                    </td>
                    <td>
                      <c:out value="${r.studentName}"/>
                    </td>
                    <td>Lần ${r.attemptNumber}</td>
                    <td>
                      <c:choose>
                        <c:when test="${r.score != null}">
                          <span class="ir-score-pill">
                            <fmt:formatNumber value="${r.score}" maxFractionDigits="2"/> / <fmt:formatNumber value="${r.maxScore}" maxFractionDigits="2"/>
                          </span>
                          <c:if test="${r.scorePercent != null}">
                            <span class="ir-score-pct">(<fmt:formatNumber value="${r.scorePercent}" maxFractionDigits="0"/>%)</span>
                          </c:if>
                        </c:when>
                        <c:otherwise>—</c:otherwise>
                      </c:choose>
                    </td>
                    <td style="font-size:0.82rem;color:#64748b">
                      <c:choose>
                        <c:when test="${r.submittedAt != null}">
                          ${fn:replace(fn:substring(r.submittedAt, 0, 16), 'T', ' ')}
                        </c:when>
                        <c:otherwise>—</c:otherwise>
                      </c:choose>
                    </td>
                    <td>
                      <c:choose>
                        <c:when test="${r.state eq 'PUBLISHED'}">
                          <span class="ins-pill-published">✅ Đã công bố</span>
                        </c:when>
                        <c:when test="${r.state eq 'READY'}">
                          <span class="ins-pill-draft">⏳ Sẵn sàng công bố</span>
                        </c:when>
                        <c:otherwise>
                          <span class="ins-pill-draft" style="background:#fee2e2;color:#b91c1c">✏️ Chưa chấm xong</span>
                        </c:otherwise>
                      </c:choose>
                    </td>
                    <td>
                      <c:choose>
                        <c:when test="${r.state eq 'READY' && r.kind eq 'QUIZ'}">
                          <form method="post" style="display:inline"
                                action="${pageContext.request.contextPath}/instructor/courses/${courseId}/results/quizzes/${r.parentId}/attempts/${r.refId}/publish">
                            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                            <button type="submit" class="ins-link-btn ins-link-btn--success">Công bố</button>
                          </form>
                        </c:when>
                        <c:when test="${r.state eq 'READY'}">
                          <form method="post" style="display:inline"
                                action="${pageContext.request.contextPath}/instructor/courses/${courseId}/results/assignments/${r.parentId}/submissions/${r.refId}/publish">
                            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/>
                            <button type="submit" class="ins-link-btn ins-link-btn--success">Công bố</button>
                          </form>
                        </c:when>
                        <c:when test="${r.state eq 'NOT_GRADED' && r.kind eq 'QUIZ'}">
                          <a class="ins-link-btn ins-link-btn--primary"
                             href="${pageContext.request.contextPath}/instructor/courses/${courseId}/quizzes/${r.parentId}/attempts/${r.refId}">
                            Chấm điểm
                          </a>
                        </c:when>
                        <c:when test="${r.state eq 'NOT_GRADED'}">
                          <a class="ins-link-btn ins-link-btn--primary"
                             href="${pageContext.request.contextPath}/instructor/courses/${courseId}/assignments/${r.parentId}/submissions/${r.refId}/grade">
                            Chấm điểm
                          </a>
                        </c:when>
                        <c:otherwise>
                          <span style="font-size:0.8rem;color:#94a3b8">Hoàn tất</span>
                        </c:otherwise>
                      </c:choose>
                    </td>
                  </tr>
                </c:forEach>
              </tbody>
            </table>
          </div>

          <!-- Student Performance Summary Table -->
          <c:if test="${not empty studentLeaderboard}">
            <section class="ir-leaderboard-card">
              <h3 class="ir-leaderboard-title">👩‍🎓 Tổng hợp tiến độ điểm theo học viên</h3>
              <table class="ir-table">
                <thead>
                  <tr>
                    <th>Học viên</th>
                    <th>Tổng bài đã nộp</th>
                    <th>Số bài đã công bố</th>
                    <th>Điểm trung bình (%)</th>
                    <th>Xếp loại học lực</th>
                  </tr>
                </thead>
                <tbody>
                  <c:forEach var="st" items="${studentLeaderboard}">
                    <tr>
                      <td><strong><c:out value="${st.studentName}"/></strong></td>
                      <td>${st.totalSubmissions}</td>
                      <td>${st.publishedSubmissions}</td>
                      <td>
                        <c:choose>
                          <c:when test="${st.averagePercent != null}">
                            <strong><fmt:formatNumber value="${st.averagePercent}" maxFractionDigits="1"/>%</strong>
                          </c:when>
                          <c:otherwise>—</c:otherwise>
                        </c:choose>
                      </td>
                      <td><c:out value="${st.standing}"/></td>
                    </tr>
                  </c:forEach>
                </tbody>
              </table>
            </section>
          </c:if>
        </c:otherwise>
      </c:choose>
    </main>
  </div>
</div>

<script>
  var activeInstructorFilter = 'ALL';

  function filterInstructorRows(mode, btn) {
    activeInstructorFilter = mode;
    var chips = document.querySelectorAll('#irFilterChips .ir-chip');
    for (var i = 0; i < chips.length; i++) {
      chips[i].classList.remove('active');
    }
    if (btn) {
      btn.classList.add('active');
    }
    applyInstructorTableFilter();
  }

  function applyInstructorTableFilter() {
    var searchEl = document.getElementById('irSearchBox');
    var q = searchEl ? searchEl.value.trim().toLowerCase() : '';
    var rows = document.querySelectorAll('#irResultsTable tbody .ir-row');

    for (var i = 0; i < rows.length; i++) {
      var tr = rows[i];
      var kind = tr.getAttribute('data-kind') || '';
      var state = tr.getAttribute('data-state') || '';
      var searchBlob = tr.getAttribute('data-search') || '';

      var matchChip = true;
      if (activeInstructorFilter === 'QUIZ' || activeInstructorFilter === 'ASSIGNMENT') {
        matchChip = (kind === activeInstructorFilter);
      } else if (activeInstructorFilter !== 'ALL') {
        matchChip = (state === activeInstructorFilter);
      }

      var matchSearch = !q || searchBlob.indexOf(q) !== -1;
      tr.style.display = (matchChip && matchSearch) ? '' : 'none';
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
