import '../../../../core/constant/id/api.dart';
import '../base_remote_data.dart';

class FeasibilityData extends BaseRemoteData {
  FeasibilityData(super.crud);
  Future<dynamic> getData() => request(url: Api.feasibilityStudy);
}
