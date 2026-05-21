import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "طلب حذف الحساب",
  description: "كيفية حذف حسابك في تطبيق فرخة وأنواع البيانات التي يتم حذفها.",
};

export default function DeleteAccountRequestPage() {
  return (
    <div className="mx-auto max-w-3xl px-4 py-8 leading-loose">
      <h1 className="mb-2 text-headline-md text-primary">طلب حذف الحساب</h1>
      <p className="mb-8 text-title-lg font-bold text-primary">تطبيق فرخة</p>

      <section className="mb-6 rounded-2xl border-r-4 border-primary bg-muted/40 p-5">
        <h2 className="mb-3 text-title-lg font-bold text-primary">
          📱 معلومات التطبيق
        </h2>
        <p>
          <strong>اسم التطبيق:</strong> فرخة
        </p>
        <p>
          <strong>المطور:</strong> NiMs
        </p>
      </section>

      <section className="mb-6 rounded-2xl border-r-4 border-primary bg-muted/40 p-5">
        <h2 className="mb-3 text-title-lg font-bold text-primary">
          📋 الخطوات المطلوبة لحذف حسابك
        </h2>
        <ol className="mr-6 list-decimal space-y-2">
          <li>
            <strong>افتح تطبيق فرخة</strong> على جهازك
          </li>
          <li>
            <strong>انتقل إلى إعدادات الحساب</strong> (Settings / الإعدادات)
          </li>
          <li>
            <strong>اختر &ldquo;حذف الحساب&rdquo;</strong> (Delete Account / حذف
            الحساب)
          </li>
          <li>
            <strong>أكد رغبتك في الحذف</strong> من خلال الضغط علي حذف
          </li>
          <li>
            <strong>سيتم حذف حسابك فوراً</strong> من Firebase Authentication
            وقاعدة البيانات
          </li>
        </ol>
        <div className="mt-4 rounded-lg bg-yellow-100 p-4 text-yellow-900 dark:bg-yellow-900/30 dark:text-yellow-200">
          <strong>⚠️ تحذير:</strong> عملية الحذف نهائية ولا يمكن التراجع عنها.
          سيتم حذف جميع بياناتك المرتبطة بالحساب بشكل دائم.
        </div>
      </section>

      <section className="mb-6 rounded-2xl border-r-4 border-primary bg-muted/40 p-5">
        <h2 className="mb-3 text-title-lg font-bold text-primary">
          🗑️ أنواع البيانات التي يتم حذفها
        </h2>
        <ul className="mr-6 list-disc space-y-2">
          <li>
            <strong>معلومات الحساب:</strong> معرف Firebase (Firebase UID)،
            الاسم
          </li>
          <li>
            <strong>رقم الهاتف:</strong> إذا كان مسجلاً في حسابك، سيتم حذفه من
            قاعدة البيانات
          </li>
          <li>
            <strong>بيانات المستخدم:</strong> جميع البيانات المخزنة في قاعدة
            البيانات المرتبطة بحسابك (الاسم، رقم الهاتف)
          </li>
          <li>
            <strong>بيانات Firebase Authentication:</strong> حساب المصادقة من
            Firebase (البريد الإلكتروني، بيانات تسجيل الدخول)
          </li>
          <li>
            <strong>جلسات الدخول:</strong> جميع جلسات تسجيل الدخول النشطة
          </li>
          <li>
            <strong>التفضيلات المحلية:</strong> البيانات المحفوظة محلياً على
            جهازك (الاسم، رقم الهاتف، حالة تسجيل الدخول، إعدادات التطبيق)
          </li>
        </ul>
      </section>

      <section className="mb-6 rounded-2xl border-r-4 border-primary bg-muted/40 p-5">
        <h2 className="mb-3 text-title-lg font-bold text-primary">
          💾 البيانات التي يتم الاحتفاظ بها
        </h2>
        <p className="mb-3">
          نحن لا نحتفظ بأي بيانات بعد حذف الحساب. جميع البيانات المرتبطة بحسابك
          يتم حذفها فوراً من:
        </p>
        <ul className="mr-6 list-disc space-y-2">
          <li>
            <strong>Firebase Authentication:</strong> حساب المصادقة بالكامل
          </li>
          <li>
            <strong>قاعدة البيانات (MySQL):</strong> جميع البيانات الشخصية
            (الاسم، رقم الهاتف، معرف Firebase)
          </li>
          <li>
            <strong>الجهاز المحلي:</strong> البيانات المحفوظة محلياً على جهازك
            (عند حذف التطبيق)
          </li>
        </ul>
        <p className="mt-3">
          <strong>ملاحظة:</strong> قد يتم الاحتفاظ ببيانات غير شخصية من Firebase
          Analytics و Crashlytics وفقاً لسياسات Firebase، ولكن لا يمكن ربطها
          بهويتك الشخصية بعد حذف الحساب.
        </p>
      </section>

      <section className="mb-6 rounded-2xl border-r-4 border-primary bg-muted/40 p-5">
        <h2 className="mb-3 text-title-lg font-bold text-primary">
          ⏱️ فترة الاحتفاظ بالبيانات
        </h2>
        <div className="rounded-lg bg-sky-100 p-4 text-sky-900 dark:bg-sky-900/30 dark:text-sky-200">
          <strong>مدة الاحتفاظ:</strong> <strong>0 أيام</strong>
          <br />
          يتم حذف جميع البيانات الشخصية <strong>فوراً</strong> عند طلب حذف
          الحساب. لا توجد فترة احتفاظ إضافية للبيانات الشخصية.
        </div>
      </section>

      <section className="mb-6 rounded-2xl border-r-4 border-primary bg-muted/40 p-5">
        <h2 className="mb-3 text-title-lg font-bold text-primary">
          📧 التواصل معنا
        </h2>
        <div className="rounded-lg bg-green-100 p-4 text-green-900 dark:bg-green-900/30 dark:text-green-200">
          <strong>
            إذا واجهت أي مشكلة في حذف حسابك أو لديك استفسارات حول سياسة الخصوصية
            أو رغبتك في ممارسة حقوقك المتعلقة ببياناتك:
          </strong>
          <br />
          <br />
          يمكنك التواصل معنا عبر البريد الإلكتروني:
          <br />
          <strong>support@nims-farkha.com</strong>
        </div>
      </section>

      <section className="mb-6 rounded-2xl border-r-4 border-primary bg-muted/40 p-5">
        <h2 className="mb-3 text-title-lg font-bold text-primary">
          ✅ بعد حذف الحساب
        </h2>
        <p className="mb-3">بعد حذف حسابك بنجاح:</p>
        <ul className="mr-6 list-disc space-y-1">
          <li>سيتم إلغاء جميع الجلسات النشطة</li>
          <li>سيتم حذف جميع بياناتك الشخصية (الاسم، رقم الهاتف) من خوادمنا</li>
          <li>سيتم حذف حسابك من Firebase Authentication</li>
          <li>يمكنك إنشاء حساب جديد في أي وقت</li>
        </ul>
      </section>
    </div>
  );
}
