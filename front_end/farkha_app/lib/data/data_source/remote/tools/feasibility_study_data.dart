import '../../../../core/class/crud.dart';
import '../../../../core/constant/id/api.dart';

class FeasibilityData {
  Crud crud;
  FeasibilityData(this.crud);
  Future<Object> getData() async {
    final response = await crud.postData(Api.feasibilityStudy, {});
    return response.fold((l) => l, (r) => r);
  }
}
