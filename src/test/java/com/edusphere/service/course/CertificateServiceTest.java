package com.edusphere.service.course;

import com.edusphere.dto.course.CertificateView;
import org.junit.jupiter.api.Test;

import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.io.ByteArrayInputStream;
import java.time.LocalDateTime;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

class CertificateServiceTest {

    @Test
    void renderCertificatePng_producesValidHighResPngImage() throws Exception {
        CertificateService service = new CertificateService(
                null, null, null, null, null, null, null, null, null, null
        );

        CertificateView cert = CertificateView.builder()
                .certificateId(101)
                .verificationCode("EDU2026CERT01")
                .issuedAt(LocalDateTime.of(2026, 11, 14, 10, 30))
                .creditsEarned(3)
                .gradePercent(95)
                .totalHours(24)
                .status("VALID")
                .studentId(10)
                .studentName("Nguyễn Văn Minh")
                .studentEmail("minh@edusphere.vn")
                .courseId(5)
                .courseTitle("Lập trình Java Web với Spring Boot & Microservices")
                .categoryName("Công nghệ phần mềm")
                .levelLabel("Trung cấp")
                .instructorName("TS. Trần Quốc Tuấn")
                .instructorTitle("Giảng viên Hướng dẫn & Chuyên gia Đào tạo")
                .lessonCount(12)
                .enrolledCount(150)
                .averageRating(4.9)
                .ratingCount(45)
                .objectivesList(List.of("Nắm vững Spring Boot", "Xây dựng RESTful API"))
                .skillsList(List.of("Java", "Spring Boot", "SQL"))
                .build();

        byte[] pngBytes = service.renderCertificatePng(cert, "https://edusphere.vn");

        assertNotNull(pngBytes);
        assertTrue(pngBytes.length > 10_000, "PNG image bytes should not be empty");

        BufferedImage img = ImageIO.read(new ByteArrayInputStream(pngBytes));
        assertNotNull(img);
        assertEquals(1800, img.getWidth());
        assertEquals(1260, img.getHeight());
    }

    public static void main(String[] args) throws Exception {
        CertificateService service = new CertificateService(
                null, null, null, null, null, null, null, null, null, null
        );
        CertificateView cert = CertificateView.builder()
                .certificateId(101)
                .verificationCode("EDU2026CERT01")
                .issuedAt(LocalDateTime.of(2026, 11, 14, 10, 30))
                .creditsEarned(3)
                .gradePercent(95)
                .totalHours(24)
                .status("VALID")
                .studentId(10)
                .studentName("Nguyễn Văn Minh")
                .studentEmail("minh@edusphere.vn")
                .courseId(5)
                .courseTitle("Lập trình Java Web với Spring Boot & Microservices")
                .categoryName("Công nghệ phần mềm")
                .levelLabel("Trung cấp")
                .instructorName("TS. Trần Quốc Tuấn")
                .instructorTitle("Giảng viên Hướng dẫn & Chuyên gia Đào tạo")
                .lessonCount(12)
                .enrolledCount(150)
                .averageRating(4.9)
                .ratingCount(45)
                .objectivesList(List.of("Nắm vững Spring Boot", "Xây dựng RESTful API"))
                .skillsList(List.of("Java", "Spring Boot", "SQL"))
                .build();

        byte[] pngBytes = service.renderCertificatePng(cert, "https://edusphere.vn");
        BufferedImage img = ImageIO.read(new ByteArrayInputStream(pngBytes));
        if (img == null || img.getWidth() != 1800 || img.getHeight() != 1260 || pngBytes.length < 10000) {
            throw new IllegalStateException("Invalid PNG output");
        }
        System.out.println("CertificateServiceTest PASSED (1800x1260 PNG, size=" + pngBytes.length + " bytes)");
    }
}
