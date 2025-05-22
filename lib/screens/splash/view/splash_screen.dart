import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../utils/session_manager.dart';
import '../../auth/view/login_screen.dart';
import '../../home/view/customer_home_screen.dart';
import '../../home/view/service_provider_home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    _animationController.forward();

    // Navigate to the appropriate screen after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      _navigateToNextScreen();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _navigateToNextScreen() async {
    // Check for auth token in shared preferences
    final authToken = await SessionManager.getAuthToken();

    if (authToken != null) {
      // User is logged in, check user type
      final userType = await SessionManager.getUserType();

      if (userType == 'service_provider') {
        Get.offAllNamed('/service-provider-home');
      } else {
        Get.offAllNamed('/customer-home');
      }
    } else {
      // User is not logged in
      Get.offAllNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App name text
              Text(
                'Service Connect',
                style: AppTextStyles.heading1.copyWith(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 32.sp,
                ),
              ),
              SizedBox(height: 24.h),

              // Circular logo with clean implementation
              ClipRRect(
                borderRadius:
                    BorderRadius.circular(100.w), // Half of width/height
                child: Container(
                  width: 200.w,
                  height: 200.w,
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.cover, // Important for proper circular cropping
                  ),
                ),
              ),

              SizedBox(height: 48.h),
              SizedBox(
                width: 40.w,
                height: 40.w,
                child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
                  strokeWidth: 3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
