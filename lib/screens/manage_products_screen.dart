import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/product_controller.dart';
import '../controllers/auth_controller.dart';
import '../utils/constants.dart';

class ManageProductsScreen extends StatefulWidget {
  const ManageProductsScreen({super.key});

  @override
  State<ManageProductsScreen> createState() => _ManageProductsScreenState();
}

class _ManageProductsScreenState extends State<ManageProductsScreen> {
  final ProductController _productController = Get.find<ProductController>();
  final AuthController _authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    _checkAdminAccess();
  }

  Future<void> _checkAdminAccess() async {
    final isAdmin = await _authController.isAdmin();
    if (!isAdmin) {
      Get.snackbar(
        'خطا',
        'شما دسترسی به این بخش را ندارید',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      Get.back();
    }
  }

  Future<void> _showDeleteDialog(Map<String, dynamic> product) async {
    return showDialog(
      context: context,
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
                  await _deleteProduct(product);
                },
                child: const Text('حذف', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  Future<void> _deleteProduct(Map<String, dynamic> product) async {
    try {
      await _productController.deleteProduct(product['id']);
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

  String _getImageUrl(String? imagePath) {
    if (imagePath == null) return '';
    if (imagePath.startsWith('http')) return imagePath;
    return '${Constants.baseUrl}$imagePath';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('مدیریت محصولات'), centerTitle: true),
      body: Obx(() {
        if (_productController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_productController.products.isEmpty) {
          return const Center(child: Text('هیچ محصولی وجود ندارد'));
        }

        return ListView.builder(
          itemCount: _productController.products.length,
          itemBuilder: (context, index) {
            final product = _productController.products[index];
            final imageUrl = _getImageUrl(product['image']);

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: ListTile(
                leading:
                    imageUrl.isNotEmpty
                        ? ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.network(
                            imageUrl,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 50,
                                height: 50,
                                color: Colors.grey[200],
                                child: const Icon(Icons.image_not_supported),
                              );
                            },
                          ),
                        )
                        : Container(
                          width: 50,
                          height: 50,
                          color: Colors.grey[200],
                          child: const Icon(Icons.image_not_supported),
                        ),
                title: Text(
                  product['name']?.toString() ?? '',
                  style: const TextStyle(fontFamily: 'Vazir'),
                ),
                subtitle: Text(
                  'قیمت: ${product['price']?.toString() ?? '0'} تومان',
                  style: const TextStyle(fontFamily: 'Vazir'),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        Get.toNamed('/edit-product', arguments: product);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _showDeleteDialog(product),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed('/add-product'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
