import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/constant/theme/colors.dart';
import '../../../core/services/initialization.dart';
import '../../../logic/controller/cycle_controller.dart';

/// يعرض toast فوق كل شيء (بما فيها الـ dialogs) باستخدام الـ root overlay
void _showOverlayToast(String message, {bool isError = false}) {
  final overlay = Get.key.currentState?.overlay;
  if (overlay == null) return;
  OverlayEntry? entry;
  entry = OverlayEntry(
    builder: (_) => Positioned(
      bottom: 40,
      left: 24,
      right: 24,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isError ? Colors.red.shade700 : Colors.green.shade700,
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)],
          ),
          child: Text(
            message,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    ),
  );
  overlay.insert(entry);
  Future.delayed(const Duration(seconds: 2), () {
    if (entry?.mounted == true) entry?.remove();
  });
}

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
        builder: (ctx) => _ContactPickerDialog(isDark: widget.isDark),
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
          _searchUser();
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

    if (result != null) {
      if (result['status'] == 'success') {
        final link = result['link']?.toString();
        setState(() {
          _invitationCode = result['code']?.toString();
          _invitationLink = link;
        });
        if (link != null) {
          await Clipboard.setData(ClipboardData(text: link));
          _showOverlayToast('تم إنشاء رابط الدعوة');
        }
      } else {
        _showOverlayToast(
          result['message']?.toString() ?? 'فشل إنشاء الرابط',
          isError: true,
        );
      }
    }
    setState(() => _isLoadingInvitation = false);
  }

  @override
  Widget build(BuildContext context) {
    final bool showAddButton = _selectedUser != null && !_isSearching;

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
          color: widget.isDark
              ? AppColors.darkSurfaceColor
              : AppColors.lightSurfaceColor,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 20,
              spreadRadius: 5,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ========= Header ==========
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 12.h),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.group_rounded,
                          color: AppColors.primaryColor, size: 22.sp),
                      SizedBox(width: 8.w),
                      Text(
                        'إدارة الأعضاء',
                        style: TextStyle(
                          color: widget.isDark ? Colors.white : Colors.black87,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    left: 0,
                    child: IconButton(
                      icon: Icon(Icons.close,
                          color: widget.isDark
                              ? Colors.white54
                              : Colors.black54,
                          size: 20.sp),
                      onPressed: () => Navigator.of(context).pop(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ),
                ],
              ),
            ),

            Divider(
              height: 1,
              color: widget.isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.grey.withValues(alpha: 0.15),
            ),

            // ========= Scrollable content ==========
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(bottom: showAddButton ? 0 : 8.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // --- قسم الأعضاء الحاليين ---
                    _MembersTab(
                      isDark: widget.isDark,
                      cycleId: widget.cycleId,
                      shrinkWrap: true,
                    ),

                    // --- فاصل + قسم إضافة عضو (للمالك فقط) ---
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
                          // فاصل
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16.w, vertical: 4.h),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Divider(
                                    color: widget.isDark
                                        ? Colors.white12
                                        : Colors.black12,
                                  ),
                                ),
                                Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 12.w),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.person_add_alt_1_rounded,
                                          size: 14.sp,
                                          color: AppColors.primaryColor),
                                      SizedBox(width: 4.w),
                                      Text(
                                        'إضافة عضو',
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Divider(
                                    color: widget.isDark
                                        ? Colors.white12
                                        : Colors.black12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // قسم الإضافة
                          _AddMemberTab(
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
                                _showOverlayToast('تم نسخ رابط الدعوة');
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

            // ========= زر تأكيد الإضافة ==========
            if (showAddButton)
              Container(
                padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
                decoration: BoxDecoration(
                  color: widget.isDark
                      ? AppColors.darkSurfaceColor
                      : AppColors.lightSurfaceColor,
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(20.r)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
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
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.person_add_alt_1_rounded, size: 20.sp),
                            SizedBox(width: 8.w),
                            Text('تأكيد إضافة العضو',
                                style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// Tab 1: عرض الأعضاء الحاليين
// ============================================================
class _MembersTab extends StatefulWidget {
  final bool isDark;
  final int? cycleId;
  final bool shrinkWrap;
  const _MembersTab({
    required this.isDark,
    required this.cycleId,
    this.shrinkWrap = false,
  });

  @override
  State<_MembersTab> createState() => _MembersTabState();
}

class _MembersTabState extends State<_MembersTab> {
  bool _isFetching = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _fetchMembers();
    });
  }

  Future<void> _fetchMembers() async {
    final cycleId = widget.cycleId;
    if (cycleId == null) return;
    if (mounted) setState(() => _isFetching = true);

    final cycleCtrl = Get.find<CycleController>();

    // تأكد من أن currentCycle يشير إلى الدورة الصحيحة قبل الجلب
    final currentId = cycleCtrl.currentCycle['cycle_id'];
    final currentIdInt =
        currentId is int ? currentId : int.tryParse(currentId?.toString() ?? '');
    if (currentIdInt != cycleId) {
      final idx = cycleCtrl.cycles.indexWhere((c) {
        final cId = c['cycle_id'];
        final cIdInt = cId is int ? cId : int.tryParse(cId?.toString() ?? '');
        return cIdInt == cycleId;
      });
      if (idx != -1) {
        cycleCtrl.currentCycle.assignAll(cycleCtrl.cycles[idx]);
      }
    }

    await cycleCtrl.fetchCycleDetails(cycleId);
    if (mounted) setState(() => _isFetching = false);
  }

  /// ابحث عن الدورة الصحيحة بالـ cycleId من cycles أو currentCycle
  Map<String, dynamic>? _findCycle(CycleController cycleCtrl) {
    final cycleId = widget.cycleId;
    if (cycleId == null) return null;

    // أولاً: تحقق من currentCycle
    final currentId = cycleCtrl.currentCycle['cycle_id'];
    final currentIdInt =
        currentId is int ? currentId : int.tryParse(currentId?.toString() ?? '');
    if (currentIdInt == cycleId) return cycleCtrl.currentCycle;

    // ثانياً: ابحث في cycles list
    final idx = cycleCtrl.cycles.indexWhere((c) {
      final cId = c['cycle_id'];
      final cIdInt = cId is int ? cId : int.tryParse(cId?.toString() ?? '');
      return cIdInt == cycleId;
    });
    if (idx != -1) return cycleCtrl.cycles[idx];

    // فال باك: currentCycle
    return cycleCtrl.currentCycle;
  }

  @override
  Widget build(BuildContext context) {
    if (_isFetching) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40.h),
          child: CircularProgressIndicator(color: AppColors.primaryColor),
        ),
      );
    }

    final cycleCtrl = Get.find<CycleController>();
    final myServices = Get.find<MyServices>();
    final String currentUserPhone =
        myServices.getStorage.read<String>('user_phone') ?? '';

    return Obx(() {
      final cycle = _findCycle(cycleCtrl);
      final List<dynamic> members =
          (cycle?['members'] as List?) ?? [];
      final bool isOwner = cycle?['is_owner'] == true;

      // عنوان القسم + عدد الأعضاء
      final header = Padding(
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
        child: Row(
          children: [
            Icon(Icons.people_rounded,
                size: 16.sp, color: AppColors.primaryColor),
            SizedBox(width: 6.w),
            Text(
              'الأعضاء الحاليون',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
                color: widget.isDark ? Colors.white70 : Colors.black87,
              ),
            ),
            SizedBox(width: 6.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                '${members.length}',
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
              ),
            ),
          ],
        ),
      );

      if (members.isEmpty) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            header,
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.group_off_rounded,
                      size: 40.sp,
                      color: widget.isDark ? Colors.white24 : Colors.black26),
                  SizedBox(height: 8.h),
                  Text(
                    'لا يوجد أعضاء في الدورة',
                    style: TextStyle(
                      color: widget.isDark ? Colors.white38 : Colors.black45,
                      fontSize: 13.sp,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }

      final list = ListView.separated(
        padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 12.w),
        shrinkWrap: widget.shrinkWrap,
        physics: widget.shrinkWrap
            ? const NeverScrollableScrollPhysics()
            : null,
        itemCount: members.length,
        separatorBuilder: (ctx, i) => SizedBox(height: 8.h),
        itemBuilder: (ctx, i) {
          final Map<String, dynamic> member =
              Map<String, dynamic>.from(members[i] as Map);
          final String memberPhone = member['phone']?.toString() ?? '';
          final bool isCurrentUser = currentUserPhone.isNotEmpty &&
              memberPhone == currentUserPhone;
          return _MemberCard(
            member: member,
            isDark: widget.isDark,
            cycleCtrl: cycleCtrl,
            isOwner: isOwner,
            isCurrentUser: isCurrentUser,
          );
        },
      );

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          header,
          widget.shrinkWrap ? list : Expanded(child: list),
        ],
      );
    });
  }
}

// ============================================================
// بطاقة العضو
// ============================================================
class _MemberCard extends StatefulWidget {
  final Map<String, dynamic> member;
  final bool isDark;
  final CycleController cycleCtrl;
  final bool isOwner;
  final bool isCurrentUser;

  const _MemberCard({
    required this.member,
    required this.isDark,
    required this.cycleCtrl,
    required this.isOwner,
    required this.isCurrentUser,
  });

  @override
  State<_MemberCard> createState() => _MemberCardState();
}

class _MemberCardState extends State<_MemberCard> {
  bool _isUpdatingRole = false;
  bool _isRemoving = false;

  String get _memberRole => widget.member['role']?.toString() ?? 'viewer';
  String get _memberName =>
      (widget.member['name'] ?? widget.member['phone'] ?? 'عضو').toString();
  String get _memberPhone => widget.member['phone']?.toString() ?? '';
  bool get _isPending => widget.member['status'] == 'pending';

  int? get _userId {
    final raw = widget.member['id'];
    if (raw is int) return raw;
    return int.tryParse(raw?.toString() ?? '');
  }

  void _changeRole(String newRole) {
    if (_userId == null || _isUpdatingRole) return;

    final roleLabel = newRole == 'admin' ? 'مشرف' : 'متابع';

    showDialog<bool>(
      context: Get.context!,
      builder: (ctx) => AlertDialog(
        title: const Text('تغيير الصلاحية'),
        content: Text(
          'هل أنت متأكد من تغيير صلاحية $_memberName إلى "$roleLabel"؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryColor),
            child: const Text('تأكيد'),
          ),
        ],
      ),
    ).then((confirmed) async {
      if (confirmed != true || !mounted) return;

      setState(() => _isUpdatingRole = true);

      final result = await widget.cycleCtrl.updateMemberRole(
        targetUserId: _userId!,
        newRole: newRole,
      );

      if (!mounted) return;
      setState(() => _isUpdatingRole = false);

      if (result != null && result['status'] == 'success') {
        _showOverlayToast('تم تغيير الصلاحية بنجاح');
      } else {
        _showOverlayToast(
          result?['message']?.toString() ?? 'فشل تغيير الصلاحية',
          isError: true,
        );
      }
    });
  }

  void _confirmRemove() {
    if (_userId == null) return;
    showDialog<void>(
      context: Get.context!,
      builder: (ctx) => AlertDialog(
        title: const Text('إزالة عضو'),
        content: Text('هل أنت متأكد من إزالة $_memberName من الدورة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final result =
                  await widget.cycleCtrl.removeMemberDirect(_userId!);
              final isSuccess = result['status'] == 'success';
              _showOverlayToast(
                result['message']?.toString() ??
                    (isSuccess ? 'تم حذف العضو' : 'فشل حذف العضو'),
                isError: !isSuccess,
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('إزالة'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isMemberOwner = _memberRole == 'owner';
    final bool isAdmin = _memberRole == 'admin';
    final bool canEdit =
        widget.isOwner && !widget.isCurrentUser && !isMemberOwner;

    IconData avatarIcon;
    Color avatarBg;
    Color avatarIconColor;
    if (isMemberOwner) {
      avatarIcon = Icons.workspace_premium_rounded;
      avatarBg = Colors.amber.withValues(alpha: 0.15);
      avatarIconColor = Colors.amber.shade700;
    } else if (isAdmin) {
      avatarIcon = Icons.manage_accounts_rounded;
      avatarBg = AppColors.primaryColor.withValues(alpha: 0.15);
      avatarIconColor = AppColors.primaryColor;
    } else {
      avatarIcon = Icons.remove_red_eye_rounded;
      avatarBg = Colors.blueGrey.withValues(alpha: 0.12);
      avatarIconColor = Colors.blueGrey;
    }

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: widget.isDark
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: _isPending
              ? Colors.orange.withValues(alpha: 0.4)
              : isMemberOwner
                  ? Colors.amber.withValues(alpha: 0.3)
                  : (widget.isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.grey.withValues(alpha: 0.15)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: widget.isDark ? 0.15 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---- Row 1: Avatar + name + badges ----
          Row(
            children: [
              CircleAvatar(
                radius: 20.r,
                backgroundColor: avatarBg,
                child: Icon(avatarIcon, color: avatarIconColor, size: 20.sp),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            _memberName,
                            style: TextStyle(
                              color: widget.isDark
                                  ? Colors.white
                                  : Colors.black87,
                              fontSize: 13.sp,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (widget.isCurrentUser) ...[
                          SizedBox(width: 5.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 6.w, vertical: 1.h),
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor
                                  .withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6.r),
                              border: Border.all(
                                  color: AppColors.primaryColor
                                      .withValues(alpha: 0.4)),
                            ),
                            child: Text(
                              'أنت',
                              style: TextStyle(
                                fontSize: 9.sp,
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (_memberPhone.isNotEmpty)
                      Text(
                        _memberPhone,
                        style: TextStyle(
                          color: widget.isDark
                              ? Colors.white54
                              : Colors.black45,
                          fontSize: 11.sp,
                        ),
                        textDirection: ui.TextDirection.ltr,
                      ),
                  ],
                ),
              ),
              if (_isPending)
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                        color: Colors.orange.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    'في انتظار القبول',
                    style: TextStyle(
                        fontSize: 10.sp,
                        color: Colors.orange,
                        fontWeight: FontWeight.w600),
                  ),
                )
              else if (isMemberOwner)
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                        color: Colors.amber.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    'صاحب الدورة',
                    style: TextStyle(
                        fontSize: 10.sp,
                        color: Colors.amber.shade700,
                        fontWeight: FontWeight.w600),
                  ),
                )
              else if (isAdmin)
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                        color: AppColors.primaryColor.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    'مشرف',
                    style: TextStyle(
                        fontSize: 10.sp,
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w600),
                  ),
                )
              else
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                        color: Colors.blueGrey.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    'متابع',
                    style: TextStyle(
                        fontSize: 10.sp,
                        color: Colors.blueGrey,
                        fontWeight: FontWeight.w600),
                  ),
                ),
            ],
          ),

          // ---- Row 2: Role toggle + remove (owner only, on non-owners) ----
          if (!_isPending && canEdit) ...[
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: _isUpdatingRole
                      ? Center(
                          child: SizedBox(
                            height: 20.h,
                            width: 20.h,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        )
                      : Row(
                          children: [
                            _RoleChip(
                              label: 'مشرف',
                              role: 'admin',
                              currentRole: _memberRole,
                              isDark: widget.isDark,
                              icon: Icons.manage_accounts_rounded,
                              onTap: () => _changeRole('admin'),
                            ),
                            SizedBox(width: 6.w),
                            _RoleChip(
                              label: 'متابع',
                              role: 'viewer',
                              currentRole: _memberRole,
                              isDark: widget.isDark,
                              icon: Icons.remove_red_eye_rounded,
                              onTap: () => _changeRole('viewer'),
                            ),
                          ],
                        ),
                ),
                SizedBox(width: 8.w),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                        color: Colors.red.withValues(alpha: 0.2)),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.person_remove_rounded,
                        color: Colors.red, size: 18.sp),
                    onPressed: _isRemoving ? null : _confirmRemove,
                    tooltip: 'إزالة العضو',
                    padding: EdgeInsets.all(6.w),
                    constraints: const BoxConstraints(),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ============================================================
// Chip لاختيار الدور
// ============================================================
class _RoleChip extends StatelessWidget {
  final String label;
  final String role;
  final String currentRole;
  final bool isDark;
  final IconData icon;
  final VoidCallback onTap;

  const _RoleChip({
    required this.label,
    required this.role,
    required this.currentRole,
    required this.isDark,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSelected = currentRole == role;
    return GestureDetector(
      onTap: isSelected ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryColor.withValues(alpha: 0.12)
              : (isDark
                  ? Colors.white.withValues(alpha: 0.04)
                  : Colors.grey[50]),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryColor
                : (isDark ? Colors.white24 : Colors.grey.shade300),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 14.sp,
                color: isSelected
                    ? AppColors.primaryColor
                    : (isDark ? Colors.white38 : Colors.grey[500])),
            SizedBox(width: 4.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight:
                    isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? AppColors.primaryColor
                    : (isDark ? Colors.white54 : Colors.grey[600]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// Tab 2: إضافة عضو جديد
// ============================================================
class _AddMemberTab extends StatelessWidget {
  final bool isDark;
  final bool isOwner;
  final TextEditingController phoneController;
  final bool isSearching;
  final bool isAddingMember;
  final bool isLoadingInvitation;
  final String selectedRole;
  final Map<String, dynamic>? selectedUser;
  final String? resultMessage;
  final bool isResultError;
  final String? invitationCode;
  final String? invitationLink;
  final VoidCallback onSearch;
  final VoidCallback onPickContact;
  final ValueChanged<String> onRoleChanged;
  final VoidCallback onAdd;
  final VoidCallback onGenerateInvitation;
  final VoidCallback onCopyLink;

  const _AddMemberTab({
    required this.isDark,
    required this.isOwner,
    required this.phoneController,
    required this.isSearching,
    required this.isAddingMember,
    required this.isLoadingInvitation,
    required this.selectedRole,
    required this.selectedUser,
    required this.resultMessage,
    required this.isResultError,
    required this.invitationCode,
    required this.invitationLink,
    required this.onSearch,
    required this.onPickContact,
    required this.onRoleChanged,
    required this.onAdd,
    required this.onGenerateInvitation,
    required this.onCopyLink,
  });

  @override
  Widget build(BuildContext context) {
    if (!isOwner) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'أدخل رقم هاتف المستخدم المسجل في التطبيق',
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black54,
              fontSize: 12.sp,
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  maxLength: 11,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 15.sp,
                    letterSpacing: 2,
                  ),
                  decoration: InputDecoration(
                    hintText: '01xxxxxxxxx',
                    counterText: '',
                    prefixIcon: Icon(Icons.phone_android_rounded,
                        color: AppColors.primaryColor, size: 20.sp),
                    filled: true,
                    fillColor: isDark ? Colors.black12 : Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(
                          color: AppColors.primaryColor.withValues(alpha: 0.3)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(
                          color: AppColors.primaryColor.withValues(alpha: 0.1)),
                    ),
                  ),
                  onChanged: (val) {
                    if (val.length == 11) onSearch();
                  },
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: IconButton(
                  icon: Icon(Icons.contacts_rounded,
                      color: AppColors.primaryColor, size: 22.sp),
                  onPressed: onPickContact,
                ),
              ),
            ],
          ),

          if (isSearching)
            Padding(
              padding: EdgeInsets.all(20.h),
              child: const Center(
                  child: CircularProgressIndicator(
                      color: AppColors.primaryColor)),
            ),

          if (resultMessage != null) ...[
            SizedBox(height: 12.h),
            Container(
              padding:
                  EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: isResultError
                    ? Colors.red.withValues(alpha: 0.1)
                    : Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  Icon(
                    isResultError
                        ? Icons.error_outline
                        : Icons.check_circle_outline,
                    color: isResultError ? Colors.red : Colors.green,
                    size: 18.sp,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      resultMessage!,
                      style: TextStyle(
                        color: isResultError ? Colors.red : Colors.green,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          if (selectedUser != null && !isSearching) ...[
            SizedBox(height: 20.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.03)
                    : Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                    color: AppColors.primaryColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22.r,
                    backgroundColor: AppColors.primaryColor,
                    child: Icon(Icons.person,
                        color: Colors.white, size: 24.sp),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selectedUser!['name']?.toString() ?? 'بدون اسم',
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          selectedUser!['phone']?.toString() ?? '',
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.black54,
                            fontSize: 12.sp,
                          ),
                          textDirection: ui.TextDirection.ltr,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'اختر الصلاحية للمستخدم',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Expanded(
                  child: _RoleButton(
                    label: 'مشرف',
                    role: 'admin',
                    selectedRole: selectedRole,
                    isDark: isDark,
                    icon: Icons.manage_accounts_rounded,
                    onTap: () => onRoleChanged('admin'),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: _RoleButton(
                    label: 'متابع',
                    role: 'viewer',
                    selectedRole: selectedRole,
                    isDark: isDark,
                    icon: Icons.remove_red_eye_rounded,
                    onTap: () => onRoleChanged('viewer'),
                  ),
                ),
              ],
            ),
          ],

          // رابط الدعوة — يظهر دائماً إذا لم يكن هناك مستخدم مختار
          if (selectedUser == null && !isSearching) ...[
            SizedBox(height: 12.h),
            if (invitationCode == null)
              OutlinedButton.icon(
                onPressed: isLoadingInvitation ? null : onGenerateInvitation,
                icon: isLoadingInvitation
                    ? SizedBox(
                        width: 14.w,
                        height: 14.w,
                        child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primaryColor))
                    : Icon(Icons.link_rounded,
                        size: 18.sp, color: AppColors.primaryColor),
                label: Text(
                  isLoadingInvitation ? 'جاري التحميل...' : 'إنشاء رابط دعوة',
                  style: TextStyle(
                      color: AppColors.primaryColor, fontSize: 13.sp),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                      color: AppColors.primaryColor.withValues(alpha: 0.5)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r)),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                ),
              )
            else
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: 14.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                      color: Colors.green.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_rounded,
                        color: Colors.green, size: 18.sp),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'تم إنشاء رابط الدعوة',
                        style: TextStyle(
                            color: Colors.green.shade700,
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: onCopyLink,
                      icon: Icon(Icons.copy_rounded,
                          size: 15.sp, color: Colors.green.shade600),
                      label: Text(
                        'نسخ',
                        style: TextStyle(
                            color: Colors.green.shade600, fontSize: 11.sp),
                      ),
                      style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 6.w)),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}

// ============================================================
// زر الدور في تبويب الإضافة
// ============================================================
class _RoleButton extends StatelessWidget {
  final String label;
  final String role;
  final String selectedRole;
  final bool isDark;
  final IconData icon;
  final VoidCallback onTap;

  const _RoleButton({
    required this.label,
    required this.role,
    required this.selectedRole,
    required this.isDark,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSelected = selectedRole == role;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryColor.withValues(alpha: 0.1)
              : (isDark ? Colors.white.withValues(alpha: 0.03) : Colors.white),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryColor
                : (isDark ? Colors.white24 : Colors.grey[300]!),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 18.sp,
                color: isSelected
                    ? AppColors.primaryColor
                    : (isDark ? Colors.white54 : Colors.grey[500])),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? AppColors.primaryColor
                    : (isDark ? Colors.white70 : Colors.grey[600]),
              ),
            )
          ],
        ),
      ),
    );
  }
}

// ============================================================
// Contact Picker Dialog
// ============================================================
class _ContactPickerDialog extends StatefulWidget {
  final bool isDark;

  const _ContactPickerDialog({required this.isDark});

  @override
  State<_ContactPickerDialog> createState() => _ContactPickerDialogState();
}

class _ContactPickerDialogState extends State<_ContactPickerDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<Contact> _allContacts = [];
  List<Contact> _filtered = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    try {
      final contacts = await FlutterContacts.getContacts(
        withProperties: true,
      );
      final withPhones = contacts.where((c) => c.phones.isNotEmpty).toList();
      if (mounted) {
        setState(() {
          _allContacts = withPhones;
          _filtered = withPhones;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filter(String query) {
    setState(() {
      if (query.isEmpty) {
        _filtered = _allContacts;
      } else {
        _filtered = _allContacts.where((c) {
          final name = c.displayName.toLowerCase();
          final phone = c.phones.first.number;
          return name.contains(query.toLowerCase()) || phone.contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: widget.isDark
          ? AppColors.darkSurfaceColor
          : AppColors.lightSurfaceColor,
      title: Text(
        'اختر جهة اتصال',
        style: TextStyle(
            color: widget.isDark ? Colors.white : Colors.black87,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: 400.h,
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              onChanged: _filter,
              style: TextStyle(
                  color: widget.isDark ? Colors.white : Colors.black87),
              decoration: InputDecoration(
                hintText: 'بحث...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: widget.isDark ? Colors.black12 : Colors.white,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: BorderSide.none),
              ),
            ),
            SizedBox(height: 12.h),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filtered.isEmpty
                      ? Center(
                          child: Text('لا توجد نتائج',
                              style: TextStyle(
                                  color: widget.isDark
                                      ? Colors.white54
                                      : Colors.black54)))
                      : ListView.separated(
                          itemCount: _filtered.length,
                          separatorBuilder: (ctx, i) => Divider(
                              height: 1,
                              color: widget.isDark
                                  ? Colors.white10
                                  : Colors.black12),
                          itemBuilder: (ctx, i) {
                            final c = _filtered[i];
                            return ListTile(
                              title: Text(c.displayName,
                                  style: TextStyle(
                                      color: widget.isDark
                                          ? Colors.white
                                          : Colors.black87,
                                      fontSize: 14.sp)),
                              subtitle: Text(c.phones.first.number,
                                  style: TextStyle(
                                      color: widget.isDark
                                          ? Colors.white54
                                          : Colors.black54,
                                      fontSize: 12.sp),
                                  textDirection: ui.TextDirection.ltr),
                              onTap: () => Navigator.of(context).pop(c),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('إلغاء'),
        ),
      ],
    );
  }
}
