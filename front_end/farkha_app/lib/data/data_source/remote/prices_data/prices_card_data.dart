import '../../../../core/constant/id/api.dart';
import '../base_remote_data.dart';

class PricesCardData extends BaseRemoteData {
  PricesCardData(super.crud);

  Future<dynamic> getDataWithTypeIds(List<int> typeIds) =>
      request(url: '${Api.pricesCard}?type_ids=${typeIds.join(',')}');
}
