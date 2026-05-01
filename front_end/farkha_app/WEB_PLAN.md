# خطة موقع الويب لتطبيق فرخة

> قرار تقني: اختيار الـ stack المناسب لإطلاق نسخة ويب عامة قابلة للظهور في نتائج البحث.

---

## 1. المتطلبات

- موقع ويب **عام** (Public website) وليس Dashboard فقط.
- يظهر في **نتائج بحث جوجل** (SEO قوي).
- يحتوي على **نفس وظائف التطبيق** (إدارة المزارع، الأسعار، الأعضاء، المقالات).
- يدعم **اللغة العربية / RTL**.
- يستخدم **نفس الـ Backend** الموجود (`backend_farkha/` — PHP REST API).
- تكامل مع **Firebase** (Auth, Analytics, Remote Config).

---

## 2. لماذا لا نستخدم Flutter Web

رغم أن المشروع الحالي مبني بـ Flutter، إلا أن **Flutter Web غير مناسب** لهذه الحالة:

| المشكلة | التفسير |
|---------|----------|
| **SEO ضعيف جداً** | Flutter Web يرندر عبر Canvas/CanvasKit — جوجل يرى صفحة فارغة تقريباً. |
| **First Load بطيء** | حجم الـ Bundle ~2-3MB JavaScript قبل ظهور أي محتوى. |
| **لا يوجد SSR حقيقي** | Meta tags و Open Graph و Structured Data صعبة التطبيق. |
| **Social Sharing سيء** | لا يظهر Preview صحيح عند مشاركة الروابط (Facebook, WhatsApp). |
| **تجربة المستخدم على الموبايل** | بطيء مقارنة بمواقع HTML/CSS التقليدية. |

**الخلاصة:** Flutter Web مناسب لـ Dashboards الداخلية فقط، ليس لمواقع عامة تعتمد على البحث.

---

## 3. التوصية: Next.js

**Next.js 15 (App Router)** هو الخيار الأنسب.

### المزايا

| الميزة | الفائدة |
|--------|---------|
| **SSR / SSG** | الصفحات تُرندر على السيرفر → جوجل يقرأها مباشرة. |
| **SEO ممتاز** | دعم كامل لـ meta tags, sitemap.xml, robots.txt, JSON-LD. |
| **أداء عالي** | First Contentful Paint سريع جداً (Core Web Vitals). |
| **RTL Support** | دعم العربية ممتاز عبر Tailwind RTL أو CSS native. |
| **Firebase SDK** | SDK ويب رسمي لـ Auth / Analytics / Remote Config. |
| **Deployment مجاني** | Vercel أو Cloudflare Pages بدون تكلفة. |
| **Image Optimization** | تحسين تلقائي للصور (WebP, lazy loading). |
| **API Routes** | إمكانية إضافة endpoints جانبية بـ Node.js عند الحاجة. |

---

## 4. الـ Stack المقترح

```
Next.js 15 (App Router)
├── TypeScript                  — Type safety
├── Tailwind CSS + RTL plugin   — Styling
├── shadcn/ui أو Radix UI       — UI Components
├── Firebase Web SDK            — Auth, Analytics, Remote Config
├── TanStack Query              — Data fetching & caching
├── Zod                         — Schema validation
└── next-intl                   — Localization (ar/en)
```

**الـ Backend:** يبقى كما هو — `backend_farkha/` (PHP REST API) يخدم التطبيق والموقع معاً.

---

## 5. هيكل المشروع المقترح

```
farkha/
├── front_end/
│   ├── farkha_app/        — تطبيق Flutter (موجود)
│   ├── farkha_admin/      — لوحة Admin (موجود)
│   └── farkha_web/        — ⭐ موقع Next.js (جديد)
│       ├── app/
│       │   ├── (public)/                  — صفحات عامة (SEO)
│       │   │   ├── page.tsx               — الرئيسية
│       │   │   ├── prices/                — أسعار الدواجن
│       │   │   ├── articles/[slug]/       — مقالات إرشادية
│       │   │   └── about/                 — عن التطبيق
│       │   ├── (auth)/                    — تسجيل دخول/إنشاء حساب
│       │   └── dashboard/                 — وظائف التطبيق (محمية)
│       │       ├── cycles/
│       │       ├── members/
│       │       └── settings/
│       ├── components/
│       ├── lib/
│       │   ├── api.ts                     — wrapper للـ PHP API
│       │   └── firebase.ts                — Firebase client
│       └── public/
└── backend_farkha/        — PHP API (موجود — لا يتغير)
```

---

## 6. صفحات SEO الأساسية

الصفحات التي ستجلب Traffic من جوجل:

| الصفحة | كلمات البحث المستهدفة |
|--------|----------------------|
| `/prices` | "أسعار الكتاكيت اليوم"، "أسعار الدواجن مصر" |
| `/articles/[slug]` | "كيف أربي دجاج"، "أمراض الدواجن"، "تربية الفراخ البياض" |
| `/calculators/feed` | "حاسبة علف الدواجن" |
| `/guides/[slug]` | "دليل تربية الدواجن للمبتدئين" |
| `/` | "تطبيق إدارة مزارع الدواجن" |

---

## 7. خطة التنفيذ المرحلية

### المرحلة 1: الأساس (1-2 أسبوع)
- إنشاء مشروع `farkha_web/` بـ Next.js 15.
- إعداد Tailwind + RTL + Cairo font.
- ربط Firebase Web SDK.
- إنشاء API wrapper للـ PHP backend.

### المرحلة 2: صفحات SEO (2-3 أسابيع)
- الصفحة الرئيسية + Landing.
- صفحة الأسعار (محتوى ديناميكي من API).
- نظام المقالات (CMS بسيط أو من قاعدة البيانات).
- Sitemap + robots.txt + JSON-LD.

### المرحلة 3: Dashboard (3-4 أسابيع)
- تسجيل دخول (Firebase Auth + Google).
- إدارة الدورات (Cycles).
- الأعضاء والصلاحيات.
- التقارير.

### المرحلة 4: التحسين (مستمر)
- Core Web Vitals optimization.
- Google Search Console + Analytics.
- A/B testing للـ landing pages.

---

## 8. البدائل المرفوضة

| البديل | لماذا رُفض |
|--------|-----------|
| **Flutter Web** | SEO ضعيف، لا يحقق الهدف الأساسي. |
| **Hybrid (Flutter + Next.js)** | تعقيد إضافي بدون فائدة — Next.js وحده كافي. |
| **Vue / Nuxt** | بديل ممتاز، لكن React أوسع انتشاراً ومجتمعه أكبر. |
| **Static HTML** | لا يدعم Dashboard ديناميكي. |
| **WordPress** | غير مرن للوظائف المخصصة. |

---

## 9. الخطوة التالية

- [ ] الموافقة على الـ Stack.
- [ ] إنشاء مجلد `front_end/farkha_web/` وبدء setup Next.js.
- [ ] تجهيز Firebase Web App في Firebase Console.
- [ ] التأكد من أن الـ PHP API يدعم CORS للموقع الجديد.
- [ ] تصميم UI/UX للصفحات العامة.

---

**تاريخ الإعداد:** 2026-05-01
