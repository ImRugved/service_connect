import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../auth/provider/auth_provider.dart';
import '../provider/service_provider_provider.dart';
import 'service_provider_home_screen.dart';

class ServiceProviderSetupScreen extends StatefulWidget {
  const ServiceProviderSetupScreen({super.key});

  @override
  State<ServiceProviderSetupScreen> createState() => _ServiceProviderSetupScreenState();
}

class _ServiceProviderSetupScreenState extends State<ServiceProviderSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  
  String _selectedCategory = 'Cleaning';
  final List<String> _categories = [
    'Cleaning',
    'Plumbing',
    'Electrical',
    'Carpentry',
    'Painting',
    'Gardening',
    'Moving',
    'Appliance Repair',
    'Beauty & Wellness',
    'Other'
  ];
  
  final List<String> _selectedServices = [];
  final Map<String, List<String>> _categoryServices = {
    'Cleaning': ['House Cleaning', 'Office Cleaning', 'Carpet Cleaning', 'Window Cleaning'],
    'Plumbing': ['Pipe Repair', 'Drain Cleaning', 'Fixture Installation', 'Water Heater'],
    'Electrical': ['Wiring', 'Lighting', 'Electrical Repairs', 'Installation'],
    'Carpentry': ['Furniture Assembly', 'Custom Furniture', 'Woodwork', 'Repairs'],
    'Painting': ['Interior Painting', 'Exterior Painting', 'Wall Painting', 'Decorative Painting'],
    'Gardening': ['Lawn Mowing', 'Planting', 'Tree Trimming', 'Landscaping'],
    'Moving': ['Home Moving', 'Office Moving', 'Packing Services', 'Furniture Moving'],
    'Appliance Repair': ['Refrigerator', 'Washing Machine', 'Dishwasher', 'Oven/Stove'],
    'Beauty & Wellness': ['Haircut', 'Massage', 'Manicure/Pedicure', 'Makeup'],
    'Other': ['Custom Service'],
  };

  @override
  void dispose() {
    _descriptionController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _saveDetails() async {
    if (_formKey.currentState!.validate() && _selectedServices.isNotEmpty) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      final serviceProviderDetails = {
        'category': _selectedCategory,
        'description': _descriptionController.text.trim(),
        'services': _selectedServices,
        'rating': 0.0,
        'reviewCount': 0,
        'isAvailable': true,
        'businessHours': {
          'monday': {'start': '09:00', 'end': '17:00'},
          'tuesday': {'start': '09:00', 'end': '17:00'},
          'wednesday': {'start': '09:00', 'end': '17:00'},
          'thursday': {'start': '09:00', 'end': '17:00'},
          'friday': {'start': '09:00', 'end': '17:00'},
          'saturday': {'start': '10:00', 'end': '15:00'},
          'sunday': {'start': '', 'end': ''},
        },
      };
      
      final success = await authProvider.updateServiceProviderDetails(serviceProviderDetails);
      
      if (success) {
        await authProvider.updateUserProfile(
          address: _addressController.text.trim(),
        );
        
        // Update categories in Firestore to ensure this service provider's category is included
        final firestore = FirebaseFirestore.instance;
        await firestore.collection('categories').doc(_selectedCategory.toLowerCase()).set({
          'name': _selectedCategory,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        
        // Get the service provider provider to update its data
        final serviceProviderProvider = Provider.of<ServiceProviderProvider>(context, listen: false);
        // Force refresh the categories and top service providers
        await serviceProviderProvider.fetchCategories();
        await serviceProviderProvider.fetchTopServiceProviders();
        
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const ServiceProviderHomeScreen()),
          );
        }
      }
    } else if (_selectedServices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one service'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Complete Your Profile',
          style: AppTextStyles.heading3,
        ),
        centerTitle: true,
        backgroundColor: AppColors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info card
                  Container(
                    padding: EdgeInsets.all(16.r),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLightBlue.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: AppColors.primaryLightBlue,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppColors.primaryBlue,
                          size: 24.w,
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            'Please provide details about your services to complete your profile.',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.primaryDarkBlue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 24.h),
                  
                  // Category selection
                  Text(
                    'Select your service category',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  
                  SizedBox(height: 12.h),
                  
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: AppColors.lightGrey),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedCategory,
                        isExpanded: true,
                        icon: const Icon(Icons.arrow_drop_down),
                        style: AppTextStyles.bodyMedium,
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedCategory = newValue;
                              _selectedServices.clear();
                            });
                          }
                        },
                        items: _categories.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 24.h),
                  
                  // Services selection
                  Text(
                    'Select your services',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  
                  SizedBox(height: 12.h),
                  
                  Container(
                    padding: EdgeInsets.all(16.r),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: AppColors.lightGrey),
                    ),
                    child: Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: _categoryServices[_selectedCategory]!.map((service) {
                        final isSelected = _selectedServices.contains(service);
                        return FilterChip(
                          label: Text(service),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedServices.add(service);
                              } else {
                                _selectedServices.remove(service);
                              }
                            });
                          },
                          backgroundColor: AppColors.white,
                          selectedColor: AppColors.primaryLightBlue,
                          checkmarkColor: AppColors.primaryDarkBlue,
                          labelStyle: AppTextStyles.bodySmall.copyWith(
                            color: isSelected ? AppColors.primaryDarkBlue : AppColors.black,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                            side: BorderSide(
                              color: isSelected ? AppColors.primaryBlue : AppColors.lightGrey,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  
                  SizedBox(height: 24.h),
                  
                  // Description
                  Text(
                    'Describe your services',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  
                  SizedBox(height: 12.h),
                  
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: 'Tell customers about your experience, skills, and services...',
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
                      filled: true,
                      fillColor: AppColors.white,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please describe your services';
                      }
                      if (value.length < 50) {
                        return 'Description should be at least 50 characters';
                      }
                      return null;
                    },
                  ),
                  
                  SizedBox(height: 24.h),
                  
                  // Address
                  Text(
                    'Your address',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  
                  SizedBox(height: 12.h),
                  
                  TextFormField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      hintText: 'Enter your address',
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
                      filled: true,
                      fillColor: AppColors.white,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your address';
                      }
                      return null;
                    },
                  ),
                  
                  SizedBox(height: 32.h),
                  
                  // Error message
                  if (authProvider.errorMessage != null)
                    Container(
                      padding: EdgeInsets.all(12.r),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        authProvider.errorMessage!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.error,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  
                  SizedBox(height: 24.h),
                  
                  // Save button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: authProvider.isLoading ? null : _saveDetails,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: AppColors.white,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        elevation: 0,
                      ),
                      child: authProvider.isLoading
                          ? SizedBox(
                              width: 24.w,
                              height: 24.w,
                              child: const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'Save & Continue',
                              style: AppTextStyles.buttonText,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
