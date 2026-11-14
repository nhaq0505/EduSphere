<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Kết quả học tập — <c:out value="${results.courseTitle}"/> — EduSphere</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app.css?v=restore-0bfd0e1-20261014">
  <style>
    :root {
      --sr-bg: #f8fafc;
      --sr-card: #ffffff;
      --sr-border: #e2e8f0;
      --sr-text: #0f172a;
      --sr-muted: #64748b;
      --sr-primary: #2563eb;
      --sr-primary-soft: #eff6ff;
      --sr-success: #059669;
      --sr-success-soft: #ecfdf5;
      --sr-warning: #d97706;
      --sr-warning-soft: #fffbeb;
      --sr-danger: #dc2626;
      --sr-danger-soft: #fef2f2;
      --sr-purple: #7c3aed;
      --sr-purple-soft: #f5f3ff;
    }

    body {
      background-color: var(--sr-bg);
      color: var(--sr-text);
      font-family: 'Inter', system-ui, -apple-system, sans-serif;
    }

    .sr-container {
      max-width: 1120px;
      margin: 0 auto;
      padding: 28px 20px 64px;
    }

    .sr-breadcrumb {
      display: inline-flex;
      align-items: center;
      gap: 8px;
      font-size: 0.9rem;
      font-weight: 600;
      color: var(--sr-primary);
      text-decoration: none;
      padding: 8px 14px;
      border-radius: 999px;
      background: var(--sr-primary-soft);
      margin-bottom: 20px;
      transition: all 0.2s ease;
    }

    .sr-breadcrumb:hover {
      background: #dbeafe;
      transform: translateX(-2px);
    }

    .sr-hero {
      background: linear-gradient(135deg, #1e3a8a 0%, #2563eb 60%, #3b82f6 100%);
      border-radius: 20px;
      padding: 32px;
      color: #ffffff;
      box-shadow: 0 14px 32px rgba(37, 99, 235, 0.18);
      margin-bottom: 24px;
      display: flex;
      flex-wrap: wrap;
      justify-content: space-between;
      align-items: center;
      gap: 24px;
    }

    .sr-hero__eyebrow {
      display: inline-flex;
      align-items: center;
      gap: 6px;
      font-size: 0.78rem;
      font-weight: 700;
      text-transform: uppercase;
      letter-spacing: 0.08em;
      background: rgba(255, 255, 255, 0.18);
      padding: 5px 12px;
      border-radius: 999px;
      margin-bottom: 10px;
    }

    .sr-hero__title {
      font-size: 1.85rem;
      font-weight: 800;
      margin: 0 0 8px;
      line-height: 1.25;
    }

    .sr-hero__sub {
      margin: 0;
      font-size: 0.95rem;
      opacity: 0.9;
    }

    .sr-hero__score-box {
      background: rgba(255, 255, 255, 0.14);
      backdrop-filter: blur(8px);
      border: 1px solid rgba(255, 255, 255, 0.25);
      border-radius: 16px;
      padding: 18px 24px;
      min-width: 220px;
      text-align: center;
    }

    .sr-hero__score-label {
      font-size: 0.8rem;
      text-transform: uppercase;
      letter-spacing: 0.06em;
      opacity: 0.85;
      margin-bottom: 4px;
    }

    .sr-hero__score-value {
      font-size: 2.2rem;
      font-weight: 800;
      line-height: 1.1;
    }

    .sr-hero__score-standing {
      display: inline-block;
      margin-top: 8px;
      font-size: 0.82rem;
      font-weight: 700;
      padding: 4px 12px;
      border-radius: 999px;
      background: rgba(255, 255, 255, 0.22);
    }

    .sr-stats-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(210px, 1fr));
      gap: 16px;
      margin-bottom: 24px;
    }

    .sr-stat-card {
      background: var(--sr-card);
      border: 1px solid var(--sr-border);
      border-radius: 16px;
      padding: 18px 20px;
      box-shadow: 0 2px 8px rgba(15, 23, 42, 0.04);
      display: flex;
      flex-direction: column;
      gap: 6px;
    }

    .sr-stat-card__head {
      display: flex;
      align-items: center;
      justify-content: space-between;
      font-size: 0.84rem;
      font-weight: 600;
      color: var(--sr-muted);
    }

    .sr-stat-card__icon {
      width: 34px;
      height: 34px;
      border-radius: 10px;
      display: inline-flex;
      align-items: center;
      justify-content: center;
      font-size: 1rem;
    }

    .sr-stat-card__value {
      font-size: 1.55rem;
      font-weight: 800;
      color: var(--sr-text);
    }

    .sr-stat-card__meta {
      font-size: 0.8rem;
      color: var(--sr-muted);
    }

    .sr-toolbar {
      background: var(--sr-card);
      border: 1px solid var(--sr-border);
      border-radius: 16px;
      padding: 14px 18px;
      margin-bottom: 20px;
      display: flex;
      flex-wrap: wrap;
      align-items: center;
      justify-content: space-between;
      gap: 14px;
    }

    .sr-tabs {
      display: flex;
      flex-wrap: wrap;
      gap: 8px;
    }

    .sr-tab-btn {
      border: 1px solid var(--sr-border);
      background: #f8fafc;
      color: var(--sr-muted);
      font-size: 0.86rem;
      font-weight: 600;
      padding: 8px 14px;
      border-radius: 10px;
      cursor: pointer;
      transition: all 0.18s ease;
    }

    .sr-tab-btn:hover {
      border-color: #cbd5e1;
      color: var(--sr-text);
    }

    .sr-tab-btn.active {
      background: var(--sr-primary);
      border-color: var(--sr-primary);
      color: #ffffff;
    }

    .sr-search-box {
      position: relative;
      min-width: 250px;
      flex: 1;
      max-width: 340px;
    }

    .sr-search-input {
      width: 100%;
      padding: 9px 14px;
      border: 1px solid var(--sr-border);
      border-radius: 10px;
      font-size: 0.88rem;
      outline: none;
      transition: border-color 0.2s;
    }

    .sr-search-input:focus {
      border-color: var(--sr-primary);
      box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.12);
    }

    .sr-list {
      display: flex;
      flex-direction: column;
      gap: 14px;
    }

    .sr-item {
      background: var(--sr-card);
      border: 1px solid var(--sr-border);
      border-radius: 16px;
      padding: 20px 22px;
      box-shadow: 0 2px 8px rgba(15, 23, 42, 0.03);
      transition: transform 0.18s ease, box-shadow 0.18s ease;
    }

    .sr-item:hover {
      transform: translateY(-2px);
      box-shadow: 0 8px 20px rgba(15, 23, 42, 0.07);
    }

    .sr-item__top {
      display: flex;
      flex-wrap: wrap;
      align-items: flex-start;
      justify-content: space-between;
      gap: 14px;
      margin-bottom: 12px;
    }

    .sr-item__badges {
      display: flex;
      flex-wrap: wrap;
      align-items: center;
      gap: 8px;
      margin-bottom: 6px;
    }

    .sr-badge {
      display: inline-flex;
      align-items: center;
      gap: 4px;
      font-size: 0.76rem;
      font-weight: 700;
      padding: 4px 10px;
      border-radius: 999px;
    }

    .sr-badge--quiz {
      background: var(--sr-purple-soft);
      color: var(--sr-purple);
    }

    .sr-badge--assignment {
      background: var(--sr-primary-soft);
      color: var(--sr-primary);
    }

    .sr-badge--published {
      background: var(--sr-success-soft);
      color: var(--sr-success);
    }

    .sr-badge--pending {
      background: var(--sr-warning-soft);
      color: var(--sr-warning);
    }

    .sr-item__title {
      font-size: 1.12rem;
      font-weight: 700;
      margin: 0 0 4px;
      color: var(--sr-text);
    }

    .sr-item__meta {
      font-size: 0.83rem;
      color: var(--sr-muted);
      margin: 0;
    }

    .sr-item__score-panel {
      text-align: right;
      min-width: 140px;
    }

    .sr-item__score-main {
      font-size: 1.45rem;
      font-weight: 800;
      color: var(--sr-text);
    }

    .sr-item__score-max {
      font-size: 0.92rem;
      font-weight: 600;
      color: var(--sr-muted);
    }

    .sr-item__score-pct {
      font-size: 0.8rem;
      font-weight: 700;
      color: var(--sr-primary);
      margin-top: 2px;
    }

    .sr-progress-track {
      width: 100%;
      height: 8px;
      background: #f1f5f9;
      border-radius: 999px;
      overflow: hidden;
      margin: 10px 0 14px;
    }

    .sr-progress-bar {
      height: 100%;
      border-radius: 999px;
      background: linear-gradient(90deg, #2563eb, #10b981);
      transition: width 0.4s ease;
    }

    .sr-feedback-box {
      background: #f8fafc;
      border-left: 4px solid var(--sr-primary);
      border-radius: 8px;
      padding: 12px 14px;
      margin: 10px 0 14px;
      font-size: 0.9rem;
      color: #334155;
      white-space: pre-wrap;
    }

    .sr-feedback-box__label {
      font-size: 0.78rem;
      font-weight: 700;
      text-transform: uppercase;
      color: var(--sr-primary);
      margin-bottom: 4px;
      display: block;
    }

    .sr-item__footer {
      display: flex;
      flex-wrap: wrap;
      align-items: center;
      justify-content: space-between;
      gap: 10px;
      padding-top: 10px;
      border-top: 1px dashed var(--sr-border);
    }

    .sr-detail-link {
      display: inline-flex;
      align-items: center;
      gap: 6px;
      font-size: 0.88rem;
      font-weight: 700;
      color: var(--sr-primary);
      text-decoration: none;
    }

    .sr-detail-link:hover {
      text-decoration: underline;
    }

    .sr-empty {
      background: var(--sr-card);
      border: 1px dashed #cbd5e1;
      border-radius: 18px;
      padding: 48px 24px;
      text-align: center;
    }

    .sr-empty__icon {
      font-size: 2.5rem;
      margin-bottom: 12px;
    }

    .sr-empty__title {
      font-size: 1.2rem;
      font-weight: 700;
      margin: 0 0 6px;
    }

    .sr-empty__desc {
      font-size: 0.92rem;
      color: var(--sr-muted);
      margin: 0;
    }

    @media (max-width: 640px) {
      .sr-hero {
        padding: 22px;
      }
      .sr-hero__score-box {
        width: 100%;
      }
      .sr-item__score-panel {
        text-align: left;
      }
    }
  </style>
</head>
<body>
  <jsp:include page="/WEB-INF/views/common/navbar.jsp"/>

  <main class="sr-container">
    <a class="sr-breadcrumb" href="${pageContext.request.contextPath}/courses/${courseId}/learn">
      ← Quay lại không gian học tập
    </a>

    <!-- Hero Banner -->
    <section class="sr-hero">
      <div>
        <span class="sr-hero__eyebrow">📊 Bảng điểm học viên · UC33</span>
        <h1 class="sr-hero__title"><c:out value="${results.courseTitle}"/></h1>
        <p class="sr-hero__sub">
          Theo dõi toàn bộ điểm số bài tập thực hành, bài kiểm tra trắc nghiệm và nhận xét chuyên môn từ giảng viên.
        </p>
      </div>
      <div class="sr-hero__score-box">
        <div class="sr-hero__score-label">Điểm trung bình tích lũy</div>
        <div class="sr-hero__score-value">
          <c:choose>
            <c:when test="${results.averagePercent != null}">
              <fmt:formatNumber value="${results.averagePercent}" maxFractionDigits="1"/>%
            </c:when>
            <c:otherwise>—</c:otherwise>
          </c:choose>
        </div>
        <span class="sr-hero__score-standing">
          <c:out value="${results.academicStandingLabel}"/>
        </span>
      </div>
    </section>

    <!-- Summary KPI Cards -->
    <section class="sr-stats-grid">
      <div class="sr-stat-card">
        <div class="sr-stat-card__head">
          <span>Đã công bố</span>
          <span class="sr-stat-card__icon" style="background:#ecfdf5;color:#059669">✓</span>
        </div>
        <div class="sr-stat-card__value">${results.publishedCount} / ${results.totalCount}</div>
        <div class="sr-stat-card__meta">
          Đang chờ chấm/công bố: <strong>${results.pendingCount}</strong> mục
        </div>
      </div>

      <div class="sr-stat-card">
        <div class="sr-stat-card__head">
          <span>Điểm hệ 10 quy đổi</span>
          <span class="sr-stat-card__icon" style="background:#eff6ff;color:#2563eb">★</span>
        </div>
        <div class="sr-stat-card__value">
          <c:choose>
            <c:when test="${results.averageScale10 != null}">
              <fmt:formatNumber value="${results.averageScale10}" maxFractionDigits="2"/> / 10
            </c:when>
            <c:otherwise>—</c:otherwise>
          </c:choose>
        </div>
        <div class="sr-stat-card__meta">
          Cao nhất:
          <c:choose>
            <c:when test="${results.highestPercent != null}">
              <strong><fmt:formatNumber value="${results.highestPercent}" maxFractionDigits="1"/>%</strong>
            </c:when>
            <c:otherwise>Chưa có</c:otherwise>
          </c:choose>
        </div>
      </div>

      <div class="sr-stat-card">
        <div class="sr-stat-card__head">
          <span>Trung bình Quiz</span>
          <span class="sr-stat-card__icon" style="background:#f5f3ff;color:#7c3aed">❓</span>
        </div>
        <div class="sr-stat-card__value">
          <c:choose>
            <c:when test="${results.quizAveragePercent != null}">
              <fmt:formatNumber value="${results.quizAveragePercent}" maxFractionDigits="1"/>%
            </c:when>
            <c:otherwise>—</c:otherwise>
          </c:choose>
        </div>
        <div class="sr-stat-card__meta">
          Tổng số lượt làm Quiz: <strong>${results.quizCount}</strong>
        </div>
      </div>

      <div class="sr-stat-card">
        <div class="sr-stat-card__head">
          <span>Trung bình Bài tập</span>
          <span class="sr-stat-card__icon" style="background:#fffbeb;color:#d97706">📝</span>
        </div>
        <div class="sr-stat-card__value">
          <c:choose>
            <c:when test="${results.assignmentAveragePercent != null}">
              <fmt:formatNumber value="${results.assignmentAveragePercent}" maxFractionDigits="1"/>%
            </c:when>
            <c:otherwise>—</c:otherwise>
          </c:choose>
        </div>
        <div class="sr-stat-card__meta">
          Tổng số bài tập đã nộp: <strong>${results.assignmentCount}</strong>
        </div>
      </div>
    </section>

    <c:choose>
      <c:when test="${empty results.rows}">
        <div class="sr-empty">
          <div class="sr-empty__icon">📭</div>
          <h2 class="sr-empty__title">Chưa có kết quả học tập</h2>
          <p class="sr-empty__desc">
            Bạn chưa nộp bài tập hoặc hoàn thành bài kiểm tra quiz nào trong khóa học này.
          </p>
        </div>
      </c:when>
      <c:otherwise>
        <!-- Filter & Search Toolbar -->
        <div class="sr-toolbar">
          <div class="sr-tabs" id="srFilterTabs">
            <button type="button" class="sr-tab-btn active" data-filter="ALL" onclick="filterStudentResults('ALL', this)">
              Tất cả (${results.totalCount})
            </button>
            <button type="button" class="sr-tab-btn" data-filter="QUIZ" onclick="filterStudentResults('QUIZ', this)">
              ❓ Quiz (${results.quizCount})
            </button>
            <button type="button" class="sr-tab-btn" data-filter="ASSIGNMENT" onclick="filterStudentResults('ASSIGNMENT', this)">
              📝 Bài tập (${results.assignmentCount})
            </button>
            <button type="button" class="sr-tab-btn" data-filter="PUBLISHED" onclick="filterStudentResults('PUBLISHED', this)">
              ✓ Đã công bố (${results.publishedCount})
            </button>
          </div>
          <div class="sr-search-box">
            <input type="text" id="srSearchInput" class="sr-search-input"
                   placeholder="Tìm theo tên bài tập hoặc quiz..."
                   oninput="applyStudentSearchAndFilter()">
          </div>
        </div>

        <!-- Results Cards -->
        <div class="sr-list" id="srResultsList">
          <c:forEach var="r" items="${results.rows}">
            <article class="sr-item"
                     data-kind="${r.kind}"
                     data-state="${r.state}"
                     data-title="${fn:toLowerCase(r.title)}">
              <div class="sr-item__top">
                <div>
                  <div class="sr-item__badges">
                    <span class="sr-badge ${r.kind eq 'QUIZ' ? 'sr-badge--quiz' : 'sr-badge--assignment'}">
                      ${r.kind eq 'QUIZ' ? '❓ Bài kiểm tra Quiz' : '📝 Bài tập thực hành'}
                    </span>
                    <c:choose>
                      <c:when test="${r.state eq 'PUBLISHED'}">
                        <span class="sr-badge sr-badge--published">✓ Đã công bố</span>
                      </c:when>
                      <c:otherwise>
                        <span class="sr-badge sr-badge--pending">⏳ Đang chờ công bố</span>
                      </c:otherwise>
                    </c:choose>
                  </div>
                  <h3 class="sr-item__title"><c:out value="${r.title}"/></h3>
                  <p class="sr-item__meta">
                    Lần làm thứ <strong>${r.attemptNumber}</strong>
                    <c:if test="${r.submittedAt != null}">
                      · Nộp lúc ${fn:replace(fn:substring(r.submittedAt, 0, 16), 'T', ' ')}
                    </c:if>
                    <c:if test="${r.publishedAt != null && r.state eq 'PUBLISHED'}">
                      · Công bố lúc ${fn:replace(fn:substring(r.publishedAt, 0, 16), 'T', ' ')}
                    </c:if>
                  </p>
                </div>

                <c:if test="${r.state eq 'PUBLISHED'}">
                  <div class="sr-item__score-panel">
                    <div class="sr-item__score-main">
                      <fmt:formatNumber value="${r.score}" maxFractionDigits="2"/>
                      <span class="sr-item__score-max">/ <fmt:formatNumber value="${r.maxScore}" maxFractionDigits="2"/></span>
                    </div>
                    <c:if test="${r.scorePercent != null}">
                      <div class="sr-item__score-pct">
                        Đạt <fmt:formatNumber value="${r.scorePercent}" maxFractionDigits="1"/>% · Xếp loại ${r.letterGrade} (${r.gradeBandLabel})
                      </div>
                    </c:if>
                  </div>
                </c:if>
              </div>

              <c:choose>
                <c:when test="${r.state eq 'PUBLISHED'}">
                  <c:if test="${r.scorePercent != null}">
                    <div class="sr-progress-track">
                      <div class="sr-progress-bar" style="width: ${r.scorePercent > 100 ? 100 : r.scorePercent}%"></div>
                    </div>
                  </c:if>

                  <c:if test="${not empty r.feedback}">
                    <div class="sr-feedback-box">
                      <span class="sr-feedback-box__label">💬 Nhận xét từ giảng viên</span>
                      <c:out value="${r.feedback}"/>
                    </div>
                  </c:if>

                  <div class="sr-item__footer">
                    <span class="sr-item__meta">
                      Điểm quy đổi thang 10:
                      <strong>
                        <c:choose>
                          <c:when test="${r.scoreScale10 != null}">
                            <fmt:formatNumber value="${r.scoreScale10}" maxFractionDigits="2"/> / 10
                          </c:when>
                          <c:otherwise>—</c:otherwise>
                        </c:choose>
                      </strong>
                    </span>
                    <c:choose>
                      <c:when test="${r.kind eq 'QUIZ'}">
                        <a class="sr-detail-link"
                           href="${pageContext.request.contextPath}/courses/${courseId}/quizzes/${r.parentId}/attempts/${r.refId}/result">
                          Xem chi tiết đáp án &amp; bài làm →
                        </a>
                      </c:when>
                      <c:otherwise>
                        <a class="sr-detail-link"
                           href="${pageContext.request.contextPath}/courses/${courseId}/assignments/${r.parentId}/result">
                          Xem chi tiết bài nộp &amp; nhận xét →
                        </a>
                      </c:otherwise>
                    </c:choose>
                  </div>
                </c:when>
                <c:otherwise>
                  <div class="sr-item__footer">
                    <span class="sr-item__meta">
                      ${r.state eq 'READY'
                        ? 'Bài làm đã được giảng viên chấm điểm và đang chờ công bố chính thức.'
                        : 'Bài làm của bạn đã được ghi nhận và đang chờ giảng viên chấm điểm.'}
                    </span>
                  </div>
                </c:otherwise>
              </c:choose>
            </article>
          </c:forEach>
        </div>
      </c:otherwise>
    </c:choose>
  </main>

  <jsp:include page="/WEB-INF/views/common/footer.jsp"/>

  <script>
    var currentStudentFilter = 'ALL';

    function filterStudentResults(filterValue, btnElement) {
      currentStudentFilter = filterValue;
      var buttons = document.querySelectorAll('#srFilterTabs .sr-tab-btn');
      for (var i = 0; i < buttons.length; i++) {
        buttons[i].classList.remove('active');
      }
      if (btnElement) {
        btnElement.classList.add('active');
      }
      applyStudentSearchAndFilter();
    }

    function applyStudentSearchAndFilter() {
      var searchInput = document.getElementById('srSearchInput');
      var query = searchInput ? searchInput.value.trim().toLowerCase() : '';
      var items = document.querySelectorAll('#srResultsList .sr-item');

      for (var i = 0; i < items.length; i++) {
        var card = items[i];
        var kind = card.getAttribute('data-kind') || '';
        var state = card.getAttribute('data-state') || '';
        var title = card.getAttribute('data-title') || '';

        var matchesFilter = true;
        if (currentStudentFilter === 'QUIZ') {
          matchesFilter = (kind === 'QUIZ');
        } else if (currentStudentFilter === 'ASSIGNMENT') {
          matchesFilter = (kind === 'ASSIGNMENT');
        } else if (currentStudentFilter === 'PUBLISHED') {
          matchesFilter = (state === 'PUBLISHED');
        }

        var matchesQuery = !query || title.indexOf(query) !== -1;
        card.style.display = (matchesFilter && matchesQuery) ? '' : 'none';
      }
    }
  </script>
</body>
</html>
