from django.apps import AppConfig

class BlogConfig(AppConfig):
    name = "blog"

    def ready(self):
        # only import your translation module here:
        import blog.translation
