import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';
import '../controllers/product_controller.dart';
import '../controllers/auth_controller.dart';
import '../utils/constants.dart';

class EditProductScreen extends StatefulWidget {
  const EditProductScreen({super.key});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
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
  final AuthController _authController = Get.find<AuthController>();
  RxInt price = 0.obs;
  RxInt salePrice = 0.obs;
  Map<String, dynamic>? _product;

  @override
  void initState() {
    super.initState();
    _checkAdminAccess();
    _initializeProduct();
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

  void _initializeProduct() {
    _product = Get.arguments as Map<String, dynamic>;
    if (_product != null) {
      _nameController.text = _product!['name']?.toString() ?? '';
      _descriptionController.text = _product!['description']?.toString() ?? '';
      _priceController.text = _product!['price']?.toString() ?? '';
      _salePriceController.text = _product!['sale_price']?.toString() ?? '';
      _stockController.text = _product!['stock']?.toString() ?? '';
      _isSale = _product!['is_sale'] ?? false;
      _isAvailable = _product!['is_available'] ?? true;
      _selectedCategory = _product!['category'] ?? 1;
      price.value = int.tryParse(_product!['price']?.toString() ?? '0') ?? 0;
      salePrice.value =
          int.tryParse(_product!['sale_price']?.toString() ?? '0') ?? 0;
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
        final croppedFile = await ImageCropper().cropImage(
          sourcePath: image.path,
          aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: 'برش تصویر',
              toolbarColor: Colors.blue,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.square,
              lockAspectRatio: true,
              hideBottomControls: false,
              showCropGrid: true,
            ),
            IOSUiSettings(
              title: 'برش تصویر',
              aspectRatioLockEnabled: true,
              resetAspectRatioEnabled: false,
            ),
          ],
        );

        if (croppedFile != null) {
          setState(() {
            _selectedImage = File(croppedFile.path);
          });
        }
      }
    } catch (e) {
      print('Error picking image: $e');
      Get.snackbar(
        'خطا',
        'خطا در انتخاب تصویر: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _takePhoto() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        final croppedFile = await ImageCropper().cropImage(
          sourcePath: image.path,
          aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: 'برش تصویر',
              toolbarColor: Colors.blue,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.square,
              lockAspectRatio: true,
              hideBottomControls: false,
              showCropGrid: true,
            ),
            IOSUiSettings(
              title: 'برش تصویر',
              aspectRatioLockEnabled: true,
              resetAspectRatioEnabled: false,
            ),
          ],
        );

        if (croppedFile != null) {
          setState(() {
            _selectedImage = File(croppedFile.path);
          });
        }
      }
    } catch (e) {
      Get.snackbar(
        'خطا',
        'خطا در گرفتن عکس: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final productData = {
        'id': _product!['id'],
        'name': _nameController.text,
        'description': _descriptionController.text,
        'price': int.parse(_priceController.text),
        'sale_price':
            _salePriceController.text.isNotEmpty
                ? int.parse(_salePriceController.text)
                : null,
        'is_sale': _isSale,
        'is_available': _isAvailable,
        'category': _selectedCategory,
      };
      print('Sending data: $productData');
      print('Selected image: $_selectedImage');

      if (_selectedImage != null) {
        await _productController.updateProduct(productData, _selectedImage);
      } else {
        await _productController.updateProduct(productData);
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        Get.back();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      print('Error updating product: $e');
      Get.snackbar(
        'خطا',
        'خطا در به‌روزرسانی محصول: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('ویرایش محصول'), centerTitle: true),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      builder:
                          (context) => Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: const Icon(Icons.photo_library),
                                title: const Text('انتخاب از گالری'),
                                onTap: () {
                                  Navigator.pop(context);
                                  _pickImage();
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.camera_alt),
                                title: const Text('گرفتن عکس'),
                                onTap: () {
                                  Navigator.pop(context);
                                  _takePhoto();
                                },
                              ),
                            ],
                          ),
                    );
                  },
                  child: Container(
                    height: 200,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image:
                            _selectedImage != null
                                ? FileImage(_selectedImage!)
                                : NetworkImage(
                                      '${Constants.baseUrl}${_product!['image']}',
                                    )
                                    as ImageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.black.withOpacity(0.3),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 50,
                        ),
                      ),
                    ),
                  ),
                ),
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
                      return 'لطفا توضیحات محصول را وارد کنید';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(
                    labelText: 'قیمت',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'لطفا قیمت محصول را وارد کنید';
                    }
                    if (int.tryParse(value) == null) {
                      return 'لطفا یک عدد معتبر وارد کنید';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('فروش ویژه'),
                  value: _isSale,
                  onChanged: (value) {
                    setState(() {
                      _isSale = value;
                      if (!value) {
                        _salePriceController.clear();
                      }
                    });
                  },
                ),
                if (_isSale) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _salePriceController,
                    decoration: const InputDecoration(
                      labelText: 'قیمت فروش ویژه',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        if (int.tryParse(value) == null) {
                          return 'لطفا یک عدد معتبر وارد کنید';
                        }
                      }
                      return null;
                    },
                  ),
                ],
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  value: _selectedCategory,
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
                  onChanged: (value) {
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
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('موجود'),
                  value: _isAvailable,
                  onChanged: (value) {
                    setState(() {
                      _isAvailable = value;
                    });
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child:
                      _isLoading
                          ? const CircularProgressIndicator()
                          : const Text('به‌روزرسانی محصول'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
