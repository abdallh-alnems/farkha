import '../../../../core/class/crud.dart';
import '../../../../core/constant/id/api.dart';

class FeedPricesData {
  Crud crud;
  FeedPricesData(this.crud);

  Future<Object> getData(String mainId) async {
    var response = await crud.postData(Api.feedPrices, {"type": mainId});
    return response.fold((l) => l, (r) => r);
  }
}
