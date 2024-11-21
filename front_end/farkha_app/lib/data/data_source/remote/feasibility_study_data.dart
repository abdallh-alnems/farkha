import '../../../core/class/crud.dart';
import '../../../core/constant/id/link_api.dart';

class FeasibilityData {
  Crud crud;
  FeasibilityData(this.crud);
  getData() async {
    var response = await crud.postData(ApiLinks.linkFeasibilityStudy, {});
    return response.fold((l) => l, (r) => r);
  }
}