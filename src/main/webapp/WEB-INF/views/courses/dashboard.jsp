<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<c:set var="cp" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Dashboard học viên — EduSphere</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="${cp}/assets/css/home.css">
  <style>
    .db-main {
      background: #f4f8fd;
      padding: 28px 0 64px;
      min-height: 75vh;
      font-family: 'Inter', sans-serif;
    }

    .db-container {
      max-width: 1140px;
      margin: 0 auto;
      padding: 0 20px;
    }

    /* Hero Banner */
    .db-hero {
      position: relative;
      overflow: hidden;
      border-radius: 18px;
      padding: 28px 34px;
      margin-bottom: 20px;
      background: linear-gradient(120deg, #dbeafe 0%, #bfdbfe 55%, #eff6ff 100%);
      border: 1px solid #dbeafe;
      display: flex;
      align-items: center;
      justify-content: space-between;
      gap: 20px;
    }

    .db-hero h1 {
      margin: 0 0 6px;
      font-size: 1.55rem;
      font-weight: 800;
      color: #0f2a5c;
    }

    .db-hero p {
      margin: 0;
      color: #334e7a;
      font-size: 0.95rem;
    }

    .db-hero__art {
      font-size: 3.8rem;
      opacity: 0.92;
      flex-shrink: 0;
    }

    /* KPI Stat Cards */
    .db-stats {
      display: grid;
      grid-template-columns: repeat(4, 1fr);
      gap: 16px;
      margin-bottom: 20px;
    }

    .db-stat {
      background: #ffffff;
      border: 1px solid #e2e8f0;
      border-radius: 14px;
      padding: 18px 20px;
      display: flex;
      align-items: center;
      gap: 14px;
      text-decoration: none;
      color: inherit;
      box-shadow: 0 2px 8px rgba(15, 23, 42, 0.04);
      transition: transform 0.16s ease, box-shadow 0.16s ease;
    }

    .db-stat:hover {
      transform: translateY(-2px);
      box-shadow: 0 6px 16px rgba(15, 23, 42, 0.07);
    }

    .db-stat--primary {
      border: 2px solid #60a5fa;
      background: #f5faff;
      flex-direction: column;
      align-items: stretch;
      gap: 10px;
    }

    .db-stat__row {
      display: flex;
      align-items: center;
      gap: 14px;
    }

    .db-stat__icon {
      width: 46px;
      height: 46px;
      border-radius: 12px;
      background: #eff6ff;
      color: #2563eb;
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 1.5rem;
      flex-shrink: 0;
    }

    .db-stat__label {
      font-size: 0.82rem;
      color: #64748b;
      font-weight: 600;
    }

    .db-stat__value {
      font-size: 1.35rem;
      font-weight: 800;
      color: #0f172a;
      line-height: 1.25;
    }

    .db-stat__value small {
      font-size: 0.95rem;
      font-weight: 600;
      color: #475569;
    }

    .db-bar {
      height: 8px;
      background: #e2e8f0;
      border-radius: 999px;
      overflow: hidden;
    }

    .db-bar__fill {
      height: 100%;
      background: linear-gradient(90deg, #2563eb, #38bdf8);
      border-radius: 999px;
    }

    .db-bar__pct {
      text-align: right;
      font-size: 0.78rem;
      font-weight: 700;
      color: #2563eb;
      margin-top: 3px;
    }

    /* Section Panels */
    .db-panel {
      background: #ffffff;
      border: 1px solid #e2e8f0;
      border-radius: 16px;
      padding: 22px 24px;
      margin-bottom: 20px;
      box-shadow: 0 2px 8px rgba(15, 23, 42, 0.04);
    }

    .db-panel__head {
      display: flex;
      align-items: center;
      justify-content: space-between;
      gap: 12px;
      margin-bottom: 16px;
    }

    .db-panel__title {
      margin: 0;
      font-size: 1.05rem;
      font-weight: 800;
      color: #0f172a;
      display: flex;
      align-items: center;
      gap: 8px;
    }

    .db-btn-outline {
      border: 1px solid #cbd5e1;
      border-radius: 999px;
      padding: 7px 16px;
      font-size: 0.84rem;
      font-weight: 700;
      color: #1e293b;
      text-decoration: none;
      background: #ffffff;
    }

    .db-btn-outline:hover {
      border-color: #2563eb;
      color: #2563eb;
    }

    /* Active Courses List */
    .db-course {
      display: flex;
      align-items: center;
      gap: 20px;
      padding: 14px 0;
      border-top: 1px solid #f1f5f9;
    }

    .db-course:first-of-type {
      border-top: none;
    }

    .db-course__thumb {
      width: 200px;
      height: 112px;
      border-radius: 12px;
      overflow: hidden;
      flex-shrink: 0;
      position: relative;
      background: linear-gradient(135deg, #1d4ed8, #38bdf8);
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 2.6rem;
    }

    .db-course__thumb img {
      width: 100%;
      height: 100%;
      object-fit: cover;
    }

    .db-course__tag {
      position: absolute;
      left: 8px;
      top: 8px;
      background: #ffffff;
      color: #2563eb;
      font-size: 0.7rem;
      font-weight: 800;
      padding: 3px 10px;
      border-radius: 999px;
    }

    .db-course__body {
      flex: 1;
      min-width: 0;
    }

    .db-course__title {
      margin: 0 0 4px;
      font-size: 1.1rem;
      font-weight: 800;
      color: #0f172a;
    }

    .db-course__desc {
      margin: 0 0 10px;
      font-size: 0.88rem;
      color: #475569;
    }

    .db-course__meta {
      font-size: 0.85rem;
      font-weight: 600;
      color: #1e293b;
      margin-bottom: 6px;
    }

    .db-btn-primary {
      background: linear-gradient(135deg, #2563eb, #3b82f6);
      color: #ffffff;
      border: none;
      border-radius: 999px;
      padding: 11px 22px;
      font-weight: 700;
      font-size: 0.9rem;
      text-decoration: none;
      white-space: nowrap;
      box-shadow: 0 4px 12px rgba(37, 99, 235, 0.28);
    }

    .db-empty {
      text-align: center;
      padding: 26px 10px;
      color: #64748b;
      font-size: 0.92rem;
    }

    /* Bottom Grid */
    .db-grid2 {
      display: grid;
      grid-template-columns: 1.7fr 1fr;
      gap: 20px;
    }

    .db-range {
      display: inline-flex;
      background: #f1f5f9;
      border-radius: 999px;
      padding: 3px;
    }

    .db-range button {
      border: none;
      background: transparent;
      padding: 6px 14px;
      border-radius: 999px;
      font-family: inherit;
      font-size: 0.8rem;
      font-weight: 700;
      color: #475569;
      cursor: pointer;
    }

    .db-range button.active {
      background: #3b82f6;
      color: #ffffff;
    }

    #dbChart {
      width: 100%;
      height: 240px;
      display: block;
    }

    .db-ach {
      text-align: center;
      padding: 12px 0 4px;
    }

    .db-ach__medal {
      font-size: 4.2rem;
      line-height: 1;
      margin-bottom: 8px;
    }

    .db-ach__title {
      font-size: 1.05rem;
      font-weight: 800;
      color: #0f172a;
    }

    .db-ach__desc {
      font-size: 0.88rem;
      color: #64748b;
      margin-top: 4px;
    }

    .db-ach__chips {
      display: flex;
      flex-wrap: wrap;
      gap: 8px;
      justify-content: center;
      margin-top: 16px;
    }

    .db-chip {
      background: #eff6ff;
      color: #1d4ed8;
      font-size: 0.78rem;
      font-weight: 700;
      padding: 5px 12px;
      border-radius: 999px;
    }

    @media (max-width: 992px) {
      .db-stats {
        grid-template-columns: repeat(2, 1fr);
      }
      .db-grid2 {
        grid-template-columns: 1fr;
      }
    }

    @media (max-width: 640px) {
      .db-stats {
        grid-template-columns: 1fr;
      }
      .db-course {
        flex-direction: column;
        align-items: stretch;
      }
      .db-course__thumb {
        width: 100%;
        height: 160px;
      }
      .db-hero__art {
        display: none;
      }
    }
  </style>
</head>
<body>

<jsp:include page="/WEB-INF/views/common/navbar.jsp"/>

<main class="db-main">
  <div class="db-container">

    <!-- Hero -->
    <section class="db-hero">
      <div>
        <h1>Xin chào, <c:out value="${dash.fullName}"/>! 👋</h1>
        <p>Cùng EduSphere khám phá tri thức và phát triển bản thân mỗi ngày!</p>
      </div>
      <div class="db-hero__art">🎓</div>
    </section>

    <!-- 4 thẻ thống kê -->
    <section class="db-stats">
      <div class="db-stat db-stat--primary">
        <div class="db-stat__row">
          <div class="db-stat__icon">⏱️</div>
          <div>
            <div class="db-stat__label">Số giờ học</div>
            <div class="db-stat__value">
              <c:out value="${dash.hoursStudiedLabel}"/>
              <small>/ <c:out value="${dash.targetHoursLabel}"/> giờ</small>
            </div>
          </div>
        </div>
        <div>
          <div class="db-bar">
            <div class="db-bar__fill" style="width:${dash.hoursPercent}%"></div>
          </div>
          <div class="db-bar__pct"><c:out value="${dash.hoursPercent}"/>%</div>
        </div>
      </div>

      <a class="db-stat" href="${cp}/my-courses">
        <div class="db-stat__icon">📘</div>
        <div>
          <div class="db-stat__label">Khóa học đã tham gia</div>
          <div class="db-stat__value">
            <c:out value="${dash.enrolledCount}"/> <small>khóa học</small>
          </div>
        </div>
      </a>

      <div class="db-stat">
        <div class="db-stat__icon">🔥</div>
        <div>
          <div class="db-stat__label">Chuỗi ngày học liên tiếp</div>
          <div class="db-stat__value">
            <c:out value="${dash.streakDays}"/> <small>ngày</small>
          </div>
          <div class="db-stat__label">Hôm nay: <c:out value="${dash.todayMinutes}"/> phút</div>
        </div>
      </div>

      <div class="db-stat">
        <div class="db-stat__icon">⭐</div>
        <div>
          <div class="db-stat__label">Đánh giá trung bình</div>
          <div class="db-stat__value">
            <c:choose>
              <c:when test="${not empty dash.averageRating}">
                <c:out value="${dash.averageRating}"/><small>/5</small>
              </c:when>
              <c:otherwise>
                <small>Chưa có</small>
              </c:otherwise>
            </c:choose>
          </div>
        </div>
      </div>
    </section>

    <!-- Khóa học đang học -->
    <section class="db-panel">
      <div class="db-panel__head">
        <h2 class="db-panel__title">📖 Khóa học đang học</h2>
        <a class="db-btn-outline" href="${cp}/my-courses">Xem tất cả →</a>
      </div>
      <c:choose>
        <c:when test="${empty dash.activeCourses}">
          <div class="db-empty">
            Bạn chưa có khóa học nào đang học.
            <a href="${cp}/courses" style="color:#2563eb;font-weight:700;">Khám phá khóa học ngay</a>
          </div>
        </c:when>
        <c:otherwise>
          <c:forEach var="course" items="${dash.activeCourses}" varStatus="st" end="2">
            <div class="db-course">
              <div class="db-course__thumb">
                <c:choose>
                  <c:when test="${not empty course.thumbnailUrl}">
                    <c:choose>
                      <c:when test="${fn:startsWith(course.thumbnailUrl, 'http://') or fn:startsWith(course.thumbnailUrl, 'https://') or fn:startsWith(course.thumbnailUrl, cp)}">
                        <img src="<c:out value='${course.thumbnailUrl}'/>" alt="">
                      </c:when>
                      <c:otherwise>
                        <img src="${cp}<c:out value='${course.thumbnailUrl}'/>" alt="">
                      </c:otherwise>
                    </c:choose>
                  </c:when>
                  <c:otherwise>📚</c:otherwise>
                </c:choose>
                <span class="db-course__tag">Đang học</span>
              </div>
              <div class="db-course__body">
                <h3 class="db-course__title"><c:out value="${course.title}"/></h3>
                <p class="db-course__desc"><c:out value="${course.summary}"/></p>
                <div class="db-course__meta">
                  Tiến độ: <c:out value="${course.progressPercent}"/>% &bull;
                  Đã học <c:out value="${course.hoursStudiedLabel}"/>/<c:out value="${course.targetHoursLabel}"/> giờ
                  (<c:out value="${course.completedLessons}"/>/<c:out value="${course.totalLessons}"/> bài)
                </div>
                <div class="db-bar">
                  <div class="db-bar__fill" style="width:${course.progressPercent}%"></div>
                </div>
              </div>
              <a class="db-btn-primary" href="${cp}/courses/${course.courseId}/learn">▶ Tiếp tục học</a>
            </div>
          </c:forEach>
        </c:otherwise>
      </c:choose>
    </section>

    <!-- Thống kê học tập + Thành tích -->
    <section class="db-grid2">
      <div class="db-panel" style="margin-bottom:0;">
        <div class="db-panel__head">
          <h2 class="db-panel__title">📊 Thống kê học tập</h2>
          <div class="db-range" id="dbRange">
            <button type="button" data-range="7" class="active">7 ngày</button>
            <button type="button" data-range="30">30 ngày</button>
            <button type="button" data-range="90">3 tháng</button>
          </div>
        </div>
        <svg id="dbChart" viewBox="0 0 640 240" preserveAspectRatio="none"></svg>
      </div>

      <div class="db-panel" style="margin-bottom:0;">
        <div class="db-panel__head">
          <h2 class="db-panel__title">🏆 Thành tích của bạn</h2>
        </div>
        <div class="db-ach">
          <div class="db-ach__medal">🏅</div>
          <div class="db-ach__title"><c:out value="${dash.achievementTitle}"/></div>
          <div class="db-ach__desc"><c:out value="${dash.achievementDesc}"/></div>
          <div class="db-ach__chips">
            <span class="db-chip">✅ <c:out value="${dash.lessonsCompleted}"/> bài học hoàn thành</span>
            <span class="db-chip">⏱️ <c:out value="${dash.hoursStudiedLabel}"/> giờ đã học</span>
          </div>
        </div>
      </div>
    </section>

  </div>
</main>

<script>
(function () {
  var DATA = {
    '7':  ${dash.chart7Json},
    '30': ${dash.chart30Json},
    '90': ${dash.chart90Json}
  };
  var svg = document.getElementById('dbChart');
  var NS = 'http://www.w3.org/2000/svg';
  var W = 640, H = 240, PL = 40, PR = 14, PT = 14, PB = 32;

  function el(name, attrs) {
    var e = document.createElementNS(NS, name);
    for (var k in attrs) {
      e.setAttribute(k, attrs[k]);
    }
    return e;
  }

  function fmt(h) {
    if (h >= 1) {
      return (Math.round(h * 10) / 10) + 'h';
    }
    return Math.round(h * 60) + ' phút';
  }

  function draw(range) {
    var d = DATA[range];
    while (svg.firstChild) {
      svg.removeChild(svg.firstChild);
    }
    var max = Math.max.apply(null, d.values.concat([1]));
    max = Math.ceil(max);
    var step = max <= 4 ? 1 : Math.ceil(max / 4);
    max = step * Math.ceil(max / step);
    var iw = W - PL - PR, ih = H - PT - PB;

    for (var v = 0; v <= max; v += step) {
      var y = PT + ih - (v / max) * ih;
      svg.appendChild(el('line', {
        x1: PL, x2: W - PR, y1: y, y2: y, stroke: '#e2e8f0', 'stroke-width': 1
      }));
      var t = el('text', {
        x: PL - 8, y: y + 4, 'text-anchor': 'end', 'font-size': 11, fill: '#64748b'
      });
      t.textContent = v + 'h';
      svg.appendChild(t);
    }

    var n = d.values.length;
    var pts = d.values.map(function (val, i) {
      return {
        x: PL + (n === 1 ? iw / 2 : (i / (n - 1)) * iw),
        y: PT + ih - (val / max) * ih,
        v: val,
        l: d.labels[i]
      };
    });

    var area = 'M' + pts[0].x + ',' + (PT + ih) + ' ' +
        pts.map(function (p) { return 'L' + p.x + ',' + p.y; }).join(' ') +
        ' L' + pts[n - 1].x + ',' + (PT + ih) + ' Z';
    svg.appendChild(el('path', { d: area, fill: 'rgba(59,130,246,.12)' }));
    svg.appendChild(el('polyline', {
      points: pts.map(function (p) { return p.x + ',' + p.y; }).join(' '),
      fill: 'none',
      stroke: '#3b82f6',
      'stroke-width': 2.2,
      'stroke-linejoin': 'round'
    }));

    var every = n > 14 ? Math.ceil(n / 8) : 1;
    pts.forEach(function (p, i) {
      var c = el('circle', {
        cx: p.x, cy: p.y, r: n > 14 ? 3 : 4, fill: '#fff', stroke: '#3b82f6', 'stroke-width': 2
      });
      var title = el('title', {});
      title.textContent = p.l + ': ' + fmt(p.v);
      c.appendChild(title);
      svg.appendChild(c);
      if (i % every === 0 || i === n - 1) {
        var tx = el('text', {
          x: p.x, y: H - 10, 'text-anchor': 'middle', 'font-size': 11, fill: '#64748b'
        });
        tx.textContent = p.l;
        svg.appendChild(tx);
      }
    });
  }

  document.querySelectorAll('#dbRange button').forEach(function (b) {
    b.addEventListener('click', function () {
      document.querySelectorAll('#dbRange button').forEach(function (x) {
        x.classList.remove('active');
      });
      b.classList.add('active');
      draw(b.getAttribute('data-range'));
    });
  });
  draw('7');
})();
</script>
</body>
</html>
