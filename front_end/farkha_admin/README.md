# Farkha Admin — لوحة تحكم Farkha

لوحة تحكم Flutter (ويب/سطح المكتب) لإدارة محتوى وبيانات تطبيق Farkha. مبنية على نفس الـ Backend (PHP REST API + MySQL).

> **Version:** 3.0.0+3 · **Flutter:** 3.4.4+ · **Dart:** 3.4.4+ · **Locale:** ar (RTL) · **Theme:** Dark

---

## نظرة عامة

`farkha_admin` هي الواجهة الإدارية المنفصلة عن تطبيق المستخدم النهائي (`farkha_app`). تتيح للأدمن:

- إدارة المستخدمين والأجهزة وحذف الحسابات
- نشر وتحديث المقالات الزراعية
- إدخال أسعار السوق اليومية
- متابعة الدورات وردود فعل المستخدمين (`cycle_feedbacks`, `app_reviews`)
- إرسال إشعارات Push مستهدفة (Firebase Messaging)
- التحكم في Remote Config
- مراجعة سجل التدقيق (audit log) وإحصائيات استخدام الأدوات
- إدارة حسابات الأدمن (دور `superadmin` / `admin` / `readonly`)

---

## الميزات

### Dashboard
- نظرة عامة على الأرقام الكلّية (مستخدمين، دورات، مقالات…) عبر `admin/dashboard/overview.php`
- مخطّطات بيانية بـ `fl_chart`

### المستخدمون والأجهزة
- قائمة المستخدمين + تفاصيل + حذف نهائي
- إرسال إشعار لمستخدم محدّد
- استعراض `user_devices` ومعرفة منصّة كل جهاز

### المحتوى
- مقالات: إضافة وتحديث
- الأسعار: إدخال أسعار اليوم، تعديل، حذف
- الفئات والأنواع الرئيسية

### المراجعات
- `app_reviews`: تقييمات التطبيق + إمكانية تمييز "Starred"
- `cycle_feedbacks`: تقييم نهاية الدورة

### الإشعارات و Remote Config
- إرسال إشعارات مستهدفة عبر Topic أو Token
- إدارة قالب Remote Config

### الإدارة
- إدارة حسابات الأدمن (CRUD + أدوار)
- سجل تدقيق (`admin_audit_log`)
- صلاحيات النظام والإعدادات العامة

---

## Tech Stack

| الفئة | الحزمة |
|------|--------|
| State Management | `get: ^4.7.2` (GetX) |
| Routing | `GetMaterialApp` + `AppPages` |
| HTTP | `http: ^1.2.2` (مغلّفة في `core/api/admin_api.dart`) |
| Local Storage | `shared_preferences: ^2.3.0` |
| Env | `flutter_dotenv: ^5.2.1` |
| Charts | `fl_chart: ^0.69.0` |
| Tables | `data_table_2: ^2.5.15` |
| Markdown | `flutter_markdown: ^0.7.4` + `markdown: ^7.2.2` |
| Localization | `intl: ^0.20.0` |
| Fonts | Cairo |

---

## هيكل المشروع

```
farkha/
├── front_end/farkha_app/     ← تطبيق المستخدم النهائي
├── front_end/farkha_admin/   ← هذا المشروع
└── backend_farkha/           ← PHP REST API + MySQL (MAMP)
```

### lib/

```
lib/
├── main.dart              — FarkhaAdminApp + SplashCheck + AdminApi.isLoggedIn()
├── link_api.dart          — رابط الـ Base URL لـ Backend
├── core/
│   ├── api/               — AdminApi (HTTP wrapper + session)
│   ├── routes/            — AppPages, routes
│   ├── theme/             — AppTheme (Dark)
│   └── widgets/           — widgets مشتركة
└── features/
    ├── admins/            — إدارة حسابات الأدمن
    ├── articles/          — المقالات
    ├── auth/              — تسجيل الدخول
    ├── categories/        — الفئات
    ├── cycles/            — الدورات
    ├── dashboard/         — لوحة الإحصائيات
    ├── devices/           — أجهزة المستخدمين
    ├── notifications/     — إرسال إشعارات
    ├── prices/            — أسعار السوق
    ├── remote_config/     — Firebase Remote Config
    ├── reviews/           — app_reviews + cycle_feedbacks
    ├── system/            — إعدادات النظام
    ├── todo/              — مهام داخلية
    └── users/             — المستخدمون
```

---

## البدء

### المتطلبات
- Flutter SDK ≥ 3.4.4 (channel stable)
- Dart SDK ≥ 3.4.4
- ملف `.env` في جذر المشروع يحتوي على رابط الـ Backend (انظر `lib/link_api.dart`)
- Backend يعمل على MAMP (راجع `backend_farkha/README.md`)

### التثبيت

```bash
cd front_end/farkha_admin
flutter pub get
```

### ملف `.env`
مُسجَّل كـ asset. ضع فيه روابط الـ API ومفاتيح البيئة (مثل `API_BASE_URL`).

---

## أوامر شائعة

```bash
# تشغيل Web (المستهدف الأساسي للوحة)
flutter run -d chrome

# بناء Web للنشر
flutter build web --release

# تشغيل على Android (اختبار)
flutter run

# الفحص والتنسيق
flutter analyze
dart format lib/

# إعادة بناء الأيقونات
dart run flutter_launcher_icons

# تنظيف
flutter clean && flutter pub get
```

---

## Architecture

- **Feature-first:** كل ميزة في `lib/features/<feature>/` تحتوي على شاشاتها و controllers و models الخاصّة بها
- **State:** GetX (`GetxController` + `GetBuilder` / `Obx`)
- **API Layer:** `core/api/admin_api.dart` يلفّ جميع طلبات HTTP ويُدير الـ session token
- **Theming:** Dark only، RTL forced في `MaterialApp.builder`
- **Routing:** مركزي في `core/routes/app_pages.dart`

### المصادقة
- `POST /admin/auth/login.php` يُرجع token
- يُخزَّن في `shared_preferences`
- يُرفَق في رؤوس الطلبات اللاحقة
- `admin_sessions` table في MySQL يخزن الجلسات (`token_hash`, `expires_at`)
- جلسة محدودة بدور المستخدم (`superadmin` / `admin` / `readonly`)

### Endpoints
كل ميزة في اللوحة تتحدّث مع مجلّد مقابل في `backend_farkha/admin/<feature>/`. مثلاً:
- `features/users/` ↔ `backend_farkha/admin/users/`
- `features/prices/` ↔ `backend_farkha/admin/prices/`

---

## الفرق عن farkha_app

| | farkha_app | farkha_admin |
|---|---|---|
| المنصة المستهدفة | Android + iOS | Web (أساسي) |
| Firebase | Auth/FCM/Crashlytics/Remote Config | لا — يستخدم REST فقط |
| تخزين محلي | `get_storage` | `shared_preferences` |
| الثيم | Light + Dark | Dark only |
| Endpoints | `backend_farkha/app/` | `backend_farkha/admin/` |
| المصادقة | Firebase Auth + OTP | username/password + admin_sessions |

---

## المساهمة

- ابقَ على نمط Feature-first عند إضافة ميزة جديدة
- استخدم `AdminApi` لكل طلبات HTTP — لا تستدعِ `http` مباشرةً
- شغّل `flutter analyze` قبل الـ commit
- تأكّد من توافق RTL لأي شاشة جديدة
- كل endpoint جديد على Backend يجب أن يمرّ بـ `AdminAuth.php` للتحقق من الصلاحيات

---

## License

Private — جميع الحقوق محفوظة.
