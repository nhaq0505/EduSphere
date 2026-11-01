package com.edusphere.config;

import org.springframework.security.access.AccessDeniedException;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;

/**
 * Xử lý lỗi toàn cục — không để lộ stack trace ra UI nhưng log đầy đủ ở server.
 */
@ControllerAdvice
public class GlobalExceptionHandler {

    /**
     * 403 — Không có quyền truy cập.
     */
    @ExceptionHandler(AccessDeniedException.class)
    public String handleAccessDenied(AccessDeniedException ex, Model model) {
        System.err.println("AccessDeniedException: " + ex.getMessage());
        model.addAttribute("errorMessage", "Bạn không có quyền truy cập trang này.");
        return "error/403";
    }

    /**
     * Lỗi chung — hiển thị thông điệp và log console.
     */
    @ExceptionHandler(Exception.class)
    public String handleGenericError(Exception ex, Model model) {
        System.err.println("Unhandled exception: " + ex.getMessage());
        ex.printStackTrace();
        model.addAttribute("errorMessage", "Đã xảy ra lỗi: " + (ex.getMessage() != null ? ex.getMessage() : ex.getClass().getSimpleName()));
        return "error/403";
    }
}
