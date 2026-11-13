import os
import sys
import re
import json
import time
import uuid
import shutil
import logging
import threading
import subprocess
import urllib.request
import urllib.error
from pathlib import Path
from typing import Optional, Dict, Any, List

from fastapi import FastAPI, BackgroundTasks, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field

# ──────────────────────────────────────────────────────────
# CONFIGURATION & CONSTANTS
# ──────────────────────────────────────────────────────────

BASE_DIR = Path(__file__).resolve().parent
TASKS_DIR = BASE_DIR / "tasks"
TASKS_DIR.mkdir(parents=True, exist_ok=True)

OLLAMA_URL = os.environ.get("OLLAMA_URL", "http://localhost:11434/api/generate")
OLLAMA_TAGS_URL = os.environ.get("OLLAMA_TAGS_URL", "http://localhost:11434/api/tags")
OLLAMA_MODEL = os.environ.get("OLLAMA_MODEL", "qwen2.5:3b")

FFMPEG_PATH = os.environ.get("FFMPEG_PATH", r"D:\ffmpeg-9.0.2-essentials_build\bin\ffmpeg.exe")
if not os.path.exists(FFMPEG_PATH):
    # Fallback to system ffmpeg if custom path doesn't exist
    FFMPEG_PATH = "ffmpeg"

WHISPER_MODEL_NAME = "small"
WHISPER_DEVICE = "cpu"
WHISPER_COMPUTE_TYPE = "int8"

CHUNK_SIZE_LINES = 15  # Số dòng timestamp tối đa trong 1 chunk hiệu đính

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(name)s: %(message)s"
)
logger = logging.getLogger("EduSphereAI")

# ──────────────────────────────────────────────────────────
# GLOBAL STATE & WHISPER MODEL SINGLETON
# ──────────────────────────────────────────────────────────

_whisper_model = None
_whisper_lock = threading.Lock()
_tasks_lock = threading.Lock()
_tasks_store: Dict[str, Dict[str, Any]] = {}


def get_whisper_model():
    """Tải và lưu trữ mô hình Faster-Whisper dạng singleton để tái sử dụng."""
    global _whisper_model
    with _whisper_lock:
        if _whisper_model is None:
            logger.info("Đang khởi tạo Faster-Whisper model (%s, %s, %s)...",
                        WHISPER_MODEL_NAME, WHISPER_DEVICE, WHISPER_COMPUTE_TYPE)
            from faster_whisper import WhisperModel
            _whisper_model = WhisperModel(
                WHISPER_MODEL_NAME,
                device=WHISPER_DEVICE,
                compute_type=WHISPER_COMPUTE_TYPE
            )
            logger.info("Faster-Whisper model đã sẵn sàng.")
        return _whisper_model


# ──────────────────────────────────────────────────────────
# PYDANTIC SCHEMAS
# ──────────────────────────────────────────────────────────

class GenerateMaterialRequest(BaseModel):
    lessonId: int = Field(..., description="ID của bài học trong EduSphere")
    videoUrl: Optional[str] = Field(None, description="URL video bài học hoặc đường dẫn file")
    bunnyVideoId: Optional[str] = Field(None, description="Bunny Stream Video GUID nếu có")
    libraryId: Optional[str] = Field(None, description="Bunny Library ID nếu có")
    bunnyApiKey: Optional[str] = Field(None, description="Bunny Stream API Key nội bộ")
    filePath: Optional[str] = Field(None, description="Đường dẫn file video/audio local nếu có")
    forceRegenerate: Optional[bool] = Field(False, description="Tạo lại kể cả khi đã có tài liệu")


class TaskStatusResponse(BaseModel):
    taskId: str
    lessonId: int
    status: str  # PENDING, DOWNLOADING, EXTRACTING_AUDIO, TRANSCRIBING, CORRECTING, GENERATING, COMPLETED, FAILED
    progress: int
    currentStep: str
    message: str
    error: Optional[str] = None


class TaskResultResponse(BaseModel):
    taskId: str
    lessonId: int
    status: str
    originalTranscript: Optional[str] = None
    correctedTranscript: Optional[str] = None
    summary: Optional[str] = None
    keyPoints: Optional[str] = None
    terms: Optional[str] = None
    conclusion: Optional[str] = None
    aiModel: Optional[str] = None
    message: Optional[str] = None


class HealthResponse(BaseModel):
    status: str
    ollama: bool
    ollamaModel: str
    ffmpeg: bool
    whisper: bool
    activeTasks: int


# ──────────────────────────────────────────────────────────
# FASTAPI APP SETUP
# ──────────────────────────────────────────────────────────

app = FastAPI(
    title="EduSphere AI Lecture Analysis Service",
    description="Microservice phân tích video bài giảng: Whisper Speech-to-Text + Qwen 2.5:3B hiệu đính & sinh tài liệu học tập.",
    version="1.0.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# ──────────────────────────────────────────────────────────
# OLLAMA CLIENT HELPER
# ──────────────────────────────────────────────────────────

def call_ollama(prompt: str, temperature: float = 0.3, timeout: int = 600) -> str:
    """Gửi yêu cầu tới Ollama local API và nhận kết quả."""
    payload = {
        "model": OLLAMA_MODEL,
        "prompt": prompt,
        "stream": False,
        "options": {
            "temperature": temperature
        }
    }
    req = urllib.request.Request(
        OLLAMA_URL,
        data=json.dumps(payload).encode("utf-8"),
        headers={"Content-Type": "application/json"},
        method="POST"
    )
    try:
        with urllib.request.urlopen(req, timeout=timeout) as resp:
            data = json.loads(resp.read().decode("utf-8"))
            return data.get("response", "")
    except urllib.error.URLError as e:
        logger.error("Lỗi kết nối tới Ollama tại %s: %s", OLLAMA_URL, e)
        raise RuntimeError(f"Không thể kết nối đến Ollama model {OLLAMA_MODEL}: {e}")
    except Exception as e:
        logger.error("Lỗi khi gọi Ollama: %s", e)
        raise RuntimeError(f"Lỗi xử lý Ollama: {e}")


def check_ollama_health() -> bool:
    """Kiểm tra Ollama có đang hoạt động và model qwen2.5:3b có sẵn không."""
    try:
        req = urllib.request.Request(OLLAMA_TAGS_URL, method="GET")
        with urllib.request.urlopen(req, timeout=4) as resp:
            data = json.loads(resp.read().decode("utf-8"))
            models = [m.get("name", "") for m in data.get("models", [])]
            return any(OLLAMA_MODEL in m for m in models)
    except Exception:
        return False


def check_ffmpeg_health() -> bool:
    """Kiểm tra FFmpeg binary có thể thực thi được không."""
    try:
        proc = subprocess.run([FFMPEG_PATH, "-version"], capture_output=True, text=True, timeout=5)
        return proc.returncode == 0
    except Exception:
        return False


# ──────────────────────────────────────────────────────────
# TASK STATE MANAGEMENT
# ──────────────────────────────────────────────────────────

def save_task_metadata(task_id: str, data: Dict[str, Any]):
    """Ghi metadata tác vụ ra file JSON trong thư mục riêng để lưu trữ bền vững."""
    task_dir = TASKS_DIR / task_id
    task_dir.mkdir(parents=True, exist_ok=True)
    meta_file = task_dir / "metadata.json"
    with open(meta_file, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)


def update_task_progress(task_id: str, status_code: str, progress: int, current_step: str, message: str, error: Optional[str] = None):
    with _tasks_lock:
        task = _tasks_store.get(task_id, {})
        task.update({
            "status": status_code,
            "progress": progress,
            "currentStep": current_step,
            "message": message,
            "error": error,
            "updatedAt": time.time()
        })
        _tasks_store[task_id] = task
        save_task_metadata(task_id, task)
    logger.info("[%s] Status: %s (%d%%) - %s", task_id, status_code, progress, message)


# ──────────────────────────────────────────────────────────
# AUDIO EXTRACTION & SOURCE RESOLUTION
# ──────────────────────────────────────────────────────────

def resolve_video_source(req: GenerateMaterialRequest, task_dir: Path) -> Path:
    """
    Xác định nguồn video/audio thực tế:
    1. Kiểm tra filePath trực tiếp (nếu có).
    2. Kiểm tra videoUrl nếu là đường dẫn tệp local hoặc relative upload.
    3. Kiểm tra Bunny Stream video (tải MP4 nhẹ 360p/240p hoặc trích xuất HLS m3u8 có Referer).
    4. Kiểm tra URL video trực tiếp (HTTP/HTTPS).
    5. Trích xuất âm thanh thành file WAV 16kHz mono qua FFmpeg.
    """
    input_file: Optional[Path] = None

    # TH1: filePath được truyền trực tiếp
    if req.filePath and os.path.exists(req.filePath):
        input_file = Path(req.filePath)
        logger.info("Sử dụng filePath cục bộ: %s", input_file)

    # TH2: videoUrl là đường dẫn tệp trên ổ đĩa (VD: "D:\...")
    elif req.videoUrl and (":\\" in req.videoUrl or ":/" in req.videoUrl) and os.path.exists(req.videoUrl):
        input_file = Path(req.videoUrl)
        logger.info("Sử dụng videoUrl dạng tệp tuyệt đối: %s", input_file)

    # TH3: videoUrl là đường dẫn upload của EduSphere (/uploads/... hoặc /EduSphere/uploads/...)
    elif req.videoUrl and ("/uploads/" in req.videoUrl):
        clean_path = req.videoUrl.split("/uploads/", 1)[1]
        user_home = Path.home()
        candidate = user_home / "edusphere" / "uploads" / clean_path.replace("/", os.sep)
        if candidate.exists():
            input_file = candidate
            logger.info("Tìm thấy tệp trong thư mục uploads của EduSphere: %s", candidate)

    # TH4: Bunny Stream Video (GUID hoặc Embed URL)
    bunny_guid = req.bunnyVideoId
    bunny_lib = req.libraryId or "800127"
    bunny_key = req.bunnyApiKey or "3f6eaad6-366f-4cba-9a3bb953d97e-341f-46c0"

    if not bunny_guid and req.videoUrl and "mediadelivery.net/embed/" in req.videoUrl:
        try:
            parts = req.videoUrl.split("mediadelivery.net/embed/")[1].split("/")
            if len(parts) >= 2:
                bunny_lib = parts[0]
                bunny_guid = parts[1].split("?")[0]
        except Exception as e:
            logger.warning("Không thể parse GUID từ videoUrl: %s", e)

    if not input_file and bunny_guid:
        logger.info("Nguồn video từ Bunny Stream (GUID: %s, Library: %s)", bunny_guid, bunny_lib)
        try:
            # 1. Gọi Bunny API lấy thông tin pull zone CDN hostname
            bunny_api = f"https://video.bunnycdn.com/library/{bunny_lib}/videos/{bunny_guid}"
            headers = {"AccessKey": bunny_key, "Accept": "application/json"}
            b_req = urllib.request.Request(bunny_api, headers=headers, method="GET")
            with urllib.request.urlopen(b_req, timeout=15) as resp:
                b_data = json.loads(resp.read().decode("utf-8"))

            video_title = b_data.get("title", f"Lesson_{req.lessonId}")
            thumbnail_url = b_data.get("thumbnailUrl", "")
            logger.info("Đã tìm thấy video trên Bunny: '%s' (Thumbnail: %s)", video_title, thumbnail_url)

            host = None
            if thumbnail_url and "/" in thumbnail_url:
                host_parts = thumbnail_url.split("/")
                if len(host_parts) >= 3:
                    host = host_parts[2]

            if not host:
                logger.warning("Không tìm thấy pullzone host từ thumbnail, sử dụng fallback vz-8708639d-b41.b-cdn.net")
                host = "vz-8708639d-b41.b-cdn.net"

            # 2. Thử tải tệp MP4 nhẹ (360p -> 240p -> 480p) kèm Referer header
            resolutions = ["play_360p.mp4", "play_240p.mp4", "play_480p.mp4"]
            downloaded_mp4 = task_dir / "bunny_video.mp4"

            for res_name in resolutions:
                video_download_url = f"https://{host}/{bunny_guid}/{res_name}"
                logger.info("Đang tải video nhẹ từ Bunny CDN: %s", video_download_url)
                down_req = urllib.request.Request(
                    video_download_url,
                    headers={"Referer": "https://player.mediadelivery.net/"}
                )
                try:
                    with urllib.request.urlopen(down_req, timeout=90) as v_resp, open(downloaded_mp4, "wb") as f_out:
                        while True:
                            chunk = v_resp.read(65536)
                            if not chunk:
                                break
                            f_out.write(chunk)
                    if downloaded_mp4.exists() and downloaded_mp4.stat().st_size > 0:
                        input_file = downloaded_mp4
                        logger.info("Tải video Bunny thành công: %s (%d bytes)", downloaded_mp4.name, downloaded_mp4.stat().st_size)
                        break
                except Exception as down_err:
                    logger.warning("Không thể tải %s: %s", res_name, down_err)

            # 3. Nếu không tải được MP4, trích xuất âm thanh trực tiếp từ HLS m3u8 bằng FFmpeg
            if not input_file:
                m3u8_url = f"https://{host}/{bunny_guid}/playlist.m3u8"
                logger.info("Thử trích xuất âm thanh trực tiếp từ m3u8 qua FFmpeg: %s", m3u8_url)
                output_wav = task_dir / "audio_16k.wav"
                cmd = [
                    FFMPEG_PATH,
                    "-y",
                    "-headers", "Referer: https://player.mediadelivery.net/\r\n",
                    "-i", m3u8_url,
                    "-vn",
                    "-acodec", "pcm_s16le",
                    "-ar", "16000",
                    "-ac", "1",
                    str(output_wav)
                ]
                proc = subprocess.run(cmd, capture_output=True, text=True, timeout=180)
                if proc.returncode == 0 and output_wav.exists() and output_wav.stat().st_size > 0:
                    logger.info("Trích xuất WAV trực tiếp từ HLS m3u8 thành công!")
                    return output_wav
        except Exception as e:
            logger.error("Lỗi khi xử lý video từ Bunny Stream (GUID %s): %s", bunny_guid, e)

    # TH5: Video URL trực tiếp từ internet (HTTP / HTTPS khác)
    if not input_file and req.videoUrl and req.videoUrl.startswith(("http://", "https://")):
        logger.info("Trích xuất âm thanh từ URL trực tiếp qua FFmpeg: %s", req.videoUrl)
        output_wav = task_dir / "audio_16k.wav"
        cmd = [
            FFMPEG_PATH,
            "-y",
            "-i", req.videoUrl,
            "-vn",
            "-acodec", "pcm_s16le",
            "-ar", "16000",
            "-ac", "1",
            str(output_wav)
        ]
        proc = subprocess.run(cmd, capture_output=True, text=True, timeout=180)
        if proc.returncode == 0 and output_wav.exists() and output_wav.stat().st_size > 0:
            return output_wav

    if not input_file or not input_file.exists():
        raise FileNotFoundError(
            f"Không thể tìm thấy hoặc tải video của bài học {req.lessonId}. "
            f"videoUrl='{req.videoUrl}', bunnyVideoId='{req.bunnyVideoId}'"
        )

    # Trích xuất sang WAV 16kHz mono phục vụ Whisper
    output_wav = task_dir / "audio_16k.wav"
    ext = input_file.suffix.lower()

    if ext == ".wav":
        # Nếu đã là wav, copy hoặc convert chuẩn
        logger.info("File đầu vào đã là WAV, chuẩn hóa tần số lấy mẫu 16kHz...")
    else:
        logger.info("Đang trích xuất âm thanh từ %s sang WAV 16kHz bằng FFmpeg...", input_file.name)

    cmd = [
        FFMPEG_PATH,
        "-y",
        "-i", str(input_file),
        "-vn",
        "-acodec", "pcm_s16le",
        "-ar", "16000",
        "-ac", "1",
        str(output_wav)
    ]
    proc = subprocess.run(cmd, capture_output=True, text=True)
    if proc.returncode != 0:
        logger.error("FFmpeg thất bại (code %d): %s", proc.returncode, proc.stderr)
        raise RuntimeError(f"FFmpeg không thể trích xuất âm thanh: {proc.stderr[:300]}")

    if not output_wav.exists() or output_wav.stat().st_size == 0:
        raise RuntimeError("File âm thanh trích xuất rỗng hoặc không tồn tại.")

    return output_wav


# ──────────────────────────────────────────────────────────
# TRANSCRIPT CORRECTION CHUNKER
# ──────────────────────────────────────────────────────────

CORRECT_PROMPT_TEMPLATE = """Bạn là chuyên gia hiệu đính bản ghi âm bài giảng tiếng Việt, đặc biệt là bài giảng lập trình công nghệ thông tin (Java).

NHIỆM VỤ:
Kiểm tra và sửa các từ Whisper nhận diện sai do phát âm, âm thanh không rõ hoặc nhầm từ đồng âm gần giống nhau trong ngữ cảnh lập trình.

NGUYÊN TẮC QUAN TRỌNG:
1. Đọc toàn bộ ngữ cảnh trước khi sửa từng từ.
2. Ưu tiên những từ có nghĩa phù hợp với bài giảng lập trình Java.
3. Sửa cả lỗi sai từ ngữ cảnh, không chỉ sửa dấu câu hoặc chính tả.
   - Ví dụ: "Ghi chú 1 rồng" -> "Ghi chú 1 dòng".
   - Ví dụ: "Căn cho cộng với Sộc" -> "Ctrl + /".
   - Ví dụ: "bài tập gia ba" -> "bài tập Java".
4. Giữ nguyên tất cả các mốc thời gian dạng [XX.XXs - YY.YYs].
5. Không tự thêm kiến thức mới hoặc thay đổi ý của giảng viên.
6. Nếu một từ không thể xác định chắc chắn ngữ cảnh, hãy đánh dấu [CẦN KIỂM TRA].
7. Chỉ trả về các dòng văn bản đã hiệu đính, không thêm lời chào hay giải thích ngoài lề.

VĂN BẢN CẦN HIỆU ĐÍNH:
{chunk_text}
"""

def correct_transcript_chunked(raw_transcript: str, task_id: Optional[str] = None) -> str:
    """Chia transcript thành các đoạn nhỏ để Qwen 3B hiệu đính không bị tràn context và không sót dòng."""
    lines = [line.strip() for line in raw_transcript.splitlines() if line.strip()]
    if not lines:
        return ""

    # Nếu transcript ngắn dưới CHUNK_SIZE_LINES, hiệu đính 1 lần
    if len(lines) <= CHUNK_SIZE_LINES:
        prompt = CORRECT_PROMPT_TEMPLATE.format(chunk_text="\n".join(lines))
        return call_ollama(prompt).strip()

    # Nếu dài, chia theo chunks
    corrected_chunks = []
    total_chunks = (len(lines) + CHUNK_SIZE_LINES - 1) // CHUNK_SIZE_LINES

    for i in range(0, len(lines), CHUNK_SIZE_LINES):
        chunk_lines = lines[i:i + CHUNK_SIZE_LINES]
        chunk_idx = (i // CHUNK_SIZE_LINES) + 1
        logger.info("Đang hiệu đính chunk %d/%d (%d dòng)...", chunk_idx, total_chunks, len(chunk_lines))

        if task_id:
            chunk_pct = 55 + int(25 * chunk_idx / total_chunks)
            update_task_progress(
                task_id, "CORRECTING", chunk_pct, "CORRECTING",
                f"Qwen 2.5:3B đang hiệu đính ngữ cảnh đoạn {chunk_idx}/{total_chunks} ({len(chunk_lines)} dòng)..."
            )

        prompt = CORRECT_PROMPT_TEMPLATE.format(chunk_text="\n".join(chunk_lines))
        chunk_result = call_ollama(prompt).strip()
        corrected_chunks.append(chunk_result)

    return "\n".join(corrected_chunks)


# ──────────────────────────────────────────────────────────
# MATERIAL GENERATION & PARSING
# ──────────────────────────────────────────────────────────

MATERIAL_PROMPT_TEMPLATE = """Bạn là trợ lý giảng dạy chuyên nghiệp của nền tảng học trực tuyến EduSphere.

Dựa trên nội dung bài giảng dưới đây, hãy biên soạn tài liệu học tập toàn diện bằng tiếng Việt.

BẮT BUỘC BẮT ĐẦU VÀ TRÌNH BÀY ĐÚNG THEO 4 TIÊU ĐỀ SAU (KHÔNG THÊM LỜI MỞ ĐẦU HOẶC CHÀO HỎI):

#### 1. SUMMARY
- Viết 1-2 đoạn văn tóm tắt nội dung chính được giảng viên trình bày trong bài học.

#### 2. KEY POINTS
- Liệt kê các kiến thức, phép toán, cú pháp hoặc thao tác quan trọng dưới dạng gạch đầu dòng (-).

#### 3. TERMS
- Liệt kê và giải thích ngắn gọn các thuật ngữ, kiểu dữ liệu xuất hiện trong bài. Định dạng: - **Tên thuật ngữ**: Giải thích.

#### 4. CONCLUSION
- Tổng kết ngắn gọn 1-2 câu về điều cốt lõi cần ghi nhớ.

NỘI DUNG BÀI GIẢNG:
{transcript}
"""

def parse_material_sections(raw_material: str) -> Dict[str, str]:
    """Phân tách văn bản markdown thành 4 trường có cấu trúc (summary, keyPoints, terms, conclusion)."""
    sections = {
        "summary": "",
        "keyPoints": "",
        "terms": "",
        "conclusion": ""
    }

    text = raw_material.strip()

    # Pattern tìm vị trí của từng heading 1..4
    h1_match = re.search(r"(?:^|\n)#{1,4}\s*(?:1\.?\s*(?:SUMMARY|TÓM TẮT|Tóm tắt))", text, re.IGNORECASE)
    h2_match = re.search(r"(?:^|\n)#{1,4}\s*(?:2\.?\s*(?:KEY\s*POINTS|Kiến thức|KIẾN THỨC|[^\n]*))", text, re.IGNORECASE)
    h3_match = re.search(r"(?:^|\n)#{1,4}\s*(?:3\.?\s*(?:TERMS|THUẬT NGỮ|Thuật ngữ|[^\n]*))", text, re.IGNORECASE)
    h4_match = re.search(r"(?:^|\n)#{1,4}\s*(?:4\.?\s*(?:CONCLUSION|TỔNG KẾT|Tổng kết|KẾT LUẬN|[^\n]*))", text, re.IGNORECASE)

    if h1_match and h2_match and h3_match and h4_match:
        p1 = h1_match.end()
        p2_start = h2_match.start()
        p2_end = h2_match.end()
        p3_start = h3_match.start()
        p3_end = h3_match.end()
        p4_start = h4_match.start()
        p4_end = h4_match.end()

        sections["summary"] = text[p1:p2_start].strip()
        sections["keyPoints"] = text[p2_end:p3_start].strip()
        sections["terms"] = text[p3_end:p4_start].strip()
        sections["conclusion"] = text[p4_end:].strip()
        return sections

    # Fallback phân tách linh hoạt theo từng block heading ####
    lines = text.splitlines()
    current_key = "summary"
    buffers = {"summary": [], "keyPoints": [], "terms": [], "conclusion": []}

    for line in lines:
        l_strip = line.strip()
        l_lower = l_strip.lower()
        if re.match(r"^#{1,4}\s*1[\.\s]|summary|tóm tắt", l_lower):
            current_key = "summary"
            continue
        elif re.match(r"^#{1,4}\s*2[\.\s]|key\s*points|kiến thức|trọng tâm", l_lower):
            current_key = "keyPoints"
            continue
        elif re.match(r"^#{1,4}\s*3[\.\s]|terms|thuật ngữ", l_lower):
            current_key = "terms"
            continue
        elif re.match(r"^#{1,4}\s*4[\.\s]|conclusion|tổng kết|kết luận", l_lower):
            current_key = "conclusion"
            continue

        buffers[current_key].append(line)

    for k in sections:
        sections[k] = "\n".join(buffers[k]).strip()

    # Nếu mô hình không dùng heading 1..4 mà dùng dạng danh sách đánh số
    if not sections["keyPoints"] or not sections["conclusion"]:
        kp_lines = []
        concl_lines = []
        sum_lines = []

        for line in lines:
            l_strip = line.strip()
            if re.match(r"^\d+[\.\)]\s+", l_strip) or re.match(r"^[-*•]\s+", l_strip):
                kp_lines.append(l_strip)
            elif any(l_strip.lower().startswith(prefix) for prefix in ["tóm lại", "kết luận", "tổng kết", "nhìn chung"]):
                concl_lines.append(l_strip)
            elif l_strip and not any(l_strip.lower().startswith(p) for p in ["dựa trên", "dưới đây", "sau đây"]):
                sum_lines.append(l_strip)

        if kp_lines and not sections["keyPoints"]:
            sections["keyPoints"] = "\n".join(kp_lines)
        if concl_lines and not sections["conclusion"]:
            sections["conclusion"] = "\n".join(concl_lines)
        if sum_lines and not sections["summary"]:
            sections["summary"] = "\n".join(sum_lines)
        elif not sections["summary"]:
            sections["summary"] = text

    return sections


# ──────────────────────────────────────────────────────────
# BACKGROUND PIPELINE WORKER
# ──────────────────────────────────────────────────────────

def run_ai_pipeline(task_id: str, req: GenerateMaterialRequest):
    """Quy trình xử lý tuần tự từ audio -> Whisper -> Qwen -> Lưu kết quả."""
    task_dir = TASKS_DIR / task_id
    task_dir.mkdir(parents=True, exist_ok=True)

    try:
        # Bước 1: Trích xuất / xác định audio
        update_task_progress(
            task_id, "EXTRACTING_AUDIO", 15, "EXTRACTING_AUDIO",
            "Đang kiểm tra nguồn video và trích xuất âm thanh bằng FFmpeg..."
        )
        audio_wav = resolve_video_source(req, task_dir)

        # Bước 2: Chuyển giọng nói thành văn bản bằng Whisper
        update_task_progress(
            task_id, "TRANSCRIBING", 35, "TRANSCRIBING",
            "Đang chuyển giọng nói thành văn bản tiếng Việt bằng Faster-Whisper..."
        )
        whisper = get_whisper_model()
        segments, info = whisper.transcribe(
            str(audio_wav),
            language="vi",
            beam_size=5,
            vad_filter=True
        )

        raw_lines = []
        for segment in segments:
            raw_lines.append(f"[{segment.start:.2f}s - {segment.end:.2f}s] {segment.text.strip()}")

        raw_transcript = "\n".join(raw_lines)
        if not raw_transcript.strip():
            raise RuntimeError("Faster-Whisper không nhận diện được giọng nói trong video (âm thanh rỗng hoặc không có tiếng).")

        # Lưu transcript gốc
        raw_transcript_path = task_dir / "transcript_raw.txt"
        with open(raw_transcript_path, "w", encoding="utf-8") as f:
            f.write(raw_transcript)

        # Bước 3: Hiệu đính transcript bằng Qwen 2.5:3B
        update_task_progress(
            task_id, "CORRECTING", 55, "CORRECTING",
            f"Đang hiệu đính ngữ cảnh và thuật ngữ lập trình bằng Qwen 2.5:3B ({len(raw_lines)} mốc thời gian)..."
        )
        corrected_transcript = correct_transcript_chunked(raw_transcript, task_id=task_id)
        corrected_transcript_path = task_dir / "transcript_corrected.txt"
        with open(corrected_transcript_path, "w", encoding="utf-8") as f:
            f.write(corrected_transcript)

        # Bước 4: Tạo tài liệu học tập bằng Qwen 2.5:3B
        update_task_progress(
            task_id, "GENERATING", 85, "GENERATING",
            "Đang tổng hợp tóm tắt, kiến thức trọng tâm, thuật ngữ và kết luận..."
        )
        material_prompt = MATERIAL_PROMPT_TEMPLATE.format(transcript=corrected_transcript)
        raw_material_md = call_ollama(material_prompt)

        # Lưu markdown hoàn chỉnh
        md_path = task_dir / "lesson_material.md"
        with open(md_path, "w", encoding="utf-8") as f:
            f.write("# TÀI LIỆU HỌC TẬP EDUSPHERE\n\n" + raw_material_md)

        # Phân tách thành 4 trường có cấu trúc
        parsed_sections = parse_material_sections(raw_material_md)

        # Bước 5: Hoàn tất tác vụ
        with _tasks_lock:
            task = _tasks_store.get(task_id, {})
            task.update({
                "status": "COMPLETED",
                "progress": 100,
                "currentStep": "COMPLETED",
                "message": "Phân tích bài giảng và tạo tài liệu học tập thành công!",
                "originalTranscript": raw_transcript,
                "correctedTranscript": corrected_transcript,
                "summary": parsed_sections["summary"],
                "keyPoints": parsed_sections["keyPoints"],
                "terms": parsed_sections["terms"],
                "conclusion": parsed_sections["conclusion"],
                "aiModel": f"{OLLAMA_MODEL} + whisper-{WHISPER_MODEL_NAME}",
                "updatedAt": time.time(),
                "error": None
            })
            _tasks_store[task_id] = task
            save_task_metadata(task_id, task)

        logger.info("[%s] Hoàn thành toàn bộ quy trình AI cho lessonId=%d!", task_id, req.lessonId)

    except Exception as e:
        logger.exception("[%s] Lỗi trong quy trình xử lý AI: %s", task_id, e)
        update_task_progress(
            task_id, "FAILED", 0, "FAILED",
            f"Xử lý thất bại: {str(e)}",
            error=str(e)
        )


# ──────────────────────────────────────────────────────────
# REST API ENDPOINTS
# ──────────────────────────────────────────────────────────

@app.get("/health", response_model=HealthResponse)
def health():
    """Kiểm tra tình trạng hoạt động của các thành phần AI (Ollama, Whisper, FFmpeg)."""
    ollama_ok = check_ollama_health()
    ffmpeg_ok = check_ffmpeg_health()
    return HealthResponse(
        status="UP" if (ollama_ok and ffmpeg_ok) else "DEGRADED",
        ollama=ollama_ok,
        ollamaModel=OLLAMA_MODEL,
        ffmpeg=ffmpeg_ok,
        whisper=True,
        activeTasks=len([t for t in _tasks_store.values() if t.get("status") not in ("COMPLETED", "FAILED")])
    )


@app.post("/api/ai/materials/generate", response_model=Dict[str, Any], status_code=status.HTTP_202_ACCEPTED)
def generate_material_endpoint(req: GenerateMaterialRequest):
    """
    Khởi tạo tác vụ phân tích video bài giảng bằng AI (Asynchronous).
    Trả về taskId ngay lập tức và chạy xử lý ngầm trong background.
    """
    if req.lessonId <= 0:
        raise HTTPException(status_code=400, detail="lessonId không hợp lệ.")

    # Kiểm tra xem có tác vụ nào của lessonId này đang chạy dở không
    with _tasks_lock:
        for tid, tdata in _tasks_store.items():
            if tdata.get("lessonId") == req.lessonId and tdata.get("status") in ("PENDING", "EXTRACTING_AUDIO", "TRANSCRIBING", "CORRECTING", "GENERATING"):
                if not req.forceRegenerate:
                    return {
                        "taskId": tid,
                        "lessonId": req.lessonId,
                        "status": tdata.get("status"),
                        "message": "Đang có một tác vụ phân tích cho bài học này đang được xử lý."
                    }

    # Tạo Task ID mới
    task_id = f"task_{int(time.time())}_{uuid.uuid4().hex[:8]}"

    initial_state = {
        "taskId": task_id,
        "lessonId": req.lessonId,
        "status": "PENDING",
        "progress": 0,
        "currentStep": "PENDING",
        "message": "Đã tiếp nhận yêu cầu phân tích bài giảng. Đang khởi tạo hàng đợi...",
        "createdAt": time.time(),
        "updatedAt": time.time(),
        "error": None
    }

    with _tasks_lock:
        _tasks_store[task_id] = initial_state
        save_task_metadata(task_id, initial_state)

    # Khởi chạy pipeline ngầm trong thread riêng
    worker_thread = threading.Thread(
        target=run_ai_pipeline,
        args=(task_id, req),
        daemon=True,
        name=f"AiWorker-{task_id}"
    )
    worker_thread.start()

    return {
        "taskId": task_id,
        "lessonId": req.lessonId,
        "status": "PENDING",
        "message": "Đã tiếp nhận yêu cầu phân tích bài giảng thành công."
    }


@app.get("/api/ai/materials/tasks/{taskId}", response_model=TaskStatusResponse)
def get_task_status(taskId: str):
    """Kiểm tra tiến trình thực tế của tác vụ AI theo taskId."""
    with _tasks_lock:
        task = _tasks_store.get(taskId)

    # Nếu chưa có trong RAM, thử đọc từ file metadata.json
    if not task:
        meta_file = TASKS_DIR / taskId / "metadata.json"
        if meta_file.exists():
            try:
                with open(meta_file, "r", encoding="utf-8") as f:
                    task = json.load(f)
                    with _tasks_lock:
                        _tasks_store[taskId] = task
            except Exception:
                task = None

    if not task:
        raise HTTPException(status_code=404, detail=f"Không tìm thấy tác vụ với taskId={taskId}")

    return TaskStatusResponse(
        taskId=task["taskId"],
        lessonId=task["lessonId"],
        status=task["status"],
        progress=task.get("progress", 0),
        currentStep=task.get("currentStep", "PENDING"),
        message=task.get("message", ""),
        error=task.get("error")
    )


@app.get("/api/ai/materials/tasks/{taskId}/result", response_model=TaskResultResponse)
def get_task_result(taskId: str):
    """Lấy kết quả đầy đủ (transcript, summary, keyPoints, terms, conclusion) khi tác vụ đã hoàn thành."""
    with _tasks_lock:
        task = _tasks_store.get(taskId)

    if not task:
        meta_file = TASKS_DIR / taskId / "metadata.json"
        if meta_file.exists():
            try:
                with open(meta_file, "r", encoding="utf-8") as f:
                    task = json.load(f)
                    with _tasks_lock:
                        _tasks_store[taskId] = task
            except Exception:
                task = None

    if not task:
        raise HTTPException(status_code=404, detail=f"Không tìm thấy tác vụ với taskId={taskId}")

    current_status = task.get("status")
    if current_status == "COMPLETED":
        return TaskResultResponse(
            taskId=task["taskId"],
            lessonId=task["lessonId"],
            status="COMPLETED",
            originalTranscript=task.get("originalTranscript"),
            correctedTranscript=task.get("correctedTranscript"),
            summary=task.get("summary"),
            keyPoints=task.get("keyPoints"),
            terms=task.get("terms"),
            conclusion=task.get("conclusion"),
            aiModel=task.get("aiModel"),
            message="Thành công"
        )
    elif current_status == "FAILED":
        return TaskResultResponse(
            taskId=task["taskId"],
            lessonId=task["lessonId"],
            status="FAILED",
            message=task.get("error", "Tác vụ thất bại.")
        )
    else:
        return TaskResultResponse(
            taskId=task["taskId"],
            lessonId=task["lessonId"],
            status=current_status,
            message="Tác vụ đang trong tiến trình xử lý, chưa hoàn thành."
        )


if __name__ == "__main__":
    import uvicorn
    port = int(os.environ.get("PORT", 8000))
    logger.info("Khởi động EduSphere AI FastAPI Service trên cổng %d...", port)
    uvicorn.run("app:app", host="0.0.0.0", port=port, reload=False)
