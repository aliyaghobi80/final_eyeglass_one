import 'package:cached_network_image/cached_network_image.dart';
import 'package:eyewear/widgets/static_buttons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';

class CustomDrawer extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();

  CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // هدر دراور با اطلاعات کاربر
          UserAccountsDrawerHeader(
            accountName: Row(
              spacing: 5,
              children: [
                Obx(
                  () => Text(
                    authController.user.value?.firstName ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Vazir',
                    ),
                  ),
                ),
                if (authController.user.value?.isStaff == true)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.yellow.withAlpha(25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Text(
                          'ادمین',
                          style: TextStyle(color: Colors.black, fontSize: 12),
                        ),
                        const Icon(Icons.verified, color: Colors.green),
                      ],
                    ),
                  ),
              ],
            ),

            accountEmail: Obx(
              () => Text(
                authController.user.value?.email ?? '',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                  fontFamily: 'Vazir',
                ),
              ),
            ),
            currentAccountPicture: GestureDetector(
              onTap: () {
                if (authController.user.value?.profilePictureUrl != null) {
                  Get.dialog(
                    Dialog(
                      child: Hero(
                        tag: 'profile-picture',
                        child: Container(
                          width: double.infinity,
                          height: 400,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: CachedNetworkImage(
                              imageUrl:
                                  authController.user.value!.profilePictureUrl!,
                              fit: BoxFit.contain,
                              placeholder:
                                  (context, url) => const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                              errorWidget:
                                  (context, url, error) =>
                                      const Icon(Icons.error),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }
              },
              child: Hero(
                tag: 'profile-picture',
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white30,
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: Obx(
                      () =>
                          authController.user.value?.profilePictureUrl != null
                              ? CachedNetworkImage(
                                imageUrl:
                                    authController
                                        .user
                                        .value!
                                        .profilePictureUrl!,
                                fit: BoxFit.cover,
                                placeholder:
                                    (context, url) =>
                                        const CircularProgressIndicator(),
                                errorWidget:
                                    (context, url, error) =>
                                        const Icon(Icons.person, size: 40),
                              )
                              : const Icon(Icons.person, size: 40),
                    ),
                  ),
                ),
              ),
            ),
            decoration: const BoxDecoration(color: Colors.blue),
          ),

          // پروفایل کاربری
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text(
              'پروفایل کاربری',
              style: TextStyle(fontFamily: 'Vazir'),
            ),
            onTap: () {
              Get.toNamed('/user-profile');
            },
          ),

          // مدیریت محصولات (برای ادمین)
          Obx(
            () =>
                authController.user.value?.isStaff == true
                    ? ExpansionTile(
                      leading: const Icon(Icons.shopping_bag),
                      title: const Text(
                        'مدیریت محصولات',
                        style: TextStyle(fontFamily: 'Vazir'),
                      ),
                      children: [
                        ListTile(
                          leading: const Icon(Icons.category),
                          title: const Text(
                            'مدیریت دسته‌بندی‌ها',
                            style: TextStyle(fontFamily: 'Vazir'),
                          ),
                          onTap: () {
                            Get.toNamed('/manage-categories');
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.add_box),
                          title: const Text(
                            'افزودن محصول جدید',
                            style: TextStyle(fontFamily: 'Vazir'),
                          ),
                          onTap: () {
                            Get.toNamed('/add-product');
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.inventory),
                          title: const Text(
                            'لیست محصولات',
                            style: TextStyle(fontFamily: 'Vazir'),
                          ),
                          onTap: () {
                            Get.toNamed('/manage-products');
                          },
                        ),
                      ],
                    )
                    : const SizedBox.shrink(),
          ),

          // مدیریت کاربران (برای ادمین)
          Obx(
            () =>
                authController.user.value?.isStaff == true
                    ? ListTile(
                      leading: const Icon(Icons.people),
                      title: const Text(
                        'مدیریت کاربران',
                        style: TextStyle(fontFamily: 'Vazir'),
                      ),
                      onTap: () {
                        Get.toNamed('/manage-users');
                      },
                    )
                    : const SizedBox.shrink(),
          ),

          // سبد خرید (فقط برای ادمین)
          Obx(
            () =>
                authController.user.value?.isStaff != true
                    ? ListTile(
                      leading: const Icon(Icons.shopping_cart),
                      title: const Text('سبد خرید'),
                      onTap: () {
                        Get.back();
                        Get.toNamed('/cart');
                      },
                    )
                    : const SizedBox.shrink(),
          ),

          // تنظیمات
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('تنظیمات', style: TextStyle(fontFamily: 'Vazir')),
            onTap: () {
              Get.toNamed('/settings');
            },
          ),

          // درباره ما
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text(
              'درباره ما',
              style: TextStyle(fontFamily: 'Vazir'),
            ),
            onTap: () {
              Get.toNamed('/about-us');
            },
          ),

          // سفارشات من (فقط برای ادمین)
          Obx(
            () =>
                authController.user.value?.isStaff != true
                    ? ListTile(
                      leading: const Icon(Icons.shopping_bag),
                      title: const Text('سفارشات من'),
                      onTap: () {
                        Get.back();
                        Get.toNamed('/orders');
                      },
                    )
                    : const SizedBox.shrink(),
          ),

          const Divider(),

          // خروج
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('خروج', style: TextStyle(fontFamily: 'Vazir')),
            onTap: () {
              Get.bottomSheet(
                BottomSheet(
                  onClosing: () {},
                  builder: (context) {
                    return SizedBox(
                      height: 150,
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            const Text(
                              'آیا واقعا میخواهید از حساب جاری خارج شوید؟',
                              style: TextStyle(fontFamily: 'Vazir'),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(
                                  child: CustomOkButton(
                                    onPressed: () {
                                      authController.logout();
                                    },
                                    text: 'بله',
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: CustomCancelButton(
                                    onPressed: () {
                                      Get.back();
                                    },
                                    text: 'خیر',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
