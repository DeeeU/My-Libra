from datetime import date
from decimal import Decimal

import pytest

from collection.stats import build_summary, period_start, subtract_months

TODAY = date(2026, 5, 31)


@pytest.mark.parametrize(
    "period,expected",
    [
        ("this_month", date(2026, 5, 1)),
        ("3_months", date(2026, 2, 28)),
        ("6_months", date(2025, 11, 30)),
        ("this_year", date(2026, 1, 1)),
        ("all", None),
    ],
)
def test_period_start(period, expected):
    assert period_start(period, TODAY) == expected


def test_subtract_months_across_year():
    assert subtract_months(date(2026, 1, 15), 2) == date(2025, 11, 15)


@pytest.mark.django_db
def test_summary_totals(make_item):
    make_item(category="カードゲーム", purchase_price=1000, purchase_date=date(2026, 1, 10))
    sold = make_item(category="フィギュア", purchase_price=2000, purchase_date=date(2026, 2, 5))
    sold.mark_as_sold(Decimal("3500"), date(2026, 3, 1))
    sold.save()
    loss = make_item(category="カードゲーム", purchase_price=800, purchase_date=date(2026, 2, 20))
    loss.mark_as_sold(Decimal("500"), date(2026, 3, 15))
    loss.save()

    s = build_summary("all", TODAY)
    assert s["total_purchase"] == Decimal("3800")
    assert s["total_sale"] == Decimal("4000")
    assert s["total_profit"] == Decimal("1200")  # +1500 と -300
    assert s["owned_count"] == 1
    assert s["sold_count"] == 2
    assert s["by_category"] == [
        {"category": "フィギュア", "amount": Decimal("2000")},
        {"category": "カードゲーム", "amount": Decimal("1800")},
    ]
    # 購入額は購入月、損益は売却月に計上
    assert s["monthly"] == [
        {"month": "2026-01", "purchase": Decimal("1000"), "profit": Decimal("0")},
        {"month": "2026-02", "purchase": Decimal("2800"), "profit": Decimal("0")},
        {"month": "2026-03", "purchase": Decimal("0"), "profit": Decimal("1200")},
    ]


@pytest.mark.django_db
def test_summary_filters_by_purchase_date(make_item):
    make_item(purchase_price=1000, purchase_date=date(2025, 12, 1))
    make_item(purchase_price=500, purchase_date=date(2026, 5, 2))
    s = build_summary("this_month", TODAY)
    assert s["total_purchase"] == Decimal("500")
    assert s["owned_count"] == 1
    assert s["start_date"] == "2026-05-01"


@pytest.mark.django_db
def test_summary_empty():
    s = build_summary("all", TODAY)
    assert s["total_purchase"] == 0
    assert s["by_category"] == []
    assert s["monthly"] == []


@pytest.mark.django_db
def test_stats_endpoint(api, make_item):
    make_item(purchase_price=1000)
    res = api.get("/api/stats/summary/", {"period": "all"})
    assert res.status_code == 200
    assert res.data["total_purchase"] == 1000
    assert api.get("/api/stats/summary/", {"period": "decade"}).status_code == 400
