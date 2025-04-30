import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeController extends GetxController {
  final GetStorage _box = GetStorage();
  final RxBool isDarkMode = true.obs;

  @override
  void onInit() {
    super.onInit();
    // خواندن مقدار ذخیره شده
    isDarkMode.value = _box.read('isDarkMode') ?? false;
    print("isDarkMode: $isDarkMode");
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }

  void toggleTheme(bool value) {
    isDarkMode.value = value;
    Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
    _box.write('isDarkMode', value); // ذخیره مقدار
  }
}
