package com.edusphere.controller.course;

import com.edusphere.dto.course.CertificateView;
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
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.nio.charset.StandardCharsets;
import java.util.List;

@Controller
public class CertificateController {

    private final CertificateService certificateService;
    private final CourseManagementService courseManagementService;

    @Autowired
    public CertificateController(CertificateService certificateService,
                                 CourseManagementService courseManagementService) {
        this.certificateService = certificateService;
        this.courseManagementService = courseManagementService;
    }

    /**
     * Kho tín chỉ & chứng chỉ đã học (/certificates) -> hiển thị giao diện tab "Certificates & Badges"
     */
    @GetMapping("/certificates")
    public String myCertificates(@AuthenticationPrincipal CustomUserDetails user, Model model) {
        if (user == null) {
            return "redirect:/login";
        }
        Integer userId = user.getUserId();
        List<CertificateView> certs = certificateService.syncAndGetMyCertificates(userId);
        int totalCredits = certs.stream()
                .mapToInt(c -> c.getCreditsEarned() != null ? c.getCreditsEarned() : 0)
                .sum();

        model.addAttribute("courses", courseManagementService.enrolledCourses(userId));
        model.addAttribute("certificates", certs);
        model.addAttribute("totalCreditsEarned", totalCredits);
        model.addAttribute("activeTab", "certificates");
        return "courses/my-courses";
    }

    /**
     * Trang chi tiết Chứng chỉ & Tín chỉ khóa học (Coursera style - Ảnh minh họa 2)
     */
    @GetMapping("/certificates/{certificateId}")
    public String viewCertificate(@PathVariable Integer certificateId,
                                  @AuthenticationPrincipal CustomUserDetails user,
                                  HttpServletRequest request,
                                  Model model) {
        CertificateView cert = certificateService.getCertificateById(certificateId);
        model.addAttribute("cert", cert);
        model.addAttribute("verifyBaseUrl", buildBaseUrl(request));
        model.addAttribute("isOwner", user != null && user.getUserId().equals(cert.getStudentId()));
        return "courses/certificate-detail";
    }

    /**
     * Tải trực tiếp ảnh chứng chỉ (PNG độ phân giải cao) theo ID chứng chỉ
     */
    @GetMapping("/certificates/{certificateId}/download")
    @ResponseBody
    public ResponseEntity<byte[]> downloadCertificateImage(@PathVariable Integer certificateId,
                                                           HttpServletRequest request) {
        CertificateView cert = certificateService.getCertificateById(certificateId);
        byte[] pngBytes = certificateService.renderCertificatePng(cert, buildBaseUrl(request));
        String code = cert.getVerificationCode() != null ? cert.getVerificationCode() : String.valueOf(certificateId);
        String filename = "Chung-chi-EduSphere-" + code + ".png";

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.IMAGE_PNG);
        headers.setContentDisposition(
                ContentDisposition.attachment().filename(filename, StandardCharsets.UTF_8).build()
        );
        return ResponseEntity.ok().headers(headers).body(pngBytes);
    }

    /**
     * Tải trực tiếp ảnh chứng chỉ của khóa học (tự động cấp nếu đã hoàn thành 100%)
     */
    @GetMapping("/courses/{courseId}/certificate/download")
    public String downloadCourseCertificate(@PathVariable Integer courseId,
                                            @AuthenticationPrincipal CustomUserDetails user,
                                            RedirectAttributes flash) {
        if (user == null) {
            return "redirect:/login";
        }
        try {
            CertificateView cert = certificateService.claimOrGetCertificate(user.getUserId(), courseId);
            return "redirect:/certificates/" + cert.getCertificateId() + "/download";
        } catch (CourseActionException ex) {
            flash.addFlashAttribute("error", ex.getMessage());
            return "redirect:/courses/" + courseId + "/learn";
        }
    }

    /**
     * Trang xác thực chứng chỉ công khai qua mã Verification Code
     */
    @GetMapping("/certificates/verify/{verificationCode}")
    public String verifyCertificate(@PathVariable String verificationCode,
                                    @AuthenticationPrincipal CustomUserDetails user,
                                    HttpServletRequest request,
                                    Model model) {
        CertificateView cert = certificateService.getCertificateByVerificationCode(verificationCode);
        model.addAttribute("cert", cert);
        model.addAttribute("verifyBaseUrl", buildBaseUrl(request));
        model.addAttribute("verifiedBanner", true);
        model.addAttribute("isOwner", user != null && user.getUserId().equals(cert.getStudentId()));
        return "courses/certificate-detail";
    }

    /**
     * Truy cập nhanh chứng chỉ của khóa học (tự động cấp nếu đã hoàn thành 100%)
     */
    @GetMapping("/courses/{courseId}/certificate")
    public String courseCertificate(@PathVariable Integer courseId,
                                    @AuthenticationPrincipal CustomUserDetails user,
                                    RedirectAttributes flash) {
        if (user == null) {
            return "redirect:/login";
        }
        try {
            CertificateView cert = certificateService.claimOrGetCertificate(user.getUserId(), courseId);
            return "redirect:/certificates/" + cert.getCertificateId();
        } catch (CourseActionException ex) {
            flash.addFlashAttribute("error", ex.getMessage());
            return "redirect:/courses/" + courseId + "/learn";
        }
    }

    /**
     * Học viên bấm nút "Nhận Chứng chỉ" sau khi hoàn thành khóa học
     */
    @PostMapping("/courses/{courseId}/certificate/claim")
    public String claimCertificate(@PathVariable Integer courseId,
                                   @AuthenticationPrincipal CustomUserDetails user,
                                   RedirectAttributes flash) {
        if (user == null) {
            return "redirect:/login";
        }
        try {
            CertificateView cert = certificateService.claimOrGetCertificate(user.getUserId(), courseId);
            flash.addFlashAttribute("success",
                    "🎉 Chúc mừng! Bạn đã nhận được chứng chỉ hoàn thành khóa học \"" + cert.getCourseTitle() + "\"!");
            return "redirect:/certificates/" + cert.getCertificateId();
        } catch (CourseActionException ex) {
            flash.addFlashAttribute("error", ex.getMessage());
            return "redirect:/courses/" + courseId + "/learn";
        }
    }

    private String buildBaseUrl(HttpServletRequest request) {
        String scheme = request.getScheme();
        String host = request.getServerName();
        int port = request.getServerPort();
        String ctx = request.getContextPath() != null ? request.getContextPath() : "";
        boolean standardPort = ("http".equalsIgnoreCase(scheme) && port == 80)
                || ("https".equalsIgnoreCase(scheme) && port == 443);
        return scheme + "://" + host + (standardPort ? "" : ":" + port) + ctx;
    }

    @ExceptionHandler(CourseActionException.class)
    public String handleCertificateError(CourseActionException ex, HttpServletResponse response, Model model) {
        response.setStatus(ex.getStatus().value());
        model.addAttribute("errorMessage", ex.getMessage());
        return "courses/action-error";
    }
}
