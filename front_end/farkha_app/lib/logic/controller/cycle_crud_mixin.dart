import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../core/class/status_request.dart';
import '../../core/constant/routes/route.dart';
import '../../core/constant/storage_keys.dart';
import '../../core/services/notification_service.dart';
import 'cycle_controller_base.dart';

mixin CycleCrudMixin on CycleControllerBase {
  Future<void> onNext() async {
    if (cycleSaveStatus.value == StatusRequest.loading) return;
    if (!formKey.currentState!.validate()) return;

    final name = nameController.text.trim();
    final chickCount = int.tryParse(countController.text.trim()) ?? 0;
    final space = double.tryParse(spaceController.text.trim()) ?? 0.0;
    const breed = 'تسمين';
    const systemType = 'أرضي';
    final startDateRaw = dateRawController.text.trim();
    final startDate = dateController.text.trim();

    final entry = {
      'name': name,
      'chickCount': countController.text.trim(),
      'space': spaceController.text.trim(),
      'breed': breed,
      'systemType': systemType,
      'startDate': startDate,
      'startDateRaw': startDateRaw,
      'mortalityEntries': <Map<String, dynamic>>[],
      'mortality': '0',
      'role': 'owner',
    };

    if (isEdit.value &&
        editIndex.value >= 0 &&
        editIndex.value < cycles.length) {
      final existing = Map<String, dynamic>.from(cycles[editIndex.value]);
      existing['name'] = name;
      existing['chickCount'] = countController.text.trim();
      existing['chick_count'] = chickCount;
      existing['space'] = spaceController.text.trim();
      existing['breed'] = breed;
      existing['systemType'] = systemType;
      existing['startDate'] = startDate;
      existing['startDateRaw'] = startDateRaw;

      final cycleId = existing['cycle_id'];

      if (cycleId != null) {
        cycleSaveStatus.value = StatusRequest.loading;
        isCreatingCycle.value = true;

        try {
          final user = auth;
          final firebaseUser = user.currentUser;
          if (firebaseUser == null) {
            isCreatingCycle.value = false;
            cycleSaveStatus.value = StatusRequest.failure;
            return;
          }

          final token = await firebaseUser.getIdToken();
          if (token == null || token.isEmpty) {
            isCreatingCycle.value = false;
            cycleSaveStatus.value = StatusRequest.failure;
            return;
          }

          final response = await cycleData.updateCycle(
            token: token,
            cycleId: cycleId is int
                ? cycleId
                : int.tryParse(cycleId.toString()) ?? 0,
            name: name,
            chickCount: chickCount,
            space: space,
            breed: breed,
            systemType: systemType,
            startDateRaw: startDateRaw,
          );

          response.fold(
            (failure) {
              cycleSaveStatus.value = failure == StatusRequest.offlineFailure
                  ? StatusRequest.offlineFailure
                  : StatusRequest.serverFailure;
            },
            (result) {
              cycleSaveStatus.value = StatusRequest.success;
            },
          );
        } catch (_) {
          cycleSaveStatus.value = StatusRequest.serverFailure;
        }

        isCreatingCycle.value = false;
      }

      cycles[editIndex.value] = existing;
      currentCycle.assignAll(existing);
      cycleDataVersion.value++;
      isEdit.value = false;
      editIndex.value = -1;

      _scheduleNotificationsForCycleData(existing);

      await myServices.getStorage.write(StorageKeys.cycles, cycles.toList());
      clearFields();

      Future.delayed(const Duration(milliseconds: 500), () {
        if (cycleSaveStatus.value == StatusRequest.success) {
          cycleSaveStatus.value = StatusRequest.none;
        }
      });

      Get.back<void>();
      return;
    }

    if (isEdit.value) {
      isEdit.value = false;
      editIndex.value = -1;
    }

    final existingCycle = cycles.indexWhere((c) => c['name'] == name);
    if (existingCycle == -1) {
      deleteCycleRelatedData(name);
    }

    isCreatingCycle.value = true;
    cycleSaveStatus.value = StatusRequest.loading;

    try {
      final isLoggedIn =
          myServices.getStorage.read<bool>(StorageKeys.isLoggedIn) ?? false;
      if (!isLoggedIn) {
        cycles.add(entry);
        await myServices.getStorage.write(StorageKeys.cycles, cycles.toList());
        clearFields();
        cycleSaveStatus.value = StatusRequest.none;
        isCreatingCycle.value = false;

        final newIndex = cycles.length - 1;
        final shouldShowTutorial = cycles.length == 2;

        unawaited(
          Get.offNamedUntil(
            AppRoute.cycle,
            ModalRoute.withName('/'),
            arguments: {'index': newIndex, 'showTutorial': shouldShowTutorial},
          ),
        );
        return;
      }

      final user = auth.currentUser;
      if (user == null) {
        isCreatingCycle.value = false;
        cycleSaveStatus.value = StatusRequest.failure;
        return;
      }

      final token = await user.getIdToken();
      if (token == null || token.isEmpty) {
        isCreatingCycle.value = false;
        cycleSaveStatus.value = StatusRequest.failure;
        return;
      }

      final response = await cycleData.createCycle(
        token: token,
        name: name,
        chickCount: chickCount,
        space: space,
        breed: breed,
        systemType: systemType,
        startDateRaw: startDateRaw,
      );

      response.fold(
        (failure) {
          cycles.add(entry);
          myServices.getStorage.write(StorageKeys.cycles, cycles.toList());
          if (failure == StatusRequest.offlineFailure) {
            cycleSaveStatus.value = StatusRequest.offlineFailure;
          } else if (failure == StatusRequest.serverFailure) {
            cycleSaveStatus.value = StatusRequest.serverFailure;
          } else {
            cycleSaveStatus.value = StatusRequest.failure;
          }
        },
        (Map<String, dynamic> result) {
          final data = result;
          final isSuccess = data['status'] == 'success';

          if (isSuccess && data['data'] != null) {
            final cycleApiData = data['data'] as Map<String, dynamic>;
            final apiCycleId = cycleApiData['cycle_id'];

            if (apiCycleId is int) {
              entry['cycle_id'] = apiCycleId;
            } else if (apiCycleId is String) {
              final parsedId = int.tryParse(apiCycleId);
              if (parsedId != null) {
                entry['cycle_id'] = parsedId;
              }
            }
          }

          cycles.add(entry);
          myServices.getStorage.write(StorageKeys.cycles, cycles.toList());
          cycleSaveStatus.value = StatusRequest.success;

          _scheduleNotificationsForCycleData(entry);
        },
      );
      clearFields();
      isCreatingCycle.value = false;

      Future.delayed(const Duration(milliseconds: 500), () {
        if (cycleSaveStatus.value == StatusRequest.success) {
          cycleSaveStatus.value = StatusRequest.none;
        }
      });

      final newIndex = cycles.length - 1;
      final shouldShowTutorial = cycles.length == 2;

      unawaited(
        Get.offNamedUntil<void>(
          AppRoute.cycle,
          ModalRoute.withName('/'),
          arguments: {'index': newIndex, 'showTutorial': shouldShowTutorial},
        ),
      );
    } catch (e) {
      cycles.add(entry);
      await myServices.getStorage.write(StorageKeys.cycles, cycles.toList());
      isCreatingCycle.value = false;
      cycleSaveStatus.value = StatusRequest.serverFailure;
      clearFields();

      final newIndex = cycles.length - 1;
      final shouldShowTutorial = cycles.length == 2;

      unawaited(
        Get.offNamedUntil<void>(
          AppRoute.cycle,
          ModalRoute.withName('/'),
          arguments: {'index': newIndex, 'showTutorial': shouldShowTutorial},
        ),
      );
    } finally {
      isCreatingCycle.value = false;
    }
  }

  void clearFields() {
    nameController.clear();
    countController.clear();
    spaceController.clear();
    dateController.clear();
    dateRawController.clear();
    formKey.currentState?.reset();
  }

  Future<bool> deleteCurrentCycle() async {
    final idx = cycles.indexWhere((c) => c['name'] == currentCycle['name']);
    if (idx == -1) return false;

    cycleDeleteStatus.value = StatusRequest.loading;

    try {
      final cycleId = currentCycle['cycle_id'];
      final cycleName = currentCycle['name']?.toString();

      final cycleIdInt = cycleId is int
          ? cycleId
          : (cycleId != null ? int.tryParse(cycleId.toString()) : null);
      final hasServerCycle = cycleIdInt != null && cycleIdInt > 0;

      debugPrint(
        '[deleteCycle] cycleName=$cycleName, cycleIdRaw=$cycleId, '
        'cycleIdInt=$cycleIdInt, hasServerCycle=$hasServerCycle',
      );

      if (hasServerCycle) {
        final isLoggedIn =
            myServices.getStorage.read<bool>(StorageKeys.isLoggedIn) ?? false;
        debugPrint('[deleteCycle] isLoggedIn=$isLoggedIn');
        if (!isLoggedIn) {
          debugPrint('[deleteCycle] FAIL: not logged in');
          cycleDeleteStatus.value = StatusRequest.failure;
          Future.delayed(const Duration(milliseconds: 2000), () {
            if (cycleDeleteStatus.value == StatusRequest.failure) {
              cycleDeleteStatus.value = StatusRequest.none;
            }
          });
          return false;
        }

        final user = auth.currentUser;
        debugPrint('[deleteCycle] firebaseUser=${user?.uid}');
        if (user == null) {
          debugPrint('[deleteCycle] FAIL: no firebase user');
          cycleDeleteStatus.value = StatusRequest.failure;
          Future.delayed(const Duration(milliseconds: 2000), () {
            if (cycleDeleteStatus.value == StatusRequest.failure) {
              cycleDeleteStatus.value = StatusRequest.none;
            }
          });
          return false;
        }

        final token = await user.getIdToken();
        debugPrint(
          '[deleteCycle] tokenEmpty=${token == null || token.isEmpty}',
        );
        if (token == null || token.isEmpty) {
          debugPrint('[deleteCycle] FAIL: empty token');
          cycleDeleteStatus.value = StatusRequest.failure;
          Future.delayed(const Duration(milliseconds: 2000), () {
            if (cycleDeleteStatus.value == StatusRequest.failure) {
              cycleDeleteStatus.value = StatusRequest.none;
            }
          });
          return false;
        }

        debugPrint('[deleteCycle] calling API with cycleId=$cycleIdInt');
        final result = await cycleData.deleteCycle(
          token: token,
          cycleId: cycleIdInt,
        );

        StatusRequest? failureStatus;
        result.fold(
          (failure) {
            debugPrint('[deleteCycle] API LEFT failure=$failure');
            failureStatus = failure;
          },
          (response) {
            debugPrint('[deleteCycle] API RIGHT response=$response');
            if (response['status'] != 'success') {
              failureStatus = StatusRequest.serverFailure;
            }
          },
        );

        if (failureStatus != null) {
          debugPrint('[deleteCycle] FAIL: API failed -> $failureStatus');
          cycleDeleteStatus.value = failureStatus!;
          Future.delayed(const Duration(milliseconds: 2000), () {
            if (cycleDeleteStatus.value == failureStatus) {
              cycleDeleteStatus.value = StatusRequest.none;
            }
          });
          return false;
        }
        debugPrint('[deleteCycle] API success, proceeding to local delete');
      }

      if (cycleName != null && cycleName.isNotEmpty) {
        deleteCycleRelatedData(cycleName);

        final deletedCycles =
            myServices.getStorage.read<List<dynamic>>(
              StorageKeys.deletedCycles,
            ) ??
            <dynamic>[];
        if (!deletedCycles.contains(cycleName)) {
          deletedCycles.add(cycleName);
          unawaited(
            myServices.getStorage.write(
              StorageKeys.deletedCycles,
              deletedCycles,
            ),
          );
        }
      }

      await NotificationService.instance.cancelCycleNotifications();

      cycles.removeAt(idx);
      await myServices.getStorage.write(StorageKeys.cycles, cycles.toList());

      if (cycles.isNotEmpty) {
        currentCycle.assignAll(cycles.last);
      } else {
        currentCycle.clear();
      }

      cycleDeleteStatus.value = StatusRequest.success;
      Future.delayed(const Duration(milliseconds: 500), () {
        if (cycleDeleteStatus.value == StatusRequest.success) {
          cycleDeleteStatus.value = StatusRequest.none;
        }
      });

      return cycles.isEmpty;
    } catch (e) {
      cycleDeleteStatus.value = StatusRequest.failure;
      Future.delayed(const Duration(milliseconds: 2000), () {
        if (cycleDeleteStatus.value == StatusRequest.failure) {
          cycleDeleteStatus.value = StatusRequest.none;
        }
      });
      return false;
    }
  }

  void prepareForEdit(Map<String, dynamic> data, int index) {
    isEdit.value = true;
    editIndex.value = index;
    nameController.text = (data['name'] ?? '').toString();
    countController.text =
        (data['chickCount'] ?? data['chick_count'] ?? '').toString();
    spaceController.text = (data['space'] ?? '').toString();
    dateController.text = (data['startDate'] ?? '').toString();
    dateRawController.text = (data['startDateRaw'] ?? '').toString();
  }

  String ageOf(String isoDate) {
    if (isoDate.isEmpty) return '';
    final start = DateTime.tryParse(isoDate);
    if (start == null) return '';
    final now = DateTime.now();
    if (now.isBefore(start)) return 'لم تبدأ';
    final days = now.difference(start).inDays + 1;
    return '$days';
  }

  Future<void> pickDate(BuildContext context) async {
    final now = DateTime.now();
    final firstAllowedDate = now.subtract(const Duration(days: 39));
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: firstAllowedDate,
      lastDate: DateTime(now.year + 1),
      locale: const Locale('ar'),
    );
    if (picked != null) {
      dateRawController.text = DateFormat('yyyy-MM-dd').format(picked);
      final formatted = DateFormat('MM-dd', 'en').format(picked);
      final dayName = DateFormat('EEEE', 'ar').format(picked);
      dateController.text = '$formatted ($dayName)';
    }
  }

  void _scheduleNotificationsForCycleData(Map<String, dynamic> data) {
    if (data['startDateRaw'] != null) {
      final date = DateTime.tryParse(data['startDateRaw'].toString());
      if (date != null) {
        final rawCycleId = data['cycle_id'];
        final cycleIdInt = rawCycleId is int
            ? rawCycleId
            : int.tryParse(rawCycleId?.toString() ?? '');
        NotificationService.instance.scheduleCycleNotifications(
          date,
          data['name']?.toString() ?? '',
          cycleIdInt,
        );
      }
    }
  }
}
