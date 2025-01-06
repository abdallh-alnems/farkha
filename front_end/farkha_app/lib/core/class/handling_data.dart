import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../constant/theme/image_asset.dart';
import 'status_request.dart';

class HandlingDataView extends StatelessWidget {
  final StatusRequest statusRequest;
  final Widget widget;
  const HandlingDataView(
      {super.key, required this.statusRequest, required this.widget});

  @override
  Widget build(BuildContext context) {
    return statusRequest == StatusRequest.loading
        ? Center(
            child: Lottie.asset(
            ImageAsset.loading,
          ))
        : statusRequest == StatusRequest.serverFailure
            ? Center(
                child: Lottie.asset(
                ImageAsset.error,
              ))
            : statusRequest == StatusRequest.failure
                ? Center(
                    child: Lottie.asset(
                    ImageAsset.noData,
                  ))
                : widget;
  }
}
