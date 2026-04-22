import 'dart:async';

import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../core/class/status_request.dart';
import '../../../data/data_source/remote/app_review_data.dart';
import '../../../data/model/app_review_model.dart';
import 'review_prompt_controller.dart';

class AppReviewController extends GetxController {
  final AppReviewData _appReviewData;
  final FirebaseAuth _auth;

  AppReviewController(this._appReviewData, {FirebaseAuth? auth})
      : _auth = auth ?? FirebaseAuth.instance;

  int rating = 0;
  TextEditingController issueController = TextEditingController();
  TextEditingController suggestionController = TextEditingController();
  StatusRequest statusRequest = StatusRequest.none;
  bool isSubmitting = false;
  String? validationError;
  AppReviewModel? existingReview;

  String? _appVersion;
  final String _platform = Platform.isAndroid ? 'android' : 'ios';

  @override
  void onInit() {
    super.onInit();
    try {
      _loadAppVersion();
    } catch (_) {}
    try {
      fetchMyReview();
    } catch (_) {}
  }

  Future<void> _loadAppVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      _appVersion = '${info.version}+${info.buildNumber}';
    } catch (_) {}
  }

  Future<void> fetchMyReview() async {
    final user = _auth.currentUser;
    if (user == null) return;

    statusRequest = StatusRequest.loading;
    update();

    try {
      final token = await user.getIdToken();
      final response = await _appReviewData.fetchMine(token: token!);

      if (response is Map<String, dynamic>) {
        final reviewData = response['data']?['review'];
        if (reviewData != null && reviewData is Map<String, dynamic>) {
          existingReview = AppReviewModel.fromJson(reviewData);
          rating = existingReview!.rating;
          if (existingReview!.issue != null) {
            issueController.text = existingReview!.issue!;
          }
          if (existingReview!.suggestion != null) {
            suggestionController.text = existingReview!.suggestion!;
          }
        }
        statusRequest = StatusRequest.success;
      } else if (response is StatusRequest) {
        statusRequest = response;
      }
    } catch (e, stack) {
      try {
        unawaited(FirebaseCrashlytics.instance.recordError(e, stack));
      } catch (_) {}
      statusRequest = StatusRequest.serverFailure;
    }
    update();
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
    if (rating == 0) {
      validationError = 'اختيار عدد النجوم مطلوب';
      update();
      return;
    }
    validationError = null;

    if (isSubmitting) return;
    isSubmitting = true;
    statusRequest = StatusRequest.loading;
    update();

    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final token = await user.getIdToken();
      final response = await _appReviewData.upsert(
        token: token!,
        rating: rating,
        issue: issueController.text.trim().isEmpty ? null : issueController.text.trim(),
        suggestion: suggestionController.text.trim().isEmpty ? null : suggestionController.text.trim(),
        appVersion: _appVersion,
        platform: _platform,
      );

      if (response is Map<String, dynamic> && response['status'] == 'success') {
        statusRequest = StatusRequest.success;
        isSubmitting = false;
        update();
        try {
          Get.find<ReviewPromptController>().markRated();
        } catch (_) {}
        _showSnackbar('شكراً', 'شكراً لتقييمك');
        Future.delayed(const Duration(milliseconds: 1500), () {
          Get.back<void>();
        });
      } else if (response is StatusRequest) {
        statusRequest = response;
        isSubmitting = false;
        if (response == StatusRequest.offlineFailure) {
          _showSnackbar('خطأ', 'تعذّر إرسال التقييم، تحقّق من الاتصال');
        } else {
          _showSnackbar('خطأ', 'حدث خطأ أثناء إرسال التقييم');
        }
        update();
      }
    } catch (e, stack) {
      try {
        unawaited(FirebaseCrashlytics.instance.recordError(e, stack));
      } catch (_) {}
      statusRequest = StatusRequest.serverFailure;
      isSubmitting = false;
      _showSnackbar('خطأ', 'حدث خطأ أثناء إرسال التقييم');
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
