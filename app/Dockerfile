FROM python:3.12-slim AS builder
WORKDIR /build
COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

FROM python:3.12-slim
WORKDIR /app
COPY --from=builder /install /usr/local
COPY server.py .
RUN adduser --disabled-password --gecos "" --uid 1001 appuser \
  && chown -R appuser /app
USER appuser
EXPOSE 8080
ENV PORT=8080
CMD ["python", "server.py"]
