import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../constant/theme/imgae_asset.dart';
import 'status_request.dart';

class HandlingDataView extends StatelessWidget {
  final StatusRequest statusRequest;
  final Widget widget;
  const HandlingDataView(
      {Key? key, required this.statusRequest, required this.widget})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return statusRequest == StatusRequest.loading
        ?   Center(child: Lottie.asset(AppImageAsset.loading , width: 250 , height: 250))
        : statusRequest == StatusRequest.offlineFailure
            ? Center(child: Lottie.asset(AppImageAsset.loading , width: 250 , height: 250))
            : statusRequest == StatusRequest.serverFailure
                ?Center(child: Lottie.asset(AppImageAsset.loading , width: 250 , height: 250))
                : statusRequest == StatusRequest.failure
                    ? Center(child: Lottie.asset(AppImageAsset.loading , width: 250 , height: 250 , repeat: true  ))
                    : widget;
  }
  
}
