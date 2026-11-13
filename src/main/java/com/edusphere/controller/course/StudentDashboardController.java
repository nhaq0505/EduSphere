package com.edusphere.controller.course;

import com.edusphere.dto.course.StudentDashboardView;
import com.edusphere.security.CustomUserDetails;
import com.edusphere.service.course.StudentDashboardService;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class StudentDashboardController {


    }

        if (user == null) {
            return "redirect:/login";
        }
    }
}
