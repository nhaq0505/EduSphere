@echo off
chcp 65001 > nul
title EDUSPHERE AI - CHIA SẺ DỊCH VỤ CHO NHÓM (CLOUDFLARE TUNNEL)
echo ======================================================================
echo       EDUSPHERE AI - CHIA SẺ DỊCH VỤ RA INTERNET CHO NHÓM DÙNG CHUNG
echo ======================================================================
echo.
echo [1] Đảm bảo Dịch vụ AI (run_server.bat) đang chạy ở cổng 8000!
echo [2] Đang tạo đường dẫn Public HTTPS miễn phí (Cloudflare Quick Tunnel)...
echo.
echo ======================================================================
echo  HÃY TÌM DÒNG CÓ ĐỊNH DẠNG:
echo    https://xxxxxxxxxxxxxx.trycloudflare.com
echo.
echo  SAU ĐÓ GỬI LINK ĐÓ CHO CÁC BẠN TRONG NHÓM!
echo  Các bạn trong nhóm chỉ cần mở file application.properties và đổi:
echo    ai.service.base-url=https://xxxxxxxxxxxxxx.trycloudflare.com
echo ======================================================================
echo.
if exist "%~dp0cloudflared.exe" (
    "%~dp0cloudflared.exe" tunnel --url http://localhost:8000
) else if exist "D:\EduSphere-AI\cloudflared.exe" (
    "D:\EduSphere-AI\cloudflared.exe" tunnel --url http://localhost:8000
) else (
    echo Chưa tìm thấy cloudflared.exe! Vui lòng tải từ https://github.com/cloudflare/cloudflared/releases
)
pause
