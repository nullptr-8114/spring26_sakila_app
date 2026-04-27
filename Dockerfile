FROM python:3.9-slim

# Maintainer info and metadata
LABEL maintainer="shahm@email.com" \
      version="1.0" \
      description="Sakila Flask Application - Optimized"

# Create a non-root user for security
RUN groupadd -r appuser && useradd -r -g appuser appuser

WORKDIR /app

# Copy requirements FIRST to leverage Docker layer caching
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
# Copy rest of application code
COPY . .

# Set ownership to non-root user
RUN chown -R appuser:appuser /app
USER appuser

# Environment variables (no secrets hardcoded)
ENV MYSQL_HOST=sakila-db-server \
    MYSQL_USER=root \
    MYSQL_DB=sakila

# Only expose the port the app actually needs
EXPOSE 5000

# Health check to verify app is responding
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:5000')" || exit 1

CMD ["python", "app.py"]
