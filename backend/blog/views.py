# blog/views.py
from rest_framework import viewsets
from .models import Post
from .serializers import PostSerializer

class PostViewSet(viewsets.ModelViewSet):
    """
    CRUD for blog posts.
    """
    queryset         = Post.objects.all().order_by("-created_at")
    serializer_class = PostSerializer
