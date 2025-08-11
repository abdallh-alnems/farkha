import '../../../../core/class/crud.dart';
import '../../../../core/constant/id/link_api.dart';

class MainDataData {
  Crud crud;
  MainDataData(this.crud);
  Future<Object> getData() async {
    var response = await crud.postData(ApiLinks.mainTypes, {});
    return response.fold((l) => l, (r) => r);
  }
}
