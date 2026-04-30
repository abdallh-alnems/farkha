import '../../../../core/constant/id/api.dart';
import '../base_remote_data.dart';

class PricesByTypeData extends BaseRemoteData {
  PricesByTypeData(super.crud);
  Future<dynamic> getData(String mainId) =>
      request(url: Api.pricesByType, data: {'type': mainId});
}
