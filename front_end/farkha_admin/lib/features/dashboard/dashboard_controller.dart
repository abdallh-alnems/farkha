import 'package:get/get.dart';
import '../../core/api/admin_api.dart';

class DashboardController extends GetxController {
  final overview = <String, dynamic>{}.obs;
  final isLoading = false.obs;
  final errorMsg = ''.obs;
  final isMaintenanceEnabled = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchOverview();
    checkMaintenanceStatus();
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

  Future<void> checkMaintenanceStatus() async {
    try {
      final res = await AdminApi.get('/admin/remote_config/get.php');
      final data = res['data'] as Map<String, dynamic>? ?? {};
      final params = data['parameters'] as List<dynamic>? ?? [];
      for (final p in params) {
        if ((p as Map<String, dynamic>)['name'] == 'maintenance_enabled') {
          isMaintenanceEnabled.value = p['default_value']?.toString() == 'true';
          break;
        }
      }
    } catch (_) {}
  }
}
