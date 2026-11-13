package com.edusphere.service.course;

import com.edusphere.dto.course.StudentDashboardView;
import com.edusphere.entity.course.Lesson;
import com.edusphere.repository.course.LessonRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

@Service
public class StudentDashboardService {


    private final LessonRepository lessonRepository;

        this.lessonRepository = lessonRepository;
    }

    @Transactional(readOnly = true)

        Map<Integer, Long> secondsByCourse = new HashMap<>();
        }

            }
        }



            }
        }
        }

        LocalDate today = LocalDate.now();

        } else {
        }

    }

            }
        }
    }

        List<String> labels = new ArrayList<>();
        List<Double> values = new ArrayList<>();
        }
    }

        List<String> labels = new ArrayList<>();
        List<Double> values = new ArrayList<>();
            }
    }

        }
            }
        }
    }

        return switch (dow) {
            case MONDAY -> "Thứ 2";
            case TUESDAY -> "Thứ 3";
            case WEDNESDAY -> "Thứ 4";
            case THURSDAY -> "Thứ 5";
            case FRIDAY -> "Thứ 6";
            case SATURDAY -> "Thứ 7";
            case SUNDAY -> "CN";
        };
    }

        }
    }

        }
    }

    }

    }
}
