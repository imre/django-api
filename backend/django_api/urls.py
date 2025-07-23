# backend/django_api/urls.py
from django.conf import settings
from django.conf.urls.static import static
from django.contrib import admin
from django.urls import path, include
from rest_framework.authtoken.views import obtain_auth_token

admin.site.site_header = "Django API Portal"
admin.site.site_title = "Django API Portal"
admin.site.index_title = "Welcome to the Django API Portal"
admin.site.site_url = None

urlpatterns = [
    path("admin/", admin.site.urls),

    path("api-token-auth/", obtain_auth_token, name="api_token_auth"),

    path('api/blog/', include('blog.urls')),
]

if settings.DEBUG and settings.MEDIA_URL and settings.MEDIA_ROOT:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
