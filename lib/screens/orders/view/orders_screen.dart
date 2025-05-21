import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../service_provider/provider/service_provider_provider.dart';
import '../model/order_model.dart';
import '../provider/order_provider.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Load orders when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOrders();
    });
  }

  Future<void> _loadOrders() async {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    await orderProvider.fetchServiceProviderOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        actions: [
          // Availability toggle
          Consumer<OrderProvider>(
            builder: (context, provider, child) {
              return provider.isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : Switch(
                      value: provider
                          .isAvailable, // Use the actual availability status from provider
                      onChanged: (value) async {
                        await provider.toggleAvailability();
                        // Refresh orders after toggling availability
                        await provider.fetchServiceProviderOrders();

                        // Force refresh of service providers in customer screens
                        try {
                          // Get the ServiceProviderProvider and refresh its data
                          final serviceProviderProvider =
                              Provider.of<ServiceProviderProvider>(context,
                                  listen: false);
                          await serviceProviderProvider
                              .fetchTopServiceProviders();
                        } catch (e) {
                          // If this fails, it's not critical
                          print('Failed to refresh service providers: $e');
                        }
                      },
                      activeColor: AppColors.success,
                      activeTrackColor: AppColors.success.withOpacity(0.5),
                      inactiveThumbColor: AppColors.error,
                      inactiveTrackColor: AppColors.error.withOpacity(0.5),
                    );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'New'),
            Tab(text: 'Ongoing'),
            Tab(text: 'Completed'),
          ],
          labelColor: AppColors.primaryBlue,
          unselectedLabelColor: AppColors.grey,
          indicatorColor: AppColors.primaryBlue,
        ),
      ),
      body: Consumer<OrderProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Use a simpler approach with TabBarView
          return TabBarView(
            controller: _tabController,
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              // New Orders Tab
              _buildOrdersList(
                provider.newOrders,
                (order) => _buildNewOrderCard(context, order, provider),
                'No new orders',
              ),

              // Ongoing Orders Tab
              _buildOrdersList(
                provider.ongoingOrders,
                (order) => _buildOngoingOrderCard(context, order, provider),
                'No ongoing orders',
              ),

              // Completed Orders Tab
              _buildOrdersList(
                provider.completedOrders,
                (order) => _buildCompletedOrderCard(context, order),
                'No completed orders',
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadOrders,
        backgroundColor: AppColors.primaryBlue,
        tooltip: 'Refresh orders',
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildOrdersList(
    List<OrderModel> orders,
    Widget Function(OrderModel) cardBuilder,
    String emptyMessage,
  ) {
    if (orders.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 64.w,
                    color: AppColors.grey,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    emptyMessage,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(16.r),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        return cardBuilder(orders[index]);
      },
    );
  }

  Widget _buildNewOrderCard(
      BuildContext context, OrderModel order, OrderProvider provider) {
    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order header
            Row(
              children: [
                const Icon(
                  Icons.person,
                  color: AppColors.primaryBlue,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    order.customerName,
                    style: AppTextStyles.heading4,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLightBlue,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Text(
                    'New',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),

            // Services
            Text(
              'Services:',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: order.services.map((service) {
                return Chip(
                  label: Text(
                    service,
                    style: AppTextStyles.bodySmall,
                  ),
                  backgroundColor: AppColors.primaryLightBlue,
                );
              }).toList(),
            ),
            SizedBox(height: 16.h),

            // Contact info
            _buildOrderInfoItem(
              icon: Icons.phone,
              title: 'Phone',
              value: order.phoneNumber,
            ),
            SizedBox(height: 8.h),
            _buildOrderInfoItem(
              icon: Icons.location_on,
              title: 'Address',
              value: order.address,
            ),

            // Notes if any
            if (order.notes.isNotEmpty) ...[
              SizedBox(height: 8.h),
              _buildOrderInfoItem(
                icon: Icons.note,
                title: 'Notes',
                value: order.notes,
              ),
            ],

            SizedBox(height: 16.h),

            // Date
            Text(
              'Ordered on: ${_formatDate(order.createdAt)}',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.grey,
              ),
            ),

            SizedBox(height: 16.h),

            // Action button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final success = await provider.startOrder(order.id);
                  if (success && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Order started successfully'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                ),
                child: Text('Start Order',
                    style: TextStyle(
                      color: AppColors.white,
                    )),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOngoingOrderCard(
      BuildContext context, OrderModel order, OrderProvider provider) {
    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order header
            Row(
              children: [
                const Icon(
                  Icons.person,
                  color: AppColors.primaryBlue,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    order.customerName,
                    style: AppTextStyles.heading4,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Text(
                    'Ongoing',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.amber[800],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),

            // Services
            Text(
              'Services:',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: order.services.map((service) {
                return Chip(
                  label: Text(
                    service,
                    style: AppTextStyles.bodySmall,
                  ),
                  backgroundColor: AppColors.primaryLightBlue,
                );
              }).toList(),
            ),
            SizedBox(height: 16.h),

            // Contact info
            _buildOrderInfoItem(
              icon: Icons.phone,
              title: 'Phone',
              value: order.phoneNumber,
            ),
            SizedBox(height: 8.h),
            _buildOrderInfoItem(
              icon: Icons.location_on,
              title: 'Address',
              value: order.address,
            ),

            // Notes if any
            if (order.notes.isNotEmpty) ...[
              SizedBox(height: 8.h),
              _buildOrderInfoItem(
                icon: Icons.note,
                title: 'Notes',
                value: order.notes,
              ),
            ],

            SizedBox(height: 16.h),

            // Dates
            Text(
              'Ordered on: ${_formatDate(order.createdAt)}',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.grey,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'Started on: ${_formatDate(order.startedAt!)}',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.grey,
              ),
            ),

            SizedBox(height: 16.h),

            // Action button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final success = await provider.completeOrder(order.id);
                  if (success && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Order completed successfully'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                ),
                child: const Text('Complete Order',
                    style: TextStyle(
                      color: AppColors.white,
                    )),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedOrderCard(BuildContext context, OrderModel order) {
    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order header
            Row(
              children: [
                const Icon(
                  Icons.person,
                  color: AppColors.primaryBlue,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    order.customerName,
                    style: AppTextStyles.heading4,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Text(
                    'Completed',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),

            // Services
            Text(
              'Services:',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: order.services.map((service) {
                return Chip(
                  label: Text(
                    service,
                    style: AppTextStyles.bodySmall,
                  ),
                  backgroundColor: AppColors.primaryLightBlue,
                );
              }).toList(),
            ),
            SizedBox(height: 16.h),

            // Contact info
            _buildOrderInfoItem(
              icon: Icons.phone,
              title: 'Phone',
              value: order.phoneNumber,
            ),
            SizedBox(height: 8.h),
            _buildOrderInfoItem(
              icon: Icons.location_on,
              title: 'Address',
              value: order.address,
            ),

            // Notes if any
            if (order.notes.isNotEmpty) ...[
              SizedBox(height: 8.h),
              _buildOrderInfoItem(
                icon: Icons.note,
                title: 'Notes',
                value: order.notes,
              ),
            ],

            SizedBox(height: 16.h),

            // Dates
            Text(
              'Ordered on: ${_formatDate(order.createdAt)}',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.grey,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'Started on: ${_formatDate(order.startedAt!)}',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.grey,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'Completed on: ${_formatDate(order.completedAt!)}',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderInfoItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18.w,
          color: AppColors.primaryBlue,
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.grey,
                ),
              ),
              Text(
                value,
                style: AppTextStyles.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
