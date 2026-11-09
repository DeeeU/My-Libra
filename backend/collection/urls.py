from django.urls import include, path
from rest_framework.routers import DefaultRouter

from . import views

router = DefaultRouter()
router.register("categories", views.CategoryViewSet, basename="category")
router.register("wishlist", views.WishlistItemViewSet, basename="wishlist")
router.register("items", views.ItemViewSet, basename="item")

urlpatterns = [
    path("stats/summary/", views.stats_summary, name="stats-summary"),
    path("", include(router.urls)),
]
