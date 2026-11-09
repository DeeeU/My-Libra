import pytest
from django.utils import timezone

from collection.models import Item, ItemStatus

pytestmark = pytest.mark.django_db

VALID = {
    "name": "ピカチュウ プロモ",
    "category": "カードゲーム",
    "purchase_price": 3000,
    "purchase_date": "2026-01-15",
    "condition": "中古",
    "memo": "",
}


def test_create_item(api):
    res = api.post("/api/items/", VALID, format="json")
    assert res.status_code == 201, res.data
    assert res.data["status"] == "保有中"
    assert res.data["profit"] is None
    assert res.data["purchase_price"] == 3000


@pytest.mark.parametrize(
    "field,value",
    [("name", "   "), ("purchase_price", -1), ("condition", "美品"), ("purchase_date", "2999-01-01")],
)
def test_create_item_validation(api, field, value):
    res = api.post("/api/items/", {**VALID, field: value}, format="json")
    assert res.status_code == 400
    assert field in res.data


def test_cannot_set_sale_fields_on_create(api):
    res = api.post("/api/items/", {**VALID, "status": "売却済み", "sale_price": 9999}, format="json")
    assert res.status_code == 201
    assert res.data["status"] == "保有中"
    assert res.data["sale_price"] is None


def test_list_filters_and_search(api, make_item):
    make_item(name="スニーカー A", category="靴・スニーカー")
    sold = make_item(name="カード B")
    sold.mark_as_sold(2000, "2026-02-01")
    sold.save()

    assert len(api.get("/api/items/").data) == 2
    assert [i["name"] for i in api.get("/api/items/", {"status": "保有中"}).data] == ["スニーカー A"]
    assert [i["name"] for i in api.get("/api/items/", {"status": "売却済み"}).data] == ["カード B"]
    assert [i["name"] for i in api.get("/api/items/", {"category": "靴・スニーカー"}).data] == ["スニーカー A"]
    assert [i["name"] for i in api.get("/api/items/", {"search": "カード"}).data] == ["カード B"]


def test_list_ordering(api, make_item):
    make_item(name="B", purchase_price=500)
    make_item(name="A", purchase_price=1500)
    assert [i["name"] for i in api.get("/api/items/", {"ordering": "name"}).data] == ["A", "B"]
    assert [i["name"] for i in api.get("/api/items/", {"ordering": "-purchase_price"}).data] == ["A", "B"]


def test_list_rejects_unknown_params(api):
    assert api.get("/api/items/", {"ordering": "id; DROP"}).status_code == 400
    assert api.get("/api/items/", {"status": "lost"}).status_code == 400


def test_update_item(api, make_item):
    item = make_item()
    res = api.patch(f"/api/items/{item.id}/", {"name": "変更後", "purchase_price": 1200}, format="json")
    assert res.status_code == 200
    item.refresh_from_db()
    assert item.name == "変更後"
    assert item.purchase_price == 1200


def test_cannot_move_purchase_date_after_sale_date(api, make_item):
    item = make_item(purchase_date="2026-01-10")
    api.post(f"/api/items/{item.id}/sell/", {"sale_price": 1500, "sale_date": "2026-01-20"}, format="json")
    res = api.patch(f"/api/items/{item.id}/", {"purchase_date": "2026-01-25"}, format="json")
    assert res.status_code == 400


def test_delete_item(api, make_item):
    item = make_item()
    assert api.delete(f"/api/items/{item.id}/").status_code == 204
    assert not Item.objects.exists()


def test_sell_item_calculates_profit(api, make_item):
    item = make_item(purchase_price=1000)
    res = api.post(f"/api/items/{item.id}/sell/", {"sale_price": 1800, "sale_date": "2026-02-01"}, format="json")
    assert res.status_code == 200, res.data
    assert res.data["status"] == "売却済み"
    assert res.data["profit"] == 800


def test_sell_defaults_to_today(api, make_item):
    item = make_item()
    res = api.post(f"/api/items/{item.id}/sell/", {"sale_price": 500}, format="json")
    assert res.status_code == 200
    assert res.data["sale_date"] == timezone.localdate().isoformat()


@pytest.mark.parametrize(
    "payload",
    [{"sale_price": -5, "sale_date": "2026-02-01"}, {"sale_price": 100, "sale_date": "2025-12-31"}, {}],
)
def test_sell_validation(api, make_item, payload):
    item = make_item(purchase_date="2026-01-10")
    assert api.post(f"/api/items/{item.id}/sell/", payload, format="json").status_code == 400
    item.refresh_from_db()
    assert item.status == ItemStatus.OWNED


def test_unsell(api, make_item):
    item = make_item()
    api.post(f"/api/items/{item.id}/sell/", {"sale_price": 1500, "sale_date": "2026-02-01"}, format="json")
    res = api.post(f"/api/items/{item.id}/unsell/")
    assert res.status_code == 200
    assert res.data["status"] == "保有中"
    assert res.data["sale_price"] is None
    assert res.data["profit"] is None
