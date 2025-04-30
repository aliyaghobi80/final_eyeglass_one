import 'package:get/get.dart';
import '../screens/login_screen.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoginScreen>(() => LoginScreen());
  }
}
