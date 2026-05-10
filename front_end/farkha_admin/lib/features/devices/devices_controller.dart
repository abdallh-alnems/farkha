import 'package:get/get.dart';
import '../../core/api/admin_api.dart';

class DevicesController extends GetxController {
  final devices = <Map<String, dynamic>>[].obs;
  final stats = <String, dynamic>{}.obs;
  final isLoading = false.obs;
  final errorMsg = ''.obs;
  final currentPage = 1.obs;
  final totalPages = 1.obs;
  final total = 0.obs;

  final selectedPlatform = ''.obs;
  final selectedPeriod = '7'.obs;
  final searchQuery = ''.obs;

  final periods = [
    ('1', 'اليوم'),
    ('7', '7 أيام'),
    ('30', '30 يوم'),
    ('90', '90 يوم'),
    ('365', 'سنة'),
    ('0', 'الكل'),
  ];

  @override
  void onInit() {
    super.onInit();
    fetchDevices();
  }

  void setPlatform(String platform) {
    selectedPlatform.value = platform;
    currentPage.value = 1;
    fetchDevices();
  }

  void setPeriod(String period) {
    selectedPeriod.value = period;
    currentPage.value = 1;
    fetchDevices();
  }

  void search(String q) {
    searchQuery.value = q;
    currentPage.value = 1;
    fetchDevices();
  }

  Future<void> fetchDevices({int? page}) async {
    isLoading.value = true;
    errorMsg.value = '';
    try {
      final p = page ?? currentPage.value;
      final activeDays = int.tryParse(selectedPeriod.value) ?? 7;
      final res = await AdminApi.post('/admin/devices/list.php', {
        'page': p,
        'page_size': 20,
        if (selectedPlatform.value.isNotEmpty) 'platform': selectedPlatform.value,
        if (activeDays > 0) 'active_days': activeDays,
        if (searchQuery.value.isNotEmpty) 'q': searchQuery.value,
      });
      final data = res['data'] as Map<String, dynamic>;
      devices.value = (data['items'] as List).map((e) => e as Map<String, dynamic>).toList();
      currentPage.value = data['page'] as int;
      totalPages.value = data['total_pages'] as int;
      total.value = data['total'] as int;
      stats.value = data['stats'] as Map<String, dynamic>? ?? {};
    } on AdminApiException catch (e) {
      errorMsg.value = e.message;
    } catch (_) {
      errorMsg.value = 'فشل تحميل البيانات';
    } finally {
      isLoading.value = false;
    }
  }
}
