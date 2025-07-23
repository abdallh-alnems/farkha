import '../../../../core/class/crud.dart';
import '../../../../core/constant/id/link_api.dart';

class LastPricesData {
  Crud crud;
  LastPricesData(this.crud);
  getData(String mainId) async {
    var response = await crud.postData(ApiLinks.lastPrices, {"type": mainId});
    return response.fold((l) => l, (r) => r);
  }
}
