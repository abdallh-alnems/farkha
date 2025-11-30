import '../../../../core/class/crud.dart';
import '../../../../core/constant/id/api.dart';

class PricesCardData {
  Crud crud;
  PricesCardData(this.crud);

  Future<Object> getDataWithTypeIds(List<int> typeIds) async {
    final url = '${Api.pricesCard}?type_ids=${typeIds.join(',')}';
    var response = await crud.postData(url, {'type_ids': typeIds.join(',')});
    return response.fold((l) => l, (r) => r);
  }
}
