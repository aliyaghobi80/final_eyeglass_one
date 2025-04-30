import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../utils/constants.dart';
import '../controllers/product_controller.dart';

class ManageCategoriesScreen extends StatefulWidget {
  const ManageCategoriesScreen({super.key});

  @override
  State<ManageCategoriesScreen> createState() => _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState extends State<ManageCategoriesScreen> {
  final ProductController productController = Get.find<ProductController>();
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
      final response = await http.get(
        Uri.parse('${Constants.baseUrl}/api/categories/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getToken()}',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        productController.categories.value = List<Map<String, dynamic>>.from(
          data['categories'],
        );
      } else {
        Get.snackbar(
          'خطا',
          'خطا در دریافت دسته‌بندی‌ها',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
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

  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token') ?? '';
  }

  Future<void> _addCategory() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      _isLoading.value = true;
      final response = await http.post(
        Uri.parse('${Constants.baseUrl}/api/categories/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getToken()}',
        },
        body: jsonEncode({'name': _categoryController.text}),
      );

      if (response.statusCode == 201) {
        _categoryController.clear();
        await _loadCategories();
        Get.snackbar(
          'موفقیت',
          'دسته‌بندی با موفقیت اضافه شد',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'خطا',
          'خطا در افزودن دسته‌بندی',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'خطا',
        'خطا در افزودن دسته‌بندی: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> _editCategory(int id, String newName) async {
    try {
      _isLoading.value = true;
      final response = await http.put(
        Uri.parse('${Constants.baseUrl}/api/categories/$id/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getToken()}',
        },
        body: jsonEncode({'name': newName}),
      );

      if (response.statusCode == 200) {
        await _loadCategories();
        Get.snackbar(
          'موفقیت',
          'دسته‌بندی با موفقیت ویرایش شد',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'خطا',
          'خطا در ویرایش دسته‌بندی',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'خطا',
        'خطا در ویرایش دسته‌بندی: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> _deleteCategory(int id) async {
    try {
      _isLoading.value = true;
      final response = await http.delete(
        Uri.parse('${Constants.baseUrl}/api/categories/$id/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getToken()}',
        },
      );

      if (response.statusCode == 204) {
        await _loadCategories();
        Get.snackbar(
          'موفقیت',
          'دسته‌بندی با موفقیت حذف شد',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'خطا',
          'خطا در حذف دسته‌بندی',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'خطا',
        'خطا در حذف دسته‌بندی: $e',
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
      body: Obx(() {
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
                      onPressed: _addCategory,
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
              _editCategory(category['id'], controller.text);
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
              _deleteCategory(id);
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
