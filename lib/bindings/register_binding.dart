import 'package:get/get.dart';
import '../screens/register_screen.dart';

class RegisterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RegisterScreen>(() => RegisterScreen());
  }
}
