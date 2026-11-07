package com.edusphere.service.course;

import org.junit.jupiter.api.Test;
import java.util.List;
import static org.junit.jupiter.api.Assertions.*;

public class VideoWatchIntervalTest {

    @Test
    void testSpecificationWorkflow() {
        // Ví dụ video dài 100 giây theo đúng yêu cầu đề bài:
        // - Xem từ 0 đến 20 giây: tiến độ 20%.
        // - Xem lại từ 10 đến 20 giây: vẫn 20%.
        // - Xem tiếp từ 20 đến 40 giây: tiến độ 40%.
        // - Xem tiếp từ 40 đến 60 giây: tiến độ 60%.
        // - Xem tiếp từ 60 đến 80 giây: tiến độ 80%.
        int totalDuration = 100;
        List<int[]> intervals = List.of();

        // Bước 1: Xem từ 0 đến 20 giây
        intervals = LearningService.mergeIntervals(intervals, 0, 20);
        int watched1 = LearningService.calculateTotalWatchedSeconds(intervals);
        int pct1 = Math.round((watched1 * 100.0f) / totalDuration);
        assertEquals(20, watched1);
        assertEquals(20, pct1, "Xem từ 0 đến 20 giây: tiến độ phải là 20%");

        // Bước 2: Xem lại từ 10 đến 20 giây -> không được tính trùng, vẫn 20%
        intervals = LearningService.mergeIntervals(intervals, 10, 20);
        int watched2 = LearningService.calculateTotalWatchedSeconds(intervals);
        int pct2 = Math.round((watched2 * 100.0f) / totalDuration);
        assertEquals(20, watched2, "Thời gian xem không được tăng khi xem lại đoạn 10-20");
        assertEquals(20, pct2, "Tiến độ vẫn phải là 20% khi xem lại");

        // Bước 3: Xem tiếp từ 20 đến 40 giây
        intervals = LearningService.mergeIntervals(intervals, 20, 40);
        int watched3 = LearningService.calculateTotalWatchedSeconds(intervals);
        int pct3 = Math.round((watched3 * 100.0f) / totalDuration);
        assertEquals(40, watched3);
        assertEquals(40, pct3, "Xem tiếp từ 20 đến 40 giây: tiến độ phải là 40%");

        // Bước 4: Xem tiếp từ 40 đến 60 giây
        intervals = LearningService.mergeIntervals(intervals, 40, 60);
        int watched4 = LearningService.calculateTotalWatchedSeconds(intervals);
        int pct4 = Math.round((watched4 * 100.0f) / totalDuration);
        assertEquals(60, watched4);
        assertEquals(60, pct4, "Xem tiếp từ 40 đến 60 giây: tiến độ phải là 60%");

        // Bước 5: Xem tiếp từ 60 đến 80 giây -> đạt 80% mở khóa Quiz!
        intervals = LearningService.mergeIntervals(intervals, 60, 80);
        int watched5 = LearningService.calculateTotalWatchedSeconds(intervals);
        int pct5 = Math.round((watched5 * 100.0f) / totalDuration);
        assertEquals(80, watched5);
        assertEquals(80, pct5, "Xem tiếp từ 60 đến 80 giây: tiến độ phải là 80%");
        assertTrue(pct5 >= 80, "Khi đạt 80% phải đủ điều kiện mở khóa Quiz!");
    }

    @Test
    void testDisjointIntervalsAndGapBridging() {
        // Kiểm tra xem các khoảng rời rạc và nối khoảng với dung sai 1s
        List<int[]> intervals = List.of();
        intervals = LearningService.mergeIntervals(intervals, 0, 5);
        intervals = LearningService.mergeIntervals(intervals, 6, 10); // khoảng nối chạm với dung sai 1s
        assertEquals(1, intervals.size());
        assertEquals(0, intervals.get(0)[0]);
        assertEquals(10, intervals.get(0)[1]);
        assertEquals(10, LearningService.calculateTotalWatchedSeconds(intervals));

        // Đoạn nhảy xa (ví dụ tua hoặc khoảng cách 10s)
        intervals = LearningService.mergeIntervals(intervals, 20, 25);
        assertEquals(2, intervals.size());
        assertEquals(15, LearningService.calculateTotalWatchedSeconds(intervals));
    }

    @Test
    void testJsonParseAndSerialization() {
        String json = "[[0,20],[25,45],[60,80]]";
        List<int[]> list = LearningService.parseIntervals(json);
        assertEquals(3, list.size());
        assertArrayEquals(new int[]{0, 20}, list.get(0));
        assertArrayEquals(new int[]{25, 45}, list.get(1));
        assertArrayEquals(new int[]{60, 80}, list.get(2));

        String serialized = LearningService.intervalsToJson(list);
        assertEquals("[[0,20],[25,45],[60,80]]", serialized);
    }
}

