import '../../../../core/class/crud.dart';
import '../../../../core/constant/id/api.dart';

class PricesByTypeData {
  Crud crud;
  PricesByTypeData(this.crud);
  Future<Object> getData(String mainId) async {
    var response = await crud.postData(Api.pricesByType, {"type": mainId});
    return response.fold((l) => l, (r) => r);
  }
}
