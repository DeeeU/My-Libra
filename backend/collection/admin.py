from django.contrib import admin

from .models import Category, Item, WishlistItem

admin.site.register(Category)
admin.site.register(WishlistItem)
admin.site.register(Item)
