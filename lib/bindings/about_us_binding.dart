import 'package:get/get.dart';
import '../screens/about_us_screen.dart';

class AboutUsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AboutUsScreen>(() => const AboutUsScreen());
  }
}
