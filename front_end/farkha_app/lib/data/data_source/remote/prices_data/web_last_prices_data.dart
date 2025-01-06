import '../../../../core/class/crud.dart';
import '../../../../core/constant/id/link_api.dart';

class WebListPricesData {
  Crud crud;
  WebListPricesData(this.crud);
  getData() async {
    var response = await crud.postData(ApiLinks.webLastPrices, {});
    return response.fold((l) => l, (r) => r);
  }
}