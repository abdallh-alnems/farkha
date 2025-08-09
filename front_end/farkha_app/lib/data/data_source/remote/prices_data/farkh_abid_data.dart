import '../../../../core/class/crud.dart';
import '../../../../core/constant/id/link_api.dart';

class FarkhAbidData {
  Crud crud;
  FarkhAbidData(this.crud);
  Future<Object> getData() async {
    var response = await crud.postData(ApiLinks.farkhAbid, {});
    return response.fold((l) => l, (r) => r);
  }
}
