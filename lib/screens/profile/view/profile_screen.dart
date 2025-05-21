import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../auth/provider/auth_provider.dart';
import '../provider/profile_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProfileProvider>(context, listen: false).initializeControllers();
    });
  }

  // No local functions needed as they've been moved to the provider

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final profileProvider = Provider.of<ProfileProvider>(context);
    final user = authProvider.userModel;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text(
          'Profile',
          style: AppTextStyles.heading3,
        ),
        actions: [
          if (!profileProvider.isEditing)
            IconButton(
              icon: const Icon(Icons.edit, color: AppColors.primaryBlue),
              onPressed: () {
                profileProvider.toggleEditing(true);
              },
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Profile header
              Container(
                padding: EdgeInsets.all(24.r),
                color: AppColors.white,
                child: Column(
                  children: [
                    // Profile image
                    Container(
                      width: 100.w,
                      height: 100.w,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLightBlue.withOpacity(0.2),
                        shape: BoxShape.circle,
                        image: user.profileImageUrl != null
                            ? DecorationImage(
                                image: NetworkImage(user.profileImageUrl!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: user.profileImageUrl == null
                          ? Icon(
                              Icons.person,
                              color: AppColors.primaryBlue,
                              size: 60.w,
                            )
                          : null,
                    ),
                    SizedBox(height: 16.h),
                    // Name
                    Text(
                      user.name,
                      style: AppTextStyles.heading2,
                    ),
                    SizedBox(height: 4.h),
                    // Email
                    Text(
                      user.email,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.grey,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    // User type
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: user.userType == 'service_provider'
                            ? AppColors.primaryLightBlue.withOpacity(0.2)
                            : AppColors.secondaryLightBlue.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Text(
                        user.userType == 'service_provider'
                            ? 'Service Provider'
                            : 'Customer',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: user.userType == 'service_provider'
                              ? AppColors.primaryDarkBlue
                              : AppColors.secondaryBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16.h),

              // Profile details
              Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: profileProvider.isEditing
                    ? _buildEditProfileForm(profileProvider)
                    : _buildProfileDetails(user),
              ),

              SizedBox(height: 16.h),

              // Settings section
              Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Settings',
                      style: AppTextStyles.heading3,
                    ),
                    SizedBox(height: 16.h),
                    _buildSettingItem(
                      icon: Icons.notifications_outlined,
                      title: 'Notifications',
                      onTap: () {
                        // TODO: Implement notifications settings
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Notifications settings will be implemented soon'),
                            backgroundColor: AppColors.primaryBlue,
                          ),
                        );
                      },
                    ),
                    _buildDivider(),
                    _buildSettingItem(
                      icon: Icons.security_outlined,
                      title: 'Privacy & Security',
                      onTap: () {
                        // TODO: Implement privacy settings
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Privacy settings will be implemented soon'),
                            backgroundColor: AppColors.primaryBlue,
                          ),
                        );
                      },
                    ),
                    _buildDivider(),
                    _buildSettingItem(
                      icon: Icons.help_outline,
                      title: 'Help & Support',
                      onTap: () {
                        // TODO: Implement help & support
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('Help & Support will be implemented soon'),
                            backgroundColor: AppColors.primaryBlue,
                          ),
                        );
                      },
                    ),
                    _buildDivider(),
                    _buildSettingItem(
                      icon: Icons.info_outline,
                      title: 'About',
                      onTap: () {
                        // TODO: Implement about
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('About section will be implemented soon'),
                            backgroundColor: AppColors.primaryBlue,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24.h),

              // Sign out button
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.r),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: profileProvider.isLoading ? null : () => profileProvider.signOut(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: AppColors.white,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      elevation: 0,
                    ),
                    child: profileProvider.isLoading
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
                            'Sign Out',
                            style: AppTextStyles.buttonText,
                          ),
                  ),
                ),
              ),

              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileDetails(dynamic user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Personal Information',
          style: AppTextStyles.heading3,
        ),
        SizedBox(height: 16.h),
        _buildInfoItem(
          icon: Icons.person_outline,
          title: 'Name',
          value: user.name,
        ),
        _buildDivider(),
        _buildInfoItem(
          icon: Icons.email_outlined,
          title: 'Email',
          value: user.email,
        ),
        _buildDivider(),
        _buildInfoItem(
          icon: Icons.phone_outlined,
          title: 'Phone',
          value: user.phoneNumber ?? 'Not provided',
        ),
        _buildDivider(),
        _buildInfoItem(
          icon: Icons.location_on_outlined,
          title: 'Address',
          value: user.address ?? 'Not provided',
        ),
      ],
    );
  }

  Widget _buildEditProfileForm(ProfileProvider profileProvider) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Edit Profile',
            style: AppTextStyles.heading3,
          ),
          SizedBox(height: 16.h),

          // Name field
          TextFormField(
            controller: profileProvider.nameController,
            decoration: InputDecoration(
              labelText: 'Name',
              prefixIcon: const Icon(Icons.person_outline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: AppColors.lightGrey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: AppColors.primaryBlue),
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

          // Phone field
          TextFormField(
            controller: profileProvider.phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: 'Phone',
              prefixIcon: const Icon(Icons.phone_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: AppColors.lightGrey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: AppColors.primaryBlue),
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

          // Address field
          TextFormField(
            controller: profileProvider.addressController,
            decoration: InputDecoration(
              labelText: 'Address',
              prefixIcon: const Icon(Icons.location_on_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: AppColors.lightGrey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: AppColors.primaryBlue),
              ),
            ),
            maxLines: 3,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your address';
              }
              return null;
            },
          ),

          SizedBox(height: 24.h),

          // Error message
          if (profileProvider.errorMessage != null)
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                profileProvider.errorMessage!,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.error,
                ),
                textAlign: TextAlign.center,
              ),
            ),

          SizedBox(height: 24.h),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    profileProvider.toggleEditing(false);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryBlue,
                    side: const BorderSide(color: AppColors.primaryBlue),
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: profileProvider.isLoading ? null : () {
                    if (_formKey.currentState!.validate()) {
                      profileProvider.updateProfile(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: AppColors.white,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    elevation: 0,
                  ),
                  child: profileProvider.isLoading
                      ? SizedBox(
                          width: 24.w,
                          height: 24.w,
                          child: const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.white),
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Save'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: AppColors.grey,
            size: 24.w,
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.grey,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  value,
                  style: AppTextStyles.bodyLarge,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppColors.primaryBlue,
              size: 24.w,
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.bodyMedium,
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.grey,
              size: 16.w,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: AppColors.lightGrey,
      height: 16.h,
    );
  }
}
