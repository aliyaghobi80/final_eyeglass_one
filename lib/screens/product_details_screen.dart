import 'package:eyewear/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:persian_number_utility/persian_number_utility.dart';

import '../controllers/cart_controller.dart';
import '../controllers/auth_controller.dart';
import '../controllers/product_controller.dart';

class ProductDetailsScreen extends StatelessWidget {
  ProductDetailsScreen({super.key});
  final Map<String, dynamic> product = Get.arguments as Map<String, dynamic>;

  final CartController cartController = Get.find();
  final AuthController authController = Get.find();
  final ProductController productController = Get.find();

  Future<void> _showDeleteDialog() async {
    return showDialog(
      context: Get.context!,
      builder:
          (context) => AlertDialog(
            title: const Text('حذف محصول'),
            content: Text(
              'آیا از حذف محصول "${product['name']}" اطمینان دارید؟',
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('انصراف'),
              ),
              TextButton(
                onPressed: () async {
                  Get.back();
                  await _deleteProduct();
                },
                child: const Text('حذف', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  Future<void> _deleteProduct() async {
    try {
      await productController.deleteProduct(product['id']);
      Get.back();
      Get.snackbar(
        'موفقیت',
        'محصول با موفقیت حذف شد',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'خطا',
        'خطا در حذف محصول: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  String _formatPrice(String price) {
    return double.parse(price).toInt().toString().seRagham();
  }

  double _calculateDiscountPercentage(Map<String, dynamic> product) {
    if (product['is_sale'] != true) return 0;
    final originalPrice = double.parse(product['price']);
    final salePrice = double.parse(product['sale_price']);
    return ((originalPrice - salePrice) / originalPrice * 100)
        .round()
        .toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final bool isOnSale = product['is_sale'] == true;
    final bool isAvailable = product['is_available'] == true;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(product['name']?.toString() ?? ''),
        centerTitle: true,
        actions: [
          FutureBuilder<bool>(
            future: authController.isAdmin(),
            builder: (context, snapshot) {
              if (snapshot.data == true) {
                return Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        Get.toNamed('/edit-product', arguments: product);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: _showDeleteDialog,
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Stack(
                children: [
                  Hero(
                    tag: 'product-${product['id']}',
                    child: InteractiveViewer(
                      minScale: 0.5,
                      maxScale: 4.0,
                      child: Image.network(
                        '${Constants.baseUrl}${product['image']}',
                        width: double.infinity,
                        height: 300,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 300,
                            color: Colors.grey[200],
                            child: const Center(
                              child: Icon(Icons.error_outline, size: 40),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  if (isOnSale)
                    Positioned(
                      top: 16,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          '${_calculateDiscountPercentage(product).toInt()}% تخفیف',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product['name']?.toString() ?? '',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color:
                            isDark ? AppColors.textDark : AppColors.textLight,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[850] : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (isOnSale) ...[
                            Text(
                              'قیمت اصلی: ${_formatPrice(product['price'])} تومان',
                              style: TextStyle(
                                fontSize: 16,
                                decoration: TextDecoration.lineThrough,
                                color:
                                    isDark
                                        ? Colors.grey[400]
                                        : Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'قیمت با تخفیف: ${_formatPrice(product['sale_price'])} تومان',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color:
                                    isDark
                                        ? Colors.greenAccent
                                        : Colors.green[700],
                              ),
                            ),
                          ] else
                            Text(
                              'قیمت: ${_formatPrice(product['price'])} تومان',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color:
                                    isDark
                                        ? AppColors.textDark
                                        : AppColors.primary,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'توضیحات محصول:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color:
                            isDark ? AppColors.textDark : AppColors.textLight,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[850] : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                        ),
                      ),
                      child: Text(
                        product['description']?.toString() ?? '',
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.5,
                          color: isDark ? Colors.grey[300] : Colors.grey[800],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color:
                            isAvailable
                                ? (isDark
                                    ? Colors.green.withOpacity(0.2)
                                    : Colors.green.withOpacity(0.1))
                                : (isDark
                                    ? Colors.red.withOpacity(0.2)
                                    : Colors.red.withOpacity(0.1)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isAvailable
                                ? Icons.check_circle
                                : Icons.remove_circle,
                            color:
                                isAvailable
                                    ? (isDark
                                        ? Colors.greenAccent
                                        : Colors.green)
                                    : (isDark ? Colors.redAccent : Colors.red),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isAvailable ? 'موجود در انبار' : 'ناموجود',
                            style: TextStyle(
                              fontSize: 16,
                              color:
                                  isAvailable
                                      ? (isDark
                                          ? Colors.greenAccent
                                          : Colors.green)
                                      : (isDark
                                          ? Colors.redAccent
                                          : Colors.red),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[850] : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton.icon(
            onPressed:
                isAvailable
                    ? () {
                      cartController.addToCart(product['id'], 1);
                      Get.snackbar(
                        'موفقیت',
                        'محصول به سبد خرید اضافه شد',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.green,
                        colorText: Colors.white,
                        margin: const EdgeInsets.all(8),
                        borderRadius: 8,
                        duration: const Duration(seconds: 2),
                      );
                    }
                    : null,
            icon: const Icon(Icons.shopping_cart),
            label: Text(
              isAvailable ? 'افزودن به سبد خرید' : 'ناموجود',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: isAvailable ? AppColors.primary : Colors.grey,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
