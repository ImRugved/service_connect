import 'package:get/get.dart';
import '../screens/auth/view/login_screen.dart';
import '../screens/auth/view/signup_screen.dart';
import '../screens/home/view/category_service_providers_screen.dart';
import '../screens/home/view/categories_screen.dart';
import '../screens/home/view/customer_home_screen.dart';
import '../screens/home/view/favorites_screen.dart';
import '../screens/home/view/service_provider_detail_screen.dart';
import '../screens/service_provider/view/service_provider_home_screen.dart';
import '../screens/home/view/service_provider_setup_screen.dart';
import '../screens/orders/view/customer_orders_screen.dart';
import '../screens/orders/view/orders_screen.dart';
import '../screens/profile/view/profile_screen.dart';
import '../screens/splash/view/splash_screen.dart';

class AppRoutes {
  // Route names
  static const String splash = '/splash';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String customerHome = '/customer-home';
  static const String serviceProviderHome = '/service-provider-home';
  static const String serviceProviderDetail = '/service-provider-detail';
  static const String serviceProviderSetup = '/service-provider-setup';
  static const String categoryServiceProviders = '/category-service-providers';
  static const String categories = '/categories';
  static const String favorites = '/favorites';
  static const String profile = '/profile';
  static const String customerOrders = '/customer-orders';
  static const String serviceProviderOrders = '/service-provider-orders';

  // Route definitions
  static final routes = [
    GetPage(
      name: splash,
      page: () => const SplashScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: login,
      page: () => const LoginScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: signup,
      page: () => const SignupScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: customerHome,
      page: () => const CustomerHomeScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: serviceProviderHome,
      page: () => const ServiceProviderHomeScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: serviceProviderSetup,
      page: () => const ServiceProviderSetupScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: serviceProviderDetail,
      page: () => ServiceProviderDetailScreen(
        serviceProviderId: Get.arguments['serviceProviderId'],
      ),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: categoryServiceProviders,
      page: () => CategoryServiceProvidersScreen(
        category: Get.arguments['category'],
      ),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: categories,
      page: () => const CategoriesScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: favorites,
      page: () => const FavoritesScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: profile,
      page: () => const ProfileScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: customerOrders,
      page: () => const CustomerOrdersScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: serviceProviderOrders,
      page: () => const OrdersScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
  ];
}
