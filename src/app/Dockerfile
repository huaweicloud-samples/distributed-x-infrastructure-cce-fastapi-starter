FROM python:3.12-slim

WORKDIR /app

RUN useradd -r -s /bin/false appuser

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY hello-world.py .

USER appuser

EXPOSE 8000

CMD ["uvicorn", "hello-world:app", "--host", "0.0.0.0", "--port", "8000"]
