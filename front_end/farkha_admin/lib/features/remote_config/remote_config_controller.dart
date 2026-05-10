import 'package:get/get.dart';
import '../../core/api/admin_api.dart';

class RemoteConfigController extends GetxController {
  final parameters = <Map<String, dynamic>>[].obs;
  final version = <String, dynamic>{}.obs;
  final isLoading = false.obs;
  final errorMsg = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchConfig();
  }

  Future<void> fetchConfig() async {
    isLoading.value = true;
    errorMsg.value = '';
    try {
      final res = await AdminApi.get('/admin/remote_config/get.php');
      final data = res['data'] as Map<String, dynamic>? ?? {};
      parameters.value = (data['parameters'] as List<dynamic>? ?? [])
          .map((e) => e as Map<String, dynamic>)
          .toList();
      version.value = data['version'] as Map<String, dynamic>? ?? {};
    } on AdminApiException catch (e) {
      errorMsg.value = e.message;
    } catch (e) {
      errorMsg.value = 'فشل تحميل الإعدادات';
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateParameter(String name, String value, {String description = ''}) async {
    try {
      final res = await AdminApi.post('/admin/remote_config/update.php', {
        'name': name,
        'value': value,
        'description': description,
      });
      final data = res['data'] as Map<String, dynamic>? ?? {};
      parameters.value = (data['parameters'] as List<dynamic>? ?? [])
          .map((e) => e as Map<String, dynamic>)
          .toList();
      version.value = data['version'] as Map<String, dynamic>? ?? {};
      return true;
    } on AdminApiException catch (e) {
      Get.snackbar('خطأ', e.message, snackPosition: SnackPosition.BOTTOM);
      return false;
    }
  }
}
