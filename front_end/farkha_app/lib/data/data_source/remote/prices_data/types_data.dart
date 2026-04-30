import '../../../../core/constant/id/api.dart';
import '../base_remote_data.dart';

class TypesData extends BaseRemoteData {
  TypesData(super.crud);

  Future<dynamic> getTypes() => request(url: Api.types);
}
