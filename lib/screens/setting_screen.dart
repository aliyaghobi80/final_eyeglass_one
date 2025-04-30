import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/theme_controller.dart';
import '../controllers/auth_controller.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final authController = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(title: const Text('تنظیمات'), centerTitle: true),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: ListView(
          children: [
            // تنظیمات ظاهری
            const ListTile(
              title: Text(
                'تنظیمات ظاهری',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            Obx(
              () => SwitchListTile(
                secondary: const Icon(Icons.dark_mode),
                title: const Text('حالت تاریک'),
                value: themeController.isDarkMode.value,
                onChanged: (value) => themeController.toggleTheme(value),
              ),
            ),
            const Divider(),

            // تنظیمات حساب کاربری
            const ListTile(
              title: Text(
                'حساب کاربری',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('ویرایش پروفایل'),
              onTap: () => Get.toNamed('/user-profile'),
            ),
            ListTile(
              leading: const Icon(Icons.password),
              title: const Text('تغییر رمز عبور'),
              onTap: () => Get.toNamed('/change-password'),
            ),
            const Divider(),

            // تنظیمات اعلان‌ها
            const ListTile(
              title: Text(
                'اعلان‌ها',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            SwitchListTile(
              secondary: const Icon(Icons.notifications),
              title: const Text('دریافت اعلان‌ها'),
              value: true, // TODO: اتصال به کنترلر اعلان‌ها
              onChanged: (value) {
                // TODO: پیاده‌سازی تغییر وضعیت اعلان‌ها
              },
            ),
            SwitchListTile(
              secondary: const Icon(Icons.local_offer),
              title: const Text('اعلان تخفیف‌ها'),
              value: true, // TODO: اتصال به کنترلر اعلان‌ها
              onChanged: (value) {
                // TODO: پیاده‌سازی تغییر وضعیت اعلان‌های تخفیف
              },
            ),
            const Divider(),

            // خروج از حساب کاربری
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'خروج از حساب کاربری',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () async {
                await authController.logout();
                Get.offAllNamed('/login');
              },
            ),
          ],
        ),
      ),
    );
  }
}
