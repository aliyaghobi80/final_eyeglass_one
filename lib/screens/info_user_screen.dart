import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';

class InfoUserScreen extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();
  InfoUserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          // بررسی وضعیت ادمین بودن کاربر
          FutureBuilder<bool>(
            future: authController.isAdmin(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }
              return Text('Admin: ${snapshot.data ?? false}');
            },
          ),

          // نمایش اطلاعات کاربر
          Obx(() {
            if (authController.user.value == null) {
              return const CircularProgressIndicator();
            }
            final user = authController.user.value!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Username: ${user.username}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text('Email: ${user.email}', style: TextStyle(fontSize: 16)),
                Text(
                  'First Name: ${user.firstName}',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  'Last Name: ${user.lastName}',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  'Active: ${user.isActive}',
                  style: TextStyle(fontSize: 16),
                ),
                Text('Admin: ${user.isStaff}', style: TextStyle(fontSize: 16)),
                if (user.phone != null)
                  Text('Phone: ${user.phone}', style: TextStyle(fontSize: 16)),
                if (user.createdAt != null)
                  Text(
                    'Created At: ${user.createdAt?.toLocal() ?? "N/A"}',
                    style: TextStyle(fontSize: 16),
                  ),
                if (user.updatedAt != null)
                  Text(
                    'Updated At: ${user.updatedAt?.toLocal() ?? "N/A"}',
                    style: TextStyle(fontSize: 16),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }
}
