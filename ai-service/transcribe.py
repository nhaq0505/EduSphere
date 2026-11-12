
from faster_whisper import WhisperModel
import os

AUDIO_FILE = r"D:\3. Ghi chú trong java - tự học lập trình java cơ bản new tutorial - YouTube.mp3"
OUTPUT_FILE = "transcript.txt"


def transcribe_audio():
    if not os.path.exists(AUDIO_FILE):
        print("Khong tim thay file MP3!")
        return

    print("Dang tai mo hinh Whisper...")

    model = WhisperModel(
        "small",
        device="cpu",
        compute_type="int8"
    )

    print("Bat dau chuyen giong noi thanh van ban...")

    segments, info = model.transcribe(
        AUDIO_FILE,
        language="vi",
        beam_size=5,
        vad_filter=True
    )

    print("Ngon ngu:", info.language)
    print("Thoi luong:", round(info.duration, 2), "giay")

    with open(OUTPUT_FILE, "w", encoding="utf-8") as f:
        for segment in segments:
            line = f"[{segment.start:.2f}s - {segment.end:.2f}s] {segment.text}"
            print(line)
            f.write(line + "\n")

    print("\nHOAN THANH!")
    print("File ket qua:", os.path.abspath(OUTPUT_FILE))


if __name__ == "__main__":
    transcribe_audio()
