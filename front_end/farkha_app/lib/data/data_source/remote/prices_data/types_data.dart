import '../../../../core/class/crud.dart';
import '../../../../core/constant/id/api.dart';

class TypesData {
  Crud crud;
  TypesData(this.crud);

  Future<Object> getTypes() async {
    var response = await crud.postData(Api.types, {});
    return response.fold((l) => l, (r) => r);
  }
}
