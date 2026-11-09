"""データモデル。

iOS 版（ios/My-Libra/Models）と supabase/migrations/001_initial_schema.sql を元にしている。
condition / status の値は iOS・Supabase と同じ日本語の文字列を使う。
Web 版はローカル単一ユーザー用のため user_id と同期用フィールドは持たない。
"""

import uuid
from decimal import Decimal

from django.db import models


class ItemCondition(models.TextChoices):
    NEW = "新品", "新品"
    USED = "中古", "中古"
    DAMAGED = "傷あり", "傷あり"
    JUNK = "ジャンク", "ジャンク"


class ItemStatus(models.TextChoices):
    OWNED = "保有中", "保有中"
    SOLD = "売却済み", "売却済み"


class TimeStampedModel(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        abstract = True


class Category(TimeStampedModel):
    name = models.CharField(max_length=100, unique=True)
    icon_name = models.CharField(max_length=100)
    is_custom = models.BooleanField(default=True)
    sort_order = models.IntegerField(default=0)

    class Meta:
        ordering = ["sort_order", "name"]

    def __str__(self) -> str:
        return self.name


class WishlistItem(TimeStampedModel):
    name = models.CharField(max_length=200)
    category = models.CharField(max_length=100)
    estimated_price = models.DecimalField(max_digits=12, decimal_places=2, null=True, blank=True)
    memo = models.TextField(blank=True, default="")
    is_purchased = models.BooleanField(default=False)

    class Meta:
        ordering = ["-created_at"]

    def __str__(self) -> str:
        return self.name


class Item(TimeStampedModel):
    name = models.CharField(max_length=200)
    category = models.CharField(max_length=100)
    purchase_price = models.DecimalField(max_digits=12, decimal_places=2)
    purchase_date = models.DateField()
    condition = models.CharField(max_length=10, choices=ItemCondition.choices)
    memo = models.TextField(blank=True, default="")
    status = models.CharField(max_length=10, choices=ItemStatus.choices, default=ItemStatus.OWNED)
    sale_price = models.DecimalField(max_digits=12, decimal_places=2, null=True, blank=True)
    sale_date = models.DateField(null=True, blank=True)

    class Meta:
        ordering = ["-purchase_date", "-created_at"]
        indexes = [models.Index(fields=["status"]), models.Index(fields=["purchase_date"])]

    def __str__(self) -> str:
        return self.name

    @property
    def profit(self) -> Decimal | None:
        """損益 = 売却価格 - 購入価格（未売却なら None）"""
        if self.sale_price is None:
            return None
        return self.sale_price - self.purchase_price

    def mark_as_sold(self, sale_price: Decimal, sale_date) -> None:
        self.sale_price = sale_price
        self.sale_date = sale_date
        self.status = ItemStatus.SOLD
