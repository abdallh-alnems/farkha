import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/constant/theme/colors.dart';
import '../../../logic/controller/cycle_controller.dart';
import 'member/add_member_tab.dart';
import 'member/contact_picker_dialog.dart';
import 'member/members_tab.dart';
import 'member/overlay_toast.dart';

class AddMemberDialog extends StatefulWidget {
  final int? cycleId;
  final bool isDark;

  const AddMemberDialog({
    super.key,
    required this.cycleId,
    required this.isDark,
  });

  @override
  State<AddMemberDialog> createState() => _AddMemberDialogState();
}

class _AddMemberDialogState extends State<AddMemberDialog> {
  final TextEditingController _phoneController = TextEditingController();
  String? _invitationCode;
  String? _invitationLink;
  bool _isLoadingInvitation = false;
  bool _isAddingMember = false;
  bool _isSearching = false;
  String _selectedRole = 'admin';

  Map<String, dynamic>? _selectedUser;
  String? _resultMessage;
  bool _isResultError = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _searchUser() async {
    final phone = _phoneController.text.trim();
    if (phone.length < 11 || _isSearching) return;

    setState(() {
      _isSearching = true;
      _selectedUser = null;
      _resultMessage = null;
    });

    final cycleCtrl = Get.find<CycleController>();
    final results = await cycleCtrl.searchUsers(phone);

    if (!mounted) return;

    if (results == null) {
      setState(() {
        _isSearching = false;
        _resultMessage = 'فشل الاتصال بالسيرفر';
        _isResultError = true;
      });
    } else if (results.isEmpty) {
      setState(() {
        _isSearching = false;
        _resultMessage = 'لا يوجد مستخدم بهذا الرقم';
        _isResultError = true;
      });
    } else {
      setState(() {
        _isSearching = false;
        _selectedUser = results.first;
      });
    }
  }

  Future<void> _addSelectedUser() async {
    if (_selectedUser == null || _isAddingMember || widget.cycleId == null) {
      return;
    }

    setState(() {
      _isAddingMember = true;
      _resultMessage = null;
    });

    final cycleCtrl = Get.find<CycleController>();
    final phone = _selectedUser!['phone']?.toString() ?? '';

    final result = await cycleCtrl.addMemberByPhone(
      phone,
      role: _selectedRole,
      cycleId: widget.cycleId,
    );

    if (!mounted) return;

    if (result != null) {
      final status = result['status'];
      final message = result['message']?.toString() ?? 'حدث خطأ غير متوقع';
      setState(() {
        _isAddingMember = false;
        _resultMessage = message;
        _isResultError = status != 'success';
        if (status == 'success') {
          _phoneController.clear();
          _selectedUser = null;
        }
      });
    } else {
      setState(() {
        _isAddingMember = false;
        _resultMessage = 'فشل الاتصال بالسيرفر';
        _isResultError = true;
      });
    }
  }

  Future<void> _pickContact() async {
    try {
      var status = await Permission.contacts.status;
      if (!status.isGranted) {
        status = await Permission.contacts.request();
        if (!status.isGranted || !mounted) return;
      }

      if (!mounted) return;
      final contact = await showDialog<Contact>(
        context: context,
        builder: (ctx) => ContactPickerDialog(isDark: widget.isDark),
      );

      if (contact != null && contact.phones.isNotEmpty && mounted) {
        String phone = contact.phones.first.number;
        phone = phone.replaceAll(RegExp(r'[\s\-\(\)\+]'), '');

        if (phone.startsWith('20') && phone.length > 11) {
          phone = '0${phone.substring(2)}';
        }
        if (phone.length > 11) {
          phone = phone.substring(phone.length - 11);
        }

        _phoneController.text = phone;
        if (phone.length == 11) {
          unawaited(_searchUser());
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _resultMessage = 'حدث خطأ في جلب جهات الاتصال';
          _isResultError = true;
        });
      }
    }
  }

  Future<void> _generateInvitation() async {
    if (widget.cycleId == null) return;

    setState(() => _isLoadingInvitation = true);
    final cycleCtrl = Get.find<CycleController>();
    final result = await cycleCtrl.createInvitation(widget.cycleId!);

    if (!mounted) return;

    if (result != null && result['status'] == 'success') {
      final payload = result['data'] as Map<String, dynamic>? ?? result;
      final code = payload['code']?.toString();
      final link = payload['link']?.toString();
      setState(() {
        _invitationCode = code;
        _invitationLink = link ?? 'farkha://join/$code';
      });
      final textToCopy = _invitationLink ?? '';
      if (textToCopy.isNotEmpty) {
        try {
          await Clipboard.setData(ClipboardData(text: textToCopy));
          showOverlayToast('تم إنشاء الرابط ونسخه للحافظة');
        } catch (_) {
          showOverlayToast('تم إنشاء الرابط');
        }
      }
    } else {
      showOverlayToast(
        result?['message']?.toString() ?? 'فشل إنشاء الرابط',
        isError: true,
      );
    }
    setState(() => _isLoadingInvitation = false);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bool showAddButton = _selectedUser != null && !_isSearching;
    final Color muted = colorScheme.onSurface.withValues(alpha: 0.35);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        width: double.maxFinite,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.88,
        ),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.close, color: muted, size: 20.sp),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  Expanded(
                    child: Text(
                      'إدارة الأعضاء',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(width: 20.sp),
                ],
              ),
            ),

            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(bottom: showAddButton ? 0 : 8.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    MembersTab(
                      isDark: widget.isDark,
                      cycleId: widget.cycleId,
                      shrinkWrap: true,
                    ),

                    Obx(() {
                      final cycleCtrl = Get.find<CycleController>();
                      final cycleId = widget.cycleId;
                      Map<String, dynamic>? cycle;
                      if (cycleId != null) {
                        final currentId = cycleCtrl.currentCycle['cycle_id'];
                        final currentIdInt = currentId is int
                            ? currentId
                            : int.tryParse(currentId?.toString() ?? '');
                        if (currentIdInt == cycleId) {
                          cycle = cycleCtrl.currentCycle;
                        } else {
                          final idx = cycleCtrl.cycles.indexWhere((c) {
                            final cId = c['cycle_id'];
                            final cIdInt = cId is int
                                ? cId
                                : int.tryParse(cId?.toString() ?? '');
                            return cIdInt == cycleId;
                          });
                          if (idx != -1) cycle = cycleCtrl.cycles[idx];
                        }
                      }
                      final bool isOwner = cycle?['is_owner'] == true;
                      if (!isOwner) return const SizedBox.shrink();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            child: Divider(
                                color: colorScheme.outline.withValues(alpha: 0.15)),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
                            child: Text(
                              'إضافة عضو',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface
                                    .withValues(alpha: 0.6),
                              ),
                            ),
                          ),
                          AddMemberTab(
                            isDark: widget.isDark,
                            isOwner: true,
                            phoneController: _phoneController,
                            isSearching: _isSearching,
                            isAddingMember: _isAddingMember,
                            isLoadingInvitation: _isLoadingInvitation,
                            selectedRole: _selectedRole,
                            selectedUser: _selectedUser,
                            resultMessage: _resultMessage,
                            isResultError: _isResultError,
                            invitationCode: _invitationCode,
                            invitationLink: _invitationLink,
                            onSearch: _searchUser,
                            onPickContact: _pickContact,
                            onRoleChanged: (role) =>
                                setState(() => _selectedRole = role),
                            onAdd: _addSelectedUser,
                            onGenerateInvitation: _generateInvitation,
                            onCopyLink: () {
                              if (_invitationLink != null) {
                                Clipboard.setData(
                                    ClipboardData(text: _invitationLink!));
                                showOverlayToast('تم نسخ رابط الدعوة');
                              }
                            },
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),

            if (showAddButton)
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
                child: ElevatedButton(
                  onPressed: _isAddingMember ? null : _addSelectedUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r)),
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                  ),
                  child: _isAddingMember
                      ? SizedBox(
                          width: 20.w,
                          height: 20.w,
                          child: const CircularProgressIndicator(
                              strokeWidth: 2.5, color: Colors.white))
                      : Text('تأكيد إضافة العضو',
                          style: TextStyle(
                              fontSize: 14.sp, fontWeight: FontWeight.bold)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
