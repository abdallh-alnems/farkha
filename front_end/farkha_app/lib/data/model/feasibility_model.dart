class FeasibilityModel {
  late int chickenSalePrice;
  late int chickPrice;
  late int badiPrice;
  late int namiPrice;
  late int nahiPrice;

  FeasibilityModel({
    required this.chickenSalePrice,
    required this.chickPrice,
    required this.badiPrice,
    required this.namiPrice,
    required this.nahiPrice,
  });

  FeasibilityModel.fromJson(List<dynamic> data) {
    // تعيين قيم افتراضية
    chickenSalePrice = 0;
    chickPrice = 0;
    badiPrice = 0;
    namiPrice = 0;
    nahiPrice = 0;

    // البحث عن كل نوع حسب type_name
    for (var item in data) {
      switch (item['name']) {
        case 'لحم ابيض':
          chickenSalePrice = int.parse(item['price']);
          break;
        case 'ابيض (شركات)':
          chickPrice = int.parse(item['price']);
          break;
        case 'بادي':
          badiPrice = int.parse(item['price']);
          break;
        case 'نامي':
          namiPrice = int.parse(item['price']);
          break;
        case 'ناهي':
          nahiPrice = int.parse(item['price']);
          break;
      }
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'chickenSalePrice': chickenSalePrice,
      'chickPrice': chickPrice,
      'badiPrice': badiPrice,
      'namiPrice': namiPrice,
      'nahiPrice': nahiPrice,
    };
  }
}
