<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>طلب حذف الحساب - تطبيق فرخة</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        body {
            font-family: 'Cairo', 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #f7f7f7;
            padding: 20px;
            min-height: 100vh;
        }
        .container {
            max-width: 900px;
            margin: 0 auto;
            background: white;
            border-radius: 12px;
            padding: 40px;
            box-shadow: 0 0 10px rgba(0,0,0,0.1);
        }
        h1 {
            color: #2A4D69;
            margin-bottom: 10px;
            font-size: 2em;
        }
        .app-name {
            color: #2A4D69;
            font-size: 1.5em;
            margin-bottom: 30px;
            font-weight: bold;
        }
        .section {
            margin-bottom: 30px;
            padding: 20px;
            background: #f8f9fa;
            border-radius: 10px;
            border-right: 4px solid #2A4D69;
        }
        .section h2 {
            color: #2A4D69;
            margin-bottom: 15px;
            font-size: 1.3em;
        }
        .section ol, .section ul {
            margin-right: 20px;
            line-height: 2;
        }
        .section li {
            margin-bottom: 10px;
            color: #555;
        }
        .warning {
            background: #fff3cd;
            border-right-color: #ffc107;
            padding: 15px;
            border-radius: 5px;
            margin-top: 15px;
        }
        .warning strong {
            color: #856404;
        }
        .data-list {
            list-style: none;
        }
        .data-list li:before {
            content: "🗑️ ";
            margin-left: 10px;
        }
        .retention {
            background: #d1ecf1;
            border-right-color: #0c5460;
            padding: 15px;
            border-radius: 5px;
            margin-top: 15px;
        }
        .retention strong {
            color: #0c5460;
        }
        .contact {
            background: #d4edda;
            border-right-color: #28a745;
            padding: 15px;
            border-radius: 5px;
            margin-top: 15px;
        }
        .contact strong {
            color: #155724;
        }
        p {
            line-height: 1.8;
            color: #555;
            margin-bottom: 10px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>طلب حذف الحساب</h1>
        <div class="app-name">تطبيق فرخة</div>
        
        <div class="section">
            <h2>📱 معلومات التطبيق</h2>
                <p><strong>اسم التطبيق:</strong> فرخة </p>
            <p><strong>المطور:</strong> NiMs </p>
        </div>

        <div class="section">
            <h2>📋 الخطوات المطلوبة لحذف حسابك</h2>
            <ol>
                <li><strong>افتح تطبيق فرخة</strong> على جهازك</li>
                <li><strong>انتقل إلى إعدادات الحساب</strong> (Settings / الإعدادات)</li>
                <li><strong>اختر "حذف الحساب"</strong> (Delete Account / حذف الحساب)</li>
                <li><strong>أكد رغبتك في الحذف</strong> من خلال الضغط علي حذف</li>
                <li><strong>سيتم حذف حسابك فوراً</strong> من Firebase Authentication وقاعدة البيانات</li>
            </ol>
            
            <div class="warning">
                <strong>⚠️ تحذير:</strong> عملية الحذف نهائية ولا يمكن التراجع عنها. سيتم حذف جميع بياناتك المرتبطة بالحساب بشكل دائم.
            </div>
        </div>

        <div class="section">
            <h2>🗑️ أنواع البيانات التي يتم حذفها</h2>
            <ul class="data-list">
                <li><strong>معلومات الحساب:</strong> معرف Firebase (Firebase UID)، الاسم</li>
                <li><strong>رقم الهاتف:</strong> إذا كان مسجلاً في حسابك، سيتم حذفه من قاعدة البيانات</li>
                <li><strong>بيانات المستخدم:</strong> جميع البيانات المخزنة في قاعدة البيانات المرتبطة بحسابك (الاسم، رقم الهاتف)</li>
                <li><strong>بيانات Firebase Authentication:</strong> حساب المصادقة من Firebase (البريد الإلكتروني، بيانات تسجيل الدخول)</li>
                <li><strong>جلسات الدخول:</strong> جميع جلسات تسجيل الدخول النشطة</li>
                <li><strong>التفضيلات المحلية:</strong> البيانات المحفوظة محلياً على جهازك (الاسم، رقم الهاتف، حالة تسجيل الدخول، إعدادات التطبيق)</li>
            </ul>
        </div>

        <div class="section">
            <h2>💾 البيانات التي يتم الاحتفاظ بها</h2>
            <p>نحن لا نحتفظ بأي بيانات بعد حذف الحساب. جميع البيانات المرتبطة بحسابك يتم حذفها فوراً من:</p>
            <ul>
                <li><strong>Firebase Authentication:</strong> حساب المصادقة بالكامل</li>
                <li><strong>قاعدة البيانات (MySQL):</strong> جميع البيانات الشخصية (الاسم، رقم الهاتف، معرف Firebase)</li>
                <li><strong>الجهاز المحلي:</strong> البيانات المحفوظة محلياً على جهازك (عند حذف التطبيق)</li>
            </ul>
            <p><strong>ملاحظة:</strong> قد يتم الاحتفاظ ببيانات غير شخصية من Firebase Analytics و Crashlytics وفقاً لسياسات Firebase، ولكن لا يمكن ربطها بهويتك الشخصية بعد حذف الحساب.</p>
        </div>

        <div class="section">
            <h2>⏱️ فترة الاحتفاظ بالبيانات</h2>
            <div class="retention">
                <strong>مدة الاحتفاظ:</strong> <strong>0 أيام</strong><br>
                يتم حذف جميع البيانات الشخصية <strong>فوراً</strong> عند طلب حذف الحساب. لا توجد فترة احتفاظ إضافية للبيانات الشخصية.
            </div>
        </div>

        <div class="section">
            <h2>📧 التواصل معنا</h2>
            <div class="contact">
                <strong>إذا واجهت أي مشكلة في حذف حسابك أو لديك استفسارات حول سياسة الخصوصية أو رغبتك في ممارسة حقوقك المتعلقة ببياناتك:</strong><br><br>
                يمكنك التواصل معنا عبر البريد الإلكتروني:<br>
                <strong>support@nims-farkha.com</strong>
            </div>
        </div>

        <div class="section">
            <h2>✅ بعد حذف الحساب</h2>
            <p>بعد حذف حسابك بنجاح:</p>
            <ul>
                <li>سيتم إلغاء جميع الجلسات النشطة</li>
                <li>سيتم حذف جميع بياناتك الشخصية (الاسم، رقم الهاتف) من خوادمنا</li>
                <li>سيتم حذف حسابك من Firebase Authentication</li>
                <li>يمكنك إنشاء حساب جديد في أي وقت</li>
            </ul>
        </div>
    </div>
</body>
</html>