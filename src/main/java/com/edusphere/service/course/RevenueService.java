package com.edusphere.service.course;

import com.edusphere.entity.account.Users;
import com.edusphere.entity.course.Course;
import com.edusphere.entity.course.Payment;
import com.edusphere.entity.course.PayoutRequest;
import com.edusphere.repository.account.UserRepository;
import com.edusphere.repository.course.CourseRepository;
import com.edusphere.repository.course.PaymentRepository;
import com.edusphere.repository.course.PayoutRequestRepository;
import lombok.Getter;
import lombok.Setter;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;

@Service
public class RevenueService {

    public static final int INSTRUCTOR_SHARE_PERCENT = 80;
    public static final int PLATFORM_FEE_PERCENT     = 20;

    private static final BigDecimal PLATFORM_RATE   = new BigDecimal("0.20");
    private static final BigDecimal MIN_PAYOUT_VND  = new BigDecimal("50000");
    private static final DateTimeFormatter DT_FMT   = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");

    private final PaymentRepository paymentRepository;
    private final PayoutRequestRepository payoutRequestRepository;
    private final CourseRepository courseRepository;
    private final UserRepository userRepository;

    public RevenueService(PaymentRepository paymentRepository,
                          PayoutRequestRepository payoutRequestRepository,
                          CourseRepository courseRepository,
                          UserRepository userRepository) {
        this.paymentRepository = paymentRepository;
        this.payoutRequestRepository = payoutRequestRepository;
        this.courseRepository = courseRepository;
        this.userRepository = userRepository;
    }

    public static BigDecimal calculatePlatformFee(BigDecimal gross) {
        if (gross == null || gross.signum() <= 0) {
            return BigDecimal.ZERO;
        }
        return gross.multiply(PLATFORM_RATE).setScale(0, RoundingMode.HALF_UP);
    }

    public static BigDecimal calculateNetEarnings(BigDecimal gross) {
        if (gross == null || gross.signum() <= 0) {
            return BigDecimal.ZERO;
        }
        return gross.subtract(calculatePlatformFee(gross));
    }

    @Transactional(readOnly = true)
    public InstructorRevenueDashboard getInstructorRevenue(Integer instructorId, Integer filterCourseId) {
        List<Course> instructorCourses = courseRepository.findByInstructor_UserIdOrderByCreatedAtDesc(instructorId);
        List<Payment> allPayments = paymentRepository.findByInstructorIdOrderByDateDesc(instructorId);
        List<PayoutRequest> payouts = payoutRequestRepository.findByInstructorIdOrderByRequestedAtDesc(instructorId);

        BigDecimal totalGross = BigDecimal.ZERO;
        BigDecimal totalPlatformFee = BigDecimal.ZERO;
        BigDecimal totalNet = BigDecimal.ZERO;
        int succeededCount = 0;

        Map<Integer, CourseRevenueRow> courseMap = new LinkedHashMap<>();
        for (Course c : instructorCourses) {
            CourseRevenueRow row = new CourseRevenueRow();
            row.setCourseId(c.getCourseId());
            row.setCourseTitle(c.getTitle());
            row.setCoursePrice(c.getPrice() != null ? c.getPrice() : BigDecimal.ZERO);
            row.setCourseStatus(c.getStatus());
            row.setInstructorName(c.getInstructor() != null ? c.getInstructor().getFullName() : "");
            courseMap.put(c.getCourseId(), row);
        }

        List<SaleTransactionRow> transactionRows = new ArrayList<>();
        for (Payment p : allPayments) {
            BigDecimal amount = p.getAmount() != null ? p.getAmount() : BigDecimal.ZERO;
            BigDecimal fee = calculatePlatformFee(amount);
            BigDecimal net = amount.subtract(fee);

            if ("SUCCEEDED".equalsIgnoreCase(p.getStatus())) {
                totalGross = totalGross.add(amount);
                totalPlatformFee = totalPlatformFee.add(fee);
                totalNet = totalNet.add(net);
                succeededCount++;

                CourseRevenueRow cRow = courseMap.get(p.getCourse().getCourseId());
                if (cRow != null) {
                    cRow.setSoldCount(cRow.getSoldCount() + 1);
                    cRow.setGrossAmount(cRow.getGrossAmount().add(amount));
                    cRow.setPlatformFee(cRow.getPlatformFee().add(fee));
                    cRow.setNetAmount(cRow.getNetAmount().add(net));
                }
            }

            if (filterCourseId == null || Objects.equals(p.getCourse().getCourseId(), filterCourseId)) {
                SaleTransactionRow tx = toTransactionRow(p, amount, fee, net);
                transactionRows.add(tx);
            }
        }

        BigDecimal withdrawnAmount = BigDecimal.ZERO;
        BigDecimal pendingPayoutAmount = BigDecimal.ZERO;
        List<PayoutRow> payoutRows = new ArrayList<>();
        for (PayoutRequest pr : payouts) {
            BigDecimal amt = pr.getAmount() != null ? pr.getAmount() : BigDecimal.ZERO;
            if ("APPROVED".equalsIgnoreCase(pr.getStatus())) {
                withdrawnAmount = withdrawnAmount.add(amt);
            } else if ("PENDING".equalsIgnoreCase(pr.getStatus())) {
                pendingPayoutAmount = pendingPayoutAmount.add(amt);
            }
            payoutRows.add(toPayoutRow(pr));
        }

        BigDecimal availableBalance = totalNet.subtract(withdrawnAmount).subtract(pendingPayoutAmount);
        if (availableBalance.signum() < 0) {
            availableBalance = BigDecimal.ZERO;
        }

        InstructorRevenueDashboard dash = new InstructorRevenueDashboard();
        dash.setInstructorSharePercent(INSTRUCTOR_SHARE_PERCENT);
        dash.setPlatformFeePercent(PLATFORM_FEE_PERCENT);
        dash.setGrossRevenue(totalGross);
        dash.setPlatformFee(totalPlatformFee);
        dash.setNetEarnings(totalNet);
        dash.setWithdrawnAmount(withdrawnAmount);
        dash.setPendingPayoutAmount(pendingPayoutAmount);
        dash.setAvailableBalance(availableBalance);
        dash.setPaidOrdersCount(succeededCount);
        dash.setFilterCourseId(filterCourseId);
        dash.setCourseRevenues(new ArrayList<>(courseMap.values()));
        dash.setTransactions(transactionRows);
        dash.setPayoutRequests(payoutRows);
        return dash;
    }

    @Transactional
    public PayoutRequest requestPayout(Integer instructorId,
                                       BigDecimal amount,
                                       String bankName,
                                       String accountNumber,
                                       String accountHolder,
                                       String instructorNote) {
        Users instructor = userRepository.findById(instructorId)
                .orElseThrow(() -> new CourseActionException(HttpStatus.NOT_FOUND, "Không tìm thấy tài khoản giảng viên."));

        if (amount == null || amount.compareTo(MIN_PAYOUT_VND) < 0) {
            throw new CourseActionException(HttpStatus.BAD_REQUEST,
                    "Số tiền rút tối thiểu là 50,000đ.");
        }
        if (bankName == null || bankName.isBlank()) {
            throw new CourseActionException(HttpStatus.BAD_REQUEST, "Vui lòng nhập tên ngân hàng.");
        }
        if (accountNumber == null || accountNumber.isBlank()) {
            throw new CourseActionException(HttpStatus.BAD_REQUEST, "Vui lòng nhập số tài khoản nhận tiền.");
        }
        if (accountHolder == null || accountHolder.isBlank()) {
            throw new CourseActionException(HttpStatus.BAD_REQUEST, "Vui lòng nhập tên chủ tài khoản.");
        }

        InstructorRevenueDashboard current = getInstructorRevenue(instructorId, null);
        if (amount.compareTo(current.getAvailableBalance()) > 0) {
            throw new CourseActionException(HttpStatus.CONFLICT,
                    "Số tiền yêu cầu rút vượt quá số dư khả dụng hiện tại ("
                            + current.getAvailableBalance().setScale(0, RoundingMode.HALF_UP).toPlainString() + "đ).");
        }

        PayoutRequest pr = new PayoutRequest();
        pr.setInstructor(instructor);
        pr.setAmount(amount.setScale(2, RoundingMode.HALF_UP));
        pr.setBankName(bankName.trim());
        pr.setAccountNumber(accountNumber.trim());
        pr.setAccountHolder(accountHolder.trim().toUpperCase());
        pr.setInstructorNote(instructorNote != null && !instructorNote.isBlank() ? instructorNote.trim() : null);
        pr.setStatus("PENDING");
        pr.setRequestedAt(LocalDateTime.now());
        return payoutRequestRepository.save(pr);
    }

    @Transactional(readOnly = true)
    public AdminRevenueDashboard getAdminRevenue() {
        List<Payment> allPayments = paymentRepository.findAllWithDetailsOrderByDateDesc();
        List<PayoutRequest> allPayouts = payoutRequestRepository.findAllWithInstructorOrderByPendingFirst();

        BigDecimal totalGross = BigDecimal.ZERO;
        BigDecimal totalPlatformFee = BigDecimal.ZERO;
        BigDecimal totalInstructorNet = BigDecimal.ZERO;
        int succeededCount = 0;

        Map<Integer, CourseRevenueRow> courseMap = new LinkedHashMap<>();
        List<SaleTransactionRow> txRows = new ArrayList<>();

        for (Payment p : allPayments) {
            BigDecimal amount = p.getAmount() != null ? p.getAmount() : BigDecimal.ZERO;
            BigDecimal fee = calculatePlatformFee(amount);
            BigDecimal net = amount.subtract(fee);

            if ("SUCCEEDED".equalsIgnoreCase(p.getStatus())) {
                totalGross = totalGross.add(amount);
                totalPlatformFee = totalPlatformFee.add(fee);
                totalInstructorNet = totalInstructorNet.add(net);
                succeededCount++;

                Course c = p.getCourse();
                CourseRevenueRow cRow = courseMap.computeIfAbsent(c.getCourseId(), id -> {
                    CourseRevenueRow r = new CourseRevenueRow();
                    r.setCourseId(c.getCourseId());
                    r.setCourseTitle(c.getTitle());
                    r.setCoursePrice(c.getPrice() != null ? c.getPrice() : BigDecimal.ZERO);
                    r.setCourseStatus(c.getStatus());
                    r.setInstructorName(c.getInstructor() != null ? c.getInstructor().getFullName() : "");
                    return r;
                });
                cRow.setSoldCount(cRow.getSoldCount() + 1);
                cRow.setGrossAmount(cRow.getGrossAmount().add(amount));
                cRow.setPlatformFee(cRow.getPlatformFee().add(fee));
                cRow.setNetAmount(cRow.getNetAmount().add(net));
            }

            txRows.add(toTransactionRow(p, amount, fee, net));
        }

        BigDecimal totalPaidOut = BigDecimal.ZERO;
        BigDecimal totalPendingPayout = BigDecimal.ZERO;
        int pendingCount = 0;
        List<PayoutRow> payoutRows = new ArrayList<>();

        for (PayoutRequest pr : allPayouts) {
            BigDecimal amt = pr.getAmount() != null ? pr.getAmount() : BigDecimal.ZERO;
            if ("APPROVED".equalsIgnoreCase(pr.getStatus())) {
                totalPaidOut = totalPaidOut.add(amt);
            } else if ("PENDING".equalsIgnoreCase(pr.getStatus())) {
                totalPendingPayout = totalPendingPayout.add(amt);
                pendingCount++;
            }
            payoutRows.add(toPayoutRow(pr));
        }

        AdminRevenueDashboard dash = new AdminRevenueDashboard();
        dash.setInstructorSharePercent(INSTRUCTOR_SHARE_PERCENT);
        dash.setPlatformFeePercent(PLATFORM_FEE_PERCENT);
        dash.setGrossRevenue(totalGross);
        dash.setPlatformFeeEarned(totalPlatformFee);
        dash.setInstructorNetTotal(totalInstructorNet);
        dash.setTotalPaidOut(totalPaidOut);
        dash.setTotalPendingPayout(totalPendingPayout);
        dash.setPendingPayoutCount(pendingCount);
        dash.setPaidOrdersCount(succeededCount);
        dash.setCourseRevenues(new ArrayList<>(courseMap.values()));
        dash.setTransactions(txRows);
        dash.setPayoutRequests(payoutRows);
        return dash;
    }

    @Transactional
    public void approvePayout(Integer payoutId, Integer adminUserId, String adminNote) {
        PayoutRequest pr = payoutRequestRepository.findByIdWithDetails(payoutId)
                .orElseThrow(() -> new CourseActionException(HttpStatus.NOT_FOUND, "Không tìm thấy yêu cầu rút tiền."));
        if (!"PENDING".equalsIgnoreCase(pr.getStatus())) {
            throw new CourseActionException(HttpStatus.CONFLICT, "Yêu cầu rút tiền này đã được xử lý trước đó.");
        }
        Users admin = userRepository.findById(adminUserId).orElse(null);
        pr.setStatus("APPROVED");
        pr.setProcessedBy(admin);
        pr.setProcessedAt(LocalDateTime.now());
        pr.setAdminNote(adminNote != null && !adminNote.isBlank() ? adminNote.trim() : "Đã xác nhận chuyển khoản cho giảng viên.");
        payoutRequestRepository.save(pr);
    }

    @Transactional
    public void rejectPayout(Integer payoutId, Integer adminUserId, String adminNote) {
        PayoutRequest pr = payoutRequestRepository.findByIdWithDetails(payoutId)
                .orElseThrow(() -> new CourseActionException(HttpStatus.NOT_FOUND, "Không tìm thấy yêu cầu rút tiền."));
        if (!"PENDING".equalsIgnoreCase(pr.getStatus())) {
            throw new CourseActionException(HttpStatus.CONFLICT, "Yêu cầu rút tiền này đã được xử lý trước đó.");
        }
        if (adminNote == null || adminNote.isBlank()) {
            throw new CourseActionException(HttpStatus.BAD_REQUEST, "Vui lòng nhập lý do từ chối yêu cầu rút tiền.");
        }
        Users admin = userRepository.findById(adminUserId).orElse(null);
        pr.setStatus("REJECTED");
        pr.setProcessedBy(admin);
        pr.setProcessedAt(LocalDateTime.now());
        pr.setAdminNote(adminNote.trim());
        payoutRequestRepository.save(pr);
    }

    private SaleTransactionRow toTransactionRow(Payment p, BigDecimal amount, BigDecimal fee, BigDecimal net) {
        SaleTransactionRow row = new SaleTransactionRow();
        row.setPaymentId(p.getPaymentId());
        row.setRequestKey(p.getRequestKey());
        row.setProviderTransactionId(p.getProviderTransactionId());
        row.setStudentName(p.getStudent() != null ? p.getStudent().getFullName() : "");
        row.setStudentEmail(p.getStudent() != null ? p.getStudent().getEmail() : "");
        row.setCourseId(p.getCourse() != null ? p.getCourse().getCourseId() : null);
        row.setCourseTitle(p.getCourse() != null ? p.getCourse().getTitle() : "");
        row.setInstructorName(p.getCourse() != null && p.getCourse().getInstructor() != null
                ? p.getCourse().getInstructor().getFullName() : "");
        row.setGrossAmount(amount);
        row.setPlatformFee(fee);
        row.setNetAmount(net);
        row.setStatus(p.getStatus());
        LocalDateTime dt = p.getCompletedAt() != null ? p.getCompletedAt() : p.getCreatedAt();
        row.setTransactionDate(dt != null ? dt.format(DT_FMT) : "");
        return row;
    }

    private PayoutRow toPayoutRow(PayoutRequest pr) {
        PayoutRow row = new PayoutRow();
        row.setPayoutId(pr.getPayoutId());
        row.setInstructorId(pr.getInstructor() != null ? pr.getInstructor().getUserId() : null);
        row.setInstructorName(pr.getInstructor() != null ? pr.getInstructor().getFullName() : "");
        row.setInstructorEmail(pr.getInstructor() != null ? pr.getInstructor().getEmail() : "");
        row.setAmount(pr.getAmount() != null ? pr.getAmount() : BigDecimal.ZERO);
        row.setBankName(pr.getBankName());
        row.setAccountNumber(pr.getAccountNumber());
        row.setAccountHolder(pr.getAccountHolder());
        row.setInstructorNote(pr.getInstructorNote());
        row.setStatus(pr.getStatus());
        row.setAdminNote(pr.getAdminNote());
        row.setProcessedByName(pr.getProcessedBy() != null ? pr.getProcessedBy().getFullName() : null);
        row.setRequestedAt(pr.getRequestedAt() != null ? pr.getRequestedAt().format(DT_FMT) : "");
        row.setProcessedAt(pr.getProcessedAt() != null ? pr.getProcessedAt().format(DT_FMT) : null);
        return row;
    }

    @Getter
    @Setter
    public static class InstructorRevenueDashboard {
        private int instructorSharePercent;
        private int platformFeePercent;
        private BigDecimal grossRevenue = BigDecimal.ZERO;
        private BigDecimal platformFee = BigDecimal.ZERO;
        private BigDecimal netEarnings = BigDecimal.ZERO;
        private BigDecimal withdrawnAmount = BigDecimal.ZERO;
        private BigDecimal pendingPayoutAmount = BigDecimal.ZERO;
        private BigDecimal availableBalance = BigDecimal.ZERO;
        private int paidOrdersCount;
        private Integer filterCourseId;
        private List<CourseRevenueRow> courseRevenues = List.of();
        private List<SaleTransactionRow> transactions = List.of();
        private List<PayoutRow> payoutRequests = List.of();
    }

    @Getter
    @Setter
    public static class AdminRevenueDashboard {
        private int instructorSharePercent;
        private int platformFeePercent;
        private BigDecimal grossRevenue = BigDecimal.ZERO;
        private BigDecimal platformFeeEarned = BigDecimal.ZERO;
        private BigDecimal instructorNetTotal = BigDecimal.ZERO;
        private BigDecimal totalPaidOut = BigDecimal.ZERO;
        private BigDecimal totalPendingPayout = BigDecimal.ZERO;
        private int pendingPayoutCount;
        private int paidOrdersCount;
        private List<CourseRevenueRow> courseRevenues = List.of();
        private List<SaleTransactionRow> transactions = List.of();
        private List<PayoutRow> payoutRequests = List.of();
    }

    @Getter
    @Setter
    public static class CourseRevenueRow {
        private Integer courseId;
        private String courseTitle;
        private String instructorName;
        private BigDecimal coursePrice = BigDecimal.ZERO;
        private String courseStatus;
        private int soldCount;
        private BigDecimal grossAmount = BigDecimal.ZERO;
        private BigDecimal platformFee = BigDecimal.ZERO;
        private BigDecimal netAmount = BigDecimal.ZERO;
    }

    @Getter
    @Setter
    public static class SaleTransactionRow {
        private Integer paymentId;
        private String requestKey;
        private String providerTransactionId;
        private String studentName;
        private String studentEmail;
        private Integer courseId;
        private String courseTitle;
        private String instructorName;
        private BigDecimal grossAmount = BigDecimal.ZERO;
        private BigDecimal platformFee = BigDecimal.ZERO;
        private BigDecimal netAmount = BigDecimal.ZERO;
        private String status;
        private String transactionDate;
    }

    @Getter
    @Setter
    public static class PayoutRow {
        private Integer payoutId;
        private Integer instructorId;
        private String instructorName;
        private String instructorEmail;
        private BigDecimal amount = BigDecimal.ZERO;
        private String bankName;
        private String accountNumber;
        private String accountHolder;
        private String instructorNote;
        private String status;
        private String adminNote;
        private String processedByName;
        private String requestedAt;
        private String processedAt;
    }
}
