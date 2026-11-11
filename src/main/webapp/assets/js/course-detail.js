/**
 * EduSphere - Course Detail Page Interaction Engine
 * Handles Tab Switching, Accordion Toggles, Review Star Rating Picker, and Comment Replies.
 */
document.addEventListener('DOMContentLoaded', function () {
    initTabs();
    initStarPicker();
    initAccordion();
    initReplyBoxes();
});

/**
 * 1. Tab Switching (Giới thiệu, Chương trình học, Đánh giá, Hỏi đáp)
 * Supports URL hash navigation (e.g., #course-reviews -> switches to reviews tab).
 */
function initTabs() {
    const tabButtons = document.querySelectorAll('.cd-tab-btn');
    const tabPanels = document.querySelectorAll('.cd-tab-panel');

    if (!tabButtons.length || !tabPanels.length) return;

    function switchTab(targetTabId) {
        let matched = false;
        tabButtons.forEach(btn => {
            const isTarget = btn.getAttribute('data-tab') === targetTabId;
            btn.classList.toggle('active', isTarget);
            btn.setAttribute('aria-selected', isTarget ? 'true' : 'false');
            if (isTarget) matched = true;
        });

        tabPanels.forEach(panel => {
            const isTarget = panel.getAttribute('data-tab-content') === targetTabId;
            panel.classList.toggle('active', isTarget);
        });

        // If not matched, default to first tab (about)
        if (!matched && tabButtons[0]) {
            tabButtons[0].classList.add('active');
            tabButtons[0].setAttribute('aria-selected', 'true');
            if (tabPanels[0]) tabPanels[0].classList.add('active');
        }
    }

    tabButtons.forEach(btn => {
        btn.addEventListener('click', function () {
            const tabId = this.getAttribute('data-tab');
            switchTab(tabId);
        });
    });

    // Check URL Hash on load
    const hash = window.location.hash;
    if (hash === '#course-reviews' || hash === '#reviews' || hash === '#ratings') {
        switchTab('reviews');
    } else if (hash === '#curriculum' || hash === '#lessons') {
        switchTab('curriculum');
    } else if (hash === '#qa' || hash === '#comments-section' || hash === '#comments') {
        switchTab('qa');
    } else {
        switchTab('about');
    }
}

/**
 * 2. Star Rating Picker for Review Form
 */
function initStarPicker() {
    const picker = document.querySelector('.cd-star-picker');
    if (!picker) return;

    const starBtns = picker.querySelectorAll('.cd-star-btn');
    const hiddenInput = document.querySelector('input[name="rating"]');
    const starLabel = picker.querySelector('.cd-star-label');

    const labels = {
        1: '1 sao - Rất tệ',
        2: '2 sao - Chưa hài lòng',
        3: '3 sao - Bình thường',
        4: '4 sao - Tốt & hữu ích',
        5: '5 sao - Tuyệt vời!'
    };

    function highlightStars(rating) {
        starBtns.forEach(btn => {
            const val = parseInt(btn.getAttribute('data-star'), 10);
            if (val <= rating) {
                btn.classList.add('active');
            } else {
                btn.classList.remove('active');
            }
        });
        if (starLabel && labels[rating]) {
            starLabel.textContent = labels[rating];
        }
    }

    let currentVal = hiddenInput && hiddenInput.value ? parseInt(hiddenInput.value, 10) : 5;
    highlightStars(currentVal);

    starBtns.forEach(btn => {
        btn.addEventListener('mouseenter', function () {
            const val = parseInt(this.getAttribute('data-star'), 10);
            highlightStars(val);
        });

        btn.addEventListener('click', function (e) {
            e.preventDefault();
            const val = parseInt(this.getAttribute('data-star'), 10);
            currentVal = val;
            if (hiddenInput) hiddenInput.value = val;
            highlightStars(val);
        });
    });

    picker.addEventListener('mouseleave', function () {
        highlightStars(currentVal);
    });
}

/**
 * 3. Accordion for Curriculum Sections
 */
function initAccordion() {
    const sectionHeaders = document.querySelectorAll('.cd-curriculum-sec-header');
    sectionHeaders.forEach(header => {
        header.addEventListener('click', function () {
            const parent = this.closest('.cd-curriculum-sec');
            if (parent) {
                parent.classList.toggle('open');
            }
        });
    });
}

/**
 * 4. Reply box toggle for discussion/comments
 */
function initReplyBoxes() {
    document.querySelectorAll('.vj-reply-toggle-btn').forEach(btn => {
        btn.addEventListener('click', function () {
            const targetId = this.getAttribute('data-reply-target');
            if (!targetId) return;
            const box = document.getElementById(targetId);
            if (box) {
                box.classList.toggle('open');
                if (box.classList.contains('open')) {
                    const textarea = box.querySelector('textarea');
                    if (textarea) textarea.focus();
                }
            }
        });
    });
}

