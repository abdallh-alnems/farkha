import 'package:get/get.dart';
import '../../core/api/admin_api.dart';

class DashboardController extends GetxController {
  final overview = <String, dynamic>{}.obs;
  final isLoading = false.obs;
  final errorMsg = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchOverview();
  }

  Future<void> fetchOverview() async {
    isLoading.value = true;
    errorMsg.value = '';
    try {
      final res = await AdminApi.post('/admin/dashboard/overview.php');
      overview.value = res['data'] as Map<String, dynamic>? ?? {};
    } on AdminApiException catch (e) {
      errorMsg.value = e.message;
    } catch (e) {
      errorMsg.value = 'فشل تحميل البيانات';
    } finally {
      isLoading.value = false;
    }
  }
}
