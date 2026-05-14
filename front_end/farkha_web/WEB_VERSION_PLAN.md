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

- [ ] **Firebase Console** — إضافة Web App (تعليمات تفصيلية في قسم 16)

- [ ] **Backend CORS** — تعديل `backend_farkha/config/bootstrap.php` ليسمح بـ `nims-farkha.com`:
  ```php
  $allowed_origins = [
      'https://nims-farkha.com',
      'https://www.nims-farkha.com',
  ];
  $origin = $_SERVER['HTTP_ORIGIN'] ?? '';
  if (in_array($origin, $allowed_origins, true)) {
      header("Access-Control-Allow-Origin: $origin");
  }
  header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
  header("Access-Control-Allow-Headers: Authorization, Content-Type");
  header("Access-Control-Allow-Credentials: true");
  if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') { http_response_code(204); exit; }
  ```

- [ ] **Google OAuth Web Client** — Google Cloud Console
  - إنشاء OAuth 2.0 Client ID نوع **Web application**
  - إضافة Authorized JavaScript origins + redirect URIs

- [ ] **Apple Sign-In Web** ✅ مطلوب في v1 (Apple Dev موجود + Apple Sign-In مفعّل في iOS)
  - [x] Apple Developer account فعّال
  - [x] التطبيق على App Store + Apple Sign-In شغّال في iOS
  - [ ] **إنشاء Service ID جديد** (مختلف عن iOS Bundle ID) — مثلاً `com.nims-farkha.web.signin`
  - [ ] إضافة **Domain + Return URL** في Apple Developer:
    - Domain: `nims-farkha.com`
    - Return URL: `https://nims-farkha.com/__/auth/handler` (Firebase handler الموحد)
  - [ ] إنشاء **Private Key** (.p8) للـ Service ID (أو إعادة استخدام المفتاح الحالي)
  - [ ] في Firebase Console > Authentication > Sign-in method > Apple > Web (configure):
    - Services ID
    - Team ID
    - Key ID
    - Private Key content
  - [ ] اختبار `signInWithPopup(new OAuthProvider("apple.com"))` من الـ web

- [ ] **Google AdSense** ✅ مطلوب في v1 (الحساب موجود، الـ domain لسه)
  - [x] حساب AdSense موجود بالفعل
  - [ ] **إضافة `nims-farkha.com` في Sites** → انتظار approval (بيمكن ياخد أسبوع لـ 2)
  - [ ] بعد الـ approval، الحصول على Publisher ID + إنشاء Ad Units:
    - Banner ads (header)
    - In-article ad (داخل صفحات الأدوات)
    - Display ad (interstitial-style قبل أدوات `showBeforeAd`)
    - Sidebar ad (لـ desktop ≥ lg)
  - تفصيل تقني في قسم 8.9
  - **استراتيجية launch:** نبني الموقع كامل بـ AdSense placeholders (يعمل بدون كراش لو الـ slot ID فاضي)، ولما الـ approval يخلص نضيف الـ IDs ويتفعّل تلقائياً

- [x] **Domain** — `nims-farkha.com` (root domain، بدون subdomain) ✅ مقرر
- [x] **Production API URL** — `https://api.nims-farkha.com/backend_farkha` ✅ (نفس URL التطبيق من `farkha_app/.env`)

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
  certbot --nginx -d nims-farkha.com
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
| ~~**next-intl**~~ | ❌ غير مطلوب — الموقع عربي فقط (زي التطبيق) |
| **`dir="rtl"` + `lang="ar"`** | RTL على مستوى `<html>` |
| **next/font/google** | لتحميل خط **Cairo** |

> **قرار اللغة:** الموقع **عربي فقط** بدون i18n. النصوص مباشرة في الـ components (مش JSON translation files). ده بيوافق التطبيق الحالي ويبسّط التنفيذ.

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
| **jsPDF + html2canvas** ✅ | إنتاج PDF عبر تحويل HTML→Canvas→PDF (يدعم Cairo + RTL طبيعياً) | pdf + printing |
| **xlsx** (SheetJS) | تصدير Excel | excel |
| **Web Share API** | مشاركة | share_plus |

> **سبب اختيار jsPDF + html2canvas:** أبسط طريقة لإخراج PDF عربي RTL — نصمم الـ closeout كـ React component عادي بـ Tailwind + Cairo، ثم نلتقطه بـ html2canvas ونحفظه PDF. لا داعي لإعادة تصميم layout خاص للـ PDF.

### أدوات إضافية
| الأداة | الغرض |
|--------|-------|
| **dayjs** أو **date-fns** | معالجة التواريخ |
| **clsx + tailwind-merge** | دمج classes (تأتي مع shadcn) |
| **@radix-ui/react-*** | primitives (تأتي مع shadcn تلقائياً) |

---

## 2) موقع المشروع — Monorepo

> **قرار:** `farkha_web` يعيش داخل نفس الـ git repo الحالي (`/Users/nims/StudioProjects/farkha`) جنب `farkha_app` و `farkha_admin` و `backend_farkha`. **مفيش repo منفصل.**

```
farkha/                     ← git repo واحد
├── backend_farkha/         ← PHP REST API
├── front_end/
│   ├── farkha_app/         ← Flutter mobile
│   ├── farkha_admin/       ← Flutter admin
│   └── farkha_web/         ← 🆕 Next.js web (هنا)
└── .git/
```

### Version Sync
- **`farkha_web` يستخدم نفس الإصدار** = **v6.4.0** (متزامن مع `farkha_app`)
- في `package.json`: `"version": "6.4.0"`
- في `.env`: `NEXT_PUBLIC_APP_VERSION=6.4.0`
- لازم يتحدث مع كل bump في إصدار الـ app

### Git Hygiene للـ Monorepo
- نضيف لـ `.gitignore` الرئيسي:
  ```
  front_end/farkha_web/node_modules/
  front_end/farkha_web/.next/
  front_end/farkha_web/.env.local
  front_end/farkha_web/.env.production
  front_end/farkha_web/dist/
  front_end/farkha_web/.turbo/
  front_end/farkha_web/.claude/
  front_end/farkha_web/.opencode/
  ```
- Commits تستخدم prefix `web:` أو `feat(web):` للتمييز عن `app:` / `admin:` / `backend:`
- CI/CD ينشر `farkha_web` فقط لما تتغير ملفات تحته (path filter)

**أمر الإنشاء (داخل الـ monorepo):**
```bash
cd /Users/nims/StudioProjects/farkha/front_end/farkha_web
# المجلد موجود بالفعل مع WEB_VERSION_PLAN.md
bun create next-app@latest . \
  --typescript --tailwind --app --src-dir \
  --import-alias "@/*" --turbopack --use-bun
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

> **المصدر:** `lib/core/constant/tools_list.dart` — نفس الـ toolId والـ order والـ icons والـ related articles.
> **Icon path في Web:** `/public/icons/tools/<name>.svg`

| toolId | الاسم | Icon | Route | Related Articles | showBeforeAd |
|--------|------|------|-------|------------------|--------------|
| 1 | معامل التحويل الغذائي (FCR) | `feed_conversion_ratio.svg` | `/tools/fcr` | [19, 12] | ✅ |
| 2 | متوسط النمو اليومي (ADG) | `adg.svg` | `/tools/adg` | [13] | ✅ |
| 3 | كثافة الفراخ | `chicken_density.svg` | `/tools/chicken-density` | [4] | — |
| 4 | استهلاك العلف اليومي | `daily_feed_consumption.svg` | `/tools/daily-feed-consumption` | [12] | — |
| 5 | استهلاك العلف الكلي | `total_feed_consumption.svg` | `/tools/total-feed-consumption` | [12] | — |
| 23 | استهلاك الماء | `water.svg` | `/tools/water-consumption` | — | — |
| 6 | الوزن حسب العمر | `weight.svg` | `/tools/weight-by-age` | [13] | ✅ |
| 7 | درجة الحرارة حسب العمر | `thermometer.svg` | `/tools/temperature-by-age` | [14, 11] | — |
| 8 | ساعات الإظلام | `darkness.svg` | `/tools/darkness-levels` | [9] | — |
| 9 | تشغيل الشفاطات | `fan.svg` | `/tools/fan-operation` | [5, 6] | — |
| 24 | الطقس | `weather.svg` | `/tools/weather` | — | — |
| 10 | جدول التحصينات | `vaccination.svg` | `/tools/vaccination-schedule` | [17] | — |
| 11 | مقالات | `article.svg` | `/articles` | — | — |
| 12 | الأمراض | `diseases.svg` | `/tools/diseases` | [1, 3, 10] | — |
| 13 | متطلبات فراخ التسمين | `chicken_requirements.svg` | `/tools/broiler-requirements` | [15, 11] | — |
| 14 | دراسة جدوى | `feasibility_study.svg` | `/tools/feasibility-study` | [20] | ✅ |
| 15 | تكلفة إنتاج الفرخ | `budget.svg` | `/tools/bird-production-cost` | [12, 20] | — |
| 16 | تكلفة العلف لكل طائر | `feed_cost_per_bird.svg` | `/tools/feed-cost-per-bird` | [12] | — |
| 17 | تكلفة العلف لكل كيلو | `feed_cost_per_kilo.svg` | `/tools/feed-cost-per-kilo` | [12] | — |
| 18 | الربح الصافي للطائر | `profits.svg` | `/tools/bird-net-profit` | [20] | — |
| 19 | العائد على الاستثمار (ROI) | `return_on_investment.svg` | `/tools/roi` | [20] | — |
| 20 | نسبة النفوق | `dead_chickens.svg` | `/tools/mortality-rate` | [2, 18] | — |
| 21 | الوزن الإجمالي | `total_weight.svg` | `/tools/total-farm-weight` | [13, 8] | — |
| 22 | إجمالي الإيرادات | `total_revenue.svg` | `/tools/total-revenue` | [20] | — |

> **`showBeforeAd`** = أداة تعرض إعلان interstitial قبل فتحها في التطبيق. على Web نتركها optional (نستخدم AdSense أو نتجاهلها).

### 4.5.1 ToolEntry Type (TypeScript)
```ts
// src/lib/constants/tools-list.ts
export interface ToolEntry {
  toolId: number;
  text: string;
  icon: string;          // path تحت /public/icons/tools/
  route: string;
  relatedArticleIds?: number[];
  showBeforeAd?: boolean;
}

export const allToolsList: ToolEntry[] = [ /* ... 24 entry ... */ ];
```

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
- ✅ **Ad Gate** (شاشة إعلان قبل أدوات `showBeforeAd` — Web يستخدم AdSense interstitial-style)
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

## 4.11 جدول مفصل: Flutter Widgets → Web Components

> **هدف الجدول:** يضمن إن كل widget في `farkha_app/lib/view/widget/` له مقابل في Web بنفس الوظيفة والمظهر.

### Drawer / Side Menu
| Flutter widget | ملف Flutter | Web component | Responsive |
|---------------|-------------|---------------|------------|
| `Drawer` | `widget/drawer/drawer.dart` | `<AppDrawer />` | Sheet على mobile + Sidebar ثابت على ≥ lg |
| `DrawerHeader` | `drawer_header.dart` | `<DrawerHeader />` | يعرض اسم + email + avatar |
| `DrawerAboutApp` | `drawer_about_app.dart` | `<AboutAppSection />` | privacy / version / terms |
| `DrawerAccountSettings` | `drawer_account_settings.dart` | `<AccountSettings />` | edit name / phone / delete |
| `DrawerSupportContact` | `drawer_support_contact.dart` | `<SupportContact />` | WhatsApp + Gmail links |
| `DrawerDisclaimer` | `drawer_disclaimer.dart` | `<DisclaimerSection />` | نص تنبيه قانوني |

### AppBar / Navbar
| Flutter | Web | ملاحظات |
|---------|-----|---------|
| `appbar_home.dart` | `<HomeNavbar />` | logo + drawer trigger + menu |
| `appbar_cycle.dart` | `<CycleNavbar />` | اسم الدورة + dropdown اختيار + actions |
| `cycle_sub_screen_appbar.dart` | `<CycleSubNavbar />` | back + title |
| `custom_appbar.dart` | `<PageHeader />` | عام لباقي الصفحات |
| `cycle_picker_sheet.dart` | `<CyclePickerSheet />` | sheet bottom mobile / dropdown desktop |
| `appbar_menu_items.dart` | `<AppBarMenu />` | overflow menu (settings / theme / share) |

### Home Screen
| Flutter widget | ملف | Web component |
|---------------|-----|---------------|
| `home_screen.dart` | `screen/home_screen.dart` | `app/page.tsx` |
| `cycle_card.dart` | `widget/home/` | `<CycleCard />` |
| `cycle_card_actions.dart` | — | `<CycleCardActions />` (3-dot menu) |
| `cycle_card_dialogs.dart` | — | `<CycleCardDialogs />` (edit/delete) |
| `cycle_card_info.dart` | — | `<CycleCardInfo />` (status badges) |
| `cycle_card_stats.dart` | — | `<CycleCardStats />` (day count + birds) |
| `invitation_card.dart` | — | `<InvitationCard />` (accept/reject) |
| `price_card.dart` | — | `<PriceCard />` (today's prices snapshot) |
| `tools_section.dart` | — | `<HomeToolsSection />` (favorite tools grid) |

### Cycle Screens & Tabs
| Flutter | Web | ملاحظات |
|---------|-----|---------|
| `cycle.dart` (شاشة رئيسية بـ tabs) | `app/cycles/[id]/page.tsx` + `<CycleTabs />` | TabsList — أفقي mobile، vertical desktop |
| `overview_tab.dart` | `<OverviewTab />` | overview cards |
| `farm_tab.dart` | `<FarmTab />` | farm details + darkness section |
| `financial_tab.dart` | `<FinancialTab />` | expenses + sales summary |
| `performance_tab.dart` | `<PerformanceTab />` | charts + metrics |
| `cycle_tabs.dart` (controller) | `<CycleTabs />` Tabs primitive | shadcn Tabs |
| `cycle_tab_bar.dart` | `<CycleTabBar />` | tabs header |
| `cycle_fab.dart` | `<CycleFab />` | mobile: FAB / desktop: button في navbar |

### Cycle Data Cards (`widget/cycle/data_cards/`)
| Flutter | Web | الوظيفة |
|---------|-----|---------|
| `mortality_card.dart` + `mortality_dialogs.dart` + `mortality_history.dart` | `<MortalityCard />` + `<MortalityDialog />` + `<MortalityHistory />` | إدخال + سجل النفوق |
| `average_weight_card.dart` + dialogs + history | `<AvgWeightCard />` + dialog + history | إدخال + سجل الأوزان |
| `feed_consumption_card.dart` + `feed/` | `<FeedConsumptionCard />` + sub | استهلاك العلف |
| `medication_card.dart` + `medication/` | `<MedicationCard />` + sub | تسجيل الأدوية |
| `custom_data_card.dart` + dialogs + entry_list | `<CustomDataCard />` | بيانات مخصصة |

### Performance Tab (`widget/cycle/performance/`)
| Flutter | Web | ملاحظات |
|---------|-----|---------|
| `growth_chart.dart` (fl_chart) | `<GrowthChart />` (Recharts) | LineChart weight over days |
| `metrics_grid.dart` | `<MetricsGrid />` | grid 2x2 / 4x2 KPIs |
| `consumption_row.dart` | `<ConsumptionRow />` | feed/water/medication stats |
| `performance_calculations.dart` | `lib/utils/performance.ts` | حسابات pure functions |

### Closeout Report
| Flutter | Web | ملاحظات |
|---------|-----|---------|
| `cycle_closeout_report.dart` (screen) | `app/cycles/[id]/closeout/page.tsx` | |
| `closeout_cards.dart` | `<CloseoutCards />` | summary cards |
| `closeout_data.dart` | `<CloseoutData />` | بيانات الدورة |
| `closeout_financial.dart` | `<CloseoutFinancial />` | ملخص مالي |
| `closeout_sections.dart` | `<CloseoutSections />` | sections قابلة للطي |
| **PDF Export** (`services/pdf/`) | `@react-pdf/renderer` + custom RTL Font | يدعم Cairo + RTL |
| **Excel Export** (`services/excel/`) | `xlsx` (SheetJS) | sheet عربي مع RTL columns |
| **Share** | Web Share API + fallback | navigator.share أو download |

### Comparison
| Flutter | Web | |
|---------|-----|--|
| `cycle_comparison_screen.dart` | `app/cycles/compare/page.tsx` | |
| `comparison_cards.dart` | `<ComparisonCards />` | cycle selection cards |
| `comparison_results.dart` | `<ComparisonResults />` | side-by-side metrics |
| `comparison_widgets.dart` | `<ComparisonWidgets />` | shared bits |

### History
| Flutter | Web | |
|---------|-----|--|
| `cycle_history_screen.dart` | `app/cycles/history/page.tsx` | |
| `history_filter_bar.dart` | `<HistoryFilterBar />` | filter chips/dropdown |
| `history_cycle_item.dart` | `<HistoryCycleItem />` | list/grid item |
| `cycle_history_details_screen.dart` | `app/cycles/history/[id]/page.tsx` | |
| `history_details_header.dart` | `<HistoryHeader />` | |
| `history_details_summary.dart` | `<HistorySummary />` | |
| `history_details_bottom_sheets.dart` | `<HistoryDetailsSheets />` | mobile sheets / desktop dialogs |

### Members & Invitations
| Flutter | Web | |
|---------|-----|--|
| `members_tab.dart` | `<MembersTab />` | list + role badges |
| `add_member_tab.dart` | `<AddMemberTab />` | search by phone/email |
| `add_member_dialog.dart` | `<AddMemberDialog />` | |
| `contact_picker_dialog.dart` | ❌ | لا يوجد على Web — إدخال يدوي |
| `member_list_item.dart` | `<MemberListItem />` | |
| `member_list_widget.dart` | `<MemberList />` | |
| `overlay_toast.dart` | sonner toast | replaced by `sonner` |

### Darkness Alarm
| Flutter | Web | |
|---------|-----|--|
| `darkness_alarm_screen.dart` | `app/cycles/[id]/darkness/page.tsx` | |
| `darkness_alarm_list.dart` | `<DarknessAlarmList />` | |
| `darkness_settings_sheet.dart` | `<DarknessSettingsSheet />` (Sheet/Dialog) | |
| `farm_darkness_section.dart` | `<FarmDarknessSection />` | |
| Native ringtone player | Web Audio + Notification API | `<audio>` element |

### Notes
| Flutter | Web | |
|---------|-----|--|
| `cycle_notes.dart` (screen) | `app/cycles/[id]/notes/page.tsx` | |
| `cycle_notes_widgets.dart` | `<NotesEditor />` + `<NoteCard />` | |

### Expenses & Sales
| Flutter | Web | |
|---------|-----|--|
| `cycle_expenses.dart` (screen) | `app/cycles/[id]/expenses/page.tsx` | |
| `add_expense_dialog.dart` | `<AddExpenseDialog />` | |
| `expense_card.dart` | `<ExpenseCard />` | |
| `expense_history_list.dart` | `<ExpenseHistoryList />` | |
| `expense_dialogs.dart` | edit/delete dialogs | |
| `cycle_sales.dart` (screen) | `app/cycles/[id]/sales/page.tsx` | |
| `sales_dialogs.dart` | add/edit/delete | |
| `sale_card.dart` | `<SaleCard />` | |
| `sales_hero.dart` | `<SalesHero />` | total revenue header |

### Weekly Report & Time-sensitive Hints
| Flutter | Web | |
|---------|-----|--|
| `weekly_report_bottom_sheet.dart` | `<WeeklyReportSheet />` (Sheet on mobile / Dialog on desktop) | |
| `weekly_report_sections.dart` | `<WeeklyReportSections />` | |
| `time_sensitive_hint_sheet.dart` | `<TimeSensitiveHintSheet />` | tips حسب يوم الدورة |

### Auth
| Flutter | Web | |
|---------|-----|--|
| `login_screen.dart` | `app/(auth)/login/page.tsx` | |
| `verify_phone_number_screen.dart` | `app/(auth)/verify-phone/page.tsx` | |
| `enter_otp_screen.dart` | `app/(auth)/enter-otp/page.tsx` | |
| `country_prefix_label.dart` | `<CountryPrefixLabel />` | flag + +20 |
| `phone_input_field.dart` | `<PhoneInputField />` | rtl + intl-tel-input |
| `otp_input_field.dart` (pin_code_fields) | `<OtpInputField />` (input-otp من shadcn) | 6 خانات |
| `resend_countdown_button.dart` | `<ResendCountdownButton />` | timer 60s |

### Onboarding
| Flutter | Web | |
|---------|-----|--|
| `onboarding_screen.dart` | `app/onboarding/page.tsx` | |
| `custom_slider.dart` | `<OnboardingSlider />` (embla-carousel) | 3 slides |
| `custom_button.dart` | shadcn Button | |
| `dot_controller.dart` | `<SlideDots />` | indicator |
| `skip_button.dart` | `<SkipButton />` | |
| **SVGs:** `cycle.svg`, `prices.svg`, `tools.svg` | نسخ لـ `/public/images/onboarding/` | |

### Prices
| Flutter | Web | |
|---------|-----|--|
| `main_types_screen.dart` | `app/prices/page.tsx` | |
| `prices_by_type_screen.dart` | `app/prices/[type]/page.tsx` | |
| `price_history_screen.dart` | `app/prices/history/page.tsx` | + chart |
| `customize_prices_screen.dart` | `app/prices/customize/page.tsx` | |
| `widget/prices/prices_card/` | `<PriceCard />` family | |
| `widget/prices/table/` | `<PricesTable />` | |
| `price_history_chart.dart` (fl_chart) | `<PriceHistoryChart />` (Recharts AreaChart) | |
| `price_row_item_history.dart` | `<PriceHistoryRow />` | |
| `price_change.dart` (`shared/`) | `<PriceChangeIndicator />` | up/down arrow + % |

### Tools Widgets (shared)
| Flutter | Web | |
|---------|-----|--|
| `tool_card.dart` | `<ToolCard />` | icon + label, used in grids |
| `tools_card.dart` | `<ToolsCard />` (alt) | |
| `tool_page_scaffold.dart` | `<ToolPageScaffold />` | layout موحد لكل أداة |
| `tools_button.dart` | `<ToolPrimaryButton />` | الحساب button |
| `notes_card.dart` | `<NotesCard />` | ملاحظات داخل الأداة |
| `related_articles_section.dart` | `<RelatedArticlesSection />` | يفلتر `relatedArticleIds` |
| `articles/` | `app/articles/` (list + detail) | markdown render |
| `disease/` | `app/tools/diseases/` + `<DiagnosisFlow />` | Q&A diagnostic |
| `feasibility_study/` | `app/tools/feasibility-study/` | uses API |
| `broiler_chicken_requirements/` | `app/tools/broiler-requirements/` | |
| `vaccination_schedule_widgets.dart` | `<VaccinationSchedule />` | table by age |
| `total_farm_weight_widgets.dart` | `<TotalFarmWeight />` | |

### Weather
| Flutter | Web | |
|---------|-----|--|
| `weather_screen.dart` | `app/tools/weather/page.tsx` | |
| `weather_hero.dart` | `<WeatherHero />` | current weather card |
| `weather_forecast.dart` | `<WeatherForecast />` | 7-day forecast |
| `weather_stats.dart` | `<WeatherStats />` | wind/humidity/uv |
| `weather_icons` package | `lucide-react` icons أو SVG مخصص | |
| `geolocator` | `navigator.geolocation` | request permission |

### Reviews & Feedback
| Flutter | Web | |
|---------|-----|--|
| `app_review_dialog.dart` | `<AppReviewDialog />` | rating stars |
| `rating_description.dart` | `<RatingDescription />` | تختلف حسب star count |
| `star_rating_input.dart` | `<StarRatingInput />` | interactive 1-5 |
| `cycle_feedback_dialog.dart` | `<CycleFeedbackDialog />` | بعد إنهاء دورة |

### Ads
| Flutter | Web |
|---------|-----|
| `widget/ad/banner.dart` | ❌ أو AdSense banner |
| `widget/ad/interstitial.dart` + wrapper | ❌ أو AdSense interstitial |
| `widget/ad/native.dart` | ❌ |
| `shared/ad_gate.dart` | `<AdGate />` no-op أو AdSense |

### Shared / Misc
| Flutter | Web |
|---------|-----|
| `shared/snackbar_message.dart` | `sonner` toast |
| `shared/usage_tips_dialog.dart` | `<UsageTipsDialog />` (first-time tooltip) |
| `shared/permissions_intro_dialog.dart` | `<PermissionsIntroDialog />` (notification/geo) |
| `shared/dialogs/` | `components/ui/dialog/` + custom |
| `shared/buttons/` | shadcn Button variants + custom |
| `shared/formatters/` | `lib/utils/format.ts` |
| `shared/input_fields/` | shadcn Input variants |
| `shared/tools/` | shared tool utilities |

### Lottie Animations
| Flutter | Web (`lottie-react`) |
|---------|---------------------|
| `assets/lottie/loading.json` | `<LottieAnimation src="/lottie/loading.json" />` |
| `assets/lottie/error.json` | error state |
| `assets/lottie/no_data.json` | empty state |
| `assets/lottie/offline.json` | offline state (مع InternetChecker) |

> ✅ ملف JSON Lottie يشتغل مباشرة على Web بدون أي تحويل.

---

## 5) ربط الـ Backend (نفس الـ API بدون تغيير)

### 5.1 Base URL والـ Auth
في `.env.local` (نفس القيم الموجودة في `farkha_app/.env`):

```env
# ── API ──────────────────────────────────────────────
# Production (نفس الـ URL اللي بيستخدمه farkha_app/.env):
NEXT_PUBLIC_API_HOST=https://api.nims-farkha.com/backend_farkha
# Development بديل (محلي MAMP):
# NEXT_PUBLIC_API_HOST=http://192.168.1.3:8888
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
# نفس الـ key اللي بيستخدمه farkha_app/.env (WeatherAPI.com)
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
NEXT_PUBLIC_APP_VERSION=6.4.0     # متزامن مع الـ Flutter app
NEXT_PUBLIC_PLATFORM=web

# ── AdSense ──────────────────────────────────────────
NEXT_PUBLIC_ADSENSE_CLIENT=ca-pub-XXXXXXXXXXXXXXXX
NEXT_PUBLIC_AD_SLOT_HEADER=XXXXXXXXXX
NEXT_PUBLIC_AD_SLOT_ARTICLE=XXXXXXXXXX
NEXT_PUBLIC_AD_SLOT_INTERSTITIAL=XXXXXXXXXX
NEXT_PUBLIC_AD_SLOT_SIDEBAR=XXXXXXXXXX
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
| `google_mobile_ads` (إعلانات AdMob) | **Google AdSense** ✅ (مفعّل في v1) — banner + in-article + interstitial-style |
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
| `pdf` + `printing` | **`jsPDF` + `html2canvas`** (نصمم HTML بـ Cairo+RTL ونحوّله) |
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

### 7.1 إعداد Cairo بكل الأوزان

التطبيق يستخدم 6 أوزان من Cairo: `ExtraLight (200)`, `Light (300)`, `Regular (400)`, `SemiBold (600)`, `Bold (700)`, `Black (900)`. نفس الأوزان في Web:

```tsx
// app/layout.tsx
import { Cairo } from "next/font/google";

const cairo = Cairo({
  subsets: ["arabic", "latin"],
  weight: ["200", "300", "400", "600", "700", "900"],
  variable: "--font-cairo",
  display: "swap",
});

export default function RootLayout({ children }) {
  return (
    <html lang="ar" dir="rtl" className={cairo.variable}>
      <body className="font-cairo antialiased">{children}</body>
    </html>
  );
}
```

### 7.2 RTL على مستوى Tailwind v4
Tailwind v4 يدعم logical properties:
- `me-4` بدل `mr-4` (margin-end)
- `ms-4` بدل `ml-4` (margin-start)
- `ps-2`, `pe-2`, `text-start`, `text-end`
- `start-0`, `end-0` بدل `left-0`, `right-0`
- variants: `ltr:text-left rtl:text-right`

### 7.3 الأيقونات الاتجاهية
- استخدم `rtl:rotate-180` على `<ChevronRight />`, `<ArrowRight />`
- أو استخدم `<ChevronLeft />` لما يكون المعنى "التالي" في RTL
- shadcn يستخدم `lucide-react` — معظم الأيقونات تشتغل بدون عكس

### 7.4 Numbers & Dates في RTL
- استخدم `Intl.NumberFormat("ar-EG")` لأرقام عربية أو `"en-US"` لإنجليزية
- التواريخ: `dayjs/locale/ar-eg` للأشهر العربية
- التطبيق يستخدم أرقام إنجليزية في الإدخالات والحسابات — نفس النهج في Web

### 7.5 shadcn/ui + RTL gotchas
- `<Sheet side="right">` على mobile (drawer) — في RTL يبقى من اليمين تلقائياً
- `<DropdownMenu>` align يحتاج تعديل في RTL (`align="end"` يبقى يسار)
- `<Tabs>` orientation horizontal يشتغل native، vertical على ≥ lg
- استورد `dir="rtl"` على root وكل الـ primitives تتصرف صح
- بعض الـ animations تحتاج reverse: `data-[side=right]:slide-in-from-right`

### 7.6 Cairo + Flutter mapping للأوزان

| Flutter `FontWeight` | CSS `font-weight` | Tailwind |
|----------------------|-------------------|----------|
| `w200` (ExtraLight) | 200 | `font-extralight` |
| `w300` (Light) | 300 | `font-light` |
| `w400` (Regular) | 400 | `font-normal` |
| `w500` (Medium) | 500 | `font-medium` (مش متوفر في Cairo التطبيق — استخدم 600) |
| `w600` (SemiBold) | 600 | `font-semibold` |
| `w700` (Bold) | 700 | `font-bold` |
| `w800` (ExtraBold) | 800 | `font-extrabold` (مش متوفر في Cairo التطبيق — استخدم 700 أو 900) |
| `w900` (Black) | 900 | `font-black` |

> **ملاحظة:** التطبيق يستخدم `w500` و `w800` من Cairo. تحميل وزن غير موجود يعمل synthesis. لو محتاجين دقة كاملة، حمّل 8 أوزان بدل 6.

---

## 8) Theme & Design Tokens (نسخ كامل من Flutter)

> **المصدر:** `farkha_app/lib/core/constant/theme/colors.dart` + `theme.dart`
> **الأساس:** Tailwind v4 CSS variables (لازم تتطابق تماماً مع الـ Flutter ColorScheme و TextTheme).

### 8.1 لوحة الألوان الكاملة (`globals.css`)

```css
@layer base {
  :root {
    /* ── Primary: Olive Green (fields, growth, life) ── */
    --primary:               78 122 62;     /* #4E7A3E */
    --primary-light:         107 156 90;    /* #6B9C5A */
    --primary-dark:          58 92 46;      /* #3A5C2E */
    --primary-container:     212 232 206;   /* #D4E8CE */

    /* ── Accent: Terracotta (earth, warmth, poultry) ── */
    --accent:                194 106 74;    /* #C26A4A */
    --accent-light:          212 139 110;   /* #D48B6E */

    /* ── Secondary: Golden Wheat (harvest, positive) ── */
    --secondary:             201 168 60;    /* #C9A83C */
    --secondary-light:       223 192 106;   /* #DFC06A */

    /* ── Light Theme Surfaces ── */
    --background:            247 242 234;   /* #F7F2EA — أساسي */
    --page-background:       240 234 224;   /* #F0EAE0 */
    --surface:               254 251 245;   /* #FEFBF5 */
    --card:                  255 255 255;   /* #FFFFFF */
    --outline:               221 213 198;   /* #DDD5C6 */

    /* ── Text (Light) ── */
    --text-primary:          44 42 37;      /* #2C2A25 */
    --text-secondary:        58 55 48;      /* #3A3730 */
    --text-tertiary:         74 70 64;      /* #4A4640 */
    --text-muted:            106 102 92;    /* #6A665C */
    --text-disabled:         122 118 108;   /* #7A766C */

    /* ── Semantic ── */
    --error:                 181 64 58;     /* #B5403A */
    --success:               78 122 62;     /* #4E7A3E (نفس الـ primary) */
    --warning:               201 168 60;    /* #C9A83C */
    --info:                  91 138 122;    /* #5B8A7A */

    /* ── Gradients (للخلفيات والـ heroes) ── */
    --sunset-start:          194 106 74;    /* terracotta */
    --sunset-end:            201 168 60;    /* wheat */
    --ocean-start:           78 122 62;     /* olive */
    --ocean-end:             143 188 143;   /* light olive */
  }

  .dark {
    --primary:               143 188 143;   /* #8FBC8F */
    --primary-container:     58 92 46;      /* #3A5C2E */
    --accent:                212 139 110;   /* #D48B6E */
    --secondary:             223 192 106;   /* #DFC06A */

    --background:            26 23 20;      /* #1A1714 */
    --surface:               37 33 24;      /* #252118 */
    --surface-elevated:      48 44 36;      /* #302C24 */
    --outline:               74 68 56;      /* #4A4438 */

    --text-primary:          232 226 216;   /* #E8E2D8 */
    --text-secondary:        208 202 184;   /* #D0CAB8 */
    --text-tertiary:         192 184 168;   /* #C0B8A8 */
    --text-muted:            144 136 120;   /* #908878 */
    --text-disabled:         128 120 104;   /* #807868 */

    --error:                 229 115 115;   /* #E57373 */
  }
}
```

### 8.2 Typography Scale (نقل دقيق من `TextTheme`)

| Token | font-size | weight | line-height | الاستخدام |
|-------|-----------|--------|-------------|-----------|
| `display-lg` | 2rem (32px) | 800 | 1.2 | عناوين Hero |
| `display-md` | 1.75rem (28px) | 700 | 1.2 | عناوين رئيسية |
| `display-sm` | 1.5rem (24px) | 700 | 1.25 | عناوين أقسام |
| `headline-lg` | 1.375rem (22px) | 700 | 1.3 | AppBar / Page title |
| `headline-md` | 1.25rem (20px) | 600 | 1.3 | عناوين بطاقات كبيرة |
| `headline-sm` | 1.125rem (18px) | 600 | 1.35 | عناوين بطاقات |
| `title-lg` | 1.0625rem (17px) | 600 | 1.35 | tabs / list headers |
| `title-md` | 0.9375rem (15px) | 500 | 1.4 | labels قوية |
| `title-sm` | 0.8125rem (13px) | 500 | 1.4 | labels صغيرة |
| `body-lg` | 0.9375rem (15px) | 400 | 1.5 | نص أساسي |
| `body-md` | 0.875rem (14px) | 400 | 1.5 | نص ثانوي |
| `body-sm` | 0.75rem (12px) | 400 | 1.45 | hints / captions |
| `label-lg` | 0.875rem (14px) | 600 | 1.4 | أزرار |
| `label-md` | 0.75rem (12px) | 500 | 1.4 | chips / badges |
| `label-sm` | 0.6875rem (11px) | 400 | 1.4 | meta |

### 8.3 Spacing Scale (نقل من `AppSpacing`)

| Token | px | rem | يقابل Tailwind |
|-------|-----|-----|----------------|
| `xs` | 4 | 0.25rem | `1` |
| `sm` | 8 | 0.5rem | `2` |
| `md` | 12 | 0.75rem | `3` |
| `lg` | 16 | 1rem | `4` |
| `xl` | 24 | 1.5rem | `6` |
| `xxl` | 32 | 2rem | `8` |
| `screen-h` | 16 | 1rem | padding أفقي للصفحة |

### 8.4 Border Radius (نقل من `AppDimens`)

| Token | px | الاستخدام |
|-------|-----|-----------|
| `radius-sm` | 8 | inputs، chips |
| `radius-md` | 12 | cards، buttons |
| `radius-lg` | 16 | dialogs، sheets |
| `radius-xl` | 24 | hero cards، modals |

### 8.5 Elevation / Shadow (نقل من `AppElevation`)

| Token | shadow CSS |
|-------|------------|
| `elev-none` | لا يوجد |
| `elev-sm` | `0 1px 2px rgba(0,0,0,0.04), 0 1px 1px rgba(0,0,0,0.06)` |
| `elev-md` | `0 2px 4px rgba(0,0,0,0.06), 0 2px 2px rgba(0,0,0,0.04)` |
| `elev-lg` | `0 4px 8px rgba(0,0,0,0.08)` |
| `elev-xl` | `0 8px 16px rgba(0,0,0,0.10)` |
| **`elev-card`** | `0 2px 8px rgba(0,0,0,0.08)` ← الافتراضي للـ cards |

> **Dark mode:** الـ cards مالهاش shadow (elevation=0)، بدلها outline من `--outline`.

### 8.6 ربط tokens بـ Tailwind v4

في `globals.css`:
```css
@theme inline {
  --color-primary: rgb(var(--primary));
  --color-accent: rgb(var(--accent));
  --color-secondary: rgb(var(--secondary));
  --color-background: rgb(var(--background));
  --color-surface: rgb(var(--surface));
  --color-card: rgb(var(--card));
  --color-outline: rgb(var(--outline));

  --font-cairo: var(--font-cairo);

  --radius-sm: 0.5rem;
  --radius-md: 0.75rem;
  --radius-lg: 1rem;
  --radius-xl: 1.5rem;
}
```

---

## 8.7) Responsive Design Strategy ⭐ (محوري)

> **Mobile-first** — نبدأ بتصميم الموبايل (مطابق للتطبيق) ثم نوسّع للـ tablet و desktop.

### Breakpoints (Tailwind default + إضافة xs)

| Name | Width | الجهاز |
|------|-------|--------|
| `xs` | < 480px | موبايل صغير |
| `sm` | ≥ 640px | موبايل كبير / phablet |
| `md` | ≥ 768px | tablet |
| `lg` | ≥ 1024px | desktop صغير / laptop |
| `xl` | ≥ 1280px | desktop |
| `2xl` | ≥ 1536px | desktop كبير |

### Container Max-Width

| Breakpoint | max-width | sidebar |
|------------|-----------|---------|
| < lg | 100% | drawer (سحب من اليمين) |
| ≥ lg | 1024px content + 280px sidebar ثابت |
| ≥ xl | 1200px content + 280px sidebar ثابت |
| ≥ 2xl | 1400px content + 320px sidebar ثابت |

### Layout Pattern (متغير حسب الـ breakpoint)

**Mobile (< md):**
```
┌─────────────────────┐
│   AppBar + Menu     │
├─────────────────────┤
│                     │
│   Page Content      │
│   (full width)      │
│                     │
├─────────────────────┤
│  BottomNav (4 tabs) │
└─────────────────────┘
[Drawer: slides from right]
```

**Tablet (md → lg):**
```
┌─────────────────────────────┐
│        Top Navbar           │
├─────────────────────────────┤
│                             │
│   Page Content              │
│   (constrained 90%)         │
│   2-col grids حيث ممكن     │
│                             │
└─────────────────────────────┘
[Drawer: slides from right]
```

**Desktop (≥ lg):**
```
┌───────────┬─────────────────────┐
│           │      Top Navbar      │
│           ├──────────────────────┤
│  Sidebar  │                      │
│  (ثابت)   │   Page Content       │
│  Drawer   │   (max 1024-1400px) │
│  محتواه   │   3-4 col grids      │
│           │                      │
└───────────┴──────────────────────┘
```

### الترجمة من Mobile UI Patterns إلى Web

| نمط موبايل (Flutter) | نسخة Mobile Web | نسخة Tablet/Desktop |
|-----------------------|------------------|---------------------|
| **Drawer** (`drawer/drawer.dart`) | Drawer منزلق من اليمين | Sidebar ثابت يسار/يمين |
| **AppBar مع Back** | AppBar أعلى + زر رجوع | Top navbar + breadcrumb |
| **BottomNav** | شريط سفلي | Tabs أفقية أعلى الـ content أو في الـ sidebar |
| **Bottom Sheet** (weekly_report، time_sensitive_hint، darkness_settings) | bottom sheet نفس النمط | Side Drawer (Sheet من اليمين) أو Dialog مركزي |
| **FAB (cycle_fab)** | FAB دائري أسفل يسار | زر Primary في الـ top bar أو ثابت overlay |
| **Cycle Tabs** (Overview/Farm/Financial/Performance/Members) | Tabs أفقية + Swipe | Tabs أفقية بدون swipe + content أوسع، أو **Vertical tabs** في الـ sidebar |
| **Tools Grid** | 2 columns | 3 (md), 4 (lg), 6 (xl), 8 (2xl) columns |
| **Cycle Cards (home)** | عمود واحد | 2 (md), 3 (lg) columns |
| **Articles List** | عمود واحد + thumbnail | masonry 2-3 columns أو list مع preview |
| **Phone OTP** | شاشة كاملة | dialog مركزي + max-width 480px |
| **Login Screen** | شاشة كاملة | split layout (illustration يسار + form يمين) |
| **Tool Page Scaffold** | inputs عمودية + result أسفل | side-by-side: inputs يسار + result مرئي يمين |
| **Cycle Closeout PDF preview** | scroll عمودي | preview على الـ desktop بحجم A4 منعكس |

### Responsive Components Strategy

#### Tools Grid (`tools_section.dart` / `all_tools.dart`)
```tsx
<div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-6 xl:grid-cols-8 gap-3 md:gap-4">
  {tools.map(tool => <ToolCard ... />)}
</div>
```

#### Cycle Cards Grid (home)
```tsx
<div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
```

#### Cycle Tab Layout
- **Mobile:** TabsList أفقي + swipeable content
- **Desktop (≥ lg):** TabsList vertical في side panel + content area واسع

#### Tool Page (e.g., FCR, ADG)
- **Mobile:** form عمودي → button → result card
- **Desktop:** grid 2 columns — form (right in RTL) + result preview (left in RTL) جنب بعض

#### Dialogs vs Bottom Sheets
- **Mobile:** `<Sheet side="bottom">` (نفس Flutter modal bottom sheet)
- **Desktop:** `<Dialog>` مركزي بـ max-width مناسب (sm: 480px, md: 640px, lg: 800px)
- Helper: `<ResponsiveSheet>` component يختار تلقائياً حسب الـ breakpoint

#### Drawer vs Sidebar
- **< lg:** `<Sheet side="right">` (sheet منزلق)
- **≥ lg:** Sidebar ثابت في الـ layout grid

### Charts Responsive (Recharts)
- استخدم `<ResponsiveContainer width="100%" height={...}>`
- على Mobile: height = 240px
- على Desktop: height = 360px أو 400px
- Growth Chart في Performance Tab: aspect-ratio على Desktop

### Forms Responsive
- **Mobile:** field كل سطر، full-width
- **Tablet:** 2 columns للـ fields الصغيرة (تواريخ، أرقام)
- **Desktop:** form مع labels على اليمين والـ inputs على اليسار في sections

### Typography Responsive
- نستخدم `clamp()` للعناوين الكبيرة:
```css
--display-lg: clamp(1.5rem, 4vw, 2rem);
```
- باقي النصوص ثابتة (مش زي flutter_screenutil) لأن CSS أكثر استقراراً.

### Images Responsive
- Logo: SVG ينضبط بـ width auto + max-height
- Tool icons (24 SVG): حجم ثابت 48px على mobile، 64px على desktop
- Onboarding SVG: max-width 320px على mobile، 480px على desktop
- استخدم `next/image` للـ raster images مع `sizes`

### RTL + Responsive
- Tailwind v4 يدعم `ltr:` و `rtl:` variants بشكل مدمج
- استخدم `me-` (margin-end) بدل `ml-` و `ms-` (margin-start) بدل `mr-`
- Chevron icons: استخدم `rtl:rotate-180` على الأسهم الاتجاهية
- AppBar back button: في RTL يبقى على اليمين تلقائياً

### Touch vs Mouse Affordances
- على < lg: targets ≥ 44x44px (touch-friendly)
- على ≥ lg: targets ≥ 32x32px + hover states واضحة
- Hover effects تظهر فقط على devices مع `(hover: hover)` media query

### Testing Responsive
- اختبر على: iPhone SE (375px), iPhone 14 (393px), iPad (768px), iPad Pro (1024px), Laptop (1366px), Desktop (1920px)
- Lighthouse mobile/desktop scores ≥ 90
- استخدم Chrome DevTools device toolbar مع network throttling

---

## 8.8) PWA Configuration ⭐ (مطلوب في v1)

### Manifest (`public/manifest.json`)
```json
{
  "name": "فرخة",
  "short_name": "فرخة",
  "description": "تطبيق إدارة مزارع الدواجن",
  "lang": "ar",
  "dir": "rtl",
  "start_url": "/",
  "display": "standalone",
  "background_color": "#F7F2EA",
  "theme_color": "#4E7A3E",
  "orientation": "portrait-primary",
  "icons": [
    { "src": "/icons/pwa-192.png", "sizes": "192x192", "type": "image/png", "purpose": "any" },
    { "src": "/icons/pwa-512.png", "sizes": "512x512", "type": "image/png", "purpose": "any" },
    { "src": "/icons/pwa-maskable-512.png", "sizes": "512x512", "type": "image/png", "purpose": "maskable" }
  ],
  "shortcuts": [
    { "name": "أسعار اليوم", "url": "/prices", "icons": [{ "src": "/icons/shortcut-prices.png", "sizes": "96x96" }] },
    { "name": "أدوات", "url": "/tools", "icons": [{ "src": "/icons/shortcut-tools.png", "sizes": "96x96" }] },
    { "name": "دوراتي", "url": "/cycles", "icons": [{ "src": "/icons/shortcut-cycles.png", "sizes": "96x96" }] }
  ],
  "screenshots": [
    { "src": "/screenshots/home.png", "sizes": "1080x1920", "type": "image/png", "form_factor": "narrow" },
    { "src": "/screenshots/desktop.png", "sizes": "1920x1080", "type": "image/png", "form_factor": "wide" }
  ]
}
```

### Service Worker Strategy
نستخدم **`next-pwa` (next-pwa أو @ducanh2912/next-pwa) أو Workbox** مع service worker واحد يدمج:

1. **FCM messaging handler** (`firebase-messaging-sw.js`) — للـ push notifications
2. **Offline caching:**
   - **Cache First** للـ static assets (icons, fonts, lottie, SVG tools)
   - **Stale While Revalidate** للـ articles + diseases + tools list
   - **Network First** للـ API calls (prices, cycles, etc.) مع fallback لآخر cache
3. **Offline page** — صفحة fallback مع `lottie/offline.json` لما الـ network مقطوع

### Install Prompt UX
- Listen لـ `beforeinstallprompt` event
- زر "تثبيت كتطبيق" يظهر في Drawer/Sidebar بعد 3 visits
- iOS: لا يدعم install prompt — نعرض tooltip "أضف للشاشة الرئيسية" مع شرح
- نستخدم `@khmyznikov/pwa-install` أو custom component

### App Icons
- نحتاج تصدير `logo.png` بأحجام: 192, 384, 512, maskable-512
- أيقونات Apple Touch: 180x180
- Favicon: 32x32 + 16x16

### Meta tags في `app/layout.tsx`
```tsx
export const viewport: Viewport = {
  themeColor: [
    { media: "(prefers-color-scheme: light)", color: "#4E7A3E" },
    { media: "(prefers-color-scheme: dark)", color: "#8FBC8F" },
  ],
  width: "device-width",
  initialScale: 1,
  maximumScale: 5,
};

export const metadata: Metadata = {
  manifest: "/manifest.json",
  appleWebApp: {
    capable: true,
    statusBarStyle: "default",
    title: "فرخة",
  },
};
```

---

## 8.9) AdSense Integration ⭐ (مطلوب في v1)

### Setup
1. حساب AdSense معتمد + `nims-farkha.com` في Sites
2. **Publisher ID:** `ca-pub-XXXXXXXX`
3. إضافة AdSense script في `app/layout.tsx`:
```tsx
<Script
  async
  src={`https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=${PUBLISHER_ID}`}
  crossOrigin="anonymous"
  strategy="afterInteractive"
/>
```
4. ملف `public/ads.txt` (اختياري لكن موصى به):
```
google.com, pub-XXXXXXXX, DIRECT, f08c47fec0942fa0
```

### Ad Components
| Component | Slot | Placement |
|-----------|------|-----------|
| `<AdBanner />` | header banner (`AD_SLOT_HEADER`) | أعلى الصفحات (مش Auth) |
| `<AdInArticle />` | in-article (`AD_SLOT_ARTICLE`) | داخل الأدوات بين Input و Result |
| `<AdInterstitialGate />` | display (`AD_SLOT_INTERSTITIAL`) | بديل AdMob interstitial — قبل أدوات `showBeforeAd` |
| `<AdSidebar />` | display (`AD_SLOT_SIDEBAR`) | على desktop ≥ lg في الجانب |

### AdGate Flow (`shared/ad_gate.dart` → `<AdInterstitialGate />`)
1. أدوات `showBeforeAd === true` (FCR/ADG/Weight/Feasibility) تستخدم Gate
2. أول مرة في session: عرض dialog فيه Ad + countdown 5 ثواني
3. بعد timer يظهر "تخطي" → ينقلها لصفحة الأداة
4. تحفظ في sessionStorage إن المستخدم شاف Ad → ما يتفرضش تاني نفس الجلسة

### AdSense Policy Compliance
- ❌ لا إعلانات على صفحات Auth/Login/OTP
- ❌ لا إعلانات على صفحات Payment/Delete Account
- ❌ لا إعلانات قبل main content load
- ✅ إعلانات مع content حقيقي (مش صفحات فاضية)
- ✅ في حالة Ad Blocker → fallback (نعرض الـ content بدون gate)

### Privacy
- إضافة Cookie Consent banner للـ EU users (GDPR)
- Privacy Policy تذكر AdSense + Google ads
- Terms of Service محدثة

---

## 9) خطة تنفيذ مرحلية (Roadmap)

### Phase 1 — الأساس + Design System (أسبوع 1)
- [ ] إنشاء مشروع Next.js + Tailwind v4 + shadcn/ui + bun
- [ ] إعداد RTL (`dir="rtl"`, `lang="ar"`) + خط Cairo (6 أوزان)
- [ ] **نقل كامل لـ Design Tokens** من `theme.dart` و `colors.dart`:
  - [ ] CSS variables للألوان (light + dark) — قسم 8.1
  - [ ] Typography scale (قسم 8.2)
  - [ ] Spacing/radius/elevation tokens (8.3-8.5)
- [ ] **Responsive Layout أساسي:**
  - [ ] `<AppShell>` يبدل Drawer↔Sidebar حسب breakpoint
  - [ ] `<ResponsiveSheet>` يبدل Bottom Sheet↔Dialog
  - [ ] `<MobileBottomNav>` للـ < lg
- [ ] إعداد Firebase Web SDK + VAPID
- [ ] Axios client مع Basic Auth (مع proxy عبر Next.js Route Handlers)
- [ ] TanStack Query + Zustand stores
- [ ] **Storybook أو page تجريبية** لكل tokens — تأكيد المطابقة مع التطبيق

### Phase 2 — Authentication (أسبوع 1-2)
- [ ] Login page (Google + **Apple** + Phone) ✅ Apple مطلوب في v1
- [ ] **Apple Sign-In setup:** Service ID + Return URL + Private Key في Firebase Console
- [ ] Phone verification flow (RecaptchaVerifier invisible)
- [ ] Auth state management (Zustand)
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
- [ ] تقرير الإغلاق (jsPDF+html2canvas للـ PDF / xlsx للـ Excel / Web Share API)
- [ ] مقارنة الدورات
- [ ] منبه الإظلام (Web Notification API)

### Phase 6 — التشطيب والـ Polish (أسبوع 6-7)
- [ ] Dark mode كامل (تطابق Flutter darkThemes)
- [ ] FCM Push Notifications Web + `firebase-messaging-sw.js`
- [ ] **PWA كامل** (مطلوب v1):
  - [ ] `manifest.json` + icons (192/384/512/maskable + Apple touch)
  - [ ] Service Worker (Workbox أو next-pwa) + offline caching
  - [ ] Install prompt UX (Drawer button + iOS tooltip)
  - [ ] Offline fallback page (lottie/offline.json)
  - [ ] App shortcuts (prices/tools/cycles)
- [ ] **AdSense Integration** (مطلوب v1):
  - [ ] AdSense script في layout
  - [ ] `<AdBanner />` على pages المسموحة
  - [ ] `<AdInArticle />` داخل الأدوات
  - [ ] `<AdInterstitialGate />` قبل أدوات `showBeforeAd`
  - [ ] `<AdSidebar />` على ≥ lg
  - [ ] Cookie consent banner (GDPR)
  - [ ] `ads.txt` في public
- [ ] SEO metadata لكل صفحة + Open Graph + Twitter cards
- [ ] Loading states (Lottie loading.json) + Error boundaries (error.json)
- [ ] Empty states (no_data.json) + Offline indicator (offline.json)
- [ ] **Responsive audit شامل** على Breakpoints:
  - [ ] iPhone SE (375), iPhone 14 (393), Galaxy (412)
  - [ ] iPad (768), iPad Pro (1024)
  - [ ] Laptop (1366), Desktop (1920), 4K (2560)
- [ ] Touch targets ≥ 44px على < lg
- [ ] Hover states على ≥ lg
- [ ] Lighthouse Mobile + Desktop ≥ 90 (Performance + a11y + SEO + PWA)
- [ ] Cross-browser: Chrome, Safari (iOS + macOS), Firefox, Edge
- [ ] **مطابقة بصرية مع التطبيق:** يفتح التطبيق على موبايل والموقع جنبه ويتم التأكد إن كل لون/خط/spacing متطابق
- [ ] **اختبار AdSense + Ad Blockers** — fallback graceful

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

**2) Clone وبناء المشروع (Monorepo strategy):**
```bash
cd /var/www
# Clone الـ monorepo كامل (مرة واحدة بس)
git clone <farkha-monorepo-url> farkha
cd farkha/front_end/farkha_web

bun install
bun run build
```

> **بديل أخف:** sparse-checkout للـ `farkha_web/` فقط (يقلل حجم الـ clone):
> ```bash
> git clone --filter=blob:none --no-checkout <repo> farkha
> cd farkha && git sparse-checkout init --cone && git sparse-checkout set front_end/farkha_web && git checkout main
> ```

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
  server_name nims-farkha.com;

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
certbot --nginx -d nims-farkha.com
```

**7) CI/CD — GitHub Actions (مع path filter للـ monorepo):**

```yaml
# .github/workflows/deploy-web.yml
on:
  push:
    branches: [main]
    paths:
      - 'front_end/farkha_web/**'   # ينطلق فقط عند تغيير ملفات الـ web
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Deploy via SSH
        uses: appleboy/ssh-action@v1.0.0
        with:
          host: ${{ secrets.VPS_HOST }}
          username: ${{ secrets.VPS_USER }}
          key: ${{ secrets.VPS_SSH_KEY }}
          script: |
            cd /var/www/farkha
            git pull origin main
            cd front_end/farkha_web
            bun install
            bun run build
            pm2 restart farkha-web
```

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

# 5) PDF/Excel (jsPDF + html2canvas للـ PDF عربي/RTL)
bun add jspdf html2canvas xlsx

# 5.1) PWA (Service Worker + caching)
bun add @ducanh2912/next-pwa
# أو بديل: bun add next-pwa
# أو manual via workbox-window

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

## 15) ✅ Acceptance Criteria — معايير القبول

### 15.1 الطابع البصري (Visual Identity)
- [ ] كل اللوحة (palette) متطابقة مع `farkha_app/lib/core/constant/theme/colors.dart` 1:1
- [ ] خط Cairo بـ 6 أوزان محمّلة من `next/font/google`
- [ ] Typography scale نفس قيم `theme.dart` (font-size + weight + line-height)
- [ ] Spacing/radius/elevation tokens نفس Flutter
- [ ] Light theme + Dark theme متطابقين مع التطبيق
- [ ] Logo + tool icons (24 SVG) منقولة من `farkha_app/assets/`
- [ ] 4 Lottie animations منقولة وتعمل (loading/error/no_data/offline)
- [ ] 3 onboarding SVGs منقولة (cycle/prices/tools)

### 15.2 Responsive
- [ ] التطبيق يشتغل بدون scroll أفقي على 320px
- [ ] Mobile (< md): layout عمود واحد، Drawer منزلق، Bottom Sheets
- [ ] Tablet (md-lg): grids 2 columns، Drawer منزلق
- [ ] Desktop (≥ lg): Sidebar ثابت + grids 3-4-6-8 columns + Dialogs بدل Bottom Sheets
- [ ] Charts responsive (Recharts ResponsiveContainer)
- [ ] Tools grid يتدرج: 2 → 3 → 4 → 6 → 8 columns
- [ ] Cycle Tabs: أفقي على mobile، vertical في sidebar على desktop
- [ ] Touch targets ≥ 44px على mobile

### 15.3 الميزات الكاملة
- [ ] كل الـ 24 أداة منفذة بنفس الـ toolId + related articles
- [ ] كل شاشات Cycle (11 شاشة) منفذة
- [ ] Auth: Login (**Google + Apple + Phone**) + Verify + OTP — كلهم في v1
- [ ] Prices (4 شاشات) + Price chart
- [ ] Articles (list + detail بـ Markdown)
- [ ] Diseases (list + detail + Diagnosis Q&A)
- [ ] Drawer كامل (header + about + settings + support)
- [ ] PDF (jsPDF+html2canvas) / Excel (xlsx) / Share من Closeout Report
- [ ] FCM Web Push + Service Worker
- [ ] Dark/Light toggle
- [ ] App Review Dialog + Cycle Feedback Dialog
- [ ] Usage Tips + Permissions Intro dialogs
- [ ] Internet Checker indicator
- [ ] **PWA كامل** — manifest + SW + install prompt + offline page
- [ ] **AdSense** — banner + in-article + interstitial gate + sidebar

### 15.5 PWA & AdSense
- [ ] Lighthouse PWA score ≥ 90
- [ ] الموقع قابل للتثبيت على Chrome (Android + Desktop)
- [ ] iOS: tooltip "أضف للشاشة الرئيسية" يظهر بشكل صحيح
- [ ] Offline fallback يعمل (Lottie offline.json)
- [ ] AdSense approved على النطاق
- [ ] لا إعلانات على Auth/Payment pages
- [ ] Cookie consent banner لـ EU users
- [ ] Ad Blocker → fallback graceful (الموقع يشتغل بدون gates)

### 15.4 الأداء والجودة
- [ ] Lighthouse Mobile ≥ 90 (Performance, A11y, SEO)
- [ ] Lighthouse Desktop ≥ 90
- [ ] First Contentful Paint < 1.5s على 3G
- [ ] Time to Interactive < 3s على Desktop
- [ ] Cumulative Layout Shift < 0.1
- [ ] لا scroll أفقي عرضي على أي شاشة

---

## 16) Firebase Web App — تعليمات Setup خطوة بخطوة

> **المشروع موجود بالفعل في Firebase Console** مع Android + iOS apps. هنضيف **Web app** بجانبهم في نفس المشروع.

### 16.1 إضافة Web App في Firebase Console

1. افتح [Firebase Console](https://console.firebase.google.com/) واختر مشروع `farkha`
2. **Project Settings (⚙️)** → tab **General**
3. انزل لـ "Your apps" واضغط **Add app** → اختر أيقونة **Web** (`</>`)
4. **Register app:**
   - App nickname: `Farkha Web`
   - ✅ علّم على **"Also set up Firebase Hosting"** — اختياري (هنستخدم VPS، فممكن نتركها)
5. **Register app** → Firebase هيدّيك كود الـ `firebaseConfig`:
   ```js
   const firebaseConfig = {
     apiKey: "AIza...",
     authDomain: "farkha-xxxxx.firebaseapp.com",
     projectId: "farkha-xxxxx",
     storageBucket: "farkha-xxxxx.appspot.com",
     messagingSenderId: "123456789012",
     appId: "1:123456789012:web:abcdef0123456789"
   };
   ```
6. **انسخ القيم** دي → هتدخلها في `.env.local`:
   ```env
   NEXT_PUBLIC_FIREBASE_API_KEY=AIza...
   NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN=farkha-xxxxx.firebaseapp.com
   NEXT_PUBLIC_FIREBASE_PROJECT_ID=farkha-xxxxx
   NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET=farkha-xxxxx.appspot.com
   NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID=123456789012
   NEXT_PUBLIC_FIREBASE_APP_ID=1:123456789012:web:abcdef0123456789
   ```

### 16.2 توليد VAPID Key (لـ FCM Web Push)

1. في Project Settings → tab **Cloud Messaging**
2. انزل لـ **Web configuration** → **Web Push certificates**
3. اضغط **Generate key pair**
4. انسخ الـ key وضيفه:
   ```env
   NEXT_PUBLIC_FIREBASE_VAPID_KEY=BNxx...long_key...
   ```

### 16.3 Authorized Domains لـ Authentication

1. Firebase Console → **Authentication** → tab **Settings**
2. انزل لـ **Authorized domains**
3. اضغط **Add domain** وضيف:
   - `nims-farkha.com`
   - `www.nims-farkha.com`
   - `localhost` (موجود by default للـ development)

> بدون ده Phone OTP + Google Sign-In + Apple Sign-In **مش هيشتغلوا** على الـ domain.

### 16.4 Google Sign-In (Web)

1. Firebase Console → Authentication → **Sign-in method**
2. اضغط على **Google** (المفروض مفعّل من Android/iOS)
3. تأكد إن **Web SDK configuration** ظاهر:
   - Web client ID (auto-generated)
   - Web client secret
4. في Google Cloud Console → APIs & Services → Credentials:
   - افتح الـ **Web client (auto created by Firebase)**
   - في **Authorized JavaScript origins** ضيف:
     - `https://nims-farkha.com`
     - `https://www.nims-farkha.com`
     - `http://localhost:3000` (للـ dev)
   - في **Authorized redirect URIs** ضيف:
     - `https://nims-farkha.com/__/auth/handler`
     - `https://farkha-xxxxx.firebaseapp.com/__/auth/handler`

### 16.5 Apple Sign-In (Web) — تعليمات تفصيلية

#### في Apple Developer Console:
1. [developer.apple.com](https://developer.apple.com/) → Certificates, Identifiers & Profiles
2. **Identifiers** → اضغط **+**
3. اختار **Services IDs** → Continue
4. املأ:
   - Description: `Farkha Web Sign In`
   - Identifier: `com.nims-farkha.web.signin` (مختلف عن iOS Bundle ID)
5. ✅ **Sign in with Apple** → اضغط **Configure**:
   - Primary App ID: اختار iOS app الموجود
   - Domains and Subdomains: `nims-farkha.com`, `www.nims-farkha.com`
   - Return URLs: `https://farkha-xxxxx.firebaseapp.com/__/auth/handler`
6. **Save** → **Continue** → **Register**

#### Private Key (.p8):
1. **Keys** → **+** (لو مفيش مفتاح بـ Sign in with Apple)
2. اسم: `Farkha Apple Sign In Key`
3. ✅ **Sign in with Apple** → Configure → اختار Primary App ID → Save
4. Continue → **Register**
5. **حمّل الـ .p8 file** (مرة واحدة بس — لا يمكن إعادة تحميلها)
6. سجّل الـ **Key ID** + **Team ID** (موجود أعلى يمين الـ developer console)

#### في Firebase Console:
1. Authentication → Sign-in method → **Apple**
2. ✅ Enable
3. **Services ID:** `com.nims-farkha.web.signin`
4. **Apple Team ID:** [من Apple Dev]
5. **Key ID:** [من Apple Dev]
6. **Private Key:** افتح ملف .p8 بمحرر نصوص وانسخ المحتوى كامل
7. **Save**

### 16.6 Phone Authentication (reCAPTCHA Web)

1. Firebase Console → Authentication → Sign-in method → **Phone** (المفروض مفعّل)
2. على Web، Firebase بيستخدم **invisible reCAPTCHA v2** تلقائياً
3. في Google Cloud Console → reCAPTCHA Enterprise (لو متفعّل):
   - تأكد إن `nims-farkha.com` مضاف للـ allowed domains

### 16.7 Service Worker لـ FCM Background Push

ملف `public/firebase-messaging-sw.js`:
```js
importScripts('https://www.gstatic.com/firebasejs/11.0.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/11.0.0/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: '...',
  authDomain: 'farkha-xxxxx.firebaseapp.com',
  projectId: 'farkha-xxxxx',
  messagingSenderId: '123456789012',
  appId: '1:123456789012:web:...'
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  const { title, body, icon } = payload.notification || {};
  self.registration.showNotification(title, {
    body,
    icon: icon || '/icons/pwa-192.png',
    dir: 'rtl',
    lang: 'ar',
  });
});
```

> ⚠️ الملف ده **لازم يكون في `/public`** عشان يخدم من root URL (`/firebase-messaging-sw.js`).
> ⚠️ القيم هنا hardcoded لأن Service Worker ما يقدرش يقرأ env vars.

### 16.8 Firebase Web SDK في الكود

`src/lib/firebase/config.ts`:
```ts
import { initializeApp, getApps } from "firebase/app";
import { getAuth } from "firebase/auth";
import { getMessaging, isSupported } from "firebase/messaging";
import { getRemoteConfig } from "firebase/remote-config";
import { getAnalytics } from "firebase/analytics";

const firebaseConfig = {
  apiKey: process.env.NEXT_PUBLIC_FIREBASE_API_KEY!,
  authDomain: process.env.NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN!,
  projectId: process.env.NEXT_PUBLIC_FIREBASE_PROJECT_ID!,
  storageBucket: process.env.NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET!,
  messagingSenderId: process.env.NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID!,
  appId: process.env.NEXT_PUBLIC_FIREBASE_APP_ID!,
};

export const app = getApps().length ? getApps()[0] : initializeApp(firebaseConfig);
export const auth = getAuth(app);

// Messaging يشتغل على client فقط
export const getMessagingInstance = async () => {
  if (typeof window === "undefined") return null;
  return (await isSupported()) ? getMessaging(app) : null;
};
```

### 16.9 Checklist للتأكد إن Firebase شغّال

- [ ] Web App مضاف في Firebase Console
- [ ] firebaseConfig مكتمل في `.env.local`
- [ ] VAPID key مولّد ومضاف
- [ ] `nims-farkha.com` + `localhost` في Authorized Domains
- [ ] Google Sign-In Web client OAuth IDs مضاف في Google Cloud
- [ ] Apple Service ID مضاف في Firebase Apple provider
- [ ] `public/firebase-messaging-sw.js` موجود
- [ ] لو ظهر error "auth/unauthorized-domain" → ضيف الـ domain للـ Authorized Domains

---

## 17) معلومات الدعم والروابط الخارجية (منقولة من `farkha_app`)

> **المصدر:** `farkha_app/lib/core/services/open_whatsapp.dart`, `open_gmail.dart`, `open_privacy_policy.dart`

| البند | القيمة | الاستخدام |
|------|--------|-----------|
| **WhatsApp** | `+20 150 099 8095` | `https://wa.me/201500998095` — زر "تواصل عبر واتساب" في Drawer |
| **Email** | `support@nims-farkha.com` | `mailto:support@nims-farkha.com` — زر "راسلنا" في Drawer |
| **Privacy Policy** | `https://www.nims-farkha.com/privacy-policy` | Drawer + Cookie Consent + footer |
| **Terms of Service** | `https://www.nims-farkha.com/terms` (يتأكد) | footer |
| **App Domain (Web)** | `https://nims-farkha.com` | الموقع نفسه |
| **API Domain** | `https://api.nims-farkha.com/backend_farkha` | كل API calls |

### 17.1 المثال في الكود

```tsx
// src/lib/constants/support.ts
export const SUPPORT = {
  whatsapp: 'https://wa.me/201500998095',
  email: 'support@nims-farkha.com',
  privacyPolicy: 'https://www.nims-farkha.com/privacy-policy',
  termsOfService: 'https://www.nims-farkha.com/terms',
} as const;

// استخدام في Drawer:
<a href={SUPPORT.whatsapp} target="_blank" rel="noopener">
  <WhatsAppIcon /> تواصل عبر واتساب
</a>

<a href={`mailto:${SUPPORT.email}`}>
  <MailIcon /> راسلنا بالبريد
</a>
```

---

## النهاية

هذه الخطة **شاملة + متجاوبة + بصرية**، مبنية بالكامل على ما هو موجود فعلياً في `farkha_app`:
- ✅ **كل ميزة** في التطبيق لها مقابلها في Web (موثقة في قسم 4 + 4.11)
- ✅ **كل token بصري** (لون، خط، spacing) منقول كما هو (قسم 8)
- ✅ **التصميم متجاوب فعلياً** Mobile-first مع desktop expansion (قسم 8.7)
- ✅ **Backend ثابت** — فقط نضمن CORS يسمح بـ domain الجديد

> **معيار النجاح النهائي:** لما تفتح التطبيق على موبايل والموقع على موبايل في نفس الوقت، الفرق الوحيد لازم يكون الـ URL bar.
