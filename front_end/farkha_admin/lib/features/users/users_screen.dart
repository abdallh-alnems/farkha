import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import 'users_controller.dart';
import 'user_detail_screen.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UsersController());

    return Scaffold(
      appBar: AppBar(
        title: Text('المستخدمون (${controller.total})'),
        actions: [
          IconButton(
            onPressed: () => controller.fetchUsers(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'بحث بالاسم أو الهاتف...',
                prefixIcon: Icon(Icons.search),
              ),
              onSubmitted: controller.search,
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.users.isEmpty) {
                return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
              }
              if (controller.errorMsg.isNotEmpty) {
                return Center(child: Text(controller.errorMsg.value, style: const TextStyle(color: AppTheme.textSecondary)));
              }
              return ListView.builder(
                itemCount: controller.users.length,
                itemBuilder: (context, index) {
                  final user = controller.users[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppTheme.primary.withValues(alpha: 0.15),
                        child: Text(
                          (user['name'] ?? '?')[0].toUpperCase(),
                          style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(user['name'] ?? '-', style: const TextStyle(fontFamily: 'Cairo')),
                      subtitle: Text(user['phone'] ?? 'بدون هاتف', style: const TextStyle(fontFamily: 'Cairo', fontSize: 12)),
                      trailing: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('${user['cycles_count'] ?? 0} دورة', style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                          Text('ID: ${user['id']}', style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
                        ],
                      ),
                      onTap: () => Get.to(() => UserDetailScreen(userId: user['id'] as int)),
                    ),
                  );
                },
              );
            }),
          ),
          Obx(() {
            if (controller.totalPages.value <= 1) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: controller.currentPage.value > 1
                        ? () => controller.fetchUsers(page: controller.currentPage.value - 1)
                        : null,
                    icon: const Icon(Icons.chevron_right),
                  ),
                  Text(
                    '${controller.currentPage} / ${controller.totalPages}',
                    style: const TextStyle(fontFamily: 'Cairo'),
                  ),
                  IconButton(
                    onPressed: controller.currentPage.value < controller.totalPages.value
                        ? () => controller.fetchUsers(page: controller.currentPage.value + 1)
                        : null,
                    icon: const Icon(Icons.chevron_left),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
