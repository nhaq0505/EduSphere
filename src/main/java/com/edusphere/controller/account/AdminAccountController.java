package com.edusphere.controller.account;

import com.edusphere.security.CustomUserDetails;
import com.edusphere.service.account.AdminAccountService;

import java.util.List;

import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Controller
@RequestMapping("/admin/users")
public class AdminAccountController {
    private final AdminAccountService accounts;

    public AdminAccountController(AdminAccountService accounts) {
        this.accounts = accounts;
    }

    @GetMapping
    public String list(@RequestParam(defaultValue = "") String q,
                       @RequestParam(defaultValue = "0") int page,
                       @AuthenticationPrincipal CustomUserDetails actor, Model model) {
        model.addAttribute("usersPage", accounts.search(q, page, actor.getUserId()));
        model.addAttribute("q", q.trim());
        return "admin/users";
    }

    @PostMapping("/{id}/roles")
    public String roles(@PathVariable Integer id, @RequestParam(required = false) List<String> roles,
                        @AuthenticationPrincipal CustomUserDetails actor,
                        RedirectAttributes redirect) {
        try {
            accounts.changeRoles(actor.getUserId(), id, roles);
            redirect.addFlashAttribute("success", "Đã cập nhật vai trò tài khoản.");
        } catch (IllegalArgumentException | IllegalStateException ex) {
            redirect.addFlashAttribute("error", ex.getMessage());
        }
        return "redirect:/admin/users";
    }

    @PostMapping("/{id}/status")
    public String status(@PathVariable Integer id, @RequestParam String action,
                         @RequestParam(required = false) String reason,
                         @AuthenticationPrincipal CustomUserDetails actor,
                         RedirectAttributes redirect) {
        try {
            accounts.changeStatus(actor.getUserId(), id, action, reason);
            redirect.addFlashAttribute("success", "Đã cập nhật trạng thái tài khoản.");
        } catch (IllegalArgumentException ex) {
            redirect.addFlashAttribute("error", ex.getMessage());
        }
        return "redirect:/admin/users";
    }
}
