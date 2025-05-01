import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/constants.dart';
import '../controllers/product_controller.dart';
import '../services/api_service.dart';

class ManageCategoriesScreen extends StatefulWidget {
  const ManageCategoriesScreen({super.key});

  @override
  State<ManageCategoriesScreen> createState() => _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState extends State<ManageCategoriesScreen> {
  final ProductController productController = Get.find<ProductController>();
  final ApiService apiService = Get.find<ApiService>();
  final TextEditingController _categoryController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final RxBool _isLoading = false.obs;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      _isLoading.value = true;
      final categories = await apiService.getCategories();
      productController.categories.value = categories;
    } catch (e) {
      Get.snackbar(
        'خطا',
        'خطا در دریافت دسته‌بندی‌ها: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مدیریت دسته‌بندی‌ها'),
        centerTitle: true,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Obx(() {
          if (_isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _categoryController,
                          decoration: const InputDecoration(
                            labelText: 'نام دسته‌بندی جدید',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'لطفاً نام دسته‌بندی را وارد کنید';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed:
                            () => apiService.addCategory(
                              _categoryController.text,
                            ),
                        child: const Text('افزودن'),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: productController.categories.length,
                  itemBuilder: (context, index) {
                    final category = productController.categories[index];
                    return ListTile(
                      title: Text(category['name']),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              _showEditDialog(category);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              _showDeleteDialog(category['id']);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  void _showEditDialog(Map<String, dynamic> category) {
    final controller = TextEditingController(text: category['name']);
    Get.dialog(
      AlertDialog(
        title: const Text('ویرایش دسته‌بندی'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'نام جدید',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('انصراف')),
          TextButton(
            onPressed: () {
              apiService.editCategory(category['id'], controller.text);
              Get.back();
            },
            child: const Text('ذخیره'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(int id) {
    Get.dialog(
      AlertDialog(
        title: const Text('حذف دسته‌بندی'),
        content: const Text('آیا از حذف این دسته‌بندی اطمینان دارید؟'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('انصراف')),
          TextButton(
            onPressed: () {
              apiService.deleteCategory(id);
              Get.back();
            },
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _categoryController.dispose();
    super.dispose();
  }
}
