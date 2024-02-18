class HomeModel {
  String? productType;
  String? productName;
  num? highestPrice;
  num? lowestPrice;
  String? priceDate;

  HomeModel(
      {this.productType,
      this.productName,
      this.highestPrice,
      this.lowestPrice,
      this.priceDate});

  HomeModel.fromJson(Map<String, dynamic> json) {
    productType = json['product_type'];
    productName = json['product_name'];
    highestPrice = json['highest_price'];
    lowestPrice = json['lowest_price'];
    priceDate = json['price_date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['product_type'] = this.productType;
    data['product_name'] = this.productName;
    data['highest_price'] = this.highestPrice;
    data['lowest_price'] = this.lowestPrice;
    data['price_date'] = this.priceDate;
    return data;
  }
}