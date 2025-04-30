import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../models/user.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  final AuthController authController = Get.find<AuthController>();
  List<User> users = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      final loadedUsers = await authController.getAllUsers();
      setState(() {
        users = loadedUsers;
      });
    } catch (e) {
      Get.snackbar('خطا', e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('مدیریت کاربران'), centerTitle: true),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child:
            users.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage:
                            user.profilePictureUrl != null
                                ? NetworkImage(user.profilePictureUrl!)
                                : null,
                        child:
                            user.profilePictureUrl == null
                                ? const Icon(Icons.person)
                                : null,
                      ),
                      title: Text(user.username),
                      subtitle: Text(user.email),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (user.isStaff)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.withAlpha(25),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'ادمین',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _showEditUserDialog(context, user),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed:
                                () => _showDeleteUserDialog(context, user),
                          ),
                        ],
                      ),
                    );
                  },
                ),
      ),
    );
  }

  void _showEditUserDialog(BuildContext context, User user) {
    final usernameController = TextEditingController(text: user.username);
    final emailController = TextEditingController(text: user.email);
    final firstNameController = TextEditingController(text: user.firstName);
    final lastNameController = TextEditingController(text: user.lastName);
    final phoneController = TextEditingController(text: user.phone);
    var isStaff = user.isStaff;
    var isActive = user.isActive;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: const Text('ویرایش کاربر'),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: usernameController,
                          decoration: const InputDecoration(
                            labelText: 'نام کاربری',
                          ),
                        ),
                        TextField(
                          controller: emailController,
                          decoration: const InputDecoration(labelText: 'ایمیل'),
                        ),
                        TextField(
                          controller: firstNameController,
                          decoration: const InputDecoration(labelText: 'نام'),
                        ),
                        TextField(
                          controller: lastNameController,
                          decoration: const InputDecoration(
                            labelText: 'نام خانوادگی',
                          ),
                        ),
                        TextField(
                          controller: phoneController,
                          decoration: const InputDecoration(
                            labelText: 'شماره تماس',
                          ),
                        ),
                        CheckboxListTile(
                          title: const Text('ادمین'),
                          value: isStaff,
                          onChanged: (value) {
                            setState(() {
                              isStaff = value ?? false;
                            });
                          },
                        ),
                        CheckboxListTile(
                          title: const Text('فعال'),
                          value: isActive,
                          onChanged: (value) {
                            setState(() {
                              isActive = value ?? false;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('انصراف'),
                    ),
                    TextButton(
                      onPressed: () async {
                        try {
                          await authController.updateUser(
                            user.id,
                            username: usernameController.text,
                            email: emailController.text,
                            firstName: firstNameController.text,
                            lastName: lastNameController.text,
                            phone: phoneController.text,
                            isStaff: isStaff,
                            isActive: isActive,
                          );
                          Get.back();
                          Get.snackbar(
                            'موفق',
                            'اطلاعات کاربر با موفقیت به‌روزرسانی شد',
                          );
                          _loadUsers(); // به‌روزرسانی لیست کاربران
                        } catch (e) {
                          Get.snackbar('خطا', e.toString());
                        }
                      },
                      child: const Text('ذخیره'),
                    ),
                  ],
                ),
          ),
    );
  }

  void _showDeleteUserDialog(BuildContext context, User user) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('حذف کاربر'),
            content: Text('آیا از حذف کاربر ${user.username} اطمینان دارید؟'),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('انصراف'),
              ),
              TextButton(
                onPressed: () async {
                  try {
                    await authController.deleteUser(user.id);
                    Get.back();
                    Get.snackbar('موفق', 'کاربر با موفقیت حذف شد');
                    _loadUsers(); // به‌روزرسانی لیست کاربران
                  } catch (e) {
                    Get.snackbar('خطا', e.toString());
                  }
                },
                child: const Text('حذف'),
              ),
            ],
          ),
    );
  }
}
