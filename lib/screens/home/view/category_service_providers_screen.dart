import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../routes/app_routes.dart';
import '../model/service_provider_model.dart';
import '../provider/service_provider_provider.dart';

class CategoryServiceProvidersScreen extends StatefulWidget {
  final String category;

  const CategoryServiceProvidersScreen({
    Key? key,
    required this.category,
  }) : super(key: key);

  @override
  State<CategoryServiceProvidersScreen> createState() =>
      _CategoryServiceProvidersScreenState();
}

class _CategoryServiceProvidersScreenState
    extends State<CategoryServiceProvidersScreen> {

  @override
  void initState() {
    super.initState();
    _loadServiceProviders();
  }

  Future<void> _loadServiceProviders() async {
    final provider =
        Provider.of<ServiceProviderProvider>(context, listen: false);
    await provider.fetchServiceProvidersByCategory(widget.category);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.category,
          style: AppTextStyles.heading3.copyWith(color: AppColors.white),
        ),
        backgroundColor: AppColors.primaryBlue,
      ),
      body: Consumer<ServiceProviderProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return _buildLoadingIndicator();
          }

          final serviceProviders = provider.serviceProviders;

          if (serviceProviders.isEmpty) {
            return _buildEmptyState();
          }

          return _buildServiceProvidersList(serviceProviders);
        },
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(
        color: AppColors.primaryBlue,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 80.w,
            color: AppColors.primaryLightBlue,
          ),
          SizedBox(height: 16.h),
          Text(
            'No Service Providers Available',
            style: AppTextStyles.heading3,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.w),
            child: Text(
              'We couldn\'t find any service providers for ${widget.category} at the moment.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: _loadServiceProviders,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: AppColors.white,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: Text(
              'Refresh',
              style: AppTextStyles.buttonText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceProvidersList(List<ServiceProviderModel> serviceProviders) {
    return ListView.builder(
      padding: EdgeInsets.all(16.r),
      itemCount: serviceProviders.length,
      itemBuilder: (context, index) {
        final provider = serviceProviders[index];
        return _buildServiceProviderCard(provider);
      },
    );
  }

  Widget _buildServiceProviderCard(ServiceProviderModel provider) {
    return GestureDetector(
      onTap: () {
        Get.toNamed(
          AppRoutes.serviceProviderDetail,
          arguments: {'serviceProviderId': provider.id},
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Provider image
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12.r),
                topRight: Radius.circular(12.r),
              ),
              child: provider.profileImageUrl != null
                  ? Image.network(
                      provider.profileImageUrl!,
                      height: 120.h,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 120.h,
                          width: double.infinity,
                          color: AppColors.primaryLightBlue.withOpacity(0.2),
                          child: Icon(
                            Icons.person,
                            size: 50.w,
                            color: AppColors.primaryBlue,
                          ),
                        );
                      },
                    )
                  : Container(
                      height: 120.h,
                      width: double.infinity,
                      color: AppColors.primaryLightBlue.withOpacity(0.2),
                      child: Icon(
                        Icons.person,
                        size: 50.w,
                        color: AppColors.primaryBlue,
                      ),
                    ),
            ),
            
            // Provider details
            Padding(
              padding: EdgeInsets.all(16.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          provider.name,
                          style: AppTextStyles.heading3,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            color: AppColors.warning,
                            size: 16.w,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            provider.rating.toString(),
                            style: AppTextStyles.bodySmall.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  
                  // Availability status
                  Row(
                    children: [
                      Icon(
                        Icons.circle,
                        size: 12.w,
                        color: provider.isAvailable
                            ? AppColors.success
                            : AppColors.error,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        provider.isAvailable ? 'Available' : 'Unavailable',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: provider.isAvailable
                              ? AppColors.success
                              : AppColors.error,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  
                  // Services
                  if (provider.services.isNotEmpty) ...[
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
                      children: provider.services
                          .take(3)
                          .map(
                            (service) => Chip(
                              label: Text(
                                service,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.primaryDarkBlue,
                                ),
                              ),
                              backgroundColor:
                                  AppColors.primaryLightBlue.withOpacity(0.2),
                              padding: EdgeInsets.zero,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                          )
                          .toList(),
                    ),
                    if (provider.services.length > 3)
                      Text(
                        '+ ${provider.services.length - 3} more',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.grey,
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
