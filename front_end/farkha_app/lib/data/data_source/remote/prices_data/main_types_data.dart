import '../../../../core/class/crud.dart';
import '../../../../core/constant/id/api.dart';

class MainDataData {
  Crud crud;
  MainDataData(this.crud);
  Future<Object> getData() async {
    final response = await crud.postData(Api.mainTypes, {});
    return response.fold((l) => l, (r) => r);
  }
}
