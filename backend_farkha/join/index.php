<?php
/**
 * صفحة إعادة توجيه لفتح التطبيق عبر رابط الدعوة
 * Redirect page to open app via invitation link
 * URL: /backend_farkha/join/?code=XXXXXX
 */

$code = $_GET['code'] ?? '';
$appScheme = "farkha://join/$code";
$playStoreUrl = "https://play.google.com/store/apps/details?id=ni.nims.frkha";
?>
<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>فرخة - انضمام للدورة</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Segoe UI', Tahoma, sans-serif;
            background: linear-gradient(135deg, #1a5e2a 0%, #2d8a4e 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
        }
        .container {
            text-align: center;
            padding: 40px 20px;
            max-width: 400px;
        }
        .icon { font-size: 80px; margin-bottom: 20px; }
        h1 { font-size: 28px; margin-bottom: 10px; }
        p { font-size: 16px; opacity: 0.9; margin-bottom: 30px; }
        .btn {
            display: inline-block;
            background: white;
            color: #1a5e2a;
            padding: 14px 40px;
            border-radius: 30px;
            text-decoration: none;
            font-size: 18px;
            font-weight: bold;
            margin: 10px;
            transition: transform 0.2s;
        }
        .btn:hover { transform: scale(1.05); }
        .btn-store {
            background: transparent;
            border: 2px solid white;
            color: white;
        }
        .code-box {
            background: rgba(255,255,255,0.15);
            padding: 15px;
            border-radius: 10px;
            margin: 20px 0;
            font-size: 24px;
            letter-spacing: 4px;
            font-weight: bold;
        }
        .loading { display: none; margin-top: 20px; font-size: 14px; opacity: 0.7; }
    </style>
</head>
<body>
    <div class="container">
        <div class="icon">🐔</div>
        <h1>تطبيق فرخة</h1>
        <p>تمت دعوتك للانضمام إلى دورة</p>

        <?php if ($code): ?>
            <div class="code-box"><?php echo htmlspecialchars($code); ?></div>
            <a href="<?php echo $appScheme; ?>" class="btn" id="openApp">فتح التطبيق</a>
            <br>
            <a href="<?php echo $playStoreUrl; ?>" class="btn btn-store">تحميل التطبيق</a>
            <p class="loading" id="loading">جاري فتح التطبيق...</p>
        <?php else: ?>
            <p>كود الدعوة غير موجود</p>
            <a href="<?php echo $playStoreUrl; ?>" class="btn">تحميل التطبيق</a>
        <?php endif; ?>
    </div>

    <script>
        document.getElementById('openApp')?.addEventListener('click', function(e) {
            document.getElementById('loading').style.display = 'block';
            // If app doesn't open in 2 seconds, stay on page
            setTimeout(function() {
                document.getElementById('loading').style.display = 'none';
            }, 2500);
        });

        // Auto-try to open app on page load
        <?php if ($code): ?>
        setTimeout(function() {
            window.location.href = <?php echo json_encode($appScheme); ?>;
        }, 500);
        <?php endif; ?>
    </script>
</body>
</html>
