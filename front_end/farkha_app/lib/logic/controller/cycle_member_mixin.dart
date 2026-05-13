import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/class/status_request.dart';
import '../../core/constant/routes/route.dart';
import '../../core/constant/storage_keys.dart';
import '../../core/constant/strings/app_strings.dart';
import '../../core/services/initialization.dart';
import '../../data/data_source/remote/cycle_data/cycle_member_data.dart';
import 'cycle_controller_base.dart';
import 'cycle_member_helpers.dart';

mixin CycleMemberMixin on CycleControllerBase {
  late final CycleMemberData _memberData = CycleMemberData();

  final RxList<Map<String, dynamic>> invitations = <Map<String, dynamic>>[].obs;
  final Rx<StatusRequest> invitationsStatus = StatusRequest.none.obs;
  final Rx<StatusRequest> invitationResponseStatus = StatusRequest.none.obs;
  final Rx<StatusRequest> cycleLeaveStatus = StatusRequest.none.obs;

  Future<Map<String, dynamic>?> addMember({
    required int cycleId,
    required String phone,
    String role = 'member',
  }) async {
    try {
      final token = await requireAuthToken(auth);
      if (token == null) return null;

      final response = await _memberData.addMember(
        token: token,
        cycleId: cycleId,
        phone: phone,
        role: role,
      );

      return response.fold(
        (failure) => {'status': 'fail', 'message': 'فشل الاتصال بالسيرفر'},
        (result) => result,
      );
    } catch (e) {
      return {'status': 'fail', 'message': 'حدث خطأ: $e'};
    }
  }

  Future<Map<String, dynamic>?> addMemberByPhone(
    String phone, {
    int? cycleId,
    String role = 'member',
  }) async {
    final effectiveCycleId = cycleId ?? resolveCycleId(currentCycle);

    if (effectiveCycleId == null) {
      return {'status': 'fail', 'message': 'لا توجد دورة محددة'};
    }

    final result = await addMember(
      cycleId: effectiveCycleId,
      phone: phone,
      role: role,
    );
    if (result?['status'] == 'success') {
      await fetchCycleDetails(effectiveCycleId);
    }
    return result;
  }

  Future<void> leaveCycle() async {
    try {
      final cycleId = currentCycle['cycle_id'];
      if (cycleId == null) return;
      final cycleIdInt =
          cycleId is int ? cycleId : int.tryParse(cycleId.toString());if (cycleIdInt == null) return;

      cycleLeaveStatus.value = StatusRequest.loading;
      final token = await requireAuthToken(auth);
      if (token == null) {
        cycleLeaveStatus.value = StatusRequest.failure;
        return;
      }

      final response = await _memberData.leaveCycle(token: token, cycleId: cycleIdInt);

      response.fold(
        (l) => cycleLeaveStatus.value = l,
        (r) {
          if (r['status'] == 'success') {
            cycleLeaveStatus.value = StatusRequest.success;
            isCycleOpen = false;
            fetchCyclesFromServer();
            Get.offAllNamed<void>(AppRoute.home);
            Future.delayed(const Duration(milliseconds: 800), () {
              Get.snackbar('نجاح', 'تمت مغادرة الدورة بنجاح',
                  snackPosition: SnackPosition.BOTTOM);
            });
          } else {
            cycleLeaveStatus.value = StatusRequest.failure;
          }
        },
      );
    } catch (e) {
      cycleLeaveStatus.value = StatusRequest.serverFailure;
    }
  }

  Future<void> removeMember(int targetUserId) async {
    final cycleId = resolveCycleId(currentCycle);
    if (cycleId == null) return;

    unawaited(
      Get.defaultDialog<void>(
        title: 'حذف عضو',
        middleText: 'هل أنت متأكد من حذف هذا العضو من الدورة؟',
        textConfirm: AppStrings.delete,
        textCancel: AppStrings.cancel,
        confirmTextColor: Colors.white,
        buttonColor: Colors.red,
        onConfirm: () async {
          Get.back<void>();
          final token = await requireAuthToken(auth);
          if (token == null) return;

          cycleLeaveStatus.value = StatusRequest.loading;
          update();

          final response = await _memberData.removeMember(
            token: token, cycleId: cycleId, targetUserId: targetUserId,
          );

          response.fold(
            (failure) {
              cycleLeaveStatus.value = StatusRequest.serverFailure;
              update();
              Get.snackbar(AppStrings.error, 'فشل الاتصال بالسيرفر');
            },
            (result) {
              if (result['status'] == 'success') {
                removeMemberFromLocalState(
                  currentCycle: currentCycle,
                  cycles: cycles,
                  targetUserId: targetUserId,
                  cycleId: cycleId,
                );
                Get.snackbar('نجاح', 'تم حذف العضو بنجاح');
              } else {
                Get.snackbar(
                  'تنبيه',
                  (result['message'] ?? 'فشل حذف العضو').toString(),
                );
              }
              cycleLeaveStatus.value = StatusRequest.none;
              update();
            },
          );
        },
      ),
    );
  }

  Future<Map<String, dynamic>> removeMemberDirect(int targetUserId) async {
    final cycleId = resolveCycleId(currentCycle);
    if (cycleId == null) {
      return {'status': 'fail', 'message': 'تعذر تحديد الدورة'};
    }

    final token = await requireAuthToken(auth);
    if (token == null) return {'status': 'fail', 'message': 'غير مسجل'};

    cycleLeaveStatus.value = StatusRequest.loading;
    update();

    final response = await _memberData.removeMember(
      token: token,
      cycleId: cycleId,
      targetUserId: targetUserId,
    );

    return response.fold(
      (failure) {
        cycleLeaveStatus.value = StatusRequest.serverFailure;
        update();
        return {'status': 'fail', 'message': 'فشل الاتصال بالسيرفر'};
      },
      (result) {
        if (result['status'] == 'success') {
          removeMemberFromLocalState(
            currentCycle: currentCycle,
            cycles: cycles,
            targetUserId: targetUserId,
            cycleId: cycleId,
          );
          cycleLeaveStatus.value = StatusRequest.none;
          update();
          return {'status': 'success', 'message': 'تم حذف العضو بنجاح'};
        } else {
          cycleLeaveStatus.value = StatusRequest.none;
          update();
          return {
            'status': 'fail',
            'message': (result['message'] ?? 'فشل حذف العضو').toString(),
          };
        }
      },
    );
  }

  Future<Map<String, dynamic>?> createInvitation(int cycleId) async {
    try {
      final token = await requireAuthToken(auth);
      if (token == null) return null;

      final response = await _memberData.createInvitation(
        token: token,
        cycleId: cycleId,
      );

      return response.fold(
        (failure) => {'status': 'fail', 'message': 'فشل إنشاء رابط الدعوة'},
        (result) => result,
      );
    } catch (e) {
      return {'status': 'fail', 'message': 'حدث خطأ: $e'};
    }
  }

  Future<void> joinByCode(String code) async {
    try {
      final token = await requireAuthToken(auth);
      if (token == null) {
        final myServices = Get.find<MyServices>();
        await myServices.getStorage.write(StorageKeys.pendingJoinCode, code);
        Get.snackbar('تنبيه', 'يجب تسجيل الدخول أولاً للانضمام للدورة',
            snackPosition: SnackPosition.BOTTOM);
        await Future<void>.delayed(const Duration(seconds: 1));
        await Get.toNamed<void>(AppRoute.login);
        return;
      }

      final response = await _memberData.joinByCode(token: token, code: code);

      response.fold(
        (failure) => Get.snackbar(AppStrings.error, 'فشل الاتصال بالسيرفر'),
        (result) {
          if (result['status'] == 'success') {
            Get.snackbar(
              'نجاح',
              result['message']?.toString() ?? 'تم الانضمام بنجاح',
            );
            fetchCyclesFromServer();
          } else {
            Get.snackbar('فشل', result['message']?.toString() ?? 'حدث خطأ');
          }
        },
      );
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back<void>();
      Get.snackbar(AppStrings.error, 'حدث خطأ: $e');
    }
  }

  Future<List<Map<String, dynamic>>?> searchUsers(String searchTerm) async {
    try {
      if (searchTerm.length < 2) return [];
      final token = await requireAuthToken(auth);
      if (token == null) return null;

      final response = await _memberData.searchUsers(
        token: token,
        searchTerm: searchTerm,
      );

      return response.fold((failure) => null, (result) {
        if (result['status'] == 'success') {
          final data = result['data'] as List?;
          if (data != null) return List<Map<String, dynamic>>.from(data);
        }
        return null;
      });
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> updateMemberRole({
    required int targetUserId,
    required String newRole,
  }) async {
    final cycleId = resolveCycleId(currentCycle);
    if (cycleId == null) {
      return {'status': 'fail', 'message': 'لا توجد دورة محددة'};
    }

    try {
      final token = await requireAuthToken(auth);
      if (token == null) return null;

      final response = await _memberData.updateMemberRole(
        token: token,
        cycleId: cycleId,
        targetUserId: targetUserId,
        newRole: newRole,
      );

      return response.fold(
        (failure) => {'status': 'fail', 'message': 'فشل الاتصال بالسيرفر'},
        (result) {
          if (result['status'] == 'success') {
            updateMemberRoleInLocalState(
              currentCycle: currentCycle,
              cycles: cycles,
              targetUserId: targetUserId,
              newRole: newRole,
              cycleId: cycleId,
            );
          }
          return result;
        },
      );
    } catch (e) {
      return {'status': 'fail', 'message': 'حدث خطأ: $e'};
    }
  }

  Future<void> fetchInvitations() async {
    final token = await requireAuthToken(auth);
    if (token == null) {
      invitations.clear();
      return;
    }

    invitationsStatus.value = StatusRequest.loading;

    try {
      final response = await _memberData.getInvitations(token: token);

      response.fold(
        (failure) => invitationsStatus.value = failure,
        (result) {
          if (result['status'] == 'success') {
            final List<dynamic> data = result['data'] as List<dynamic>? ?? [];
            invitations.assignAll(
              data.map((e) => Map<String, dynamic>.from(e as Map)).toList(),
            );
            invitationsStatus.value = StatusRequest.success;
          } else {
            invitationsStatus.value = StatusRequest.failure;
          }
        },
      );
    } catch (e) {
      invitationsStatus.value = StatusRequest.serverFailure;
    }
  }

  Future<Map<String, dynamic>?> respondToInvitation(
    int cycleId,
    String action,
  ) async {
    final token = await requireAuthToken(auth);
    if (token == null) return null;

    invitationResponseStatus.value = StatusRequest.loading;

    try {
      final response = await _memberData.respondToInvitation(
        token: token,
        cycleId: cycleId,
        action: action,
      );

      return response.fold(
        (failure) {
          invitationResponseStatus.value = failure;
          return {'status': 'fail', 'message': 'فشل تنفيذ العملية'};
        },
        (result) {
          if (result['status'] == 'success') {
            invitationResponseStatus.value = StatusRequest.success;
            invitations.removeWhere((inv) => inv['cycle_id'] == cycleId);

            if (action == 'accept') {
              fetchCyclesFromServer();
            }

            return {
              'status': 'success',
              'message':
                  action == 'accept' ? 'تم قبول الدعوة بنجاح' : 'تم رفض الدعوة',
            };
          } else {
            invitationResponseStatus.value = StatusRequest.failure;
            return {
              'status': 'fail',
              'message': (result['message'] ?? 'فشل تنفيذ العملية').toString(),
            };
          }
        },
      );
    } catch (e) {
      invitationResponseStatus.value = StatusRequest.serverFailure;
      return {'status': 'fail', 'message': 'حدث خطأ غير متوقع'};
    }
  }
}
