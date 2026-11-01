package com.edusphere.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import java.io.File;

/**
 * Cấu hình Spring MVC.
 * Map URL /uploads/** -> thư mục upload thực tế trên disk.
 * Cho phép browser load ảnh avatar, thumbnail và video đã upload.
 */
@Configuration
public class WebMvcConfig implements WebMvcConfigurer {

    @Value("${app.upload.base-dir:${user.home}/edusphere/uploads}")
    private String baseUploadDir;

    @Value("${app.upload.dir:${user.home}/edusphere/uploads/avatars}")
    private String uploadDir;

    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        // Static assets từ webapp/assets — map đúng đường dẫn thực tế
        registry.addResourceHandler("/assets/**")
                .addResourceLocations("/assets/");

        // Đảm bảo đường dẫn kết thúc bằng dấu gạch chéo
        String baseDirNormalized = baseUploadDir.replace("\\", "/");
        if (!baseDirNormalized.endsWith("/")) {
            baseDirNormalized += "/";
        }

        // Tự động tạo thư mục nếu chưa tồn tại
        File dir = new File(baseUploadDir);
        if (!dir.exists()) {
            dir.mkdirs();
        }

        // Toàn bộ uploads: thumbnails, videos, materials, avatars
        registry.addResourceHandler("/uploads/**")
                .addResourceLocations("file:" + baseDirNormalized);
    }
}
