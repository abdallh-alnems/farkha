import 'dart:io';

import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ExcelExportService {
  static Future<void> exportCycleReport(Map<String, dynamic> cycle) async {
    final excel = Excel.createExcel();
    final sheet = excel['تقرير الدورة'];

    final headerStyle = CellStyle(
      bold: true,
      fontSize: 13,
      backgroundColorHex: ExcelColor.blue,
      fontColorHex: ExcelColor.white,
      horizontalAlign: HorizontalAlign.Center,
    );

    final sectionStyle = CellStyle(
      bold: true,
      fontSize: 12,
      backgroundColorHex: ExcelColor.fromHexString('#D9E1F2'),
      horizontalAlign: HorizontalAlign.Right,
    );

    final labelStyle = CellStyle(
      bold: true,
      fontSize: 11,
      horizontalAlign: HorizontalAlign.Right,
    );

    final valueStyle = CellStyle(
      fontSize: 11,
      horizontalAlign: HorizontalAlign.Center,
    );

    void setCell(int row, int col, dynamic value, {CellStyle? style}) {
      final cellIndex = CellIndex.indexByColumnRow(
        columnIndex: col,
        rowIndex: row,
      );
      sheet.updateCell(
        cellIndex,
        value is num ? DoubleCellValue(value.toDouble()) : TextCellValue('$value'),
        cellStyle: style,
      );
    }

    void addSection(int row, String title) {
      sheet.merge(
        CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row),
        CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row),
      );
      setCell(row, 0, title, style: sectionStyle);
    }

    void addKv(int row, String label, String value) {
      setCell(row, 0, label, style: labelStyle);
      setCell(row, 1, value, style: valueStyle);
    }

    void addTable(int startRow, List<String> headers, List<List<String>> rows) {
      for (var c = 0; c < headers.length; c++) {
        setCell(startRow, c, headers[c], style: headerStyle);
      }
      for (var r = 0; r < rows.length; r++) {
        for (var c = 0; c < rows[r].length; c++) {
          setCell(startRow + 1 + r, c, rows[r][c]);
        }
      }
    }

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

    final liveCount =
        (int.tryParse(chickCount) ?? 0) - (int.tryParse(mortality) ?? 0);
    final averageWeight =
        double.tryParse(cycle['average_weight']?.toString() ?? '0') ?? 0.0;
    final totalMeat = liveCount * averageWeight;
    final fcr = cycle['fcr']?.toString() ?? '0.00';
    final costPerBird = cycle['cost_per_bird']?.toString() ?? '0.00';

    final totalFeed =
        double.tryParse(cycle['total_feed']?.toString() ?? '0') ?? 0.0;
    final totalExpenses =
        double.tryParse(cycle['total_expenses']?.toString() ?? '0') ?? 0.0;
    final totalSales =
        double.tryParse(cycle['total_sales']?.toString() ?? '0') ?? 0.0;
    final netProfit =
        double.tryParse(cycle['net_profit']?.toString() ?? '0') ?? 0.0;

    final mortalityEntries =
        (cycle['mortalityEntries'] as List<dynamic>?) ?? [];
    final weightEntries =
        (cycle['averageWeightEntries'] as List<dynamic>?) ??
        (cycle['weightEntries'] as List<dynamic>?) ??
        [];
    final feedEntries =
        (cycle['feedConsumptionEntries'] as List<dynamic>?) ?? [];
    final medicationEntries =
        (cycle['medicationEntries'] as List<dynamic>?) ?? [];
    final expensesList = (cycle['expenses'] as List<dynamic>?) ?? [];
    final salesList = (cycle['sales'] as List<dynamic>?) ?? [];
    final customDataEntries =
        (cycle['customDataEntries'] as List<dynamic>?) ?? [];

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

    var row = 0;

    addSection(row, 'معلومات الدورة');
    row++;
    addKv(row, 'اسم الدورة', name);
    row++;
    addKv(row, 'السلالة', breed);
    row++;
    addKv(row, 'نظام التربية', systemType);
    row++;
    addKv(row, 'تاريخ البدء', startDate);
    row++;
    if (endDate != '-' && endDate.isNotEmpty) {
      addKv(row, 'تاريخ الانتهاء', endDate);
      row++;
    }
    addKv(row, 'عمر الدورة', '$cycleAge يوم');
    row++;
    addKv(row, 'مساحة العنبر', '$space م²');
    row++;

    row++;
    addSection(row, 'أداء القطيع');
    row++;
    addKv(row, 'العدد الأولي', '$chickCount طائر');
    row++;
    addKv(row, 'النافق', '$mortality ($mortalityRate%)');
    row++;
    addKv(row, 'العدد المتبقي', '$liveCount طائر');
    row++;
    addKv(row, 'متوسط الوزن', '${averageWeight.toStringAsFixed(2)} كجم/طائر');
    row++;
    addKv(
      row,
      'إجمالي اللحم المنتج',
      '${totalMeat.toStringAsFixed(0)} كجم',
    );
    row++;
    addKv(row, 'معامل التحويل (FCR)', fcr);
    row++;

    row++;
    addSection(row, 'المالية');
    row++;
    addKv(row, 'تكلفة الفرخ', '$costPerBird ج.م');
    row++;
    addKv(
      row,
      'إجمالي العلف',
      '${totalFeed.toStringAsFixed(0)} كجم',
    );
    row++;
    addKv(
      row,
      'المصروفات',
      '${totalExpenses.toStringAsFixed(0)} ج.م',
    );
    row++;
    addKv(row, 'المبيعات', '${totalSales.toStringAsFixed(0)} ج.م');
    row++;
    addKv(
      row,
      'صافي الربح/الخسارة',
      '${netProfit >= 0 ? '+' : ''}${netProfit.toStringAsFixed(0)} ج.م',
    );
    row++;

    if (expensesList.isNotEmpty) {
      row++;
      addSection(row, 'المصروفات التفصيلية');
      row++;
      final expRows =
          expensesList.map((e) {
            final type = e['type']?.toString() ?? '-';
            final amount =
                double.tryParse(e['amount']?.toString() ?? '0') ?? 0.0;
            final date = e['created_at']?.toString() ?? '-';
            return [date, type, '${amount.toStringAsFixed(0)} ج.م'];
          }).toList();
      addTable(row, ['التاريخ', 'النوع', 'المبلغ'], expRows);
      row += 1 + expRows.length;
    }

    if (salesList.isNotEmpty) {
      row++;
      addSection(row, 'سجل المبيعات');
      row++;
      final saleRows =
          salesList.map((s) {
            final raw = s['sale_date']?.toString() ?? '';
            final date = (() {
              if (raw.isEmpty) return '-';
              final parsed = DateTime.tryParse(raw);
              if (parsed == null) {
                return raw.length >= 10 ? raw.substring(0, 10) : raw;
              }
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
      addTable(
        row,
        ['التاريخ', 'العدد', 'الوزن الكلي', 'سعر الكيلو', 'الإجمالي'],
        saleRows,
      );
      row += 1 + saleRows.length;
    }

    if (mortalityEntries.isNotEmpty) {
      row++;
      addSection(row, 'سجل النافق اليومي');
      row++;
      final rows =
          mortalityEntries.map((e) {
            final date = e['date']?.toString() ?? '-';
            final count = e['count']?.toString() ?? '0';
            return [date, '$count طائر'];
          }).toList();
      addTable(row, ['التاريخ', 'عدد النافق'], rows);
      row += 1 + rows.length;
    }

    if (weightEntries.isNotEmpty) {
      row++;
      addSection(row, 'قياسات الوزن');
      row++;
      final rows =
          weightEntries.map((e) {
            final date = e['date']?.toString() ?? '-';
            final weight =
                double.tryParse(e['weight']?.toString() ?? '0') ?? 0.0;
            return [date, '${weight.toStringAsFixed(2)} كجم'];
          }).toList();
      addTable(row, ['التاريخ', 'متوسط الوزن'], rows);
      row += 1 + rows.length;
    }

    if (feedEntries.isNotEmpty) {
      row++;
      addSection(row, 'استهلاك العلف اليومي');
      row++;
      final rows =
          feedEntries.map((e) {
            final date = e['date']?.toString() ?? '-';
            final amount =
                double.tryParse(e['amount']?.toString() ?? '0') ?? 0.0;
            return [date, '${amount.toStringAsFixed(1)} كجم'];
          }).toList();
      addTable(row, ['التاريخ', 'الكمية'], rows);
      row += 1 + rows.length;
    }

    if (medicationEntries.isNotEmpty) {
      row++;
      addSection(row, 'التحصينات والأدوية');
      row++;
      final rows =
          medicationEntries.map((e) {
            final date = e['date']?.toString() ?? '-';
            final text = e['text']?.toString() ?? '-';
            return [date, text];
          }).toList();
      addTable(row, ['التاريخ', 'التفاصيل'], rows);
      row += 1 + rows.length;
    }

    if (noteEntries.isNotEmpty) {
      row++;
      addSection(row, 'ملاحظات وبيانات مخصصة');
      row++;
      final rows =
          noteEntries.map((e) {
            final date = e['date']?.toString() ?? '-';
            final label = e['label']?.toString() ?? '-';
            final value = e['value']?.toString() ?? '-';
            return [date, label, value];
          }).toList();
      addTable(row, ['التاريخ', 'النوع', 'القيمة'], rows);
    }

    final bytes = excel.save();
    if (bytes == null) throw Exception('فشل في إنشاء ملف Excel');

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/تقرير_دورة_$name.xlsx');
    await file.writeAsBytes(bytes);

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        subject: 'تقرير دورة: $name',
      ),
    );
  }
}
