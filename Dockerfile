FROM python:3.12-slim-bookworm
ENV PYTHONUNBUFFERED=1
WORKDIR /app
RUN useradd --uid 10001 --create-home app
COPY app/app.py .
USER app
EXPOSE 5000
CMD ["python", "app.py"]
