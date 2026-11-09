from django.db import migrations

# iOS 版 Category.presetCategories と同じ内容
PRESET_CATEGORIES = [
    ("カードゲーム", "rectangle.portrait.on.rectangle.portrait"),
    ("靴・スニーカー", "shoe"),
    ("フィギュア", "figure.stand"),
    ("本・漫画", "book"),
    ("ゲーム", "gamecontroller"),
    ("電子機器", "iphone"),
    ("その他", "cube.box"),
]


def create_presets(apps, schema_editor):
    Category = apps.get_model("collection", "Category")
    for order, (name, icon) in enumerate(PRESET_CATEGORIES):
        Category.objects.get_or_create(
            name=name, defaults={"icon_name": icon, "is_custom": False, "sort_order": order}
        )


def remove_presets(apps, schema_editor):
    Category = apps.get_model("collection", "Category")
    Category.objects.filter(is_custom=False, name__in=[n for n, _ in PRESET_CATEGORIES]).delete()


class Migration(migrations.Migration):
    dependencies = [("collection", "0001_initial")]
    operations = [migrations.RunPython(create_presets, remove_presets)]
