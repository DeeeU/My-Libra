from django.db import transaction
from django.db.models import Q
from django.utils import timezone
from rest_framework import status, viewsets
from rest_framework.decorators import action, api_view
from rest_framework.exceptions import ValidationError
from rest_framework.response import Response

from .models import Category, Item, ItemStatus, WishlistItem
from .serializers import (
    CategorySerializer,
    ItemSerializer,
    PurchaseSerializer,
    SellSerializer,
    WishlistItemSerializer,
)
from .stats import PERIODS, build_summary

ITEM_ORDERING = {"purchase_date", "-purchase_date", "purchase_price", "-purchase_price", "name", "-name"}


class CategoryViewSet(viewsets.ModelViewSet):
    queryset = Category.objects.all()
    serializer_class = CategorySerializer

    def perform_create(self, serializer):
        last = Category.objects.order_by("-sort_order").first()
        serializer.save(is_custom=True, sort_order=(last.sort_order + 1) if last else 0)

    def destroy(self, request, *args, **kwargs):
        if not self.get_object().is_custom:
            return Response({"detail": "プリセットカテゴリーは削除できません。"}, status=status.HTTP_400_BAD_REQUEST)
        return super().destroy(request, *args, **kwargs)


class WishlistItemViewSet(viewsets.ModelViewSet):
    serializer_class = WishlistItemSerializer

    def get_queryset(self):
        qs = WishlistItem.objects.all()
        params = self.request.query_params
        # 一覧では購入済みを隠す（詳細・購入アクションでは対象にする）
        if self.action == "list" and params.get("include_purchased") != "true":
            qs = qs.filter(is_purchased=False)
        if category := params.get("category"):
            qs = qs.filter(category=category)
        if search := params.get("search"):
            qs = qs.filter(Q(name__icontains=search) | Q(memo__icontains=search))
        return qs

    @action(detail=True, methods=["post"])
    def purchase(self, request, pk=None):
        """買い物リストのアイテムを保有品に変換する"""
        wishlist_item = self.get_object()
        if wishlist_item.is_purchased:
            return Response({"detail": "すでに購入済みです。"}, status=status.HTTP_400_BAD_REQUEST)
        serializer = PurchaseSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        with transaction.atomic():
            item = Item.objects.create(
                name=wishlist_item.name,
                category=wishlist_item.category,
                memo=serializer.validated_data["memo"] or wishlist_item.memo,
                purchase_price=serializer.validated_data["purchase_price"],
                purchase_date=serializer.validated_data["purchase_date"],
                condition=serializer.validated_data["condition"],
            )
            wishlist_item.is_purchased = True
            wishlist_item.save(update_fields=["is_purchased", "updated_at"])
        return Response(ItemSerializer(item).data, status=status.HTTP_201_CREATED)


class ItemViewSet(viewsets.ModelViewSet):
    serializer_class = ItemSerializer

    def get_queryset(self):
        qs = Item.objects.all()
        params = self.request.query_params
        if item_status := params.get("status"):
            if item_status not in ItemStatus.values:
                raise ValidationError({"status": f"{', '.join(ItemStatus.values)} のいずれかを指定してください。"})
            qs = qs.filter(status=item_status)
        if category := params.get("category"):
            qs = qs.filter(category=category)
        if condition := params.get("condition"):
            qs = qs.filter(condition=condition)
        if search := params.get("search"):
            qs = qs.filter(Q(name__icontains=search) | Q(memo__icontains=search))
        if ordering := params.get("ordering"):
            if ordering not in ITEM_ORDERING:
                raise ValidationError({"ordering": f"{', '.join(sorted(ITEM_ORDERING))} のいずれかを指定してください。"})
            qs = qs.order_by(ordering, "-created_at")
        return qs

    @action(detail=True, methods=["post"])
    def sell(self, request, pk=None):
        """売却を記録する（損益は自動計算）"""
        item = self.get_object()
        serializer = SellSerializer(data=request.data, context={"item": item})
        serializer.is_valid(raise_exception=True)
        item.mark_as_sold(serializer.validated_data["sale_price"], serializer.validated_data["sale_date"])
        item.save()
        return Response(ItemSerializer(item).data)

    @action(detail=True, methods=["post"])
    def unsell(self, request, pk=None):
        """売却記録を取り消して保有中に戻す"""
        item = self.get_object()
        item.sale_price = None
        item.sale_date = None
        item.status = ItemStatus.OWNED
        item.save()
        return Response(ItemSerializer(item).data)


@api_view(["GET"])
def stats_summary(request):
    period = request.query_params.get("period", "all")
    if period not in PERIODS:
        return Response(
            {"period": f"{', '.join(PERIODS)} のいずれかを指定してください。"},
            status=status.HTTP_400_BAD_REQUEST,
        )
    return Response(build_summary(period, timezone.localdate()))
