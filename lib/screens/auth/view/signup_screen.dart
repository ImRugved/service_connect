import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../routes/app_routes.dart';
import '../provider/auth_provider.dart';
import '../provider/signup_provider.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      // Check if service provider has selected a category
      final signupProvider = Provider.of<SignupProvider>(context, listen: false);
      if (signupProvider.selectedUserType == 'service_provider' && 
          signupProvider.selectedCategory.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a service category'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
      
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final success = await authProvider.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
        userType: signupProvider.selectedUserType,
        phoneNumber: _phoneController.text.trim(),
        category: signupProvider.selectedUserType == 'service_provider' 
            ? signupProvider.selectedCategory 
            : null,
      );

      if (success && mounted) {
        if (signupProvider.selectedUserType == 'service_provider') {
          // Navigate to service provider setup screen
          Get.offAllNamed(
            AppRoutes.serviceProviderSetup,
          );
        } else {
          Get.offAllNamed(AppRoutes.customerHome);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 20.h),

                  // Title
                  Text(
                    'Create Account',
                    style: AppTextStyles.heading1,
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: 8.h),

                  // Subtitle
                  Text(
                    'Sign up to get started',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: 32.h),

                  // User type selection
                  Text(
                    'I am a:',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  SizedBox(height: 12.h),

                  Consumer<SignupProvider>(
                    builder: (context, signupProvider, _) {
                      return Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              signupProvider.setUserType('customer');
                            },
                            child: Container(
                              padding: EdgeInsets.all(5.r),
                              decoration: BoxDecoration(
                                color: signupProvider.selectedUserType ==
                                        'customer'
                                    ? AppColors.primaryLightBlue
                                    : AppColors.lightGrey,
                                borderRadius: BorderRadius.circular(8.r),
                                border: Border.all(
                                  color: signupProvider.selectedUserType ==
                                          'customer'
                                      ? AppColors.primaryBlue
                                      : AppColors.lightGrey,
                                  width: 2,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.person,
                                    color: signupProvider.selectedUserType ==
                                            'customer'
                                        ? AppColors.primaryBlue
                                        : AppColors.grey,
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    'Customer',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      fontSize: 14.sp,
                                      color: signupProvider.selectedUserType ==
                                              'customer'
                                          ? AppColors.primaryBlue
                                          : AppColors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Spacer(),
                          GestureDetector(
                            onTap: () {
                              signupProvider.setUserType('service_provider');
                            },
                            child: Container(
                              padding: EdgeInsets.all(5.r),
                              decoration: BoxDecoration(
                                color: signupProvider.selectedUserType ==
                                        'service_provider'
                                    ? AppColors.primaryLightBlue
                                    : AppColors.lightGrey,
                                borderRadius: BorderRadius.circular(8.r),
                                border: Border.all(
                                  color: signupProvider.selectedUserType ==
                                          'service_provider'
                                      ? AppColors.primaryBlue
                                      : AppColors.lightGrey,
                                  width: 2,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.handyman,
                                    color: signupProvider.selectedUserType ==
                                            'service_provider'
                                        ? AppColors.primaryBlue
                                        : AppColors.grey,
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    'Service Provider',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: signupProvider.selectedUserType ==
                                              'service_provider'
                                          ? AppColors.primaryBlue
                                          : AppColors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  SizedBox(height: 24.h),

                  // Name field
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      hintText: 'Enter your full name',
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide:
                            const BorderSide(color: AppColors.lightGrey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide:
                            const BorderSide(color: AppColors.primaryBlue),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: 16.h),

                  // Email field
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      hintText: 'Enter your email',
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide:
                            const BorderSide(color: AppColors.lightGrey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide:
                            const BorderSide(color: AppColors.primaryBlue),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                          .hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: 16.h),

                  // Phone field
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      hintText: 'Enter your phone number',
                      prefixIcon: const Icon(Icons.phone_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide:
                            const BorderSide(color: AppColors.lightGrey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide:
                            const BorderSide(color: AppColors.primaryBlue),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your phone number';
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: 16.h),

                  // Password field
                  TextFormField(
                    controller: _passwordController,
                    obscureText:
                        Provider.of<SignupProvider>(context).obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: 'Enter your password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          Provider.of<SignupProvider>(context).obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          Provider.of<SignupProvider>(context, listen: false)
                              .togglePasswordVisibility();
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide:
                            const BorderSide(color: AppColors.lightGrey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide:
                            const BorderSide(color: AppColors.primaryBlue),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: 16.h),

                  // Confirm password field
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: Provider.of<SignupProvider>(context)
                        .obscureConfirmPassword,
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      hintText: 'Confirm your password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          Provider.of<SignupProvider>(context)
                                  .obscureConfirmPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          Provider.of<SignupProvider>(context, listen: false)
                              .toggleConfirmPasswordVisibility();
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide:
                            const BorderSide(color: AppColors.lightGrey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide:
                            const BorderSide(color: AppColors.primaryBlue),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: 16.h),

                  // Service category dropdown (only for service providers)
                  Consumer<SignupProvider>(builder: (context, signupProvider, _) {
                    if (signupProvider.selectedUserType == 'service_provider') {
                      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(
                          'Service Category',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: AppColors.lightGrey),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: signupProvider.selectedCategory.isEmpty
                                  ? null
                                  : signupProvider.selectedCategory,
                              hint: Text('Select a category'),
                              items: [
                                'Cleaning',
                                'Plumbing',
                                'Electrical',
                                'Carpentry',
                                'Painting',
                                'Gardening',
                                'Moving',
                                'Beauty',
                                'Other'
                              ].map((String category) {
                                return DropdownMenuItem<String>(
                                  value: category,
                                  child: Text(category),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  signupProvider.setCategory(newValue);
                                }
                              },
                            ),
                          ),
                        ),
                        SizedBox(height: 8.h),
                      ]);
                    } else {
                      return SizedBox.shrink();
                    }
                  }),

                  SizedBox(height: 24.h),

                  // Error message
                  if (authProvider.errorMessage != null)
                    Container(
                      padding: EdgeInsets.all(12.r),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        authProvider.errorMessage!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.error,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  SizedBox(height: 24.h),

                  // Sign up button
                  ElevatedButton(
                    onPressed: authProvider.isLoading ? null : _signUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: AppColors.white,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      elevation: 0,
                    ),
                    child: authProvider.isLoading
                        ? SizedBox(
                            width: 24.w,
                            height: 24.w,
                            child: const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.white),
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Sign Up',
                            style: AppTextStyles.buttonText,
                          ),
                  ),

                  SizedBox(height: 24.h),

                  // Sign in link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account?',
                        style: AppTextStyles.bodyMedium,
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          'Sign In',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.primaryBlue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
