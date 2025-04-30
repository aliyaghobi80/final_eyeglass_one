import 'package:get/get.dart';
import '../screens/edit_product_screen.dart';

class EditProductBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EditProductScreen>(() => EditProductScreen());
  }
}
