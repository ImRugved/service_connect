import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../routes/app_routes.dart';
import '../../auth/provider/auth_provider.dart';
import '../provider/service_provider_provider.dart' as home_provider;
import '../../home/model/service_provider_model.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  final _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData();
    });
  }

  // Function to refresh all data
  Future<void> _refreshData() async {
    final provider = Provider.of<home_provider.ServiceProviderProvider>(context,
        listen: false);
    await provider.fetchTopServiceProviders();
    await provider.fetchCategories();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _searchServiceProviders(String query) {
    Provider.of<home_provider.ServiceProviderProvider>(context, listen: false)
        .searchServiceProviders(query);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final homeProvider =
        Provider.of<home_provider.ServiceProviderProvider>(context);
    final userName = authProvider.userModel?.name.split(' ').first ?? 'User';

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
            icon: const Icon(Icons.favorite, color: AppColors.primaryBlue),
            onPressed: () {
              // Clear search focus before navigating
              _searchFocusNode.unfocus();
              Get.toNamed(AppRoutes.favorites)!.then((_) {
                // Refresh data when returning from favorites
                Provider.of<home_provider.ServiceProviderProvider>(context,
                        listen: false)
                    .fetchTopServiceProviders();
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.person, color: AppColors.primaryBlue),
            onPressed: () {
              // Clear search focus before navigating
              _searchFocusNode.unfocus();
              Get.toNamed(AppRoutes.profile);
            },
          ),
        ],
      ),
      body: SafeArea(
          child: RefreshIndicator(
        onRefresh: _refreshData,
        color: AppColors.primaryBlue,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                      'What service are you looking for today?',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.grey,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    // Search bar
                    TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      decoration: InputDecoration(
                        hintText: 'Search by name, category or service...',
                        prefixIcon:
                            const Icon(Icons.search, color: AppColors.grey),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear,
                                    color: AppColors.grey),
                                onPressed: () {
                                  _searchController.clear();
                                  _searchServiceProviders('');
                                  // Clear focus when clearing search
                                  _searchFocusNode.unfocus();
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: AppColors.lightGrey.withOpacity(0.3),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                      onChanged: _searchServiceProviders,
                      textInputAction: TextInputAction.search,
                      onSubmitted: (value) {
                        _searchServiceProviders(value);
                        // Clear focus when search is submitted
                        _searchFocusNode.unfocus();
                      },
                    ),
                    // Add a GestureDetector to unfocus when tapping outside the search bar
                    GestureDetector(
                      onTap: () {
                        // Clear focus when tapping outside the search field
                        _searchFocusNode.unfocus();
                      },
                      behavior: HitTestBehavior.translucent,
                      child: Container(height: 0),
                    ),
                  ],
                ),
              ),

              // Categories and Orders navigation buttons
              Padding(
                padding: EdgeInsets.all(16.r),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Get.toNamed(AppRoutes.categories);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.category, color: AppColors.white),
                            SizedBox(width: 8.w),
                            Text(
                              'Categories',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Get.toNamed(AppRoutes.customerOrders);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryLightBlue,
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.receipt_long,
                                color: AppColors.primaryBlue),
                            SizedBox(width: 8.w),
                            Text(
                              'My Orders',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.primaryBlue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Featured Categories section
              Padding(
                padding: EdgeInsets.all(16.r),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Featured Categories',
                      style: AppTextStyles.heading3,
                    ),
                    TextButton(
                      onPressed: () {
                        Get.toNamed(AppRoutes.categories);
                      },
                      child: Text(
                        'View All',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _buildCategoriesSection(homeProvider),

              // Search results
              if (_searchController.text.isNotEmpty)
                _buildSearchResults(homeProvider)
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top service providers section
                    Padding(
                      padding: EdgeInsets.all(16.r),
                      child: Text(
                        'Top Service Providers',
                        style: AppTextStyles.heading3,
                      ),
                    ),
                    _buildTopServiceProvidersSection(homeProvider),
                  ],
                ),
            ],
          ),
        ),
      )),
    );
  }

  Widget _buildSearchResults(home_provider.ServiceProviderProvider provider) {
    if (provider.isSearching) {
      return _buildSearchShimmer();
    }

    if (provider.searchResults.isEmpty) {
      return SizedBox(
        height: 200.h,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off,
                size: 48.w,
                color: AppColors.grey,
              ),
              SizedBox(height: 16.h),
              Text(
                'No service providers found',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(16.r),
      itemCount: provider.searchResults.length,
      itemBuilder: (context, index) {
        final serviceProvider = provider.searchResults[index];
        return _buildServiceProviderCard(serviceProvider);
      },
    );
  }

  Widget _buildSearchShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.all(16.r),
        itemCount: 3,
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.only(bottom: 16.h),
            padding: EdgeInsets.all(16.r),
            height: 120.h,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12.r),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoriesSection(
      home_provider.ServiceProviderProvider provider) {
    // Fixed list of categories that should always be shown
    final List<String> fixedCategories = [
      'Cleaning',
      'Plumbing',
      'Electrical',
      'Carpentry',
      'Painting',
      'Gardening',
      'Moving',
      'Beauty',
      'Other'
    ];

    // Combine fixed categories with any from the provider
    final Set<String> allCategories = {...fixedCategories};
    if (!provider.isLoading && provider.categories.isNotEmpty) {
      allCategories.addAll(provider.categories);
    }

    // Convert back to list for display
    final List<String> displayCategories = allCategories.toList();

    if (provider.isLoading) {
      return _buildCategoriesShimmer();
    }

    if (displayCategories.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Center(
          child: Text(
            'No categories available',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.grey,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 120.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: displayCategories.length,
        itemBuilder: (context, index) {
          return _buildCategoryCard(displayCategories[index]);
        },
      ),
    );
  }

  Widget _buildCategoriesShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: SizedBox(
        height: 120.h,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          itemCount: 5,
          itemBuilder: (context, index) {
            return Container(
              width: 100.w,
              margin: EdgeInsets.only(right: 16.w),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12.r),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCategoryCard(String category) {
    IconData iconData;
    switch (category) {
      case 'Cleaning':
        iconData = Icons.cleaning_services;
        break;
      case 'Plumbing':
        iconData = Icons.plumbing;
        break;
      case 'Electrical':
        iconData = Icons.electrical_services;
        break;
      case 'Carpentry':
        iconData = Icons.carpenter;
        break;
      case 'Painting':
        iconData = Icons.format_paint;
        break;
      case 'Gardening':
        iconData = Icons.yard;
        break;
      case 'Moving':
        iconData = Icons.local_shipping;
        break;
      case 'Appliance Repair':
        iconData = Icons.home_repair_service;
        break;
      case 'Beauty & Wellness':
        iconData = Icons.spa;
        break;
      default:
        iconData = Icons.miscellaneous_services;
    }

    return GestureDetector(
      onTap: () {
        // Clear search focus before navigating
        _searchFocusNode.unfocus();
        Get.toNamed(
          AppRoutes.categoryServiceProviders,
          arguments: {'category': category},
        );
      },
      child: Container(
        width: 100.w,
        margin: EdgeInsets.only(right: 16.w),
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: AppColors.primaryLightBlue.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                iconData,
                color: AppColors.primaryBlue,
                size: 30.w,
              ),
            ),
            SizedBox(height: 8.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: Text(
                category,
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopServiceProvidersSection(
      home_provider.ServiceProviderProvider provider) {
    if (provider.isLoading) {
      return _buildServiceProvidersShimmer();
    }

    if (provider.topServiceProviders.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(16.r),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.person_search,
                size: 48.w,
                color: AppColors.grey,
              ),
              SizedBox(height: 16.h),
              Text(
                'No service providers available yet',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(16.r),
      itemCount: provider.topServiceProviders.length,
      itemBuilder: (context, index) {
        final serviceProvider = provider.topServiceProviders[index];
        return _buildServiceProviderCard(serviceProvider);
      },
    );
  }

  Widget _buildServiceProvidersShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.all(16.r),
        itemCount: 3,
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.only(bottom: 16.h),
            padding: EdgeInsets.all(16.r),
            height: 120.h,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12.r),
            ),
          );
        },
      ),
    );
  }

  Widget _buildServiceProviderCard(ServiceProviderModel serviceProvider) {
    return GestureDetector(
      onTap: () {
        // Clear search focus before navigating
        _searchFocusNode.unfocus();
        Get.toNamed(
          AppRoutes.serviceProviderDetail,
          arguments: {'serviceProviderId': serviceProvider.id},
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
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
            // Profile image
            Container(
              width: 70.w,
              height: 70.w,
              decoration: BoxDecoration(
                color: AppColors.primaryLightBlue.withOpacity(0.2),
                shape: BoxShape.circle,
                image: serviceProvider.profileImageUrl != null
                    ? DecorationImage(
                        image: NetworkImage(serviceProvider.profileImageUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: serviceProvider.profileImageUrl == null
                  ? Icon(
                      Icons.person,
                      color: AppColors.primaryBlue,
                      size: 40.w,
                    )
                  : null,
            ),
            SizedBox(width: 16.w),
            // Provider details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    serviceProvider.name,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    serviceProvider.category,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.grey,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      // Rating
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 16.w,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            serviceProvider.rating.toStringAsFixed(1),
                            style: AppTextStyles.bodySmall,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            '(${serviceProvider.reviewCount})',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.grey,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: 16.w),
                      // Availability
                      Row(
                        children: [
                          Icon(
                            Icons.circle,
                            color: serviceProvider.isAvailable
                                ? AppColors.success
                                : AppColors.error,
                            size: 8.w,
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
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Arrow icon
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
}
