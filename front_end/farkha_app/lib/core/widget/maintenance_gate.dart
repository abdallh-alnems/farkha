import 'dart:async';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_storage/get_storage.dart';

import '../services/notification_service.dart';

class MaintenanceGate extends StatefulWidget {
  final Widget child;
  const MaintenanceGate({super.key, required this.child});

  static _MaintenanceGateState? _instance;

  static void trigger(bool enabled) {
    final storage = GetStorage();
    storage.write(kPendingMaintenanceKey, enabled);
    _instance?._setMaintenance(enabled);
  }

  @override
  State<MaintenanceGate> createState() => _MaintenanceGateState();
}

class _MaintenanceGateState extends State<MaintenanceGate>
    with WidgetsBindingObserver {
  bool _isMaintenance = false;
  bool _isChecking = true;
  StreamSubscription<RemoteConfigUpdate>? _rcSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    MaintenanceGate._instance = this;
    _init();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _rcSubscription?.cancel();
    MaintenanceGate._instance = null;
    super.dispose();
  }

  Future<void> _init() async {
    final storage = GetStorage();
    final pending = storage.read<bool>(kPendingMaintenanceKey) ?? false;
    if (pending) {
      _isMaintenance = true;
      storage.remove(kPendingMaintenanceKey);
    }

    try {
      final rc = FirebaseRemoteConfig.instance;
      await rc.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 5),
        minimumFetchInterval:
            kDebugMode ? Duration.zero : const Duration(hours: 1),
      ));
      await rc.fetchAndActivate();
      _isMaintenance = rc.getBool('maintenance_enabled');
      _rcSubscription = rc.onConfigUpdated.listen((_) async {
        await rc.activate();
        if (!mounted) return;
        final m = rc.getBool('maintenance_enabled');
        _setMaintenance(m);
      });
    } catch (_) {}

    if (mounted) setState(() => _isChecking = false);
  }

  void _setMaintenance(bool enabled) {
    if (!mounted || enabled == _isMaintenance) return;
    setState(() => _isMaintenance = enabled);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkNow();
    }
  }

  Future<void> _checkNow() async {
    try {
      final rc = FirebaseRemoteConfig.instance;
      await rc.fetchAndActivate();
      final m = rc.getBool('maintenance_enabled');
      _setMaintenance(m);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_isMaintenance) {
      return const _MaintenanceScreen();
    }

    return widget.child;
  }
}

class _MaintenanceScreen extends StatelessWidget {
  const _MaintenanceScreen();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final message =
        FirebaseRemoteConfig.instance.getString('maintenance_message');
    final displayMessage =
        message.isNotEmpty ? message : 'التطبيق تحت الصيانة حالياً، سنعود قريباً';

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.all(24.w),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.errorContainer
                          .withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.build_rounded,
                      size: 64.sp,
                      color: theme.colorScheme.error,
                    ),
                  ),
                  SizedBox(height: 32.h),
                  Text(
                    'تحت الصيانة',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    displayMessage,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
