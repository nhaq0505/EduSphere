package com.edusphere.config;

import com.edusphere.service.course.CourseActionException;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.multipart.MaxUploadSizeExceededException;
import org.springframework.web.servlet.NoHandlerFoundException;
import org.springframework.web.servlet.resource.NoResourceFoundException;

import java.util.Map;

/**
 * Xử lý lỗi toàn cục — không để lộ stack trace ra UI nhưng log đầy đủ ở server.
 */
@ControllerAdvice
public class GlobalExceptionHandler {

    private static final Logger log = LoggerFactory.getLogger(GlobalExceptionHandler.class);

    /**
     * 413 — File tải lên vượt quá dung lượng cho phép.
     */
    @ExceptionHandler(MaxUploadSizeExceededException.class)
    public Object handleMaxUploadSizeExceeded(MaxUploadSizeExceededException ex,
                                              HttpServletRequest request,
                                              HttpServletResponse response,
                                              Model model) {
        log.warn("MaxUploadSizeExceededException: {}", ex.getMessage());
        String msg = "File vượt quá dung lượng tối đa cho phép (100MB).";
        if (expectsJson(request)) {
            return ResponseEntity.status(HttpStatus.PAYLOAD_TOO_LARGE)
                    .body(Map.of("success", false, "error", msg, "message", msg));
        }
        response.setStatus(HttpStatus.PAYLOAD_TOO_LARGE.value());
        model.addAttribute("errorMessage", msg);
        return "error/403";
    }

    /**
     * Nghiệp vụ khóa học không hợp lệ hoặc bị cấm (CourseActionException).
     */
    @ExceptionHandler(CourseActionException.class)
    public Object handleCourseAction(CourseActionException ex,
                                     HttpServletRequest request,
                                     HttpServletResponse response,
                                     Model model) {
        log.warn("CourseActionException at {}: status={}, message={}", request.getRequestURI(), ex.getStatus(), ex.getMessage());
        if (expectsJson(request)) {
            return ResponseEntity.status(ex.getStatus())
                    .body(Map.of("success", false, "error", ex.getMessage(), "message", ex.getMessage()));
        }
        response.setStatus(ex.getStatus().value());
        model.addAttribute("errorMessage", ex.getMessage());
        return "courses/action-error";
    }

    /**
     * 403 — Không có quyền truy cập.
     */
    @ExceptionHandler(AccessDeniedException.class)
    public String handleAccessDenied(AccessDeniedException ex,
                                     HttpServletResponse response,
                                     Model model) {
        log.warn("AccessDeniedException: {}", ex.getMessage());
        response.setStatus(HttpServletResponse.SC_FORBIDDEN);
        model.addAttribute("errorMessage", "Bạn không có quyền truy cập trang này.");
        return "error/403";
    }

    /**
     * 404 — Không tìm thấy tài nguyên hoặc đường dẫn.
     */
    @ExceptionHandler({NoResourceFoundException.class, NoHandlerFoundException.class})
    public String handleNotFound(Exception ex,
                                 HttpServletResponse response,
                                 Model model) {
        log.debug("Resource not found: {}", ex.getMessage());
        response.setStatus(HttpServletResponse.SC_NOT_FOUND);
        model.addAttribute("errorMessage", "Không tìm thấy trang hoặc tài nguyên yêu cầu.");
        return "error/404";
    }

    /**
     * 500 — Lỗi hệ thống chung (không lộ thông báo SQL / stack trace ra giao diện).
     */
    @ExceptionHandler(Exception.class)
    public Object handleGeneralException(Exception ex,
                                         HttpServletRequest request,
                                         HttpServletResponse response,
                                         Model model) {
        log.error("Unhandled exception at {}: {}", request.getRequestURI(), ex.getMessage(), ex);
        ex.printStackTrace();
        String safeMsg = "Đã xảy ra lỗi hệ thống.";
        if (expectsJson(request)) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("success", false, "error", safeMsg, "message", safeMsg));
        }
        response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        model.addAttribute("errorMessage", "Đã xảy ra lỗi hệ thống. Vui lòng thử lại sau.");
        return "error/403";
    }

    private boolean expectsJson(HttpServletRequest request) {
        if (request == null) {
            return false;
        }
        String uri = request.getRequestURI() != null ? request.getRequestURI() : "";
        String contextPath = request.getContextPath() != null ? request.getContextPath() : "";
        String accept = request.getHeader("Accept");
        String requestedWith = request.getHeader("X-Requested-With");
        return uri.startsWith("/instructor/upload")
                || uri.startsWith(contextPath + "/instructor/upload")
                || (accept != null && accept.contains("application/json"))
                || "XMLHttpRequest".equalsIgnoreCase(requestedWith);
    }
}
