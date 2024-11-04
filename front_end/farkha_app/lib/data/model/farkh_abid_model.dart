class ModelLastPriceFarkhAbid {
  int? price;

  ModelLastPriceFarkhAbid({this.price});

  ModelLastPriceFarkhAbid.fromJson(Map<String, dynamic> json) {
    price = json['price'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['price'] = this.price;
    return data;
  }
}