import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../core/services/open_privacy_policy.dart';

class DrawerFooter extends StatelessWidget {
  const DrawerFooter({super.key});

  static final Future<PackageInfo> _packageInfoFuture =
      PackageInfo.fromPlatform();

  void _handlePrivacyPolicy(BuildContext context) {
    Navigator.pop(context);
    openPrivacyPolicy();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextButton(
          onPressed: () => _handlePrivacyPolicy(context),
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.onSurface,
          ),
          child: const Text('سياسة الخصوصية'),
        ),
        FutureBuilder<PackageInfo>(
          future: _packageInfoFuture,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox.shrink();
            }
            final version = snapshot.data!.version;
            return Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: Text(
                'الإصدار : $version',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            );
          },
        ),
      ],
    );
  }
}


