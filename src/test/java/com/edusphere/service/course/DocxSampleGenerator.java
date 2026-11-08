package com.edusphere.service.course;

import org.apache.poi.xwpf.usermodel.ParagraphAlignment;
import org.apache.poi.xwpf.usermodel.XWPFDocument;
import org.apache.poi.xwpf.usermodel.XWPFParagraph;
import org.apache.poi.xwpf.usermodel.XWPFRun;

import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.file.Path;
import java.nio.file.Paths;

public class DocxSampleGenerator {

    public static void main(String[] args) {
        String outputPath = args.length > 0 ? args[0] : "Mau_Cau_Hoi_EduSphere.docx";

        try (XWPFDocument doc = new XWPFDocument();
             FileOutputStream fos = new FileOutputStream(outputPath)) {

            // Header Title
            XWPFParagraph titlePara = doc.createParagraph();
            titlePara.setAlignment(ParagraphAlignment.CENTER);
            XWPFRun titleRun = titlePara.createRun();
            titleRun.setText("BỘ ĐỀ CÂU HỎI MẪU - EDUSPHERE");
            titleRun.setBold(true);
            titleRun.setFontSize(16);
            titleRun.setColor("1E40AF");
            titleRun.setFontFamily("Arial");

            // Subtitle
            XWPFParagraph subPara = doc.createParagraph();
            subPara.setAlignment(ParagraphAlignment.CENTER);
            XWPFRun subRun = subPara.createRun();
            subRun.setText("(Mẫu tệp Word chuẩn hỗ trợ nhập câu hỏi trắc nghiệm, đúng/sai, tự luận và ảnh minh họa)");
            subRun.setItalic(true);
            subRun.setFontSize(11);
            subRun.setColor("4B5563");
            subRun.setFontFamily("Arial");

            doc.createParagraph(); // Spacing

            // Câu 1: Trắc nghiệm 1 đáp án
            addPara(doc, "Câu 1: Ngôn ngữ lập trình nào sau đây chạy trực tiếp trên máy ảo Java (JVM)?", true, "111827");
            addPara(doc, "A. Java", false, "374151");
            addPara(doc, "B. C++", false, "374151");
            addPara(doc, "C. PHP", false, "374151");
            addPara(doc, "D. Ruby", false, "374151");
            addPara(doc, "Đáp án: A", true, "15803D");
            addPara(doc, "Lời giải: Java biên dịch mã nguồn thành bytecode (.class) và được thực thi trên máy ảo Java Virtual Machine (JVM).", false, "0369A1");
            doc.createParagraph();

            // Câu 2: Trắc nghiệm nhiều đáp án
            addPara(doc, "Câu 2: Các phương thức HTTP nào thường được sử dụng trong việc thiết kế RESTful API?", true, "111827");
            addPara(doc, "A. GET", false, "374151");
            addPara(doc, "B. POST", false, "374151");
            addPara(doc, "C. FETCH", false, "374151");
            addPara(doc, "D. DELETE", false, "374151");
            addPara(doc, "Đáp án: A, B, D", true, "15803D");
            addPara(doc, "Lời giải: GET (lấy dữ liệu), POST (tạo mới) và DELETE (xóa) là các HTTP methods tiêu chuẩn của REST API.", false, "0369A1");
            doc.createParagraph();

            // Câu 3: Đúng / Sai
            addPara(doc, "Câu 3: Giao thức HTTPS sử dụng cơ chế mã hóa SSL/TLS để bảo mật đường truyền mạng?", true, "111827");
            addPara(doc, "A. Đúng", false, "374151");
            addPara(doc, "B. Sai", false, "374151");
            addPara(doc, "Đáp án: A", true, "15803D");
            addPara(doc, "Lời giải: Đúng, HTTPS bảo mật hơn HTTP thông qua lớp chứng chỉ bảo mật SSL/TLS.", false, "0369A1");
            doc.createParagraph();

            // Câu 4: Tự luận
            addPara(doc, "Câu 4: [Tự luận] Trình bày 4 tính chất cơ bản của lập trình hướng đối tượng (OOP). Nêu ví dụ về tính Kế thừa.", true, "111827");
            addPara(doc, "Lời giải: 4 tính chất OOP gồm: Đóng gói (Encapsulation), Kế thừa (Inheritance), Đa hình (Polymorphism), Trừu tượng (Abstraction). Ví dụ: Lớp Dog kế thừa lớp Animal, có thể dùng lại các thuộc tính như eat(), sleep() của Animal.", false, "0369A1");

            doc.write(fos);
            System.out.println("Đã tạo file Word mẫu thành công tại: " + outputPath);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    private static void addPara(XWPFDocument doc, String text, boolean bold, String hexColor) {
        XWPFParagraph p = doc.createParagraph();
        XWPFRun r = p.createRun();
        r.setText(text);
        r.setBold(bold);
        r.setFontFamily("Arial");
        r.setFontSize(12);
        if (hexColor != null) {
            r.setColor(hexColor);
        }
    }
}

