-- EduSphere: three complete self-study starter courses, authored 2026-10-14.
-- Run after SQLQuery1.sql and scripts/seed-demo.sql, in SSMS or sqlcmd UTF-8.
-- Inserts only missing courses owned by instructor@instructor.com. Existing course
-- contents, credentials and learning progress are not changed on reruns.
-- Enrolls student@student.com when the active student account is present.
-- Official resources are linked, not copied. Spring guides use Thymeleaf in places;
-- course examples explicitly use the existing Java 17 / Spring Boot 3.3 / JSP stack.
USE [EduSphere];
GO
SET NOCOUNT ON;
SET XACT_ABORT ON;
SET ANSI_NULLS ON;
SET ANSI_PADDING ON;
SET ANSI_WARNINGS ON;
SET ARITHABORT ON;
SET CONCAT_NULL_YIELDS_NULL ON;
SET QUOTED_IDENTIFIER ON;
SET NUMERIC_ROUNDABORT OFF;
BEGIN TRY
    BEGIN TRANSACTION;
    DECLARE @lock_result INT;
    EXEC @lock_result = sys.sp_getapplock @Resource = N'EduSphere_learning_seed_20261014',
        @LockMode = N'Exclusive', @LockOwner = N'Transaction', @LockTimeout = 15000;
    IF @lock_result < 0 THROW 51010, 'Could not acquire the content seed lock.', 1;
    DECLARE @instructor_id INT = (
        SELECT u.user_id FROM dbo.users u JOIN dbo.user_roles ur ON ur.user_id = u.user_id
        JOIN dbo.roles r ON r.role_id = ur.role_id
        WHERE u.email = N'instructor@instructor.com' AND u.status = N'ACTIVE' AND r.role_name = N'INSTRUCTOR');
    DECLARE @admin_id INT = (
        SELECT u.user_id FROM dbo.users u JOIN dbo.user_roles ur ON ur.user_id = u.user_id
        JOIN dbo.roles r ON r.role_id = ur.role_id
        WHERE u.email = N'admin@admin.com' AND u.status = N'ACTIVE' AND r.role_name = N'ADMINISTRATOR');
    DECLARE @student_id INT = (
        SELECT u.user_id FROM dbo.users u JOIN dbo.user_roles ur ON ur.user_id = u.user_id
        JOIN dbo.roles r ON r.role_id = ur.role_id
        WHERE u.email = N'student@student.com' AND u.status = N'ACTIVE' AND r.role_name = N'STUDENT');
    IF @instructor_id IS NULL OR @admin_id IS NULL
        THROW 51011, 'Run seed-demo.sql first: an active demo instructor and administrator are required.', 1;
    DECLARE @now DATETIME2 = SYSDATETIME();
    DECLARE @courseData TABLE (title NVARCHAR(255) PRIMARY KEY, description NVARCHAR(MAX), category_name NVARCHAR(100), level NVARCHAR(20));
    INSERT INTO @courseData VALUES
    (N'Java nền tảng: từ biến đến ứng dụng quản lý khóa học', N'Lộ trình tự học 4 bài dành cho người mới, khoảng 3–4 giờ. Dùng Java 17 và IntelliJ IDEA hoặc terminal. Bạn sẽ viết chương trình tính điểm, thiết kế lớp Course và quản lý danh sách khóa học. Mỗi bài có giải thích, ví dụ chạy được, bài thực hành và đáp án tự kiểm tra. Nội dung tiếng Việt do EduSphere biên soạn; tài liệu tham khảo chính thức bằng tiếng Anh.', N'Lập trình', N'BEGINNER'),
    (N'Spring MVC và JSP: hiểu luồng code qua EduSphere', N'4 bài thực hành trực tiếp với Java 17, Spring Boot 3.3 và JSP trong EduSphere, khoảng 3–4 giờ. Đi từ URL, Controller và Model tới nhận form, Service/Repository và tài khoản đang đăng nhập. Cần biết Java cơ bản và đã chạy được dự án. Các ví dụ dùng JSP; một số hướng dẫn Spring tham khảo dùng Thymeleaf để minh họa cùng nguyên lý MVC.', N'Lập trình', N'INTERMEDIATE'),
    (N'SQL Server thực hành: thiết kế bảng, truy vấn và giao dịch', N'4 bài SQL Server cơ bản, khoảng 3–4 giờ, thực hành bằng SSMS hoặc công cụ truy vấn tương đương. Dùng bảng tạm #CourseLab và #EnrollmentLab để học mà không sửa các bảng thật của EduSphere. Có dữ liệu mẫu, câu truy vấn, bài tập và kết quả mong đợi. Cần có kết nối SQL Server; giữ cùng một cửa sổ truy vấn cho các bài.', N'Dữ liệu', N'BEGINNER');
    DECLARE @lessonData TABLE (course_title NVARCHAR(255), order_index INT, title NVARCHAR(255), content NVARCHAR(MAX), PRIMARY KEY (course_title, order_index));
    INSERT INTO @lessonData VALUES
    (N'Java nền tảng: từ biến đến ứng dụng quản lý khóa học', 1, N'Chạy chương trình Java đầu tiên và hiểu biến, kiểu dữ liệu', N'MỤC TIÊU · 35–45 phút
Sau bài này, bạn có thể biên dịch và chạy một chương trình Java 17, giải thích biến là gì và phân biệt int, double, boolean, String.

1. CHUẨN BỊ
Cài JDK 17 và kiểm tra bằng hai lệnh java -version, javac -version. JDK chứa công cụ phát triển; javac chuyển file .java thành bytecode .class, còn java khởi chạy chương trình. Nếu terminal báo không tìm thấy javac, kiểm tra lại JDK/PATH trước khi viết tiếp.

2. CHƯƠNG TRÌNH ĐẦU TIÊN
Tạo file Main.java rồi nhập:

public class Main {
    public static void main(String[] args) {
        String courseName = "Java nền tảng";
        int lessons = 4;
        double hoursPerLesson = 0.75;
        boolean free = true;
        double totalHours = lessons * hoursPerLesson;
        System.out.println(courseName);
        System.out.println("Thời lượng: " + totalHours + " giờ");
        System.out.println("Miễn phí: " + free);
    }
}

Chạy javac -encoding UTF-8 Main.java, sau đó java Main. Tên file phải trùng với lớp public Main. main là điểm bắt đầu. Dấu ; kết thúc câu lệnh. int lưu số nguyên; double lưu số thực; boolean nhận true/false; String lưu chuỗi. Khi nối chuỗi với số bằng +, kết quả là chuỗi.

3. THỰC HÀNH
Đổi lessons thành 6 và hoursPerLesson thành 0.5. Thêm biến int students = 12 và in: "Khóa Java nền tảng có 12 học viên". Thử sửa int lessons = 4.5 và đọc lỗi trình biên dịch, sau đó sửa lại. Không đánh dấu đã học trước khi tự chạy ví dụ.

4. TỰ KIỂM TRA
Kết quả thời lượng sau khi sửa là 3.0 giờ. int không nhận trực tiếp 4.5 vì đó là số có phần thập phân. Phân biệt lỗi biên dịch với kết quả chương trình không đúng mong muốn. double phù hợp ví dụ thời lượng; khi làm tiền trong dự án thật, dùng BigDecimal để kiểm soát độ chính xác.

KHI HOÀN THÀNH
Bạn có file Main.java chạy được và tự giải thích được mỗi biến đang chứa gì. Mở tài liệu Java bên dưới để đọc thêm, rồi bấm Đánh dấu đã học.'),
    (N'Java nền tảng: từ biến đến ứng dụng quản lý khóa học', 2, N'Điều kiện, vòng lặp và phương thức qua bài toán tính điểm', N'MỤC TIÊU · 45 phút
Viết được điều kiện if, duyệt mảng bằng for và tách một phép tính thành phương thức có giá trị trả về. Dùng lại file Main.java của bài trước hoặc tạo project console mới.

1. TỪ YÊU CẦU ĐẾN CODE
Ta muốn tính trung bình ba điểm và kết luận đạt khi trung bình từ 5 trở lên. Phương thức nhận đầu vào qua tham số và trả đầu ra bằng return. Biến nằm trong phương thức chỉ dùng được trong phạm vi của nó.

public class Main {
    static double average(double[] scores) {
        if (scores.length == 0) {
            throw new IllegalArgumentException("Danh sách điểm rỗng");
        }
        double total = 0;
        for (double score : scores) {
            total += score;
        }
        return total / scores.length;
    }

    public static void main(String[] args) {
        double result = average(new double[] {6, 8, 4});
        if (result >= 5) {
            System.out.println("Đạt: " + result);
        } else {
            System.out.println("Chưa đạt: " + result);
        }
    }
}

2. ĐỌC LUỒNG CHẠY
main gọi average. Vòng for lần lượt lấy 6, 8, 4 và cộng vào total. return đưa kết quả 6.0 về biến result, sau đó if chọn nhánh in Đạt. return kết thúc lần gọi phương thức; nó không tự in kết quả. Nhánh kiểm tra mảng rỗng tránh phép chia cho 0.

3. THỰC HÀNH
Chạy với {2, 4, 3}, rồi {5, 5, 5}; dự đoán kết quả trước khi chạy. Viết thêm static String classify(double score), trả "Giỏi" nếu >= 8, "Đạt" nếu >= 5 và "Cần ôn" trong các trường hợp còn lại. Kiểm tra score nằm ngoài 0–10 bằng IllegalArgumentException.

4. TỰ KIỂM TRA
Hai bộ điểm có trung bình 3.0 và 5.0. Trong classify, kiểm tra >= 8 trước >= 5; nếu đảo thứ tự, điểm 9 sẽ bị phân loại thành Đạt. Khi so sánh chuỗi, dùng equals thay cho == để so nội dung. Với nhiều dữ liệu đầu vào, thử cả giá trị nhỏ nhất, lớn nhất và trường hợp không hợp lệ.

KHI HOÀN THÀNH
Bạn có average và classify chạy đúng ở các mốc 0, 5, 8, 10, đồng thời biết lỗi được ném ở đâu khi nhập -1.'),
    (N'Java nền tảng: từ biến đến ứng dụng quản lý khóa học', 3, N'Class, object và constructor: tự viết lớp Course', N'MỤC TIÊU · 45 phút
Phân biệt class với object, khởi tạo object bằng constructor và giữ quy tắc dữ liệu bên trong class. Ví dụ dùng Java thuần, chưa dùng Spring hoặc database.

1. CLASS MÔ TẢ, OBJECT LÀ MỘT TRƯỜNG HỢP CỤ THỂ
Course mô tả thông tin chung của khóa học. Mỗi lần new Course(...) tạo một object khác. Đặt thuộc tính private để bên ngoài không tùy ý đổi dữ liệu, rồi cung cấp phương thức cần thiết.

public class Course {
    private final String title;
    private int lessonCount;

    public Course(String title) {
        if (title == null || title.isBlank()) {
            throw new IllegalArgumentException("Tên không được trống");
        }
        this.title = title.trim();
    }

    public String getTitle() { return title; }
    public int getLessonCount() { return lessonCount; }
    public void addLesson() { lessonCount++; }
}

Lưu vào Course.java. Trong main của Main.java:

Course java = new Course("Java nền tảng");
Course sql = new Course("SQL Server");
java.addLesson();
java.addLesson();
System.out.println(java.getTitle() + ": " + java.getLessonCount());
System.out.println(sql.getLessonCount());

Biên dịch javac -encoding UTF-8 Main.java Course.java rồi chạy java Main. this.title là thuộc tính của object hiện tại; title trong constructor là tham số nhận vào. final ngăn gán lại title sau khi khởi tạo. Hai object có lessonCount riêng nên tăng số bài của java không làm sql thay đổi.

2. THỰC HÀNH
Thêm private String description, getter và setter. Cho setter từ chối null, đồng thời trim khoảng trắng. Tạo hai khóa, cập nhật mô tả một khóa và in cả hai. Thử new Course("   ") và giải thích vì sao constructor báo lỗi.

3. TỰ KIỂM TRA
Ví dụ đầu in Java nền tảng: 2 rồi 0. Class không phải là một dòng trong database cho đến khi bạn ánh xạ/lưu dữ liệu. Constructor không có kiểu trả về. Getter đọc dữ liệu, setter thay đổi dữ liệu; bạn không bắt buộc phải tạo setter cho mọi thuộc tính.

KHI HOÀN THÀNH
Bạn có Course.java và Main.java, tạo được nhiều khóa độc lập, đồng thời biết quy tắc tên không trống đang được kiểm tra ở constructor.'),
    (N'Java nền tảng: từ biến đến ứng dụng quản lý khóa học', 4, N'List và bài thực hành quản lý danh sách khóa học', N'MỤC TIÊU · 50–60 phút
Dùng List/ArrayList để thêm và duyệt khóa học, sau đó tìm kiếm theo tên. Bài này cần lớp Course có getTitle() ở bài trước. Dữ liệu nằm trong RAM và sẽ mất khi chương trình dừng.

1. DANH SÁCH CÓ KIỂU
List<Course> nói rằng danh sách chứa các object Course. ArrayList là một cách cài đặt List. Chỉ số bắt đầu từ 0, vì vậy get(0) lấy phần tử đầu tiên.

import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

public class Main {
    static List<Course> search(List<Course> courses, String keyword) {
        String normalized = keyword.trim().toLowerCase(Locale.ROOT);
        List<Course> result = new ArrayList<>();
        for (Course course : courses) {
            if (course.getTitle().toLowerCase(Locale.ROOT).contains(normalized)) {
                result.add(course);
            }
        }
        return result;
    }

    public static void main(String[] args) {
        List<Course> courses = new ArrayList<>();
        courses.add(new Course("Java nền tảng"));
        courses.add(new Course("SQL Server"));
        courses.add(new Course("Java hướng đối tượng"));
        for (Course course : search(courses, "java")) {
            System.out.println(course.getTitle());
        }
    }
}

2. THỰC HÀNH
Thêm khóa Spring MVC. Tìm với các từ java, SQL và python. Với danh sách kết quả rỗng, in "Không có khóa phù hợp". Viết hàm tính tổng số bài của tất cả khóa. Mở rộng thành menu console gồm xem danh sách, tìm kiếm và thoát; đọc lựa chọn bằng Scanner.nextLine() để tránh lẫn xử lý xuống dòng.

3. TỰ KIỂM TRA
Tìm java trả hai khóa, tìm SQL trả một, python trả rỗng. search tạo danh sách kết quả mới và không xóa phần tử trong danh sách gốc. List.of(...) trả danh sách không cho thêm/xóa; nếu cần chỉnh sửa, dùng ArrayList. Tránh gọi remove trên chính danh sách đang duyệt bằng for-each vì có thể gây ConcurrentModificationException.

BÀI TỔNG KẾT KHÓA
Nộp cho chính mình một project console có Course, Main và menu tìm kiếm. Tự chạy ba tình huống: danh sách rỗng, không tìm thấy, nhiều kết quả. Sau bước này bạn đã sẵn sàng học cách đưa danh sách đó qua Service và Controller lên trang JSP.'),
    (N'Spring MVC và JSP: hiểu luồng code qua EduSphere', 1, N'GET request, Controller, Model và JSP nối với nhau thế nào?', N'MỤC TIÊU · 40 phút
Theo dõi được một lần mở trang từ trình duyệt tới JSP. Chạy EduSphere rồi mở trang danh sách khóa học. Ghi lại URL trước khi đọc code.

1. TỪ URL ĐẾN HTML
Trình duyệt gửi HTTP GET. Spring Security kiểm tra quyền truy cập, DispatcherServlet tìm phương thức Controller phù hợp, Controller gọi Service để lấy dữ liệu và đưa kết quả vào Model. ViewResolver dùng tên view mà Controller trả về để tìm JSP. JSP tạo HTML, trình duyệt nhận HTML và vẽ giao diện.

Ví dụ phương thức trong một class có @Controller:

@GetMapping("/hello")
public String hello(
        @RequestParam(defaultValue = "bạn") String name,
        Model model) {
    model.addAttribute("displayName", name);
    return "hello";
}

Tạo hello.jsp trong thư mục views đã cấu hình:

<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<p>Xin chào <c:out value="${displayName}"/></p>

Sau khi đăng nhập vào EduSphere, mở /EduSphere/hello?name=Quan để thử. Dự án yêu cầu đăng nhập cho các đường dẫn chưa được cho phép công khai; nếu bị chuyển tới login thì đó là quy tắc Security, chưa phải lỗi JSP.

2. MODEL LÀ GÌ?
Model giống một túi dữ liệu dùng cho lần hiển thị trang hiện tại. "displayName" là tên để JSP tra cứu; name là giá trị Java. return "hello" chọn view, không trả chuỗi hello ra màn hình. Dùng c:out để hiển thị dữ liệu dưới dạng văn bản và tránh diễn giải nội dung người dùng thành HTML.

3. THỰC HÀNH
Đọc CourseManagementController.myCourses(). Tách dòng model.addAttribute("courses", service.enrolledCourses(user.getUserId())) thành ba câu lệnh. Đặt breakpoint rồi kiểm tra userId, danh sách trả về và tên thuộc tính Model.

TỰ KIỂM TRA
Bạn phải chỉ ra được dữ liệu lấy từ URL qua @RequestParam khác dữ liệu đưa xuống JSP qua Model thế nào. Sau khi thử, xóa endpoint hello tự tạo để tránh để lại chức năng ngoài bài thực hành.'),
    (N'Spring MVC và JSP: hiểu luồng code qua EduSphere', 2, N'Nhận form với @ModelAttribute và hiển thị lỗi nhập liệu', N'MỤC TIÊU · 45 phút
Hiểu cách title/content từ form trở thành LessonForm. Dùng tài khoản giảng viên, tạo một khóa nháp riêng để thực hành; không sửa khóa bạn đang dùng để học.

1. MỞ FORM VÀ GỬI FORM LÀ HAI REQUEST
GET chuẩn bị đối tượng trống bằng model.addAttribute("lessonForm", new LessonForm()) rồi mở JSP. Trong JSP, form:form modelAttribute="lessonForm" liên kết form với đối tượng; form:input path="title" tạo trường mang tên title. Khi submit, trình duyệt gửi title=... và content=... qua POST.

Controller nhận dữ liệu bằng:

@PostMapping
public String create(
        @Valid @ModelAttribute("lessonForm") LessonForm form,
        BindingResult errors,
        @AuthenticationPrincipal CustomUserDetails instructor,
        Model model,
        RedirectAttributes flash) {
    // Xem phương thức đầy đủ trong LessonManagementController.
    // Kiểm tra quyền sở hữu khóa, lỗi form, rồi mới gọi Service.
    // Đoạn này chỉ minh họa chữ ký hàm, không thay thế code dự án.
    return "courses/lesson-form";
}

2. CHUYỆN GÌ DIỄN RA?
Spring khởi tạo LessonForm và gọi setter tương ứng với các trường gửi lên. @Valid chạy các ràng buộc như @NotBlank. BindingResult, đặt ngay sau form, giữ lỗi binding/validation. Khi có lỗi, Controller trả lại view form cùng dữ liệu đã nhập để người dùng sửa. Service vẫn phải kiểm tra nghiệp vụ và quyền, vì dữ liệu gửi lên có thể bị chỉnh ngoài trình duyệt.

3. CSRF VÀ REDIRECT
Form POST trong EduSphere có hidden input chứa ${_csrf.parameterName} và ${_csrf.token}. Thiếu token có thể nhận 403. Sau khi lưu thành công, redirect đưa trình duyệt sang một GET mới; flash.addFlashAttribute đưa thông báo thành công sang request đó. Model thông thường không tự đi qua redirect.

4. THỰC HÀNH VÀ KẾT QUẢ
Mở tạo bài học, gửi tên chỉ có dấu cách. Bạn phải thấy lỗi tên không hợp lệ. Nhập tên đúng, nội dung ngắn, lưu lại và kiểm tra URL đã chuyển sang chi tiết bài. Mở DevTools Network để so sánh GET mở form, POST lưu và GET sau redirect.

TỰ KIỂM TRA
@ModelAttribute nhận dữ liệu form, Model chuyển dữ liệu xuống view. Cả hai đều không tự ghi database. Chỉ sau khi Service/Repository thực hiện thành công thì bài học mới được lưu.'),
    (N'Spring MVC và JSP: hiểu luồng code qua EduSphere', 3, N'Dependency Injection, Service, Repository và giao dịch database', N'MỤC TIÊU · 45–55 phút
Giải thích được vì sao Controller nhận Service qua constructor và vì sao nghiệp vụ ghi danh không nằm trong JSP. Bài này chủ yếu đọc code hiện có, không yêu cầu tạo thêm bảng.

1. DEPENDENCY INJECTION
Spring tạo và quản lý các bean như @Controller, @Service và Spring Data repository. Controller khai báo dependency qua constructor:

private final CourseManagementService service;

public CourseManagementController(CourseManagementService service) {
    this.service = service;
}

Vì chỉ có một constructor, không cần thêm @Autowired ở đây. Khi khởi tạo Controller, Spring cung cấp Service phù hợp. Cách này tương tự constructor injection trong ASP.NET Core và giúp viết test bằng Service giả.

2. THEO DÕI VIỆC GHI DANH
Đọc enroll trong CourseManagementController, rồi mở CourseManagementService.enroll. Controller nhận courseId và tài khoản; Service kiểm tra khóa đã công bố, người dùng và ghi danh hiện có. Repository truy vấn theo studentId/courseId, sau đó lưu Enrollment. JPA ánh xạ object sang bảng SQL Server; nó không tự thay bạn quyết định ai được ghi danh.

3. @TRANSACTIONAL
Một thao tác nghiệp vụ có thể đọc và ghi nhiều bảng. @Transactional tạo ranh giới giao dịch: các thay đổi tham gia cùng giao dịch được commit khi xử lý thành công; RuntimeException mặc định làm rollback. Không bắt rồi bỏ qua lỗi nếu bạn cần toàn bộ thao tác bị hủy. @Transactional(readOnly = true) thể hiện ý định chỉ đọc, không phải cơ chế phân quyền.

4. THỰC HÀNH
Vẽ luồng Controller → Service → EnrollmentRepository → SQL Server cho một lần ghi danh. Dùng tài khoản học viên ghi danh một khóa miễn phí chưa tham gia rồi mở Khóa học của tôi. Thử truy cập khóa chưa được công bố bằng tài khoản khác và đọc nơi Service chặn yêu cầu. Khi kiểm tra database, chỉ SELECT, không xóa dữ liệu để thử lại.

TỰ KIỂM TRA
Bạn giải thích được vì sao không new CourseManagementService(...) trong Controller, vì sao Repository không chứa logic điều hướng và vì sao code chỉ có @Transactional chưa đủ để đảm bảo phân quyền. Hướng dẫn JPA tham khảo dùng database khác trong ví dụ; EduSphere vẫn dùng cấu hình SQL Server của dự án.'),
    (N'Spring MVC và JSP: hiểu luồng code qua EduSphere', 4, N'Người đang đăng nhập, phân quyền và luồng ghi danh → học bài', N'MỤC TIÊU · 45 phút
Hiểu @AuthenticationPrincipal và tái hiện trọn luồng POST ghi danh, redirect rồi GET danh sách. Dùng tài khoản học viên demo để đọc trang học, tài khoản giảng viên demo để quan sát trang quản lý.

1. NGƯỜI DÙNG ĐẾN TỪ ĐÂU?
@AuthenticationPrincipal CustomUserDetails user lấy principal mà Spring Security đã xác thực. user.getUserId() lấy ID tài khoản hiện tại. Không nhận studentId do form gửi lên để quyết định đang thao tác thay ai; người dùng có thể tự sửa trường đó. @PathVariable courseId chỉ xác định khóa được yêu cầu.

2. HAI REQUEST KHÁC NHAU
Trong Controller hiện có:

service.enroll(courseId, user.getUserId());
flash.addFlashAttribute("success", "Ghi danh thành công.");
return "redirect:/my-courses";

Đoạn trên lưu nghiệp vụ và trả lệnh chuyển hướng. Trình duyệt gửi GET /my-courses; hàm myCourses gọi service.enrolledCourses(user.getUserId()), đặt kết quả vào Model dưới tên courses và chọn courses/my-courses.jsp. JSP đọc ${courses} để hiển thị. Không có dữ liệu JSON trong luồng này.

3. ROLE KHÁC OWNERSHIP
SecurityConfig yêu cầu STUDENT cho đường học bài và INSTRUCTOR cho đường quản lý. Sau đó Service còn kiểm tra học viên đã ghi danh hay chưa, hoặc khóa có thuộc giảng viên đang đăng nhập hay không. Chỉ kiểm tra role không ngăn một giảng viên sửa khóa của giảng viên khác.

4. THỰC HÀNH
Mở DevTools Network, chọn một khóa miễn phí chưa ghi danh, bấm Ghi danh. Tìm POST, response redirect và GET kế tiếp. Từ Khóa học của tôi, bấm Vào học, mở học liệu rồi Đánh dấu đã học. Tải lại trang và xác nhận tiến độ vẫn được lưu. Đăng nhập giảng viên, thử mở URL học bài; bạn phải bị chặn bởi quy tắc role. Không dùng URL để tự gọi GET cho thao tác POST.

TỰ KIỂM TRA
Bạn phân biệt được 401/chưa xác thực, 403/không có quyền, lỗi nghiệp vụ như chưa ghi danh và chuyển hướng sau đăng nhập. Hướng dẫn tham khảo là tài liệu nền; cấu hình đang áp dụng phải đọc từ SecurityConfig của EduSphere.'),
    (N'SQL Server thực hành: thiết kế bảng, truy vấn và giao dịch', 1, N'Thiết kế bảng và tạo dữ liệu thực hành trong bảng tạm', N'MỤC TIÊU · 40 phút
Hiểu dòng, cột, khóa chính, khóa ngoại và ràng buộc dữ liệu. Mở một cửa sổ truy vấn SQL Server và giữ cửa sổ đó cho cả khóa học. Bảng bắt đầu bằng # chỉ tồn tại trong phiên kết nối hiện tại; khi mất kết nối hãy chạy lại đoạn tạo dữ liệu này.

1. TẠO BẢNG THỰC HÀNH
Các lệnh dưới đây chỉ thao tác bảng tạm, không thay đổi dbo.courses hoặc dbo.enrollments của EduSphere.

DROP TABLE IF EXISTS #EnrollmentLab;
DROP TABLE IF EXISTS #CourseLab;

CREATE TABLE #CourseLab (
    course_id INT PRIMARY KEY,
    title NVARCHAR(100) NOT NULL,
    price DECIMAL(18,2) NOT NULL CHECK (price >= 0)
);
CREATE TABLE #EnrollmentLab (
    student_name NVARCHAR(100) NOT NULL,
    course_id INT NOT NULL,
    PRIMARY KEY (student_name, course_id)
);
INSERT INTO #CourseLab VALUES
    (1, N''Java nền tảng'', 0),
    (2, N''Spring MVC'', 199000),
    (3, N''SQL Server'', 0);
INSERT INTO #EnrollmentLab VALUES
    (N''An'', 1), (N''Bình'', 1), (N''An'', 2);
SELECT * FROM #CourseLab;
SELECT * FROM #EnrollmentLab;

2. ĐỌC THIẾT KẾ
Mỗi dòng CourseLab là một khóa. course_id xác định duy nhất dòng, NOT NULL cấm giá trị thiếu, CHECK cấm học phí âm. NVARCHAR cùng tiền tố N trước chuỗi giữ tiếng Việt. DECIMAL dùng độ chính xác thập phân thích hợp cho học phí. EnrollmentLab dùng khóa chính ghép, nên cùng học viên không có hai dòng cùng course_id.

Trong database thật, quan hệ giữa ghi danh và khóa được bảo vệ bằng FOREIGN KEY. Ví dụ bảng tạm này không khai báo khóa ngoại: SQL Server không thực thi FOREIGN KEY trên bảng tạm. Vì thế không dùng nó để kết luận khóa ngoại trong schema thật hoạt động thế nào.

3. THỰC HÀNH VÀ TỰ KIỂM TRA
Chạy từng phần và xác nhận mỗi bảng có 3 dòng. Thử INSERT khóa có price = -1; CHECK phải chặn. Thử chèn lại (N''An'', 1); khóa chính ghép phải chặn trùng. Sau mỗi lần thử, đọc lỗi trước khi chạy tiếp.

KHI HOÀN THÀNH
Bạn giải thích được dữ liệu hợp lệ không chỉ phụ thuộc form; database cũng có các ràng buộc để bảo vệ dữ liệu.'),
    (N'SQL Server thực hành: thiết kế bảng, truy vấn và giao dịch', 2, N'SELECT, WHERE và ORDER BY: lọc danh sách khóa học', N'MỤC TIÊU · 40 phút
Đọc được dữ liệu cần thiết thay vì lấy mọi cột, lọc bằng WHERE và sắp xếp ổn định bằng ORDER BY. Dùng dữ liệu bảng tạm của bài 1 trong cùng cửa sổ truy vấn.

1. TRUY VẤN CƠ BẢN

SELECT course_id, title, price
FROM #CourseLab
WHERE price = 0
ORDER BY course_id;

Kết quả có hai khóa: ID 1 Java nền tảng và ID 3 SQL Server. WHERE chọn dòng phù hợp; danh sách sau SELECT chọn cột hiển thị. Không có ORDER BY thì bạn không được giả định database trả về theo thứ tự thêm dữ liệu.

2. TÌM KIẾM VÀ PHÂN TRANG

DECLARE @keyword NVARCHAR(100) = N''Java'';
SELECT course_id, title
FROM #CourseLab
WHERE title LIKE N''%'' + @keyword + N''%''
ORDER BY course_id;

SELECT course_id, title, price
FROM #CourseLab
ORDER BY price DESC, course_id ASC
OFFSET 0 ROWS FETCH NEXT 2 ROWS ONLY;

Dấu % trong LIKE đại diện cho chuỗi ký tự bất kỳ. Trong truy vấn thứ hai, khóa học phí 199000 đứng trước, sau đó là khóa miễn phí có ID nhỏ hơn. Thêm course_id vào ORDER BY tạo cách phân xử khi nhiều khóa có cùng giá.

3. THỰC HÀNH
Đổi từ khóa thành SQL, rồi từ không tồn tại. Viết truy vấn lấy khóa có giá trong khoảng 0 đến 200000. Đổi OFFSET thành 2 để lấy trang tiếp theo. Khi đưa dữ liệu tìm kiếm từ người dùng vào ứng dụng, dùng tham số truy vấn hoặc JPA binding; không nối trực tiếp chuỗi người dùng vào câu SQL thực thi.

4. TỰ KIỂM TRA
Tìm SQL trả đúng khóa ID 3; từ không tồn tại trả 0 dòng. Trang đầu có ID 2 và 1, trang sau còn ID 3. So sánh giá trị NULL bằng IS NULL hoặc IS NOT NULL, không dùng = NULL. Chuỗi rỗng và NULL mang ý nghĩa khác nhau.

KHI HOÀN THÀNH
Bạn có bốn câu SELECT chạy được và dự đoán đúng kết quả. Thử giải thích tại sao tìm kiếm không có kết quả là trạng thái bình thường, không phải lỗi database.'),
    (N'SQL Server thực hành: thiết kế bảng, truy vấn và giao dịch', 3, N'JOIN và GROUP BY: thống kê số học viên theo khóa', N'MỤC TIÊU · 45 phút
Kết hợp thông tin khóa học với lượt ghi danh, đồng thời hiển thị khóa chưa có học viên. Chạy lại bài 1 nếu các bảng tạm không còn tồn tại trong kết nối.

1. GHÉP DÒNG BẰNG INNER JOIN

SELECT e.student_name, c.title
FROM #EnrollmentLab AS e
INNER JOIN #CourseLab AS c ON c.course_id = e.course_id
ORDER BY e.student_name, c.course_id;

Mỗi dòng ghi danh ghép với khóa có cùng course_id. Kết quả có 3 dòng: An học Java, An học Spring MVC, Bình học Java. Một khóa có nhiều lượt ghi danh sẽ xuất hiện ở nhiều dòng; đó là quan hệ một-nhiều, không phải database tự nhân dữ liệu sai.

2. GIỮ CẢ KHÓA CHƯA CÓ GHI DANH

SELECT c.course_id, c.title, COUNT(e.course_id) AS student_count
FROM #CourseLab AS c
LEFT JOIN #EnrollmentLab AS e ON e.course_id = c.course_id
GROUP BY c.course_id, c.title
ORDER BY c.course_id;

LEFT JOIN giữ mọi dòng của bảng bên trái. Với khóa SQL chưa ai ghi danh, các cột e là NULL. COUNT(e.course_id) bỏ qua NULL nên kết quả là 0. Nếu đổi thành COUNT(*), dòng khóa SQL vẫn được đếm thành 1, làm sai ý nghĩa số ghi danh.

3. THỰC HÀNH
Thêm dòng (N''Chi'', 3) vào #EnrollmentLab rồi chạy lại thống kê. Viết truy vấn chỉ lấy khóa có từ 2 học viên bằng HAVING COUNT(e.course_id) >= 2. Chạy lại truy vấn INNER JOIN và đếm xem tăng bao nhiêu dòng. Tránh đặt điều kiện trên e trong WHERE của LEFT JOIN nếu bạn vẫn muốn giữ khóa không có ghi danh; cân nhắc điều kiện cần nằm trong ON.

4. TỰ KIỂM TRA
Trước khi thêm Chi, số lượng theo ID 1, 2, 3 là 2, 1, 0. Sau khi thêm là 2, 1, 1. HAVING >= 2 chỉ giữ Java. WHERE lọc dòng trước khi gom nhóm; HAVING lọc nhóm sau khi tổng hợp.

KHI HOÀN THÀNH
Bạn giải thích được tại sao màn quản lý khóa học cần LEFT JOIN để không làm mất khóa vừa tạo chưa có học viên.'),
    (N'SQL Server thực hành: thiết kế bảng, truy vấn và giao dịch', 4, N'Transaction, rollback và kiểm tra cập nhật an toàn', N'MỤC TIÊU · 45 phút
Hiểu BEGIN TRANSACTION, COMMIT, ROLLBACK và kiểm tra phạm vi cập nhật bằng WHERE. Tiếp tục dùng #CourseLab, tuyệt đối không thay tên thành bảng thật khi làm bài tập này.

1. THỬ CẬP NHẬT RỒI HOÀN TÁC

SELECT course_id, title, price FROM #CourseLab WHERE course_id = 2;
BEGIN TRANSACTION;
    UPDATE #CourseLab SET price = 249000 WHERE course_id = 2;
    SELECT course_id, title, price FROM #CourseLab WHERE course_id = 2;
ROLLBACK TRANSACTION;
SELECT course_id, title, price FROM #CourseLab WHERE course_id = 2;

Ba lần đọc lần lượt cho học phí 199000, 249000 và 199000 nếu bạn chưa sửa dữ liệu trước đó. UPDATE đã chạy trong giao dịch, nhưng ROLLBACK hủy thay đổi. COMMIT mới chấp nhận giao dịch thành công.

2. BẮT LỖI VÀ HỦY TOÀN BỘ THAO TÁC

SET XACT_ABORT ON;
BEGIN TRY
    BEGIN TRANSACTION;
        UPDATE #CourseLab SET price = 249000 WHERE course_id = 2;
        UPDATE #CourseLab SET price = -1 WHERE course_id = 1;
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    SELECT ERROR_MESSAGE() AS error_message;
END CATCH;
SELECT course_id, price FROM #CourseLab ORDER BY course_id;

CHECK cấm giá âm gây lỗi. CATCH hủy giao dịch còn mở, vì vậy lần tăng giá đầu tiên cũng không được giữ lại. Nếu chỉ cập nhật từng dòng riêng lẻ ngoài giao dịch, thao tác trước có thể đã thành công trong khi thao tác sau thất bại.

3. THỰC HÀNH
Dự đoán học phí trước khi chạy mỗi truy vấn. Sau lỗi, chạy SELECT @@TRANCOUNT; giá trị phải bằng 0. Viết một giao dịch cập nhật khóa ID 2 về 199000 rồi COMMIT. Trước mọi UPDATE, chạy SELECT với cùng WHERE để xem chính xác các dòng bị tác động.

BÀI TỔNG KẾT KHÓA
Lưu file .sql gồm tạo bảng tạm, thêm mẫu, tìm kiếm, thống kê và giao dịch rollback. Mở kết nối mới rồi chạy lần lượt từ đầu. Nếu thống kê ra 2, 1, 0 trước khi thêm Chi và học phí không âm, bạn đã kiểm tra được cả truy vấn lẫn ràng buộc. Transaction trong SQL liên hệ trực tiếp với @Transactional trong khóa Spring MVC.');
    DECLARE @materialData TABLE (course_title NVARCHAR(255), lesson_order INT, order_index INT, title NVARCHAR(255), url NVARCHAR(2048), PRIMARY KEY (course_title, lesson_order, order_index));
    INSERT INTO @materialData VALUES
    (N'Java nền tảng: từ biến đến ứng dụng quản lý khóa học', 1, 1, N'Oracle — tài liệu JDK 17', N'https://docs.oracle.com/en/java/javase/17/'),
    (N'Java nền tảng: từ biến đến ứng dụng quản lý khóa học', 1, 2, N'Java — trung tâm học chính thức', N'https://dev.java/learn/'),
    (N'Java nền tảng: từ biến đến ứng dụng quản lý khóa học', 2, 1, N'Java — biến, toán tử và luồng điều khiển', N'https://dev.java/learn/language-basics/'),
    (N'Java nền tảng: từ biến đến ứng dụng quản lý khóa học', 3, 1, N'Java — lớp, đối tượng và constructor', N'https://dev.java/learn/oop/'),
    (N'Java nền tảng: từ biến đến ứng dụng quản lý khóa học', 4, 1, N'Oracle Java 17 — ArrayList API', N'https://docs.oracle.com/en/java/javase/17/docs/api/java.base/java/util/ArrayList.html'),
    (N'Java nền tảng: từ biến đến ứng dụng quản lý khóa học', 4, 2, N'Java — Collections Framework', N'https://dev.java/learn/api/collections-framework/'),
    (N'Spring MVC và JSP: hiểu luồng code qua EduSphere', 1, 1, N'Spring — phục vụ trang với Spring MVC (ví dụ dùng Thymeleaf)', N'https://spring.io/guides/gs/serving-web-content/'),
    (N'Spring MVC và JSP: hiểu luồng code qua EduSphere', 2, 1, N'Spring — xử lý gửi form (ví dụ dùng Thymeleaf)', N'https://spring.io/guides/gs/handling-form-submission/'),
    (N'Spring MVC và JSP: hiểu luồng code qua EduSphere', 3, 1, N'Spring — truy cập dữ liệu với JPA', N'https://spring.io/guides/gs/accessing-data-jpa/'),
    (N'Spring MVC và JSP: hiểu luồng code qua EduSphere', 4, 1, N'Spring — bảo vệ ứng dụng web', N'https://spring.io/guides/gs/securing-web/'),
    (N'SQL Server thực hành: thiết kế bảng, truy vấn và giao dịch', 1, 1, N'Microsoft Learn — CREATE TABLE', N'https://learn.microsoft.com/en-us/sql/t-sql/statements/create-table-transact-sql?view=sql-server-ver16'),
    (N'SQL Server thực hành: thiết kế bảng, truy vấn và giao dịch', 2, 1, N'Microsoft Learn — SELECT', N'https://learn.microsoft.com/en-us/sql/t-sql/queries/select-transact-sql?view=sql-server-ver16'),
    (N'SQL Server thực hành: thiết kế bảng, truy vấn và giao dịch', 3, 1, N'Microsoft Learn — JOIN trong SQL Server', N'https://learn.microsoft.com/en-us/sql/relational-databases/performance/joins?view=sql-server-ver16'),
    (N'SQL Server thực hành: thiết kế bảng, truy vấn và giao dịch', 4, 1, N'Microsoft Learn — giao dịch Transact-SQL', N'https://learn.microsoft.com/en-us/sql/t-sql/language-elements/transactions-transact-sql?view=sql-server-ver16');
    IF EXISTS (SELECT 1 FROM @courseData d WHERE NOT EXISTS (
        SELECT 1 FROM dbo.categories c WHERE c.name = d.category_name AND c.parent_category_id IS NULL AND c.status = N'ACTIVE'))
        THROW 51012, 'Required active course categories are missing.', 1;

    DECLARE @newCourses TABLE (course_id INT PRIMARY KEY, title NVARCHAR(255));
    INSERT INTO dbo.courses (title, description, category_id, instructor_id, level, price, currency,
        status, version_no, created_at, updated_at, submitted_at, approved_at, published_at)
    OUTPUT inserted.course_id, inserted.title INTO @newCourses
    SELECT d.title, d.description, cat.category_id, @instructor_id, d.level, 0, 'VND',
        N'PUBLISHED', 1, @now, @now, @now, @now, @now
    FROM @courseData d JOIN dbo.categories cat ON cat.name = d.category_name
        AND cat.parent_category_id IS NULL AND cat.status = N'ACTIVE'
    WHERE NOT EXISTS (SELECT 1 FROM dbo.courses c WHERE c.title = d.title AND c.instructor_id = @instructor_id);

    INSERT INTO dbo.course_reviews (course_id, course_version, admin_id, decision, comment, reviewed_at)
    SELECT course_id, 1, @admin_id, N'APPROVED', N'Nội dung tự học được cài đặt sẵn theo yêu cầu của nhóm; tài liệu nguồn chính thức nằm ở từng bài.', @now
    FROM @newCourses;

    INSERT INTO dbo.lessons (course_id, title, content, order_index, status, created_at)
    SELECT c.course_id, l.title, l.content, l.order_index, N'PUBLISHED', @now
    FROM @lessonData l JOIN @newCourses c ON c.title = l.course_title;

    INSERT INTO dbo.materials (lesson_id, title, type, file_url, order_index, uploaded_by, uploaded_at)
    SELECT l.lesson_id, m.title, N'LINK', m.url, m.order_index, @instructor_id, @now
    FROM @materialData m JOIN @newCourses c ON c.title = m.course_title
    JOIN dbo.lessons l ON l.course_id = c.course_id AND l.order_index = m.lesson_order;

    INSERT INTO dbo.enrollments (student_id, course_id, enrolled_at, status)
    SELECT @student_id, c.course_id, @now, N'ACTIVE'
    FROM dbo.courses c JOIN @courseData d ON d.title = c.title
    WHERE @student_id IS NOT NULL AND c.instructor_id = @instructor_id AND c.status = N'PUBLISHED'
        AND NOT EXISTS (SELECT 1 FROM dbo.enrollments e WHERE e.student_id = @student_id AND e.course_id = c.course_id);

    COMMIT TRANSACTION;
    SELECT c.course_id, c.title, c.status,
        (SELECT COUNT(*) FROM dbo.lessons l WHERE l.course_id = c.course_id) AS lesson_count,
        (SELECT COUNT(*) FROM dbo.materials m JOIN dbo.lessons l ON l.lesson_id = m.lesson_id WHERE l.course_id = c.course_id) AS resource_count
    FROM dbo.courses c JOIN @courseData d ON d.title = c.title
    WHERE c.instructor_id = @instructor_id ORDER BY c.course_id;
    SELECT COUNT(*) AS inserted_courses_this_run FROM @newCourses;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;
