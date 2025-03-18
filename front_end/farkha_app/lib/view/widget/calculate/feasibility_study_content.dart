import 'package:flutter/material.dart';
import '../../../../core/constant/theme/color.dart';
import '../../../../logic/controller/calculate_controller/feasibility_study_controller.dart';
import '../ad/native.dart';
import 'feasibility_study_title.dart';

class FeasibilityStudyContent extends StatelessWidget {
  final FeasibilityController controller;

  const FeasibilityStudyContent({required this.controller, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildPricesSection(),
        AdNativeWidget(adIndex: 2),
        _buildResultSection("التكاليف", [
          _buildItem(
            "الكتاكيت",
            "سعر الكتاكيت × عدد الكتاكيت",
          ),
          _buildItem(
            "العلف",
            "سعر كيلو البادي × 0.5ك",
            tooltip: "اجمالي استهلاك الفرخ للعلف طوال الدورة هي 3.5 كيلو",
          ),
          SizedBox(height: 5),
          const Text("سعر كيلو النامي × 1.2ك"),
          SizedBox(height: 5),
          const Text("سعر كيلو الناهي × 1.8ك"),
          SizedBox(height: 5),
          const Text("البادي + النامي + الناهي × عدد الفراح "),
          _buildItem(
            "النثريات",
            "عدد الفراخ × 10ج",
            tooltip: "النثريات هي احتياجات الدورة من ايجار وخلافة",
          ),
          _buildItem(
            "النافق",
            "%5 × عدد الفراخ",
            tooltip:
                "نسبة 5% هي نسبة النفوق العالمي وان تعدي النافق هذة النسبة يكون هناك خلل في ادارة الدورة",
          ),
          _buildItem("التكلفة الاجمالية", "الكتاكيت + العلف + النثريات"),
        ]),
        const SizedBox(height: 25),
        _buildResultSection("المبيعات", [
          _buildItem(
            "الوزن",
            "عدد الفراخ × 2ك",
            tooltip: "يتم ضرب عدد الفراخ في وزن 2 كيلو بعد خصم النافق",
          ),
          _buildItem("البيع", "الوزن × سعر البيع"),
        ]),
        const SizedBox(height: 25),
        _buildResultSection("الارباح", [
          _buildItem("اجمالي الارباح", "التكاليف - المبيعات"),
        ]),
      ],
    );
  }

  Widget _buildPricesSection() {
    return Column(
      children: [
        const SizedBox(height: 11),
        _buildPriceRow(
            "اللحم الابيض", controller.feasibilityModel.chickenSalePrice),
        _buildPriceRow(
            "الكتكوت الابيض (شركات)", controller.feasibilityModel.chickPrice),
        _buildPriceRow("علف بادي", controller.feasibilityModel.badiPrice),
        _buildPriceRow("علف نامي", controller.feasibilityModel.namiPrice),
        _buildPriceRow("علف ناهي", controller.feasibilityModel.nahiPrice),
        const SizedBox(height: 11),
      ],
    );
  }

  Widget _buildPriceRow(String label, int price) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(price.toString()),
        const SizedBox(height: 33),
        Text(" : $label"),
      ],
    );
  }

  Widget _buildResultSection(String title, List<Widget> items) {
    return Column(
      children: [
        ResultTitle(title: title),
        ...items,
      ],
    );
  }

  Widget _buildItem(String label, String description, {String? tooltip}) {
    return Padding(
      padding: const EdgeInsets.only(top: 21),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (tooltip != null)
                PopupMenuButton(
                  padding: EdgeInsets.zero,
                  tooltip: '',
                  offset: const Offset(0, 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: SizedBox(
                        width: 200,
                        child: Text(
                          tooltip,
                          style: const TextStyle(fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                  child: Icon(
                    Icons.help_outline,
                    size: 18,
                    color: AppColor.primaryColor,
                  ),
                ),
              const SizedBox(width: 5),
              Text(label),
              const SizedBox(width: 9),
              Container(
                height: 9,
                width: 9,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(9),
                  color: AppColor.primaryColor,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text(description),
          ),
        ],
      ),
    );
  }
}
