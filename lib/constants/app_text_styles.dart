import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Headings
  static TextStyle heading1 = GoogleFonts.poppins(
    fontSize: 24.sp,
    fontWeight: FontWeight.bold,
    color: AppColors.black,
  );
  
  static TextStyle heading2 = GoogleFonts.poppins(
    fontSize: 20.sp,
    fontWeight: FontWeight.bold,
    color: AppColors.black,
  );
  
  static TextStyle heading3 = GoogleFonts.poppins(
    fontSize: 18.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.black,
  );
  
  static TextStyle heading4 = GoogleFonts.poppins(
    fontSize: 16.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.black,
  );
  
  // Body text
  static TextStyle bodyLarge = GoogleFonts.poppins(
    fontSize: 16.sp,
    fontWeight: FontWeight.normal,
    color: AppColors.black,
  );
  
  static TextStyle bodyMedium = GoogleFonts.poppins(
    fontSize: 14.sp,
    fontWeight: FontWeight.normal,
    color: AppColors.black,
  );
  
  static TextStyle bodySmall = GoogleFonts.poppins(
    fontSize: 12.sp,
    fontWeight: FontWeight.normal,
    color: AppColors.black,
  );
  
  // Button text
  static TextStyle buttonText = GoogleFonts.poppins(
    fontSize: 16.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
  );
  
  // Link text
  static TextStyle linkText = GoogleFonts.poppins(
    fontSize: 14.sp,
    fontWeight: FontWeight.w500,
    color: AppColors.primaryBlue,
    decoration: TextDecoration.underline,
  );
  
  // Input text
  static TextStyle inputText = GoogleFonts.poppins(
    fontSize: 14.sp,
    fontWeight: FontWeight.normal,
    color: AppColors.black,
  );
  
  static TextStyle inputHint = GoogleFonts.poppins(
    fontSize: 14.sp,
    fontWeight: FontWeight.normal,
    color: AppColors.grey,
  );
  
  // Error text
  static TextStyle errorText = GoogleFonts.poppins(
    fontSize: 12.sp,
    fontWeight: FontWeight.normal,
    color: AppColors.error,
  );
}
