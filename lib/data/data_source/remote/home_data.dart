import '../../../core/class/crud.dart';
import '../../../core/constant/link_api.dart';

class HomeData {
  Crud crud;
  HomeData(this.crud);
  getData() async {
    var response = await crud.postData(AppLink.home, {});
    return response.fold((l) => l, (r) => r);
  }
   
}