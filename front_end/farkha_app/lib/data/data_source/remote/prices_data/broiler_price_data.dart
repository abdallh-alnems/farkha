import '../../../../core/constant/id/api.dart';
import '../base_remote_data.dart';

class BroilerPriceData extends BaseRemoteData {
  BroilerPriceData(super.crud);

  Future<dynamic> getBroilerPrice() => request(url: Api.broilerChicken);
}
