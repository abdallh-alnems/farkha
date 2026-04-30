# خطة إعادة هيكلة مشروع فرخة (Farkha)

> **الهدف:** تنظيف المشروع، حذف الكود الميت، توحيد التكرار، تحسين أسماء الملفات، وإزالة الحزم غير المستخدمة.
> **النطاق:** `front_end/farkha_app` بشكل أساسي.
> **المنفذ:** هذه الخطة وثيقة تنفيذية لنموذج آخر — كل بند يمكن قراءته وتنفيذه بشكل مستقل.
> **مبدأ عام:** كل تعديل يجب أن يُتبع بـ `flutter analyze` و `flutter test`. لا تدمج تعديلات عدة في commit واحد.

---

## 📊 الملخص التنفيذي

| المحور | عدد العناصر | حجم الأثر |
|---|---|---|
| حزم للحذف | 4 حزم | تقليل حجم الـ APK |
| حزم للمراجعة | 23 حزمة (1-2 استخدام) | تقليل التعقيد |
| ملفات ميتة | 6 ملفات | -411 سطر |
| route ميت | 1 (`/adad`) | تنظيف الراوتر |
| تكرار في الـ widgets | 4 فئات (buttons, dialogs, cards) | -30% كود مكرر |
| تكرار في الـ data layer | 9 ملفات بنفس boilerplate | base class واحد |
| تكرار في الـ controllers | 20+ controller | base controller |
| ملفات تحتاج إعادة تسمية | 11 ملف | اتساق أعلى |

---

## 1️⃣ المرحلة الأولى: حذف الحزم غير المستخدمة

### 1.1 حذف فوري (0 استخدامات) — `pubspec.yaml`

احذف الأسطر التالية من `front_end/farkha_app/pubspec.yaml`:

```yaml
cupertino_icons: ^1.0.8        # غير مستخدمة
connectivity_plus: ^7.0.0       # غير مستخدمة
gma_mediation_meta: ^1.5.1      # غير مستخدمة
percent_indicator: ^4.2.5       # غير مستخدمة
```

> ⚠️ **`markdown` لا تُحذف:** رغم أنها تبدو كأنها مغطّاة بـ `flutter_markdown`، فهي مُستوردة مباشرة في `lib/view/screen/tools/articles/article_detail.dart` كـ `md` namespace لاستخدام `md.Text` داخل custom `MarkdownElementBuilder`. الإبقاء عليها مطلوب.

**خطوات التنفيذ:**
1. احذف الأسطر الخمسة من `pubspec.yaml`
2. شغّل `flutter pub get`
3. شغّل `flutter analyze` للتأكد من عدم وجود استيرادات معلقة
4. شغّل `flutter build apk --debug` للتحقق

> **ملاحظة:** قبل حذف `connectivity_plus`، تحقق من أن `lib/logic/controller/internet_controller.dart` لا يستخدمها فعلاً (قد يكون بآلية أخرى مثل `dart:io InternetAddress.lookup`). إن كان يستخدمها فعلاً وكنا فقط لم نلتقطها بالـ grep، أعد الإضافة.

### 1.2 حزم للمراجعة (1 استخدام فقط)

كل حزمة من هذه يجب التحقق من قيمتها:

| الحزمة | الملف الوحيد المستخدم | التوصية |
|---|---|---|
| `font_awesome_flutter` | `view/widget/drawer/drawer.dart` | استبدلها بـ `Icons` المدمجة في Flutter أو `flutter_svg` |
| `vector_math` | `core/shared/snackbar_message.dart` | تحقّق من الاستخدام — قد يمكن الاستغناء عنه |
| `flutter_localization` | `main.dart` + ملف اختبار | احذفها — `flutter_localizations` (SDK) + `intl` كافيان |
| `weather_icons` | `view/widget/cycle/environment_status.dart` | احتفظ إن كانت رموز الطقس ضرورية |
| `flutter_markdown` | `view/screen/tools/articles/article_detail.dart` | احتفظ إن كانت المقالات بصيغة Markdown |

**قاعدة:** لا تحذف أي حزمة بدون قراءة الملف الوحيد الذي يستخدمها أولاً.

---

## 2️⃣ المرحلة الثانية: حذف الملفات الميتة

### 2.1 ملفات للحذف الفوري (لا تستوردها أي ملف آخر)

```
lib/view/widget/onboarding/feasibility_study_onboarding.dart   ← ملف فارغ (0 سطر)
lib/view/widget/cycle/cycle_expenses_card.dart                  ← 133 سطر، widget يتيم
lib/view/widget/drawer/drawer_menu_items.dart                   ← 77 سطر، widget يتيم
lib/view/widget/tools/tools_result.dart                         ← 45 سطر، widget يتيم
lib/core/services/notifications/cycle/smart_alerts.dart         ← 121 سطر، service لم يُربط بشيء
lib/data/model/cycle_feedback_model.dart                        ← 33 سطر، model غير مستخدم
```

**خطوات التحقق قبل الحذف (لكل ملف):**
```bash
grep -rln "<اسم_الكلاس>" lib/ test/   # يجب ألا يعطي نتائج
grep -rln "<اسم_الملف_بدون_dart>" lib/ test/
```

> **تحذير لـ `cycle_feedback_model.dart`:** هذه ميزة حديثة (cycle-rating). تأكد من أن `cycle_feedback_controller.dart` لا يحتاجه فعلاً قبل الحذف — إذا كان يستخدم Map خام بدلاً من Model، فربما يجب الإبقاء عليه واستخدامه (تحسين، ليس حذف).

### 2.2 Routes ميتة

في `lib/core/constant/routes/route.dart`:
- احذف ثابت `'/adad'` — غير مرجَّع في أي `Get.toNamed` أو `Get.offNamed`.
- في `lib/core/constant/routes/get_page.dart`: احذف الـ `GetPage` المقابل لو موجود.

### 2.3 توضيح بشأن "الملفات المتطابقة الأسماء"

الملفات التالية لها نفس الاسم في مسارات مختلفة — **هذه ليست ازدواجية فعلية** لأن كل ملف يخدم طبقة مختلفة:

| اسم الملف | المسار 1 | المسار 2 | الإجراء |
|---|---|---|---|
| `cycle_data.dart` | `view/screen/cycle/` | `data/data_source/remote/cycle_data/` | أعد تسمية الـ screen إلى `cycle_data_screen.dart` |
| `disease_details.dart` | `view/widget/tools/disease/` | `view/screen/tools/disease/` | الأول widget والثاني screen — أعد تسمية الثاني إلى `disease_details_screen.dart` |
| `prices_by_type.dart` | `view/screen/prices/` | `data/data_source/remote/prices_data/` | أعد تسمية الـ screen إلى `prices_by_type_screen.dart` |

---

## 3️⃣ المرحلة الثالثة: تقليل التكرار (DRY)

### 3.1 توحيد الأزرار (5 تطبيقات مختلفة لنفس الزر)

**الملفات الحالية:**
- `view/widget/onboarding/custom_button.dart`
- `view/widget/onboarding/skip_button.dart`
- `view/widget/tools/tools_button.dart`
- `core/shared/action_button.dart`
- `view/widget/tutorial/widgets/tutorial_action_buttons.dart`

**الحل:** أنشئ `lib/core/shared/buttons/app_button.dart`:
```dart
enum AppButtonVariant { primary, secondary, text, outlined }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool fullWidth;
  final bool loading;
  // ...
}
```

ثم استبدل كل الاستعمالات بـ `AppButton(variant: ...)`.
اترك الأزرار الخاصة جداً (مثل زر إعلان interstitial) كما هي.

### 3.2 توحيد الـ Dialogs

**الملفات الحالية:**
- `view/widget/dialog/darkness_permission_dialog.dart`
- `view/widget/dialog/darkness_suggestion_dialog.dart`
- `core/shared/permissions_intro_dialog.dart`
- `core/shared/usage_tips_dialog.dart`

**الحل:** أنشئ `lib/core/shared/dialogs/app_alert_dialog.dart`:
```dart
class AppAlertDialog extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final String primaryActionLabel;
  final VoidCallback primaryAction;
  final String? secondaryActionLabel;
  final VoidCallback? secondaryAction;
}
```

استبدل الأربعة باستدعاء `AppAlertDialog(...)` مباشرة.

### 3.3 توحيد طبقة الـ API (الأهم)

**المشكلة:** كل ملف في `lib/data/data_source/remote/**/*.dart` يكرر نفس الـ pattern:
```dart
if (await this.checkInternet()) {
  var response = await crud.postData(url, data);
  return response.fold((l) => l, (r) => r);
} else {
  return StatusRequest.offlinefailure;
}
```
يتكرر في: `auth_data/login_data.dart`, `send_otp_data.dart`, `verify_otp_data.dart`, `update_name_data.dart`, `delete_account_data.dart`, `prices_data/main_types_data.dart`, `types_data.dart`, `prices_card_data.dart` + غيرها.

**الحل:** أنشئ `lib/data/data_source/remote/base_remote_data.dart`:
```dart
abstract class BaseRemoteData {
  final Crud crud;
  BaseRemoteData(this.crud);

  Future<dynamic> request({
    required String url,
    Map<String, String>? data,
    bool isPost = true,
  }) async {
    if (!await checkInternet()) return StatusRequest.offlinefailure;
    final response = isPost
      ? await crud.postData(url, data ?? {})
      : await crud.getData(url);
    return response.fold((l) => l, (r) => r);
  }
}
```

ثم كل data class:
```dart
class LoginData extends BaseRemoteData {
  LoginData(super.crud);
  Future login(String email, String password) =>
      request(url: AppLink.login, data: {'email': email, 'password': password});
}
```

### 3.4 توحيد الـ Controllers (Base Controller)

**المشكلة:** كل قائمة controller تكرر:
- `StatusRequest statusRequest = StatusRequest.none`
- `update()` يدوي بعد كل تغيير
- معالجة الأخطاء نفسها

**الحل:** أنشئ `lib/logic/controller/base/base_list_controller.dart`:
```dart
abstract class BaseListController<T> extends GetxController {
  StatusRequest statusRequest = StatusRequest.none;
  List<T> items = [];

  Future<dynamic> fetchItems();
  T fromJson(Map<String, dynamic> json);

  Future<void> load() async {
    statusRequest = StatusRequest.loading;
    update();

    final response = await fetchItems();
    statusRequest = handlingData(response);

    if (statusRequest == StatusRequest.success) {
      if (response['status'] == 'success') {
        items = (response['data'] as List).map((e) => fromJson(e)).toList();
      } else {
        statusRequest = StatusRequest.failure;
      }
    }
    update();
  }
}
```

طبّق على: `MainTypesController`, `PricesByTypeController`, `ArticlesListController`، وأي قائمة أخرى.

### 3.5 توحيد الستايلات (Theme)

**المشكلة:** `BorderRadius.circular(10.r)` يتكرر **77 مرة**، `12.r` يتكرر **66 مرة**، إلخ.

**الحل:** وسّع `lib/core/constant/theme/theme.dart`:
```dart
class AppDimens {
  static double get radiusSm => 8.r;
  static double get radiusMd => 12.r;
  static double get radiusLg => 16.r;
  static double get radiusXl => 20.r;

  static BorderRadius get borderSm => BorderRadius.circular(radiusSm);
  static BorderRadius get borderMd => BorderRadius.circular(radiusMd);
}

class AppSpacing {
  static double get xs => 4.h;
  static double get sm => 8.h;
  static double get md => 12.h;
  static double get lg => 16.h;
  static double get xl => 24.h;

  static EdgeInsets get padMd => EdgeInsets.all(md);
  static EdgeInsets get padLg => EdgeInsets.all(lg);
}
```

ثم استبدل تدريجياً (نمط واحد في كل commit).

### 3.6 توحيد النصوص العربية

**المشكلة:** نصوص مثل `'متابعة'`, `'تخطي'`, `'تنبيهات الإظلام'` متكررة في عدة ملفات.

**الحل:** أنشئ `lib/core/constant/strings/app_strings.dart`:
```dart
class AppStrings {
  AppStrings._();

  // Actions
  static const String continueAction = 'متابعة';
  static const String skip = 'تخطي';
  static const String cancel = 'إلغاء';
  static const String confirm = 'تأكيد';

  // Darkness alerts
  static const String darknessAlerts = 'تنبيهات الإظلام';
  // ...
}
```

> **ملاحظة:** هذا ليس i18n حقيقي، فقط تجميع. لاحقاً يمكن الترقية إلى `intl` ARB إذا أراد المالك دعم الإنجليزية.

### 3.7 توحيد مفاتيح GetStorage

أنشئ `lib/core/constant/storage_keys.dart`:
```dart
class StorageKeys {
  StorageKeys._();
  // Auth
  static const String userToken = 'user_token';
  static const String isLoggedIn = 'is_logged_in';
  // App lifecycle
  static const String firstLaunchAt = 'first_launch_at';
  // Reviews
  static const String reviewSubmitted = 'review_submitted';
  static const String cycleReviewSubmitted = 'cycle_review_submitted';
  static const String cycleReviewShownAt = 'cycle_review_shown_at';
  // Theme
  static const String themeMode = 'theme_mode';
  // Onboarding
  static const String onboardingDone = 'onboarding_done';
}
```

استبدل كل سلاسل المفاتيح المباشرة في الكود بهذه الثوابت.

### 3.8 توحيد ArabicToEnglish digit formatter

**المشكلة:** التحويل من أرقام عربية إلى إنجليزية معرَّف في مكانين:
- `core/shared/input_fields/input_field.dart:64` (private)
- `core/functions/input_validation.dart`

**الحل:** اجعله public في `input_validation.dart`، احذف التعريف الخاص في `input_field.dart`، استورده.

---

## 4️⃣ المرحلة الرابعة: إعادة تسمية الملفات

### 4.1 تصحيحات الإملاء

| الحالي | الجديد |
|---|---|
| `core/functions/handing_data_controller.dart` | `core/functions/handling_data_controller.dart` |

### 4.2 إضافة الـ suffix الواضح للشاشات

| الحالي | الجديد |
|---|---|
| `view/screen/home.dart` | `view/screen/home_screen.dart` |
| `view/screen/onboarding.dart` | `view/screen/onboarding_screen.dart` |
| `view/screen/cycle/cycle_data.dart` | `view/screen/cycle/cycle_data_screen.dart` |
| `view/screen/prices/main_types.dart` | `view/screen/prices/main_types_screen.dart` |
| `view/screen/prices/prices_by_type.dart` | `view/screen/prices/prices_by_type_screen.dart` |
| `view/screen/tools/disease/disease_details.dart` | `view/screen/tools/disease/disease_details_screen.dart` |

### 4.3 توضيح أسماء الـ services

| الحالي | الجديد |
|---|---|
| `core/services/env.dart` | `core/services/environment_service.dart` |

> **لا تضف `_widget` لكل widget** — هذا ليس conv. Flutter standard. اكتفِ بأسماء وصفية (`cycle_card.dart` كافٍ، لا يحتاج `cycle_card_widget.dart`).

### 4.4 توحيد ترتيب التسمية

| الحالي | الجديد | السبب |
|---|---|---|
| `view/widget/home/card_cycle.dart` | `view/widget/home/cycle_card.dart` | الترتيب القياسي: `<entity>_<type>` |

### 4.5 خطوات التنفيذ لكل إعادة تسمية

1. أعد تسمية الملف بـ `git mv`
2. ابحث عن كل `import` للملف القديم: `grep -rln "<old_name>" lib/ test/`
3. استبدل المسارات
4. شغّل `flutter analyze`
5. اعمل commit مستقل لكل ملف (لتسهيل المراجعة والـ revert)

---

## 5️⃣ المرحلة الخامسة: تحسينات حقن التبعيات

> هذه المرحلة كانت موضوع نقاش سابق. مذكورة هنا للاكتمال.

### 5.1 نقل `MobileAds.instance.initialize()`
- **من:** `lib/logic/bindings/app_binding.dart`
- **إلى:** `lib/core/services/initialization.dart` ضمن `MyServices.init()`
- **السبب:** SDK init وليس DI.

### 5.2 إخراج `CycleFeedbackBinding` من `AppBindings`
- **من:** `app_binding.dart` (يُحقن global)
- **إلى:** `GetPage.binding` للـ route الذي يستخدمه فقط
- **السبب:** feature-scoped binding لا يجب تحميله مع كل التطبيق.

### 5.3 نقل الـ controllers العامة من `HomeBindings` إلى `AppBindings`
الـ controllers الآتية معرَّفة كـ `permanent: true` في `HomeBindings`، لكنها فعلياً global:
- `PermissionController`
- `InternetController`
- `RateMyAppController`
- `FavoriteToolsController`

انقلها لـ `AppBindings` كي تكون متاحة قبل شاشة Home (في login/splash/onboarding).
اترك في `HomeBindings` فقط ما هو خاص بـ Home: `PricesCardController`, `ReviewPromptController`.

---

## 6️⃣ ترتيب التنفيذ المُوصى به

نفّذ المراحل بالترتيب التالي. **كل مرحلة = PR منفصل.**

| الترتيب | المرحلة | المخاطرة | الأثر |
|---|---|---|---|
| 1 | حذف الحزم الخمس غير المستخدمة | ⚪ منخفضة | حجم APK |
| 2 | حذف الملفات الستة الميتة + route `/adad` | ⚪ منخفضة | -411 سطر |
| 3 | إعادة تسمية الملفات (4.1 → 4.4) | 🟡 متوسطة | اتساق |
| 4 | إعادة هيكلة DI (5.1 → 5.3) | 🟡 متوسطة | استقرار |
| 5 | إنشاء `StorageKeys` + `AppStrings` واستبدال السلاسل | 🟡 متوسطة | صيانة |
| 6 | إنشاء `AppButton` + استبدال الأزرار | 🟠 عالية | -200 سطر |
| 7 | إنشاء `AppAlertDialog` + استبدال الـ dialogs | 🟠 عالية | -150 سطر |
| 8 | إنشاء `BaseRemoteData` + ترحيل ملفات data | 🔴 عالية جداً | -300 سطر |
| 9 | إنشاء `BaseListController` + ترحيل controllers القوائم | 🔴 عالية جداً | -400 سطر |
| 10 | توحيد الـ `AppDimens` و `AppSpacing` (تدريجياً) | ⚪ منخفضة | اتساق بصري |

### قواعد عامة لأي PR:
- ✅ `flutter analyze` بدون errors
- ✅ `flutter test` ينجح
- ✅ تشغيل التطبيق على الأقل لـ smoke test
- ❌ لا تجمع تعديلات من مراحل مختلفة
- ❌ لا تحذف أي ملف بدون التحقق من الاستخدام بـ `grep` أولاً

---

## 7️⃣ ما يجب **ألا** يُلمس

- **بنية المجلدات الرئيسية** (`core/`, `data/`, `logic/`, `view/`) — هي MVVM متّبعة وصحيحة.
- **الـ middleware** (`AuthMiddleware`, `OnboardingMiddleware`) — مستخدمة فعلاً في `get_page.dart`.
- **حقن `Crud`** في `AppBindings` — صحيح في مكانه.
- **الحزم الـ core** (`get`, `dartz`, `flutter_screenutil`, `intl`, `http`, `firebase_auth`, `get_storage`) — مستخدمة بكثافة.
- **الـ tests الموجودة** (52 test) — لا تكسرها أثناء إعادة الهيكلة.

---

## 8️⃣ ما هو خارج النطاق

- إعادة كتابة الـ backend PHP — يحتاج خطة منفصلة.
- ترقية إصدارات الحزم الكبرى (Firebase 4 → 5 إلخ).
- تغيير state management (الإبقاء على GetX).
- إضافة ميزات جديدة.

---

**نهاية الخطة.**
