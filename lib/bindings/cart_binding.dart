import 'package:get/get.dart';
import '../screens/cart_screen.dart';

class CartBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CartScreen>(() => CartScreen());
  }
}
