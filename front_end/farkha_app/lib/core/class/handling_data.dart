import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../constant/theme/images.dart';
import 'status_request.dart';

class HandlingDataView extends StatelessWidget {
  final StatusRequest statusRequest;
  final Widget widget;
  const HandlingDataView({
    super.key,
    required this.statusRequest,
    required this.widget,
  });

  @override
  Widget build(BuildContext context) {
    return statusRequest == StatusRequest.loading
        ? Center(
          child: Lottie.asset(AppImages.loading, width: 250, height: 250),
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
