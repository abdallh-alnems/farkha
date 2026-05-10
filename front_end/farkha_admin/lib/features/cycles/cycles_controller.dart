import 'package:get/get.dart';
import '../../core/api/admin_api.dart';

class CyclesController extends GetxController {
  final cycles = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;
  final errorMsg = ''.obs;
  final currentPage = 1.obs;
  final totalPages = 1.obs;
  final statusFilter = 'all'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCycles();
  }

  Future<void> fetchCycles({int? page}) async {
    isLoading.value = true;
    errorMsg.value = '';
    try {
      final res = await AdminApi.post('/admin/cycles/list.php', {
        'page': page ?? currentPage.value,
        'page_size': 20,
        'status': statusFilter.value,
      });
      final data = res['data'] as Map<String, dynamic>;
      cycles.value = (data['items'] as List).map((e) => e as Map<String, dynamic>).toList();
      currentPage.value = data['page'] as int;
      totalPages.value = data['total_pages'] as int;
    } on AdminApiException catch (e) {
      errorMsg.value = e.message;
    } catch (_) {
      errorMsg.value = 'فشل تحميل البيانات';
    } finally {
      isLoading.value = false;
    }
  }

  void setFilter(String status) {
    statusFilter.value = status;
    currentPage.value = 1;
    fetchCycles();
  }

  Future<bool> forceClose(int cycleId, String endDate) async {
    try {
      await AdminApi.post('/admin/cycles/force_close.php', {'cycle_id': cycleId, 'end_date': endDate});
      fetchCycles();
      return true;
    } on AdminApiException catch (e) {
      Get.snackbar('خطأ', e.message, snackPosition: SnackPosition.BOTTOM);
      return false;
    }
  }

  Future<bool> softDelete(int cycleId) async {
    try {
      await AdminApi.post('/admin/cycles/soft_delete.php', {'cycle_id': cycleId});
      fetchCycles();
      return true;
    } on AdminApiException catch (e) {
      Get.snackbar('خطأ', e.message, snackPosition: SnackPosition.BOTTOM);
      return false;
    }
  }

  Future<bool> hardDelete(int cycleId) async {
    try {
      await AdminApi.post('/admin/cycles/hard_delete.php', {'cycle_id': cycleId});
      fetchCycles();
      return true;
    } on AdminApiException catch (e) {
      Get.snackbar('خطأ', e.message, snackPosition: SnackPosition.BOTTOM);
      return false;
    }
  }
}
