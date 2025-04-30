import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import '../services/api_service.dart';
import '../utils/constants.dart';
import '../controllers/cart_controller.dart';

class OrderController extends GetxController {
  final ApiService apiService = ApiService();
  final CartController cartController = Get.find();
  var isLoading = false.obs;
  var error = ''.obs;
  var orders = <Map<String, dynamic>>[].obs;

  Future<void> createOrder({
    required String address,
    required String phone,
  }) async {
    try {
      isLoading(true);
      error('');

      // بررسی خالی نبودن سبد خرید
      if (cartController.cartItems.isEmpty) {
        throw Exception('سبد خرید شما خالی است');
      }

      final response = await apiService.sendRequestWithAuth(
        'POST',
        Constants.createOrderUrl,
        body: {
          'items':
              cartController.cartItems
                  .map(
                    (item) => {
                      'product_id': item.productId,
                      'quantity': item.quantity,
                    },
                  )
                  .toList(),
          'total_amount': cartController.totalPrice,
          'address': address,
          'phone': phone,
        },
      );

      Get.log('Order Response: ${response.body}');

      if (response.statusCode == 201) {
        // پاک کردن سبد خرید بعد از ثبت سفارش
        await cartController.clearCart();
        Get.snackbar(
          'موفقیت',
          'سفارش شما با موفقیت ثبت شد',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        final errorData = json.decode(response.body);
        String errorMessage = errorData['error'] ?? 'خطا در ثبت سفارش';

        if (response.statusCode == 400) {
          errorMessage = 'اطلاعات ارسالی نامعتبر است';
        } else if (response.statusCode == 401) {
          errorMessage = 'لطفاً ابتدا وارد حساب کاربری خود شوید';
        } else if (response.statusCode == 403) {
          errorMessage = 'شما دسترسی لازم برای این عملیات را ندارید';
        } else if (response.statusCode == 404) {
          errorMessage = 'یکی از محصولات در سبد خرید یافت نشد';
        } else if (response.statusCode == 500) {
          errorMessage = 'خطای سرور. لطفاً دوباره تلاش کنید';
        }

        throw Exception(errorMessage);
      }
    } catch (e) {
      Get.log('Error creating order: $e');
      String errorMessage = e.toString().replaceAll('Exception: ', '');
      error(errorMessage);
      Get.snackbar(
        'خطا',
        errorMessage,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      rethrow;
    } finally {
      isLoading(false);
    }
  }

  Future<void> getOrders() async {
    try {
      isLoading(true);
      error('');

      final response = await apiService.sendRequestWithAuth(
        'GET',
        Constants.orderListUrl,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        orders.value = List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception('خطا در دریافت لیست سفارش‌ها');
      }
    } catch (e) {
      Get.log('Error getting orders: $e');
      error(e.toString());
      Get.snackbar(
        'خطا',
        'خطا در دریافت لیست سفارش‌ها',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading(false);
    }
  }

  Future<Map<String, dynamic>> getOrderDetail(int orderId) async {
    try {
      isLoading(true);
      error('');

      final response = await apiService.sendRequestWithAuth(
        'GET',
        Constants.getOrderDetailUrl(orderId),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('خطا در دریافت جزئیات سفارش');
      }
    } catch (e) {
      Get.log('Error getting order detail: $e');
      error(e.toString());
      Get.snackbar(
        'خطا',
        'خطا در دریافت جزئیات سفارش',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      rethrow;
    } finally {
      isLoading(false);
    }
  }
}
