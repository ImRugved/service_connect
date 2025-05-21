import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../screens/orders/provider/order_provider.dart';
import '../provider/service_provider_provider.dart';

class ServiceProviderDetailScreen extends StatefulWidget {
  final String serviceProviderId;

  const ServiceProviderDetailScreen({
    super.key,
    required this.serviceProviderId,
  });

  @override
  State<ServiceProviderDetailScreen> createState() =>
      _ServiceProviderDetailScreenState();
}

class _ServiceProviderDetailScreenState
    extends State<ServiceProviderDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback to ensure the widget is fully built before updating state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadServiceProviderDetails();
    });
  }

  Future<void> _loadServiceProviderDetails() async {
    final provider =
        Provider.of<ServiceProviderProvider>(context, listen: false);
    await provider.loadServiceProviderDetails(widget.serviceProviderId);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ServiceProviderProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: provider.isDetailLoading
              ? _buildLoadingShimmer()
              : provider.currentServiceProvider == null
                  ? _buildErrorView()
                  : _buildServiceProviderDetail(provider),
        );
      },
    );
  }

  Widget _buildLoadingShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              height: 250.h,
              color: Colors.white,
            ),
            Padding(
              padding: EdgeInsets.all(16.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  Container(
                    height: 24.h,
                    width: 200.w,
                    color: Colors.white,
                  ),
                  SizedBox(height: 8.h),
                  // Category
                  Container(
                    height: 16.h,
                    width: 100.w,
                    color: Colors.white,
                  ),
                  SizedBox(height: 16.h),
                  // Rating
                  Container(
                    height: 16.h,
                    width: 150.w,
                    color: Colors.white,
                  ),
                  SizedBox(height: 24.h),
                  // About
                  Container(
                    height: 16.h,
                    width: 100.w,
                    color: Colors.white,
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    height: 80.h,
                    color: Colors.white,
                  ),
                  SizedBox(height: 24.h),
                  // Services
                  Container(
                    height: 16.h,
                    width: 100.w,
                    color: Colors.white,
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    height: 40.h,
                    color: Colors.white,
                  ),
                  SizedBox(height: 24.h),
                  // Contact
                  Container(
                    height: 16.h,
                    width: 100.w,
                    color: Colors.white,
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    height: 80.h,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64.w,
            color: AppColors.error,
          ),
          SizedBox(height: 16.h),
          Text(
            'Failed to load service provider details',
            style: AppTextStyles.heading3,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          Text(
            'Please try again later',
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: _loadServiceProviderDetails,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: AppColors.white,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceProviderDetail(ServiceProviderProvider provider) {
    final serviceProvider = provider.currentServiceProvider!;
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            // App bar with image
            SliverAppBar(
              expandedHeight: 200.h,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: serviceProvider.profileImageUrl != null &&
                        serviceProvider.profileImageUrl!.isNotEmpty
                    ? Image.network(
                        serviceProvider.profileImageUrl!,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        color: AppColors.primaryLightBlue,
                        child: Icon(
                          Icons.person,
                          size: 80.w,
                          color: AppColors.primaryBlue,
                        ),
                      ),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    provider.isFavorite(serviceProvider.id) == true
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: provider.isFavorite(serviceProvider.id) == true
                        ? AppColors.error
                        : AppColors.white,
                  ),
                  onPressed: () {
                    provider.toggleFavorite(serviceProvider.id);
                  },
                ),
              ],
            ),
            // Content
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name and category
                    Text(
                      serviceProvider.name,
                      style: AppTextStyles.heading2,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      serviceProvider.category,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.grey,
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Rating and availability
                    Row(
                      children: [
                        // Rating
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 20.w,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              serviceProvider.rating.toString(),
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              '(${serviceProvider.reviewCount} reviews)',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.grey,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: 24.w),
                        // Availability
                        Row(
                          children: [
                            Icon(
                              Icons.circle,
                              color: serviceProvider.isAvailable
                                  ? AppColors.success
                                  : AppColors.error,
                              size: 10.w,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              serviceProvider.isAvailable
                                  ? 'Available'
                                  : 'Unavailable',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: serviceProvider.isAvailable
                                    ? AppColors.success
                                    : AppColors.error,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    SizedBox(height: 24.h),

                    // About section
                    Text(
                      'About',
                      style: AppTextStyles.heading3,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      serviceProvider.description,
                      style: AppTextStyles.bodyMedium,
                    ),

                    SizedBox(height: 24.h),

                    // Services section
                    Text(
                      'Services',
                      style: AppTextStyles.heading3,
                    ),
                    SizedBox(height: 8.h),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: serviceProvider.services.map((service) {
                        return Container(
                          decoration: BoxDecoration(
                            //  color: AppColors.white,
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 8.w),
                          child: Chip(
                            label: Text(service),
                            backgroundColor: Colors.transparent,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                        );
                      }).toList(),
                    ),

                    SizedBox(height: 24.h),

                    // Contact section
                    Text(
                      'Contact',
                      style: AppTextStyles.heading3,
                    ),
                    SizedBox(height: 8.h),
                    _buildContactItem(
                      icon: Icons.phone,
                      title: 'Phone',
                      value: serviceProvider.phoneNumber,
                    ),
                    SizedBox(height: 8.h),
                    _buildContactItem(
                      icon: Icons.email,
                      title: 'Email',
                      value: serviceProvider.email,
                    ),
                    SizedBox(height: 8.h),
                    _buildContactItem(
                      icon: Icons.location_on,
                      title: 'Address',
                      value: serviceProvider.address ?? '',
                    ),

                    SizedBox(height: 24.h),

                    // Business hours section
                    Text(
                      'Business Hours',
                      style: AppTextStyles.heading3,
                    ),
                    SizedBox(height: 8.h),
                    _buildBusinessHours(serviceProvider.businessHours),

                    // Add extra padding at the bottom for the floating button
                    SizedBox(height: 80.h),
                  ],
                ),
              ),
            ),
          ],
        ),
        // Booking button at the bottom
        Positioned(
          bottom: 16.h,
          left: 16.w,
          right: 16.w,
          child: ElevatedButton(
            onPressed: serviceProvider.isAvailable == true
                ? () =>
                    _showBookingDialog(context, serviceProvider, orderProvider)
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              disabledBackgroundColor: AppColors.lightGrey,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: Text(
              serviceProvider.isAvailable
                  ? 'Book Now'
                  : 'Currently Unavailable',
              style: AppTextStyles.buttonText,
            ),
          ),
        ),
      ],
    );
  }

  // Show booking dialog
  void _showBookingDialog(BuildContext context, dynamic serviceProvider,
      OrderProvider orderProvider) {
    final notesController = TextEditingController();
    final selectedServices = <String>[];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Book ${serviceProvider.name}'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Services',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  // Service checkboxes
                  ...serviceProvider.services.map((service) => CheckboxListTile(
                        title: Text(service),
                        value: selectedServices.contains(service),
                        onChanged: (value) {
                          setState(() {
                            if (value == true) {
                              selectedServices.add(service);
                            } else {
                              selectedServices.remove(service);
                            }
                          });
                        },
                      )),
                  SizedBox(height: 16.h),
                  // Notes field
                  TextField(
                    controller: notesController,
                    decoration: InputDecoration(
                      labelText: 'Additional Notes',
                      hintText: 'Any special requirements?',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.grey,
                ),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: selectedServices.isEmpty
                    ? null
                    : () async {
                        try {
                          Navigator.pop(context); // Close the booking dialog
                          
                          // Show loading indicator
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );

                          // Create order
                          final success = await orderProvider.createOrder(
                            serviceProviderId: serviceProvider.id,
                            serviceProviderName: serviceProvider.name,
                            serviceCategory: serviceProvider.category,
                            services: selectedServices,
                            notes: notesController.text.trim(),
                          );
                          
                          // Fetch customer orders to update the list
                          if (success) {
                            await orderProvider.fetchCustomerOrders();
                          }

                          // Check if context is still valid before proceeding
                          if (!context.mounted) return;
                          
                          // Close loading indicator
                          Navigator.pop(context);

                          // Show result
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                success
                                    ? 'Booking successful! The service provider will contact you soon.'
                                    : orderProvider.errorMessage ??
                                        'Failed to create booking',
                              ),
                              backgroundColor:
                                  success ? AppColors.success : AppColors.error,
                            ),
                          );
                          
                          // If booking was successful, navigate to customer orders screen
                          if (success) {
                            Future.delayed(const Duration(milliseconds: 500), () {
                              if (context.mounted) {
                                Navigator.pushReplacementNamed(context, '/customer-orders');
                              }
                            });
                          }
                        } catch (e) {
                          // Handle any unexpected errors
                          if (context.mounted) {
                            // Make sure we close the loading dialog if it's open
                            Navigator.of(context).popUntil((route) => route.isFirst);
                            
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('An error occurred: ${e.toString()}'),
                                backgroundColor: AppColors.error,
                              ),
                            );
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.lightGrey,
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
                ),
                child: Text('Book', style: AppTextStyles.buttonText),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20.w,
          color: AppColors.primaryBlue,
        ),
        SizedBox(width: 12.w),
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
              SizedBox(height: 2.h),
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

  Widget _buildBusinessHours(Map<String, dynamic>? businessHours) {
    if (businessHours == null) {
      return const Text('Business hours not available');
    }
    final days = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday',
    ];

    return Column(
      children: days.map((day) {
        final hours = businessHours[day] ?? {'start': '', 'end': ''};
        final isClosed = hours['start'] == null ||
            hours['start'] == '' ||
            hours['end'] == null ||
            hours['end'] == '';

        return Padding(
          padding: EdgeInsets.only(bottom: 8.h),
          child: Row(
            children: [
              SizedBox(
                width: 100.w,
                child: Text(
                  day.substring(0, 1).toUpperCase() + day.substring(1),
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                isClosed ? 'Closed' : '${hours['start']} - ${hours['end']}',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isClosed ? AppColors.error : AppColors.black,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
