import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/class/status_request.dart';
import '../../../core/services/initialization.dart';
import '../../../data/data_source/remote/auth_data/delete_account_data.dart';
import '../../../data/data_source/remote/auth_data/update_name_data.dart';
import '../../../data/data_source/remote/auth_data/update_phone_data.dart';
import '../../../logic/controller/auth/login_controller.dart';

class DrawerAccountSettings extends StatefulWidget {
  const DrawerAccountSettings({super.key});

  @override
  State<DrawerAccountSettings> createState() => _DrawerAccountSettingsState();
}

class _DrawerAccountSettingsState extends State<DrawerAccountSettings> {
  bool _isExpanded = false;

  void _showSnackbar(String message, {bool isError = false}) {
    // محاولة متعددة للحصول على context صالح
    void tryShow(int attempt) {
      if (attempt > 5) {
        // إذا فشلت جميع المحاولات، استخدم Get.snackbar كبديل
        Get.snackbar(
          isError ? 'خطأ' : 'نجاح',
          message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor:
              isError
                  ? Colors.red.withValues(alpha: 0.9)
                  : Colors.green.withValues(alpha: 0.9),
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          icon: Icon(
            isError ? Icons.error_outline : Icons.check_circle,
            color: Colors.white,
          ),
          duration: const Duration(seconds: 3),
        );
        return;
      }

      Future.delayed(Duration(milliseconds: 300 + (attempt * 200)), () {
        final BuildContext? currentContext =
            Get.key.currentContext ?? Get.context;
        if (currentContext != null && currentContext.mounted) {
          final scaffoldMessenger = ScaffoldMessenger.maybeOf(currentContext);
          if (scaffoldMessenger != null) {
            scaffoldMessenger.showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(
                      isError ? Icons.error_outline : Icons.check_circle,
                      color: Colors.white,
                      size: 21,
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Text(
                        message,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
                backgroundColor: isError ? Colors.red : Colors.green,
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                duration: const Duration(seconds: 3),
              ),
            );
          } else {
            tryShow(attempt + 1);
          }
        } else {
          tryShow(attempt + 1);
        }
      });
    }

    tryShow(0);
  }

  Future<void> _handleEditName() async {
    final myServices = Get.find<MyServices>();
    final currentName = myServices.getStorage.read<String>('user_name') ?? '';

    final nameController = TextEditingController(text: '');

    final result = await showDialog<String>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('تعديل الاسم'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (currentName.isNotEmpty) ...[
                  Text(
                    'الاسم الحالي: $currentName',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  SizedBox(height: 16.h),
                ],
                TextField(
                  controller: nameController,
                  autofocus: true,
                  keyboardType: TextInputType.name,
                  decoration: InputDecoration(
                    labelText: 'الاسم',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  onSubmitted:
                      (value) => Navigator.of(dialogContext).pop(value),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('إلغاء'),
              ),
              TextButton(
                onPressed:
                    () => Navigator.of(dialogContext).pop(nameController.text),
                child: const Text('حفظ'),
              ),
            ],
          ),
    );

    if (mounted) {
      Navigator.pop(context);
    }

    if (result != null && result.isNotEmpty) {
      await Future.delayed(const Duration(milliseconds: 500));
      await _updateName(result);
    }
  }

  Future<void> _updateName(String name) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showSnackbar('يجب تسجيل الدخول أولاً', isError: true);
        return;
      }

      final String? token = await user.getIdToken();
      if (token == null) {
        _showSnackbar('فشل الحصول على رمز الدخول', isError: true);
        return;
      }

      final updateNameData = UpdateNameData();
      final response = await updateNameData.updateName(
        token: token,
        name: name,
      );

      response.fold(
        (failure) {
          _showSnackbar('فشل تحديث الاسم', isError: true);
        },
        (success) {
          final data = success as Map<String, dynamic>;
          if (data['success'] == true || data['status'] == 'success') {
            final myServices = Get.find<MyServices>();
            myServices.getStorage.write('user_name', name);
            _showSnackbar('تم تحديث الاسم بنجاح');
            if (mounted) {
              setState(() {});
            }
          } else {
            _showSnackbar(data['message'] ?? 'فشل تحديث الاسم', isError: true);
          }
        },
      );
    } catch (e) {
      _showSnackbar('حدث خطأ أثناء تحديث الاسم', isError: true);
    }
  }

  Future<void> _handleEditPhone() async {
    final myServices = Get.find<MyServices>();
    final currentPhone = myServices.getStorage.read<String>('user_phone');
    final isAdding = currentPhone == null || currentPhone.isEmpty;

    final phoneController = TextEditingController(text: '');

    final result = await showDialog<String>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: Text(isAdding ? 'إضافة رقم الهاتف' : 'تعديل رقم الهاتف'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isAdding) ...[
                  Text(
                    'الرقم الحالي: $currentPhone',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  SizedBox(height: 16.h),
                ],
                TextField(
                  controller: phoneController,
                  autofocus: true,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'رقم الهاتف',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  onSubmitted:
                      (value) => Navigator.of(dialogContext).pop(value),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('إلغاء'),
              ),
              TextButton(
                onPressed:
                    () => Navigator.of(dialogContext).pop(phoneController.text),
                child: const Text('حفظ'),
              ),
            ],
          ),
    );

    if (mounted) {
      Navigator.pop(context);
    }

    if (result != null && result.isNotEmpty) {
      await Future.delayed(const Duration(milliseconds: 500));
      await _updatePhone(result);
    }
  }

  Future<void> _updatePhone(String phone) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showSnackbar('يجب تسجيل الدخول أولاً', isError: true);
        return;
      }

      final String? token = await user.getIdToken();
      if (token == null) {
        _showSnackbar('فشل الحصول على رمز الدخول', isError: true);
        return;
      }

      final updatePhoneData = UpdatePhoneData();
      final response = await updatePhoneData.updatePhone(
        token: token,
        phone: phone,
      );

      response.fold(
        (failure) {
          _showSnackbar('فشل تحديث رقم الهاتف', isError: true);
        },
        (success) {
          final data = success as Map<String, dynamic>;
          if (data['success'] == true || data['status'] == 'success') {
            final myServices = Get.find<MyServices>();
            final wasEmpty =
                myServices.getStorage.read<String>('user_phone') == null;
            myServices.getStorage.write('user_phone', phone);
            _showSnackbar(
              'تم ${wasEmpty ? 'إضافة' : 'تحديث'} رقم الهاتف بنجاح',
            );
            if (mounted) {
              setState(() {});
            }
          } else {
            _showSnackbar(
              data['message'] ?? 'فشل تحديث رقم الهاتف',
              isError: true,
            );
          }
        },
      );
    } catch (e) {
      _showSnackbar('حدث خطأ أثناء تحديث رقم الهاتف', isError: true);
    }
  }

  Future<void> _handleSignOut() async {
    Navigator.pop(context);
    // LoginController is registered in AppBindings
    final loginController = Get.find<LoginController>();
    await loginController.signOut();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _handleDeleteAccount() async {
    Navigator.pop(context);
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('حذف الحساب'),
        content: const Text(
          'هل أنت متأكد من حذف حسابك؟ لا يمكن التراجع عن هذا الإجراء.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _deleteAccount();
    }
  }

  Future<void> _deleteAccount() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showSnackbar('يجب تسجيل الدخول أولاً', isError: true);
        return;
      }

      final String? token = await user.getIdToken();
      if (token == null) {
        _showSnackbar('فشل الحصول على رمز الدخول', isError: true);
        return;
      }

      final deleteAccountData = DeleteAccountData();
      final response = await deleteAccountData.deleteAccount(token: token);

      response.fold(
        (failure) {
          if (failure == StatusRequest.offlineFailure) {
            _showSnackbar('لا يوجد اتصال بالإنترنت', isError: true);
          } else {
            _showSnackbar('فشل حذف الحساب', isError: true);
          }
        },
        (result) {
          final data = result as Map<String, dynamic>;
          if (data['status'] == 'success') {
            // Delete account locally
            final loginController = Get.find<LoginController>();
            loginController.signOut();
            _showSnackbar('تم حذف الحساب بنجاح');
          } else {
            _showSnackbar(data['message'] ?? 'فشل حذف الحساب', isError: true);
          }
        },
      );
    } catch (e) {
      _showSnackbar('حدث خطأ أثناء حذف الحساب', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final myServices = Get.find<MyServices>();
    final isLoggedIn =
        myServices.getStorage.read<bool>('is_logged_in') ?? false;

    if (!isLoggedIn) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 13).r,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Icon(
            Icons.settings_rounded,
            size: 21.sp,
            color: Theme.of(context).colorScheme.primary,
          ),
          title: Text('إعدادات الحساب', style: TextStyle(fontSize: 15.sp)),
          trailing: const SizedBox.shrink(),
          tilePadding: EdgeInsets.zero,
          childrenPadding: EdgeInsets.zero,
          initiallyExpanded: _isExpanded,
          onExpansionChanged: (expanded) {
            setState(() {
              _isExpanded = expanded;
            });
          },
          children: [
            ListTile(
              onTap: _handleEditName,
              title: Text('تعديل الاسم', style: TextStyle(fontSize: 15.sp)),
              shape: const Border(),
              contentPadding: EdgeInsets.symmetric(horizontal: 13.w),
            ),
            Builder(
              builder: (context) {
                final myServices = Get.find<MyServices>();
                final currentPhone = myServices.getStorage.read<String>(
                  'user_phone',
                );
                final isAdding = currentPhone == null || currentPhone.isEmpty;

                return ListTile(
                  onTap: _handleEditPhone,
                  title: Text(
                    isAdding ? 'إضافة رقم الهاتف' : 'تعديل رقم الهاتف',
                    style: TextStyle(fontSize: 15.sp),
                  ),
                  subtitle:
                      currentPhone != null && currentPhone.isNotEmpty
                          ? Text(
                            currentPhone,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          )
                          : null,
                  shape: const Border(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 13.w),
                );
              },
            ),
            ListTile(
              onTap: _handleSignOut,
              title: Text('تسجيل الخروج', style: TextStyle(fontSize: 15.sp)),
              shape: const Border(),
              contentPadding: EdgeInsets.symmetric(horizontal: 13.w),
            ),
            ListTile(
              onTap: _handleDeleteAccount,
              title: Text('حذف الحساب', style: TextStyle(fontSize: 15.sp)),
              shape: const Border(),
              contentPadding: EdgeInsets.symmetric(horizontal: 13.w),
            ),
          ],
        ),
      ),
    );
  }
}
