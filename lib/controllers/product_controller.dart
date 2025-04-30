import 'dart:io';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:web_socket_channel/io.dart';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';
import 'package:flutter/material.dart';
import '../utils/constants.dart';

class ProductController extends GetxController {
  final RxList<Map<String, dynamic>> products = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> categories = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final searchResults = <Map<String, dynamic>>[].obs;
  final isSearching = false.obs;
  final RxString selectedCategory = 'همه'.obs;
  late IOWebSocketChannel channel;
  late IOWebSocketChannel categoryChannel;
  final ApiService _apiService = Get.find<ApiService>();

  @override
  void onInit() {
    super.onInit();
    initWebSocket();
    initCategoryWebSocket();
    fetchCategories();
    fetchProducts();
  }

  @override
  void onClose() {
    channel.sink.close();
    categoryChannel.sink.close();
    super.onClose();
  }

  Future<Map<String, String>> get _headers async {
    final token = await _apiService.getValidAccessToken();
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  Future<void> initWebSocket() async {
    try {
      final token = await _apiService.getValidAccessToken();
      channel = IOWebSocketChannel.connect(
        'ws://87.248.155.142/ws/products/',
        headers: {
          'Authorization': 'Bearer $token',
          'Connection': 'Upgrade',
          'Upgrade': 'websocket',
        },
      );

      channel.stream.listen(
        (message) {
          try {
            final data = jsonDecode(utf8.decode(message.toString().codeUnits));

            if (data['action'] == 'delete') {
              products.removeWhere(
                (p) => p['id'].toString() == data['product_id'].toString(),
              );
            } else if (data['action'] == 'add') {
              products.add(data['product']);
            } else if (data['action'] == 'update') {
              final index = products.indexWhere(
                (p) => p['id'].toString() == data['product']['id'].toString(),
              );
              if (index != -1) {
                products[index] = data['product'];
              }
            }
          } catch (e) {
            error.value = 'خطا در پردازش پیام وب‌سوکت';
          }
        },
        onError: (error) {
          Future.delayed(const Duration(seconds: 5), initWebSocket);
        },
        onDone: () {
          Future.delayed(const Duration(seconds: 5), initWebSocket);
        },
      );
    } catch (e) {
      Future.delayed(const Duration(seconds: 5), initWebSocket);
    }
  }

  Future<void> initCategoryWebSocket() async {
    try {
      final token = await _apiService.getValidAccessToken();
      categoryChannel = IOWebSocketChannel.connect(
        'ws://87.248.155.142/ws/categories/',
        headers: {
          'Authorization': 'Bearer $token',
          'Connection': 'Upgrade',
          'Upgrade': 'websocket',
        },
      );

      categoryChannel.stream.listen(
        (message) {
          try {
            final data = jsonDecode(utf8.decode(message.toString().codeUnits));

            if (data['action'] == 'delete') {
              categories.removeWhere(
                (c) => c['id'].toString() == data['category_id'].toString(),
              );
            } else if (data['action'] == 'add') {
              categories.add(data['category']);
            } else if (data['action'] == 'update') {
              final index = categories.indexWhere(
                (c) => c['id'].toString() == data['category']['id'].toString(),
              );
              if (index != -1) {
                categories[index] = data['category'];
              }
            }
          } catch (e) {
            error.value = 'خطا در پردازش پیام وب‌سوکت دسته‌بندی';
          }
        },
        onError: (error) {
          Future.delayed(const Duration(seconds: 5), initCategoryWebSocket);
        },
        onDone: () {
          Future.delayed(const Duration(seconds: 5), initCategoryWebSocket);
        },
      );
    } catch (e) {
      Future.delayed(const Duration(seconds: 5), initCategoryWebSocket);
    }
  }

  Future<void> fetchProducts() async {
    try {
      isLoading.value = true;
      final headers = await _headers;
      final response = await http.get(
        Uri.parse('http://87.248.155.142/api/product_list/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(utf8.decode(response.bodyBytes));
        if (decodedData['products'] != null) {
          products.value = List<Map<String, dynamic>>.from(
            decodedData['products'],
          );
        }
      } else {
        error.value = 'خطا در دریافت محصولات';
      }
    } catch (e) {
      print('Error fetching products: $e');
      error.value = 'خطا در دریافت محصولات';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchCategories() async {
    try {
      final headers = await _headers;
      final response = await http.get(
        Uri.parse('${Constants.baseUrl}/api/categories/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(utf8.decode(response.bodyBytes));
        categories.value = List<Map<String, dynamic>>.from(
          decodedData['categories'],
        );
      } else {
        error.value = 'خطا در دریافت دسته‌بندی‌ها';
      }
    } catch (e) {
      error.value = 'خطا در دریافت دسته‌بندی‌ها';
      print('Error fetching categories: $e');
    }
  }

  Future<void> addProduct({
    required String name,
    required String description,
    required int price,
    required int salePrice,
    required bool isSale,
    required bool isAvailable,
    required File image,
    required int category,
  }) async {
    try {
      isLoading.value = true;
      final productData = {
        'name': name,
        'description': description,
        'price': price,
        'sale_price': salePrice,
        'is_sale': isSale,
        'is_available': isAvailable,
        'category': category,
        'image': image,
      };

      await _apiService.addProduct(productData);
      await fetchProducts();
      Get.snackbar(
        'موفقیت',
        'محصول با موفقیت اضافه شد',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'خطا',
        'خطا در افزودن محصول: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProduct(
    Map<String, dynamic> productData, [
    File? imageFile,
  ]) async {
    try {
      print('Updating product with data: $productData');
      print('Image file: ${imageFile?.path}');

      final productId = productData['id'];
      if (productId == null) {
        throw Exception('شناسه محصول نامعتبر است');
      }

      // آماده‌سازی داده‌ها برای ارسال به سرور
      final dataToSend = {
        'name': productData['name'],
        'description': productData['description'],
        'price': (productData['price'] / 1).toString(), // تبدیل به عدد اعشاری
        'sale_price':
            (productData['sale_price'] / 1).toString(), // تبدیل به عدد اعشاری
        'is_sale':
            productData['is_sale'] ? 'True' : 'False', // تبدیل به True/False
        'is_available':
            productData['is_available']
                ? 'True'
                : 'False', // تبدیل به True/False
        'category': productData['category'].toString(),
      };

      print('Sending data to server: $dataToSend');
      if (productData["image"] != null) {
        print("Uploading image: ${productData["image"].path}");
      }

      if (imageFile != null) {
        print('Updating product with image');
        await _apiService.updateProduct(
          productId,
          dataToSend,
          imageFile: imageFile,
        );
      } else {
        print('Updating product without image');
        await _apiService.updateProduct(productId, dataToSend);
      }

      // به‌روزرسانی لیست محصولات
      await fetchProducts();
      Get.snackbar(
        'موفقیت',
        'محصول با موفقیت به‌روزرسانی شد',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      Get.offAllNamed('/home'); // برگشت به صفحه اصلی
    } catch (e) {
      print('Error in updateProduct: $e');
      print('Error type: ${e.runtimeType}');
      print('Error stack trace: ${StackTrace.current}');

      String errorMessage = 'خطا در به‌روزرسانی محصول';
      if (e.toString().contains('FormatException')) {
        errorMessage = 'خطا در فرمت داده‌ها. لطفاً مقادیر را بررسی کنید.';
      } else if (e.toString().contains('Connection refused')) {
        errorMessage =
            'خطا در اتصال به سرور. لطفاً اتصال اینترنت خود را بررسی کنید.';
      } else if (e.toString().contains('401')) {
        errorMessage = 'خطا در احراز هویت. لطفاً دوباره وارد شوید.';
      } else if (e.toString().contains('404')) {
        errorMessage = 'محصول مورد نظر یافت نشد.';
      } else if (e.toString().contains('400')) {
        errorMessage =
            'داده‌های ارسالی نامعتبر هستند. لطفاً مقادیر را بررسی کنید.';
      }

      Get.snackbar(
        'خطا',
        errorMessage,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      rethrow;
    }
  }

  Future<void> deleteProduct(int productId) async {
    try {
      isLoading.value = true;
      await _apiService.deleteProduct(productId);
      await fetchProducts();
      Get.snackbar('موفقیت', 'محصول با موفقیت حذف شد');
    } catch (e) {
      Get.snackbar('خطا', 'خطا در حذف محصول: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> searchProducts(String query) async {
    try {
      isSearching(true);
      isLoading(true);
      final headers = await _headers;
      final response = await http.get(
        Uri.parse('${Constants.baseUrl}/api/products/search/?query=$query'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(utf8.decode(response.bodyBytes));
        if (decodedData['products'] != null) {
          searchResults.value = List<Map<String, dynamic>>.from(
            decodedData['products'],
          );
          products.value = searchResults; // نمایش نتایج جستجو در صفحه اصلی
        }
      } else {
        error.value = 'خطا در جستجوی محصولات';
        Get.snackbar(
          'خطا',
          'خطا در جستجوی محصولات',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      error.value = 'خطا در جستجوی محصولات';
      Get.snackbar(
        'خطا',
        'خطا در جستجوی محصولات',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading(false);
      isSearching(false);
    }
  }

  void filterProductsByCategory(String categoryName) async {
    try {
      isLoading.value = true;
      selectedCategory.value = categoryName;

      // Always fetch fresh data when switching categories
      await fetchProducts();

      if (categoryName == 'همه') {
        return;
      }

      // اگر دسته‌بندی "محصولات تخفیف‌دار" انتخاب شده است
      if (categoryName == 'محصولات تخفیف‌دار') {
        final discountedProducts =
            products.where((product) => product['is_sale'] == true).toList();
        products.value = discountedProducts;
        return;
      }

      // برای سایر دسته‌بندی‌ها
      final filteredProducts =
          products.where((product) {
            final categoryId = product['category']?.toString() ?? '0';
            final category = categories.firstWhere(
              (cat) => cat['id'].toString() == categoryId,
              orElse: () => {'name': 'سایر'},
            );
            return category['name'] == categoryName;
          }).toList();

      // جدا کردن محصولات تخفیف‌دار و معمولی
      final discountedProducts =
          filteredProducts
              .where((product) => product['is_sale'] == true)
              .toList();
      final regularProducts =
          filteredProducts
              .where((product) => product['is_sale'] != true)
              .toList();

      // ترکیب محصولات با اولویت تخفیف‌دارها
      products.value = [...discountedProducts, ...regularProducts];
    } catch (e) {
      print('Error filtering products: $e');
      error.value = 'خطا در فیلتر کردن محصولات';
    } finally {
      isLoading.value = false;
    }
  }
}
