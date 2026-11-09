import pytest

from collection.models import Category, Item, WishlistItem

pytestmark = pytest.mark.django_db


def test_presets_are_seeded(api):
    res = api.get("/api/categories/")
    names = [c["name"] for c in res.data]
    assert names[:3] == ["カードゲーム", "靴・スニーカー", "フィギュア"]
    assert len(names) == 7
    assert all(not c["is_custom"] for c in res.data)


def test_custom_category_crud(api):
    res = api.post("/api/categories/", {"name": "トレカ用品", "icon_name": "tag"}, format="json")
    assert res.status_code == 201
    assert res.data["is_custom"] is True
    assert res.data["sort_order"] == 7
    assert api.post("/api/categories/", {"name": "トレカ用品", "icon_name": "tag"}, format="json").status_code == 400
    assert api.delete(f"/api/categories/{res.data['id']}/").status_code == 204


def test_preset_category_cannot_be_deleted(api):
    preset = Category.objects.get(name="ゲーム")
    assert api.delete(f"/api/categories/{preset.id}/").status_code == 400
    assert Category.objects.filter(pk=preset.pk).exists()


def test_wishlist_purchase_creates_item(api):
    w = WishlistItem.objects.create(name="新弾BOX", category="カードゲーム", estimated_price=5000, memo="予約")
    res = api.post(
        f"/api/wishlist/{w.id}/purchase/",
        {"purchase_price": 5500, "purchase_date": "2026-03-01", "condition": "新品"},
        format="json",
    )
    assert res.status_code == 201, res.data
    item = Item.objects.get()
    assert item.name == "新弾BOX"
    assert item.memo == "予約"
    w.refresh_from_db()
    assert w.is_purchased
    # 購入済みは一覧から消え、二重購入はできない
    assert api.get("/api/wishlist/").data == []
    assert len(api.get("/api/wishlist/", {"include_purchased": "true"}).data) == 1
    assert api.post(
        f"/api/wishlist/{w.id}/purchase/", {"purchase_price": 1, "condition": "新品"}, format="json"
    ).status_code == 400


def test_wishlist_purchase_validation(api):
    w = WishlistItem.objects.create(name="X", category="ゲーム")
    res = api.post(f"/api/wishlist/{w.id}/purchase/", {"purchase_price": -1, "condition": "新品"}, format="json")
    assert res.status_code == 400
    assert not Item.objects.exists()
