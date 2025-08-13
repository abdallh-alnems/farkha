# تطبيق Server-Sent Events (SSE) في Flutter

## التعديلات المطبقة

### 1. إضافة Dependency
تم إضافة `sse: ^4.1.0` إلى `pubspec.yaml`

### 2. إنشاء خدمة SSE
تم إنشاء `SseService` في `lib/core/services/sse_service.dart` للتعامل مع Server-Sent Events

### 3. تحديث الـ Controller
تم تحديث `FarkhAbidController` لاستخدام SSE مع fallback للطريقة التقليدية

### 4. إنشاء Binding
تم إنشاء `InitialBinding` لإضافة خدمة SSE

### 5. تحديث الـ Widget
تم إضافة مؤشر الاتصال المباشر في `CardPriceFarkhAbidHome`

## كيفية التشغيل

### 1. تثبيت Dependencies
```bash
cd front_end/farkha_app
flutter pub get
```

### 2. التأكد من تشغيل الخادم
تأكد من أن ملف `farkh_abid.php` يعمل على الخادم

### 3. تشغيل التطبيق
```bash
flutter run
```

## المميزات الجديدة

- **تحديث فوري**: الأسعار تتحدث فورياً عند تغييرها في قاعدة البيانات
- **مؤشر الاتصال**: مؤشر بصري لحالة الاتصال (أخضر = متصل، أحمر = غير متصل)
- **إعادة الاتصال التلقائي**: إذا انقطع الاتصال، سيحاول إعادة الاتصال
- **Fallback**: إذا فشل SSE، يستخدم الطريقة التقليدية
- **إدارة الموارد**: إغلاق الاتصالات عند إغلاق الـ Controller

## ملاحظات مهمة

1. تأكد من أن الخادم يدعم CORS
2. تأكد من أن الـ URL صحيح في `link_api.dart`
3. قد تحتاج إلى إضافة permissions في Android/iOS إذا لزم الأمر

## استكشاف الأخطاء

إذا واجهت مشاكل:

1. تحقق من console logs للـ SSE
2. تأكد من أن الخادم يعمل
3. تحقق من الـ network permissions
4. جرب الطريقة التقليدية كـ fallback



