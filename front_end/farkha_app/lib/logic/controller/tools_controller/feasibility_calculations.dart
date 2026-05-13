import 'package:excel/excel.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../data/model/feasibility_model.dart';

class FeasibilityInput {
  final int chickenCount;
  final FeasibilityModel model;
  final double mortalityRate;
  final double overheadPerChicken;
  final double defaultWeight;
  final bool isProfessionalMode;
  final double badiFeedRatio;
  final double namiFeedRatio;
  final double nahiFeedRatio;
  final double averageFeedRatio;
  final double averageFeedPrice;

  const FeasibilityInput({
    required this.chickenCount,
    required this.model,
    required this.mortalityRate,
    required this.overheadPerChicken,
    required this.defaultWeight,
    required this.isProfessionalMode,
    required this.badiFeedRatio,
    required this.namiFeedRatio,
    required this.nahiFeedRatio,
    required this.averageFeedRatio,
    required this.averageFeedPrice,
  });
}

class FeasibilityResult {
  final int chickenCount;
  final int deadChickens;
  final int deadChickenTotalCost;
  final int totalChickenCost;
  final double totalFeedCost;
  final double totalOverheadCost;
  final double totalCost;

  const FeasibilityResult({
    required this.chickenCount,
    required this.deadChickens,
    required this.deadChickenTotalCost,
    required this.totalChickenCost,
    required this.totalFeedCost,
    required this.totalOverheadCost,
    required this.totalCost,
  });
}

class FeasibilityDisplayTexts {
  final String chickenCountText;
  final String mortalityRateText;
  final String chickenCostText;
  final String feedCostText;
  final String overheadCostText;
  final String totalCostText;
  final String costPerChickenText;
  final String costPerKgText;
  final String totalKgProducedText;
  final double totalChickenCostRaw;
  final double totalFeedCostRaw;
  final double totalOverheadCostRaw;

  const FeasibilityDisplayTexts({
    required this.chickenCountText,
    required this.mortalityRateText,
    required this.chickenCostText,
    required this.feedCostText,
    required this.overheadCostText,
    required this.totalCostText,
    required this.costPerChickenText,
    required this.costPerKgText,
    required this.totalKgProducedText,
    required this.totalChickenCostRaw,
    required this.totalFeedCostRaw,
    required this.totalOverheadCostRaw,
  });
}

double calculateFeedCost(int chickenCount, FeasibilityInput input) {
  if (input.isProfessionalMode) {
    final badiFeedCost =
        input.badiFeedRatio * (input.model.badiPrice / 1000);
    final namiFeedCost =
        input.namiFeedRatio * (input.model.namiPrice / 1000);
    final nahiFeedCost =
        input.nahiFeedRatio * (input.model.nahiPrice / 1000);
    return (badiFeedCost + namiFeedCost + nahiFeedCost) * chickenCount;
  }
  return input.averageFeedRatio *
      (input.averageFeedPrice / 1000) *
      chickenCount;
}

int calculateChickenCountFromBudget(double budget, FeasibilityInput input) {
  final feedCostPerChicken = calculateFeedCost(1, input);
  final totalCostPerChicken =
      input.model.chickPrice.toDouble() +
          feedCostPerChicken +
          input.overheadPerChicken;
  return (budget / totalCostPerChicken).floor();
}

FeasibilityResult computeFeasibility(FeasibilityInput input) {
  int deadChickens =
      (input.chickenCount * input.mortalityRate / 100).round();
  if (deadChickens > input.chickenCount) deadChickens = input.chickenCount;

  final totalChickenCost = input.chickenCount * input.model.chickPrice;

  final feedCostForAll = calculateFeedCost(input.chickenCount, input);
  final feedCostPerChicken = calculateFeedCost(1, input);

  final feedDeductionForDead = deadChickens * 0.5 * feedCostPerChicken;
  final totalFeedCost = feedCostForAll - feedDeductionForDead;
  final totalOverheadCost = input.chickenCount * input.overheadPerChicken;
  final totalCost = totalChickenCost + totalFeedCost + totalOverheadCost;

  final deadChickenChickCost = input.chickenCount > 0
      ? (deadChickens * totalChickenCost / input.chickenCount).round()
      : 0;
  final deadChickenFeedCost = deadChickens * 0.5 * feedCostPerChicken;
  final deadChickenOverheadCost = deadChickens * input.overheadPerChicken;
  final deadChickenTotalCost =
      (deadChickenChickCost + deadChickenFeedCost + deadChickenOverheadCost)
          .round();

  return FeasibilityResult(
    chickenCount: input.chickenCount,
    deadChickens: deadChickens,
    deadChickenTotalCost: deadChickenTotalCost,
    totalChickenCost: totalChickenCost,
    totalFeedCost: totalFeedCost,
    totalOverheadCost: totalOverheadCost,
    totalCost: totalCost,
  );
}

String formatNoTrailingZero(double value, int decimals) {
  final s = value.toStringAsFixed(decimals);
  return s.replaceAll(RegExp(r'\.0+$'), '');
}

FeasibilityDisplayTexts formatResultTexts(
  FeasibilityResult result,
  bool isChickenCountMode,
  double defaultWeight,
) {
  final chickenCountText =
      isChickenCountMode ? '' : '${result.chickenCount} فرخ';

  final mortalityRateText = result.deadChickenTotalCost > 0
      ? '${result.deadChickens} فرخ (${result.deadChickenTotalCost} ج)'
      : '${result.deadChickens} فرخ';

  final chickenCostText = '${result.totalChickenCost} ج';
  final feedCostText = '${result.totalFeedCost.toStringAsFixed(0)} ج';
  final overheadCostText = '${result.totalOverheadCost.toStringAsFixed(0)} ج';
  final totalCostText = '${result.totalCost.toStringAsFixed(0)} ج';

  final remainingChickens = result.chickenCount - result.deadChickens;

  String costPerChickenText;
  String costPerKgText;
  String totalKgProducedText;

  if (remainingChickens > 0) {
    final costPerChicken = result.totalCost / remainingChickens;
    costPerChickenText = '${costPerChicken.toStringAsFixed(0)} ج';

    final totalKg = remainingChickens * defaultWeight;
    if (totalKg > 0) {
      final tons = totalKg / 1000;
      totalKgProducedText = totalKg >= 1000
          ? '${formatNoTrailingZero(tons, 1)} طن'
          : '${formatNoTrailingZero(totalKg, 1)} كجم';
      final costPerKg = result.totalCost / totalKg;
      costPerKgText = '${formatNoTrailingZero(costPerKg, 1)} ج/كجم';
    } else {
      totalKgProducedText = '-';
      costPerKgText = '-';
    }
  } else {
    costPerChickenText = '-';
    costPerKgText = '-';
    totalKgProducedText = '-';
  }

  return FeasibilityDisplayTexts(
    chickenCountText: chickenCountText,
    mortalityRateText: mortalityRateText,
    chickenCostText: chickenCostText,
    feedCostText: feedCostText,
    overheadCostText: overheadCostText,
    totalCostText: totalCostText,
    costPerChickenText: costPerChickenText,
    costPerKgText: costPerKgText,
    totalKgProducedText: totalKgProducedText,
    totalChickenCostRaw: result.totalChickenCost.toDouble(),
    totalFeedCostRaw: result.totalFeedCost,
    totalOverheadCostRaw: result.totalOverheadCost,
  );
}

String buildShareText(FeasibilityDisplayTexts texts) {
  final buffer = StringBuffer();
  buffer.writeln('تطبيق فَرْخة');
  buffer.writeln('دراسة جدوى');
  buffer.writeln();
  if (texts.chickenCountText.isNotEmpty) {
    buffer.writeln('عدد الفراخ: ${texts.chickenCountText}');
    buffer.writeln();
  }
  buffer.writeln('التكاليف:');
  buffer.writeln('• النافق: ${texts.mortalityRateText}');
  buffer.writeln('• سعر الكتاكيت: ${texts.chickenCostText}');
  buffer.writeln('• تكلفة العلف: ${texts.feedCostText}');
  buffer.writeln('• النثريات: ${texts.overheadCostText}');
  buffer.writeln('• التكلفة الإجمالية: ${texts.totalCostText}');
  if (texts.costPerChickenText.isNotEmpty &&
      texts.costPerChickenText != '-') {
    buffer.writeln('• تكلفة الفرخ الواحد: ${texts.costPerChickenText}');
  }
  if (texts.costPerKgText.isNotEmpty && texts.costPerKgText != '-') {
    buffer.writeln('• تكلفة الكيلو: ${texts.costPerKgText}');
  }
  return buffer.toString();
}

Future<pw.Document> buildFeasibilityPdf(
    FeasibilityDisplayTexts texts) async {
  final regularFontData =
      await rootBundle.load('assets/fonts/Cairo/Cairo-Regular.ttf');
  final boldFontData =
      await rootBundle.load('assets/fonts/Cairo/Cairo-Bold.ttf');
  final regular = pw.Font.ttf(regularFontData);
  final bold = pw.Font.ttf(boldFontData);

  final pdf = pw.Document(
    theme: pw.ThemeData.withFont(base: regular, bold: bold),
  );

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      build: (context) => pw.Directionality(
        textDirection: pw.TextDirection.rtl,
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'دراسة جدوى',
              style: pw.TextStyle(font: bold, fontSize: 24),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              'تطبيق فَرْخة',
              style: pw.TextStyle(
                  font: regular, fontSize: 12, color: PdfColors.grey600),
            ),
            pw.SizedBox(height: 24),
            _pdfSection('التكاليف', regular, bold, [
              if (texts.chickenCountText.isNotEmpty)
                _pdfRow('عدد الفراخ', texts.chickenCountText, regular, bold),
              _pdfRow('النافق', texts.mortalityRateText, regular, bold),
              _pdfRow('سعر الكتاكيت', texts.chickenCostText, regular, bold),
              _pdfRow('تكلفة العلف', texts.feedCostText, regular, bold),
              _pdfRow('النثريات', texts.overheadCostText, regular, bold),
              _pdfRow('تكلفة الفرخ الواحد', texts.costPerChickenText,
                  regular, bold),
              _pdfRow('تكلفة الكيلو', texts.costPerKgText, regular, bold),
              _pdfRow(
                  'التكلفة الإجمالية', texts.totalCostText, regular, bold),
            ]),
          ],
        ),
      ),
    ),
  );

  return pdf;
}

pw.Widget _pdfSection(
    String title, pw.Font regular, pw.Font bold, List<pw.Widget> rows) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(title, style: pw.TextStyle(font: bold, fontSize: 16)),
      pw.Divider(),
      ...rows,
    ],
  );
}

pw.Widget _pdfRow(
    String label, String value, pw.Font regular, pw.Font bold) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 3),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label, style: pw.TextStyle(font: regular, fontSize: 12)),
        pw.Text(value, style: pw.TextStyle(font: bold, fontSize: 12)),
      ],
    ),
  );
}

List<int> buildFeasibilityExcel(FeasibilityDisplayTexts texts) {
  final excel = Excel.createExcel();
  final sheet = excel['دراسة جدوى'];
  excel.delete('Sheet1');

  final headerStyle = CellStyle(
    bold: true,
    fontSize: 12,
    backgroundColorHex: ExcelColor.fromHexString('#4E7A3E'),
    fontColorHex: ExcelColor.white,
  );

  final titleStyle = CellStyle(bold: true, fontSize: 14);

  void setCell(int row, int col, String value, {CellStyle? style}) {
    sheet.updateCell(
      CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row),
      TextCellValue(value),
      cellStyle: style,
    );
  }

  setCell(0, 1, 'دراسة جدوى - تطبيق فَرْخة', style: titleStyle);

  int row = 2;
  row = _writeExcelSection(sheet, row, 'التكاليف', headerStyle, [
    if (texts.chickenCountText.isNotEmpty)
      ['عدد الفراخ', texts.chickenCountText],
    ['النافق', texts.mortalityRateText],
    ['سعر الكتاكيت', texts.chickenCostText],
    ['تكلفة العلف', texts.feedCostText],
    ['النثريات', texts.overheadCostText],
    ['تكلفة الفرخ الواحد', texts.costPerChickenText],
    ['تكلفة الكيلو', texts.costPerKgText],
    ['التكلفة الإجمالية', texts.totalCostText],
  ], setCell);

  sheet.setColumnWidth(1, 25);

  final bytes = excel.save();
  if (bytes == null) throw Exception('فشل في إنشاء ملف Excel');
  return bytes;
}

int _writeExcelSection(
  Sheet sheet,
  int startRow,
  String title,
  CellStyle headerStyle,
  List<List<String>> rows,
  void Function(int, int, String, {CellStyle? style}) setCell,
) {
  setCell(startRow, 1, title, style: headerStyle);
  startRow++;

  for (final row in rows) {
    setCell(startRow, 1, row[0]);
    setCell(startRow, 2, row[1]);
    startRow++;
  }

  return startRow;
}
