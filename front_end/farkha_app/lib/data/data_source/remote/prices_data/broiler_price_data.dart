import '../../../../core/class/crud.dart';
import '../../../../core/constant/id/api.dart';

class BroilerPriceData {
  Crud crud;
  BroilerPriceData(this.crud);

  Future<Object> getBroilerPrice() async {
    final url = Api.broilerChicken;
    final response = await crud.postData(url, {});
    return response.fold((l) => l, (r) => r);
  }
}

