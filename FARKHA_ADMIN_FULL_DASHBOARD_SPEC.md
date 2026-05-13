# Farkha Admin — Full Control Dashboard (مواصفات تنفيذ)

> **الهدف:** تحويل `front_end/farkha_admin` من 4 شاشات بسيطة (أسعار/مقالات/تحليلات/مسح كاش) إلى **لوحة تحكم كاملة** تعطي الأدمن سيطرة شاملة على تطبيق فرخة: عرض الإحصائيات، إدارة المستخدمين والدورات، التحكم في Remote Config (الإصدار الإجباري وغيره)، إرسال الإشعارات، وتعديل قاعدة البيانات بأمان.

> **المخاطب:** هذا الملف موجَّه لنموذج تنفيذ (Claude/Codex/إلخ). نفِّذ كل قسم بالترتيب. كل قسم يحدد ملفات محددة (PATH) ويصف الواجهة المتوقعة (request/response) وقيود الأمان.

---

## 0. الوضع الحالي (snapshot — حقائق مُتحقَّق منها يوم 2026-05-09)

### Backend (`backend_farkha/`)
- **Stack:** PHP 8.x + PDO + MySQL 8.0.44 على MAMP (port 8889، db=`farkha`، user=`root`، pass=`root`).
- **Firebase PHP SDK مثبَّت:** `kreait/firebase-php` متاح بالفعل (in `vendor/`). يدعم Auth، Messaging، **و Remote Config** (`Kreait\Firebase\Contract\RemoteConfig`).
- **Firebase credentials:** `core/firebase_credentials.json` (محمي بـ `.htaccess`).
- **Endpoints أدمن موجودة (تحت `admin/`):**
  - `prices/today.php`, `prices/add.php`, `prices/update.php`, `prices/delete.php`
  - `articles/add.php`, `articles/update.php`
- **Endpoints تحليلات:** `analytics/tools_analytics.php` (تجميع `tools_usage` بفترات: 7days/30days/1year/alltime).
- **Cache system:** `cache_system/clear_cache.php`.
- **Models جاهزة:** `UserModel`, `CycleModel`, `PriceModel`, `ArticleModel`, `AnalyticsModel`, `FeedbackModel`, `ReviewModel`.

### ⚠️ ثغرة أمنية مكتشفة — أولوية حرجة
> الـ Flutter admin بيبعت `Authorization: Basic base64(SECURITY_USER:SECURITY_KEY)` لكن **مفيش أي ملف PHP في `admin/` بيتحقق فعلياً من البيانات دي**. `BaseApi::requireAuth=true` بينده `RateLimiter::enforceIpLimit()` بس — مش `Auth::*`. يعني حالياً أي IP يقدر ينده endpoints الأدمن من غير credentials.
>
> **لازم يتصلَّح في Phase 1 قبل أي feature جديد** (Section 4).

### Admin app الحالي (`front_end/farkha_admin/`)
- Flutter بسيط جداً: `MaterialApp` → `HomeScreen` فيها 3 أزرار + زر مسح كاش.
- **مفيش GetX، مفيش Theme، مفيش Routing، مفيش Models، مفيش State management.**
- Dependencies: `http`, `flutter_dotenv`, `flutter_markdown` بس.
- `.env` فيه: `API_HOST`, `SECURITY_USER`, `SECURITY_KEY`.
- النسخة الحالية: `2.0.0+2`.

### Database — جداول رئيسية (من `migrations/schema.sql`)
| جدول | الصفوف الأخيرة | الغرض |
|---|---|---|
| `users` | AI=225 | المستخدمون (firebase_uid فريد) |
| `user_devices` | AI=25 | FCM tokens (متعدد لكل user) |
| `cycles` | AI=215 | دورات التربية (soft-delete عبر `deleted_at`) |
| `cycle_users` | AI=254 | علاقة user↔cycle + role |
| `cycle_data` | AI=179 | EAV (وزن/نفوق/علف/...) |
| `cycle_expenses` | AI=353 | مصاريف الدورة |
| `cycle_sales` | AI=32 | المبيعات |
| `cycle_inventory` | — | المخزون |
| `cycle_invitations` | AI=7 | دعوات الانضمام |
| `cycle_notes` | AI=5 | ملاحظات |
| `cycle_feedbacks` | AI=9 | تقييمات نهاية الدورة |
| `app_reviews` | AI=21 | تقييمات التطبيق |
| `prices` | AI=891 | الأسعار اليومية |
| `types` | AI=53 | المنتجات |
| `product_categories` | AI=8 | الفئات (لحوم/بياض/علف/...) |
| `articles` | AI=21 | المقالات (soft-delete) |
| `tools_usage` | — | عداد استخدام الأدوات يومياً (PK مركَّب: `usage_date`+`tool_id`) |
| `tools_usage_events` | — | event-level لكل استخدام (`user_id`+`tool_id`+`used_at`) |
| `phone_verifications` | AI=21 | OTP sessions |

### Remote Config — مفاتيح مُستخدَمة في التطبيق
- `min_required_version` (يُقرأ في `lib/core/services/update_service.dart:52`) — لو الإصدار الحالي أقل منه → **force update**.
- التطبيق فيه `setDefaults({'min_required_version': '0.0.0'})` في `initialization.dart:47`.

### الأدوات المعروفة (24 أداة، من `analytics_screen.dart`)
ID 1-24: FCR, ADG, كثافة الفراخ، استهلاك العلف اليومي/الكلي، الوزن حسب العمر، الحرارة، الإضلام، الشفاطات، التحصينات، مقالات، الأمراض، متطلبات تسمين، دراسة جدوى، تكلفة إنتاج/علف/كيلو، الربح، ROI، النفوق، الوزن الإجمالي، الإيرادات، الماء، الطقس.

---

## 1. النطاق (Scope) — ما اللي هيتبني

### 🟢 Core (Phase 1 — لازم)
1. **Admin auth حقيقي** (إصلاح الثغرة).
2. **Dashboard Overview** — KPIs رئيسية في صفحة واحدة.
3. **Remote Config Manager** — قراءة وتعديل أي مفتاح، خاصة `min_required_version`.

### 🟡 Management (Phase 2)
4. **Users Manager** — قائمة، بحث، تفاصيل، حذف، إرسال إشعار.
5. **Cycles Manager** — قائمة، تفاصيل، إغلاق إجباري، حذف ناعم/نهائي.
6. **Categories & Types Manager** — CRUD على `product_categories` و `types`.

### 🟠 Engagement (Phase 3)
7. **Notifications Broadcaster** — إرسال إشعار مخصص (لكل المستخدمين / لـ topic / لمستخدم محدد).
8. **App Reviews & Cycle Feedbacks** — عرض، تصفية، رد.
9. **Tools Analytics** — تطوير الموجود (charts، per-user، trends).

### 🔴 System (Phase 4)
10. **Database Operations** — backup (mysqldump)، schema viewer، read-only SQL runner، عمليات maintenance محدودة.
11. **Logs & Errors viewer** — قراءة `error_log` (مع pagination).
12. **Account Deletions Insights** — تحليل أسباب وفترات الحذف.

---

## 2. القرارات المعمارية (Architecture decisions)

### 2.1 Backend
- **استمر على نفس الـ stack** (PHP + PDO). لا داعي لإعادة هيكلة.
- **كل endpoint جديد** يمتد من `BaseApi` ويوضع تحت `backend_farkha/admin/<feature>/<action>.php`.
- **استخدم Models موجودة** كلما أمكن. أنشئ models جديدة عند الحاجة (مثلاً `RemoteConfigModel`، `AdminUserModel`).
- **Firebase Remote Config:** استخدم `kreait/firebase-php` المثبَّت بالفعل. مثال:
  ```php
  $rc = (new Factory)->withServiceAccount($credentialsPath)->createRemoteConfig();
  $template = $rc->get();
  // $template->parameters() → array of Parameter
  // $rc->validate($template); $rc->publish($template);
  ```
- **Output:** كل response يستخدم `Response::success($data)` / `Response::fail($msg, $code)` (موجود في `core/Response.php`).

### 2.2 Admin app (Flutter)
- **انتقل لـ GetX** (نفس التطبيق الرئيسي) — نفس الـ pattern: Controller + Binding + Screen.
- **هيكل مُقترَح:**
  ```
  farkha_admin/lib/
  ├── core/
  │   ├── api/             — admin_api.dart (يلف http.post)
  │   ├── auth/            — admin_login_controller.dart (يحفظ token محلياً)
  │   ├── routes/          — app_pages.dart, app_routes.dart
  │   ├── theme/           — app_theme.dart (داكن + Cairo)
  │   └── widgets/         — kpi_card.dart, data_table.dart, async_view.dart
  ├── features/
  │   ├── auth/            — login_screen.dart
  │   ├── dashboard/       — overview_screen.dart, dashboard_controller.dart
  │   ├── users/           — list, detail, controller, model
  │   ├── cycles/          — list, detail, controller, model
  │   ├── prices/          — (موجود) — أعِد كتابته بـ GetX
  │   ├── articles/        — (موجود) — أعِد كتابته بـ GetX
  │   ├── categories/      — CRUD
  │   ├── notifications/   — broadcaster
  │   ├── reviews/         — app_reviews + cycle_feedbacks
  │   ├── analytics/       — (موجود) — وسِّعه بـ charts
  │   ├── remote_config/   — list, edit, controller
  │   └── system/          — db_ops, logs, cache
  └── main.dart
  ```
- **Dependencies جديدة (لـ pubspec.yaml):**
  ```yaml
  get: ^4.7.2
  fl_chart: ^0.69.0           # للـ charts
  data_table_2: ^2.5.15       # جداول scrollable
  intl: ^0.20.0               # تنسيق تواريخ/أرقام
  shared_preferences: ^2.3.0  # تخزين admin token محلياً
  ```
- **التصميم:** dark mode افتراضياً، Cairo font (يُنزَّل من Google Fonts إن لزم)، RTL.

### 2.3 الأمان (Security)
- **لا تكتفي بـ Basic Auth.** أضف:
  1. **Bearer admin token** — JWT أو opaque token مولَّد من login endpoint وموقَّع بـ HMAC.
  2. **IP allowlist** اختياري عبر env (`ADMIN_IP_ALLOWLIST=1.2.3.4,5.6.7.8`).
  3. **`.htaccess` داخل `backend_farkha/admin/`** يمنع الوصول المباشر للملفات الفرعية بدون GET/POST صحيحة.
- **حدّ الصلاحيات الخطيرة:** عمليات DB destructive (DROP/TRUNCATE/UPDATE without WHERE) تُرفض دائماً، حتى من الأدمن.

---

## 3. Schema — جداول جديدة لازمة

### 3.1 `admin_users` (جدول جديد)
```sql
CREATE TABLE `admin_users` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(50) NOT NULL,
  `password_hash` varchar(255) NOT NULL,         -- password_hash() بـ PASSWORD_BCRYPT
  `display_name` varchar(100) DEFAULT NULL,
  `role` enum('superadmin','admin','readonly') NOT NULL DEFAULT 'admin',
  `last_login_at` datetime DEFAULT NULL,
  `last_login_ip` varchar(45) DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

### 3.2 `admin_sessions` (جدول جديد)
```sql
CREATE TABLE `admin_sessions` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `admin_id` int unsigned NOT NULL,
  `token_hash` char(64) NOT NULL,                -- sha256(token)
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `expires_at` datetime NOT NULL,
  `last_used_at` datetime DEFAULT NULL,
  `ip` varchar(45) DEFAULT NULL,
  `user_agent` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_token_hash` (`token_hash`),
  KEY `idx_admin_expires` (`admin_id`,`expires_at`),
  CONSTRAINT `fk_as_admin` FOREIGN KEY (`admin_id`) REFERENCES `admin_users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

### 3.3 `admin_audit_log` (جدول جديد — لتتبُّع كل عملية أدمن)
```sql
CREATE TABLE `admin_audit_log` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `admin_id` int unsigned DEFAULT NULL,
  `action` varchar(80) NOT NULL,                 -- e.g. 'price.add', 'user.delete', 'remote_config.publish'
  `target_type` varchar(50) DEFAULT NULL,        -- 'user', 'cycle', 'price', 'remote_config_param'
  `target_id` varchar(100) DEFAULT NULL,
  `payload` json DEFAULT NULL,                   -- snapshot للتغيير (before/after مثلاً)
  `ip` varchar(45) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_aal_admin_created` (`admin_id`,`created_at`),
  KEY `idx_aal_action` (`action`),
  CONSTRAINT `fk_aal_admin` FOREIGN KEY (`admin_id`) REFERENCES `admin_users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

### 3.4 Migration file
- ضع الـ DDL أعلاه في: `backend_farkha/migrations/2026_05_09_admin_panel.sql`
- اكتب أيضاً rollback مقابل: `backend_farkha/migrations/rollback_2026_05_09_admin_panel.sql`
- **بعد الإنشاء**، أنشئ admin أول يدوياً عبر سكريبت لمرة واحدة (لا تتركه publicly accessible):
  ```php
  // backend_farkha/scripts/seed_first_admin.php (يُنفَّذ من CLI ثم يُحذف)
  $hash = password_hash('CHANGE_ME_STRONG_PASSWORD', PASSWORD_BCRYPT);
  Database::execute("INSERT INTO admin_users (username, password_hash, role) VALUES (?, ?, 'superadmin')", ['nims', $hash]);
  ```

---

## 4. Phase 1 — Auth + Dashboard + Remote Config (الأولوية القصوى)

### 4.1 Backend — Admin Auth

#### 4.1.1 ملف جديد: `backend_farkha/core/AdminAuth.php`
```php
<?php
final class AdminAuth {
    private const TOKEN_LIFETIME_HOURS = 12;

    /** يُستدعى في بداية كل admin endpoint. يضيف $GLOBALS['current_admin']. */
    public static function require(?string $minRole = null): array {
        $token = self::extractBearerToken();
        if (!$token) Response::fail('Admin token required', 401);

        $hash = hash('sha256', $token);
        $row = Database::fetchOne(
            "SELECT s.admin_id, s.expires_at, a.role, a.username, a.is_active
             FROM admin_sessions s JOIN admin_users a ON a.id = s.admin_id
             WHERE s.token_hash = ? LIMIT 1",
            [$hash]
        );
        if (!$row) Response::fail('Invalid admin token', 401);
        if (!$row['is_active']) Response::fail('Admin disabled', 403);
        if (strtotime($row['expires_at']) < time()) Response::fail('Session expired', 401);

        if ($minRole && !self::roleSufficient($row['role'], $minRole)) {
            Response::fail('Insufficient role', 403);
        }

        // touch last_used_at
        Database::execute("UPDATE admin_sessions SET last_used_at = NOW() WHERE token_hash = ?", [$hash]);

        $GLOBALS['current_admin'] = $row;
        return $row;
    }

    public static function login(string $username, string $password, string $ip, string $ua): array {
        $admin = Database::fetchOne(
            "SELECT id, password_hash, role, display_name, is_active FROM admin_users WHERE username = ? LIMIT 1",
            [$username]
        );
        if (!$admin || !$admin['is_active'] || !password_verify($password, $admin['password_hash'])) {
            // rate-limit failed attempts (use existing RateLimiter on identifier "admin_login_$ip")
            Response::fail('Invalid credentials', 401);
        }

        $token = bin2hex(random_bytes(32));
        $hash = hash('sha256', $token);
        $expires = date('Y-m-d H:i:s', time() + self::TOKEN_LIFETIME_HOURS * 3600);

        Database::execute(
            "INSERT INTO admin_sessions (admin_id, token_hash, expires_at, ip, user_agent) VALUES (?,?,?,?,?)",
            [$admin['id'], $hash, $expires, $ip, substr($ua, 0, 255)]
        );
        Database::execute("UPDATE admin_users SET last_login_at = NOW(), last_login_ip = ? WHERE id = ?", [$ip, $admin['id']]);

        return [
            'token' => $token,
            'expires_at' => $expires,
            'admin' => [
                'id' => $admin['id'],
                'username' => $username,
                'display_name' => $admin['display_name'],
                'role' => $admin['role'],
            ],
        ];
    }

    public static function logout(string $token): void {
        Database::execute("DELETE FROM admin_sessions WHERE token_hash = ?", [hash('sha256', $token)]);
    }

    public static function logAction(string $action, ?string $targetType = null, $targetId = null, ?array $payload = null): void {
        $admin = $GLOBALS['current_admin'] ?? null;
        Database::execute(
            "INSERT INTO admin_audit_log (admin_id, action, target_type, target_id, payload, ip) VALUES (?,?,?,?,?,?)",
            [
                $admin['admin_id'] ?? null,
                $action,
                $targetType,
                $targetId !== null ? (string) $targetId : null,
                $payload ? json_encode($payload, JSON_UNESCAPED_UNICODE) : null,
                $_SERVER['REMOTE_ADDR'] ?? null,
            ]
        );
    }

    private static function extractBearerToken(): ?string {
        $h = $_SERVER['HTTP_AUTHORIZATION'] ?? $_SERVER['REDIRECT_HTTP_AUTHORIZATION'] ?? '';
        if (preg_match('/Bearer\s+(.+)/i', $h, $m)) return trim($m[1]);
        return null;
    }

    private static function roleSufficient(string $actual, string $required): bool {
        $rank = ['readonly' => 1, 'admin' => 2, 'superadmin' => 3];
        return ($rank[$actual] ?? 0) >= ($rank[$required] ?? 0);
    }
}
```

#### 4.1.2 ملف جديد: `backend_farkha/core/AdminBaseApi.php`
```php
<?php
abstract class AdminBaseApi extends BaseApi {
    protected ?string $minRole = null; // 'readonly' | 'admin' | 'superadmin'
    protected bool $requireAuth = false; // لا تستخدم Auth العادي

    public function __construct() {
        parent::__construct();
        AdminAuth::require($this->minRole);
    }
}
```

#### 4.1.3 Endpoints جديدة
- `backend_farkha/admin/auth/login.php` — POST { username, password } → { token, expires_at, admin }. (بدون AdminAuth، لكن مع `RateLimiter::checkLimit('admin_login_'.$ip, 10, 600)`).
- `backend_farkha/admin/auth/logout.php` — POST → نجاح. (مع AdminAuth).
- `backend_farkha/admin/auth/me.php` — GET → admin info.

#### 4.1.4 تحديث endpoints الأدمن الحالية
كل ملف في `admin/prices/` و `admin/articles/`:
- غيِّر `extends BaseApi` → `extends AdminBaseApi`.
- بعد كل عملية write، نده `AdminAuth::logAction('price.add', 'price', $id, [...])`.

---

### 4.2 Backend — Dashboard Overview KPIs

#### ملف جديد: `backend_farkha/admin/dashboard/overview.php`
```php
class DashboardOverviewApi extends AdminBaseApi {
    protected ?string $minRole = 'readonly';
    public function __construct() {
        parent::__construct();
        $this->handleRequest(function () {
            $data = [
                'users' => [
                    'total' => Database::fetchOne("SELECT COUNT(*) c FROM users")['c'],
                    'verified_phone' => Database::fetchOne("SELECT COUNT(*) c FROM users WHERE phone IS NOT NULL")['c'],
                    'new_today' => Database::fetchOne("SELECT COUNT(*) c FROM users WHERE DATE(created_at) = CURDATE()")['c'],
                    'new_7d' => Database::fetchOne("SELECT COUNT(*) c FROM users WHERE created_at >= NOW() - INTERVAL 7 DAY")['c'],
                    'new_30d' => Database::fetchOne("SELECT COUNT(*) c FROM users WHERE created_at >= NOW() - INTERVAL 30 DAY")['c'],
                ],
                'cycles' => [
                    'total_active' => Database::fetchOne("SELECT COUNT(*) c FROM cycles WHERE deleted_at IS NULL AND end_date_raw IS NULL")['c'],
                    'total_closed' => Database::fetchOne("SELECT COUNT(*) c FROM cycles WHERE end_date_raw IS NOT NULL")['c'],
                    'total_deleted' => Database::fetchOne("SELECT COUNT(*) c FROM cycles WHERE deleted_at IS NOT NULL")['c'],
                    'created_7d' => Database::fetchOne("SELECT COUNT(*) c FROM cycles WHERE created_at >= NOW() - INTERVAL 7 DAY")['c'],
                ],
                'devices' => [
                    'total' => Database::fetchOne("SELECT COUNT(*) c FROM user_devices")['c'],
                    'android' => Database::fetchOne("SELECT COUNT(*) c FROM user_devices WHERE platform='android'")['c'],
                    'ios' => Database::fetchOne("SELECT COUNT(*) c FROM user_devices WHERE platform='ios'")['c'],
                    'active_7d' => Database::fetchOne("SELECT COUNT(*) c FROM user_devices WHERE last_active >= NOW() - INTERVAL 7 DAY")['c'],
                ],
                'tools' => [
                    'usage_today' => Database::fetchOne("SELECT COALESCE(SUM(usage_count),0) c FROM tools_usage WHERE usage_date = CURDATE()")['c'],
                    'usage_7d' => Database::fetchOne("SELECT COALESCE(SUM(usage_count),0) c FROM tools_usage WHERE usage_date >= CURDATE() - INTERVAL 6 DAY")['c'],
                    'top_today' => Database::fetchAll("SELECT tool_id, usage_count FROM tools_usage WHERE usage_date = CURDATE() ORDER BY usage_count DESC LIMIT 5"),
                ],
                'reviews' => [
                    'app_total' => Database::fetchOne("SELECT COUNT(*) c FROM app_reviews")['c'],
                    'app_avg' => (float) (Database::fetchOne("SELECT AVG(rating) a FROM app_reviews WHERE rating IS NOT NULL")['a'] ?? 0),
                    'cycle_total' => Database::fetchOne("SELECT COUNT(*) c FROM cycle_feedbacks")['c'],
                    'cycle_avg' => (float) (Database::fetchOne("SELECT AVG(rating) a FROM cycle_feedbacks")['a'] ?? 0),
                ],
                'prices' => [
                    'total_records' => Database::fetchOne("SELECT COUNT(*) c FROM prices")['c'],
                    'updated_today' => Database::fetchOne("SELECT COUNT(*) c FROM prices WHERE DATE(date) = CURDATE()")['c'],
                ],
                'timeline_30d' => [
                    'users' => Database::fetchAll(
                        "SELECT DATE(created_at) d, COUNT(*) c FROM users
                         WHERE created_at >= CURDATE() - INTERVAL 29 DAY
                         GROUP BY DATE(created_at) ORDER BY d"
                    ),
                    'cycles' => Database::fetchAll(
                        "SELECT DATE(created_at) d, COUNT(*) c FROM cycles
                         WHERE created_at >= CURDATE() - INTERVAL 29 DAY
                         GROUP BY DATE(created_at) ORDER BY d"
                    ),
                ],
                'generated_at' => date('c'),
            ];
            $this->success($data);
        }, 'dashboard_overview');
    }
}
new DashboardOverviewApi();
```

---

### 4.3 Backend — Remote Config Manager

#### 4.3.1 ملف جديد: `backend_farkha/core/RemoteConfigService.php`
```php
<?php
require_once __DIR__ . '/../config/firebase.php';

use Kreait\Firebase\Factory;
use Kreait\Firebase\RemoteConfig\Parameter;
use Kreait\Firebase\RemoteConfig\DefaultValue;

final class RemoteConfigService {
    private static $rc = null;

    private static function client() {
        if (self::$rc === null) {
            $cred = __DIR__ . '/firebase_credentials.json';
            self::$rc = (new Factory)->withServiceAccount($cred)->createRemoteConfig();
        }
        return self::$rc;
    }

    public static function getAll(): array {
        $tpl = self::client()->get();
        $out = ['parameters' => [], 'version' => null, 'etag' => null];

        foreach ($tpl->parameters() as $p) {
            $name = $p->name();
            $defaultValue = $p->defaultValue();
            $out['parameters'][] = [
                'name' => $name,
                'description' => $p->description() ?? '',
                'default_value' => $defaultValue ? $defaultValue->value() : null,
            ];
        }
        $version = $tpl->version();
        if ($version) {
            $out['version'] = [
                'number' => $version->versionNumber(),
                'updated_at' => $version->updatedAt()->format('c'),
                'updated_by' => $version->user() ? $version->user()->email() : null,
                'description' => $version->description() ?? '',
            ];
        }
        return $out;
    }

    public static function setParameter(string $name, string $value, string $description = ''): array {
        $tpl = self::client()->get();
        $param = Parameter::named($name)
            ->withDefaultValue(DefaultValue::with($value));
        if ($description) $param = $param->withDescription($description);
        $tpl = $tpl->withParameter($param);
        $newTpl = self::client()->validate($tpl);
        self::client()->publish($newTpl ?? $tpl);
        return self::getAll();
    }

    public static function deleteParameter(string $name): array {
        $tpl = self::client()->get();
        // re-build template without that parameter
        $existing = $tpl->parameters();
        $newTpl = $tpl;
        // SDK doesn't expose direct remove; rebuild via withParameters() if needed
        // workaround: set an empty value or use the SDK's remove if available in this version
        // Check version of kreait/firebase-php for `withRemovedParameter`. If unavailable, document limitation.
        if (method_exists($tpl, 'withRemovedParameter')) {
            $newTpl = $tpl->withRemovedParameter($name);
            self::client()->publish($newTpl);
        } else {
            throw new RuntimeException('SDK version does not support removing parameters; use overwrite instead');
        }
        return self::getAll();
    }
}
```

> **ملاحظة تنفيذ:** تأكد من أن SDK المُثبَّت يدعم `withRemovedParameter`. تحقَّق من النسخة في `composer.lock`. إن لم يدعم، اكتفِ بتحديث القيمة بدلاً من الحذف.

#### 4.3.2 Endpoints
- `backend_farkha/admin/remote_config/get.php` — GET → list + version. minRole: readonly.
- `backend_farkha/admin/remote_config/update.php` — POST { name, value, description? } → updated list. minRole: admin.
  - Audit: `AdminAuth::logAction('remote_config.publish', 'param', $name, ['old' => $old, 'new' => $value])`.
- `backend_farkha/admin/remote_config/delete.php` — POST { name } → updated list. minRole: superadmin.

---

### 4.4 Frontend — Phase 1 شاشات

#### 4.4.1 إعداد عام
- **استبدل `main.dart`** بـ:
  ```dart
  void main() async {
    WidgetsFlutterBinding.ensureInitialized();
    await dotenv.load(fileName: ".env");
    await GetStorage.init(); // لتخزين token
    runApp(const FarkhaAdminApp());
  }
  ```
- **GetMaterialApp** + locale `ar` + ThemeData داكن + RTL.
- **Initial route:** `/login` لو مفيش token محفوظ، `/dashboard` لو فيه.

#### 4.4.2 شاشات Phase 1
1. **`features/auth/login_screen.dart`** — نموذج username/password، يستدعي `/admin/auth/login.php`، يحفظ token في GetStorage، يحوِّل لـ `/dashboard`.
2. **`features/dashboard/overview_screen.dart`**:
   - **شريط جانبي (Drawer/NavigationRail)** فيه روابط لكل الـ sections.
   - **شبكة KPI Cards** (8-12 كارت): إجمالي المستخدمين، الجدد آخر 7 أيام، الدورات النشطة، الأجهزة النشطة، استخدام الأدوات اليوم، متوسط تقييم التطبيق، إلخ.
   - **2 charts** (`fl_chart` LineChart): مستخدمون جدد آخر 30 يوم، دورات جديدة آخر 30 يوم.
   - **List**: أكثر 5 أدوات استخداماً اليوم.
   - زر refresh + auto-refresh كل دقيقة.
3. **`features/remote_config/list_screen.dart`**:
   - DataTable: الاسم، القيمة، الوصف، آخر تعديل.
   - زر "تعديل" بجوار كل صف → dialog يعرض القيمة الحالية ويسمح بالتعديل.
   - **Highlight خاص لـ `min_required_version`** مع warning: "تغيير هذا المفتاح يجبر كل المستخدمين على التحديث."
   - زر "إضافة مفتاح جديد" (superadmin only).

#### 4.4.3 ApiClient (مهم — استخدمه في كل feature)
**`core/api/admin_api.dart`:**
```dart
class AdminApi {
  static String get _base => dotenv.get('API_HOST');
  static final _box = GetStorage();

  static Map<String, String> _headers() {
    final token = _box.read<String>('admin_token');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<Map<String, dynamic>> post(String path, [Map<String, dynamic>? body]) async {
    final res = await http.post(
      Uri.parse('$_base$path'),
      headers: _headers(),
      body: jsonEncode(body ?? {}),
    );
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 401) {
      _box.remove('admin_token');
      Get.offAllNamed('/login');
    }
    if (data['status'] != 'success') {
      throw AdminApiException(data['message'] ?? 'خطأ', res.statusCode);
    }
    return data;
  }
}
```

---

## 5. Phase 2 — Users / Cycles / Categories Manager

### 5.1 Users Manager

#### Backend endpoints
- `admin/users/list.php` — POST { page, page_size, q (search by name/phone/firebase_uid) } → { items, total, page }.
  - Query: `SELECT id, name, phone, firebase_uid, created_at, updated_at FROM users WHERE (name LIKE ? OR phone LIKE ? OR firebase_uid LIKE ?) ORDER BY id DESC LIMIT ? OFFSET ?`.
  - أرجع أيضاً عداد الدورات للمستخدم (subquery).
- `admin/users/detail.php` — POST { user_id } → كامل بيانات المستخدم + أجهزته + دوراته.
- `admin/users/delete.php` — POST { user_id, reason } → ينده `UserModel::deleteByFirebaseUid`. minRole: superadmin. Audit: `user.delete`.
- `admin/users/send_notification.php` — POST { user_id, title, body, data? } → ينده `NotificationService::sendToUser`. Audit: `user.notify`.

#### Frontend
- `features/users/users_list_screen.dart` — DataTable2 بـ pagination + search box.
- `features/users/user_detail_screen.dart` — تبويبات: Info, Devices, Cycles, Reviews. أزرار: إرسال إشعار، حذف.

### 5.2 Cycles Manager

#### Backend endpoints
- `admin/cycles/list.php` — POST { page, page_size, status (active/closed/deleted), owner_id? } → cycles list + counts.
- `admin/cycles/detail.php` — POST { cycle_id } → full cycle (members, data, expenses, sales, notes, inventory).
- `admin/cycles/force_close.php` — POST { cycle_id, end_date } → set `end_date_raw`. minRole: admin.
- `admin/cycles/soft_delete.php` / `restore.php` / `hard_delete.php` — حسب الحالة. `hard_delete` superadmin only.

#### Frontend
- `features/cycles/cycles_list_screen.dart` — مع filter chips (نشط/مغلق/محذوف).
- `features/cycles/cycle_detail_screen.dart` — أقسام طي/فرد لكل نوع بيانات + أزرار العمليات.

### 5.3 Categories & Types Manager

#### Backend endpoints
- `admin/categories/list.php`, `add.php`, `update.php`, `delete.php` (يرفض الحذف لو عليه `types` مرتبطة).
- `admin/types/list.php` (ممكن تتضمن category_id filter)، `add.php`, `update.php`, `delete.php` (يرفض لو عليه `prices`).

#### Frontend
- شاشة واحدة fيها قسمين: Categories list (يسار) + Types of selected category (يمين).

---

## 6. Phase 3 — Notifications / Reviews / Analytics

### 6.1 Notifications Broadcaster

#### Backend
- `admin/notifications/send_topic.php` — POST { topic, title, body, data? } → `NotificationService::broadcastToTopic`. minRole: admin. Audit.
- `admin/notifications/send_all_users.php` — POST { title, body } → ينده `broadcastToTopic` على topic="users" أو يلوب على devices (السلوك الحالي بيستخدم topic="users" — تأكد من التطبيق سابسكرايب له).
- `admin/notifications/send_to_user.php` — POST { user_id, title, body, data? } → `NotificationService::sendToUser`.
- `admin/notifications/topics.php` — GET → `TopicManager::getAllTopics()` (للـ dropdown).

#### Frontend
- `features/notifications/broadcast_screen.dart`:
  - Tabs: لمستخدم محدد / لـ topic / للكل.
  - حقول title (max 60)، body (max 200)، data key/value optional.
  - Confirm dialog قبل الإرسال.

### 6.2 Reviews & Feedbacks

#### Backend
- `admin/reviews/app_list.php` — POST { page, page_size, min_rating?, max_rating? } → list + avg/distribution.
- `admin/reviews/cycle_feedbacks_list.php` — نفس الفكرة.
- (اختياري) `admin/reviews/export_csv.php`.

#### Frontend
- `features/reviews/app_reviews_screen.dart`:
  - Histogram للتوزيع (1-5 stars) عبر `fl_chart`.
  - DataTable: rating، issue، suggestion، platform، app_version، التاريخ.
  - فلاتر: rating range، platform، تاريخ.

### 6.3 Tools Analytics (تطوير الموجود)
- أضف:
  - **LineChart**: استخدام آخر 30 يوم (اجمع الكل أو لكل أداة).
  - **BarChart**: top 10 tools.
  - **Per-user breakdown**: من `tools_usage_events` (top users، tools per user).
  - فلاتر: date range، tool_id، user_id.

---

## 7. Phase 4 — System Operations

### 7.1 Database Operations (احذر — نطاق محدود)

#### Backend
- `admin/db/schema.php` — GET → list of tables + row counts (SHOW TABLES + استعلام count لكل واحد). minRole: readonly.
- `admin/db/table_preview.php` — POST { table, limit (≤100), offset } → SELECT * FROM <whitelisted_table> LIMIT...
  - **whitelist صارم** للجداول المسموح browseها (في كود الـ endpoint — مش من الـ request).
- `admin/db/sql_select.php` — POST { sql } → ينفِّذ SELECT فقط:
  - يرفض إن طول SQL > 5000 chars، أو يحتوي `;` (multi-statement)، أو لا يبدأ بـ `SELECT` بعد trim/lowercase.
  - يستخدم `Database::query` مع timeout قصير.
  - minRole: superadmin. Audit الـ SQL كامل.
- `admin/db/backup.php` — POST → ينفِّذ `mysqldump` عبر `exec()` ويحفظ في `backups/farkha_<timestamp>.sql`، ثم يعطي download URL مؤقت موقَّع.
  - **خطر:** تأكد من `$path` آمن من injection (لا تستقبل مدخلات من user).
  - minRole: superadmin.

> **يُمنع منعاً باتاً** أي endpoint ينفِّذ DML/DDL مفتوح من الأدمن. أي تعديل بيانات لازم يكون له endpoint مخصَّص بـ params محدَّدة.

### 7.2 Cache Manager
- الموجود (`cache_system/clear_cache.php`) — لفّه بـ AdminAuth + audit.
- أضف: `admin/cache/stats.php` (عدد الملفات + الحجم الكلي + أقدم/أحدث ملف).

### 7.3 Logs Viewer
- `admin/logs/list.php` — يقرأ آخر N سطر من PHP `error_log` (path من php.ini عبر `ini_get('error_log')`).
  - Pagination باستخدام file offsets (يقرأ من النهاية).
  - minRole: admin.

### 7.4 Audit Log Viewer
- `admin/audit/list.php` — POST { page, page_size, action?, admin_id?, date_from?, date_to? } → audit log entries.

### 7.5 Account Deletions Insights
- _Removed — `account_deletions` table no longer exists._

---

## 8. التسليم — Acceptance criteria

### Phase 1 (Must-have)
- [ ] Migration `2026_05_09_admin_panel.sql` يطبَّق بنجاح ويُنشئ 3 جداول.
- [ ] Seed أول superadmin يدوياً عبر CLI script ثم يُحذف الـ script.
- [ ] `POST /admin/auth/login.php` بـ creds صحيحة → 200 + token. بـ creds خطأ → 401 + rate-limit بعد 10 محاولات.
- [ ] أي endpoint أدمن بدون Bearer header صالح → 401.
- [ ] كل endpoints أدمن قديمة (prices/articles) محدَّثة لتستخدم `AdminBaseApi` وتسجِّل audit.
- [ ] `POST /admin/dashboard/overview.php` يرجِّع KPIs كاملة < 500ms.
- [ ] `GET /admin/remote_config/get.php` يرجِّع قائمة المعلَمات بما فيها `min_required_version`.
- [ ] `POST /admin/remote_config/update.php` بـ `{name:"min_required_version", value:"1.5.0"}` يحدِّث Firebase فعلياً (تحقَّق من Firebase Console).
- [ ] الـ Flutter admin: شاشة login + dashboard + remote config تعمل end-to-end.
- [ ] **مفيش endpoint أدمن واحد يعمل بدون token صحيح** (تحقَّق يدوياً بـ curl بدون header).

### Phase 2-4
- لكل feature: شاشة عرض + عملية واحدة على الأقل (CRUD أو action) + audit log entry لكل عملية write.

---

## 9. Best practices ملزمة لنموذج التنفيذ

1. **لا تخترع endpoint موجود.** استخدم endpoints/Models موجودة كلما أمكن.
2. **كل عملية write** تستدعي `AdminAuth::logAction(...)`. بدون استثناء.
3. **لا تضع credentials في الكود.** استخدم env vars.
4. **اختبر يدوياً** كل endpoint بـ `curl` قبل ما تروح للـ Flutter.
5. **Migration تُكتب مرة واحدة** وتُختبر على نسخة من الـ DB، ولا تُعدَّل بعد التطبيق — أي تغيير = migration جديد.
6. **لغة الواجهة عربية** (RTL، Cairo). الكود/التعليقات/أسماء المتغيرات إنجليزية.
7. **Pagination دائماً** في أي list يحتمل > 100 صف.
8. **حدود الـ inputs:** اعتبر كل input من العميل ضارًا — استخدم `Validator` الموجود.
9. **Rate-limit مناسب** على endpoints حساسة (login: 10/10min، sql_select: 30/hour).
10. **Backup قبل أي destructive action** على DB (خاصة hard_delete).
11. **اقطع الـ token** فوراً لو الأدمن غُيِّر `is_active=0` (يحدث طبيعياً لأن `AdminAuth::require` يفحص `is_active`).
12. **لا ترجِّع `password_hash`** أبداً في أي response.
13. **لا تكتب IDs مكشوفة** في رسائل الخطأ للعميل.

---

## 10. ترتيب التنفيذ المقترح (مرجعية واحدة)

```
T1.  migration 2026_05_09_admin_panel.sql  + rollback
T2.  scripts/seed_first_admin.php → run → delete
T3.  core/AdminAuth.php + core/AdminBaseApi.php
T4.  admin/auth/{login,logout,me}.php
T5.  curl test: login → get token → logout (✅ checkpoint)
T6.  Update existing admin/{prices,articles}/*.php to use AdminBaseApi + audit
T7.  admin/dashboard/overview.php
T8.  core/RemoteConfigService.php + admin/remote_config/{get,update,delete}.php
T9.  curl test: remote config get/update (✅ checkpoint — تحقق من Firebase console)
T10. Flutter admin: pubspec deps + main.dart + theme + GetX setup
T11. Flutter: AdminApi client + auth/login_screen + storage
T12. Flutter: dashboard/overview_screen + KPI cards + 2 charts
T13. Flutter: remote_config/list_screen
T14. **End-to-end test Phase 1 (✅ deliverable)**
T15. Phase 2 endpoints (users, cycles, categories) + screens
T16. Phase 3 endpoints (notifications, reviews, analytics-v2) + screens
T17. Phase 4 endpoints (db ops, logs, cache stats, audit viewer) + screens
T18. Smoke test + Audit log منطقي + Document any deviations.
```

---

## 11. ملاحظات أخيرة لنموذج التنفيذ

- **الـ DB حية ومُتَّصلة** على MAMP port 8889 (راجع `memory/project_db_environment.md` لو متاح). اختبر استعلاماتك على نسخة محلية أولاً.
- لو لقيت أن SDK `kreait/firebase-php` نسخته القديمة لا تدعم Remote Config method معينة، **رفِّع الحزمة** (`composer update kreait/firebase-php`) — أو اكتب fallback عبر REST API لـ Firebase Remote Config (`https://firebaseremoteconfig.googleapis.com/v1/projects/<project>/remoteConfig`).
- **أي قرار تنفيذي مهم** لم يُذكر هنا (مثلاً: تخزين كلمات السر، حد الـ session)، اتخذه بحكمة وسجله في تعليق `// DECISION:` في الملف.
- **عند الانتهاء من كل Phase**، اكتب ملخص قصير في `FARKHA_ADMIN_PROGRESS.md` يضم: ما تم، ما تبقى، ومشاكل محتملة لاحظتها.

— نهاية المواصفات —
