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
    <title><c:out value="${cert.courseTitle}"/> — Course Certificate | EduSphere</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&family=Playfair+Display:ital,wght@0,600;0,700;1,600&family=Dancing+Script:wght@600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${cp}/assets/css/home.css">
    <style>
        :root {
            --coursera-blue: #0056d2;
            --coursera-blue-hover: #00419e;
            --coursera-light-bg: #eef4fc;
            --text-dark: #1f1f1f;
            --text-muted: #5f6368;
            --border-color: #dadce0;
        }
        body {
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
            background: #ffffff;
            color: var(--text-dark);
            margin: 0;
        }
        .cert-page {
            max-width: 1240px;
            margin: 0 auto;
            padding: 28px 24px 72px;
        }
        .cert-breadcrumb {
            display: flex;
            align-items: center;
            gap: 10px;
            font-size: 0.875rem;
            color: var(--text-muted);
            margin-bottom: 12px;
        }
        .cert-breadcrumb a {
            color: var(--coursera-blue);
            text-decoration: underline;
            font-weight: 500;
        }
        .cert-breadcrumb a:hover {
            color: var(--coursera-blue-hover);
        }
        .cert-main-title {
            font-size: 2rem;
            font-weight: 700;
            color: #1f1f1f;
            margin: 0 0 28px;
            letter-spacing: -0.02em;
            line-height: 1.25;
        }
        .cert-alert {
            padding: 14px 18px;
            border-radius: 8px;
            margin-bottom: 22px;
            font-size: 0.92rem;
            font-weight: 500;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .cert-alert--success {
            background: #ecfdf5;
            border: 1px solid #a7f3d0;
            color: #065f46;
        }
        .cert-layout {
            display: grid;
            grid-template-columns: 480px 1fr;
            gap: 40px;
            align-items: start;
        }
        /* Left Column: Verification Box */
        .cert-verified-box {
            background: #edf4ff;
            border-radius: 4px;
            padding: 28px 28px 26px;
            display: flex;
            gap: 22px;
            align-items: flex-start;
            margin-bottom: 32px;
        }
        .cert-avatar-wrap {
            position: relative;
            width: 82px;
            height: 82px;
            flex-shrink: 0;
        }
        .cert-avatar-img {
            width: 82px;
            height: 82px;
            border-radius: 50%;
            object-fit: cover;
            border: 2px solid #ffffff;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.12);
        }
        .cert-avatar-fallback {
            width: 82px;
            height: 82px;
            border-radius: 50%;
            background: linear-gradient(135deg, #0056d2 0%, #1e40af 100%);
            color: #ffffff;
            font-size: 2rem;
            font-weight: 700;
            display: flex;
            align-items: center;
            justify-content: center;
            border: 2px solid #ffffff;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.12);
        }
        .cert-avatar-check {
            position: absolute;
            top: 0;
            right: -2px;
            width: 24px;
            height: 24px;
            border-radius: 50%;
            background: #ffffff;
            color: #1f1f1f;
            display: flex;
            align-items: center;
            justify-content: center;
            box-shadow: 0 1px 4px rgba(0,0,0,0.18);
            font-size: 13px;
            font-weight: 800;
        }
        .cert-verified-info h2 {
            font-size: 1.2rem;
            font-weight: 700;
            margin: 0 0 10px;
            color: #1f1f1f;
        }
        .cert-verified-meta {
            font-size: 0.92rem;
            font-weight: 700;
            color: #1f1f1f;
            margin: 0 0 8px;
        }
        .cert-verified-credits {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            background: #dbeafe;
            color: #1e40af;
            padding: 3px 10px;
            border-radius: 999px;
            font-size: 0.82rem;
            font-weight: 700;
            margin-bottom: 8px;
        }
        .cert-verified-desc {
            font-size: 0.875rem;
            line-height: 1.5;
            color: #374151;
            margin: 12px 0 0;
        }
        .cert-verified-desc a {
            color: #1f1f1f;
            text-decoration: underline;
            font-weight: 500;
        }

        /* Course mini summary */
        .cert-course-mini {
            display: flex;
            gap: 16px;
            align-items: flex-start;
            margin-bottom: 28px;
        }
        .cert-course-logo {
            width: 62px;
            height: 62px;
            border-radius: 4px;
            background: #00274c;
            color: #ffcb05;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            font-weight: 900;
            font-size: 1.5rem;
            flex-shrink: 0;
            line-height: 1;
            letter-spacing: -0.03em;
            overflow: hidden;
        }
        .cert-course-logo span.sub {
            font-size: 0.45rem;
            color: #ffffff;
            font-weight: 600;
            letter-spacing: 0.08em;
            margin-top: 3px;
            text-transform: uppercase;
        }
        .cert-course-mini__body h3 {
            font-size: 1rem;
            font-weight: 700;
            margin: 0 0 4px;
        }
        .cert-course-mini__body h3 a {
            color: #1f1f1f;
            text-decoration: underline;
        }
        .cert-course-mini__org {
            font-size: 0.82rem;
            color: var(--text-muted);
            margin: 0 0 6px;
        }
        .cert-course-mini__rating {
            display: flex;
            align-items: center;
            flex-wrap: wrap;
            gap: 6px;
            font-size: 0.8rem;
            color: #374151;
        }
        .cert-stars {
            color: #f59e0b;
            font-size: 0.92rem;
            letter-spacing: 1px;
        }

        /* What you will learn */
        .cert-section-label {
            font-size: 0.85rem;
            font-weight: 700;
            color: #1f1f1f;
            margin: 0 0 14px;
        }
        .cert-learn-box {
            border-top: 1px solid #e5e7eb;
            border-bottom: 1px solid #e5e7eb;
            padding: 18px 0;
            margin-bottom: 24px;
        }
        .cert-learn-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 14px 24px;
        }
        .cert-learn-item {
            display: flex;
            align-items: flex-start;
            gap: 10px;
            font-size: 0.84rem;
            line-height: 1.45;
            color: #374151;
        }
        .cert-learn-item__check {
            color: #16a34a;
            font-weight: 800;
            flex-shrink: 0;
            margin-top: 1px;
        }

        /* Skills you will gain */
        .cert-skills-list {
            display: flex;
            flex-wrap: wrap;
            gap: 8px;
        }
        .cert-skill-pill {
            background: #e8eef5;
            color: #1f2937;
            font-size: 0.78rem;
            font-weight: 600;
            padding: 5px 12px;
            border-radius: 999px;
        }

        /* Right Column: Ornate Certificate Frame */
        .cert-doc-outer {
            background: #ffffff;
            border: 3px solid #9ca3af;
            padding: 6px;
            box-shadow: 0 8px 28px rgba(15, 23, 42, 0.12);
            position: relative;
        }
        .cert-doc-inner {
            border: 2px solid #cbd5e1;
            background:
                radial-gradient(circle at 75% 45%, rgba(219, 234, 254, 0.25) 0%, transparent 55%),
                repeating-radial-gradient(circle at 50% 50%, rgba(241, 245, 249, 0.35) 0px, rgba(241, 245, 249, 0.35) 2px, transparent 2px, transparent 10px),
                #fffdf9;
            padding: 38px 42px 26px;
            position: relative;
            min-height: 460px;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            overflow: hidden;
        }
        /* Vertical Ribbon on Right */
        .cert-ribbon {
            position: absolute;
            top: 0;
            right: 48px;
            width: 152px;
            height: 365px;
            background: linear-gradient(180deg, #e5e7eb 0%, #f3f4f6 65%, #e5e7eb 100%);
            border-left: 1px solid #d1d5db;
            border-right: 1px solid #d1d5db;
            display: flex;
            flex-direction: column;
            align-items: center;
            padding-top: 28px;
            z-index: 2;
            clip-path: polygon(0 0, 100% 0, 100% 100%, 50% 87%, 0 100%);
        }
        .cert-ribbon__title {
            font-size: 0.78rem;
            font-weight: 700;
            letter-spacing: 0.18em;
            color: #374151;
            text-align: center;
            line-height: 1.45;
            text-transform: uppercase;
            margin-bottom: 18px;
        }
        .cert-ribbon__credits-pill {
            background: #1e3a8a;
            color: #fde047;
            font-size: 0.68rem;
            font-weight: 800;
            letter-spacing: 0.08em;
            padding: 4px 10px;
            border-radius: 999px;
            text-transform: uppercase;
            margin-bottom: 18px;
            box-shadow: 0 2px 5px rgba(30, 58, 138, 0.25);
        }
        /* Circular Seal */
        .cert-seal {
            width: 112px;
            height: 112px;
            border-radius: 50%;
            border: 3px double #374151;
            background: #ffffff;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            position: relative;
            box-shadow: inset 0 0 0 4px #f9fafb, inset 0 0 0 5px #6b7280;
            padding: 8px;
            text-align: center;
        }
        .cert-seal__top {
            font-size: 0.45rem;
            font-weight: 700;
            letter-spacing: 0.14em;
            color: #4b5563;
            text-transform: uppercase;
            margin-bottom: 4px;
        }
        .cert-seal__center {
            font-size: 0.92rem;
            font-weight: 900;
            color: #111827;
            letter-spacing: -0.02em;
            border-top: 1px solid #9ca3af;
            border-bottom: 1px solid #9ca3af;
            padding: 3px 6px;
            margin: 2px 0;
        }
        .cert-seal__bottom {
            font-size: 0.44rem;
            font-weight: 700;
            letter-spacing: 0.12em;
            color: #4b5563;
            text-transform: uppercase;
            margin-top: 4px;
        }

        /* Certificate Main Content (Left 65%) */
        .cert-doc-content {
            max-width: 62%;
            position: relative;
            z-index: 3;
        }
        .cert-brand {
            display: flex;
            align-items: center;
            gap: 12px;
            margin-bottom: 34px;
        }
        .cert-brand__emblem {
            width: 44px;
            height: 44px;
            background: #00274c;
            color: #ffcb05;
            font-weight: 900;
            font-size: 1.45rem;
            display: flex;
            align-items: center;
            justify-content: center;
            border-radius: 3px;
            letter-spacing: -0.04em;
        }
        .cert-brand__text {
            display: flex;
            flex-direction: column;
        }
        .cert-brand__uni {
            font-size: 0.98rem;
            font-weight: 800;
            letter-spacing: 0.06em;
            color: #00274c;
            line-height: 1.15;
            text-transform: uppercase;
        }
        .cert-brand__sub {
            font-size: 0.65rem;
            font-weight: 600;
            letter-spacing: 0.12em;
            color: #64748b;
            text-transform: uppercase;
        }
        .cert-issue-date {
            font-size: 0.72rem;
            color: #6b7280;
            margin-bottom: 6px;
            font-family: Georgia, serif;
        }
        .cert-student-name {
            font-family: 'Playfair Display', Georgia, serif;
            font-size: 1.95rem;
            font-weight: 700;
            color: #1f2937;
            margin: 0 0 10px;
            line-height: 1.2;
        }
        .cert-completed-label {
            font-size: 0.75rem;
            color: #6b7280;
            font-style: italic;
            margin: 0 0 8px;
            font-family: Georgia, serif;
        }
        .cert-course-title {
            font-family: 'Playfair Display', Georgia, serif;
            font-size: 1.25rem;
            font-weight: 700;
            color: #111827;
            margin: 0 0 8px;
            line-height: 1.3;
        }
        .cert-auth-line {
            font-size: 0.7rem;
            color: #4b5563;
            line-height: 1.45;
            margin: 0 0 28px;
        }

        /* Signature & Footer */
        .cert-doc-bottom {
            display: flex;
            justify-content: space-between;
            align-items: flex-end;
            gap: 20px;
            margin-top: 16px;
            position: relative;
            z-index: 3;
        }
        .cert-sig-block {
            min-width: 210px;
        }
        .cert-sig-script {
            font-family: 'Dancing Script', cursive;
            font-size: 1.65rem;
            font-weight: 700;
            color: #1e293b;
            margin-bottom: -4px;
            padding-left: 4px;
        }
        .cert-sig-line {
            border-bottom: 1px solid #374151;
            width: 210px;
            margin-bottom: 5px;
        }
        .cert-sig-name {
            font-size: 0.68rem;
            font-weight: 700;
            color: #1f2937;
        }
        .cert-sig-role {
            font-size: 0.6rem;
            color: #6b7280;
            line-height: 1.3;
        }
        .cert-verify-block {
            text-align: right;
            font-size: 0.62rem;
            color: #4b5563;
            line-height: 1.4;
            max-width: 270px;
        }
        .cert-verify-block a {
            color: var(--coursera-blue);
            text-decoration: none;
            font-weight: 600;
            word-break: break-all;
        }
        .cert-disclaimer {
            font-size: 0.54rem;
            color: #9ca3af;
            text-align: center;
            margin-top: 14px;
            padding-top: 8px;
            border-top: 1px solid #f1f5f9;
            line-height: 1.35;
        }

        /* Action Buttons under Certificate */
        .cert-actions {
            display: flex;
            align-items: center;
            gap: 16px;
            margin-top: 22px;
        }
        .cert-btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            font-size: 0.92rem;
            font-weight: 700;
            padding: 12px 24px;
            border-radius: 4px;
            cursor: pointer;
            text-decoration: none;
            transition: all 0.18s ease;
        }
        .cert-btn--primary {
            background: var(--coursera-blue);
            color: #ffffff;
            border: 1px solid var(--coursera-blue);
        }
        .cert-btn--primary:hover {
            background: var(--coursera-blue-hover);
        }
        .cert-btn--outline {
            background: #ffffff;
            color: var(--coursera-blue);
            border: 1px solid var(--coursera-blue);
        }
        .cert-btn--outline:hover {
            background: #f0f6ff;
        }

        /* Toast notification */
        .cert-toast {
            position: fixed;
            bottom: 28px;
            right: 28px;
            background: #1e293b;
            color: #ffffff;
            padding: 12px 20px;
            border-radius: 8px;
            font-size: 0.88rem;
            font-weight: 600;
            box-shadow: 0 10px 25px rgba(0,0,0,0.2);
            display: none;
            z-index: 9999;
        }

        @media (max-width: 1024px) {
            .cert-layout {
                grid-template-columns: 1fr;
            }
        }
        @media (max-width: 640px) {
            .cert-learn-grid {
                grid-template-columns: 1fr;
            }
            .cert-ribbon {
                position: static;
                width: 100%;
                height: auto;
                clip-path: none;
                padding: 16px;
                margin-bottom: 20px;
            }
            .cert-doc-content {
                max-width: 100%;
            }
            .cert-doc-bottom {
                flex-direction: column;
                align-items: flex-start;
            }
            .cert-verify-block {
                text-align: left;
            }
        }

        /* Print CSS: only print the Certificate Frame cleanly in landscape */
        @media print {
            @page {
                size: landscape;
                margin: 10mm;
            }
            body * {
                visibility: hidden;
            }
            #certificate-printable, #certificate-printable * {
                visibility: visible;
            }
            #certificate-printable {
                position: fixed;
                left: 0;
                top: 0;
                width: 100%;
                box-shadow: none !important;
            }
        }
    </style>
</head>
<body>

<jsp:include page="/WEB-INF/views/common/navbar.jsp"/>

<main class="cert-page">
    <!-- Breadcrumb -->
    <nav class="cert-breadcrumb" aria-label="Breadcrumb">
        <a href="${cp}/certificates">Certificates</a>
        <span>›</span>
        <span>Course Certificate</span>
    </nav>

    <!-- Course Main Title -->
    <h1 class="cert-main-title"><c:out value="${cert.courseTitle}"/></h1>

    <c:if test="${not empty success}">
        <div class="cert-alert cert-alert--success">
            <span><c:out value="${success}"/></span>
        </div>
    </c:if>
    <c:if test="${verifiedBanner}">
        <div class="cert-alert cert-alert--success">
            <span>✅ Chứng chỉ xác thực hợp lệ trên hệ thống đào tạo tín chỉ trực tuyến EduSphere (Mã xác thực: <strong><c:out value="${cert.verificationCode}"/></strong>).</span>
        </div>
    </c:if>

    <div class="cert-layout">
        <!-- ══════ LEFT COLUMN ══════ -->
        <div class="cert-left">
            <!-- Blue Verification Card -->
            <div class="cert-verified-box">
                <div class="cert-avatar-wrap">
                    <c:choose>
                        <c:when test="${not empty cert.studentAvatarUrl}">
                            <img class="cert-avatar-img" src="${cert.studentAvatarUrl}" alt="${cert.studentName}">
                        </c:when>
                        <c:otherwise>
                            <div class="cert-avatar-fallback">
                                <c:out value="${fn:substring(cert.studentName, 0, 1)}"/>
                            </div>
                        </c:otherwise>
                    </c:choose>
                    <span class="cert-avatar-check" title="Tài khoản đã xác thực">✓</span>
                </div>

                <div class="cert-verified-info">
                    <h2>Completed by <c:out value="${cert.studentName}"/></h2>
                    <p class="cert-verified-meta"><c:out value="${cert.formattedIssuedDateEn}"/></p>
                    <div class="cert-verified-credits">
                        🎓 <c:out value="${cert.creditsEarned}"/> Tín chỉ tích lũy (Credits)
                    </div>
                    <p class="cert-verified-meta"><c:out value="${cert.totalHours}"/> hours (approximately)</p>
                    <p class="cert-verified-meta">Grade Achieved: <c:out value="${cert.gradePercent}"/>%</p>
                    <p class="cert-verified-desc">
                        <c:out value="${cert.studentName}"/>'s account is verified. EduSphere certifies their successful completion of
                        <a href="${cp}/courses/${cert.courseId}"><c:out value="${cert.courseTitle}"/></a>
                        (<c:out value="${cert.creditsEarned}"/> tín chỉ).
                    </p>
                </div>
            </div>

            <!-- Course Summary Mini Card -->
            <div class="cert-course-mini">
                <div class="cert-course-logo">
                    <span>E</span>
                    <span class="sub">EDUSPHERE</span>
                </div>
                <div class="cert-course-mini__body">
                    <h3><a href="${cp}/courses/${cert.courseId}"><c:out value="${cert.courseTitle}"/></a></h3>
                    <p class="cert-course-mini__org">EduSphere Academy • GV: <c:out value="${cert.instructorName}"/></p>
                    <div class="cert-course-mini__rating">
                        <span class="cert-stars">★★★★★</span>
                        <strong><c:out value="${cert.averageRating}"/></strong>
                        <span>(<c:out value="${cert.ratingCount}"/> ratings)</span>
                        <span>|</span>
                        <span><c:out value="${cert.enrolledCount}"/> already enrolled</span>
                        <span>|</span>
                        <strong><c:out value="${cert.creditsEarned}"/> Tín chỉ</strong>
                    </div>
                </div>
            </div>

            <!-- What you will learn -->
            <div class="cert-learn-box">
                <h4 class="cert-section-label">What you will learn</h4>
                <div class="cert-learn-grid">
                    <c:forEach var="obj" items="${cert.objectivesList}">
                        <div class="cert-learn-item">
                            <span class="cert-learn-item__check">✓</span>
                            <span><c:out value="${obj}"/></span>
                        </div>
                    </c:forEach>
                </div>
            </div>

            <!-- Skills you will gain -->
            <div>
                <h4 class="cert-section-label">Skills you will gain</h4>
                <div class="cert-skills-list">
                    <c:forEach var="skill" items="${cert.skillsList}">
                        <span class="cert-skill-pill"><c:out value="${skill}"/></span>
                    </c:forEach>
                </div>
            </div>
        </div>

        <!-- ══════ RIGHT COLUMN: CERTIFICATE DOCUMENT ══════ -->
        <div class="cert-right">
            <div class="cert-doc-outer" id="certificate-printable">
                <div class="cert-doc-inner">
                    <!-- Vertical Right Ribbon with Seal -->
                    <div class="cert-ribbon">
                        <div class="cert-ribbon__title">
                            COURSE<br>CERTIFICATE
                        </div>
                        <div class="cert-ribbon__credits-pill">
                            ★ <c:out value="${cert.creditsEarned}"/> CREDITS ★
                        </div>
                        <div class="cert-seal">
                            <span class="cert-seal__top">EDUCATION FOR EVERYONE</span>
                            <span class="cert-seal__center">EduSphere</span>
                            <span class="cert-seal__bottom">COURSE CERTIFICATE</span>
                        </div>
                    </div>

                    <!-- Main Certificate Body -->
                    <div class="cert-doc-content">
                        <div class="cert-brand">
                            <div class="cert-brand__emblem">E</div>
                            <div class="cert-brand__text">
                                <span class="cert-brand__uni">EDUSPHERE ACADEMY</span>
                                <span class="cert-brand__sub"><c:out value="${cert.categoryName}"/> • CREDIT SYSTEM</span>
                            </div>
                        </div>

                        <div class="cert-issue-date"><c:out value="${cert.formattedIssuedDateShortEn}"/></div>
                        <div class="cert-student-name"><c:out value="${cert.studentName}"/></div>
                        <div class="cert-completed-label">has successfully completed</div>
                        <div class="cert-course-title"><c:out value="${cert.courseTitle}"/></div>
                        <p class="cert-auth-line">
                            an online credit-bearing course (<c:out value="${cert.creditsEarned}"/> Academic Credits • <c:out value="${cert.totalHours}"/> Hours) authorized by EduSphere Academy and offered through EduSphere E-Learning Platform.
                        </p>
                    </div>

                    <!-- Signature & Verification URL -->
                    <div>
                        <div class="cert-doc-bottom">
                            <div class="cert-sig-block">
                                <div class="cert-sig-script"><c:out value="${cert.instructorName}"/></div>
                                <div class="cert-sig-line"></div>
                                <div class="cert-sig-name"><c:out value="${cert.instructorName}"/></div>
                                <div class="cert-sig-role">
                                    <c:out value="${cert.instructorTitle}"/><br>
                                    Faculty of <c:out value="${cert.categoryName}"/>, EduSphere Academy
                                </div>
                            </div>

                            <div class="cert-verify-block">
                                <div>Verify at:</div>
                                <div>
                                    <a href="${cp}/certificates/verify/${cert.verificationCode}">
                                        <c:out value="${verifyBaseUrl}/certificates/verify/${cert.verificationCode}"/>
                                    </a>
                                </div>
                                <div style="margin-top:3px;">
                                    EduSphere has confirmed the identity of this individual and their participation in the course.
                                </div>
                            </div>
                        </div>

                        <div class="cert-disclaimer">
                            This certificate attests to the learner's completion of an online course / project delivered via EduSphere and awards <c:out value="${cert.creditsEarned}"/> learning credits on the EduSphere Credit Repository.
                        </div>
                    </div>
                </div>
            </div>

            <!-- Share & Download Buttons -->
            <div class="cert-actions" style="flex-wrap:wrap;">
                <a class="cert-btn cert-btn--primary"
                   href="${cp}/certificates/${cert.certificateId}/download"
                   download="Chung-chi-EduSphere-${cert.verificationCode}.png"
                   onclick="showCustomToast('✅ Đang tải ảnh chứng chỉ (PNG) về máy...')">
                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M21 15v4a2 2 0 01-2 2H5a2 2 0 01-2-2v-4"/>
                        <polyline points="7 10 12 15 17 10"/>
                        <line x1="12" y1="15" x2="12" y2="3"/>
                    </svg>
                    Tải ảnh chứng chỉ (PNG)
                </a>
                <button type="button" class="cert-btn cert-btn--outline" onclick="window.print()">
                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <polyline points="6 9 6 2 18 2 18 9"/>
                        <path d="M6 18H4a2 2 0 0 1-2-2v-5a2 2 0 0 1 2-2h16a2 2 0 0 1 2 2v5a2 2 0 0 1-2 2h-2"/>
                        <rect x="6" y="14" width="12" height="8"/>
                    </svg>
                    In / Lưu PDF
                </button>
                <button type="button" class="cert-btn cert-btn--outline" onclick="shareCertificate()">
                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M4 12v8a2 2 0 002 2h12a2 2 0 002-2v-8"/>
                        <polyline points="16 6 12 2 8 6"/>
                        <line x1="12" y1="2" x2="12" y2="15"/>
                    </svg>
                    Chia sẻ chứng chỉ
                </button>
                <a class="cert-btn cert-btn--outline" href="${cp}/certificates">
                    ← Kho chứng chỉ
                </a>
            </div>
        </div>
    </div>
</main>

<div id="certToast" class="cert-toast">✅ Đã sao chép đường dẫn xác thực chứng chỉ vào bộ nhớ tạm!</div>

<script>
function shareCertificate() {
    const verifyUrl = window.location.origin + '${cp}/certificates/verify/${cert.verificationCode}';
    if (navigator.clipboard && navigator.clipboard.writeText) {
        navigator.clipboard.writeText(verifyUrl).then(() => showCustomToast('✅ Đã sao chép đường dẫn xác thực chứng chỉ vào bộ nhớ tạm!')).catch(() => promptCopy(verifyUrl));
    } else {
        promptCopy(verifyUrl);
    }
}
function promptCopy(url) {
    window.prompt('Sao chép liên kết xác thực chứng chỉ dưới đây:', url);
}
function showCustomToast(msg) {
    const t = document.getElementById('certToast');
    if (msg) t.textContent = msg;
    t.style.display = 'block';
    setTimeout(() => { t.style.display = 'none'; }, 3200);
}
</script>
</body>
</html>
