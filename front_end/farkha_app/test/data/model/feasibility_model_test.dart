import 'package:farkha_app/data/model/feasibility_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FeasibilityModel', () {
    test('fromJson يستخرج الأسعار من القائمة', () {
      final data = [
        {'name': 'لحم ابيض', 'price': '45'},
        {'name': 'ابيض (شركات)', 'price': '12'},
        {'name': 'بادي', 'price': '800'},
        {'name': 'نامي', 'price': '750'},
        {'name': 'ناهي', 'price': '700'},
      ];

      final model = FeasibilityModel.fromJson(data);

      expect(model.chickenSalePrice, 45);
      expect(model.chickPrice, 12);
      expect(model.badiPrice, 800);
      expect(model.namiPrice, 750);
      expect(model.nahiPrice, 700);
    });

    test('fromJson يتعامل مع قائمة فارغة', () {
      final model = FeasibilityModel.fromJson([]);

      expect(model.chickenSalePrice, 0);
      expect(model.chickPrice, 0);
      expect(model.badiPrice, 0);
      expect(model.namiPrice, 0);
      expect(model.nahiPrice, 0);
    });

    test('fromJson يتجاهل العناصر غير المعروفة', () {
      final data = [
        {'name': 'عنصر مجهول', 'price': '999'},
        {'name': 'لحم ابيض', 'price': '50'},
      ];

      final model = FeasibilityModel.fromJson(data);

      expect(model.chickenSalePrice, 50);
      expect(model.chickPrice, 0);
    });

    test('toJson يُرجع كل الأسعار', () {
      final model = FeasibilityModel(
        chickenSalePrice: 45,
        chickPrice: 12,
        badiPrice: 800,
        namiPrice: 750,
        nahiPrice: 700,
      );

      final json = model.toJson();

      expect(json['chickenSalePrice'], 45);
      expect(json['chickPrice'], 12);
      expect(json['badiPrice'], 800);
      expect(json['namiPrice'], 750);
      expect(json['nahiPrice'], 700);
    });

    test('fromJson يتعامل مع أسعار رقمية (int)', () {
      final data = [
        {'name': 'لحم ابيض', 'price': 55},
      ];

      final model = FeasibilityModel.fromJson(data);

      expect(model.chickenSalePrice, 55);
    });
  });
}
