#!/bin/sh
# Exit immediately if any command returns a non-zero status
set -e

# Notify that we are waiting for the database to be reachable
echo "Waiting for PostgreSQL..."
# Repeat until the Postgres host/port is accepting connections
while ! nc -z "$DB_HOST" "$DB_PORT"; do
  # Pause briefly before trying again
  sleep 0.1
done

# Once the loop exits, the database is up
echo "PostgreSQL started"

# Collect all static files into STATIC_ROOT (no interactive prompts)
echo "Collecting static files..."
python manage.py collectstatic --no-input

# Apply any outstanding migrations to bring the database schema up to date
echo "Applying database migrations..."
python manage.py migrate

# If superuser credentials have been provided via environment variables…
if [ -n "$DJANGO_SUPERUSER_USERNAME" ] && \
   [ -n "$DJANGO_SUPERUSER_EMAIL" ]    && \
   [ -n "$DJANGO_SUPERUSER_PASSWORD" ]; then

  # …ensure a superuser with those credentials exists
  echo "Ensuring Django superuser exists…"
  python manage.py shell <<EOF
from django.contrib.auth import get_user_model
User = get_user_model()
u = "${DJANGO_SUPERUSER_USERNAME}"
e = "${DJANGO_SUPERUSER_EMAIL}"
p = "${DJANGO_SUPERUSER_PASSWORD}"
# Create the superuser only if one with the same username doesn’t already exist
if not User.objects.filter(username=u).exists():
    User.objects.create_superuser(username=u, email=e, password=p)
EOF
fi

# Finally, hand over execution to the command specified in the Dockerfile/CMD
exec "$@"
