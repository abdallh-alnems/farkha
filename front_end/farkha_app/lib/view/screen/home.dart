import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/functions/alert_exit_app.dart';
import '../../core/functions/check_internet.dart';
import '../../core/package/rating_app.dart';
import '../../core/package/upgrade/upgrade.dart';
import '../widget/ad/banner.dart';
import '../widget/ad/native.dart';
import '../widget/app_bar/app_bar_home.dart';
import '../widget/home/price_stream/price_card.dart';
import '../widget/home/tools_section.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
      ),
    );
  }

  void _startAnimations() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Get.find<InternetController>();
    Get.find<RateMyAppController>();

    return Scaffold(
      appBar: const AppBarHome(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            TapToExit(
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        children: [
                          _buildAnimatedUpgrade(),
                          const SizedBox(height: 16),
                          _buildAnimatedPriceCard(),
                          const SizedBox(height: 16),
                          const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 17,
                              vertical: 9,
                            ),
                            child: AdNativeWidget(),
                          ),
                          const SizedBox(height: 13),
                          _buildAnimatedToolsSection(),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AdBannerWidget(),
    );
  }

  Widget _buildAnimatedUpgrade() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1200),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(scale: value, child: const Upgrade());
      },
    );
  }

  Widget _buildAnimatedPriceCard() {
    return TweenAnimationBuilder<Offset>(
      duration: const Duration(milliseconds: 1400),
      tween: Tween(begin: const Offset(-1.0, 0.0), end: Offset.zero),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return SlideTransition(
          position: AlwaysStoppedAnimation(value),
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 1200),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, opacity, child) {
              return Opacity(opacity: opacity, child: const PriceCard());
            },
          ),
        );
      },
    );
  }

  Widget _buildAnimatedToolsSection() {
    return TweenAnimationBuilder<Offset>(
      duration: const Duration(milliseconds: 1800),
      tween: Tween(begin: const Offset(0.0, 1.0), end: Offset.zero),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return SlideTransition(
          position: AlwaysStoppedAnimation(value),
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 1500),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, opacity, child) {
              return Opacity(opacity: opacity, child: const ToolsSection());
            },
          ),
        );
      },
    );
  }
}
