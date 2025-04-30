import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import '../controllers/auth_controller.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final AuthController authController = Get.find<AuthController>();
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;
  bool _isLoading = false;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _setupUserListener();
  }

  void _initializeControllers() {
    _usernameController = TextEditingController();
    _emailController = TextEditingController();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _phoneController = TextEditingController();

    if (authController.user.value != null) {
      _updateTextFields(authController.user.value!);
    }
  }

  void _setupUserListener() {
    ever(authController.user, (user) {
      if (mounted && user != null) {
        _updateTextFields(user);
      }
    });
  }

  void _updateTextFields(user) {
    if (!mounted) return;

    setState(() {
      _usernameController.text = user.username ?? '';
      _emailController.text = user.email ?? '';
      _firstNameController.text = user.firstName ?? '';
      _lastNameController.text = user.lastName ?? '';
      _phoneController.text = user.phone ?? '';
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  /// 📷 انتخاب و برش عکس
  Future<void> _pickAndCropImage() async {
    if (!mounted) return;

    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 70,
    );

    if (image == null) return;

    final CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: image.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      compressQuality: 70,
      maxWidth: 512,
      maxHeight: 512,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'برش تصویر',
          toolbarColor: Colors.blue,
          toolbarWidgetColor: Colors.white,
          activeControlsWidgetColor: Colors.blue,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: true,
        ),
        IOSUiSettings(
          title: 'برش تصویر',
          doneButtonTitle: 'تأیید',
          cancelButtonTitle: 'لغو',
        ),
      ],
    );

    if (croppedFile != null && mounted) {
      setState(() => _selectedImage = File(croppedFile.path));
    }
  }

  /// 🔄 ذخیره پروفایل
  Future<void> _updateProfile() async {
    if (!mounted) return;

    if (!_formKey.currentState!.validate()) return;

    bool confirm = await Get.dialog(
      AlertDialog(
        title: const Text(
          'تأیید تغییرات',
          style: TextStyle(fontFamily: 'Vazir'),
        ),
        content: const Text(
          'آیا از تغییر اطلاعات خود مطمئن هستید؟',
          style: TextStyle(fontFamily: 'Vazir'),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('لغو', style: TextStyle(fontFamily: 'Vazir')),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            child: const Text('بله', style: TextStyle(fontFamily: 'Vazir')),
          ),
        ],
      ),
    );

    if (!confirm || !mounted) return;

    setState(() => _isLoading = true);

    try {
      await authController.updateProfile(
        email: _emailController.text.trim(),
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phone: _phoneController.text.trim(),
        profilePicture: _selectedImage,
      );

      if (mounted) {
        Get.snackbar(
          'موفقیت',
          'اطلاعات پروفایل با موفقیت به‌روزرسانی شد',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      if (mounted) {
        Get.snackbar(
          'خطا',
          'مشکلی پیش آمد: $e',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'پروفایل کاربری',
            style: TextStyle(fontFamily: 'Vazir'),
          ),
        ),
        body: Obx(() {
          final user = authController.user.value;
          if (user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Stack(children: [_buildProfilePicture()]),
                  const SizedBox(height: 20),
                  Card(
                    child: Column(
                      children: [
                        _buildListTile(
                          Icons.person,
                          'نام کاربری',
                          _usernameController,
                          enabled: false,
                        ),
                        _buildListTile(
                          Icons.email,
                          'ایمیل',
                          _emailController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'لطفا ایمیل خود را وارد کنید';
                            }
                            if (!value.contains('@')) {
                              return 'لطفا یک ایمیل معتبر وارد کنید';
                            }
                            return null;
                          },
                        ),
                        _buildListTile(
                          Icons.person,
                          'نام',
                          _firstNameController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'لطفا نام خود را وارد کنید';
                            }
                            return null;
                          },
                        ),
                        _buildListTile(
                          Icons.person_outline,
                          'نام خانوادگی',
                          _lastNameController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'لطفا نام خانوادگی خود را وارد کنید';
                            }
                            return null;
                          },
                        ),
                        _buildListTile(
                          Icons.phone,
                          'شماره تلفن',
                          _phoneController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'لطفا شماره تلفن خود را وارد کنید';
                            }
                            if (value.length < 11) {
                              return 'شماره تلفن باید 11 رقم باشد';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _updateProfile,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 30,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child:
                        _isLoading
                            ? const CircularProgressIndicator()
                            : const Text(
                              'ذخیره تغییرات',
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'Vazir',
                              ),
                            ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildProfilePicture() {
    return Stack(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipOval(
            child:
                _selectedImage != null
                    ? Image.file(
                      _selectedImage!,
                      fit: BoxFit.cover,
                      width: 120,
                      height: 120,
                      errorBuilder: (context, error, stackTrace) {
                        print('Error loading profile picture: $error');
                        return Container(
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.grey,
                          ),
                        );
                      },
                    )
                    : authController.user.value?.profilePictureUrl != null
                    ? Image.network(
                      authController.user.value!.profilePictureUrl!,
                      fit: BoxFit.cover,
                      width: 120,
                      height: 120,
                      errorBuilder: (context, error, stackTrace) {
                        print('Error loading profile picture: $error');
                        return Container(
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.grey,
                          ),
                        );
                      },
                    )
                    : Container(
                      color: Colors.grey[200],
                      child: const Icon(
                        Icons.person,
                        size: 60,
                        color: Colors.grey,
                      ),
                    ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: 30,
            height: 30,
            padding: const EdgeInsets.all(1),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.camera_alt, size: 15),
              onPressed: _pickAndCropImage,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildListTile(
    IconData icon,
    String hint,
    TextEditingController controller, {
    bool enabled = true,
    String? Function(String?)? validator,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon),
          title: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hint,
            ),
            enabled: enabled,
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            style: const TextStyle(fontFamily: 'Vazir', fontSize: 16),
            validator: validator,
          ),
        ),
        Divider(height: 1, color: Colors.grey.shade300),
      ],
    );
  }
}
