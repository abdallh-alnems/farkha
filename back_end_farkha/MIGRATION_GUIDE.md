# دليل الانتقال من Farkha API v1.0 إلى v2.0

## 📋 نظرة عامة

تم إعادة هيكلة المشروع بالكامل لتحسين الأمان والأداء والقابلية للصيانة. هذا الدليل يوضح كيفية الانتقال من النظام القديم إلى النظام الجديد.

## 🔄 التغييرات الرئيسية

### 1. هيكل المشروع
**قديم:**
```
├── connect.php
├── function.php
├── config.php
├── create/
│   ├── add.php
│   └── suggestion.php
└── read/
    ├── main.php
    ├── last_prices.php
    └── ...
```

**جديد:**
```
├── app/
│   ├── config/
│   ├── controllers/
│   ├── core/
│   ├── middleware/
│   ├── models/
│   └── utils/
├── public/
│   ├── index.php
│   └── routes.php
└── logs/
```

### 2. نقاط النهاية (Endpoints)

| النظام القديم | النظام الجديد | الملاحظات |
|--------------|--------------|----------|
| `POST /create/add.php` | `POST /prices/add` | ✅ إعادة توجيه تلقائية |
| `POST /create/suggestion.php` | `POST /suggestions/add` | ✅ إعادة توجيه تلقائية |
| `GET /read/main.php` | `GET /main` | ✅ إعادة توجيه تلقائية |
| `GET /read/last_prices.php` | `POST /prices/by-type` | ✅ إعادة توجيه تلقائية |
| `GET /read/web_last_prices.php` | `GET /prices/web` | ✅ إعادة توجيه تلقائية |
| `GET /read/farkh_abid.php` | `GET /prices/latest?type=1` | ✅ إعادة توجيه تلقائية |
| `GET /read/feasibility_study.php` | `GET /prices/feasibility-study` | ✅ إعادة توجيه تلقائية |

## 🛠️ خطوات الانتقال

### الخطوة 1: النسخ الاحتياطي
```bash
# إنشاء نسخة احتياطية من النظام القديم
cp -r /path/to/old/project /path/to/backup/
```

### الخطوة 2: تحديث إعدادات الخادم
```apache
# تحديث DocumentRoot في Apache
DocumentRoot /path/to/project/public

# أو إضافة Virtual Host
<VirtualHost *:80>
    DocumentRoot /path/to/project/public
    ServerName farkha-api.local
</VirtualHost>
```

### الخطوة 3: إعداد متغيرات البيئة
```bash
# نسخ ملف الإعدادات
cp env.example .env

# تحرير الإعدادات
nano .env
```

**ملف .env:**
```env
# من config.php القديم
DB_HOST=localhost
DB_NAME=farkha
DB_USER=root
DB_PASS=

# من function.php القديم
BASIC_AUTH_USER=NiMs_farkha
BASIC_AUTH_PASS=Abdallh29512A

# إعدادات جديدة
JWT_SECRET=your-new-secure-secret-key
APP_DEBUG=false
```

### الخطوة 4: تحديث أذونات الملفات
```bash
chmod 755 logs/
chmod 644 .env
chmod 755 public/
```

### الخطوة 5: اختبار النظام
```bash
# فحص الصحة
curl http://localhost/health

# اختبار API قديم (يجب أن يعيد توجيه)
curl -I http://localhost/read/main.php

# اختبار API جديد
curl http://localhost/main
```

## 🔧 تحديث التطبيقات العميلة

### للتطبيقات التي تستخدم النظام القديم:

#### 1. لا حاجة لتغيير فوري
- النظام الجديد يدعم إعادة التوجيه التلقائية
- الاستجابات تحافظ على نفس التنسيق

#### 2. التحديث المُوصى به (اختياري):
```dart
// قديم
final response = await http.post(
  Uri.parse('$baseUrl/create/add.php'),
  body: {'price': '25.50', 'type_id': '1'}
);

// جديد (مُوصى به)
final response = await http.post(
  Uri.parse('$baseUrl/prices/add'),
  body: {'price': '25.50', 'type_id': '1'}
);
```

## 📊 مقارنة الميزات

| الميزة | النظام القديم | النظام الجديد |
|-------|--------------|--------------|
| **الأمان** | ⚠️ Basic Auth فقط | ✅ JWT + Basic Auth |
| **التحقق من البيانات** | ⚠️ محدود | ✅ شامل ومفصل |
| **معالجة الأخطاء** | ❌ أساسية | ✅ متقدمة مع logging |
| **الأداء** | ⚠️ متوسط | ✅ محسّن |
| **التوثيق** | ❌ غير موجود | ✅ مدمج في API |
| **CORS** | ⚠️ أساسي | ✅ قابل للتكوين |
| **التحكم بالإصدارات** | ❌ غير موجود | ✅ مدمج |
| **البيئات المتعددة** | ❌ غير مدعوم | ✅ مدعوم |

## 🔒 تحسينات الأمان

### 1. حماية كلمات المرور
```php
// قديم: في الكود مباشرة
define('PHP_PASS', "Abdallh29512A");

// جديد: في متغيرات البيئة
BASIC_AUTH_PASS=your_secure_password
```

### 2. التحقق من البيانات
```php
// قديم: تحقق بسيط
$price = filterRequset('price');

// جديد: تحقق شامل
$validator->required('price')
          ->numeric('price')
          ->positive('price');
```

### 3. معالجة الأخطاء
```php
// قديم: عرض الأخطاء مباشرة
echo $e->getMessage();

// جديد: logging آمن
Logger::error($e->getMessage());
ResponseHandler::serverError('Internal server error');
```

## 📈 فوائد النظام الجديد

### 1. **أمان محسّن**
- JWT tokens للمصادقة
- تشفير متقدم لكلمات المرور
- حماية من SQL Injection و XSS
- CORS قابل للتكوين

### 2. **أداء أفضل**
- Connection pooling
- Prepared statements caching
- استعلامات محسّنة
- Response caching

### 3. **قابلية الصيانة**
- كود منظم ومهيكل
- فصل الاهتمامات (Separation of concerns)
- Repository pattern
- Dependency injection

### 4. **مراقبة محسّنة**
- Logging شامل
- Error tracking
- Performance monitoring
- Health checks

## 🚨 أمور مهمة للانتباه

### 1. **قاعدة البيانات**
- لا حاجة لتغيير في هيكل قاعدة البيانات
- النظام الجديد يعمل مع نفس الجداول

### 2. **الملفات القديمة**
- يمكن الاحتفاظ بها كنسخة احتياطية
- لا تؤثر على النظام الجديد

### 3. **التطبيقات العميلة**
- ستعمل بدون تغيير (إعادة توجيه تلقائية)
- يُفضل التحديث للنقاط الجديدة تدريجياً

## 📞 المساعدة والدعم

### في حالة وجود مشاكل:

1. **تحقق من logs:**
   ```bash
   tail -f logs/app.log
   ```

2. **اختبر health check:**
   ```bash
   curl http://localhost/health
   ```

3. **تحقق من إعدادات .env**

4. **تحقق من أذونات الملفات**

### رسائل الخطأ الشائعة:

| الخطأ | السبب | الحل |
|-------|-------|-----|
| "Database connection failed" | خطأ في إعدادات قاعدة البيانات | تحقق من .env |
| "Missing authentication" | Basic Auth غير مُعدّ | تحقق من username/password |
| "Permission denied" | أذونات الملفات | `chmod 755 logs/` |

---

**نصيحة:** ابدأ بتشغيل النظامين جنباً إلى جنب للتأكد من الاستقرار قبل إيقاف النظام القديم نهائياً.
