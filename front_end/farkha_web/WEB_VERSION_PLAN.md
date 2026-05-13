# خطة تحويل تطبيق فرخة إلى نسخة Web

> **المصدر:** تطبيق `farkha_app` (Flutter) — `/Users/nims/StudioProjects/farkha/front_end/farkha_app`
> **الهدف:** نسخة Web **متجاوبة** متطابقة وظيفياً بنفس الـ Backend (`backend_farkha` PHP REST API)، مع الحفاظ الكامل على **الطابع البصري والهوية** (olive + terracotta + wheat + Cairo + RTL).
> **التاريخ:** 2026-05-14 (آخر تحديث)
> **المرجع البصري:** `farkha_app/lib/core/constant/theme/` + `farkha_app/lib/view/widget/`

---

## 🎯 القرارات النهائية (مُتفق عليها)

| القرار | الاختيار |
|--------|----------|
| **التصميم** | Responsive يتكيف (Mobile-first + Desktop expansion) |
| **Hosting** | Hostinger **VPS** |
| **أمان API** | Next.js API Routes كـ proxy (الـ secrets على Server فقط) |
| **Package Manager** | **bun** (الأسرع) |
| **Framework** | Next.js 15 App Router + TypeScript + Tailwind v4 + shadcn/ui |
| **AI Tools** | Claude Code + opencode (عبر Spec Kit) |

---

## ✅ Checklist قبل البدء

### 🔴 يجب إنجازها قبل أي كود

- [ ] **Firebase Console** — إضافة Web App للمشروع الحالي
  - Project Settings → Add App → Web
  - نسخ `firebaseConfig` كاملاً
  - توليد **VAPID Key** من Cloud Messaging > Web configuration
  - إضافة domain الموقع لـ **Authorized domains** في Authentication

- [ ] **Backend CORS** — تعديل `backend_farkha/config/bootstrap.php`:
  ```php
  header("Access-Control-Allow-Origin: https://your-web-domain.com");
  header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
  header("Access-Control-Allow-Headers: Authorization, Content-Type");
  if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') { http_response_code(204); exit; }
  ```

- [ ] **Google OAuth Web Client** — Google Cloud Console
  - إنشاء OAuth 2.0 Client ID نوع **Web application**
  - إضافة Authorized JavaScript origins + redirect URIs

- [ ] **Apple Sign-In Web** (اختياري لو نريده على Web)
  - إنشاء Service ID في Apple Developer
  - تكوين Return URL في Firebase Auth

- [ ] **Domain** — تحديد domain الموقع (مثال: `web.nims-farkha.com`)

- [ ] **Hostinger VPS** — تجهيز السيرفر:
  ```bash
  # Node.js + bun
  curl -fsSL https://bun.sh/install | bash
  # أو via nvm: nvm install 20 && npm i -g bun

  # Nginx + PM2
  apt update && apt install -y nginx
  bun add -g pm2

  # SSL
  apt install -y certbot python3-certbot-nginx
  certbot --nginx -d web.nims-farkha.com
  ```

### 🟡 مرغوب قبل البدء

- [ ] **لقطات شاشة** من التطبيق الحالي للتصاميم المرجعية
- [ ] **Constitution** — كتابة `/speckit-constitution` بمبادئ المشروع
- [ ] **Logo & assets** — نسخ من `farkha_app/assets/` إلى `public/`
- [ ] **خط Cairo** — يتم تلقائياً عبر `next/font/google`

---

## ⚠️ تنبيه مهم

كل شيء في هذه الخطة **مبني على ما هو موجود فعلياً في `/Users/nims/StudioProjects/farkha/front_end/farkha_app`**.
- نفس الشاشات → نفس الصفحات في Web
- نفس الـ API endpoints (لا تغيير في الـ backend)
- نفس الألوان والخط (Cairo) والـ RTL
- نفس Firebase project
- نفس الـ Auth flow (Firebase Auth + Google Sign-In + Phone OTP)

---

## 0) الهوية البصرية والطابع (Visual Identity)

> **القاعدة الذهبية:** الموقع لازم يحس المستخدم إنه نفس التطبيق، مش موقع تاني. كل لون وكل خط وكل radius وكل spacing لازم يتطابق مع `farkha_app`.

### 0.1 شخصية التصميم
- **روح ريفية دافئة** — ألوان مستوحاة من المزرعة (زيتي، تيراكوتا، قمحي ذهبي)
- **خلفية كريمية ناعمة** بدل الأبيض الناصع — تريح العين وتعطي طابع طبيعي
- **زوايا ناعمة** (radius 8-24px) — يدوي وحميمي، مش حاد
- **Cards بحدود رفيعة + ظل خفيف** — مش flat ومش ثقيلة
- **خط Cairo** عربي أنيق، أوزان متدرجة من ExtraLight (200) لـ Black (900)
- **RTL أصلي** — كل شيء يبدأ من اليمين، الأيقونات الاتجاهية معكوسة
- **توازن دافئ بين الإضاءة والظل** في Light + Dark modes

### 0.2 المراجع المرئية من التطبيق
- `lib/core/constant/theme/colors.dart` — لوحة الألوان الكاملة
- `lib/core/constant/theme/theme.dart` — Typography + dimens + spacing + elevation
- `assets/fonts/Cairo/` — 6 أوزان (ExtraLight, Light, Regular, SemiBold, Bold, Black)
- `assets/icons/tools/` — 24 SVG icon للأدوات
- `assets/images/onboarding/` — 3 SVG (cycle, prices, tools)
- `assets/lottie/` — error, loading, no_data, offline

---

## 1) الأدوات (Tech Stack)

### الأساسيات
| الأداة | الإصدار | الغرض | يقابل في Flutter |
|--------|---------|-------|-------------------|
| **Next.js** | 15.x (App Router) | Framework أساسي + SSR/SSG | Flutter SDK |
| **TypeScript** | 5.x | أمان النوع | Dart |
| **Tailwind CSS** | v4.x | Styling | Material/Theme |
| **shadcn/ui** | latest | مكونات UI جاهزة | Flutter widgets |
| **React** | 19.x | UI library (مدمج مع Next) | Flutter |

### إدارة الحالة والبيانات
| الأداة | الغرض | يقابل في Flutter |
|--------|-------|-------------------|
| **Zustand** | State management خفيف وبسيط | GetX (`GetxController`) |
| **TanStack Query (React Query)** | جلب البيانات + caching + retries | `crud.dart` + `StatusRequest` |
| **Axios** | HTTP client | `http` package |
| **React Hook Form + Zod** | Forms + validation | TextField + validators |

### Firebase (نفس الـ project الحالي)
| الأداة | الغرض |
|--------|-------|
| **firebase** (Web SDK v11) | Firebase Web SDK |
| **firebase/auth** | Authentication |
| **firebase/messaging** | Push Notifications (FCM Web) |
| **firebase/analytics** | Analytics |
| **firebase/remote-config** | Remote Config |

### Auth الخاص (متطابق مع التطبيق)
| الأداة | الغرض |
|--------|-------|
| **Google Sign-In** | عبر `firebase/auth` (GoogleAuthProvider) |
| **Phone OTP** | عبر `firebase/auth` (RecaptchaVerifier + signInWithPhoneNumber) |
| **Sign in with Apple** | عبر `firebase/auth` (OAuthProvider) |

### Internationalization & RTL
| الأداة | الغرض |
|--------|-------|
| **next-intl** | i18n للعربية (اختياري إذا أردنا multi-language) |
| **`dir="rtl"` + `lang="ar"`** | RTL على مستوى `<html>` |
| **next/font/google** | لتحميل خط **Cairo** |

### UI Helpers
| الأداة | الغرض | يقابل في Flutter |
|--------|-------|-------------------|
| **lucide-react** | أيقونات | font_awesome_flutter |
| **recharts** | رسوم بيانية | fl_chart |
| **lottie-react** | Lottie animations | lottie |
| **sonner** | Toast notifications | GetX snackbar |
| **next-themes** | Dark/Light mode | DarkLightService |
| **react-day-picker** | Date picker | DatePicker |

### PDF & Excel & Share (لميزة `cycle_closeout_report`)
| الأداة | الغرض | يقابل في Flutter |
|--------|-------|-------------------|
| **@react-pdf/renderer** أو **jsPDF + html2canvas** | إنتاج PDF | pdf + printing |
| **xlsx** (SheetJS) | تصدير Excel | excel |
| **Web Share API** | مشاركة | share_plus |

### أدوات إضافية
| الأداة | الغرض |
|--------|-------|
| **dayjs** أو **date-fns** | معالجة التواريخ |
| **clsx + tailwind-merge** | دمج classes (تأتي مع shadcn) |
| **@radix-ui/react-*** | primitives (تأتي مع shadcn تلقائياً) |

---

## 2) موقع المشروع الجديد

```
/Users/nims/StudioProjects/farkha/front_end/
├── farkha_app/          ← التطبيق Flutter (المرجع)
├── farkha_admin/        ← لوحة Admin (Flutter)
└── farkha_web/          ← 🆕 المشروع الجديد Next.js
```

**أمر الإنشاء:**
```bash
cd /Users/nims/StudioProjects/farkha/front_end
npx create-next-app@latest farkha_web \
  --typescript \
  --tailwind \
  --app \
  --src-dir \
  --import-alias "@/*" \
  --turbopack
```

---

## 3) هيكل المشروع المقترح

```
farkha_web/
├── src/
│   ├── app/                              ← App Router
│   │   ├── layout.tsx                    ← <html dir="rtl" lang="ar"> + Cairo font
│   │   ├── page.tsx                      ← Landing / Home
│   │   ├── globals.css                   ← Tailwind + متغيرات الألوان
│   │   ├── (auth)/
│   │   │   ├── login/page.tsx
│   │   │   ├── verify-phone/page.tsx
│   │   │   └── enter-otp/page.tsx
│   │   ├── onboarding/page.tsx
│   │   ├── prices/
│   │   │   ├── page.tsx                  ← mainTypes
│   │   │   ├── [type]/page.tsx           ← prices by type
│   │   │   ├── history/page.tsx
│   │   │   └── customize/page.tsx
│   │   ├── cycles/
│   │   │   ├── page.tsx                  ← قائمة الدورات
│   │   │   ├── new/page.tsx              ← add_cycle
│   │   │   ├── [id]/
│   │   │   │   ├── page.tsx              ← تفاصيل الدورة
│   │   │   │   ├── data/page.tsx
│   │   │   │   ├── expenses/page.tsx
│   │   │   │   ├── sales/page.tsx
│   │   │   │   ├── notes/page.tsx
│   │   │   │   ├── closeout/page.tsx     ← cycle_closeout_report
│   │   │   │   └── members/page.tsx
│   │   │   ├── history/page.tsx
│   │   │   ├── history/[id]/page.tsx
│   │   │   └── compare/page.tsx          ← cycle_comparison
│   │   ├── tools/
│   │   │   ├── page.tsx                  ← all_tools
│   │   │   ├── fcr/page.tsx              ← معامل التحويل الغذائي
│   │   │   ├── adg/page.tsx
│   │   │   ├── chicken-density/page.tsx
│   │   │   ├── daily-feed-consumption/page.tsx
│   │   │   ├── total-feed-consumption/page.tsx
│   │   │   ├── water-consumption/page.tsx
│   │   │   ├── weight-by-age/page.tsx
│   │   │   ├── temperature-by-age/page.tsx
│   │   │   ├── darkness-levels/page.tsx
│   │   │   ├── fan-operation/page.tsx
│   │   │   ├── weather/page.tsx
│   │   │   ├── vaccination-schedule/page.tsx
│   │   │   ├── diseases/page.tsx
│   │   │   ├── broiler-requirements/page.tsx
│   │   │   ├── feasibility-study/page.tsx
│   │   │   ├── bird-production-cost/page.tsx
│   │   │   ├── feed-cost-per-bird/page.tsx
│   │   │   ├── feed-cost-per-kilo/page.tsx
│   │   │   ├── bird-net-profit/page.tsx
│   │   │   ├── roi/page.tsx
│   │   │   ├── mortality-rate/page.tsx
│   │   │   ├── total-farm-weight/page.tsx
│   │   │   └── total-revenue/page.tsx
│   │   ├── articles/
│   │   │   ├── page.tsx
│   │   │   └── [id]/page.tsx
│   │   └── settings/page.tsx
│   ├── components/
│   │   ├── ui/                           ← shadcn/ui components
│   │   ├── layout/
│   │   │   ├── navbar.tsx
│   │   │   ├── sidebar.tsx
│   │   │   └── footer.tsx
│   │   ├── cycle/                        ← مكونات الدورات
│   │   ├── tools/                        ← مكونات الأدوات
│   │   ├── auth/
│   │   └── shared/
│   ├── lib/
│   │   ├── api/                          ← يقابل data/data_source/remote/
│   │   │   ├── client.ts                 ← Axios instance + Basic Auth
│   │   │   ├── endpoints.ts              ← يقابل core/constant/id/api.dart
│   │   │   ├── auth.ts
│   │   │   ├── cycles.ts
│   │   │   ├── prices.ts
│   │   │   ├── tools.ts
│   │   │   └── types.ts                  ← TypeScript types من Models
│   │   ├── firebase/
│   │   │   ├── config.ts                 ← Firebase init
│   │   │   ├── auth.ts                   ← Auth helpers
│   │   │   ├── messaging.ts              ← FCM Web
│   │   │   └── remote-config.ts
│   │   ├── hooks/                        ← React hooks (يقابل controllers)
│   │   │   ├── use-auth.ts
│   │   │   ├── use-cycles.ts
│   │   │   ├── use-prices.ts
│   │   │   └── use-cycle-data.ts
│   │   ├── stores/                       ← Zustand stores
│   │   │   ├── auth-store.ts
│   │   │   └── theme-store.ts
│   │   ├── utils/
│   │   │   ├── number-format.ts          ← يقابل core/functions/number_format.dart
│   │   │   ├── date-format.ts
│   │   │   └── cn.ts                     ← clsx + twMerge
│   │   └── constants/
│   │       ├── tools-list.ts             ← يقابل core/constant/tools_list.dart
│   │       ├── routes.ts                 ← يقابل core/constant/routes/route.dart
│   │       └── colors.ts                 ← يقابل core/constant/theme/colors.dart
│   ├── types/
│   │   └── api.ts
│   └── middleware.ts                     ← حماية المسارات المحمية
├── public/
│   ├── images/                           ← نسخ من farkha_app/assets/images
│   ├── icons/
│   ├── fonts/                            ← Cairo (أو نستخدم next/font)
│   └── lottie/
├── .env.local                            ← يقابل farkha_app/.env
├── tailwind.config.ts
├── tsconfig.json
├── next.config.ts
├── components.json                       ← إعدادات shadcn/ui
└── package.json
```

---

## 4) قائمة الميزات (مأخوذة من التطبيق الفعلي)

### 4.1 Authentication
- ✅ Login (Google / Apple / Phone)
- ✅ Phone Verification (send OTP / verify OTP / resend)
- ✅ Update Name / Phone
- ✅ Delete Account
- ✅ Update FCM Token

### 4.2 Onboarding
- ✅ Onboarding screens (3-4 شاشات تعريفية)

### 4.3 الأسعار (Prices)
- ✅ الأنواع الرئيسية (mainTypes)
- ✅ الأسعار حسب النوع (pricesByType)
- ✅ تاريخ الأسعار (priceHistory)
- ✅ تخصيص الأسعار (customizePrices)
- ✅ بطاقات أسعار اليوم (cards)

### 4.4 الدورات (Cycles) — الأكبر والأكثر تعقيداً
- ✅ إنشاء/تعديل/حذف دورة (create/update/delete)
- ✅ بيانات يومية متعددة الأنواع (add_data):
  - **Mortality** (نفوق) — مع تاريخ + إحصاءات
  - **Average Weight** (متوسط الوزن) — مع تاريخ
  - **Feed Consumption** (استهلاك العلف)
  - **Medication** (الأدوية)
  - **Custom Data** (بيانات مخصصة)
- ✅ Expenses — إضافة/تعديل/حذف + سجل المصاريف
- ✅ Sales — إضافة/تعديل/حذف + بطاقات المبيعات
- ✅ Notes — CRUD كامل
- ✅ Cycle Tabs: Overview / Farm / Financial / Performance / Members
- ✅ **Performance Tab** — Growth Chart + Metrics Grid + حسابات أداء
- ✅ **Weekly Report** (تقرير أسبوعي bottom sheet)
- ✅ **Time-sensitive hints** (تنبيهات حسب مرحلة الدورة)
- ✅ History — قائمة الدورات السابقة + Filter Bar
- ✅ History Details — Header + Summary + Bottom Sheets
- ✅ Closeout Report — Cards + Data + Financial + Sections (PDF/Excel/Share)
- ✅ Cycle Comparison — Cards + Results + مقارنة بصرية
- ✅ Darkness Alarm — جدولة + قائمة + Settings Sheet (Web Notifications)
- ✅ Farm Darkness Section
- ✅ Members:
  - إضافة عبر بحث/Contact Picker (في Web: إدخال يدوي)
  - عرض القائمة
  - تحديث الدور (admin/member)
  - حذف العضو
  - مغادرة الدورة
- ✅ Invitations:
  - عرض الدعوات الواردة
  - الرد على دعوة (قبول/رفض)
  - الانضمام عبر كود (Join by code)
  - إنشاء كود دعوة

### 4.5 الأدوات الحسابية (Tools) — 24 أداة
حسب `tools_list.dart` بالضبط (toolId → الاسم → article ids):
1. معامل التحويل الغذائي (FCR)
2. متوسط النمو اليومي (ADG)
3. كثافة الفراخ
4. استهلاك العلف اليومي
5. استهلاك العلف الكلي
6. استهلاك الماء
7. الوزن حسب العمر
8. درجة الحرارة حسب العمر
9. ساعات الإظلام
10. تشغيل الشفاطات
11. الطقس
12. جدول التحصينات
13. المقالات
14. الأمراض
15. متطلبات فراخ التسمين
16. دراسة جدوى
17. تكلفة إنتاج الفرخ
18. تكلفة العلف لكل طائر
19. تكلفة العلف لكل كيلو
20. الربح الصافي للطائر
21. العائد على الاستثمار (ROI)
22. نسبة النفوق
23. الوزن الإجمالي
24. إجمالي الإيرادات

### 4.6 المقالات (Articles)
- ✅ قائمة المقالات
- ✅ تفاصيل المقالة (Markdown rendering عبر `react-markdown` + GFM)
- ✅ Related Articles section (مقالات مرتبطة بكل أداة)

### 4.7 الأمراض (Disease)
- ✅ قائمة الأمراض
- ✅ تفاصيل المرض
- ✅ **Diagnosis Diseases** (تشخيص بنظام أسئلة وأجوبة)

### 4.8 Drawer / Settings
- ✅ Drawer Header (معلومات المستخدم)
- ✅ Account Settings (تعديل الاسم، تعديل رقم الهاتف، حذف الحساب)
- ✅ About App (سياسة الخصوصية، الإصدار، شروط الاستخدام)
- ✅ Support Contact (WhatsApp + Gmail)
- ✅ Dark/Light mode toggle
- ✅ Share app

### 4.9 ميزات تفاعلية إضافية (مأخوذة من farkha_app)
- ✅ **App Review Dialog** (تقييم التطبيق + إرسال للـ backend عبر `upsert_review.php`)
  - Star rating input + Rating description
- ✅ **Cycle Feedback Dialog** (تقييم تجربة الدورة بعد الانتهاء — `submit_feedback.php`)
- ✅ **Usage Tips Dialog** (نصائح استخدام عند فتح ميزة جديدة)
- ✅ **Permissions Intro Dialog** (شرح أذونات قبل الطلب)
- ✅ **Favorite Tools** (تثبيت أدوات مفضلة في الصفحة الرئيسية)
- ✅ **Tools Usage Analytics** (تسجيل استخدام كل أداة — `record_tools_usage.php`)
- ✅ **Price Change Indicator** (مؤشر تغير الأسعار)
- ✅ **Ad Gate** (شاشة إعلان قبل بعض الأدوات — في Web اختياري أو AdSense)
- ✅ **Snackbar / Toast Messages** (عبر sonner)
- ✅ **Internet Checker** (مؤشر اتصال الإنترنت)
- ✅ **Test Mode Manager** (وضع اختبار للأدمنز)

### 4.10 الإشعارات (Push Notifications) — تخصصية
المعلومات مأخوذة من `core/services/notifications/`:
- ✅ **Cycle Care Notifications** (تذكيرات الرعاية)
- ✅ **Darkness Notifications** (تذكير وقت الإظلام)
- ✅ **Feed Notifications** (تذكير العلف)
- ✅ **Phase Notifications** (تنبيه دخول مرحلة جديدة)
- ✅ **Space Notifications** (تنبيه الكثافة)
- ✅ **Vaccination Notifications** (تذكير التحصينات)
- ✅ **Price Notifications** (تنبيه تغير الأسعار)

**ملاحظة Web:** تستخدم FCM Web SDK + Service Worker + Web Notifications API + Web Audio API (بدلاً من `flutter_ringtone_player`)

---

## 5) ربط الـ Backend (نفس الـ API بدون تغيير)

### 5.1 Base URL والـ Auth
في `.env.local` (نفس القيم الموجودة في `farkha_app/.env`):

```env
# ── API ──────────────────────────────────────────────
NEXT_PUBLIC_API_HOST=http://192.168.1.3:8888
# (أو الإنتاج: https://api.nims-farkha.com/backend_farkha)
NEXT_PUBLIC_SECURITY_USER=NiMs_farkha
NEXT_PUBLIC_SECURITY_KEY=Abdallh29512A

# ⚠️ تنبيه: SECURITY_USER/KEY ستكون مكشوفة في الـ Browser. للأمان الفعلي،
# مرر الطلبات عبر Next.js API routes (Route Handlers) كـ proxy وحقن الـ
# Basic Auth في الـ server-side فقط — ولا تستخدم NEXT_PUBLIC_ لهم.
# مثال آمن (موصى به):
# SECURITY_USER=NiMs_farkha   ← بدون NEXT_PUBLIC_
# SECURITY_KEY=Abdallh29512A  ← بدون NEXT_PUBLIC_
# ثم استخدم app/api/[...path]/route.ts كـ proxy

# ── Weather API (لأداة الطقس) ────────────────────────
NEXT_PUBLIC_WEATHER_API=48cc15ea6702472893a225904240612

# ── Firebase Web (من Firebase Console > Web App) ────
NEXT_PUBLIC_FIREBASE_API_KEY=...
NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN=...
NEXT_PUBLIC_FIREBASE_PROJECT_ID=...
NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET=...
NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID=...
NEXT_PUBLIC_FIREBASE_APP_ID=...
NEXT_PUBLIC_FIREBASE_VAPID_KEY=...     # FCM Web Push

# ── App settings ─────────────────────────────────────
NEXT_PUBLIC_APP_VERSION=6.1.8
NEXT_PUBLIC_PLATFORM=web
```

### Web Service Worker لـ FCM (`public/firebase-messaging-sw.js`)
ملف Service Worker مطلوب لاستقبال FCM في الـ background.

### 5.2 API Client (`src/lib/api/client.ts`)
نفس منطق `core/class/crud.dart`:
- Basic Auth header (`SECURITY_USER:SECURITY_KEY` → base64)
- Detect 401 / 404 "User not found" → force logout
- إرجاع Either-style response (نجاح / فشل)

### 5.3 Endpoints الكاملة (نسخ من `core/constant/id/api.dart`)

#### Auth (`/app/auth/`)
- `login.php` · `update_name.php` · `update_phone.php` · `update_fcm_token.php`
- `delete_account.php` · `send_otp.php` · `verify_otp.php` · `resend_otp.php`
- `phone_verification_status.php`

#### Cycles (`/app/cycles/`)
- `create.php` · `delete.php` · `leave_cycle.php` · `update_cycle.php` · `update_status.php`
- `add_data.php` · `add_expense.php` · `add_sale.php` · `delete_cycle_item.php`
- `get_cycles.php` · `get_cycle_details.php` · `get_history.php`
- `add_member.php` · `remove_member.php` · `update_member_role.php`
- `create_invitation.php` · `join_by_code.php` · `respond_to_invitation.php`
- `get_my_invitations.php` · `search_users.php`

#### Cycle Notes (`/app/cycles/notes/`)
- `add_note.php` · `get_notes.php` · `update_note.php` · `delete_note.php`

#### Prices (`/app/prices/`)
- `main_types.php` · `by_type.php` · `history.php` · `broiler_latest.php`

#### Card Prices (`/app/prices/card_prices/`)
- `cards.php` · `types.php`

#### Tools (`/app/tools/`)
- `feasibility_study.php` (باقي الأدوات حسابات محلية)

#### Articles (`/app/articles/`)
- `list.php` · `detail.php`

#### App Reviews (`/app/app_reviews/`)
- `upsert_review.php`

#### Cycle Feedbacks (`/app/cycle_feedbacks/`)
- `submit_feedback.php`

#### Analytics (`/analytics/`)
- `record_tools_usage.php`

---

## 6) ⚠️ ملاحظات هامة على الـ Web vs Mobile

### مميزات نحتاج تعديل في Web
| الميزة في التطبيق | البديل في Web |
|-------------------|----------------|
| `flutter_local_notifications` (إشعارات داخلية) | Web Notifications API + Service Worker |
| `firebase_messaging` (FCM Push) | FCM Web SDK + Service Worker (`firebase-messaging-sw.js`) |
| `google_mobile_ads` (إعلانات AdMob) | **AdSense** (إذا أردت إعلانات) — أو حذفها |
| `geolocator` (موقع) | `navigator.geolocation` Web API |
| `permission_handler` | Web Permissions API |
| `share_plus` | Web Share API (`navigator.share`) — fallback لـ copy link |
| `url_launcher` | `<a>` tag أو `window.open` |
| `in_app_update` | لا يوجد على Web (PWA يحدث تلقائياً) |
| `upgrader` | لا حاجة له |
| `flutter_ringtone_player` | `<audio>` element + Notification API |
| `path_provider` + ملفات محلية | localStorage / IndexedDB |
| `get_storage` | localStorage (أو `zustand/middleware/persist`) |
| `flutter_dotenv` | `.env.local` (Next.js built-in) |
| `pdf` + `printing` | `@react-pdf/renderer` أو `jsPDF` |
| `excel` | `xlsx` (SheetJS) |
| `flutter_contacts` | ❌ غير ممكن في Web (نحذفها أو نطلب رقم يدوي) |
| `app_links` (Deep Links) | Next.js URL routing (طبيعي) |
| `sign_in_with_apple` | Firebase Auth OAuthProvider مع Apple |

### مميزات Web إضافية
- ✅ SEO ممتاز (Server Components + metadata)
- ✅ مشاركة روابط مباشرة لأي صفحة
- ✅ PWA (إذا أردنا تثبيت كتطبيق)
- ✅ سرعة تحميل أعلى عبر Static Generation للصفحات الثابتة

---

## 7) RTL والخط العربي

### في `app/layout.tsx`:
```tsx
import { Cairo } from "next/font/google";

const cairo = Cairo({ subsets: ["arabic", "latin"], variable: "--font-cairo" });

export default function RootLayout({ children }) {
  return (
    <html lang="ar" dir="rtl" className={cairo.variable}>
      <body className="font-cairo">{children}</body>
    </html>
  );
}
```

### في `tailwind.config.ts`:
```ts
fontFamily: {
  cairo: ["var(--font-cairo)", "sans-serif"],
}
```

### shadcn/ui + RTL:
shadcn/ui يحتوي على بعض الـ icons والـ animations تحتاج عكس في RTL:
- استخدم `ltr:` و `rtl:` variants من Tailwind v4
- ابدل `ChevronRight` بـ `ChevronLeft` تلقائياً عبر CSS `[dir="rtl"]`

---

## 8) Theme & Colors (نسخة من Flutter)

استخدم نفس الألوان من `core/constant/theme/colors.dart` كـ CSS variables في `globals.css`:

```css
@layer base {
  :root {
    --primary: 78 122 62;          /* #4E7A3E */
    --primary-light: 107 156 90;
    --primary-dark: 58 92 46;
    --accent: 194 106 74;          /* #C26A4A */
    --secondary: 201 168 60;       /* #C9A83C */
    --background: 247 242 234;
    --surface: 254 251 245;
    --error: 181 64 58;
    /* ... */
  }
  .dark {
    --background: 26 23 20;
    --surface: 37 33 24;
    /* ... */
  }
}
```

---

## 9) خطة تنفيذ مرحلية (Roadmap)

### Phase 1 — الأساس (أسبوع 1)
- [ ] إنشاء مشروع Next.js + Tailwind + shadcn/ui
- [ ] إعداد RTL + خط Cairo + الألوان
- [ ] إعداد Firebase Web SDK
- [ ] إعداد Axios client مع Basic Auth (نسخة من `crud.dart`)
- [ ] إعداد TanStack Query + Zustand
- [ ] Layout أساسي (Navbar + Sidebar + Footer)

### Phase 2 — Authentication (أسبوع 1-2)
- [ ] Login page (Google + Apple + Phone)
- [ ] Phone verification flow (RecaptchaVerifier)
- [ ] Auth state management
- [ ] Protected routes via middleware
- [ ] Update profile / Delete account

### Phase 3 — الأسعار + المقالات (أسبوع 2)
- [ ] صفحات Prices (الأنواع + التفاصيل + التاريخ + التخصيص)
- [ ] صفحات Articles (list + detail بـ Markdown)

### Phase 4 — الأدوات (أسبوع 3-4)
- [ ] All tools page (شبكة الأدوات الـ 24)
- [ ] تنفيذ كل أداة (معظمها حسابات محلية بدون API)
- [ ] أداة دراسة الجدوى (تستخدم API)
- [ ] أداة الطقس (Geolocation + Weather API)
- [ ] جدول التحصينات + الأمراض
- [ ] رسوم بيانية بـ Recharts

### Phase 5 — الدورات (أسبوع 4-6) — الأكبر
- [ ] قائمة الدورات + إنشاء دورة جديدة
- [ ] صفحة تفاصيل الدورة
- [ ] إضافة بيانات يومية / مصاريف / مبيعات
- [ ] الملاحظات (CRUD)
- [ ] الأعضاء + الدعوات
- [ ] تقرير الإغلاق (PDF/Excel/Share)
- [ ] مقارنة الدورات
- [ ] منبه الإظلام (Web Notification API)

### Phase 6 — التشطيب (أسبوع 6-7)
- [ ] Dark mode كامل
- [ ] FCM Push Notifications Web
- [ ] PWA manifest + Service Worker
- [ ] SEO metadata لكل صفحة
- [ ] Loading states + Error boundaries
- [ ] Empty states
- [ ] Responsive (Mobile / Tablet / Desktop)

### Phase 7 — النشر (أسبوع 7)
- [ ] Build optimization
- [ ] Deploy على **Vercel** (الأفضل لـ Next.js) أو **Netlify** أو **VPS**
- [ ] إعداد Domain
- [ ] Analytics + Sentry للأخطاء

---

## 10) Backend — لا تغييرات

✅ **لا نلمس** `/Users/nims/StudioProjects/farkha/backend_farkha/`
- نفس الـ endpoints
- نفس قاعدة البيانات
- نفس Authentication (Basic Auth + Firebase token)
- نفس CORS settings (تأكد أن `Access-Control-Allow-Origin` يسمح للـ domain الجديد)

### تأكد فقط من:
1. **CORS** — في `backend_farkha/config/bootstrap.php` تأكد أن domain الـ Web مسموح
2. **Firebase token verification** — يعمل من Web Firebase SDK بنفس الطريقة
3. **Rate Limiting** — يعمل بالـ IP، لا تغيير

---

## 11) النشر (Deployment)

### الخيار المختار: **Hostinger VPS**

#### خطوات النشر التفصيلية

**1) على Hostinger VPS — تجهيز البيئة:**
```bash
# تحديث النظام
apt update && apt upgrade -y

# تثبيت Node.js 20 (إن لم يكن موجوداً)
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt install -y nodejs

# تثبيت bun
curl -fsSL https://bun.sh/install | bash
source ~/.bashrc

# تثبيت Nginx + PM2
apt install -y nginx
bun add -g pm2

# تثبيت Git
apt install -y git
```

**2) Clone وبناء المشروع:**
```bash
cd /var/www
git clone <repo-url> farkha_web
cd farkha_web
bun install
bun run build
```

**3) إعداد `.env.production` بقيم الإنتاج**

**4) PM2 لتشغيل Next.js:**
```bash
pm2 start "bun run start" --name farkha-web
pm2 startup
pm2 save
```

**5) Nginx reverse proxy (`/etc/nginx/sites-available/farkha-web`):**
```nginx
server {
  listen 80;
  server_name web.nims-farkha.com;

  location / {
    proxy_pass http://localhost:3000;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection 'upgrade';
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_cache_bypass $http_upgrade;
  }
}
```

```bash
ln -s /etc/nginx/sites-available/farkha-web /etc/nginx/sites-enabled/
nginx -t && systemctl reload nginx
```

**6) SSL via Let's Encrypt:**
```bash
apt install -y certbot python3-certbot-nginx
certbot --nginx -d web.nims-farkha.com
```

**7) CI/CD (اختياري) — GitHub Actions:**
عند push لـ main → SSH للسيرفر → `git pull && bun install && bun run build && pm2 restart farkha-web`

---

## 12) ملخص الأدوات في جملة واحدة

> **Next.js 15 (App Router) + TypeScript + Tailwind v4 + shadcn/ui + Zustand + TanStack Query + Axios + Firebase Web SDK + react-hook-form + Zod + recharts + lucide-react + dayjs + sonner.**

---

## 13) Spec-Driven Development (Spec Kit)

المشروع مهيأ بـ **GitHub Spec Kit** مع دعم **Claude Code** و **opencode**.

### الأوامر المتاحة داخل المشروع
بعد فتح Claude Code أو opencode داخل `farkha_web/`:

- `/speckit.constitution` — كتابة دستور المشروع (المبادئ والقيود)
- `/speckit.specify` — كتابة spec لميزة جديدة
- `/speckit.plan` — توليد خطة تنفيذ من spec
- `/speckit.tasks` — تقسيم الخطة لـ tasks
- `/speckit.implement` — تنفيذ tasks

### Workflow المقترح لكل ميزة
1. `/speckit.specify` "إضافة شاشة Login مع Phone OTP"
2. `/speckit.plan` لتوليد التصميم التقني
3. `/speckit.tasks` لإنشاء قائمة tasks مفصلة
4. `/speckit.implement` لتنفيذ task واحدة في كل مرة

### ملفات Spec Kit
- `.specify/` — مجلد إعدادات وقوالب Spec Kit
- `specs/` — كل ميزة في spec منفصل
- `memory/constitution.md` — مبادئ المشروع

---

## 14) أمر البدء السريع

```bash
# ⚠️ مهم: المشروع موجود بالفعل في farkha_web/ مع Spec Kit مثبت
# لا تستخدم create-next-app في الجذر — استخدم --here داخل المجلد الحالي

cd /Users/nims/StudioProjects/farkha/front_end/farkha_web

# 1) إنشاء Next.js في نفس المجلد (مع bun)
bun create next-app@latest . \
  --typescript --tailwind --app --src-dir \
  --import-alias "@/*" --turbopack --use-bun

# 2) إعداد shadcn/ui
bunx shadcn@latest init

# 3) المكتبات الأساسية
bun add zustand @tanstack/react-query axios firebase
bun add react-hook-form zod @hookform/resolvers
bun add lucide-react sonner next-themes
bun add dayjs recharts react-markdown remark-gfm
bun add lottie-react

# 4) مكونات shadcn/ui الشائعة
bunx shadcn@latest add button card input form dialog dropdown-menu \
  sheet tabs select textarea label avatar separator \
  skeleton alert badge calendar popover sonner

# 5) PDF/Excel
bun add @react-pdf/renderer xlsx

# 6) Dev dependencies
bun add -D @types/node prettier prettier-plugin-tailwindcss eslint-config-prettier

# 7) تشغيل
bun run dev
```

### تنبيهات عند إنشاء المشروع
- ⚠️ لا تحذف `.claude/` و `.opencode/` و `.specify/` الموجودة (Spec Kit)
- ⚠️ لا تحذف `WEB_VERSION_PLAN.md`
- ✅ Next.js سينشئ `package.json`, `tsconfig.json`, `next.config.ts`, `src/`, `public/`
- ✅ بعد الإنشاء، أضف `.gitignore` يحتوي `.claude/`, `.opencode/` لتجنب تسرب credentials

---

## النهاية

هذه الخطة **شاملة** ومبنية على ما هو موجود فعلياً في `farkha_app`. أي ميزة في التطبيق لها مقابلها في Web. الـ Backend يبقى كما هو بدون أي تعديل، فقط نضمن أن CORS يسمح بـ domain الموقع الجديد.
