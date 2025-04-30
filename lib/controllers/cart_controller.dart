import 'package:get/get.dart';
import '../models/cart_item.dart';
import '../models/order.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';
import '../controllers/auth_controller.dart';

class CartController extends GetxController {
  final ApiService apiService = ApiService();
  final AuthController authController = Get.find<AuthController>();
  var isLoading = false.obs;
  var cartItems = <CartItem>[].obs;
  var recentOrders = <Order>[].obs;
  var error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // فقط سبد خرید رو در ابتدا دریافت می‌کنیم
    fetchCart();
  }

  Future<void> fetchCart() async {
    try {
      isLoading(true);
      error('');

      final response = await apiService.sendRequestWithAuth(
        'GET',
        Constants.viewCartUrl,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> cartItemsData = data['cart_items'] as List<dynamic>;
        cartItems.value =
            cartItemsData.map((item) => CartItem.fromJson(item)).toList();
      } else {
        error('خطا در دریافت سبد خرید');
        Get.snackbar(
          'خطا',
          'خطا در دریافت سبد خرید',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.log('Error fetching cart: $e');
      error('خطا در دریافت سبد خرید');
      Get.snackbar(
        'خطا',
        'خطا در دریافت سبد خرید',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchRecentOrders() async {
    try {
      isLoading(true);
      error('');

      final response = await apiService.sendRequestWithAuth(
        'GET',
        Constants.recentOrdersUrl,
      );

      Get.log('Orders Response: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> data = responseData['orders'] as List<dynamic>;
        recentOrders.value = data.map((item) => Order.fromJson(item)).toList();
        Get.log('Parsed Orders: ${recentOrders.length}');
      } else {
        error('خطا در دریافت سفارشات اخیر');
        Get.snackbar(
          'خطا',
          'خطا در دریافت سفارشات اخیر',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.log('Error fetching recent orders: $e');
      error('خطا در دریافت سفارشات اخیر');
      Get.snackbar(
        'خطا',
        'خطا در دریافت سفارشات اخیر',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading(false);
    }
  }

  Future<void> addToCart(int productId, int quantity) async {
    try {
      // بررسی ادمین بودن کاربر
      if (await authController.isAdmin()) {
        Get.snackbar(
          'خطا',
          'کاربران ادمین نمی‌توانند محصولی به سبد خرید اضافه کنند',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        return;
      }

      isLoading(true);
      error('');

      final response = await apiService.sendRequestWithAuth(
        'POST',
        Constants.addToCartUrl,
        body: {'product_id': productId, 'quantity': quantity},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // به‌روزرسانی سبد خرید از سرور
        await fetchCart();

        Get.snackbar(
          'موفق',
          'محصول با موفقیت به سبد خرید اضافه شد',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
          errorData['error'] ?? 'خطا در اضافه کردن محصول به سبد خرید',
        );
      }
    } catch (e) {
      Get.log('Error adding to cart: $e');
      String errorMessage;

      if (e.toString().contains('Connection refused')) {
        errorMessage =
            'خطا در اتصال به سرور. لطفاً اتصال اینترنت خود را بررسی کنید.';
      } else if (e.toString().contains('SocketException')) {
        errorMessage = 'خطا در برقراری ارتباط با سرور';
      } else {
        errorMessage = e.toString().replaceAll('Exception: ', '');
      }

      error(errorMessage);
      Get.snackbar(
        'خطا',
        errorMessage,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading(false);
    }
  }

  Future<void> removeFromCart(int productId) async {
    try {
      isLoading(true);
      error('');

      final response = await apiService.sendRequestWithAuth(
        'DELETE',
        '${Constants.removeFromCartUrl}$productId/',
      );

      if (response.statusCode == 204) {
        await fetchCart();
        Get.snackbar(
          'موفق',
          'محصول با موفقیت از سبد خرید حذف شد',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        final errorData = json.decode(response.body);
        String errorMessage =
            errorData['error'] ?? 'خطا در حذف محصول از سبد خرید';

        if (response.statusCode == 404) {
          errorMessage = 'محصول مورد نظر در سبد خرید یافت نشد';
        } else if (response.statusCode == 403) {
          errorMessage = 'شما دسترسی لازم برای این عملیات را ندارید';
        } else if (response.statusCode == 401) {
          errorMessage = 'لطفاً ابتدا وارد حساب کاربری خود شوید';
        }

        throw Exception(errorMessage);
      }
    } catch (e) {
      Get.log('Error removing from cart: $e');
      String errorMessage = e.toString().replaceAll('Exception: ', '');
      error(errorMessage);
      Get.snackbar(
        'خطا',
        errorMessage,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading(false);
    }
  }

  Future<void> clearCart() async {
    try {
      isLoading(true);
      error('');

      final response = await apiService.sendRequestWithAuth(
        'DELETE',
        Constants.clearCartUrl,
      );

      if (response.statusCode == 204) {
        cartItems.clear();
        Get.snackbar(
          'موفق',
          'سبد خرید با موفقیت پاک شد',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        throw Exception('خطا در پاک کردن سبد خرید');
      }
    } catch (e) {
      Get.log('Error clearing cart: $e');
      error('خطا در پاک کردن سبد خرید');
      Get.snackbar(
        'خطا',
        'خطا در پاک کردن سبد خرید',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      rethrow;
    } finally {
      isLoading(false);
    }
  }

  int get totalItems => cartItems.fold(0, (sum, item) => sum + item.quantity);
  double get totalPrice =>
      cartItems.fold(0, (sum, item) => sum + item.getTotalPrice());
}
