# blog/tests.py
from django.test import TestCase
from django.urls import reverse
from rest_framework import status
from rest_framework.test import APIClient
from .models import Post

class PostAPITest(TestCase):
    def setUp(self):
        self.client = APIClient()
        Post.objects.create(title="First", content="Hello world")
        Post.objects.create(title="Second", content="Another post")

    def test_list_posts(self):
        url = reverse("post-list")
        resp = self.client.get(url)
        self.assertEqual(resp.status_code, status.HTTP_200_OK)
        self.assertEqual(len(resp.data["results"]), 2)

    def test_create_post(self):
        url = reverse("post-list")
        data = {"title": "New", "content": "New content"}
        resp = self.client.post(url, data, format="json")
        self.assertEqual(resp.status_code, status.HTTP_201_CREATED)
        self.assertEqual(Post.objects.count(), 3)
