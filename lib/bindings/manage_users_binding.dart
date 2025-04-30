import 'package:get/get.dart';
import '../screens/manage_users_screen.dart';

class ManageUsersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ManageUsersScreen>(() => ManageUsersScreen());
  }
}
