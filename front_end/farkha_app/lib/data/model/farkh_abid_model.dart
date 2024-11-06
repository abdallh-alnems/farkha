class FarkhAbidModel {
  int? price;

  FarkhAbidModel({this.price});

  FarkhAbidModel.fromJson(Map<String, dynamic> json) {
    price = json['price'];
  }

 

}