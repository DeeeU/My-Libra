from datetime import date
from decimal import Decimal

from collection.models import Item, ItemStatus


def test_profit_is_none_until_sold(make_item):
    item = make_item(purchase_price=Decimal("1000"))
    assert item.profit is None


def test_profit_after_sale(make_item):
    item = make_item(purchase_price=Decimal("1000"))
    item.mark_as_sold(Decimal("1500"), date(2026, 2, 1))
    assert item.profit == Decimal("500")
    assert item.status == ItemStatus.SOLD


def test_loss_is_negative(make_item):
    item = make_item(purchase_price=Decimal("1000"))
    item.mark_as_sold(Decimal("300"), date(2026, 2, 1))
    assert item.profit == Decimal("-700")


def test_new_item_is_owned(make_item):
    assert make_item().status == ItemStatus.OWNED
    assert Item.objects.count() == 1
