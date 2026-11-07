package com.edusphere.service.course;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.Locale;
import java.util.Set;
import java.util.UUID;

@Service
public class FileUploadService {

    private static final Set<String> ALLOWED_IMAGE_EXTS = Set.of("jpg", "jpeg", "png", "webp", "gif");
    private static final Set<String> ALLOWED_VIDEO_EXTS = Set.of("mp4", "webm", "mov", "mkv", "avi");
    private static final Set<String> ALLOWED_DOC_EXTS   = Set.of("pdf", "doc", "docx", "ppt", "pptx", "xls", "xlsx", "zip", "rar", "txt");

    @Value("${app.upload.base-dir:${user.home}/edusphere/uploads}")
    private String baseUploadDir;

    public String storeFile(MultipartFile file, String category) {
        if (file == null || file.isEmpty()) {
            throw new CourseActionException(HttpStatus.BAD_REQUEST, "Tệp tải lên không được để trống.");
        }

        String originalName = file.getOriginalFilename();
        if (originalName == null || !originalName.contains(".")) {
            throw new CourseActionException(HttpStatus.BAD_REQUEST, "Tên tệp không hợp lệ.");
        }

        String ext = originalName.substring(originalName.lastIndexOf('.') + 1).toLowerCase(Locale.ROOT);
        String subFolder = "general";

        if ("thumbnail".equalsIgnoreCase(category) || "image".equalsIgnoreCase(category)) {
            if (!ALLOWED_IMAGE_EXTS.contains(ext)) {
                throw new CourseActionException(HttpStatus.BAD_REQUEST, "Định dạng ảnh không hỗ trợ. Cho phép: JPG, PNG, WEBP, GIF.");
            }
            subFolder = "thumbnails";
        } else if ("video".equalsIgnoreCase(category)) {
            if (!ALLOWED_VIDEO_EXTS.contains(ext)) {
                throw new CourseActionException(HttpStatus.BAD_REQUEST, "Định dạng video không hỗ trợ. Cho phép: MP4, WEBM, MOV.");
            }
            subFolder = "videos";
        } else if ("material".equalsIgnoreCase(category) || "document".equalsIgnoreCase(category)) {
            if (!ALLOWED_DOC_EXTS.contains(ext) && !ALLOWED_IMAGE_EXTS.contains(ext) && !ALLOWED_VIDEO_EXTS.contains(ext)) {
                throw new CourseActionException(HttpStatus.BAD_REQUEST, "Định dạng tài liệu không hỗ trợ. Cho phép: PDF, Word, PPTX, ZIP.");
            }
            subFolder = "materials";
        }

        try {
            Path targetDir = Paths.get(baseUploadDir, subFolder);
            if (!Files.exists(targetDir)) {
                Files.createDirectories(targetDir);
            }

            String cleanName = originalName.replaceAll("[^a-zA-Z0-9.-]", "_");
            String storedFileName = System.currentTimeMillis() + "_" + UUID.randomUUID().toString().substring(0, 8) + "_" + cleanName;
            Path targetPath = targetDir.resolve(storedFileName);

            Files.copy(file.getInputStream(), targetPath, StandardCopyOption.REPLACE_EXISTING);

            // Web-accessible URL path
            return "/uploads/" + subFolder + "/" + storedFileName;
        } catch (IOException e) {
            throw new CourseActionException(HttpStatus.INTERNAL_SERVER_ERROR, "Không thể lưu tệp lên hệ thống: " + e.getMessage());
        }
    }

    public String storeBytes(byte[] data, String ext, String subFolder) {
        if (data == null || data.length == 0) return null;
        try {
            Path targetDir = Paths.get(baseUploadDir, subFolder);
            if (!Files.exists(targetDir)) {
                Files.createDirectories(targetDir);
            }
            String storedFileName = System.currentTimeMillis() + "_" + UUID.randomUUID().toString().substring(0, 8) + "." + ext;
            Path targetPath = targetDir.resolve(storedFileName);
            Files.write(targetPath, data);
            return "/uploads/" + subFolder + "/" + storedFileName;
        } catch (IOException e) {
            return null;
        }
    }
}

