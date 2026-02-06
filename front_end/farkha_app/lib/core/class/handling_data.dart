import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../constant/theme/images.dart';
import 'status_request.dart';

class HandlingDataView extends StatelessWidget {
  final StatusRequest statusRequest;
  final Widget widget;
  /// Optional text shown under the loading icon (e.g. "الطقس قادم").
  final String? loadingMessage;

  const HandlingDataView({
    super.key,
    required this.statusRequest,
    required this.widget,
    this.loadingMessage,
  });

  @override
  Widget build(BuildContext context) {
    return statusRequest == StatusRequest.loading
        ? Center(
          child: loadingMessage != null && loadingMessage!.isNotEmpty
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Lottie.asset(AppImages.loading, width: 250, height: 250),
                    const SizedBox(height: 16),
                    Text(
                      loadingMessage!,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                )
              : Lottie.asset(AppImages.loading, width: 250, height: 250),
        )
        : statusRequest == StatusRequest.serverFailure
        ? Center(child: Lottie.asset(AppImages.error, width: 250, height: 250))
        : statusRequest == StatusRequest.failure
        ? Center(child: Lottie.asset(AppImages.noData, width: 250, height: 250))
        : statusRequest == StatusRequest.offlineFailure
        ? Center(
          child: Lottie.asset(AppImages.offline, width: 250, height: 250),
        )
        : widget;
  }
}
