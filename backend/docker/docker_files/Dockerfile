# backend/docker/docker_files/Dockerfile

# Use the official Python slim image
FROM python:3.10-slim-bullseye

# Don’t buffer stdout/stderr, don’t write .pyc files, point GDAL includes
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    CPLUS_INCLUDE_PATH=/usr/include/gdal \
    C_INCLUDE_PATH=/usr/include/gdal \
    PYTHONPATH=/code

# Install OS-level dependencies
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
       build-essential \
       libpq-dev \
       netcat-openbsd \
       gettext \
       gdal-bin \
       libgdal-dev \
       libgeos-dev \
  && rm -rf /var/lib/apt/lists/*

# Set our working directory
WORKDIR /code

# Copy & install Python requirements + Gunicorn
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip \
  && pip install --no-cache-dir -r requirements.txt \
  && pip install --no-cache-dir gunicorn

# Copy the rest of the Django app
COPY . .

# Make our entrypoint script executable
RUN chmod +x /code/docker/entrypoints/entrypoint.sh

# Expose the port Azure App Service uses
EXPOSE 8000

# First wait for the DB and run migrations
ENTRYPOINT ["/code/docker/entrypoints/entrypoint.sh"]

# Then launch Gunicorn
CMD ["gunicorn", "django_api.wsgi:application", "--bind", "0.0.0.0:8000", "--workers", "3"]
