import '../../../../core/class/crud.dart';
import '../../../../core/constant/id/api.dart';

class PriceHistoryData {
  PriceHistoryData(this.crud);

  final Crud crud;

  Future<Object> getPriceHistory({
    required int typeId,
    int limit = 30,
    String? beforeDate,
  }) async {
    final buffer = StringBuffer('${Api.priceHistory}?type_id=$typeId&limit=$limit');
    if (beforeDate != null && beforeDate.isNotEmpty) {
      buffer.write('&before_date=${Uri.encodeComponent(beforeDate)}');
    }
    final url = buffer.toString();
    final response = await crud.postData(url, {});
    return response.fold((l) => l, (r) => r);
  }
}
