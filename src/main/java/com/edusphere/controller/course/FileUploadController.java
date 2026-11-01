package com.edusphere.controller.course;

import com.edusphere.service.course.CourseActionException;
import com.edusphere.service.course.FileUploadService;

import jakarta.servlet.http.HttpServletRequest;

import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;

import java.util.HashMap;
import java.util.Map;

@Controller
@RequestMapping("/instructor/upload")
@PreAuthorize("hasRole('INSTRUCTOR')")
public class FileUploadController {

    private final FileUploadService uploadService;

    public FileUploadController(FileUploadService uploadService) {
        this.uploadService = uploadService;
    }

    @PostMapping
    @ResponseBody
    public ResponseEntity<Map<String, Object>> uploadFile(
            @RequestParam("file") MultipartFile file,
            @RequestParam(value = "category", defaultValue = "general") String category,
            HttpServletRequest request) {

        Map<String, Object> response = new HashMap<>();
        try {
            String path = uploadService.storeFile(file, category);
            String fullUrl = request.getContextPath() + path;

            response.put("success", true);
            response.put("path", path);
            response.put("url", fullUrl);
            response.put("originalName", file.getOriginalFilename());
            response.put("size", file.getSize());

            return ResponseEntity.ok(response);
        } catch (CourseActionException ex) {
            response.put("success", false);
            response.put("message", ex.getMessage());
            return ResponseEntity.status(ex.getStatus()).body(response);
        } catch (Exception ex) {
            response.put("success", false);
            response.put("message", "Đã có lỗi xảy ra khi tải tệp lên: " + ex.getMessage());
            return ResponseEntity.internalServerError().body(response);
        }
    }
}

