import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../model/order_model.dart';
import '../provider/order_provider.dart';

class CustomerOrdersScreen extends StatefulWidget {
  const CustomerOrdersScreen({super.key});

  @override
  State<CustomerOrdersScreen> createState() => _CustomerOrdersScreenState();
}

class _CustomerOrdersScreenState extends State<CustomerOrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
    await orderProvider.fetchCustomerOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
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

          return RefreshIndicator(
            onRefresh: _loadOrders,
            color: AppColors.primaryBlue,
            child: TabBarView(
              controller: _tabController,
              children: [
                // New Orders Tab
                _buildOrdersList(
                  provider.newOrders,
                  (order) => _buildNewOrderCard(context, order),
                  'No new bookings',
                ),

                // Ongoing Orders Tab
                _buildOrdersList(
                  provider.ongoingOrders,
                  (order) => _buildOngoingOrderCard(context, order),
                  'No ongoing bookings',
                ),

                // Completed Orders Tab
                _buildOrdersList(
                  provider.completedOrders,
                  (order) => _buildCompletedOrderCard(context, order),
                  'No completed bookings',
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadOrders,
        backgroundColor: AppColors.primaryBlue,
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildOrdersList(
    List<OrderModel> orders,
    Widget Function(OrderModel) cardBuilder,
    String emptyMessage,
  ) {
    return RefreshIndicator(
      onRefresh: _loadOrders,
      color: AppColors.primaryBlue,
      child: orders.isEmpty
          ? ListView(
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
            )
          : ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(16.r),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                return cardBuilder(orders[index]);
              },
            ),
    );
  }

  Widget _buildNewOrderCard(BuildContext context, OrderModel order) {
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
                  Icons.business,
                  color: AppColors.primaryBlue,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    order.serviceProviderName,
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
            SizedBox(height: 8.h),
            Text(
              order.serviceCategory,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.grey,
              ),
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

            // Notes if any
            if (order.notes.isNotEmpty) ...[
              Text(
                'Your Notes:',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                order.notes,
                style: AppTextStyles.bodyMedium,
              ),
              SizedBox(height: 16.h),
            ],

            // Date
            Text(
              'Booked on: ${_formatDate(order.createdAt)}',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.grey,
              ),
            ),

            SizedBox(height: 16.h),

            // Status message
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: AppColors.primaryLightBlue.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                'Waiting for service provider to accept your booking',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primaryBlue,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOngoingOrderCard(BuildContext context, OrderModel order) {
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
                  Icons.business,
                  color: AppColors.primaryBlue,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    order.serviceProviderName,
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
            SizedBox(height: 8.h),
            Text(
              order.serviceCategory,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.grey,
              ),
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

            // Notes if any
            if (order.notes.isNotEmpty) ...[
              Text(
                'Your Notes:',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                order.notes,
                style: AppTextStyles.bodyMedium,
              ),
              SizedBox(height: 16.h),
            ],

            // Dates
            Text(
              'Booked on: ${_formatDate(order.createdAt)}',
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

            // Status message
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                'Service provider is working on your order',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.amber[800],
                ),
                textAlign: TextAlign.center,
              ),
            ),

            SizedBox(height: 16.h),

            // Contact button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  // Implement contact functionality
                },
                icon: const Icon(Icons.phone),
                label: const Text('Contact Service Provider'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryBlue,
                  side: BorderSide(color: AppColors.primaryBlue),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                ),
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
                  Icons.business,
                  color: AppColors.primaryBlue,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    order.serviceProviderName,
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
            SizedBox(height: 8.h),
            Text(
              order.serviceCategory,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.grey,
              ),
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

            // Notes if any
            if (order.notes.isNotEmpty) ...[
              Text(
                'Your Notes:',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                order.notes,
                style: AppTextStyles.bodyMedium,
              ),
              SizedBox(height: 16.h),
            ],

            // Dates
            Text(
              'Booked on: ${_formatDate(order.createdAt)}',
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

            SizedBox(height: 16.h),

            // Status message
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                'Service completed successfully',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.success,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            SizedBox(height: 16.h),

            // Book again button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Navigate to service provider detail screen
                },
                icon: const Icon(Icons.repeat),
                label: const Text('Book Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
