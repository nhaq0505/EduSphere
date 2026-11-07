/**
 * EDUSPHERE STUDY PAGE — CLIENT ENGINE
 * File: assets/js/study.js
 *
 * Chức năng:
 * - Điều khiển giao diện Accordion danh sách Chương & Tab bài học.
 * - Trình phát video đa nguồn (Bunny Stream, YouTube, HTML5 video).
 * - Chống tua vượt đoạn chưa xem (Anti-seeking).
 * - Theo dõi tiến độ xem thực tế và gửi ping định kỳ về backend.
 * - Mở khóa bài kiểm tra (Quiz) theo thời gian thực khi đạt >= 80%.
 */

// ── 1. GIAO DIỆN: Accordion chương & Tab bài học ──

function toggleChapter(headEl) {
    if (!headEl) return;
    var accordion = headEl.parentElement;
    if (!accordion) return;
    var isOpen = accordion.classList.contains('open');
    var arrow = headEl.querySelector('.chapter-head-arrow');
    if (isOpen) {
        accordion.classList.remove('open');
        if (arrow) arrow.textContent = '▼';
    } else {
        accordion.classList.add('open');
        if (arrow) arrow.textContent = '▲';
    }
}

function switchTab(name) {
    document.querySelectorAll('.lesson-tab').forEach(function(t) { t.classList.remove('active'); });
    document.querySelectorAll('.tab-panel').forEach(function(p) { p.classList.remove('active'); });
    var btn = document.getElementById('tab-' + name);
    var panel = document.getElementById('panel-' + name);
    if (btn) btn.classList.add('active');
    if (panel) panel.classList.add('active');
}

// ── 2. TOAST THÔNG BÁO CHỐNG TUA & KHÓA QUIZ ──

function showSeekWarning(msg) {
    var toast = document.getElementById('seekWarningToast');
    if (!toast) {
        toast = document.createElement('div');
        toast.id = 'seekWarningToast';
        toast.className = 'study-seek-toast';
        document.body.appendChild(toast);
    }
    toast.textContent = msg || '⚠️ Bạn không thể tua tới đoạn chưa xem! Video đã quay về vị trí hợp lệ.';
    toast.classList.add('show');
    clearTimeout(toast._timer);
    toast._timer = setTimeout(function() {
        toast.classList.remove('show');
    }, 2800);
}

function handleLockedQuizClick(e) {
    if (e) e.preventDefault();
    showSeekWarning('🔒 Bạn cần xem ít nhất 80% video để mở khóa bài kiểm tra!');
    return false;
}

// ── 3. CẬP NHẬT GIAO DIỆN TIẾN ĐỘ & MỞ KHÓA REAL-TIME ──

function updateWatchBar(pct) {
    if (typeof pct !== 'number') pct = parseInt(pct) || 0;
    pct = Math.min(100, Math.max(0, pct));

    // Thanh ngang & số phần trăm
    var fill = document.getElementById('watchBarFill');
    var badge = document.getElementById('barPctBadge');
    if (fill) fill.style.width = pct + '%';
    if (badge) badge.textContent = pct + '%';

    // Vòng tròn phần trăm
    var circFill = document.getElementById('circularProgressFill');
    var circText = document.getElementById('circWatchPct');
    if (circFill) circFill.setAttribute('stroke-dasharray', pct + ', 100');
    if (circText) circText.textContent = pct + '%';

    // Trạng thái bên sidebar phải
    var statusBadge = document.getElementById('rightStatusBadge');
    if (statusBadge) statusBadge.textContent = '✔ Đã xem ' + pct + '%';

    // Mô tả động viên còn thiếu bao nhiêu %
    var motDesc = document.getElementById('rightMotivationDesc');
    if (motDesc && pct < 80) {
        var needed = Math.max(0, 80 - pct);
        motDesc.textContent = 'Bạn chỉ cần xem thêm ' + needed + '% nữa là có thể làm bài Quiz rồi!';
    }

    var gatePct = document.getElementById('gateWatchPct');
    if (gatePct) gatePct.textContent = pct;
}

function unlockQuizUI(pct) {
    updateWatchBar(pct || 80);

    // Tiêu đề phụ dưới video
    var sub = document.getElementById('watchProgressSubtitle');
    if (sub) {
        sub.textContent = '🎉 Chúc mừng! Bạn đã mở khóa bài kiểm tra';
        sub.classList.add('unlocked-text');
    }

    // Hộp điều kiện bên phải
    var condBox = document.getElementById('rightConditionBox');
    var condIcon = document.getElementById('rightConditionIcon');
    var condText = document.getElementById('rightConditionText');
    if (condBox) condBox.className = 'widget-cond-alert widget-cond-alert--unlocked';
    if (condIcon) condIcon.textContent = '🎉';
    if (condText) condText.textContent = 'Đã đủ điều kiện mở khóa bài kiểm tra!';

    // Card động viên bên phải
    var motTitle = document.getElementById('rightMotivationTitle');
    var motDesc = document.getElementById('rightMotivationDesc');
    if (motTitle) motTitle.textContent = 'Chúc mừng!';
    if (motDesc) motDesc.textContent = 'Chúc mừng bạn đã mở khóa bài Quiz! Bạn có thể làm bài ngay bây giờ.';

    // Nút làm bài Quiz CTA bên phải
    var rightBtn = document.getElementById('rightQuizBtn');
    var rightIcon = document.getElementById('rightQuizBtnIcon');
    var rightLabel = document.getElementById('rightQuizBtnLabel');
    if (rightBtn) {
        rightBtn.className = 'btn-quiz-cta btn-quiz-cta--active';
        rightBtn.removeAttribute('aria-disabled');
        rightBtn.removeAttribute('disabled');
        rightBtn.removeAttribute('onclick');
        rightBtn.onclick = null;
        var qUrl = rightBtn.getAttribute('data-quiz-url');
        if (qUrl) {
            rightBtn.setAttribute('href', qUrl);
        }
    }
    if (rightIcon) rightIcon.textContent = '📝';
    if (rightLabel) rightLabel.textContent = 'Làm bài Quiz ngay';

    // Đổi biểu tượng ổ khóa ở sidebar trái thành mở khóa
    document.querySelectorAll('.sidebar-lock-badge').forEach(function(el) {
        el.textContent = '🔓';
    });
    document.querySelectorAll('[id^="sidebarQuizLink-"]').forEach(function(link) {
        link.onclick = null;
    });

    // Mở khóa banner ở tab bài tập nếu có
    var gate = document.getElementById('exerciseTabGate');
    if (gate) {
        gate.outerHTML = '<div class="completed-banner" id="quizUnlockedBanner" style="margin-bottom:16px;">🎉 Chúc mừng! Bạn đã mở khóa bài kiểm tra.</div>';
    }
}

// ── 4. VIDEO TRACKER & CHỐNG TUA ENGINE ──

document.addEventListener('DOMContentLoaded', function() {
    var app = document.getElementById('studyApp');
    if (!app) return;

    var container = document.getElementById('studyPlayerContainer');
    if (!container) return;

    var rawUrl      = app.getAttribute('data-video-url') || '';
    var videoStatus = app.getAttribute('data-video-status') || '';
    var resumePos   = parseFloat(app.getAttribute('data-last-pos')) || 0;
    var savedPct    = parseInt(app.getAttribute('data-watch-pct')) || 0;
    var courseId    = app.getAttribute('data-course-id') || '';
    var lessonId    = app.getAttribute('data-lesson-id') || '';
    var csrfParam   = app.getAttribute('data-csrf-param') || '_csrf';
    var csrfToken   = app.getAttribute('data-csrf-token') || '';
    var ctxPath     = app.getAttribute('data-context-path') || '';

    if (!rawUrl || rawUrl.trim() === '') {
        container.innerHTML =
            '<div style="display:flex;align-items:center;justify-content:center;height:100%;background:#F8FAFC;border-radius:16px;min-height:240px;">' +
            '<div style="text-align:center;color:#94A3B8;"><div style="font-size:2.5rem;margin-bottom:8px;">🎥</div>' +
            '<div style="font-weight:600;">Bài học này chưa có video.</div></div></div>';
        return;
    }

    var url = rawUrl.trim();

    function initVideoTracker(adapter) {
        var furthestAllowedPos = resumePos > 0 ? resumePos : 0;
        var videoDuration = 0;
        var isPlaying = false;
        var isSnapping = false;
        var segmentStart = null;
        var lastPlaybackTime = null;
        var progressTimer = null;

        adapter.on('ready', function() {
            adapter.getDuration(function(d) {
                if (d && d > 0) videoDuration = Math.round(d);
                if (resumePos > 0 && videoDuration > 0 && resumePos < videoDuration - 2) {
                    adapter.setCurrentTime(resumePos);
                }
            });
        });

        adapter.on('play', function() {
            isPlaying = true;
            adapter.getCurrentTime(function(t) {
                segmentStart = t;
                lastPlaybackTime = t;
            });
            clearInterval(progressTimer);
            progressTimer = setInterval(function() {
                if (!isPlaying || isSnapping) return;
                adapter.getCurrentTime(function(t) {
                    recordTick(t);
                });
            }, 4000);
        });

        adapter.on('pause', function() {
            isPlaying = false;
            clearInterval(progressTimer);
            adapter.getCurrentTime(function(t) {
                recordTick(t);
                segmentStart = null;
                lastPlaybackTime = null;
            });
        });

        adapter.on('ended', function() {
            isPlaying = false;
            clearInterval(progressTimer);
            adapter.getCurrentTime(function(t) {
                recordTick(t);
                segmentStart = null;
                lastPlaybackTime = null;
            });
        });

        adapter.on('timeupdate', function(data) {
            if (isSnapping) return;
            var currentTime = (data && typeof data.seconds === 'number') ? data.seconds : null;
            if (currentTime === null) return;

            if (data && data.duration && videoDuration <= 0) {
                videoDuration = Math.round(data.duration);
            }

            // 1. PHÁT HIỆN TUA TỚI VƯỢT QUÁ ĐOẠN ĐÃ XEM:
            if (currentTime > furthestAllowedPos + 1.5) {
                isSnapping = true;
                adapter.setCurrentTime(furthestAllowedPos);
                showSeekWarning('⚠️ Bạn không thể tua tới đoạn chưa xem! Video đã quay về vị trí hợp lệ.');
                segmentStart = furthestAllowedPos;
                lastPlaybackTime = furthestAllowedPos;
                setTimeout(function() { isSnapping = false; }, 400);
                return;
            }

            // 2. PHÁT HIỆN TUA LÙI ĐỂ XEM LẠI:
            if (lastPlaybackTime !== null && currentTime < lastPlaybackTime - 1.0) {
                if (segmentStart !== null && lastPlaybackTime > segmentStart + 0.5) {
                    sendProgressSegment(segmentStart, lastPlaybackTime, lastPlaybackTime, videoDuration);
                }
                segmentStart = currentTime;
                lastPlaybackTime = currentTime;
                return;
            }

            // 3. TIẾN BÌNH THƯỜNG VỀ PHÍA TRƯỚC:
            if (isPlaying) {
                if (currentTime > furthestAllowedPos) {
                    furthestAllowedPos = currentTime;
                }
                lastPlaybackTime = currentTime;
            }
        });

        function recordTick(currentTime) {
            if (segmentStart === null || typeof currentTime !== 'number') {
                segmentStart = currentTime;
                lastPlaybackTime = currentTime;
                return;
            }
            var s = segmentStart;
            var e = currentTime;
            if (e > s + 0.5) {
                sendProgressSegment(s, e, currentTime, videoDuration);
                segmentStart = currentTime;
                lastPlaybackTime = currentTime;
            }
        }

        function sendProgressSegment(s, e, pos, dur) {
            var fd = new FormData();
            fd.append(csrfParam, csrfToken);
            fd.append('start', s.toFixed(1));
            fd.append('end', e.toFixed(1));
            fd.append('position', Math.round(pos));
            if (dur && dur > 0) fd.append('duration', Math.round(dur));

            fetch(ctxPath + '/courses/' + courseId + '/lessons/' + lessonId + '/watch-progress', {
                method: 'POST',
                body: fd
            })
            .then(function(res) { return res.json(); })
            .then(function(data) {
                if (data && data.success) {
                    var pct = data.percent;
                    updateWatchBar(pct);
                    if (data.quizUnlocked || pct >= 80) {
                        unlockQuizUI(pct);
                    }
                }
            })
            .catch(function() {});
        }

        window.addEventListener('beforeunload', function() {
            clearInterval(progressTimer);
            if (isPlaying && segmentStart !== null && lastPlaybackTime !== null && lastPlaybackTime > segmentStart + 0.5) {
                sendProgressSegment(segmentStart, lastPlaybackTime, lastPlaybackTime, videoDuration);
            }
        });
    }

    // Trường hợp 1: Bunny Stream Player
    if (url.indexOf('player.mediadelivery.net') !== -1) {
        if (videoStatus === 'PROCESSING' || videoStatus === 'UPLOADING') {
            container.innerHTML =
                '<div style="display:flex;align-items:center;justify-content:center;height:100%;background:#EFF6FF;border-radius:16px;min-height:240px;">' +
                '<div style="text-align:center;"><div style="font-size:2.5rem;margin-bottom:10px;">⏳</div>' +
                '<div style="font-weight:700;color:#1D4ED8;margin-bottom:4px;">Video đang được xử lý</div>' +
                '<div style="font-size:.84rem;color:#3B82F6;">Bunny Stream đang encode. Thử lại sau vài phút.</div>' +
                '</div></div>';
            return;
        } else if (videoStatus === 'FAILED') {
            container.innerHTML =
                '<div style="display:flex;align-items:center;justify-content:center;height:100%;background:#FEF2F2;border-radius:16px;min-height:240px;">' +
                '<div style="text-align:center;"><div style="font-size:2.5rem;margin-bottom:10px;">❌</div>' +
                '<div style="font-weight:700;color:#DC2626;">Video xử lý thất bại</div></div></div>';
            return;
        }

        var iframeId = 'bunny-iframe-' + lessonId;
        container.innerHTML =
            '<iframe id="' + iframeId + '" src="' + url + '"' +
            ' style="position:absolute;top:0;left:0;width:100%;height:100%;border:0;"' +
            ' allowfullscreen allow="autoplay; encrypted-media" loading="lazy"></iframe>';

        var script = document.createElement('script');
        script.src = 'https://assets.mediadelivery.net/playerjs/player-0.1.0.min.js';
        script.onload = function() {
            var iframe = document.getElementById(iframeId);
            if (!iframe || typeof playerjs === 'undefined') return;

            var player = new playerjs.Player(iframe);
            var bunnyAdapter = {
                on: function(evt, handler) { player.on(evt, handler); },
                getCurrentTime: function(cb) { player.getCurrentTime(cb); },
                setCurrentTime: function(secs) { player.setCurrentTime(secs); },
                getDuration: function(cb) { player.getDuration(cb); }
            };

            initVideoTracker(bunnyAdapter);
        };
        document.head.appendChild(script);
        return;
    }

    // Trường hợp 2: YouTube
    if (url.indexOf('youtube.com') !== -1 || url.indexOf('youtu.be') !== -1) {
        var videoId = '';
        if (url.indexOf('watch?v=') !== -1) videoId = url.split('watch?v=')[1].split('&')[0];
        else if (url.indexOf('youtu.be/') !== -1) videoId = url.split('youtu.be/')[1].split('?')[0];
        else videoId = url;
        var embedUrl = videoId.indexOf('http') === 0 ? videoId : 'https://www.youtube.com/embed/' + videoId;
        container.innerHTML = '<iframe src="' + embedUrl + '" style="position:absolute;top:0;left:0;width:100%;height:100%;border:0;" allowfullscreen allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"></iframe>';
        return;
    }

    // Trường hợp 3: Video HTML5 trực tiếp
    var vid = document.createElement('video');
    vid.controls = true;
    vid.preload  = 'metadata';
    vid.style.cssText = 'position:absolute;top:0;left:0;width:100%;height:100%;background:#000;';

    var src = document.createElement('source');
    src.src  = url;
    src.type = 'video/mp4';
    vid.appendChild(src);
    container.innerHTML = '';
    container.appendChild(vid);

    var html5Adapter = {
        on: function(evt, handler) {
            if (evt === 'ready') {
                if (vid.readyState >= 1) handler();
                else vid.addEventListener('loadedmetadata', handler);
            } else if (evt === 'timeupdate') {
                vid.addEventListener('timeupdate', function() {
                    handler({ seconds: vid.currentTime, duration: vid.duration });
                });
                vid.addEventListener('seeking', function() {
                    handler({ seconds: vid.currentTime, duration: vid.duration });
                });
            } else {
                vid.addEventListener(evt, handler);
            }
        },
        getCurrentTime: function(cb) { cb(vid.currentTime); },
        setCurrentTime: function(secs) { vid.currentTime = secs; },
        getDuration: function(cb) { cb(vid.duration); }
    };

    initVideoTracker(html5Adapter);
});

