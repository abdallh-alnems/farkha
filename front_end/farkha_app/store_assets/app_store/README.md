# أصول App Store — تطبيق فرخة 🐔 (iOS)

تطبيق إدارة مزارع الدواجن (bundle `ni.nims.frkha`). iPhone.

## 📁 المحتويات
```
app_store/
├── icon/app_icon_1024.png        ← أيقونة 1024×1024 (بلا شفافية)
├── make_screenshots.py            ← سكربت التأطير
└── screenshots/
    ├── raw/ar/                     ← اللقطات الخام من المحاكي
    ├── iphone_6_9/ar/              ← نهائية 1320×2868 (شاشة 6.9") — يولّدها السكربت
    └── iphone_6_5/ar/              ← نهائية 1284×2778 (شاشة 6.5") إن طلب App Store ذلك
```
8 لقطات: الدورات · تسجيل اليوميات · الأسعار · الأدوات · التحصينات · الأمراض · المقالات · الملاحظات.

## 🛠️ التوليد
```bash
pip3 install pillow arabic-reshaper python-bidi
cd store_assets/app_store
# ضع اللقطات الخام (1320×2868) في screenshots/raw/ar/ بأسماء تحوي:
# cycles / record / prices / tools / vaccination / diseases / articles / notes
python3 make_screenshots.py        # → screenshots/iphone_6_9/ar/
```

## 📝 نصوص App Store
**اسم التطبيق (≤30):** `فرخة لإدارة الدواجن`
**Subtitle (≤30):** `دورات وأسعار وأدوات تسمين`
**Keywords (≤100):**
```
دواجن,فراخ,تسمين,مزرعة,دورة,علف,تحصينات,اسعار,FCR,امراض الطيور,بياض,عنبر
```
**الوصف:** (نفس وصف Google Play في `../play_store_assets/README.md`)

## 🔗 روابط App Store Connect
- Privacy Policy: `https://www.nims-farkha.com/privacy-policy`
- Support URL: `https://www.nims-farkha.com`

## 🔑 بيانات مراجعة (Sign-in)
> ⚠️ يحتاج التطبيق تسجيل دخول. جهّز حساب مراجعة دائماً قبل الإرسال:
- رقم الهاتف: `__________`
- كود التحقق (OTP) للمراجعة: `__________`
```
Sign in with the phone number and verification code above.
This is a permanent reviewer account with sample cycles; all screens are accessible.
```

## ملاحظات
- الواجهة عربية RTL بالكامل (خط Cairo)؛ لا توجد واجهة إنجليزية، لذا اللقطات بالعربية فقط.
- تأكّد أن أيقونة 1024 بلا قناة ألفا/شفافية (مطلب Apple) — المرفقة مأخوذة من `ios/.../AppIcon` ومناسبة.
