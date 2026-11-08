package com.edusphere.controller.course;

import com.edusphere.security.CustomUserDetails;
import com.edusphere.service.course.CourseActionException;
import com.edusphere.service.course.RevenueService;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.math.BigDecimal;

/**
 * Controller quản lý trang Doanh thu & Ví tiền của Giảng viên (/instructor/revenue)
 * và trang Quản lý Doanh thu & Duyệt rút tiền của Admin (/admin/revenue).
 */
@Controller
public class RevenueController {

    private final RevenueService revenueService;

    public RevenueController(RevenueService revenueService) {
        this.revenueService = revenueService;
    }

    // ==================== INSTRUCTOR REVENUE & WALLET ====================

    /**
     * Hiển thị trang Doanh thu & Ví tiền cho Giảng viên (hỗ trợ lọc giao dịch theo khóa học).
     */
    @GetMapping("/instructor/revenue")
    public String instructorRevenue(@RequestParam(value = "courseId", required = false) Integer courseId,
                                    @AuthenticationPrincipal CustomUserDetails user,
                                    Model model) {
        RevenueService.InstructorRevenueDashboard revenue =
                revenueService.getInstructorRevenue(user.getUserId(), courseId);
        model.addAttribute("revenue", revenue);
        return "courses/instructor-revenue";
    }

    /**
     * Xử lý khi Giảng viên gửi form yêu cầu rút tiền từ số dư khả dụng về tài khoản ngân hàng.
     */
    @PostMapping("/instructor/revenue/payouts")
    public String requestPayout(@RequestParam("amount") BigDecimal amount,
                                @RequestParam("bankName") String bankName,
                                @RequestParam("accountNumber") String accountNumber,
                                @RequestParam("accountHolder") String accountHolder,
                                @RequestParam(value = "instructorNote", required = false) String instructorNote,
                                @AuthenticationPrincipal CustomUserDetails user,
                                RedirectAttributes flash) {
        try {
            revenueService.requestPayout(
                    user.getUserId(), amount, bankName, accountNumber, accountHolder, instructorNote);
            flash.addFlashAttribute("success",
                    "Đã gửi yêu cầu rút tiền thành công! Quản trị viên sẽ đối soát và chuyển khoản cho bạn.");
        } catch (CourseActionException ex) {
            flash.addFlashAttribute("error", ex.getMessage());
        } catch (Exception ex) {
            flash.addFlashAttribute("error", "Không thể gửi yêu cầu rút tiền: " + ex.getMessage());
        }
        return "redirect:/instructor/revenue";
    }

    // ==================== ADMIN REVENUE & PAYOUT APPROVAL ====================

    /**
     * Hiển thị trang Tổng quan Doanh thu toàn hệ thống & Danh sách yêu cầu rút tiền cho Admin.
     */
    @GetMapping("/admin/revenue")
    public String adminRevenue(Model model) {
        RevenueService.AdminRevenueDashboard revenue = revenueService.getAdminRevenue();
        model.addAttribute("revenue", revenue);
        return "admin/revenue";
    }

    /**
     * Xử lý khi Admin bấm phê duyệt (xác nhận đã chuyển khoản) cho một yêu cầu rút tiền của Giảng viên.
     */
    @PostMapping("/admin/revenue/payouts/{payoutId}/approve")
    public String approvePayout(@PathVariable Integer payoutId,
                                @RequestParam(value = "adminNote", required = false) String adminNote,
                                @AuthenticationPrincipal CustomUserDetails admin,
                                RedirectAttributes flash) {
        try {
            revenueService.approvePayout(payoutId, admin.getUserId(), adminNote);
            flash.addFlashAttribute("success",
                    "Đã phê duyệt và xác nhận thanh toán yêu cầu rút tiền #" + payoutId + ".");
        } catch (CourseActionException ex) {
            flash.addFlashAttribute("error", ex.getMessage());
        }
        return "redirect:/admin/revenue";
    }

    /**
     * Xử lý khi Admin từ chối một yêu cầu rút tiền (hoàn lại số tiền vào số dư khả dụng của Giảng viên).
     */
    @PostMapping("/admin/revenue/payouts/{payoutId}/reject")
    public String rejectPayout(@PathVariable Integer payoutId,
                               @RequestParam(value = "adminNote", required = false) String adminNote,
                               @AuthenticationPrincipal CustomUserDetails admin,
                               RedirectAttributes flash) {
        try {
            revenueService.rejectPayout(payoutId, admin.getUserId(), adminNote);
            flash.addFlashAttribute("success",
                    "Đã từ chối yêu cầu rút tiền #" + payoutId + ". Số tiền đã được hoàn lại vào số dư khả dụng của giảng viên.");
        } catch (CourseActionException ex) {
            flash.addFlashAttribute("error", ex.getMessage());
        }
        return "redirect:/admin/revenue";
    }
}
