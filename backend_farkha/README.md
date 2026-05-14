# Farkha Backend — REST API

Backend بلغة PHP يخدم تطبيق `farkha_app` ولوحة التحكم `farkha_admin`. مبني على PHP 8.x + MySQL، يعمل محلّياً على MAMP.

> **PHP:** ≥ 7.4 (يُطوَّر على 8.x) · **MySQL:** 8.0.44 (MAMP) · **Server:** Apache (MAMP) · **DB:** `farkha`

---

## نظرة عامة

`backend_farkha` يقدّم:

- **App API** للتطبيق (`/app/*`): مصادقة، دورات، أسعار، مقالات، أدوات، مراجعات
- **Admin API** للوحة التحكم (`/admin/*`): إدارة المستخدمين والمحتوى والإشعارات
- **Public** صفحات HTML (حذف الحساب، صفحات الخطأ)
- **Analytics** تسجيل استخدام الأدوات
- **Cache** نظام كاش بسيط للأسعار والمقالات المتكرّرة

كل endpoint في ملف PHP منفصل — لا framework. النمط: ملف يستقبل الطلب، يستدعي query/model، يرجع JSON عبر `core/Response.php`.

---

## هيكل المشروع

```
backend_farkha/
├── app/                    — endpoints للتطبيق (farkha_app)
│   ├── auth/               — تسجيل دخول، OTP، تحديث FCM token، حذف حساب
│   ├── cycles/             — إنشاء/إدارة دورات + أعضاء + مدخلات + دعوات
│   ├── prices/             — أسعار السوق (broiler/main_types/history)
│   ├── articles/           — قائمة وتفاصيل المقالات
│   ├── tools/              — أدوات حسابية
│   ├── app_reviews/        — مراجعات التطبيق
│   └── cycle_feedbacks/    — تقييم نهاية الدورة
├── admin/                  — endpoints للوحة التحكم (farkha_admin)
│   ├── auth/               — login / logout / me
│   ├── dashboard/          — overview
│   ├── users/              — قائمة/تفاصيل/حذف/إرسال إشعار
│   ├── articles/           — add / update
│   ├── prices/             — today / add / update / delete
│   ├── reviews/            — app_list / cycle_feedbacks_list / toggle_star
│   ├── admins/             — إدارة حسابات الأدمن
│   ├── notifications/      — إرسال إشعارات Push
│   ├── remote_config/      — إدارة قالب Firebase Remote Config
│   ├── devices/            — أجهزة المستخدمين
│   ├── categories/         — الفئات
│   ├── types/              — الأنواع الرئيسية
│   ├── cycles/             — دورات النظام
│   ├── cache/              — إدارة الكاش
│   ├── db/                 — أدوات قاعدة البيانات
│   ├── audit/              — سجل التدقيق
│   └── logs/               — السجلات
├── core/                   — مكتبات مشتركة
│   ├── BaseApi.php         — أساس endpoints التطبيق
│   ├── AdminBaseApi.php    — أساس endpoints الأدمن
│   ├── Auth.php            — مصادقة المستخدم (Firebase)
│   ├── AdminAuth.php       — مصادقة الأدمن + جلسات
│   ├── Response.php        — JSON responses موحّدة
│   ├── Validator.php       — تحقق من المدخلات
│   ├── RateLimiter.php     — حدّ معدّل الطلبات
│   ├── OtpService.php      — توليد/تحقق OTP
│   ├── WhatsAppService.php — إرسال OTP عبر WhatsApp
│   ├── NotificationService.php — Firebase Messaging wrapper
│   ├── TopicManager.php    — إدارة Topics للإشعارات
│   ├── RemoteConfigService.php — Firebase Remote Config
│   ├── Cache.php           — كاش بسيط
│   ├── I18n.php            — تحميل ملفات الترجمة
│   └── firebase_credentials.json — مفاتيح Firebase Admin SDK
├── models/                 — طبقة البيانات (PDO)
│   ├── UserModel.php
│   ├── CycleModel.php
│   ├── PriceModel.php
│   ├── ArticleModel.php
│   ├── FeedbackModel.php
│   ├── ReviewModel.php
│   └── AnalyticsModel.php
├── config/
│   ├── bootstrap.php       — تحميل البيئة و autoloader
│   ├── cors.php            — رؤوس CORS
│   ├── database.php        — Database singleton + helpers
│   ├── env.php             — تحميل متغيرات البيئة (DB_*, Firebase…)
│   └── firebase.php        — تهيئة Firebase Admin SDK
├── migrations/             — ملفات SQL مع tracker
│   ├── migrate.sh          — أداة تشغيل migrations + تحديث schema.sql
│   ├── schema.sql          — dump كامل (للمرجع)
│   ├── 2026_05_08_full_overhaul.sql
│   ├── 2026_05_09_admin_panel.sql
│   ├── 2026_05_09_users_hard_delete.sql
│   ├── 2026_05_10_review_starred.sql
│   ├── 2026_05_11_user_locale.sql
│   └── rollback_*.sql      — rollback لكل migration
├── analytics/              — record_tools_usage / tools_analytics
├── cache_system/           — cache_manager + cache_storage + clear_cache
├── join/                   — صفحة دعوة الانضمام لدورة
├── lang/                   — ar.php / en.php
├── public/                 — delete-account.html / error.php
├── scripts/                — seed_first_admin / migrate_admin_user
├── admin/                  — (مفصّل أعلاه)
├── vendor/                 — Composer dependencies
└── composer.json           — kreait/firebase-php
```

---

## Tech Stack

- **PHP** ≥ 7.4 (مُطوَّر على 8.x)
- **MySQL** 8.0.44 (MAMP — port 8889)
- **PDO** للاتصال بقاعدة البيانات (انظر `config/database.php`)
- **Composer**:
  - [`kreait/firebase-php`](https://github.com/kreait/firebase-php) ^7.0 — Firebase Admin SDK (Auth, FCM, Remote Config)
- لا framework — kit endpoints + helpers بسيطة

---

## قاعدة البيانات

اسم القاعدة: `farkha`  
الجداول الرئيسية (مستخرَجة من `migrations/schema.sql`):

- `users` — مستخدمو التطبيق
- `user_devices` — أجهزة المستخدم (FCM tokens, platform, locale)
- `admin_users` — حسابات لوحة التحكم (دور: superadmin/admin/readonly)
- `admin_sessions` — جلسات الأدمن (token_hash, expires_at)
- `admin_audit_log` — سجل تدقيق
- `cycles` + `cycle_members` + `cycle_invitations` + `cycle_data` + `cycle_expenses` + `cycle_sales` + `cycle_notes`
- `cycle_feedbacks` — تقييم نهاية الدورة (Spec 004)
- `app_reviews` — مراجعات التطبيق
- `articles` + `categories`
- `prices` (broiler / main_types / history)
- `notifications`
- `tools_analytics`
- `_migrations` — tracker

---

## البدء

### المتطلبات
- MAMP (Apache + MySQL 8 + PHP 8)
- Composer
- مشروع Firebase + ملف Service Account JSON

### الإعداد

```bash
cd backend_farkha
composer install
```

### متغيرات البيئة
انسخ القيم في `config/env.php` أو أنشئ `.env` (حسب التهيئة):
```
DB_DSN=mysql:host=localhost;port=8889;dbname=farkha;charset=utf8mb4
DB_USER=root
DB_PASS=root
FIREBASE_CREDENTIALS=core/firebase_credentials.json
```
بيانات MAMP الافتراضية:
- Host: `localhost`
- Port: `8889`
- User: `root`
- Pass: `root`

### الـ Migrations

```bash
cd migrations
./migrate.sh
```
السكربت:
1. ينشئ جدول `_migrations` إذا لم يكن موجوداً
2. يطبّق ملفات `20*.sql` بالترتيب
3. يحدّث `schema.sql` تلقائياً بعد كل تشغيل

للرجوع عن migration معيّن: شغّل ملف `rollback_*.sql` المقابل يدوياً.

### Seed أوّل أدمن

```bash
php scripts/seed_first_admin.php
```

---

## التشغيل

### عبر MAMP
1. ضع المشروع داخل `/Applications/MAMP/htdocs/` (أو رابط رمزي إليه)
2. شغّل MAMP — Apache على `:8888`, MySQL على `:8889`
3. الـ Base URL يصبح: `http://localhost:8888/backend_farkha/`

### نقاط النهاية الشائعة

```
POST   /app/auth/login.php
POST   /app/auth/send_otp.php
POST   /app/auth/verify_otp.php
GET    /app/articles/list.php
GET    /app/prices/broiler_latest.php
POST   /app/cycles/create.php
POST   /app/cycles/add_data.php

POST   /admin/auth/login.php
GET    /admin/dashboard/overview.php
GET    /admin/users/list.php
POST   /admin/prices/add.php
POST   /admin/notifications/...
```

---

## Architecture

### نمط الطلب
```
Request → cors.php + bootstrap.php
       → BaseApi.php / AdminBaseApi.php (auth + validation + rate limit)
       → Model (PDO query)
       → Response::success() / Response::error()
       → JSON
```

### المصادقة
- **التطبيق:** Firebase ID Token يُتحقَّق منه في `core/Auth.php` عبر `kreait/firebase-php`
- **لوحة الأدمن:** username/password → `admin_sessions` token عشوائي يُخزَّن hash منه في DB

### Rate Limiting
`core/RateLimiter.php` — حدّ بسيط لكل IP/Endpoint (ضدّ إساءة استخدام OTP خاصّة).

### OTP
- `core/OtpService.php` يولّد ويحفظ ويتحقّق من OTP
- التسليم عبر `WhatsAppService.php`

### الكاش
- `core/Cache.php` + `cache_system/cache_manager.php`
- يخزَّن في `cache_system/cache_storage/`
- `cache_system/clear_cache.php` لمسحه

### الإشعارات
- `core/NotificationService.php` يلفّ Firebase Messaging
- `core/TopicManager.php` لإدارة Topics
- جدول `notifications` لحفظ السجلّ

---

## التطوير

### إضافة endpoint جديد
1. أنشئ ملف PHP داخل `app/<feature>/` أو `admin/<feature>/`
2. ابدأ بـ:
   ```php
   require_once __DIR__ . '/../../config/bootstrap.php';
   require_once __DIR__ . '/../../core/BaseApi.php'; // أو AdminBaseApi.php
   ```
3. استخدم `Validator` للمدخلات، `Database::query` أو Model للقاعدة، و`Response` للإرجاع.

### إضافة migration
1. أنشئ `migrations/YYYY_MM_DD_<name>.sql`
2. أنشئ `migrations/rollback_YYYY_MM_DD_<name>.sql`
3. شغّل `./migrate.sh`

### الترجمة
- `lang/ar.php` و `lang/en.php`
- استخدم `I18n::t('key')` داخل endpoints

---

## نشر الإنتاج

> ⚠️ **ملاحظات:**
> - `core/firebase_credentials.json` لا يجب أن يُرفع لمستودع عام
> - راجع `config/cors.php` قبل النشر (افتراضياً مفتوح للتطوير المحلي)
> - فعّل HTTPS — مصادقة الأدمن تعتمد على تمرير token في الرؤوس
> - عيّن `display_errors=Off` و `log_errors=On` في `php.ini`

---

## License

Private — جميع الحقوق محفوظة.
