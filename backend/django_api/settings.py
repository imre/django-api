# django_api/settings.py
from pathlib import Path
from dotenv import load_dotenv
import os
import sentry_sdk
from sentry_sdk.integrations.django import DjangoIntegration

# Load .env & init Sentry
load_dotenv()

# Add Sentry (optional)
# sentry_sdk.init(
#     dsn=os.environ.get("SENTRY_DSN"),
#     integrations=[DjangoIntegration()],
#     traces_sample_rate=0.2,
#     send_default_pii=True,
# )

# Paths
BASE_DIR = Path(__file__).resolve().parent.parent

# Security & Debug
SECRET_KEY = os.environ["SECRET_KEY"]
DEBUG      = os.environ.get("DEBUG", "1") == "1"
ALLOWED_HOSTS = os.environ.get("DJANGO_ALLOWED_HOSTS", "127.0.0.1").split(" ")

# Trust Azure’s front‑end if you deploy there (optional)
CSRF_TRUSTED_ORIGINS = [f"https://{h}" for h in ALLOWED_HOSTS]

if not DEBUG:
    SECURE_PROXY_SSL_HEADER = ("HTTP_X_FORWARDED_PROTO", "https")
    SESSION_COOKIE_SECURE   = True
    CSRF_COOKIE_SECURE      = True

# Installed apps
INSTALLED_APPS = [
    # Translation
    "modeltranslation",

    # REST
    "rest_framework",
    "rest_framework.authtoken",
    "django_filters",

    # Django core
    "django.contrib.admin",
    "django.contrib.auth",
    "django.contrib.contenttypes",
    "django.contrib.sessions",
    "django.contrib.messages",
    "django.contrib.staticfiles",
    "django.contrib.postgres",

    # Your app
    "blog.apps.BlogConfig",
]

# Middleware
MIDDLEWARE = [
    "django.middleware.security.SecurityMiddleware",
    "whitenoise.middleware.WhiteNoiseMiddleware",          # static files
    "django.contrib.sessions.middleware.SessionMiddleware",
    "django.middleware.locale.LocaleMiddleware",           # i18n
    "django.middleware.common.CommonMiddleware",
    "django.middleware.csrf.CsrfViewMiddleware",
    "django.contrib.auth.middleware.AuthenticationMiddleware",
    "django.contrib.messages.middleware.MessageMiddleware",
    "django.middleware.clickjacking.XFrameOptionsMiddleware",
]

# URL / Templates / WSGI
ROOT_URLCONF = "django_api.urls"

TEMPLATES = [
    {
        "BACKEND": "django.template.backends.django.DjangoTemplates",
        "DIRS": [],
        "APP_DIRS": True,
        "OPTIONS": {
            "context_processors": [
                "django.template.context_processors.debug",
                "django.template.context_processors.request",
                "django.contrib.auth.context_processors.auth",
                "django.contrib.messages.context_processors.messages",
            ],
        },
    },
]

WSGI_APPLICATION = "django_api.wsgi.application"
ASGI_APPLICATION = "django_api.asgi.application"

# Require SSL in production for the database
db_options = {}
if not DEBUG:
    db_options["sslmode"] = "require"

# Database (PostgreSQL)
DATABASES = {
    "default": {
        "ENGINE":   os.environ.get("DB_ENGINE",   "django.db.backends.postgresql"),
        "NAME":     os.environ["DB_NAME"],
        "USER":     os.environ["DB_USER"],
        "PASSWORD": os.environ["DB_PASSWORD"],
        "HOST":     os.environ["DB_HOST"],
        "PORT":     os.environ.get("DB_PORT", "5432"),
        "OPTIONS":  db_options,
    }
}

# Password validation
AUTH_PASSWORD_VALIDATORS = [
    {"NAME": "django.contrib.auth.password_validation.UserAttributeSimilarityValidator",},
    {"NAME": "django.contrib.auth.password_validation.MinimumLengthValidator",},
    {"NAME": "django.contrib.auth.password_validation.CommonPasswordValidator",},
    {"NAME": "django.contrib.auth.password_validation.NumericPasswordValidator",},
]

# Internationalisation & Translations
LANGUAGES = [
    ("en", "English"),
    ("ar", "Arabic"),
    ("fr", "French"),
]

# django-modeltranslation  
MODELTRANSLATION_DEFAULT_LANGUAGE = "en"
MODELTRANSLATION_LANGUAGES       = [code for code, _ in LANGUAGES]

LANGUAGE_CODE = "en-gb"
TIME_ZONE     = "UTC"
USE_I18N      = True
USE_L10N      = True
USE_TZ        = True

# Static & Media files
STATIC_URL   = "/static/"
STATIC_ROOT  = BASE_DIR / "staticfiles"

MEDIA_URL    = "/media/"
MEDIA_ROOT   = BASE_DIR / "media"

# WhiteNoise settings
STATICFILES_STORAGE = "whitenoise.storage.CompressedManifestStaticFilesStorage"

# REST Framework
REST_FRAMEWORK = {
    "DEFAULT_AUTHENTICATION_CLASSES": [
        "rest_framework.authentication.TokenAuthentication",
    ],
    "DEFAULT_PERMISSION_CLASSES": [
        "rest_framework.permissions.AllowAny",
    ],
    "DEFAULT_FILTER_BACKENDS": [
        "django_filters.rest_framework.DjangoFilterBackend",
        "rest_framework.filters.SearchFilter",
        "rest_framework.filters.OrderingFilter",
    ],
    "DEFAULT_PAGINATION_CLASS": "rest_framework.pagination.PageNumberPagination",
    "PAGE_SIZE": 10,
}

# Default primary key field type
DEFAULT_AUTO_FIELD = "django.db.models.BigAutoField"
