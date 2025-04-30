import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import '../controllers/auth_controller.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthController authController = Get.find<AuthController>();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  // Add focus nodes
  final FocusNode usernameFocus = FocusNode();
  final FocusNode emailFocus = FocusNode();
  final FocusNode firstNameFocus = FocusNode();
  final FocusNode lastNameFocus = FocusNode();
  final FocusNode phoneFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();
  final FocusNode confirmPasswordFocus = FocusNode();

  // Add error states
  final RxString usernameError = ''.obs;
  final RxString emailError = ''.obs;
  final RxString phoneError = ''.obs;
  final RxString passwordError = ''.obs;
  final RxString confirmPasswordError = ''.obs;

  // Add form key
  final _formKey = GlobalKey<FormState>();

  // Add Rx variables
  final Rx<File?> selectedImage = Rx<File?>(null);
  final RxBool showImageError = false.obs;
  final RxString phoneLength = '0/11'.obs;
  final RxBool isPhoneComplete = false.obs;

  @override
  void initState() {
    super.initState();
    // Add listener for phone number changes
    phoneController.addListener(() {
      phoneLength.value = '${phoneController.text.length}/11';
      isPhoneComplete.value = phoneController.text.length == 11;
    });
  }

  // Function to clear all error states
  void _clearErrors() {
    usernameError.value = '';
    emailError.value = '';
    phoneError.value = '';
    passwordError.value = '';
    confirmPasswordError.value = '';
  }

  // Function to handle server errors
  void _handleServerError(String error) {
    try {
      // Check if it's a successful registration response
      if (error.contains('success signup')) {
        return; // Don't show error for successful registration
      }

      final Map<String, dynamic> errorData = json.decode(
        error.replaceAll("ثبت‌نام: ", ""),
      );

      if (errorData.containsKey('username')) {
        if (errorData['username'].contains('username already exists')) {
          setState(() {
            usernameError.value = 'لطفا نام کاربری دیگری انتخاب کنید';
          });
        } else {
          setState(() {
            usernameError.value = errorData['username'].join(', ');
          });
        }
      }

      if (errorData.containsKey('email')) {
        setState(() {
          emailError.value = errorData['email'].join(', ');
        });
      }

      if (errorData.containsKey('phone')) {
        setState(() {
          phoneError.value = errorData['phone'].join(', ');
        });
      }

      if (errorData.containsKey('password')) {
        setState(() {
          passwordError.value = errorData['password'].join(', ');
        });
      }
    } catch (e) {
      // Only show error if it's not a successful registration
      if (!error.contains('success signup')) {
        setState(() {
          usernameError.value = 'لطفا نام کاربری دیگری انتخاب کنید';
        });
      }
    }
  }

  // Function to pick and crop image
  Future<void> pickAndCropImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: source,
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

    if (croppedFile != null) {
      selectedImage.value = File(croppedFile.path);
      showImageError.value = false;
    }
  }

  // Show bottom sheet for image source selection
  void showImageSourceSelection(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('دوربین'),
                onTap: () {
                  pickAndCropImage(ImageSource.camera);
                  Get.back();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('گالری'),
                onTap: () {
                  pickAndCropImage(ImageSource.gallery);
                  Get.back();
                },
              ),
            ],
          ),
    );
  }

  // Function to validate and submit form
  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedImage.value == null) {
      showImageError.value = true;
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      setState(() {
        confirmPasswordError.value = 'رمز عبور و تکرار آن باید یکسان باشند';
      });
      return;
    }

    showImageError.value = false;
    _clearErrors(); // Clear previous errors

    try {
      await authController.register(
        username: usernameController.text,
        password: passwordController.text,
        email: emailController.text,
        firstName: firstNameController.text,
        lastName: lastNameController.text,
        phone: phoneController.text,
        profilePicture: selectedImage.value,
      );
    } catch (e) {
      _handleServerError(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 24),
                // Profile picture selection
                Obx(
                  () => Column(
                    children: [
                      GestureDetector(
                        onTap: () => showImageSourceSelection(context),
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color:
                                  showImageError.value
                                      ? Colors.red
                                      : Colors.grey,
                              width: showImageError.value ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child:
                              selectedImage.value == null
                                  ? const Icon(
                                    Icons.add_a_photo,
                                    size: 40,
                                    color: Colors.grey,
                                  )
                                  : ClipRRect(
                                    borderRadius: BorderRadius.circular(50),
                                    child: Image.file(
                                      selectedImage.value!,
                                      fit: BoxFit.cover,
                                      width: 100,
                                      height: 100,
                                    ),
                                  ),
                        ),
                      ),
                      if (showImageError.value)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            'لطفا عکس خود را وارد یا انتخاب کنید',
                            style: TextStyle(
                              color: Colors.red[700],
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Obx(
                  () => TextFormField(
                    controller: usernameController,
                    focusNode: usernameFocus,
                    decoration: InputDecoration(
                      labelText: 'نام کاربری (انگلیسی)',
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      errorText:
                          usernameError.value.isNotEmpty
                              ? usernameError.value
                              : null,
                      errorStyle: const TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                      ),
                    ),
                    onChanged: (_) => _clearErrors(),
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) => emailFocus.requestFocus(),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'لطفا نام کاربری را وارد کنید';
                      }
                      if (value.length < 3) {
                        return 'نام کاربری باید حداقل 3 کاراکتر باشد';
                      }
                      if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
                        return 'نام کاربری باید فقط شامل حروف انگلیسی، اعداد و خط زیر باشد';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: emailController,
                  focusNode: emailFocus,
                  decoration: InputDecoration(
                    labelText: 'ایمیل (انگلیسی)',
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    errorText:
                        emailError.value.isNotEmpty ? emailError.value : null,
                    errorStyle: const TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                    ),
                  ),
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) => firstNameFocus.requestFocus(),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'لطفا ایمیل را وارد کنید';
                    }
                    if (!GetUtils.isEmail(value)) {
                      return 'لطفا یک ایمیل معتبر وارد کنید';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Name fields in a row
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: firstNameController,
                        focusNode: firstNameFocus,
                        decoration: const InputDecoration(
                          labelText: 'نام',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                        ),
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) => lastNameFocus.requestFocus(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'لطفا نام را وارد کنید';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: lastNameController,
                        focusNode: lastNameFocus,
                        decoration: const InputDecoration(
                          labelText: 'نام خانوادگی',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                        ),
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) => phoneFocus.requestFocus(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'لطفا نام خانوادگی را وارد کنید';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: phoneController,
                  focusNode: phoneFocus,
                  decoration: InputDecoration(
                    labelText: 'شماره تلفن',
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    counterText: '',
                    suffix: Obx(
                      () => Text(
                        phoneLength.value,
                        style: TextStyle(
                          color:
                              isPhoneComplete.value
                                  ? Colors.green
                                  : Colors.grey,
                          fontWeight:
                              isPhoneComplete.value
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                        ),
                      ),
                    ),
                    errorText:
                        phoneError.value.isNotEmpty ? phoneError.value : null,
                    errorStyle: const TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                    ),
                  ),
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) => passwordFocus.requestFocus(),
                  maxLength: 11,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'لطفا شماره تلفن را وارد کنید';
                    }
                    if (!GetUtils.isPhoneNumber(value)) {
                      return 'لطفا یک شماره تلفن معتبر وارد کنید';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: passwordController,
                  focusNode: passwordFocus,
                  decoration: InputDecoration(
                    labelText: 'رمز عبور',
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    errorText:
                        passwordError.value.isNotEmpty
                            ? passwordError.value
                            : null,
                    errorStyle: const TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                    ),
                  ),
                  obscureText: true,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) => confirmPasswordFocus.requestFocus(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'لطفا رمز عبور را وارد کنید';
                    }
                    if (value.length < 6) {
                      return 'رمز عبور باید حداقل 6 کاراکتر باشد';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: confirmPasswordController,
                  focusNode: confirmPasswordFocus,
                  decoration: InputDecoration(
                    labelText: 'تکرار رمز عبور',
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    errorText:
                        confirmPasswordError.value.isNotEmpty
                            ? confirmPasswordError.value
                            : null,
                    errorStyle: const TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                    ),
                  ),
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submitForm(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'لطفا تکرار رمز عبور را وارد کنید';
                    }
                    if (value != passwordController.text) {
                      return 'رمز عبور و تکرار آن باید یکسان باشند';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                Obx(
                  () => SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed:
                          authController.isLoading.value ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child:
                          authController.isLoading.value
                              ? const CircularProgressIndicator()
                              : const Text('ثبت نام'),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Get.closeCurrentSnackbar();
                    Get.back();
                  },
                  child: const Text('حساب کاربری دارید؟ وارد شوید'),
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
    usernameFocus.dispose();
    emailFocus.dispose();
    firstNameFocus.dispose();
    lastNameFocus.dispose();
    phoneFocus.dispose();
    passwordFocus.dispose();
    confirmPasswordFocus.dispose();
    phoneController.dispose();
    super.dispose();
  }
}
