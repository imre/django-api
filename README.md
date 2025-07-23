# Django API Template

A clean, production-ready Django API boilerplate powered by Docker, PostgreSQL, and localisation support.

This project is designed as a starting point for RESTful backend APIs, making it easy to build, extend, and deploy to Azure via [Terraform](https://developer.hashicorp.com/terraform).

## Features

- **Django 4+** with optional PostGIS backend support
- **Docker Compose** for isolated, repeatable environments
- **Multi-language support** via `django-modeltranslation`
- **Admin UI** pre-configured and styled
- **Token-based authentication** (`rest_framework.authtoken`)
- **REST API tooling** with Django REST Framework
- Ready for **media handling**, **static file collection**, and **deployment**

## Getting Started

### 1. Clone the repo

```bash
git clone https://github.com/imre/django-api.git
cd django-api
````

### 2. Set up environment variables

Copy `.env.example` to `.env` and adjust values as needed:

```bash
cp .env.example .env
```

This file is used by both Django and Docker Compose.

### 3. Build and run locally with Docker

```bash
docker-compose up --build -d
```

This will start:

* `api`: Django backend
* `db`: PostgreSQL with PostGIS

You can now access:

* Django Admin: [http://localhost:8000/admin](http://localhost:8000/admin)

### 4. Apply migrations & create a superuser

```bash
docker-compose exec api python manage.py makemigrations
docker-compose exec api python manage.py migrate
docker-compose exec api python manage.py createsuperuser
```

## Localisation

The project uses `django-modeltranslation` to handle multilingual content.

You’ll see fields like:

```
Title [en]:
Title [ar]:
Title [fr]:
```

These are auto-generated and hooked into the admin interface. Add translations as needed in the `settings.py` file.

## Development Notes

* All backend code lives under `/backend`
* Media is stored in `/media`
* Static files are collected into `/staticfiles` via `WhiteNoise`
* Logs output to Docker console

## API Preview

Authentication via Token:

```http
POST /api-token-auth/
```

Blog endpoint (example model):

```http
GET /api/posts/
```

## Deployment

This template is deployment-ready. For production:

* Use Gunicorn or Uvicorn
* Connect to external Postgres (Azure, AWS RDS, etc)
* Set `DEBUG=0` (0 = False)
* Use `django-environ` for environment settings if scaling further

## Why Use This?

This is not a bloated monolith. It’s built for speed, clarity, and actual use:

* **Start fast** with sensible defaults
* **Scale up** cleanly with migrations, Docker, and localisation
* **Avoid framework lock-in** swap pieces as needed, Django APIs can be used with your framework of chocie.

## License

MIT, do what you want, but give credit.  
See License file for more information.

## Author

Created by [Imre Draskovits](https://imre.app), designed to be pragmatic, durable, and usable from day one.  
Feel free to contact me or open an issue if you have any questions getting started.   
