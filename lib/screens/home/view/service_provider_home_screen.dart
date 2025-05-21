import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../auth/provider/auth_provider.dart';
import '../provider/service_provider_provider.dart';
import '../../profile/view/profile_screen.dart';

class ServiceProviderHomeScreen extends StatefulWidget {
  const ServiceProviderHomeScreen({super.key});

  @override
  State<ServiceProviderHomeScreen> createState() =>
      _ServiceProviderHomeScreenState();
}

class _ServiceProviderHomeScreenState extends State<ServiceProviderHomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final serviceProviderProvider = Provider.of<ServiceProviderProvider>(context);
    final userName =
        authProvider.userModel?.name.split(' ').first ?? 'Provider';

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text(
          'Service Connect',
          style: AppTextStyles.heading3.copyWith(
            color: AppColors.primaryBlue,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: AppColors.primaryBlue),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryBlue,
          unselectedLabelColor: AppColors.grey,
          indicatorColor: AppColors.primaryBlue,
          tabs: const [
            Tab(text: 'New Orders'),
            Tab(text: 'Ongoing'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Welcome section
            Container(
              padding: EdgeInsets.all(16.r),
              color: AppColors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, $userName!',
                    style: AppTextStyles.heading2,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Manage your service orders here',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.grey,
                    ),
                  ),
                ],
              ),
            ),

            // Status card
            Container(
              margin: EdgeInsets.all(16.r),
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primaryBlue,
                    AppColors.primaryDarkBlue,
                  ],
                ),
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryBlue.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatusItem(
                      icon: Icons.pending_actions,
                      title: 'Pending',
                      count: '0',
                    ),
                  ),
                  Container(
                    height: 40.h,
                    width: 1,
                    color: AppColors.white.withOpacity(0.3),
                  ),
                  Expanded(
                    child: _buildStatusItem(
                      icon: Icons.work,
                      title: 'In Progress',
                      count: '0',
                    ),
                  ),
                  Container(
                    height: 40.h,
                    width: 1,
                    color: AppColors.white.withOpacity(0.3),
                  ),
                  Expanded(
                    child: _buildStatusItem(
                      icon: Icons.check_circle,
                      title: 'Completed',
                      count: '0',
                    ),
                  ),
                ],
              ),
            ),

            // Toggle availability
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16.r),
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Availability',
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Toggle to show customers you are available for work',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: serviceProviderProvider.isAvailable,
                    onChanged: (value) {
                      serviceProviderProvider.toggleAvailability();
                    },
                    activeColor: AppColors.primaryBlue,
                  ),
                ],
              ),
            ),

            SizedBox(height: 16.h),

            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildEmptyOrdersView('No new orders yet'),
                  _buildEmptyOrdersView('No ongoing orders'),
                  _buildEmptyOrdersView('No completed orders'),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement add service functionality
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('Add service functionality will be implemented soon'),
              backgroundColor: AppColors.primaryBlue,
            ),
          );
        },
        backgroundColor: AppColors.primaryBlue,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatusItem({
    required IconData icon,
    required String title,
    required String count,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppColors.white,
          size: 24.w,
        ),
        SizedBox(height: 8.h),
        Text(
          count,
          style: AppTextStyles.heading3.copyWith(
            color: AppColors.white,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          title,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyOrdersView(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox,
            size: 64.w,
            color: AppColors.grey,
          ),
          SizedBox(height: 16.h),
          Text(
            message,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.grey,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Your orders will appear here',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
