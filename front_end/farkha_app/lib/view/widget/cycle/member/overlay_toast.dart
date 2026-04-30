import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showOverlayToast(String message, {bool isError = false}) {
  final overlay = Get.key.currentState?.overlay;
  if (overlay == null) return;
  OverlayEntry? entry;
  entry = OverlayEntry(
    builder: (_) => Positioned(
      bottom: 40,
      left: 24,
      right: 24,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isError ? Colors.red.shade700 : Colors.green.shade700,
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)],
          ),
          child: Text(
            message,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    ),
  );
  overlay.insert(entry);
  Future.delayed(const Duration(seconds: 2), () {
    if (entry?.mounted == true) entry?.remove();
  });
}
