# تحليل ميزة الدورة — فرخة مقابل المنافسين

**آخر تحديث:** 2026-04-20 | **النطاق:** ميزة الدورة تحديداً (lib/view/screen/cycle)

---

## المنافسون المقارَنون

| التطبيق                      | نوع          |
| ---------------------------- | ------------ |
| My Poultry Manager (Bivatec) | Mobile + Web |
| SmartBird                    | Web          |
| PRIMA (Hendrix Genetics)     | Mobile       |
| PoultryPlan                  | Web          |
| PoultryPro+                  | Web/Mobile   |
| EasePoultry                  | Web          |
| FarmKeep                     | Mobile       |
| MTech Systems                | Enterprise   |
| Livine                       | Cloud ERP    |
| NAVFarm                      | Web ERP      |

---

## ✅ ما هو منفذ في الدورة حالياً

| العنصر                                                         | الملف                                                                   |
| -------------------------------------------------------------- | ----------------------------------------------------------------------- |
| إضافة/تعديل/حذف دورة                                           | `cycle/add_cycle.dart` + `cycle_controller.dart`                        |
| شاشة دورة رئيسية بتصفّح بين الدورات (PageView)                 | `cycle/cycle.dart`                                                      |
| شريط الإحصائيات (العمر، الأيام)                                | `widget/cycle/cycle_stats_bar.dart`                                     |
| حالة البيئة (طقس، حرارة، رطوبة)                                | `widget/cycle/environment_status.dart`                                  |
| مقاييس الأداء (وزن، FCR، نفوق تراكمي)                          | `widget/cycle/performance_metrics_card.dart`                            |
| استهلاك العلف (بادي/نامي/ناهي حسب العمر)                       | `widget/cycle/feed_consumption_card.dart`                               |
| ملخص مالي (تكلفة للفرخة، سعر الكيلو، ربح متوقع)                | `widget/cycle/financial_summary_card.dart`                              |
| المساحة والظلام                                                | `widget/cycle/area_darkness_card.dart` + `darkness_schedule_card.dart`  |
| البيانات اليومية (نفوق، وزن، أدوية، علف، تطعيمات بجدول تلقائي) | `cycle/cycle_data.dart`                                                 |
| المصروفات                                                      | `cycle/cycle_expenses.dart`                                             |
| المبيعات                                                       | `cycle/cycle_sales.dart`                                                |
| الملاحظات                                                      | `cycle/cycle_notes.dart`                                                |
| الأعضاء والصلاحيات (owner/viewer) + مغادرة الدورة              | `widget/cycle/member_list_widget.dart` + `add_member_dialog.dart`       |
| سجل الدورات السابقة                                            | `cycle/cycle_history_screen.dart` + `cycle_history_details_screen.dart` |
| تصدير PDF كامل للدورة                                          | `core/services/pdf/pdf_export_service.dart`                             |
| إدارة المخزون المستقلة                                         | `cycle/cycle_inventory.dart`                                            |
| منبه الظلام                                                    | `cycle/darkness_alarm_screen.dart`                                      |
| مؤشر EPEF (الكفاءة الإنتاجية الأوروبية)                        | `widget/cycle/performance_metrics_card.dart`                            |
| مقارنة الوزن بالقياسي (Benchmark)                              | `widget/cycle/performance_metrics_card.dart` (\_buildWeightMetricItem)  |
| تنبيهات أداء ذكية (نفوق مرتفع، FCR مرتفع)                      | `core/services/notifications/cycle/smart_alerts.dart`                   |
| منحنى النمو البياني (فعلي مقابل القياسي)                       | `widget/cycle/growth_curve_card.dart`                                   |
| تقرير ختامي موحّد للدورة                                       | `cycle/cycle_closeout_report.dart`                                      |
| تصدير Excel                                                    | `core/services/excel/excel_export_service.dart`                         |
| تتبع استهلاك المياه ونسبة ماء/علف                              | `widget/cycle/water_consumption_card.dart`                              |
| تقرير أسبوعي مجمَّع (KPIs)                                     | `widget/cycle/weekly_report_bottom_sheet.dart`                          |
| مقارنة بين الدورات (Batch Comparison)                          | `cycle/cycle_comparison_screen.dart`                                    |

---

## ❌ ما ينقص ميزة الدورة

### 🔴 أولوية عالية (من بحث المنافسين أبريل 2026)

#### 1. اختيار السلالة والمعيار القياسي المرتبط بها (Breed Standard)

- **المنافسون:** PRIMA, SmartBird, PoultryCare, Aviagen-based apps — عند إنشاء الدورة يختار المربي السلالة (Ross 308 / Cobb 500 / Arbor Acres / Hubbard / Lohmann) ويُحمَّل تلقائياً منحنى الوزن القياسي، FCR القياسي، جدول التطعيمات، متطلبات الحرارة/الإضاءة لتلك السلالة بالذات
- **الوضع الحالي:** منحنى نمو + Benchmark يعتمدان على قياسي عام، بدون تمييز بين السلالات
- **الأثر:** Ross 308 تصل لذروة النمو في اليوم 30-34، Cobb 500 أكثر كفاءة في FCR — استخدام قياسي موحّد يعطي قراءات غير دقيقة لكل سلالة
- **الحل:** جدول مرجعي per-breed في `core/constant/` + اختيار السلالة في `add_cycle.dart` → تحديث المقاييس تلقائياً

#### 2. سبب النفوق (Mortality Reason Tracking)

- **المنافسون:** SmartBird, FarmKeep, PoultryCare — كل حالة نفوق تُصنَّف: مرض / استبعاد (Culling) / حادثة / افتراس / سبب غير معروف
- **الوضع الحالي:** رقم إجمالي فقط بدون تصنيف
- **الأثر:** لا يمكن تحليل أسباب النفوق للوقاية منها مستقبلاً
- **الحل:** Dropdown في حقل النفوق اليومي + تقرير تحليلي بالأسباب

#### 3. Placement-wise P&L (ترتيب الدورات بالربحية)

- **المنافسون:** PoultryCare, PoultryOS — ترتيب كل الدورات السابقة من الأكثر ربحاً للأقل لمعرفة النمط الأفضل
- **الوضع الحالي:** كل دورة لها ربحها منفرداً بدون مقارنة عبر الزمن
- **الحل:** قسم في `cycle_history_screen.dart` بترتيب تنازلي للربح/فرخة

---

### 🟡 أولوية متوسطة

#### 4. تجانس القطيع (Uniformity / CV%)

- **المعيار:** عند وزن عينة من عدة طيور، يُحسب معامل التباين. CV% < 12% = جيد، > 15% = مشكلة إدارية
- **المنافسون:** Aviagen-based apps
- **الوضع الحالي:** يُدخَل متوسط وزن واحد فقط
- **الحل:** خيار "وزن عينة" يقبل عدة قراءات → حساب المتوسط + CV%

#### 5. تكامل IoT مع حساسات العنبر (Shed Sensors)

- **المنافسون:** NAVFarm, MTech, PoultryPlan — قراءة مباشرة من حساسات الحرارة/الرطوبة/NH3/CO2 داخل العنبر بدل الإدخال اليدوي
- **الوضع الحالي:** حرارة ورطوبة من Weather API خارجي (طقس المدينة)، لا قراءة داخل العنبر
- **الأثر:** الطقس الخارجي ≠ بيئة العنبر الفعلية، خصوصاً مع التدفئة/التبريد
- **الحل:** MQTT/HTTP endpoint يستقبل قراءات من ESP32/Raspberry Pi (إضافة اختيارية)، مع تنبيهات عتبات

#### 6. إدارة السايلو وتنبيه نفاد العلف (Feed Silo Monitoring)

- **المنافسون:** BinMaster FeedView, BinConnect, MTech — عرض نسبة امتلاء السايلو وتوقع تاريخ النفاد
- **الوضع الحالي:** مخزون علف عام بدون ربط باستهلاك يومي وتوقع النفاد
- **الحل:** حقل "سعة السايلو" + حساب أيام متبقية بناءً على متوسط الاستهلاك + إشعار قبل 3 أيام

#### 7. جدول الإضاءة الكامل (Lighting Program)

- **المنافسون:** PoultryPlan, PoultryCare, Aviagen apps — جدول ساعات ضوء/ظلام لكل أسبوع عمر (مثلاً: أسبوع 1: 23L/1D، أسبوع 2: 20L/4D…)
- **الوضع الحالي:** ساعات الظلام + منبه الظلام موجود، لكن بدون برنامج متكامل متغيّر حسب العمر
- **الحل:** توسيع `darkness_schedule_card.dart` إلى جدول كامل 6 أسابيع قابل للتعديل per-breed

#### 8. برنامج الحرارة حسب العمر (Temperature Set-Point Curve)

- **المعيار:** اليوم 1: 33-34°C، تنخفض تدريجياً حتى 20-22°C بنهاية الدورة
- **المنافسون:** Aviagen Broiler Management Handbooks integrated apps
- **الوضع الحالي:** عرض حرارة البيئة الخارجية فقط دون هدف مطلوب
- **الحل:** منحنى حرارة مثالية per-age + مقارنة بالفعلي + تنبيه عند الانحراف

#### 9. حساب الجرعات الدوائية حسب الوزن/العدد (Dosage Calculator)

- **المنافسون:** FarmKeep, SmartBird — إدخال اسم الدواء + الجرعة لكل 1000 طائر → حساب الكمية الكلية
- **الوضع الحالي:** تُسجَّل الأدوية كنص بدون حسبة
- **الحل:** صيغة `dose_per_1000 × (birds/1000) × days` في شاشة تسجيل الدواء

#### 10. Biosecurity — سجل الزوار والتطهير

- **المنافسون:** Forms on Fire, Folio3, PoultryCare — سجل منفصل للزوار (اسم/سبب/وقت) + جدول تطهير (معدات/مركبات/دخول)
- **الوضع الحالي:** غير موجود
- **الحل:** Tab "البيوأمن" يحتوي سجل زوار + Checklist تطهير يومي

---

### 🟢 أولوية منخفضة

#### 11. دعم عدة عنابر/حظائر لنفس الدورة (Multi-house)

- **المنافسون:** PoultryPlan, Livine, NAVFarm — يدعمون "دورة واحدة = عدة عنابر"
- **الوضع الحالي:** دورة = عنبر واحد (حقل `space` وحيد)
- **الأثر:** يحد من المزارع الكبيرة فقط

#### 12. قوالب دورة (Cycle Templates)

- **المنافسون:** SmartBird, MTech — حفظ (السلالة، العنبر، جدول التطعيم، الإضاءة) كقالب
- **الوضع الحالي:** كل دورة تُنشَأ من الصفر
- **الحل:** زر "استخدم إعدادات آخر دورة" عند الإضافة

#### 13. دجاج البياض (Layers) + أنواع أخرى

- **الوضع الحالي:** `_buildFixedField('نوع الدورة', 'تسمين')` و `'نظام التربية', 'أرضي'` — مقفّلان في `add_cycle.dart:244,265`
- **المنافسون:** الكل يدعم بياض/تسمين/أقفاص/حر + بعضهم ديك رومي وبط
- **الأثر:** يستبعد شريحة كبيرة من السوق

#### 14. معاملات FCR المصحّح (Corrected FCR)

- **المعيار:** تعديل FCR لوزن مرجعي عند المقارنة (±227 جم)
- **المنافسون:** PRIMA, PoultryPerformancePlus
- **الحل:** خانة "FCR مصحّح" بجانب FCR الخام

#### 15. تشخيص الأمراض بالذكاء الاصطناعي (AI Disease Detection)

- **المنافسون:** تطبيقات حديثة تستخدم YOLOv8 / CNN لتحليل صور الذرق/الطيور لكشف Coccidiosis / Salmonella / Newcastle بدقة تصل لـ 99%
- **الوضع الحالي:** غير موجود
- **الحل:** رفع صورة + نموذج TFLite محلي أو استدعاء API خارجي — ميزة متقدمة تستحق القسط المدفوع

#### 16. جدول الاستلام والتسويق (Catching & Processor Pickup)

- **المنافسون:** MTech Amino, NAVFarm — جدولة يوم الاستلام وتخصيص عدد الشاحنات/مجازر
- **الوضع الحالي:** مبيعات تُسجَّل بعد التنفيذ، بدون جدولة مسبقة
- **الحل:** Calendar مع "موعد استلام مخطَّط" + قسمة الكمية على شاحنات

#### 17. إدارة الفرشة (Litter Management)

- **المنافسون:** PoultryPlan — تسجيل تاريخ تقليب/تغيير الفرشة + نوع وكمية المادة
- **الوضع الحالي:** غير موجود
- **الحل:** قسم "الفرشة" في `cycle_data` يسجل التغييرات

#### 18. تعدد الأدوار والصلاحيات (Fine-grained Roles)

- **المنافسون:** Navfarm, SmartBird — أدوار: مدير، عامل، بيطري، محاسب — كل دور يرى بياناته فقط
- **الوضع الحالي:** صلاحيتان فقط (Owner / Viewer)
- **الحل:** توسيع نظام العضوية لإضافة أدوار أكثر بصلاحيات مخصصة

---

## ملخص حالة التنفيذ لميزة الدورة

| العنصر                                        | الحالة  |
| --------------------------------------------- | ------- |
| إضافة/تعديل/حذف دورة                          | ✅ منفذ |
| بيانات يومية شاملة                            | ✅ منفذ |
| مصروفات/مبيعات/ملاحظات                        | ✅ منفذ |
| FCR/تكلفة/ربح متوقع                           | ✅ منفذ |
| أعضاء وصلاحيات + مغادرة                       | ✅ منفذ |
| سجل الدورات                                   | ✅ منفذ |
| تصدير PDF                                     | ✅ منفذ |
| مخزون                                         | ✅ منفذ |
| EPEF/EPI                                      | ✅ منفذ |
| Benchmark (مقارنة الوزن بالقياسي)             | ✅ منفذ |
| تنبيهات أداء ذكية                             | ✅ منفذ |
| منحنى نمو بياني                               | ✅ منفذ |
| تقرير ختامي موحّد                             | ✅ منفذ |
| تصدير Excel                                   | ✅ منفذ |
| استهلاك مياه                                  | ✅ منفذ |
| تقرير أسبوعي                                  | ✅ منفذ |
| مقارنة دورات                                  | ✅ منفذ |
| اختيار السلالة + قياسي خاص بها (Ross/Cobb/AA) | ❌      |
| سبب النفوق (تصنيف)                            | ❌      |
| Placement-wise P&L                            | ❌      |
| Uniformity (CV%)                              | ❌      |
| تكامل IoT للعنبر (NH3/CO2/حرارة داخلية)       | ❌      |
| إدارة السايلو + توقع نفاد العلف               | ❌      |
| جدول إضاءة كامل حسب العمر                     | ❌      |
| منحنى حرارة مثالية حسب العمر                  | ❌      |
| حاسبة جرعات الأدوية                           | ❌      |
| البيوأمن (زوار/تطهير)                         | ❌      |
| Multi-house                                   | ❌      |
| قوالب دورة                                    | ❌      |
| دعم بياض                                      | ❌      |
| FCR مصحّح                                     | ❌      |
| تشخيص الأمراض بـ AI                           | ❌      |
| جدولة استلام/تسويق                            | ❌      |
| إدارة الفرشة                                  | ❌      |
| أدوار مخصصة (بيطري/محاسب/عامل)                | ❌      |

---

## نقاط قوة فريدة في دورة فرخة

| الميزة                                                 | الوضع التنافسي                      |
| ------------------------------------------------------ | ----------------------------------- |
| منبه الظلام (Darkness Alarm)                           | ✅✅✅ لا يملكه أحد                 |
| جدول تطعيمات تلقائي حسب العمر                          | ✅✅ متقدم                          |
| تكامل الطقس مع بيئة العنبر                             | ✅✅ غير شائع                       |
| الواجهة العربية الكاملة + RTL                          | ✅✅✅ الأفضل في السوق              |
| تسجيل أدوية + تطعيمات + نفوق + وزن + علف في شاشة واحدة | ✅✅ متكامل                         |
| مؤشر EPEF + مقارنة الوزن بالقياسي                      | ✅✅ محترف                          |
| تنبيهات أداء ذكية (نفوق/FCR)                           | ✅✅ غير شائع في التطبيقات المجانية |
| منحنى النمو البياني + تقرير ختامي + تقرير أسبوعي       | ✅✅ اكتمل المستوى الاحترافي        |
| تصدير PDF + Excel لكامل بيانات الدورة                  | ✅✅ تكافؤ مع المنافسين العالميين   |
| مقارنة بين دورتين جنباً إلى جنب                        | ✅✅ ميزة تحليلية متقدمة            |

---

## الخلاصة الاستراتيجية — الخطوة التالية

### ما تم إنجازه في هذه الجولة (Quick Wins ✅)

- تقرير ختامي موحّد (`cycle_closeout_report.dart`)
- تصدير Excel (`core/services/excel/excel_export_service.dart`)
- مقارنة بين دورتين (`cycle_comparison_screen.dart`)
- استهلاك المياه + نسبة ماء/علف (`water_consumption_card.dart`)
- منحنى نمو بياني فعلي مقابل القياسي (`growth_curve_card.dart`)
- تقرير أسبوعي مجمَّع (`weekly_report_bottom_sheet.dart`)

### الخطوة التالية المقترحة — ترتيب حسب القيمة/الجهد

**ربح عالي / جهد منخفض (ابدأ هنا)**

1. **اختيار السلالة + قياسي per-breed** — بيانات ثابتة في ملف JSON، أثر ضخم على دقة Benchmark والمنحنى
2. **سبب النفوق (Dropdown)** — تعديل Schema بسيط + تقرير تحليلي
3. **حاسبة جرعات الأدوية** — صيغة رياضية بسيطة
4. **جدول إضاءة + منحنى حرارة حسب العمر** — توسيع لميزات موجودة

**ربح عالي / جهد متوسط** 5. **Uniformity (CV%)** — وزن عينة متعددة 6. **Placement-wise P&L** — Query + شاشة ترتيب 7. **البيوأمن (زوار/تطهير)** — جدول جديد بسيط 8. **FCR مصحّح** — صيغة قياسية معروفة

**يفتح سوقاً جديداً (جهد أكبر)** 9. **دعم البياض (Layers)** — يضاعف قاعدة المستخدمين 10. **Multi-house** — مزارع كبيرة 11. **قوالب دورة** — إعادة استخدام الإعدادات 12. **أدوار مخصصة** — مزارع بفرق متخصصة

**ميزات إستراتيجية (التمايز)** 13. **تكامل IoT للعنبر** — فرق عن كل المنافسين المحليين 14. **تشخيص أمراض بـ AI** — ميزة Premium مميزة 15. **إدارة السايلو + توقع النفاد** — مع IoT أو إدخال يدوي

---

## المراجع

**منافسون رئيسيون:**

- [My Poultry Manager — Bivatec](https://www.bivatec.com/apps/my-poultry-manager)
- [PoultryPro+](https://www.poultryproplus.com/)
- [PRIMA — Hendrix Genetics](https://layinghens.hendrix-genetics.com/en/prima/)
- [PoultryPlan](https://www.poultryplan.com/)
- [EasePoultry](https://www.easepoultry.com/)
- [SmartBird](https://smartbirdapp.com/)
- [FarmKeep](https://www.farmkeep.com/farm-type/poultry-management-software)
- [NAVFarm](https://www.navfarm.com/poultry/)
- [PoultryCare ERP — Broiler](https://www.poultry.care/broiler-management)
- [MTech Systems — Amino](https://mtechsystems.io/products/amino/)
- [Folio3 AgTech — Broiler](https://agtech.folio3.com/poultry-management-software/broiler/)
- [FitGap — Broiler SW April 2026](https://us.fitgap.com/search/farm-management-software/broiler)
- [Kukufarm](https://kukufarm.com/)

**معايير الأداء والمقاييس:**

- [Aviagen — Evaluating Comparative Broiler Performance](https://aviagen.com/assets/Tech_Center/Broiler_Breeder_Tech_Articles/English/AviagenBrief-EvaluatingComparativeBroilerPerformance-Trials-EN19.pdf)
- [Aviagen 2025 Broiler Management Handbooks](https://www.thepoultrysite.com/news/2025/04/latest-arbor-acres-indian-river-and-ross-broiler-management-advice-now-available)
- [Corrected FCR — PoultryPerformancePlus](https://poultryperformanceplus.com/information-database/broilers/354-corrected-feed-conversion-ratio-fcr)
- [Cobb vs Ross vs Hubbard performance comparison — ScienceDirect](https://www.sciencedirect.com/science/article/pii/S000390982500284X)

**IoT / حساسات العنبر:**

- [Smart automatic control for poultry houses — Nature 2025](https://www.nature.com/articles/s41598-025-17074-2)
- [BinMaster FeedView — Feed Silo Monitoring](https://binmaster.com/feedview)
- [BinConnect — Feed Inventory](https://www.nanolike.com/binconnect/)

**تشخيص الأمراض بالذكاء الاصطناعي:**

- [YOLOv8 Poultry Disease Detection — arXiv 2025](https://arxiv.org/abs/2508.04658)
- [Smartphone-based fecal disease classification — ScienceDirect](https://www.sciencedirect.com/science/article/pii/S2772375523000515)
- [AI Poultry Diagnostics — Frontiers](https://www.frontiersin.org/articles/10.3389/frai.2022.733345)

**الماليات والربحية:**

- [Broiler Buddy — Alabama Extension](https://www.aces.edu/blog/topics/farm-management/broiler-buddy-financial-tool/)
- [PoultryCare — Profit & Loss Calculator](https://www.poultry.care/features/profit-loss-calculator)
