import 'package:get/get.dart';
import '../screens/home_screen.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeScreen>(() => HomeScreen());
  }
}
