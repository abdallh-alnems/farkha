import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AutoScrollController extends GetxController {
  late ScrollController _scrollController;

  Timer? _autoScrollTimer;
  Timer? _pauseTimer;
  Timer? _manualScrollTimer;

  final RxBool _isAutoScrolling = true.obs;
  final RxBool _isPaused = false.obs;
  final RxBool _isReversing = false.obs;

  static const Duration _pauseDuration = Duration(seconds: 3);
  static const Duration _manualScrollDelay = Duration(seconds: 5);
  static const Duration _updateInterval = Duration(milliseconds: 16);
  static const Duration _checkInterval = Duration(milliseconds: 100);
  static const double _scrollSpeed = 60.0;
  static const int _maxAttempts = 30;

  bool get isAutoScrolling => _isAutoScrolling.value;
  bool get isPaused => _isPaused.value;
  bool get isReversing => _isReversing.value;
  ScrollController get scrollController => _scrollController;

  @override
  void onInit() {
    super.onInit();
    _initializeControllers();
  }

  void _initializeControllers() {
    _scrollController = ScrollController();
  }

  void _startAutoScroll() {
    if (_isPaused.value) return;

    _autoScrollTimer?.cancel();

    _autoScrollTimer = Timer.periodic(_updateInterval, (timer) {
      if (!_shouldContinueScrolling()) return;

      if (!_isScrollControllerReady()) return;

      _performScroll();
    });
  }

  bool _shouldContinueScrolling() {
    return _isAutoScrolling.value && !_isPaused.value;
  }

  bool _isScrollControllerReady() {
    return _scrollController.hasClients &&
        _scrollController.position.hasContentDimensions &&
        _scrollController.position.maxScrollExtent > 0;
  }

  void _performScroll() {
    final currentOffset = _scrollController.offset;
    final maxScrollExtent = _scrollController.position.maxScrollExtent;

    if (currentOffset >= maxScrollExtent - 1 && !_isReversing.value) {
      _isReversing.value = true;
    } else if (currentOffset <= 1 && _isReversing.value) {
      _isReversing.value = false;
    } else {
      final scrollStep = _scrollSpeed * (_updateInterval.inMilliseconds / 1000);
      final newOffset =
          _isReversing.value
              ? currentOffset - scrollStep
              : currentOffset + scrollStep;
      _scrollController.jumpTo(newOffset);
    }
  }

  void pauseAutoScroll() {
    _isPaused.value = true;
    _autoScrollTimer?.cancel();

    _pauseTimer?.cancel();
    _pauseTimer = Timer(_pauseDuration, () {
      if (_isAutoScrolling.value) {
        _isPaused.value = false;
        _startAutoScroll();
      }
    });
  }

  void stopAutoScroll() {
    _isAutoScrolling.value = false;
    _isPaused.value = false;
    _cancelAllTimers();
  }

  void resumeAutoScroll() {
    if (!_isAutoScrolling.value) {
      _isAutoScrolling.value = true;
      _isPaused.value = false;
      _startAutoScroll();
    }
  }

  void toggleAutoScroll() {
    if (_isAutoScrolling.value) {
      stopAutoScroll();
    } else {
      resumeAutoScroll();
    }
  }

  void startManualScroll() {
    _autoScrollTimer?.cancel();
    _manualScrollTimer?.cancel();
    _manualScrollTimer = Timer(_manualScrollDelay, () {
      if (_isAutoScrolling.value && !_isPaused.value) {
        _startAutoScroll();
      }
    });
  }

  void stopManualScroll() {
    _manualScrollTimer?.cancel();
  }

  void startAutoScrollWhenReady() {
    int attempts = 0;

    Timer.periodic(_checkInterval, (timer) {
      attempts++;

      if (attempts > _maxAttempts) {
        timer.cancel();
        return;
      }

      if (_isScrollControllerReady()) {
        timer.cancel();
        _startAutoScroll();
      }
    });
  }

  void _cancelAllTimers() {
    _autoScrollTimer?.cancel();
    _pauseTimer?.cancel();
    _manualScrollTimer?.cancel();
  }

  @override
  void onClose() {
    _cancelAllTimers();
    _scrollController.dispose();
    super.onClose();
  }
}
