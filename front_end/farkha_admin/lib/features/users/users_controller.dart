import 'package:get/get.dart';
import '../../core/api/admin_api.dart';

class UsersController extends GetxController {
  final users = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;
  final errorMsg = ''.obs;
  final currentPage = 1.obs;
  final totalPages = 1.obs;
  final total = 0.obs;
  final searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUsers();
  }

  Future<void> fetchUsers({int? page}) async {
    isLoading.value = true;
    errorMsg.value = '';
    try {
      final p = page ?? currentPage.value;
      final res = await AdminApi.post('/admin/users/list.php', {
        'page': p,
        'page_size': 20,
        if (searchQuery.value.isNotEmpty) 'q': searchQuery.value,
      });
      final data = res['data'] as Map<String, dynamic>;
      users.value = (data['items'] as List).map((e) => e as Map<String, dynamic>).toList();
      currentPage.value = data['page'] as int;
      totalPages.value = data['total_pages'] as int;
      total.value = data['total'] as int;
    } on AdminApiException catch (e) {
      errorMsg.value = e.message;
    } catch (_) {
      errorMsg.value = 'فشل تحميل البيانات';
    } finally {
      isLoading.value = false;
    }
  }

  void search(String q) {
    searchQuery.value = q;
    currentPage.value = 1;
    fetchUsers();
  }

  Future<bool> deleteUser(int userId, {String reason = 'admin_delete'}) async {
    try {
      await AdminApi.post('/admin/users/delete.php', {
        'user_id': userId,
        'reason': reason,
      });
      fetchUsers();
      return true;
    } on AdminApiException catch (e) {
      Get.snackbar('خطأ', e.message, snackPosition: SnackPosition.BOTTOM);
      return false;
    }
  }

  Future<bool> sendNotification(int userId, String title, String body) async {
    try {
      await AdminApi.post('/admin/users/send_notification.php', {
        'user_id': userId,
        'title': title,
        'body': body,
      });
      return true;
    } on AdminApiException catch (e) {
      Get.snackbar('خطأ', e.message, snackPosition: SnackPosition.BOTTOM);
      return false;
    }
  }
}
