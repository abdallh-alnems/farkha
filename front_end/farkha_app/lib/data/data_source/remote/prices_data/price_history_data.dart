import '../../../../core/constant/id/api.dart';
import '../base_remote_data.dart';

class PriceHistoryData extends BaseRemoteData {
  PriceHistoryData(super.crud);

  Future<dynamic> getPriceHistory({
    required int typeId,
    int limit = 30,
    String? beforeDate,
  }) {
    final buffer = StringBuffer('${Api.priceHistory}?type_id=$typeId&limit=$limit');
    if (beforeDate != null && beforeDate.isNotEmpty) {
      buffer.write('&before_date=${Uri.encodeComponent(beforeDate)}');
    }
    return request(url: buffer.toString());
  }
}
