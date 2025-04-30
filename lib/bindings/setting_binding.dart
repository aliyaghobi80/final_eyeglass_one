import 'package:get/get.dart';
import '../screens/setting_screen.dart';
import '../controllers/theme_controller.dart';
import '../controllers/auth_controller.dart';

class SettingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SettingScreen>(() => SettingScreen());
    Get.lazyPut<ThemeController>(() => ThemeController());
    Get.lazyPut<AuthController>(() => AuthController());
  }
}
