import 'package:flutter/material.dart';

class Constants {
  static const String baseUrl = 'http://**.***.***.***';

  // Authentication endpoints
  static const String loginUrl = '$baseUrl/api/login/';
  static const String logoutUrl = '$baseUrl/api/logout/';
  static const String registerUrl = '$baseUrl/api/signup/';
  static const String refreshTokenUrl = '$baseUrl/api/token/refresh/';

  // Profile and User Management endpoints
  static const String profileUrl = '$baseUrl/api/users/profile/';
  static const String updateProfileUrl = '$baseUrl/api/users/profile/update/';
  static const String updateUserProfileUrl =
      '$baseUrl/api/users/profile/me/update/';
  static const String usersListUrl = '$baseUrl/api/users/';
  static const String deleteUserUrl = '$baseUrl/api/users/delete/';
  static const String editUserUrl = '$baseUrl/api/users/edit/';
  static const String changePasswordUrl = '$baseUrl/api/users/change-password/';

  // Product endpoints
  static const String productListUrl = '$baseUrl/api/product_list/';
  static const String productUrl = '$baseUrl/api/product/';
  static const String addProductUrl = '$baseUrl/api/add_product/';
  static const String deleteProductUrl = '$baseUrl/api/delete_product/';
  static const String editProductUrl = '$baseUrl/api/edit_product/';

  // Category endpoints
  static const String categoriesUrl = '$baseUrl/api/categories/';
  static const String addCategoryUrl = '$baseUrl/api/add_category/';
  static const String editCategoryUrl = '$baseUrl/api/edit_category/';
  static const String deleteCategoryUrl = '$baseUrl/api/delete_category/';

  // Cart endpoints
  static const String viewCartUrl = '$baseUrl/api/view_cart/';
  static const String addToCartUrl = '$baseUrl/api/add_to_cart/';
  static const String removeFromCartUrl = '$baseUrl/api/remove_from_cart/';
  static const String clearCartUrl = '$baseUrl/api/clear_cart/';

  // Order endpoints
  static const String createOrderUrl = '$baseUrl/api/orders/create/';
  static const String orderListUrl = '$baseUrl/api/orders/';
  static const String orderDetailUrl = '$baseUrl/api/orders/';
  static const String recentOrdersUrl = '$baseUrl/api/recent_orders/';

  // Helper methods
  static String getProductDetailUrl(int productId) => '$productUrl$productId/';
  static String getDeleteProductUrl(int productId) =>
      '$deleteProductUrl$productId/';
  static String getEditProductUrl(int productId) =>
      '$editProductUrl$productId/';
  static String getOrderDetailUrl(int orderId) => '$orderDetailUrl$orderId/';
  static String getDeleteUserUrl(int userId) => '$deleteUserUrl$userId/';
  static String getEditUserUrl(int userId) => '$editUserUrl$userId/';
  static String getUserProfileUrl(int userId) => '$profileUrl$userId/';
  static String getEditCategoryUrl(int categoryId) =>
      '$editCategoryUrl$categoryId/';
  static String getDeleteCategoryUrl(int categoryId) =>
      '$deleteCategoryUrl$categoryId/';
}

// رنگ‌های اصلی
class AppColors {
  static const Color primary = Color(0xFF6200EE);
  static const Color secondary = Color(0xFF03DAC6);
  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color textLight = Color(0xFF000000);
  static const Color textDark = Color(0xFFFFFFFF);
  static const Color dynamicTextLight = Color(0xFF000000);
  static const Color dynamicTextDark = Color(0xFFFFFFFF);
}

// فونت‌ها
class AppFonts {
  static const String primaryFont = 'Vazir';
}

// تم لایت
final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: AppColors.primary,
  scaffoldBackgroundColor: AppColors.backgroundLight,
  textTheme: const TextTheme(
    bodyLarge: TextStyle(
      fontFamily: AppFonts.primaryFont,
      color: AppColors.textLight,
    ),
    bodyMedium: TextStyle(
      fontFamily: AppFonts.primaryFont,
      color: AppColors.textLight,
    ),
  ),
);

// تم دارک
final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: AppColors.primary,
  scaffoldBackgroundColor: AppColors.backgroundDark,
  textTheme: const TextTheme(
    bodyLarge: TextStyle(
      fontFamily: AppFonts.primaryFont,
      color: AppColors.textDark,
    ),
    bodyMedium: TextStyle(
      fontFamily: AppFonts.primaryFont,
      color: AppColors.textDark,
    ),
  ),
);
