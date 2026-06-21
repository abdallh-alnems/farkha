# أصول المتاجر — تطبيق فرخة 🐔

كل ما يلزم لرفع تطبيق **فرخة** (إدارة مزارع الدواجن) على Google Play و App Store، في مكان واحد.

- التطبيق: `فرخة` · الحزمة `ni.nims.frkha` · الإصدار `6.4.2`
- الواجهة: **عربية RTL فقط** (خط Cairo)
- سياسة الخصوصية: `https://www.nims-farkha.com/privacy-policy`
- الدعم/الموقع: `https://www.nims-farkha.com`

## 📁 الهيكل

```
store_assets/
├── play_store_assets/        ← Google Play (Android)
│   ├── icon/                  app_icon_512.png
│   ├── feature_graphic/       الرسم المميز 1024×500 (يولّده السكربت)
│   ├── screenshots/           raw/ → phone/ (يولّدها السكربت، 1080×1920)
│   ├── data_safety/           إقرار «أمان البيانات»
│   ├── make_screenshots.py
│   ├── make_feature_graphic.py
│   └── README.md              ← نصوص بطاقة المتجر + التعليمات
└── app_store/                ← App Store (iOS)
    ├── icon/                  app_icon_1024.png
    ├── screenshots/           raw/ → iphone_6_9/ (يولّدها السكربت، 1320×2868)
    ├── make_screenshots.py
    └── README.md              ← نصوص App Store + بيانات المراجعة
```

## ⚙️ تشغيل سكربتات التصميم (مرة واحدة)

```bash
pip3 install pillow arabic-reshaper python-bidi
```

ثم ضع لقطاتك الخام داخل مجلد `screenshots/raw/ar/` لكل متجر، وشغّل السكربت من داخل مجلده.
التفاصيل في `README.md` الخاص بكل متجر.

> ملاحظة: مجلدات `en/` موجودة في الهيكل للتوافق فقط — تطبيق فرخة عربي فقط، لذا اكتفِ بـ `ar/`.
