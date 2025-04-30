import 'package:get/get.dart';
import '../screens/add_product_screen.dart';

class AddProductBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddProductScreen>(() => AddProductScreen());
  }
}
