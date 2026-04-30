import '../../../../core/constant/id/api.dart';
import '../base_remote_data.dart';

class MainDataData extends BaseRemoteData {
  MainDataData(super.crud);
  Future<dynamic> getData() => request(url: Api.mainTypes);
}
