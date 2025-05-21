import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../routes/app_routes.dart';
import '../model/service_provider_model.dart';
import '../provider/service_provider_provider.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch favorite service providers when the screen is loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ServiceProviderProvider>(context, listen: false)
          .fetchFavoriteServiceProviders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Favorites',
          style: AppTextStyles.heading3.copyWith(color: AppColors.white),
        ),
        backgroundColor: AppColors.primaryBlue,
      ),
      body: Consumer<ServiceProviderProvider>(
        builder: (context, provider, child) {
          final favoriteProviders = provider.favoriteServiceProviders;
          
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryBlue,
              ),
            );
          }
          
          if (favoriteProviders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 80.w,
                    color: AppColors.primaryLightBlue,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'No favorites yet',
                    style: AppTextStyles.heading3,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Add service providers to your favorites',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }
          
          return ListView.builder(
            padding: EdgeInsets.all(16.r),
            itemCount: favoriteProviders.length,
            itemBuilder: (context, index) {
              final provider = favoriteProviders[index];
              return _buildServiceProviderCard(provider);
            },
          );
        },
      ),
    );
  }

  Widget _buildServiceProviderCard(ServiceProviderModel provider) {
    return GestureDetector(
      onTap: () {
        Get.toNamed(
          AppRoutes.serviceProviderDetail,
          arguments: {'serviceProviderId': provider.id},
        )!.then((_) {
          // Refresh the list when returning from details
          Provider.of<ServiceProviderProvider>(context, listen: false)
              .fetchFavoriteServiceProviders();
        });
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
                  
                  // Category
                  Text(
                    provider.category,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.grey,
                    ),
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
                  
                  // Remove from favorites button
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () async {
                        final serviceProvider = Provider.of<ServiceProviderProvider>(
                            context, listen: false);
                        await serviceProvider.toggleFavorite(provider.id);
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${provider.name} removed from favorites'),
                            backgroundColor: AppColors.primaryBlue,
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.favorite,
                        color: AppColors.error,
                      ),
                      label: Text(
                        'Remove',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
