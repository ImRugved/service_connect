import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:service_connect/constants/app_colors.dart';
import 'package:service_connect/firebase_options.dart';
import 'package:service_connect/routes/app_routes.dart';
import 'package:service_connect/screens/auth/provider/auth_provider.dart';
import 'package:service_connect/screens/auth/provider/login_provider.dart';
import 'package:service_connect/screens/auth/provider/signup_provider.dart';
import 'package:service_connect/screens/home/provider/service_provider_provider.dart';
import 'package:service_connect/screens/orders/provider/order_provider.dart';
import 'package:service_connect/screens/profile/provider/profile_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider(create: (_) => ServiceProviderProvider()),
            ChangeNotifierProvider(create: (_) => LoginProvider()),
            ChangeNotifierProvider(create: (_) => SignupProvider()),
            ChangeNotifierProvider(create: (_) => ProfileProvider()),
            ChangeNotifierProvider(create: (_) => OrderProvider()),
          ],
          child: GetMaterialApp(
            title: 'Service Connect',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primaryColor: AppColors.primaryBlue,
              scaffoldBackgroundColor: AppColors.background,
              fontFamily: 'Poppins',
              useMaterial3: true,
            ),
            initialRoute: AppRoutes.splash,
            getPages: AppRoutes.routes,
            defaultTransition: Transition.fadeIn,
          ),
        );
      },
    );
  }
}
