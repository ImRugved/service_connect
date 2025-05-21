import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../routes/app_routes.dart';
import '../../auth/provider/auth_provider.dart';
import '../provider/service_provider_provider.dart';
import '../../profile/view/profile_screen.dart';
import '../../orders/view/orders_screen.dart';
import '../../orders/provider/order_provider.dart';

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

    // Load data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData();

      // Set up order provider to listen for new orders
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      orderProvider.fetchServiceProviderOrders();

      // Debug: Print current user ID
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      // print('Current user ID: ${authProvider.userModel?.id}');
      // print('Current user role: ${authProvider.userModel?.role}');
    });
  }

  // Method to refresh all data
  Future<void> _refreshData() async {
    final serviceProviderProvider =
        Provider.of<ServiceProviderProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    try {
      // Refresh all relevant data
      await Future.wait([
        serviceProviderProvider.refreshData(),
        orderProvider.fetchServiceProviderOrders(),
      ]);

      print(
          'Refresh completed. New orders count: ${orderProvider.newOrders.length}');

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data refreshed successfully'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Error refreshing data: $e');
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to refresh: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final serviceProviderProvider =
        Provider.of<ServiceProviderProvider>(context);
    final orderProvider = Provider.of<OrderProvider>(context);
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
          // Notifications icon
          IconButton(
            onPressed: () {
              // TODO: Implement notifications
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Notifications coming soon!'),
                ),
              );
            },
            icon: const Icon(
              Icons.notifications_outlined,
              color: AppColors.primaryBlue,
            ),
          ),
          // Profile icon
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
            icon: const Icon(
              Icons.person_outline,
              color: AppColors.primaryBlue,
            ),
          ),
        ],
      ),
      body: serviceProviderProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshData,
              color: AppColors.primaryBlue,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Welcome message and availability toggle
                      Padding(
                        padding: EdgeInsets.all(16.r),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Welcome, $userName',
                                    style: AppTextStyles.heading2,
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    'Manage your services and orders',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Available',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: serviceProviderProvider.isAvailable
                                        ? AppColors.success
                                        : AppColors.grey,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Switch(
                                  value: serviceProviderProvider.isAvailable,
                                  onChanged: (value) async {
                                    await serviceProviderProvider
                                        .toggleAvailability();
                                  },
                                  activeColor: AppColors.success,
                                  activeTrackColor: AppColors.successLight,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Quick stats
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Row(
                          children: [
                            _buildStatCard(
                              icon: Icons.calendar_today,
                              title: 'Today',
                              value: '0',
                              color: AppColors.primaryBlue,
                            ),
                            SizedBox(width: 16.w),
                            _buildStatCard(
                              icon: Icons.star,
                              title: 'Rating',
                              value: '0.0',
                              color: AppColors.warning,
                            ),
                            SizedBox(width: 16.w),
                            _buildStatCard(
                              icon: Icons.people,
                              title: 'Customers',
                              value: '0',
                              color: AppColors.success,
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 24.h),

                      // Quick actions
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Text(
                          'Quick Actions',
                          style: AppTextStyles.heading3,
                        ),
                      ),
                      SizedBox(height: 16.h),

                      // Action buttons
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Row(
                          children: [
                            _buildActionButton(
                              icon: Icons.receipt_long,
                              label: 'Orders',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const OrdersScreen()),
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      // Recent orders section
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Direct orders display
                            Text(
                              'New Orders (${orderProvider.newOrders.length})',
                              style: AppTextStyles.heading4.copyWith(
                                color: AppColors.primaryBlue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8.h),

                            // Orders list
                            orderProvider.newOrders.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.receipt_long_outlined,
                                          size: 48.r,
                                          color: AppColors.grey,
                                        ),
                                        SizedBox(height: 8.h),
                                        Text(
                                          'No new orders yet',
                                          style:
                                              AppTextStyles.bodyMedium.copyWith(
                                            color: AppColors.grey,
                                          ),
                                        ),
                                        SizedBox(height: 8.h),
                                        ElevatedButton(
                                          onPressed: _refreshData,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                AppColors.primaryBlue,
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 16.w,
                                              vertical: 8.h,
                                            ),
                                          ),
                                          child: Text(
                                            'Refresh',
                                            style: AppTextStyles.bodySmall
                                                .copyWith(
                                              color: AppColors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : Container(
                                    height: 200.h,
                                    child: ListView.builder(
                                      padding: EdgeInsets.only(top: 8.h),
                                      itemCount: orderProvider.newOrders.length,
                                      itemBuilder: (context, index) {
                                        final order =
                                            orderProvider.newOrders[index];
                                        return Card(
                                          margin: EdgeInsets.only(bottom: 8.h),
                                          color: AppColors.white,
                                          elevation: 2,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.r),
                                            side: BorderSide(
                                              color: AppColors.primaryLightBlue,
                                              width: 1,
                                            ),
                                          ),
                                          child: ListTile(
                                            contentPadding:
                                                EdgeInsets.all(12.r),
                                            leading: CircleAvatar(
                                              backgroundColor:
                                                  AppColors.primaryLightBlue,
                                              child: Text(
                                                order.customerName
                                                    .substring(0, 1)
                                                    .toUpperCase(),
                                                style: TextStyle(
                                                  color: AppColors.primaryBlue,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            title: Text(
                                              order.customerName,
                                              style: AppTextStyles.bodyMedium
                                                  .copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            subtitle: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Services: ${order.services.join(", ")}',
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style:
                                                      AppTextStyles.bodySmall,
                                                ),
                                                Text(
                                                  'Created: ${_formatDate(order.createdAt)}',
                                                  style: AppTextStyles.bodySmall
                                                      .copyWith(
                                                    color: AppColors.grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            trailing: ElevatedButton(
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) =>
                                                        const OrdersScreen(),
                                                  ),
                                                );
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    AppColors.primaryBlue,
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 12.w,
                                                  vertical: 6.h,
                                                ),
                                              ),
                                              child: Text(
                                                'View',
                                                style: AppTextStyles.bodySmall
                                                    .copyWith(
                                                  color: AppColors.white,
                                                ),
                                              ),
                                            ),
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      const OrdersScreen(),
                                                ),
                                              );
                                            },
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _refreshData,
        backgroundColor: AppColors.primaryBlue,
        tooltip: 'Refresh orders',
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: color,
              size: 24.r,
            ),
            SizedBox(height: 8.h),
            Text(
              value,
              style: AppTextStyles.heading3.copyWith(
                color: color,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              title,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: AppColors.lightGrey,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: AppColors.primaryBlue,
                size: 32.r,
              ),
              SizedBox(height: 8.h),
              Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to format date
  String _formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} hr ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}
