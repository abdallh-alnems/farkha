import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfExportService {
  static Future<void> exportCycleReport(Map<String, dynamic> cycle) async {
    final pdf = pw.Document();

    // Load custom Arabic font
    final fontData = await rootBundle.load('assets/fonts/Cairo/Cairo-Regular.ttf');
    final ttf = pw.Font.ttf(fontData);

    // Load Logo (if exists)
    pw.ImageProvider? logoImage;
    try {
      final logoData = await rootBundle.load('assets/images/logo.png');
      logoImage = pw.MemoryImage(logoData.buffer.asUint8List());
    } catch (_) {}

    // 1. Extract Cycle Data
    final name = cycle['name']?.toString() ?? 'دورة بدون اسم';
    final breed = cycle['breed']?.toString() ?? 'تسمين';
    final systemType = cycle['systemType']?.toString() ?? 'أرضي';
    final startDate = cycle['startDate']?.toString() ?? '-';
    final endDate = cycle['endDate']?.toString() ?? '-';
    final cycleAge = cycle['cycle_age']?.toString() ?? '0';
    final chickCount = cycle['chickCount']?.toString() ?? '0';
    final space = cycle['space']?.toString() ?? '-';
    final mortality = cycle['mortality']?.toString() ?? '0';
    final mortalityRate = cycle['mortality_rate']?.toString() ?? '0.0';

    final liveCount = (int.tryParse(chickCount) ?? 0) - (int.tryParse(mortality) ?? 0);
    final averageWeight = double.tryParse(cycle['average_weight']?.toString() ?? '0') ?? 0.0;
    final totalMeat = liveCount * averageWeight;
    final fcr = cycle['fcr']?.toString() ?? '0.00';
    final costPerBird = cycle['cost_per_bird']?.toString() ?? '0.00';

    final totalFeed = double.tryParse(cycle['total_feed']?.toString() ?? '0') ?? 0.0;
    final totalExpenses = double.tryParse(cycle['total_expenses']?.toString() ?? '0') ?? 0.0;
    final totalSales = double.tryParse(cycle['total_sales']?.toString() ?? '0') ?? 0.0;
    final netProfit = double.tryParse(cycle['net_profit']?.toString() ?? '0') ?? 0.0;

    // 2. Detailed lists
    final mortalityEntries = (cycle['mortalityEntries'] as List<dynamic>?) ?? [];
    final weightEntries = (cycle['averageWeightEntries'] as List<dynamic>?)
        ?? (cycle['weightEntries'] as List<dynamic>?) ?? [];
    final feedEntries = (cycle['feedConsumptionEntries'] as List<dynamic>?) ?? [];
    final medicationEntries = (cycle['medicationEntries'] as List<dynamic>?) ?? [];
    final expensesList = (cycle['expenses'] as List<dynamic>?) ?? [];
    final salesList = (cycle['sales'] as List<dynamic>?) ?? [];
    final customDataEntries = (cycle['customDataEntries'] as List<dynamic>?) ?? [];

    // Filter custom data: only user-written notes (not mortality/weight/feed/medication)
    final noteEntries = customDataEntries.where((e) {
      final label = e['label']?.toString() ?? '';
      final labelLower = label.toLowerCase();
      return !labelLower.contains('نافق') &&
          !labelLower.contains('وزن') &&
          !labelLower.contains('تحصين') &&
          !labelLower.contains('دواء') &&
          !labelLower.contains('استهلاك') &&
          !labelLower.contains('علف') &&
          !labelLower.contains('mortality') &&
          !labelLower.contains('weight') &&
          !labelLower.contains('feed') &&
          !labelLower.contains('medication');
    }).toList();

    // ─── Helper widgets ────────────────────────────────────────────────────────

    pw.Widget buildRow(String title, String value) {
      return pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 4),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(title,
                style: pw.TextStyle(
                    font: ttf, fontSize: 13, color: PdfColors.grey700)),
            pw.Text(value,
                style: pw.TextStyle(
                    font: ttf, fontSize: 13, fontWeight: pw.FontWeight.bold)),
          ],
        ),
      );
    }

    pw.Widget buildSectionTitle(String title) {
      return pw.Container(
        margin: const pw.EdgeInsets.only(top: 16, bottom: 8),
        padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        decoration: pw.BoxDecoration(
          color: PdfColors.grey200,
          borderRadius: pw.BorderRadius.circular(4),
        ),
        child: pw.Text(title,
            style: pw.TextStyle(
                font: ttf,
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue900)),
      );
    }

    /// Builds a table with a header row and data rows.
    /// [headers] and each row in [rows] must have the same length.
    pw.Widget buildTable(List<String> headers, List<List<String>> rows) {
      final colCount = headers.length;
      return pw.Table(
        border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
        columnWidths: {
          for (var i = 0; i < colCount; i++)
            i: const pw.FlexColumnWidth(),
        },
        children: [
          // Header row
          pw.TableRow(
            decoration: const pw.BoxDecoration(color: PdfColors.blueGrey100),
            children: headers
                .map(
                  (h) => pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(
                        vertical: 5, horizontal: 6),
                    child: pw.Text(h,
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                            font: ttf,
                            fontSize: 11,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.blueGrey900)),
                  ),
                )
                .toList(),
          ),
          // Data rows
          ...rows.map(
            (row) => pw.TableRow(
              children: row
                  .map(
                    (cell) => pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(
                          vertical: 4, horizontal: 6),
                      child: pw.Text(cell,
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(font: ttf, fontSize: 11)),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      );
    }

    // ─── Build PDF content ────────────────────────────────────────────────────

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        textDirection: pw.TextDirection.rtl,
        theme: pw.ThemeData.withFont(base: ttf, bold: ttf),
        build: (pw.Context context) {
          final widgets = <pw.Widget>[];

          // ── Header ──────────────────────────────────────────────────────────
          widgets.add(
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('تطبيق فرخة (Farkha App)',
                        style: pw.TextStyle(
                            font: ttf,
                            fontSize: 14,
                            color: PdfColors.grey600)),
                    pw.SizedBox(height: 4),
                    pw.Text('تقرير الدورة المفصل',
                        style: pw.TextStyle(
                            font: ttf,
                            fontSize: 24,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.blueGrey900)),
                  ],
                ),
                if (logoImage != null)
                  pw.Container(
                    width: 60,
                    height: 60,
                    child: pw.Image(logoImage),
                  ),
              ],
            ),
          );
          widgets.add(pw.SizedBox(height: 20));
          widgets.add(pw.Divider(color: PdfColors.grey300));

          // ── Basic Info ───────────────────────────────────────────────────────
          widgets.add(buildSectionTitle('معلومات الدورة الرئيسية'));
          widgets.add(buildRow('اسم الدورة', name));
          widgets.add(buildRow('السلالة', breed));
          widgets.add(buildRow('نظام التربية', systemType));
          widgets.add(buildRow('تاريخ البدء', startDate));
          if (endDate != '-' && endDate.isNotEmpty) {
            widgets.add(buildRow('تاريخ الانتهاء', endDate));
          }
          widgets.add(buildRow('عمر الدورة', '$cycleAge يوم'));
          widgets.add(buildRow('مساحة العنبر', '$space م²'));

          // ── Flock Performance ────────────────────────────────────────────────
          widgets.add(buildSectionTitle('أداء القطيع (المخرجات)'));
          widgets.add(buildRow('العدد الأولي', '$chickCount طائر'));
          widgets.add(buildRow('النافق', '$mortality ($mortalityRate%)'));
          widgets.add(buildRow('العدد المتبقي (الفعلي)', '$liveCount طائر'));
          widgets.add(buildRow('متوسط الوزن المباع',
              '${averageWeight.toStringAsFixed(2)} كجم/طائر'));
          widgets.add(buildRow(
              'إجمالي اللحم المنتج', '${totalMeat.toStringAsFixed(0)} كجم'));
          widgets.add(buildRow('معامل التحويل التعلفي (FCR)', fcr));

          // ── Financial Summary ─────────────────────────────────────────────────
          widgets.add(buildSectionTitle('المالية والمخزون'));
          widgets.add(buildRow('تكلفة الفرخ الواحد', '$costPerBird ج.م'));
          widgets.add(
              buildRow('إجمالي سحب العلف', '${totalFeed.toStringAsFixed(0)} كجم'));
          widgets.add(pw.Divider(color: PdfColors.grey300));
          widgets.add(buildRow(
              'المصروفات الكلية', '${totalExpenses.toStringAsFixed(0)} ج.م'));
          widgets.add(buildRow(
              'المبيعات الكلية', '${totalSales.toStringAsFixed(0)} ج.م'));
          widgets.add(
            pw.Container(
              margin: const pw.EdgeInsets.only(top: 10),
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(
                    color:
                        netProfit >= 0 ? PdfColors.green300 : PdfColors.red300),
                borderRadius: pw.BorderRadius.circular(8),
                color: netProfit >= 0 ? PdfColors.green50 : PdfColors.red50,
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('صافي الربح / الخسارة',
                      style: pw.TextStyle(
                          font: ttf,
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.grey800)),
                  pw.Text(
                      '${netProfit >= 0 ? '+' : ''}${netProfit.toStringAsFixed(0)} ج.م',
                      style: pw.TextStyle(
                          font: ttf,
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                          color: netProfit >= 0
                              ? PdfColors.green700
                              : PdfColors.red700)),
                ],
              ),
            ),
          );

          // ── Detailed Expenses ─────────────────────────────────────────────────
          if (expensesList.isNotEmpty) {
            widgets.add(buildSectionTitle('المصروفات التفصيلية'));
            final expRows = expensesList.map((e) {
              final type = e['type']?.toString() ?? '-';
              final amount =
                  double.tryParse(e['amount']?.toString() ?? '0') ?? 0.0;
              final date = e['created_at']?.toString() ?? '-';
              return [date, type, '${amount.toStringAsFixed(0)} ج.م'];
            }).toList();
            widgets.add(buildTable(['التاريخ', 'النوع', 'المبلغ'], expRows));
          }

          // ── Sales ──────────────────────────────────────────────────────────────
          if (salesList.isNotEmpty) {
            widgets.add(buildSectionTitle('سجل المبيعات'));
            final saleRows = salesList.map((s) {
              final date = (() {
                final raw = s['sale_date']?.toString() ?? '';
                if (raw.isEmpty) return '-';
                final parsed = DateTime.tryParse(raw);
                if (parsed == null) return raw.length >= 10 ? raw.substring(0, 10) : raw;
                return '${parsed.year}/${parsed.month.toString().padLeft(2, '0')}/${parsed.day.toString().padLeft(2, '0')}';
              })();
              final qty = s['quantity']?.toString() ?? '0';
              final totalWeight =
                  double.tryParse(s['total_weight']?.toString() ?? '0') ?? 0.0;
              final pricePerKg =
                  double.tryParse(s['price_per_kg']?.toString() ?? '0') ?? 0.0;
              final totalPrice =
                  double.tryParse(s['total_price']?.toString() ?? '0') ?? 0.0;
              return [
                date,
                '$qty طائر',
                '${totalWeight.toStringAsFixed(1)} كجم',
                '${pricePerKg.toStringAsFixed(2)} ج.م',
                '${totalPrice.toStringAsFixed(0)} ج.م',
              ];
            }).toList();
            widgets.add(buildTable(
              ['التاريخ', 'العدد', 'الوزن الكلي', 'سعر الكيلو', 'الإجمالي'],
              saleRows,
            ));
          }

          // ── Daily Mortality ──────────────────────────────────────────────────
          if (mortalityEntries.isNotEmpty) {
            widgets.add(buildSectionTitle('سجل النافق اليومي'));
            final rows = mortalityEntries.map((e) {
              final date = e['date']?.toString() ?? '-';
              final count = e['count']?.toString() ?? '0';
              return [date, '$count طائر'];
            }).toList();
            widgets.add(buildTable(['التاريخ', 'عدد النافق'], rows));
          }

          // ── Weight Measurements ───────────────────────────────────────────────
          if (weightEntries.isNotEmpty) {
            widgets.add(buildSectionTitle('قياسات الوزن'));
            final rows = weightEntries.map((e) {
              final date = e['date']?.toString() ?? '-';
              final weight =
                  double.tryParse(e['weight']?.toString() ?? '0') ?? 0.0;
              return [date, '${weight.toStringAsFixed(2)} كجم'];
            }).toList();
            widgets.add(buildTable(['التاريخ', 'متوسط الوزن'], rows));
          }

          // ── Feed Consumption ──────────────────────────────────────────────────
          if (feedEntries.isNotEmpty) {
            widgets.add(buildSectionTitle('استهلاك العلف اليومي'));
            final rows = feedEntries.map((e) {
              final date = e['date']?.toString() ?? '-';
              final amount =
                  double.tryParse(e['amount']?.toString() ?? '0') ?? 0.0;
              return [date, '${amount.toStringAsFixed(1)} كجم'];
            }).toList();
            widgets.add(buildTable(['التاريخ', 'الكمية'], rows));
          }

          // ── Medications ────────────────────────────────────────────────────────
          if (medicationEntries.isNotEmpty) {
            widgets.add(buildSectionTitle('التحصينات والأدوية'));
            final rows = medicationEntries.map((e) {
              final date = e['date']?.toString() ?? '-';
              final text = e['text']?.toString() ?? '-';
              return [date, text];
            }).toList();
            widgets.add(buildTable(['التاريخ', 'التفاصيل'], rows));
          }

          // ── Custom Notes ───────────────────────────────────────────────────────
          if (noteEntries.isNotEmpty) {
            widgets.add(buildSectionTitle('ملاحظات وبيانات مخصصة'));
            final rows = noteEntries.map((e) {
              final date = e['date']?.toString() ?? '-';
              final label = e['label']?.toString() ?? '-';
              final value = e['value']?.toString() ?? '-';
              return [date, label, value];
            }).toList();
            widgets.add(buildTable(['التاريخ', 'النوع', 'القيمة'], rows));
          }

          // ── Footer ────────────────────────────────────────────────────────────
          widgets.add(pw.SizedBox(height: 30));
          widgets.add(
            pw.Center(
              child: pw.Text(
                'تم إنشاء هذا التقرير آلياً بواسطة تطبيق فرخة',
                style: pw.TextStyle(
                    font: ttf, fontSize: 10, color: PdfColors.grey500),
              ),
            ),
          );

          return widgets;
        },
      ),
    );

    try {
      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: 'تقرير_دورة_$name.pdf',
      );
    } catch (e) {
      print('PdfExportService error: $e');
      rethrow;
    }
  }
}
