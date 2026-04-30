import '../class/status_request.dart';

StatusRequest handlingData(dynamic response) {
  if (response is StatusRequest) {
    return response;
  } else {
    return StatusRequest.success;
  }
}
