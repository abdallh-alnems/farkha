-- ============================================================
-- بيانات تجريبية لدورة "مرحبا"  (نسخة محصّنة — لا تعتمد على متغيّرات الجلسة)
-- شغّل الملف كاملاً دفعة واحدة في phpMyAdmin (قاعدة u869543217_farkha).
-- التواريخ تُحسب مباشرة من start_date_raw داخل كل جملة، فتعمل بشكل صحيح
-- مهما نُفِّذت (لا مشكلة "نفس اليوم").
-- ============================================================
USE `u869543217_farkha`;

-- (1) تحقّق: تأكد أن هذه هي الدورة الصحيحة قبل المتابعة
SELECT id, name, owner_user_id, chick_count, start_date_raw
FROM cycles WHERE name = 'مرحبا' ORDER BY id DESC LIMIT 1;

-- (2) تنظيف الصفوف الخاطئة المؤرّخة باليوم (الناتجة عن التشغيل السابق) لهذه الدورة فقط
DELETE FROM cycle_data
 WHERE cycle_id = (SELECT MAX(id) FROM cycles WHERE name = 'مرحبا')
   AND DATE(entry_date) = CURDATE();
DELETE FROM cycle_expenses
 WHERE cycle_id = (SELECT MAX(id) FROM cycles WHERE name = 'مرحبا')
   AND DATE(entry_date) = CURDATE();
DELETE FROM cycle_inventory
 WHERE cycle_id = (SELECT MAX(id) FROM cycles WHERE name = 'مرحبا')
   AND DATE(entry_date) = CURDATE();
DELETE FROM cycle_notes
 WHERE cycle_id = (SELECT MAX(id) FROM cycles WHERE name = 'مرحبا')
   AND DATE(entry_date) = CURDATE();
DELETE FROM cycle_sales
 WHERE cycle_id = (SELECT MAX(id) FROM cycles WHERE name = 'مرحبا')
   AND sale_date >= CURDATE();

-- ============================================================
-- البيانات (cycle_data) — التواريخ = start_date_raw + إزاحة بالأيام
-- ============================================================
INSERT INTO cycle_data (cycle_id, metric_type, numeric_value, text_value, entry_date)
SELECT c.id, v.metric_type, v.numeric_value, v.text_value,
       DATE_ADD(c.start_date_raw, INTERVAL v.d DAY)
FROM cycles c
JOIN (
            SELECT 'weight'      AS metric_type, CAST(42.00 AS DECIMAL(10,2)) AS numeric_value, CAST(NULL AS CHAR) AS text_value, 0  AS d
  UNION ALL SELECT 'weight',      160.00,  NULL, 5
  UNION ALL SELECT 'weight',      400.00,  NULL, 10
  UNION ALL SELECT 'weight',      720.00,  NULL, 15
  UNION ALL SELECT 'weight',      1100.00, NULL, 20
  UNION ALL SELECT 'weight',      1550.00, NULL, 25
  UNION ALL SELECT 'weight',      1950.00, NULL, 30
  UNION ALL SELECT 'mortality',   8.00,    NULL, 1
  UNION ALL SELECT 'mortality',   5.00,    NULL, 3
  UNION ALL SELECT 'mortality',   4.00,    NULL, 7
  UNION ALL SELECT 'mortality',   3.00,    NULL, 14
  UNION ALL SELECT 'mortality',   2.00,    NULL, 21
  UNION ALL SELECT 'mortality',   2.00,    NULL, 28
  UNION ALL SELECT 'feed',        150.00,  NULL, 5
  UNION ALL SELECT 'feed',        300.00,  NULL, 10
  UNION ALL SELECT 'feed',        480.00,  NULL, 15
  UNION ALL SELECT 'feed',        650.00,  NULL, 20
  UNION ALL SELECT 'feed',        820.00,  NULL, 25
  UNION ALL SELECT 'feed',        980.00,  NULL, 30
  UNION ALL SELECT 'water',       80.00,   NULL, 0
  UNION ALL SELECT 'water',       180.00,  NULL, 5
  UNION ALL SELECT 'water',       300.00,  NULL, 10
  UNION ALL SELECT 'water',       420.00,  NULL, 15
  UNION ALL SELECT 'water',       540.00,  NULL, 20
  UNION ALL SELECT 'water',       650.00,  NULL, 25
  UNION ALL SELECT 'water',       760.00,  NULL, 30
  UNION ALL SELECT 'temperature', 33.00,   NULL, 0
  UNION ALL SELECT 'temperature', 31.00,   NULL, 5
  UNION ALL SELECT 'temperature', 29.00,   NULL, 10
  UNION ALL SELECT 'temperature', 27.00,   NULL, 15
  UNION ALL SELECT 'temperature', 25.00,   NULL, 20
  UNION ALL SELECT 'temperature', 23.00,   NULL, 25
  UNION ALL SELECT 'temperature', 22.00,   NULL, 30
  UNION ALL SELECT 'humidity',    65.00,   NULL, 0
  UNION ALL SELECT 'humidity',    63.00,   NULL, 5
  UNION ALL SELECT 'humidity',    62.00,   NULL, 10
  UNION ALL SELECT 'humidity',    60.00,   NULL, 15
  UNION ALL SELECT 'humidity',    60.00,   NULL, 20
  UNION ALL SELECT 'humidity',    58.00,   NULL, 25
  UNION ALL SELECT 'humidity',    57.00,   NULL, 30
  UNION ALL SELECT 'vaccination', NULL, 'نيوكاسل (لاسوتا) - تقطير بالعين', 7
  UNION ALL SELECT 'vaccination', NULL, 'جامبورو - في ماء الشرب',          14
  UNION ALL SELECT 'vaccination', NULL, 'نيوكاسل تنشيطية',                 18
  UNION ALL SELECT 'medicine',    NULL, 'فيتامينات + إلكتروليت لتقليل إجهاد النقل', 3
  UNION ALL SELECT 'medicine',    NULL, 'مضاد حيوي (إنروفلوكساسين) 3 أيام',        10
  UNION ALL SELECT 'medicine',    NULL, 'مضاد كوكسيديا وقائي',                    22
) v
WHERE c.id = (SELECT MAX(id) FROM cycles WHERE name = 'مرحبا');

-- ============================================================
-- المصروفات (cycle_expenses)
-- ============================================================
INSERT INTO cycle_expenses (cycle_id, label, value, entry_date)
SELECT c.id, v.label, v.value, DATE_ADD(c.start_date_raw, INTERVAL v.d DAY)
FROM cycles c
JOIN (
            SELECT 'شراء الكتاكيت (5000 كتكوت كوب 500)' AS label, 75000 AS value, 0  AS d
  UNION ALL SELECT 'علف بادئ',         42000, 2
  UNION ALL SELECT 'علف نامي',         88000, 12
  UNION ALL SELECT 'علف ناهي',         65000, 22
  UNION ALL SELECT 'أدوية وتحصينات',   12000, 8
  UNION ALL SELECT 'كهرباء وتدفئة',    9000,  15
  UNION ALL SELECT 'عمالة',            8000,  20
  UNION ALL SELECT 'نشارة خشب (فرشة)', 3500,  0
) v
WHERE c.id = (SELECT MAX(id) FROM cycles WHERE name = 'مرحبا');

-- ============================================================
-- المبيعات (cycle_sales)
-- ============================================================
INSERT INTO cycle_sales (cycle_id, quantity, total_weight, price_per_kg, total_price, sale_date)
SELECT c.id, v.quantity, v.total_weight, v.price_per_kg, v.total_price,
       DATE_ADD(c.start_date_raw, INTERVAL v.d DAY)
FROM cycles c
JOIN (
            SELECT 1500 AS quantity, 3000 AS total_weight, 70 AS price_per_kg, 210000 AS total_price, 32 AS d
  UNION ALL SELECT 2000, 4100, 72, 295200, 34
  UNION ALL SELECT 1450, 3050, 71, 216550, 36
) v
WHERE c.id = (SELECT MAX(id) FROM cycles WHERE name = 'مرحبا');

-- ============================================================
-- المخزون (cycle_inventory)
-- ============================================================
INSERT INTO cycle_inventory (cycle_id, item_name, category, unit, quantity, transaction_type, notes, entry_date)
SELECT c.id, v.item_name, v.category, v.unit, v.quantity, v.transaction_type, v.notes,
       DATE_ADD(c.start_date_raw, INTERVAL v.d DAY)
FROM cycles c
JOIN (
            SELECT 'علف بادئ'  AS item_name, 'علف'  AS category, 'كيس'    AS unit, 60  AS quantity, 'in'  AS transaction_type, 'استلام دفعة العلف البادئ' AS notes, 0  AS d
  UNION ALL SELECT 'علف نامي',  'علف',   'كيس',    120, 'in',  'استلام دفعة العلف النامي', 10
  UNION ALL SELECT 'نشارة خشب', 'فرشة',  'شيكارة', 40,  'in',  'فرشة أرضية',               0
  UNION ALL SELECT 'لقاحات',    'أدوية', 'جرعة',   5000,'in',  'دفعة التحصينات',           1
  UNION ALL SELECT 'علف بادئ',  'علف',   'كيس',    55,  'out', 'استهلاك أول أسبوعين',      14
) v
WHERE c.id = (SELECT MAX(id) FROM cycles WHERE name = 'مرحبا');

-- ============================================================
-- الملاحظات (cycle_notes)
-- ============================================================
INSERT INTO cycle_notes (cycle_id, content, entry_date)
SELECT c.id, v.content, DATE_ADD(c.start_date_raw, INTERVAL v.d DAY)
FROM cycles c
JOIN (
            SELECT 'بداية الدورة - استلام 5000 كتكوت من سلالة كوب 500. الوزن الابتدائي 42 جرام. الكتاكيت نشطة وحيوية.' AS content, 0  AS d
  UNION ALL SELECT 'تم رفع التدفئة ليلاً بسبب انخفاض حرارة الجو. توزيع الكتاكيت جيد حول المدفأة.',                       4
  UNION ALL SELECT 'لوحظ تحسن في استهلاك المياه والعلف بعد التحصين. معدل النمو ضمن المستهدف.',                          16
  UNION ALL SELECT 'بدء تجهيز العنبر لمرحلة التسويق. الوزن قريب من وزن البيع المستهدف.',                                28
) v
WHERE c.id = (SELECT MAX(id) FROM cycles WHERE name = 'مرحبا');

-- ============================================================
-- (3) تحقّق نهائي: عيّنة من التواريخ + عدد الصفوف لكل قسم
-- ============================================================
SELECT metric_type, numeric_value, text_value, entry_date
FROM cycle_data
WHERE cycle_id = (SELECT MAX(id) FROM cycles WHERE name = 'مرحبا')
ORDER BY entry_date ASC
LIMIT 15;

SELECT 'cycle_data'      AS section, COUNT(*) AS cnt FROM cycle_data      WHERE cycle_id = (SELECT MAX(id) FROM cycles WHERE name = 'مرحبا')
UNION ALL SELECT 'cycle_expenses',  COUNT(*) FROM cycle_expenses  WHERE cycle_id = (SELECT MAX(id) FROM cycles WHERE name = 'مرحبا')
UNION ALL SELECT 'cycle_sales',     COUNT(*) FROM cycle_sales     WHERE cycle_id = (SELECT MAX(id) FROM cycles WHERE name = 'مرحبا')
UNION ALL SELECT 'cycle_inventory', COUNT(*) FROM cycle_inventory WHERE cycle_id = (SELECT MAX(id) FROM cycles WHERE name = 'مرحبا')
UNION ALL SELECT 'cycle_notes',     COUNT(*) FROM cycle_notes     WHERE cycle_id = (SELECT MAX(id) FROM cycles WHERE name = 'مرحبا');
