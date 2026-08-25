# Dockerfile

# استخدم صورة Python الرسمية
FROM python:3.11-slim

# أنشئ مجلد داخل الحاوية
WORKDIR /app

# انسخ كل الملفات
COPY . .

# ثبّت مكتبة websockets
RUN pip install --no-cache-dir websockets

# شغّل الخادم عند بدء الحاوية
CMD ["python3", "/app/server.py"]