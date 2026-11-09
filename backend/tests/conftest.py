import pytest
from rest_framework.test import APIClient


@pytest.fixture
def api():
    return APIClient()


@pytest.fixture
def make_item(db):
    from collection.models import Item

    def _make(**kwargs):
        data = {
            "name": "テスト商品",
            "category": "カードゲーム",
            "purchase_price": "1000",
            "purchase_date": "2026-01-10",
            "condition": "新品",
        }
        data.update(kwargs)
        return Item.objects.create(**data)

    return _make
