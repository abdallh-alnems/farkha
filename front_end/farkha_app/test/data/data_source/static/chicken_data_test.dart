import 'package:farkha_app/data/data_source/static/chicken_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ChickenData (static data integrity)', () {
    test('كل القوائم تحتوي على 45 عنصر (عدد أيام الدورة)', () {
      expect(feedConsumptions.length, 45);
      expect(temperatureList.length, 45);
      expect(weightsList.length, 45);
      expect(waterConsumptions.length, 45);
      expect(darknessLevels.length, 45);
    });

    test('أوزان الدجاج تزداد مع تقدم الأيام', () {
      for (int i = 1; i < weightsList.length; i++) {
        expect(weightsList[i], greaterThanOrEqualTo(weightsList[i - 1]));
      }
    });

    test('استهلاك العلف يزداد مع تقدم الأيام', () {
      for (int i = 1; i < feedConsumptions.length; i++) {
        expect(feedConsumptions[i], greaterThanOrEqualTo(feedConsumptions[i - 1]));
      }
    });

    test('استهلاك الماء يزداد مع تقدم الأيام', () {
      for (int i = 1; i < waterConsumptions.length; i++) {
        expect(waterConsumptions[i], greaterThanOrEqualTo(waterConsumptions[i - 1]));
      }
    });

    test('درجة الحرارة تتناقص مع تقدم الأيام', () {
      for (int i = 1; i < temperatureList.length; i++) {
        expect(temperatureList[i], lessThanOrEqualTo(temperatureList[i - 1]));
      }
    });

    test('ساعات الإظلام بين 0 و 24', () {
      for (final level in darknessLevels) {
        expect(level, greaterThanOrEqualTo(0));
        expect(level, lessThanOrEqualTo(24));
      }
    });

    test('الأوزان كلها أرقام موجبة', () {
      for (final w in weightsList) {
        expect(w, greaterThan(0));
      }
    });
  });
}
