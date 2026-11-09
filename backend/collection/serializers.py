from decimal import Decimal

from django.utils import timezone
from rest_framework import serializers

from .models import Category, Item, ItemCondition, WishlistItem

PRICE_FIELD = {"max_digits": 12, "decimal_places": 2, "min_value": Decimal("0")}

def validate_not_future(value):
    if value and value > timezone.localdate():
        raise serializers.ValidationError("未来の日付は指定できません。")
    return value

class CategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = Category
        fields = ["id", "name", "icon_name", "is_custom", "sort_order", "created_at", "updated_at"]
        read_only_fields = ["id", "is_custom", "created_at", "updated_at"]

    def validate_name(self, value: str) -> str:
        value = value.strip()
        if not value:
            raise serializers.ValidationError("カテゴリー名を入力してください。")
        return value

class WishlistItemSerializer(serializers.ModelSerializer):
    estimated_price = serializers.DecimalField(**PRICE_FIELD, required=False, allow_null=True)

    class Meta:
        model = WishlistItem
        fields = ["id", "name", "category", "estimated_price", "memo", "is_purchased", "created_at", "updated_at"]
        read_only_fields = ["id", "is_purchased", "created_at", "updated_at"]

class ItemSerializer(serializers.ModelSerializer):
    purchase_price = serializers.DecimalField(**PRICE_FIELD)
    purchase_date = serializers.DateField(validators=[validate_not_future])
    profit = serializers.DecimalField(max_digits=13, decimal_places=2, read_only=True)

    class Meta:
        model = Item
        fields = [
            "id", "name", "category", "purchase_price", "purchase_date", "condition", "memo",
            "status", "sale_price", "sale_date", "profit", "created_at", "updated_at",
        ]
        # 売却情報は sell / unsell アクションでのみ変更する
        read_only_fields = ["id", "status", "sale_price", "sale_date", "created_at", "updated_at"]

    def validate_name(self, value: str) -> str:
        value = value.strip()
        if not value:
            raise serializers.ValidationError("商品名を入力してください。")
        return value

    def validate(self, attrs):
        purchase_date = attrs.get("purchase_date", getattr(self.instance, "purchase_date", None))
        sale_date = getattr(self.instance, "sale_date", None)
        if purchase_date and sale_date and sale_date < purchase_date:
            raise serializers.ValidationError({"purchase_date": "購入日は売却日より前にしてください。"})
        return attrs

class SellSerializer(serializers.Serializer):
    sale_price = serializers.DecimalField(**PRICE_FIELD)
    sale_date = serializers.DateField(default=timezone.localdate, validators=[validate_not_future])

    def validate(self, attrs):
        item: Item = self.context["item"]
        if attrs["sale_date"] < item.purchase_date:
            raise serializers.ValidationError({"sale_date": "売却日は購入日以降にしてください。"})
        return attrs

class PurchaseSerializer(serializers.Serializer):
    """買い物リストのアイテムを購入済み（保有品）に変換するときの入力"""

    purchase_price = serializers.DecimalField(**PRICE_FIELD)
    purchase_date = serializers.DateField(default=timezone.localdate, validators=[validate_not_future])
    condition = serializers.ChoiceField(choices=ItemCondition.choices)
    memo = serializers.CharField(required=False, allow_blank=True, default="")
