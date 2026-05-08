# خطة تحسين قاعدة البيانات — Farkha

> **المستهدف:** نموذج AI آخر ينفّذ هذه الخطة على المراحل.
> **التاريخ:** 2026-05-06
> **النطاق:** قاعدة بيانات MySQL (MAMP) + Backend PHP + تطبيق Flutter
> **الجذر:** `/Users/nims/StudioProjects/farkha/`

---

## 📋 الفهرس

1. [قبل البدء — متطلبات إلزامية](#قبل-البدء)
2. [ملخص التحسينات](#ملخص-التحسينات)
3. [المرحلة 1 — DB فقط (آمنة 100%)](#المرحلة-1)
4. [المرحلة 2 — تأثير محدود على Backend](#المرحلة-2)
5. [المرحلة 3 — تأثير واسع (تأجيل موصى به)](#المرحلة-3)
6. [اختبار شامل بعد كل مرحلة](#اختبار-شامل)
7. [استراتيجية التراجع (Rollback)](#rollback)

---

<a name="قبل-البدء"></a>
## ⚠️ قبل البدء — متطلبات إلزامية

قبل أي تعديل على القاعدة:

```bash
# 1. نسخة احتياطية كاملة (إلزامية)
cd /Users/nims/StudioProjects/farkha
mysqldump -u root -p farkha_db > backup_$(date +%Y%m%d_%H%M%S).sql

# 2. تحقق أن البيئة المحلية MAMP مشغّلة
mysql -u root -p -e "SHOW DATABASES LIKE 'farkha%';"

# 3. تحقق من حالة Git نظيفة قبل البدء
cd /Users/nims/StudioProjects/farkha
git status
```

**قواعد ذهبية:**
- ✅ شغّل كل ALTER داخل `START TRANSACTION; ... COMMIT;`
- ✅ بعد كل مرحلة: شغّل اختبار يدوي + Flutter integration tests
- ✅ لا تنتقل للمرحلة التالية إلا بعد التأكد من نجاح الحالية
- ❌ **لا تشغّل المراحل دفعة واحدة** — كل مرحلة لها commit مستقل

---

<a name="ملخص-التحسينات"></a>
## 📊 ملخص التحسينات (23 تحسين)

| المرحلة | عدد التحسينات | تأثير Backend | تأثير Flutter |
|:-------:|:-------------:|:-------------:|:-------------:|
| 1 | 14 | لا | لا |
| 2 | 5 | محدود (≤3 ملفات لكل) | لا |
| 3 | 4 | واسع | واسع |

---

<a name="المرحلة-1"></a>
## 🟢 المرحلة 1 — تحسينات DB فقط (آمنة 100%)

### الملف الجاهز
الهجرة جاهزة بالفعل في:
```
backend_farkha/migrations/2026_05_06_database_improvements.sql
```

### قائمة التعديلات

| # | الجدول | التعديل |
|:-:|--------|---------|
| 1.1 | `cycle_feedbacks` | إضافة `user_id` و`cycle_id` + FKs |
| 1.2 | `cycles` | إضافة `updated_at DATETIME` تلقائي |
| 1.3 | `app_reviews` | FK لـ `user_id` + CHECK rating |
| 1.4 | `types` | FK `main` → `main(id)` |
| 1.5 | `prices` | FK `type` → `types(id)` |
| 1.6 | `prices` | فهرس `idx_prices_date` |
| 1.7 | `cycle_data` | فهرسان `idx_cd_entry_date`, `idx_cd_cycle_date` |
| 1.8 | `cycle_expenses` | فهرس `idx_ce_cycle_date` |
| 1.9 | `cycle_sales` | فهرس `idx_cs_cycle_date` |
| 1.10 | `app_reviews` | فهرس `idx_ar_created_at` |
| 1.11 | `tools_usage` | فهرس `idx_tu_tool_name` |
| 1.12 | `phone_verifications` | فهرسان `idx_pv_phone_status`, `idx_pv_expires_at` |
| 1.13 | `cycle_invitations` | فهرس `idx_ci_expires_at` |

### خطوات التنفيذ

```bash
# 1. فحص قيم يتيمة (يجب يرجع فاضي)
mysql -u root -p farkha_db -e "
SELECT * FROM types WHERE main NOT IN (SELECT id FROM main);
SELECT * FROM prices WHERE type NOT IN (SELECT id FROM types);
SELECT * FROM cycle_feedbacks WHERE user_id IS NOT NULL AND user_id NOT IN (SELECT id FROM users);
"

# 2. تطبيق الهجرة
mysql -u root -p farkha_db < backend_farkha/migrations/2026_05_06_database_improvements.sql

# 3. تحقق
mysql -u root -p farkha_db -e "SHOW CREATE TABLE cycle_feedbacks\G"
```

### ملفات Backend المتأثرة
**لا شيء.** الكود الحالي يعمل كما هو.

### ملفات Flutter المتأثرة
**لا شيء.**

### Commit
```bash
git add backend_farkha/migrations/2026_05_06_database_improvements.sql
git commit -m "db: phase 1 — add indexes, FKs, updated_at, rating CHECK"
```

---

<a name="المرحلة-2"></a>
## 🟡 المرحلة 2 — تأثير محدود على Backend

### 2.1 — `phone` UNIQUE في `users`

**SQL:**
```sql
START TRANSACTION;

-- فحص أولاً (يجب يرجع فاضي)
SELECT phone, COUNT(*) as cnt FROM users
WHERE phone IS NOT NULL GROUP BY phone HAVING cnt > 1;

ALTER TABLE `users`
    DROP INDEX `idx_phone`,
    ADD UNIQUE KEY `uk_phone` (`phone`);

COMMIT;
```

**ملفات Backend المطلوب تعديلها:**

| الملف | التعديل |
|-------|---------|
| `backend_farkha/app/auth/send_otp.php` | قبل INSERT/UPDATE: تحقق من عدم استخدام الرقم لمستخدم آخر، وأرجع رسالة `phone_already_used` |
| `backend_farkha/app/auth/update_phone.php` | نفس الفحص قبل UPDATE |
| `backend_farkha/app/auth/verify_otp.php` | في حالة merge accounts (لو مدعوم): راجع منطق الدمج |

**رسالة الخطأ المقترحة:**
```php
if ($exists) {
    echo json_encode([
        "status" => "failure",
        "error" => "phone_already_used",
        "message" => "هذا الرقم مستخدم بالفعل"
    ]);
    exit;
}
```

**ملفات Flutter المتأثرة:**
- `lib/data/data_source/remote/auth_data/` — معالجة رسالة `phone_already_used` الجديدة في الـ controllers.

---

### 2.2 — `cycles.owner_user_id`

**SQL:**
```sql
START TRANSACTION;

-- 1. أضف العمود
ALTER TABLE `cycles`
    ADD COLUMN `owner_user_id` INT DEFAULT NULL AFTER `name`;

-- 2. Backfill من cycle_users
UPDATE `cycles` c
JOIN `cycle_users` cu
    ON cu.cycle_id = c.id AND cu.role = 'owner' AND cu.status = 'accepted'
SET c.owner_user_id = cu.user_id
WHERE c.owner_user_id IS NULL;

-- 3. تحقق أن كل الدورات لها مالك
SELECT COUNT(*) FROM cycles WHERE owner_user_id IS NULL;
-- يجب يرجع 0

-- 4. اجعل العمود NOT NULL + FK
ALTER TABLE `cycles`
    MODIFY COLUMN `owner_user_id` INT NOT NULL,
    ADD CONSTRAINT `fk_cycles_owner`
        FOREIGN KEY (`owner_user_id`) REFERENCES `users`(`id`)
        ON DELETE RESTRICT;

COMMIT;
```

**ملفات Backend المطلوب تعديلها:**

| الملف | التعديل |
|-------|---------|
| `backend_farkha/app/cycles/create.php` | عند INSERT: ضع `owner_user_id = $user_id` للمنشئ |
| `backend_farkha/app/cycles/get_cycles.php` | يمكن تبسيط الاستعلام (اختياري) — استخدم `owner_user_id` بدل JOIN |
| `backend_farkha/app/cycles/get_cycle_details.php` | اختياري — تحقق الصلاحية أسرع عبر `c.owner_user_id` |
| `backend_farkha/app/cycles/update_cycle.php` | اختياري — تحقق الصلاحية مباشرة |
| `backend_farkha/app/cycles/delete.php` | اختياري — تحقق الصلاحية مباشرة |
| `backend_farkha/models/CycleModel.php` | إضافة الحقل في الموديل |

**ملفات Flutter المتأثرة:**
- اختياري: `lib/data/model/cycle/` — إضافة `ownerUserId` إذا أردت استخدامه في الواجهة.

---

### 2.3 — تحسين `cycle_invitations`

**SQL:**
```sql
START TRANSACTION;

ALTER TABLE `cycle_invitations`
    ADD COLUMN `created_by_user_id` INT DEFAULT NULL AFTER `cycle_id`,
    ADD COLUMN `used_by_user_id` INT DEFAULT NULL,
    ADD COLUMN `used_at` DATETIME DEFAULT NULL,
    ADD COLUMN `status` ENUM('active','used','expired','revoked')
        NOT NULL DEFAULT 'active',
    ADD INDEX `idx_ci_status` (`status`),
    ADD CONSTRAINT `fk_ci_creator`
        FOREIGN KEY (`created_by_user_id`) REFERENCES `users`(`id`)
        ON DELETE SET NULL,
    ADD CONSTRAINT `fk_ci_user`
        FOREIGN KEY (`used_by_user_id`) REFERENCES `users`(`id`)
        ON DELETE SET NULL;

COMMIT;
```

**ملفات Backend المطلوب تعديلها:**

| الملف | التعديل |
|-------|---------|
| `backend_farkha/app/cycles/create_invitation.php` | حفظ `created_by_user_id = $user_id` |
| `backend_farkha/app/cycles/join_by_code.php` | عند نجاح الانضمام: `UPDATE cycle_invitations SET used_by_user_id, used_at, status='used'`. ارفض الكود لو `status != 'active'` |
| `backend_farkha/app/cycles/get_my_invitations.php` | فلتر بـ `status='active' AND expires_at > NOW()` |
| `backend_farkha/app/cycles/respond_to_invitation.php` | حدّث `status` عند الرفض إلى `revoked` |

**ملفات Flutter المتأثرة:** لا شيء (التغييرات داخلية في الـ backend).

---

### 2.4 — إعادة تسمية `main` → `product_categories`

**السبب:** اسم `main` غامض ومحجوز جزئياً في SQL.

**SQL:**
```sql
START TRANSACTION;

-- 1. حذف الـ FK مؤقتاً (إذا تم تطبيق المرحلة 1)
ALTER TABLE `types` DROP FOREIGN KEY `fk_types_main`;

-- 2. إعادة التسمية
RENAME TABLE `main` TO `product_categories`;

-- 3. إعادة تسمية العمود في types
ALTER TABLE `types` CHANGE COLUMN `main` `category_id` INT NOT NULL;

-- 4. إعادة إضافة الـ FK باسم جديد
ALTER TABLE `types`
    ADD CONSTRAINT `fk_types_category`
        FOREIGN KEY (`category_id`) REFERENCES `product_categories`(`id`)
        ON DELETE RESTRICT;

-- 5. تحديث الفهرس القديم
ALTER TABLE `types` DROP INDEX `idx_main`;
ALTER TABLE `types` ADD INDEX `idx_category` (`category_id`);

COMMIT;
```

**ملفات Backend المطلوب تعديلها:**

| الملف | التعديل |
|-------|---------|
| `backend_farkha/app/prices/main_types.php` | استبدل `FROM main` بـ `FROM product_categories`، و`types.main` بـ `types.category_id` |
| `backend_farkha/app/prices/card_prices/types.php` | نفس التعديل |
| `backend_farkha/admin/` | ابحث في `admin/articles/` و`admin/prices/` عن أي مرجع لجدول `main` |

**أمر بحث للتأكد:**
```bash
cd /Users/nims/StudioProjects/farkha/backend_farkha
grep -rln "FROM main\|JOIN main\|\`main\`\|\.main " --include="*.php" | grep -v vendor
```

**ملفات Flutter المتأثرة:**
- `lib/data/data_source/remote/prices_data/` — إذا كان يقرأ حقل `main` مباشرة.

---

### 2.5 — `cycle_feedbacks` يكتب `user_id` و`cycle_id`

> هذا تكميل للمرحلة 1 (التي أضافت الأعمدة فقط).

**ملفات Backend المطلوب تعديلها:**

| الملف | التعديل |
|-------|---------|
| `backend_farkha/app/cycle_feedbacks/submit_feedback.php` | عند INSERT: مرّر `user_id` و`cycle_id` (إن توفرا في الطلب) |

**ملفات Flutter المتأثرة:**
- ابحث عن استدعاء submit_feedback وأضف `cycle_id` للـ payload لو متاح.

```bash
grep -rln "submit_feedback\|cycle_feedback" /Users/nims/StudioProjects/farkha/front_end/farkha_app/lib
```

---

<a name="المرحلة-3"></a>
## 🔴 المرحلة 3 — تأثير واسع (تأجيل موصى به)

> **توصية قوية:** لا تنفّذ هذه المرحلة الآن. هي لتوثيق الخطة المستقبلية فقط.
> نفّذها فقط عند ظهور حاجة فعلية (مشاكل أداء، multi-device push، أو فقدان بيانات).

### 3.1 — Soft Delete (`deleted_at`)

**SQL:**
```sql
ALTER TABLE `users` ADD COLUMN `deleted_at` DATETIME DEFAULT NULL,
                   ADD INDEX `idx_users_deleted_at` (`deleted_at`);
ALTER TABLE `cycles` ADD COLUMN `deleted_at` DATETIME DEFAULT NULL,
                    ADD INDEX `idx_cycles_deleted_at` (`deleted_at`);
ALTER TABLE `articles` ADD COLUMN `deleted_at` DATETIME DEFAULT NULL,
                      ADD INDEX `idx_articles_deleted_at` (`deleted_at`);
```

**ملفات Backend المتأثرة (~30+ ملف):**

كل SELECT/DELETE في:
- `app/cycles/*.php` (~22 ملف)
- `app/auth/*.php` (~9 ملفات)
- `app/articles/*.php` (~2 ملف)

**نمط التعديل:**
- استبدل `DELETE FROM users WHERE id=...` بـ `UPDATE users SET deleted_at=NOW() WHERE id=...`
- أضف `AND deleted_at IS NULL` لكل SELECT.

**التأثير على Flutter:** لا شيء (شفّاف من جهة الواجهة).

---

### 3.2 — جدول `user_devices` (Multi-device FCM)

**SQL:**
```sql
CREATE TABLE `user_devices` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT NOT NULL,
    `fcm_token` VARCHAR(255) NOT NULL,
    `platform` ENUM('android','ios') NOT NULL,
    `device_id` VARCHAR(100) DEFAULT NULL,
    `last_active` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY `uk_token` (`fcm_token`),
    INDEX `idx_user_id` (`user_id`),
    CONSTRAINT `fk_ud_user` FOREIGN KEY (`user_id`)
        REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Backfill من users.fcm_token
INSERT INTO user_devices (user_id, fcm_token, platform)
SELECT id, fcm_token, 'android' FROM users WHERE fcm_token IS NOT NULL AND fcm_token != '';

-- لاحقاً: حذف العمود القديم
-- ALTER TABLE users DROP COLUMN fcm_token;
```

**ملفات Backend المطلوب تعديلها:**

| الملف | التعديل |
|-------|---------|
| `backend_farkha/app/auth/update_fcm_token.php` | UPSERT في `user_devices` بدلاً من `users.fcm_token` |
| `backend_farkha/core/NotificationService.php` | اقرأ كل `fcm_token` من `user_devices` لكل user |
| `backend_farkha/models/UserModel.php` | احذف `fcm_token` بعد الاطمئنان |
| كل ملف يستخدم `fcm_token`: | راجع: `update_member_role.php`, `create_invitation.php`, `respond_to_invitation.php`, `add_member.php`, `delete_account.php`, `update_status.php`, `update_phone.php`, `resend_otp.php`, `send_otp.php`, `verify_otp.php`, `delete_cycle_item.php`, `notes/delete_note.php`, إلخ. |

**ملفات Flutter المطلوب تعديلها:**

| الملف | التعديل |
|-------|---------|
| `lib/core/services/notification_service.dart` | عند تحديث FCM token، أرسل أيضاً `device_id` و`platform` |
| `lib/data/data_source/remote/auth_data/` | تعديل `update_fcm_token` payload |
| `lib/core/constant/id/api.dart` | لا تغيير في endpoint URL |

---

### 3.3 — EAV Refactor لـ `cycle_data`

**السبب:** حالياً `label VARCHAR + value VARCHAR` بدون فاليديشن.

**SQL:**
```sql
ALTER TABLE `cycle_data`
    ADD COLUMN `metric_type` ENUM('weight','mortality','feed','water','temperature','humidity','medicine','other')
        NOT NULL DEFAULT 'other' AFTER `cycle_id`,
    ADD COLUMN `numeric_value` DECIMAL(10,2) DEFAULT NULL,
    ADD COLUMN `text_value` VARCHAR(255) DEFAULT NULL,
    ADD INDEX `idx_cd_cycle_metric_date` (`cycle_id`, `metric_type`, `entry_date`);

-- Backfill (يدوي بناءً على القيم الموجودة في label)
UPDATE cycle_data SET metric_type='weight', numeric_value=CAST(value AS DECIMAL(10,2))
    WHERE label LIKE '%وزن%';
UPDATE cycle_data SET metric_type='mortality', numeric_value=CAST(value AS DECIMAL(10,2))
    WHERE label LIKE '%نفوق%';
-- إلخ...

-- لاحقاً (بعد التأكد):
-- ALTER TABLE cycle_data DROP COLUMN label, DROP COLUMN value;
```

**ملفات Backend المطلوب تعديلها:**

| الملف | التعديل |
|-------|---------|
| `backend_farkha/app/cycles/add_data.php` | استقبل `metric_type` بدلاً من `label`، وحدّد إذا `numeric_value` أو `text_value` |
| `backend_farkha/app/cycles/get_cycle_details.php` | عرض حسب `metric_type` |
| `backend_farkha/app/cycles/delete_cycle_item.php` | إذا فيه فلترة حسب نوع |
| `backend_farkha/models/CycleModel.php` | تحديث الموديل |

**ملفات Flutter المطلوب تعديلها:**

| الملف | التعديل |
|-------|---------|
| `lib/data/model/cycle/` | تحديث موديل بيانات الدورة |
| `lib/logic/controller/cycle_data_entry_mixin.dart` | إرسال `metric_type` بدلاً من `label` |
| `lib/logic/controller/cycle_custom_data_controller.dart` | تعديل البنية |
| `lib/logic/controller/cycle_controller_base.dart` | معالجة الأنواع |
| `lib/data/data_source/remote/cycle_data/` | تعديل API |
| `lib/view/widget/cycle/` | عرض البيانات حسب النوع |

---

### 3.4 — تتبع زمني لـ `tools_usage`

**حالياً:** عمود `usage_count` يفقد التاريخ.

**SQL (إضافة جدول أحداث منفصل):**
```sql
CREATE TABLE `tools_usage_events` (
    `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT NOT NULL,
    `tool_name` VARCHAR(100) NOT NULL,
    `used_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_tue_user` (`user_id`),
    INDEX `idx_tue_tool` (`tool_name`),
    INDEX `idx_tue_used_at` (`used_at`),
    CONSTRAINT `fk_tue_user` FOREIGN KEY (`user_id`)
        REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

**ملفات Backend المتأثرة:**

| الملف | التعديل |
|-------|---------|
| `backend_farkha/analytics/record_tools_usage.php` | INSERT في الجدول الجديد بالإضافة للقديم |
| `backend_farkha/analytics/tools_analytics.php` | استعلامات زمنية على الجدول الجديد |

---

<a name="اختبار-شامل"></a>
## ✅ اختبار شامل بعد كل مرحلة

### بعد المرحلة 1
```bash
cd /Users/nims/StudioProjects/farkha/front_end/farkha_app
flutter analyze
flutter test
flutter run --dart-define-from-file=.env  # اختبر يدوياً: تسجيل دخول، إنشاء دورة، إضافة بيانات
```

**سيناريوهات يدوية:**
- [ ] تسجيل دخول
- [ ] إنشاء دورة جديدة (تحقق من `updated_at`)
- [ ] إضافة بيانات وقراءتها (الفهارس الجديدة)
- [ ] إرسال تقييم (`app_reviews` rating CHECK)

### بعد المرحلة 2
كل اختبارات المرحلة 1 + ما يلي:

- [ ] تسجيل برقم موجود مسبقاً → رسالة `phone_already_used`
- [ ] إنشاء دورة → تحقق `owner_user_id` في DB
- [ ] إنشاء دعوة → تحقق `created_by_user_id`
- [ ] استخدام كود دعوة → تحقق `status='used'`
- [ ] محاولة استخدام كود مستخدم سابقاً → يُرفض
- [ ] قراءة الأسعار (بعد تغيير اسم `main`)

### بعد المرحلة 3
اختبارات شاملة + integration tests الموجودة في `front_end/farkha_app/integration_test/`.

---

<a name="rollback"></a>
## 🔄 استراتيجية التراجع

### المرحلة 1
ملف Rollback موجود في تعليقات `2026_05_06_database_improvements.sql`.

### المرحلة 2 و3
لكل تعديل، أنشئ ملف rollback مرافق:
```
backend_farkha/migrations/rollback_<date>_<change>.sql
```

### في حال الفشل الكامل
```bash
# استرجع من النسخة الاحتياطية
mysql -u root -p farkha_db < backup_YYYYMMDD_HHMMSS.sql

# تراجع git commits
cd /Users/nims/StudioProjects/farkha
git reset --hard HEAD~N  # حسب عدد الـ commits المعنية
```

---

## 📝 ملاحظات للمنفّذ

1. **اشتغل بالترتيب:** المرحلة 1 → اختبار → commit → المرحلة 2 → اختبار → commit.
2. **لا تجمع المراحل في commit واحد.** كل مرحلة في commit مستقل.
3. **لو واجهت قيم يتيمة** عند تطبيق FK: لا تحذف البيانات تلقائياً — اسأل المستخدم.
4. **رسائل الـ commit:**
   - المرحلة 1: `db: phase 1 — indexes, FKs, updated_at, rating CHECK`
   - المرحلة 2.1: `db: phase 2.1 — phone UNIQUE constraint + backend duplicate check`
   - إلخ.
5. **المرحلة 3 لا تنفّذ بدون موافقة صريحة من المستخدم.**

---

## 🗂️ ملفات مرجعية

| الملف | الغرض |
|-------|-------|
| `backend_farkha/migrations/schema.sql` | السكيما الكاملة الحالية |
| `backend_farkha/migrations/2026_05_06_database_improvements.sql` | هجرة المرحلة 1 (جاهزة) |
| `backend_farkha/migrations/2026_04_20_add_phone_verifications.sql` | هجرة OTP السابقة |
| `backend_farkha/migrations/2026_04_22_add_cycle_feedbacks.sql` | هجرة Feedbacks السابقة |

---

**نهاية الوثيقة.** أي سؤال غامض → اسأل المستخدم قبل التنفيذ.
