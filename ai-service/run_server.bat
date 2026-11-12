@echo off
chcp 65001 > nul
echo ========================================================
echo       KHỞI ĐỘNG EDUSPHERE AI FASTAPI SERVICE (PORT 8000)
echo ========================================================
cd /d "%~dp0"
call "%~dp0venv\Scripts\activate.bat"
python -m uvicorn app:app --host 0.0.0.0 --port 8000

