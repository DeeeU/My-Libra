"""損益の集計。

iOS 版の StatisticsViewModel と同じ考え方で集計する:
- 期間は「購入日」で絞り込む
- 月別の購入額は購入月、月別の損益は売却月で集計する
"""

from collections import defaultdict
from datetime import date
from decimal import Decimal

from .models import Item, ItemStatus

PERIODS = ("this_month", "3_months", "6_months", "this_year", "all")


def subtract_months(d: date, months: int) -> date:
    month_index = d.year * 12 + (d.month - 1) - months
    year, month = divmod(month_index, 12)
    month += 1
    # 月末日の調整（例: 5/31 の3ヶ月前 → 2/28）
    for day in (d.day, 30, 29, 28):
        try:
            return date(year, month, day)
        except ValueError:
            continue
    raise ValueError("invalid date")


def period_start(period: str, today: date) -> date | None:
    if period == "this_month":
        return today.replace(day=1)
    if period == "3_months":
        return subtract_months(today, 3)
    if period == "6_months":
        return subtract_months(today, 6)
    if period == "this_year":
        return today.replace(month=1, day=1)
    if period == "all":
        return None
    raise ValueError(f"unknown period: {period}")


def month_key(d: date) -> str:
    return f"{d.year:04d}-{d.month:02d}"


def build_summary(period: str, today: date) -> dict:
    start = period_start(period, today)
    items = Item.objects.all()
    if start is not None:
        items = items.filter(purchase_date__gte=start)
    items = list(items)

    total_purchase = sum((i.purchase_price for i in items), Decimal("0"))
    sold = [i for i in items if i.sale_price is not None]
    total_sale = sum((i.sale_price for i in sold), Decimal("0"))
    total_profit = sum((i.profit for i in sold), Decimal("0"))

    by_category: dict[str, Decimal] = defaultdict(Decimal)
    for i in items:
        by_category[i.category] += i.purchase_price

    monthly: dict[str, dict[str, Decimal]] = defaultdict(lambda: {"purchase": Decimal("0"), "profit": Decimal("0")})
    for i in items:
        monthly[month_key(i.purchase_date)]["purchase"] += i.purchase_price
        if i.sale_date is not None and i.profit is not None:
            monthly[month_key(i.sale_date)]["profit"] += i.profit

    return {
        "period": period,
        "start_date": start.isoformat() if start else None,
        "total_purchase": total_purchase,
        "total_sale": total_sale,
        "total_profit": total_profit,
        "owned_count": sum(1 for i in items if i.status == ItemStatus.OWNED),
        "sold_count": sum(1 for i in items if i.status == ItemStatus.SOLD),
        "by_category": [
            {"category": name, "amount": amount}
            for name, amount in sorted(by_category.items(), key=lambda kv: kv[1], reverse=True)
        ],
        "monthly": [
            {"month": key, "purchase": v["purchase"], "profit": v["profit"]}
            for key, v in sorted(monthly.items())
        ],
    }
