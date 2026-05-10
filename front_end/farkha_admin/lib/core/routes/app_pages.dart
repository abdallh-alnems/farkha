import 'package:get/get.dart';
import '../../main.dart';
import '../routes/app_routes.dart';
import '../../features/auth/login_screen.dart';
import '../../features/dashboard/dashboard_binding.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/remote_config/remote_config_binding.dart';
import '../../features/remote_config/remote_config_screen.dart';
import '../../features/prices/prices_screen.dart';
import '../../features/articles/articles_screen.dart';
import '../../features/analytics/analytics_screen.dart';
import '../../features/users/users_screen.dart';
import '../../features/cycles/cycles_screen.dart';
import '../../features/notifications/notifications_screen.dart';
import '../../features/reviews/reviews_screen.dart';
import '../../features/categories/categories_screen.dart';
import '../../features/system/system_screen.dart';

class AppPages {
  static final pages = [
    GetPage(name: '/', page: () => const SplashCheck()),
    GetPage(name: AppRoutes.login, page: () => const LoginScreen()),
    GetPage(name: AppRoutes.dashboard, page: () => const DashboardScreen(), binding: DashboardBinding()),
    GetPage(name: AppRoutes.remoteConfig, page: () => const RemoteConfigScreen(), binding: RemoteConfigBinding()),
    GetPage(name: AppRoutes.prices, page: () => const PricesScreen()),
    GetPage(name: AppRoutes.articles, page: () => const ArticlesScreen()),
    GetPage(name: AppRoutes.analytics, page: () => const AnalyticsScreen()),
    GetPage(name: AppRoutes.users, page: () => const UsersScreen()),
    GetPage(name: AppRoutes.cycles, page: () => const CyclesScreen()),
    GetPage(name: AppRoutes.notifications, page: () => const NotificationsScreen()),
    GetPage(name: AppRoutes.reviews, page: () => const ReviewsScreen()),
    GetPage(name: AppRoutes.categories, page: () => const CategoriesScreen()),
    GetPage(name: AppRoutes.system, page: () => const SystemScreen()),
  ];
}
