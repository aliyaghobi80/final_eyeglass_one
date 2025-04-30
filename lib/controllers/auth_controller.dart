import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:eyewear/models/user.dart';
import 'package:eyewear/utils/constants.dart';
import 'package:get/get.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:eyewear/controllers/product_controller.dart';

class AuthController extends GetxController {
  final ApiService apiService = ApiService();
  var isLoading = false.obs;
  var user = Rxn<User>();

  @override
  void onInit() {
    super.onInit();
    // Ensure _loadUser is called before any navigation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUser();
    });
  }

  Future<bool> isAdmin() async {
    if (user.value == null) {
      return false;
    }
    return user.value!.isStaff;
  }

  Future<void> _loadUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');
      final refreshToken = prefs.getString('refresh_token');

      if (accessToken == null ||
          accessToken.isEmpty ||
          refreshToken == null ||
          refreshToken.isEmpty) {
        print('Tokens are empty or null');
        await _clearUserData();
        Get.offAllNamed('/login');
        return;
      }

      final response = await http.get(
        Uri.parse(Constants.profileUrl),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> userData = jsonDecode(response.body);
        user.value = User.fromJson(userData);
        Get.log('User loaded successfully from server');

        // If we're on the login screen, navigate to home
        if (Get.currentRoute == '/login') {
          Get.offAllNamed('/home');
        }
      } else {
        print('Failed to load user data: ${response.statusCode}');
        await _clearUserData();
        Get.offAllNamed('/login');
      }
    } catch (e) {
      print('Error loading user data: $e');
      await _clearUserData();
      Get.offAllNamed('/login');
    }
  }

  Future<void> _saveUser(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      Get.log("Saving user data...");

      // Save tokens first
      await prefs.setString('access_token', user.accessToken);
      await prefs.setString('refresh_token', user.refreshToken);

      // Save user data as JSON string to preserve UTF-8 encoding
      final userData = {
        'id': user.id,
        'username': user.username,
        'email': user.email,
        'first_name': user.firstName,
        'last_name': user.lastName,
        'is_staff': user.isStaff,
        'is_active': user.isActive,
        'profile': {
          'profile_picture': user.profilePictureUrl,
          'phone': user.phone,
          'created_at': user.createdAt?.toIso8601String(),
          'updated_at': user.updatedAt?.toIso8601String(),
        },
      };

      Get.log("Saving user data: ${jsonEncode(userData)}");
      await prefs.setString('user_data', jsonEncode(userData));

      // Verify data was saved correctly
      final savedData = prefs.getString('user_data');
      if (savedData != null) {
        final decodedData = jsonDecode(savedData);
        Get.log("Verified saved data: ${jsonEncode(decodedData)}");
      }

      Get.log("User data saved successfully");
    } catch (e) {
      Get.log("Error saving user data: $e");
      throw Exception('خطا در ذخیره اطلاعات کاربر: $e');
    }
  }

  Future<void> login(String username, String password) async {
    try {
      isLoading(true);
      Get.log('Attempting login with username: $username');

      final loggedInUser = await apiService.login(username, password);
      Get.log('Login response received: ${loggedInUser.toJson()}');

      if (loggedInUser.accessToken.isEmpty ||
          loggedInUser.refreshToken.isEmpty) {
        throw Exception('خطا در ورود: توکن‌ها یافت نشدند');
      }

      // Fetch complete profile data after successful login
      Get.log('Fetching complete profile data...');
      final response = await apiService.getProfile();
      Get.log('Profile response status: ${response.statusCode}');
      Get.log('Profile response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final completeUser = User.fromJson({
          ...data,
          'access_token': loggedInUser.accessToken,
          'refresh_token': loggedInUser.refreshToken,
        });

        user.value = completeUser;
        await _saveUser(completeUser);
        Get.log('Complete user data saved successfully');

        // دریافت داده‌های محصولات بعد از لاگین موفق
        final ProductController productController =
            Get.find<ProductController>();
        await productController.fetchCategories();
        await productController.fetchProducts();

        Get.offAllNamed('/home');
      } else {
        throw Exception('خطا در دریافت اطلاعات پروفایل');
      }
    } catch (e, stackTrace) {
      Get.log('Login error: $e');
      Get.log('Stack trace: $stackTrace');

      if (e is HttpException) {
      } else if (e is SocketException) {
      } else if (e is FormatException) {
      } else if (e.toString().contains('401')) {
      } else if (e.toString().contains('404')) {
      } else if (e.toString().contains('500')) {
      } else {}

      // Remove Get.snackbar to let the LoginScreen handle the error display
      rethrow;
    } finally {
      isLoading(false);
    }
  }

  Future<void> register({
    required String username,
    required String password,
    required String email,
    required String firstName,
    required String lastName,
    required String phone,
    File? profilePicture,
  }) async {
    try {
      isLoading.value = true;
      Get.log('Starting registration process...');

      final registeredUser = await apiService.register(
        username: username,
        password: password,
        email: email,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        profilePicture: profilePicture,
      );

      Get.log('Registration successful, saving user data...');

      // Ensure we have valid tokens
      if (registeredUser.accessToken.isEmpty ||
          registeredUser.refreshToken.isEmpty) {
        throw Exception('خطا در ثبت نام: توکن‌ها دریافت نشدند');
      }

      // Save user data and tokens
      user.value = registeredUser;
      await _saveUser(registeredUser);
      Get.log('User data saved successfully');

      // Fetch complete profile data after successful registration
      Get.log('Fetching complete profile data...');
      final response = await apiService.getProfile();

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final completeUser = User.fromJson({
          ...data,
          'access_token': registeredUser.accessToken,
          'refresh_token': registeredUser.refreshToken,
        });

        user.value = completeUser;
        await _saveUser(completeUser);
        Get.log('Complete user data saved successfully');

        try {
          Get.log('Fetching initial product data...');
          final ProductController productController =
              Get.find<ProductController>();
          await productController.fetchCategories();
          await productController.fetchProducts();
          Get.log('Product data fetched successfully');
        } catch (e) {
          Get.log('Error fetching product data: $e');
          // Even if product loading fails, we don't want to stop the registration process
        }

        Get.offAllNamed('/home');
      } else {
        throw Exception('خطا در دریافت اطلاعات پروفایل');
      }
    } catch (e) {
      Get.log('Registration error: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token') ?? '';
      final refreshToken = prefs.getString('refresh_token') ?? '';

      if (accessToken.isNotEmpty && refreshToken.isNotEmpty) {
        String validToken = accessToken;
        if (JwtDecoder.isExpired(accessToken)) {
          validToken = await apiService.refreshAccessToken(refreshToken);
          await prefs.setString('access_token', validToken);
        }
        await apiService.logout();
      }

      await prefs.clear();
      user.value = null;
      Get.offAllNamed('/login');
    } catch (e) {
      Get.snackbar('خطا', 'خطا در خروج از سیستم: $e');
    }
  }

  Future<void> updateProfile({
    String? username,
    required String email,
    required String firstName,
    required String lastName,
    String? phone,
    File? profilePicture,
  }) async {
    try {
      isLoading(true);

      // Get current tokens before update
      final prefs = await SharedPreferences.getInstance();
      final currentAccessToken = prefs.getString('access_token');
      final currentRefreshToken = prefs.getString('refresh_token');

      if (currentAccessToken == null || currentRefreshToken == null) {
        throw Exception('توکن‌های احراز هویت یافت نشدند');
      }

      final updatedUser = await apiService.updateProfile(
        username: username ?? user.value?.username ?? '',
        email: email,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        profilePicture: profilePicture,
      );

      // Ensure we keep the current tokens
      updatedUser.accessToken = currentAccessToken;
      updatedUser.refreshToken = currentRefreshToken;

      user.value = updatedUser;
      await _saveUser(updatedUser);

      Get.snackbar('موفق', 'اطلاعات پروفایل با موفقیت به‌روزرسانی شد');
    } catch (e) {
      Get.log('Error updating profile: $e');
      Get.snackbar('خطا', e.toString());
      rethrow;
    } finally {
      isLoading(false);
    }
  }

  Future<void> _clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    user.value = null;
  }

  Future<void> refreshAccessToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString('refresh_token');

      if (refreshToken == null || refreshToken.isEmpty) {
        print('Refresh token is empty or null');
        await _clearUserData();
        Get.offAllNamed('/login');
        return;
      }

      final response = await http.post(
        Uri.parse(Constants.refreshTokenUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh': refreshToken}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final newAccessToken = responseData['access'];

        if (newAccessToken == null || newAccessToken.isEmpty) {
          print('New access token is empty or null');
          await _clearUserData();
          Get.offAllNamed('/login');
          return;
        }

        await prefs.setString('access_token', newAccessToken);
        await _loadUser();
      } else {
        print('Token refresh failed with status: ${response.statusCode}');
        await _clearUserData();
        Get.offAllNamed('/login');
      }
    } catch (e) {
      print('Error refreshing token: $e');
      await _clearUserData();
      Get.offAllNamed('/login');
    }
  }

  Future<List<User>> getAllUsers() async {
    try {
      final response = await apiService.sendRequestWithAuth(
        'GET',
        Constants.usersListUrl,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => User.fromJson(json)).toList();
      } else {
        throw Exception('خطا در دریافت لیست کاربران: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('خطا در دریافت لیست کاربران: $e');
    }
  }

  Future<void> deleteUser(int userId) async {
    try {
      final response = await apiService.sendRequestWithAuth(
        'DELETE',
        '${Constants.deleteUserUrl}$userId/',
      );

      if (response.statusCode != 204) {
        throw Exception('خطا در حذف کاربر: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('خطا در حذف کاربر: $e');
    }
  }

  Future<void> updateUser(
    int userId, {
    String? username,
    String? email,
    String? firstName,
    String? lastName,
    String? phone,
    bool? isStaff,
    bool? isActive,
  }) async {
    try {
      final Map<String, dynamic> updateData = {};

      if (username != null) updateData['username'] = username;
      if (email != null) updateData['email'] = email;
      if (firstName != null) updateData['first_name'] = firstName;
      if (lastName != null) updateData['last_name'] = lastName;
      if (phone != null) updateData['phone'] = phone;
      if (isStaff != null) updateData['is_staff'] = isStaff ? 'True' : 'False';
      if (isActive != null) {
        updateData['is_active'] = isActive ? 'True' : 'False';
      }

      // تبدیل داده‌ها به فرمت مورد نیاز سرور
      final Map<String, String> formData = {};
      updateData.forEach((key, value) {
        formData[key] = value.toString();
      });

      final response = await apiService.sendRequestWithAuth(
        'PUT',
        '${Constants.editUserUrl}$userId/',
        body: formData,
      );

      if (response.statusCode != 200) {
        throw Exception('خطا در به‌روزرسانی کاربر: ${response.statusCode}');
      }

      // به‌روزرسانی لیست کاربران بعد از تغییرات موفق
      await getAllUsers();
    } catch (e) {
      throw Exception('خطا در به‌روزرسانی کاربر: $e');
    }
  }

  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      final response = await apiService.sendRequestWithAuth(
        'PUT',
        Constants.changePasswordUrl,
        body: {
          'current_password': currentPassword,
          'new_password': newPassword,
        },
      );

      Get.log('Response status: ${response.statusCode}');
      Get.log('Response body: ${response.body}');

      final Map<String, dynamic> responseData = json.decode(response.body);
      print("responseData: $responseData");
      print("response.statusCode: ${response.statusCode}");
      print("response.body: ${response.body}");
      print("response: $response");

      if (response.statusCode == 400) {
        print("response.statusCode to ifo: ${response.statusCode}");
        String errorMessage = responseData['error'] ?? 'خطا در تغییر رمز عبور';

        // ترجمه پیام‌های خطای رایج
        switch (errorMessage) {
          case 'Current password is incorrect':
            errorMessage = 'رمز عبور فعلی اشتباه است';
            break;
          case 'New password cannot be the same as the current password':
            errorMessage =
                'رمز عبور جدید نمی‌تواند با رمز عبور فعلی یکسان باشد';
            break;
          case 'Password must be at least 8 characters long':
            errorMessage = 'رمز عبور باید حداقل ۸ کاراکتر باشد';
            break;
        }
        print("errorMessage: $errorMessage");
        Get.log('Throwing error: $errorMessage'); // لاگ مقدار خطا قبل از پرتاب
        throw errorMessage;
      } else if (response.statusCode != 200) {
        throw 'خطا در تغییر رمز عبور';
      }

      Get.snackbar(
        'موفق',
        'رمز عبور با موفقیت تغییر کرد',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      // برگشت به صفحه قبل بعد از نمایش پیام موفقیت
      await Future.delayed(const Duration(seconds: 2));
      // Get.back();
    } catch (e) {
      Get.log('Error in changePassword (catch block): $e'); // بررسی مقدار e

      Future.delayed(Duration.zero, () {
        Get.snackbar(
          'خطا',
          e.toString(),
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      });
    }
  }
}
