# Impeccable — مرجع الأوامر الكامل

> مكتبة مهارات ديزاين لـ Claude Code وأدوات الـ AI  
> المصدر: https://impeccable.style | التثبيت: `npx skills add pbakaus/impeccable`

---

## ⚡ أول خطوة — Setup المشروع

```
/impeccable teach
```

شغّله **مرة واحدة** في مجلد مشروعك.  
بيسأل Claude عن المشروع ويحفظ السياق في `.impeccable.md`  
كل الأوامر التانية بتستفيد منه تلقائياً.

---

## 🏗️ Create — بناء من الصفر

| الأمر | الوصف |
|---|---|
| `/impeccable` | الـ skill الأساسية — بتعلّم الـ AI مبادئ الديزاين الحقيقي |
| `/impeccable craft` | interview + brief + implementation كامل دفعة واحدة |
| `/impeccable teach` | setup سياق المشروع (شغّله مرة واحدة) |
| `/impeccable extract` | استخراج design tokens من الكود الحالي |
| `/shape` | interview منظّم عن الـ purpose والـ audience وينتج design brief قبل أي كود |

**متى تستخدمها؟**  
لما تبدأ مشروع جديد أو فيتشر جديد من صفحة بيضاء.

---

## 🔍 Evaluate — تقييم ومراجعة

| الأمر | الوصف |
|---|---|
| `/audit` | مراجعة شاملة — بيدي scores على 5 أبعاد مع تقييم P0-P3 وخطة عمل |
| `/critique` | نقد متعمق — personas متعددة بتراجع بالتوازي + Nielsen's 10 heuristics + overlay مرئي |

**متى تستخدمها؟**  
لما عندك شاشة موجودة وعايز تعرف إيه المشاكل وأولوياتها.

**الفرق بينهم:**
- `/audit` → أرقام وأولويات وخطة عمل
- `/critique` → تحليل UX عميق بمنظور مستخدمين مختلفين

---

## ✨ Refine — تحسين بُعد واحد في كل مرة

| الأمر | الوصف |
|---|---|
| `/typeset` | إصلاح الـ typography — scale ثابت للـ apps، fluid للـ marketing |
| `/colorize` | تحسين نظام الألوان وضمان الـ contrast |
| `/layout` | إصلاح المسافات والترتيب والـ grid |
| `/animate` | إضافة animations وmicro-interactions |
| `/bolder` | جعل الديزاين أكثر جرأة وشخصية وتميزاً |
| `/quieter` | تهدئة الديزاين وتقليل الضوضاء البصرية |
| `/delight` | إضافة لمسات بهجة وتجربة مميزة |
| `/overdrive` | effects استثنائية ومذهلة (تجريبي 🧪) |

**متى تستخدمها؟**  
لما عارف بالضبط إيه البُعد اللي محتاج تحسينه.

---

## 🗜️ Simplify — تبسيط وتقليل

| الأمر | الوصف |
|---|---|
| `/distill` | تبسيط وإزالة الزوائد — كل عنصر لازم يكون له سبب |
| `/clarify` | توضيح الـ UX وتسهيل الفهم على المستخدم |
| `/adapt` | تكييف الديزاين لأحجام شاشات مختلفة (responsive) |

**متى تستخدمها؟**  
لما الشاشة مزدحمة أو مربكة أو مش شغّالة على الموبايل.

---

## 🔧 Harden — جاهزية للـ Production

| الأمر | الوصف |
|---|---|
| `/polish` | تلميع شامل نهائي — last-mile pass قبل الشحن |
| `/harden` | تجهيز للـ production: empty states، error states، first-run experience |
| `/optimize` | تحسين الأداء والسرعة |

**متى تستخدمها؟**  
آخر خطوة قبل ما تشحن الفيتشر.

---

## 🗺️ Workflow عملي مقترح

### لفيتشر جديد:
```
1. /shape              ← فهم المتطلبات وعمل brief
2. /impeccable craft   ← تنفيذ كامل بناءً على الـ brief
3. /critique           ← مراجعة النتيجة
4. /polish             ← تلميع نهائي
```

### لشاشة موجودة:
```
1. /audit              ← اعرف إيه المشاكل وأولوياتها
2. /typeset            ← ابدأ بالـ typography
3. /layout             ← ثم الـ spacing والترتيب
4. /colorize           ← ثم الألوان
5. /polish             ← تلميع نهائي
```

### لو مش عارف تبدأ منين:
```
/audit [اسم الملف]     ← هيقولك بالضبط إيه الأولوية
```

---

## ⚠️ الـ Anti-Patterns اللي Impeccable بيتجنبها

دي أكتر الأخطاء اللي الـ AI بيقع فيها تلقائياً:

- 🟣 **Purple Gradients** — gradient بنفسجي على خلفية بيضاء
- 🃏 **Cardocalypse** — cards جوا cards جوا cards
- 📦 **Side-Tab Cards** — كروت بـ border سميك على الجانب
- 🔤 **Inter Everywhere** — Inter على كل حاجة
- 📐 **Template Layouts** — نفس الـ hero section في كل موقع
- 👁️ **Bad Contrast** — نص منخفض الـ contrast

---

## 🔄 تحديث الـ Skills

```bash
npx impeccable skills update
```

---

## 🔗 روابط مفيدة

- الموقع: https://impeccable.style
- الـ Cheatsheet: https://impeccable.style/cheatsheet
- الـ Anti-Patterns: https://impeccable.style/anti-patterns
- GitHub: https://github.com/pbakaus/impeccable
- Chrome Extension: للكشف عن الـ anti-patterns في أي موقع
