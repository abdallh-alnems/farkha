import '../../../../core/class/crud.dart';
import '../../../../core/constant/id/link_api.dart';

class LastPricesData {
  Crud crud;
  LastPricesData(this.crud);
  getData() async {
    var response = await crud.postData(ApiLinks.linkLastPrices, {});
    return response.fold((l) => l, (r) => r);
  }
}
