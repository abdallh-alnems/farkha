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

    // البحث عن كل نوع حسب name
    for (var item in data) {
      switch (item['name']) {
        case 'لحم ابيض':
          chickenSalePrice = int.tryParse(item['price'].toString()) ?? 0;
          break;
        case 'ابيض (شركات)':
          chickPrice = int.tryParse(item['price'].toString()) ?? 0;
          break;
        case 'بادي':
          badiPrice = int.tryParse(item['price'].toString()) ?? 0;
          break;
        case 'نامي':
          namiPrice = int.tryParse(item['price'].toString()) ?? 0;
          break;
        case 'ناهي':
          nahiPrice = int.tryParse(item['price'].toString()) ?? 0;
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
