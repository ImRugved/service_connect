import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../routes/app_routes.dart';
import '../provider/service_provider_provider.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _filteredCategories = [];
  List<String> _allCategories = [];

  @override
  void initState() {
    super.initState();
    // Initialize with the fixed list of categories
    _allCategories = [
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
    _filteredCategories = _allCategories;

    // Also fetch any additional categories from the database
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCategories();
    });
  }

  Future<void> _loadCategories() async {
    final provider =
        Provider.of<ServiceProviderProvider>(context, listen: false);
    await provider.fetchCategories();

    // Merge the fixed categories with any additional ones from the database
    setState(() {
      final Set<String> uniqueCategories = {
        ..._allCategories,
        ...provider.categories
      };
      _allCategories = uniqueCategories.toList();
      _filteredCategories = _allCategories;
    });
  }

  void _filterCategories(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredCategories = _allCategories;
      } else {
        _filteredCategories = _allCategories
            .where((category) =>
                category.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Categories',
          style: AppTextStyles.heading3,
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primaryBlue),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: EdgeInsets.all(16.r),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search categories...',
                prefixIcon: const Icon(Icons.search, color: AppColors.grey),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: AppColors.grey),
                        onPressed: () {
                          _searchController.clear();
                          _filterCategories('');
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
              onChanged: _filterCategories,
            ),
          ),

          // Categories grid
          Expanded(
            child: Consumer<ServiceProviderProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (_filteredCategories.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.category_outlined,
                          size: 64.w,
                          color: AppColors.grey,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'No categories found',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  padding: EdgeInsets.all(16.r),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.0,
                    crossAxisSpacing: 16.w,
                    mainAxisSpacing: 16.h,
                  ),
                  itemCount: _filteredCategories.length,
                  itemBuilder: (context, index) {
                    return _buildCategoryCard(_filteredCategories[index]);
                  },
                );
              },
            ),
          ),
        ],
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
      case 'Beauty':
        iconData = Icons.spa;
        break;
      case 'Other':
        iconData = Icons.miscellaneous_services;
        break;
      default:
        iconData = Icons.miscellaneous_services;
    }

    return GestureDetector(
      onTap: () {
        Get.toNamed(
          AppRoutes.categoryServiceProviders,
          arguments: {'category': category},
        );
      },
      child: Container(
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
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: AppColors.primaryLightBlue.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                iconData,
                color: AppColors.primaryBlue,
                size: 36.w,
              ),
            ),
            SizedBox(height: 12.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: Text(
                category,
                style: AppTextStyles.bodyMedium.copyWith(
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
}
