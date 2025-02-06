@echo off
cd /d D:\Nam_4\HealthFoodAI\backend\flask_api
@REM echo [✔] Đang tạo môi trường ảo...
@REM python -m venv venv

echo Environment activated
call venv\Scripts\activate

@REM echo [✔] Đang cài đặt thư viện từ requirements.txt...
@REM pip install -r requirements.txt

echo Server running...
python app.py

pause
