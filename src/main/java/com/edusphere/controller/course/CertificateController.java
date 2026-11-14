package com.edusphere.controller.course;

import com.edusphere.dto.course.CertificateView;
import com.edusphere.dto.course.EnrolledCourseView;
import com.edusphere.security.CustomUserDetails;
import com.edusphere.service.course.CertificateService;
import com.edusphere.service.course.CourseActionException;
import com.edusphere.service.course.CourseManagementService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ContentDisposition;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * Controller quản lý toàn bộ luồng nghiệp vụ Kho Chứng Chỉ & Tín Chỉ (Course Certificates):
 * - Xem danh sách chứng chỉ cá nhân (/certificates)
 * - Xem chi tiết chứng chỉ & xác thực công khai (/certificates/{id}, /certificates/verify/{code})
 * - Tải ảnh chứng chỉ PNG độ phân giải cao (/certificates/{id}/download)
 * - Tự động cấp chứng chỉ khi học viên hoàn thành 100% bài học (/courses/{courseId}/certificate)
 */
@Controller
public class CertificateController {

  private final CertificateService certificateService;
  private final CourseManagementService courseManagementService;

  @Autowired
  public CertificateController(
      final CertificateService certificateService,
      final CourseManagementService courseManagementService) {
    this.certificateService = certificateService;
    this.courseManagementService = courseManagementService;
  }

  /**
   * Kho tín chỉ & chứng chỉ đã học (/certificates) -> hiển thị giao diện tab "Certificates & Badges".
   */
  @GetMapping("/certificates")
  public String myCertificates(
      @AuthenticationPrincipal final CustomUserDetails authenticatedUser,
      @RequestParam(value = "q", required = false) final String searchQuery,
      @RequestParam(value = "sort", required = false, defaultValue = "newest") final String sortOrder,
      final Model viewModel) {
    if (authenticatedUser == null) {
      return "redirect:/login";
    }
    final Integer studentUserId = authenticatedUser.getUserId();
    final List<CertificateView> issuedCertificates =
        this.certificateService.syncAndGetMyCertificates(studentUserId);

    final int totalCreditsAccumulated = issuedCertificates.stream()
        .mapToInt(item -> item.getCreditsEarned() != null ? item.getCreditsEarned() : 0)
        .sum();
    final int totalHoursAccumulated = issuedCertificates.stream()
        .mapToInt(item -> item.getTotalHours() != null ? item.getTotalHours() : 0)
        .sum();
    final double averageCertGrade = issuedCertificates.isEmpty()
        ? 0.0
        : Math.round(issuedCertificates.stream()
            .mapToInt(item -> item.getGradePercent() != null ? item.getGradePercent() : 100)
            .average()
            .orElse(100.0) * 10.0) / 10.0;

    final List<EnrolledCourseView> enrolledCourses =
        this.courseManagementService.enrolledCourses(studentUserId);

    viewModel.addAttribute("courses", enrolledCourses);
    viewModel.addAttribute("certificates", issuedCertificates);
    viewModel.addAttribute("totalCreditsEarned", totalCreditsAccumulated);
    viewModel.addAttribute("totalCertificateHours", totalHoursAccumulated);
    viewModel.addAttribute("averageCertificateGrade", averageCertGrade);
    viewModel.addAttribute("certificateSearchQuery", searchQuery != null ? searchQuery.trim() : "");
    viewModel.addAttribute("certificateSortOrder", sortOrder);
    viewModel.addAttribute("activeTab", "certificates");
    return "courses/my-courses";
  }

  /**
   * Trang chi tiết Chứng chỉ & Tín chỉ khóa học (Coursera style).
   */
  @GetMapping("/certificates/{certificateId}")
  public String viewCertificate(
      @PathVariable final Integer certificateId,
      @AuthenticationPrincipal final CustomUserDetails authenticatedUser,
      final HttpServletRequest servletRequest,
      final Model viewModel) {
    final CertificateView certView = this.certificateService.getCertificateById(certificateId);
    final String baseUrl = buildBaseUrl(servletRequest);
    final boolean isCertificateOwner = authenticatedUser != null
        && authenticatedUser.getUserId().equals(certView.getStudentId());

    viewModel.addAttribute("cert", certView);
    viewModel.addAttribute("verifyBaseUrl", baseUrl);
    viewModel.addAttribute("fullVerifyUrl", baseUrl + "/certificates/verify/" + certView.getVerificationCode());
    viewModel.addAttribute("isOwner", isCertificateOwner);
    viewModel.addAttribute("honorsLabel", certView.getHonorsDistinctionLabel());
    viewModel.addAttribute("letterGrade", certView.getLetterGradeCode());
    return "courses/certificate-detail";
  }

  /**
   * Tải trực tiếp ảnh chứng chỉ (PNG độ phân giải cao 1800x1260) theo ID chứng chỉ.
   */
  @GetMapping("/certificates/{certificateId}/download")
  @ResponseBody
  public ResponseEntity<byte[]> downloadCertificateImage(
      @PathVariable final Integer certificateId,
      final HttpServletRequest servletRequest) {
    final CertificateView certView = this.certificateService.getCertificateById(certificateId);
    final byte[] pngImageBytes = this.certificateService.renderCertificatePng(
        certView,
        buildBaseUrl(servletRequest)
    );
    final String codeSuffix = certView.getVerificationCode() != null
        ? certView.getVerificationCode()
        : String.valueOf(certificateId);
    final String downloadFilename = "Chung-chi-EduSphere-" + codeSuffix + ".png";

    final HttpHeaders responseHeaders = new HttpHeaders();
    responseHeaders.setContentType(MediaType.IMAGE_PNG);
    responseHeaders.setContentDisposition(
        ContentDisposition.attachment().filename(downloadFilename, StandardCharsets.UTF_8).build()
    );
    return ResponseEntity.ok().headers(responseHeaders).body(pngImageBytes);
  }

  /**
   * Tải trực tiếp ảnh chứng chỉ của khóa học (tự động cấp nếu đã hoàn thành 100%).
   */
  @GetMapping("/courses/{courseId}/certificate/download")
  public String downloadCourseCertificate(
      @PathVariable final Integer courseId,
      @AuthenticationPrincipal final CustomUserDetails authenticatedUser,
      final RedirectAttributes redirectAttributes) {
    if (authenticatedUser == null) {
      return "redirect:/login";
    }
    try {
      final CertificateView certView = this.certificateService.claimOrGetCertificate(
          authenticatedUser.getUserId(),
          courseId
      );
      return "redirect:/certificates/" + certView.getCertificateId() + "/download";
    } catch (final CourseActionException ex) {
      redirectAttributes.addFlashAttribute("error", ex.getMessage());
      return "redirect:/courses/" + courseId + "/learn";
    }
  }

  /**
   * Trang xác thực chứng chỉ công khai qua mã Verification Code.
   */
  @GetMapping("/certificates/verify/{verificationCode}")
  public String verifyCertificate(
      @PathVariable final String verificationCode,
      @AuthenticationPrincipal final CustomUserDetails authenticatedUser,
      final HttpServletRequest servletRequest,
      final Model viewModel) {
    final CertificateView certView =
        this.certificateService.getCertificateByVerificationCode(verificationCode);
    final String baseUrl = buildBaseUrl(servletRequest);
    final boolean isCertificateOwner = authenticatedUser != null
        && authenticatedUser.getUserId().equals(certView.getStudentId());

    viewModel.addAttribute("cert", certView);
    viewModel.addAttribute("verifyBaseUrl", baseUrl);
    viewModel.addAttribute("fullVerifyUrl", baseUrl + "/certificates/verify/" + certView.getVerificationCode());
    viewModel.addAttribute("verifiedBanner", Boolean.TRUE);
    viewModel.addAttribute("isOwner", isCertificateOwner);
    viewModel.addAttribute("honorsLabel", certView.getHonorsDistinctionLabel());
    viewModel.addAttribute("letterGrade", certView.getLetterGradeCode());
    return "courses/certificate-detail";
  }

  /**
   * API JSON xác thực chứng chỉ công khai theo mã Verification Code.
   */
  @GetMapping(value = "/api/certificates/verify/{verificationCode}", produces = MediaType.APPLICATION_JSON_VALUE)
  @ResponseBody
  public ResponseEntity<Map<String, Object>> verifyCertificateApi(
      @PathVariable final String verificationCode,
      final HttpServletRequest servletRequest) {
    final Map<String, Object> payload = new LinkedHashMap<>();
    try {
      final CertificateView cert =
          this.certificateService.getCertificateByVerificationCode(verificationCode);
      final String baseUrl = buildBaseUrl(servletRequest);
      payload.put("valid", Boolean.TRUE);
      payload.put("certificateId", cert.getCertificateId());
      payload.put("verificationCode", cert.getVerificationCode());
      payload.put("status", cert.getStatus());
      payload.put("studentName", cert.getStudentName());
      payload.put("courseId", cert.getCourseId());
      payload.put("courseTitle", cert.getCourseTitle());
      payload.put("categoryName", cert.getCategoryName());
      payload.put("instructorName", cert.getInstructorName());
      payload.put("creditsEarned", cert.getCreditsEarned());
      payload.put("gradePercent", cert.getGradePercent());
      payload.put("honorsDistinction", cert.getHonorsDistinctionLabel());
      payload.put("letterGrade", cert.getLetterGradeCode());
      payload.put("totalHours", cert.getTotalHours());
      payload.put("issuedDateVi", cert.getFormattedIssuedDateVi());
      payload.put("issuedDateEn", cert.getFormattedIssuedDateEn());
      payload.put("verifyUrl", baseUrl + "/certificates/verify/" + cert.getVerificationCode());
      return ResponseEntity.ok(payload);
    } catch (final CourseActionException ex) {
      payload.put("valid", Boolean.FALSE);
      payload.put("verificationCode", verificationCode);
      payload.put("message", ex.getMessage());
      return ResponseEntity.status(ex.getStatus()).body(payload);
    }
  }

  /**
   * API JSON trả về bảng điểm tín chỉ & danh sách chứng chỉ của học viên hiện tại.
   */
  @GetMapping(value = "/certificates/transcript-json", produces = MediaType.APPLICATION_JSON_VALUE)
  @ResponseBody
  public ResponseEntity<Map<String, Object>> myCertificateTranscriptJson(
      @AuthenticationPrincipal final CustomUserDetails authenticatedUser) {
    if (authenticatedUser == null) {
      final Map<String, Object> err = new LinkedHashMap<>();
      err.put("authenticated", Boolean.FALSE);
      return ResponseEntity.status(401).body(err);
    }
    final List<CertificateView> certs =
        this.certificateService.syncAndGetMyCertificates(authenticatedUser.getUserId());

    int totalCredits = 0;
    int totalHours = 0;
    final List<Map<String, Object>> items = new ArrayList<>();
    for (final CertificateView c : certs) {
      totalCredits += (c.getCreditsEarned() != null ? c.getCreditsEarned() : 0);
      totalHours += (c.getTotalHours() != null ? c.getTotalHours() : 0);
      final Map<String, Object> row = new LinkedHashMap<>();
      row.put("certificateId", c.getCertificateId());
      row.put("verificationCode", c.getVerificationCode());
      row.put("courseTitle", c.getCourseTitle());
      row.put("categoryName", c.getCategoryName());
      row.put("creditsEarned", c.getCreditsEarned());
      row.put("gradePercent", c.getGradePercent());
      row.put("letterGrade", c.getLetterGradeCode());
      row.put("honors", c.getHonorsDistinctionLabel());
      row.put("totalHours", c.getTotalHours());
      row.put("issuedDateVi", c.getFormattedIssuedDateVi());
      items.add(row);
    }

    final Map<String, Object> transcript = new LinkedHashMap<>();
    transcript.put("authenticated", Boolean.TRUE);
    transcript.put("studentId", authenticatedUser.getUserId());
    transcript.put("studentName", authenticatedUser.getFullName());
    transcript.put("certificateCount", certs.size());
    transcript.put("totalCreditsEarned", totalCredits);
    transcript.put("totalHoursCompleted", totalHours);
    transcript.put("certificates", items);
    return ResponseEntity.ok(transcript);
  }

  /**
   * Truy cập nhanh chứng chỉ của khóa học (tự động cấp nếu đã hoàn thành 100%).
   */
  @GetMapping("/courses/{courseId}/certificate")
  public String courseCertificate(
      @PathVariable final Integer courseId,
      @AuthenticationPrincipal final CustomUserDetails authenticatedUser,
      final RedirectAttributes redirectAttributes) {
    if (authenticatedUser == null) {
      return "redirect:/login";
    }
    try {
      final CertificateView certView = this.certificateService.claimOrGetCertificate(
          authenticatedUser.getUserId(),
          courseId
      );
      return "redirect:/certificates/" + certView.getCertificateId();
    } catch (final CourseActionException ex) {
      redirectAttributes.addFlashAttribute("error", ex.getMessage());
      return "redirect:/courses/" + courseId + "/learn";
    }
  }

  /**
   * Học viên bấm nút "Nhận Chứng chỉ" sau khi hoàn thành khóa học.
   */
  @PostMapping("/courses/{courseId}/certificate/claim")
  public String claimCertificate(
      @PathVariable final Integer courseId,
      @AuthenticationPrincipal final CustomUserDetails authenticatedUser,
      final RedirectAttributes redirectAttributes) {
    if (authenticatedUser == null) {
      return "redirect:/login";
    }
    try {
      final CertificateView certView = this.certificateService.claimOrGetCertificate(
          authenticatedUser.getUserId(),
          courseId
      );
      redirectAttributes.addFlashAttribute(
          "success",
          "🎉 Chúc mừng! Bạn đã nhận được chứng chỉ hoàn thành khóa học \"" + certView.getCourseTitle() + "\"!"
      );
      return "redirect:/certificates/" + certView.getCertificateId();
    } catch (final CourseActionException ex) {
      redirectAttributes.addFlashAttribute("error", ex.getMessage());
      return "redirect:/courses/" + courseId + "/learn";
    }
  }

  private String buildBaseUrl(final HttpServletRequest request) {
    final String scheme = request.getScheme();
    final String host = request.getServerName();
    final int port = request.getServerPort();
    final String contextPath = request.getContextPath() != null ? request.getContextPath() : "";
    final boolean isStandardPort = ("http".equalsIgnoreCase(scheme) && port == 80)
        || ("https".equalsIgnoreCase(scheme) && port == 443);
    return scheme + "://" + host + (isStandardPort ? "" : ":" + port) + contextPath;
  }

  @ExceptionHandler(CourseActionException.class)
  public String handleCertificateError(
      final CourseActionException ex,
      final HttpServletResponse response,
      final Model model) {
    response.setStatus(ex.getStatus().value());
    model.addAttribute("errorMessage", ex.getMessage());
    return "courses/action-error";
  }
}
