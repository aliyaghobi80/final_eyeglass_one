import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:persian_number_utility/persian_number_utility.dart';
import 'dart:io';
import '../controllers/product_controller.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _salePriceController = TextEditingController();
  final _stockController = TextEditingController();
  File? _selectedImage;
  bool _isLoading = false;
  bool _isSale = false;
  bool _isAvailable = true;
  int _selectedCategory = 1;
  final ProductController _productController = Get.find<ProductController>();
  RxInt price = 0.obs;
  RxInt salePrice = 0.obs;
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('افزودن محصول جدید')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child:
                        _selectedImage != null
                            ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                _selectedImage!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                            )
                            : const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_a_photo, size: 50),
                                  SizedBox(height: 8),
                                  Text('برای انتخاب تصویر کلیک کنید'),
                                ],
                              ),
                            ),
                  ),
                ),
                const SizedBox(height: 16),
                Obx(() {
                  if (_productController.categories.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // مقدار پیش‌فرض تعیین شود تا `null` نباشد
                  if (!_productController.categories.any(
                    (category) => category['id'] == _selectedCategory,
                  )) {
                    _selectedCategory =
                        _productController.categories.first['id'] as int;
                  }

                  return DropdownButtonFormField<int>(
                    value: _selectedCategory, // مقدار انتخاب‌شده
                    decoration: const InputDecoration(
                      labelText: 'دسته‌بندی',
                      border: OutlineInputBorder(),
                    ),
                    items:
                        _productController.categories.map((category) {
                          return DropdownMenuItem<int>(
                            value: category['id'] as int,
                            child: Text(category['name'] as String),
                          );
                        }).toList(),
                    onChanged: (int? value) {
                      if (value != null) {
                        setState(() {
                          _selectedCategory = value;
                        });
                      }
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'لطفا دسته‌بندی را انتخاب کنید';
                      }
                      return null;
                    },
                  );
                }),

                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'نام محصول',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'لطفا نام محصول را وارد کنید';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'توضیحات',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'لطفا توضیحات را وارد کنید';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Obx(
                  () => Text(
                    " مجموع: ${'$price'.toWord()} تومان ",
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ),
                TextFormField(
                  controller: _priceController,

                  decoration: const InputDecoration(
                    labelText: 'قیمت',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (val) {
                    if (val.isEmpty) {
                      price.value = 0;
                    }
                    price.value = int.parse(val);
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'لطفا قیمت را وارد کنید';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('فروش ویژه'),
                  value: _isSale,
                  onChanged: (bool value) {
                    setState(() {
                      _isSale = value;
                    });
                  },
                ),
                if (_isSale) ...[
                  const SizedBox(height: 16),
                  Obx(
                    () => Text(
                      " مجموع: ${'$salePrice'.toWord()} تومان ",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  TextFormField(
                    controller: _salePriceController,
                    onChanged: (val) {
                      if (val.isEmpty) {
                        salePrice.value = 0;
                      }
                      salePrice.value = int.parse(val);
                    },
                    decoration: const InputDecoration(
                      labelText: 'قیمت فروش ویژه',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ],
                const SizedBox(height: 16),
                TextFormField(
                  controller: _stockController,
                  decoration: const InputDecoration(
                    labelText: 'موجودی',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'لطفا موجودی را وارد کنید';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('موجود'),
                  value: _isAvailable,
                  onChanged: (bool value) {
                    setState(() {
                      _isAvailable = value;
                    });
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  child:
                      _isLoading
                          ? const CircularProgressIndicator()
                          : const Text('افزودن محصول'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedImage == null) {
      Get.snackbar(
        'خطا',
        'لطفا یک تصویر انتخاب کنید',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _productController.addProduct(
        name: _nameController.text,
        description: _descriptionController.text,
        price: int.parse(_priceController.text),
        salePrice: _isSale ? int.parse(_salePriceController.text) : 0,
        isSale: _isSale,
        isAvailable: _isAvailable,
        image: _selectedImage!,
        category: _selectedCategory,
      );

      Get.offAllNamed('/home');

      Get.snackbar(
        'موفقیت',
        'محصول با موفقیت اضافه شد',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Error adding product: $e');
      Get.snackbar(
        'خطا',
        'خطا در افزودن محصول: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      Get.snackbar(
        'خطا',
        'خطا در انتخاب تصویر: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _salePriceController.dispose();
    _stockController.dispose();
    super.dispose();
  }
}
