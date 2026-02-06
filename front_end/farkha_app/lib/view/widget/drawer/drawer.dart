import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'drawer_about_app.dart';
import 'drawer_account_settings.dart';
import 'drawer_header.dart';
import 'drawer_support_contact.dart';

class HomeDrawer extends StatefulWidget {
  const HomeDrawer({super.key});

  @override
  State<HomeDrawer> createState() => _HomeDrawerState();
}

class _HomeDrawerState extends State<HomeDrawer> {
  int? _expandedIndex;

  void _handleExpansionChanged(int index, bool isExpanded) {
    setState(() {
      _expandedIndex = isExpanded ? index : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Drawer(
      width: screenWidth * 0.7,
      child: SafeArea(
        child: Column(
          children: [
            const DrawerHeaderWidget(),
            SizedBox(height: 15.h),
            const Divider(height: 1, thickness: 0.5),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    DrawerAboutApp(
                      isExpanded: _expandedIndex == 0,
                      onExpansionChanged:
                          (expanded) => _handleExpansionChanged(0, expanded),
                    ),
                    const Divider(height: 1, thickness: 0.5),
                    DrawerAccountSettings(
                      isExpanded: _expandedIndex == 1,
                      onExpansionChanged:
                          (expanded) => _handleExpansionChanged(1, expanded),
                    ),
                    const Divider(height: 1, thickness: 0.5),
                    DrawerSupportContact(
                      isExpanded: _expandedIndex == 2,
                      onExpansionChanged:
                          (expanded) => _handleExpansionChanged(2, expanded),
                    ),
                    const Divider(height: 1, thickness: 0.5),
                  ],
                ),
              ),
            ),
            _buildSocialIcons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialIcons(BuildContext context) {
    Future<void> launchSocial(String urlString) async {
      final Uri url = Uri.parse(urlString);
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Could not launch url')));
        }
      }
    }

    return Column(
      children: [
        Text(
          'تابعنا',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        SizedBox(height: 7.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 8.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _SocialIcon(
                icon: FontAwesomeIcons.youtube,
                color: const Color(0xFFFF0000),
                onTap:
                    () => launchSocial(
                      'https://www.youtube.com/channel/UCdZGvP5kCXaOPTXCFIm9LsA',
                    ),
              ),
              _SocialIcon(
                icon: FontAwesomeIcons.facebook,
                color: const Color(0xFF1877F2),
                onTap:
                    () => launchSocial(
                      'https://www.facebook.com/share/14XXZM4nthV/',
                    ),
              ),
            ],
          ),
        ),
        SizedBox(height: 40.h),
      ],
    );
  }
}

class _SocialIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _SocialIcon({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(10.r),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: FaIcon(icon, color: color, size: 24.sp),
      ),
    );
  }
}
