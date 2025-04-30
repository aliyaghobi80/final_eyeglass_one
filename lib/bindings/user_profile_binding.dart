import 'package:get/get.dart';
import '../screens/user_profile_screen.dart';

class UserProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UserProfileScreen>(() => UserProfileScreen());
  }
}
