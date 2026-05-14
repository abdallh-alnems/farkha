import 'dart:async';

import 'package:get/get.dart';

import '../../../core/functions/number_format.dart';
import '../weather_controller.dart';

class FanProgram {
  final String name;
  final int runMinutes;
  final int offMinutes;
  final String description;

  const FanProgram({
    required this.name,
    required this.runMinutes,
    required this.offMinutes,
    required this.description,
  });

  int get cycleDurationMinutes => runMinutes + offMinutes;
}

class FanOperationController extends GetxController {
  WeatherController weatherController = Get.put(WeatherController());

  static const List<FanProgram> presetPrograms = [
    FanProgram(
      name: '1 د',
      runMinutes: 1,
      offMinutes: 9,
      description: '1 تشغيل / 9 إيقاف',
    ),
    FanProgram(
      name: '3 د',
      runMinutes: 3,
      offMinutes: 7,
      description: '3 تشغيل / 7 إيقاف',
    ),
    FanProgram(
      name: '5 د',
      runMinutes: 5,
      offMinutes: 5,
      description: '5 تشغيل / 5 إيقاف',
    ),
    FanProgram(
      name: '10 د',
      runMinutes: 10,
      offMinutes: 5,
      description: '10 تشغيل / 5 إيقاف',
    ),
    FanProgram(
      name: 'مستمر',
      runMinutes: 60,
      offMinutes: 0,
      description: 'تشغيل مستمر بدون إيقاف',
    ),
  ];

  RxInt numberOfBirds = 0.obs;
  RxDouble averageWeight = 0.0.obs;
  RxDouble fanCapacityPerHour = 0.0.obs;
  RxDouble temperature = 0.0.obs;

  RxDouble airFlowPerKg = 0.0.obs;
  RxDouble requiredAirFlowPerHour = 0.0.obs;
  RxDouble fanCapacityPerMinute = 0.0.obs;
  RxDouble operationDuration = 0.0.obs;
  RxString operationStatus = ''.obs;

  Rx<FanProgram?> selectedProgram = Rx<FanProgram?>(null);
  RxInt recommendedProgramIndex = (-1).obs;
  RxBool hasCalculated = false.obs;

  Rx<Duration> timerRemaining = Duration.zero.obs;
  RxBool isTimerRunning = false.obs;
  RxBool isTimerInRunPhase = true.obs;
  RxInt timerCycleCount = 0.obs;

  Timer? _timer;
  int _timerTotalSeconds = 0;

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  bool get canCalculate =>
      numberOfBirds.value > 0 &&
      averageWeight.value > 0 &&
      fanCapacityPerHour.value > 0 &&
      temperature.value > 0;

  void calculateFanOperation() {
    final totalWeight = numberOfBirds.value * averageWeight.value;

    final currentTemp =
        temperature.value > 0
            ? temperature.value
            : weatherController.currentTemperature.value;
    if (currentTemp < 10) {
      airFlowPerKg.value = 0.4;
    } else if (currentTemp <= 20) {
      airFlowPerKg.value = 1.4;
    } else if (currentTemp <= 25) {
      airFlowPerKg.value = 2.5;
    } else if (currentTemp <= 35) {
      airFlowPerKg.value = 4.3;
    } else {
      airFlowPerKg.value = 7.5;
    }

    requiredAirFlowPerHour.value = totalWeight * airFlowPerKg.value;
    fanCapacityPerMinute.value = fanCapacityPerHour.value / 60;

    if (fanCapacityPerMinute.value > 0) {
      operationDuration.value =
          requiredAirFlowPerHour.value / fanCapacityPerMinute.value;
    } else {
      operationDuration.value = 0;
    }

    if (operationDuration.value <= 60) {
      operationStatus.value =
          'تشغيل مستمر (${formatDecimal(operationDuration.value)} دقيقة)';
    } else if (operationDuration.value <= 120) {
      operationStatus.value =
          'تشغيل متقطع (${formatDecimal(operationDuration.value)} دقيقة)';
    } else {
      operationStatus.value =
          'تشغيل خفيف (${formatDecimal(operationDuration.value)} دقيقة)';
    }

    _recommendProgram();
    hasCalculated.value = true;
  }

  void _recommendProgram() {
    final duration = operationDuration.value;
    if (duration <= 0) {
      recommendedProgramIndex.value = -1;
      return;
    }

    if (duration <= 60) {
      recommendedProgramIndex.value = 4;
    } else if (duration <= 90) {
      recommendedProgramIndex.value = 3;
    } else if (duration <= 150) {
      recommendedProgramIndex.value = 2;
    } else if (duration <= 240) {
      recommendedProgramIndex.value = 1;
    } else {
      recommendedProgramIndex.value = 0;
    }
  }

  void selectProgram(FanProgram program) {
    final current = selectedProgram.value;
    selectedProgram.value = current == program ? null : program;
    stopTimer();
  }

  int get totalCycles {
    final program = selectedProgram.value;
    if (program == null || program.offMinutes == 0) return 1;
    return (operationDuration.value / program.runMinutes).ceil();
  }

  double get totalMinutes {
    final program = selectedProgram.value;
    if (program == null || program.offMinutes == 0) {
      return operationDuration.value;
    }
    final cycles = (operationDuration.value / program.runMinutes).ceil();
    return cycles * program.cycleDurationMinutes.toDouble();
  }

  void startTimer() {
    final program = selectedProgram.value;
    if (program == null) return;

    _timer?.cancel();
    isTimerRunning.value = true;
    isTimerInRunPhase.value = true;
    timerCycleCount.value = 1;
    _timerTotalSeconds = program.runMinutes * 60;
    timerRemaining.value = Duration(seconds: _timerTotalSeconds);

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final remaining = timerRemaining.value.inSeconds - 1;
      if (remaining <= 0) {
        _switchPhase();
      } else {
        timerRemaining.value = Duration(seconds: remaining);
      }
    });
  }

  void _switchPhase() {
    final program = selectedProgram.value;
    if (program == null) return;

    if (isTimerInRunPhase.value) {
      if (program.offMinutes == 0) {
        stopTimer();
        return;
      }
      isTimerInRunPhase.value = false;
      _timerTotalSeconds = program.offMinutes * 60;
      timerRemaining.value = Duration(seconds: _timerTotalSeconds);
    } else {
      timerCycleCount.value++;
      isTimerInRunPhase.value = true;
      _timerTotalSeconds = program.runMinutes * 60;
      timerRemaining.value = Duration(seconds: _timerTotalSeconds);
    }
  }

  void pauseTimer() {
    _timer?.cancel();
    isTimerRunning.value = false;
  }

  void resumeTimer() {
    if (selectedProgram.value == null) return;
    isTimerRunning.value = true;

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final remaining = timerRemaining.value.inSeconds - 1;
      if (remaining <= 0) {
        _switchPhase();
      } else {
        timerRemaining.value = Duration(seconds: remaining);
      }
    });
  }

  void stopTimer() {
    _timer?.cancel();
    isTimerRunning.value = false;
    timerRemaining.value = Duration.zero;
    timerCycleCount.value = 0;
    isTimerInRunPhase.value = true;
  }

  String formatTimerDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  double get timerProgress {
    if (_timerTotalSeconds <= 0) return 0;
    return timerRemaining.value.inSeconds / _timerTotalSeconds;
  }

  void updateNumberOfBirds(String value) {
    numberOfBirds.value = tryParseInt(value) ?? 0;
  }

  void updateAverageWeight(String value) {
    averageWeight.value = tryParseNum(value) ?? 0.0;
  }

  void updateFanCapacityPerHour(String value) {
    fanCapacityPerHour.value = tryParseNum(value) ?? 0.0;
  }

  void updateTemperature(String value) {
    temperature.value = tryParseNum(value) ?? 0.0;
  }

  Future<void> getWeatherData() async {
    await weatherController.getWeatherData();
    if (weatherController.hasWeatherData && currentTemperature > 0) {
      temperature.value = currentTemperature;
      update();
    }
  }

  double get currentTemperature => weatherController.currentTemperature.value;

  bool get isWeatherLoading => weatherController.isLoading;

  bool get hasWeatherError => weatherController.hasError;

  String get locationMessage => weatherController.locationMessage;

  bool get hasWeatherData => weatherController.hasWeatherData;
}
