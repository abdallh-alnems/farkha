class FeasibilityModel {
  int chickenSalePrice;
  int chickPrice;
  int badiPrice;
  int namiPrice;
  int nahiPrice;

  FeasibilityModel({
    required this.chickenSalePrice,
    required this.chickPrice,
    required this.badiPrice,
    required this.namiPrice,
    required this.nahiPrice,
  });

  FeasibilityModel.fromJson(List<dynamic> data)
      : chickenSalePrice = data[0]['price'],
        chickPrice = data[1]['price'],
        badiPrice = data[2]['price'],
        namiPrice = data[3]['price'],
        nahiPrice = data[4]['price'];
}