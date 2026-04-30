import 'dart:async';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../core/constant/strings/app_strings.dart';
import '../../../core/class/status_request.dart';
import '../../../data/data_source/remote/app_review_data.dart';
import 'review_prompt_controller.dart';

class AppReviewController extends GetxController {
  final AppReviewData _appReviewData;

  AppReviewController(this._appReviewData);

  int rating = 0;
  TextEditingController issueController = TextEditingController();
  TextEditingController suggestionController = TextEditingController();
  bool isSubmitting = false;
  bool isSubmitted = false;
  String? validationError;

  String? _appVersion;
  final String _platform = Platform.isAndroid ? 'android' : 'ios';

  @override
  void onInit() {
    super.onInit();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      _appVersion = info.version;
    } catch (_) {}
  }

  void setRating(int value) {
    rating = value;
    update();
  }

  void _showSnackbar(String title, String message) {
    if (Get.testMode) return;
    try {
      Get.snackbar(title, message, snackPosition: SnackPosition.BOTTOM);
    } catch (_) {}
  }

  Future<void> submit() async {
    final hasIssue = issueController.text.trim().isNotEmpty;
    final hasSuggestion = suggestionController.text.trim().isNotEmpty;

    if (rating == 0 && !hasIssue && !hasSuggestion) {
      validationError = 'اختار نجوم أو اكتب مشكلة أو اقتراح';
      update();
      return;
    }
    validationError = null;

    if (isSubmitting) return;
    isSubmitting = true;
    update();

    try {
      final Either<StatusRequest, Map<String, dynamic>> result =
          await _appReviewData.submit(
        rating: rating,
        issue: issueController.text.trim().isEmpty
            ? null
            : issueController.text.trim(),
        suggestion: suggestionController.text.trim().isEmpty
            ? null
            : suggestionController.text.trim(),
        appVersion: _appVersion,
        platform: _platform,
      );

      result.fold(
        (failure) {
          isSubmitting = false;
          if (failure == StatusRequest.offlineFailure) {
            _showSnackbar(AppStrings.error, 'تعذّر إرسال التقييم، تحقّق من الاتصال');
          } else {
            _showSnackbar(AppStrings.error, 'حدث خطأ أثناء إرسال التقييم');
          }
          update();
        },
        (response) {
          isSubmitting = false;
          isSubmitted = true;
          update();
          if (Get.isRegistered<ReviewPromptController>()) {
            Get.find<ReviewPromptController>().markRated();
          }
        },
      );
    } catch (e, stack) {
      try {
        unawaited(FirebaseCrashlytics.instance.recordError(e, stack));
      } catch (_) {}
      isSubmitting = false;
      _showSnackbar(AppStrings.error, 'حدث خطأ أثناء إرسال التقييم');
      update();
    }
  }

  @override
  void onClose() {
    issueController.dispose();
    suggestionController.dispose();
    super.onClose();
  }
}
