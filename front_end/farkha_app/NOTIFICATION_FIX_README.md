# حل مشكلة الإشعارات في تطبيق فرخة

## المشكلة
كانت الإشعارات تصل إلى التطبيق لكنها لا تظهر على الشاشة إلا بعد تفعيلها يدوياً من إعدادات النظام في قناة "Miscellaneous".

## السبب
في Android 8.0+ (API level 26)، يجب إنشاء **Notification Channel** مخصصة قبل إرسال الإشعارات. عندما لا يتم إنشاء قناة مخصصة، تذهب الإشعارات تلقائياً إلى قناة "Miscellaneous" الافتراضية التي تكون معطلة في معظم الأجهزة.

## الحل المطبق

### 1. إضافة المكتبة المطلوبة
تم إضافة `flutter_local_notifications: ^18.0.1` إلى `pubspec.yaml`

### 2. تحديث AndroidManifest.xml
تم إضافة الأذونات المطلوبة:
```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.VIBRATE" />
```

وتم إضافة إعدادات Firebase Cloud Messaging:
```xml
<meta-data
    android:name="com.google.firebase.messaging.default_notification_channel_id"
    android:value="farkha_notifications_channel"/>
```

### 2.1. تحديث build.gradle.kts
تم تفعيل **Core Library Desugaring** لدعم Java 8+ APIs على الأجهزة القديمة:
```kotlin
compileOptions {
    isCoreLibraryDesugaringEnabled = true
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}
```
هذا مطلوب من `flutter_local_notifications` للعمل بشكل صحيح.

### 3. إنشاء خدمة إدارة الإشعارات (notification_service.dart)
تم إنشاء `lib/core/services/notification_service.dart` التي تقوم بـ:
- إنشاء Notification Channel مخصصة بأهمية عالية (High Importance)
- طلب أذونات الإشعارات تلقائياً
- معالجة الإشعارات في الحالات الثلاث:
  - عندما يكون التطبيق مفتوح (Foreground)
  - عندما يكون التطبيق في الخلفية (Background)
  - عندما يكون التطبيق مغلق (Terminated)
- الاشتراك وإلغاء الاشتراك في Topics

### 4. تهيئة الخدمة عند بدء التطبيق
تم تعديل `lib/core/services/initialization.dart` لتهيئة خدمة الإشعارات تلقائياً عند بدء التطبيق.

### 5. تحديث Home Screen
تم تحديث `lib/view/screen/home.dart` لاستخدام الخدمة الجديدة بدلاً من استدعاء Firebase Messaging مباشرة.

## المميزات الجديدة

### 1. إشعارات تظهر تلقائياً
الآن جميع الإشعارات ستظهر على الشاشة فوراً بدون الحاجة لتفعيلها يدوياً.

### 2. قناة إشعارات مخصصة
تم إنشاء قناة باسم "إشعارات فرخة" بإعدادات:
- أهمية عالية (High Importance)
- صوت مُفعّل
- اهتزاز مُفعّل
- إظهار Badge

### 3. معالجة شاملة للإشعارات
الخدمة تتعامل مع جميع حالات الإشعارات:
- إشعارات أثناء استخدام التطبيق
- إشعارات أثناء وجود التطبيق في الخلفية
- إشعارات أثناء إغلاق التطبيق
- النقر على الإشعارات

### 4. طلب الأذونات تلقائياً
الأذونات يتم طلبها بشكل منظم عبر:
- **Android**: `PermissionController` يطلب أذونات الإشعارات عند فتح التطبيق
- **ملاحظة**: التطبيق مخصص لـ Android فقط، لذا تم إزالة جميع الأكواد الخاصة بـ iOS

## كيفية الاستخدام

### الاشتراك في Topic
```dart
NotificationService.instance.subscribeToTopic('topic_name');
```

### إلغاء الاشتراك من Topic
```dart
NotificationService.instance.unsubscribeFromTopic('topic_name');
```

### إرسال إشعار يدوي
```dart
// يتم معالجة الإشعارات تلقائياً عند استلامها من Firebase
// لا حاجة لاستدعاء showNotification يدوياً
```

## ملاحظات مهمة

### 1. اختبار الإشعارات
- قم بإلغاء تثبيت التطبيق القديم تماماً قبل تثبيت النسخة الجديدة
- هذا يضمن إنشاء Notification Channel جديدة بالإعدادات الصحيحة

### 2. Token للاختبار
عند بدء التطبيق، يتم طباعة FCM Token في Console:
```
FCM Token: xxxxx
```
يمكن استخدام هذا Token لإرسال إشعارات تجريبية من Firebase Console.

### 3. تخصيص الإشعارات
يمكن تخصيص إعدادات القناة من ملف `notification_service.dart`:
- تغيير اسم القناة
- تعديل الأهمية (Importance)
- تعطيل/تفعيل الصوت أو الاهتزاز

## إرسال إشعارات من Firebase Console

عند إرسال إشعار من Firebase Console، استخدم هذا التنسيق:

```json
{
  "notification": {
    "title": "عنوان الإشعار",
    "body": "محتوى الإشعار"
  },
  "android": {
    "notification": {
      "channel_id": "farkha_notifications_channel"
    }
  },
  "topic": "lhm_abyad"
}
```

## حل التضارب في طلب الأذونات

### المشكلة الثانية التي ظهرت:
```
[firebase_messaging/unknown] A request for permissions is already running
```

### السبب:
كان هناك تضارب بين:
- `NotificationService` يطلب أذونات الإشعارات في `init()`
- `PermissionController` يطلب نفس الأذونات في `onInit()`
- كلاهما يعملان في نفس الوقت!

### الحل المطبق:
تم فصل المسؤوليات:
- **Android**: `PermissionController` فقط يطلب أذونات الإشعارات
- **NotificationService**: إزالة طلب الأذونات من هنا لتجنب التضارب
- **تنظيف الكود**: إزالة جميع الأكواد الخاصة بـ iOS لأن التطبيق Android فقط
- **النتيجة**: لا يوجد تضارب ✅

## التحقق من نجاح الحل

بعد تطبيق هذا الحل:
1. ✅ الإشعارات تظهر فوراً بدون الدخول للإعدادات
2. ✅ القناة تظهر باسم "إشعارات فرخة" في إعدادات النظام
3. ✅ الإشعارات تعمل في جميع حالات التطبيق
4. ✅ يتم طلب الأذونات تلقائياً بدون تضارب
5. ✅ لا توجد أخطاء في Console

## الدعم الفني

في حالة وجود أي مشاكل:
1. تأكد من إلغاء تثبيت النسخة القديمة تماماً
2. تحقق من أن Firebase متصل بشكل صحيح
3. تأكد من وجود ملف `google-services.json` في `android/app/`
4. راجع الـ Console للتأكد من عدم وجود أخطاء

