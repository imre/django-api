# blog/admin.py
from django.contrib import admin
from modeltranslation.admin import TabbedTranslationAdmin
from .models import Post

@admin.register(Post)
class PostAdmin(TabbedTranslationAdmin, admin.ModelAdmin):
    """
    TabbedTranslationAdmin will render your translated fields
    in separate tabs per language, instead of ugly flat suffixes.
    """
    list_display    = ('title', 'created_at', 'updated_at')
    readonly_fields = ('created_at', 'updated_at')
