package com.edusphere.dto.planning;

import lombok.Getter;

import java.time.LocalDate;
import java.util.List;

@Getter
public class CalendarDayView {

    private final LocalDate date;
    private final String dayOfWeekName;
    private final boolean isToday;
    private final List<PersonalTaskView> tasks;

    public CalendarDayView(LocalDate date, String dayOfWeekName, boolean isToday, List<PersonalTaskView> tasks) {
        this.date = date;
        this.dayOfWeekName = dayOfWeekName;
        this.isToday = isToday;
        this.tasks = tasks;
    }
}

