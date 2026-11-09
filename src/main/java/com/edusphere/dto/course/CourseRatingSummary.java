package com.edusphere.dto.course;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@AllArgsConstructor
public class CourseRatingSummary {
    private double averageRating;
    private long ratingCount;
    private long totalComments;
    private int fiveStarCount;
    private int fourStarCount;
    private int threeStarCount;
    private int twoStarCount;
    private int oneStarCount;

    public int starPercent(int star) {
        if (ratingCount <= 0) {
            return star == 5 ? 100 : 0;
        }
        int cnt = switch (star) {
            case 5 -> fiveStarCount;
            case 4 -> fourStarCount;
            case 3 -> threeStarCount;
            case 2 -> twoStarCount;
            case 1 -> oneStarCount;
            default -> 0;
        };
        return (int) Math.round((cnt * 100.0) / ratingCount);
    }
}
