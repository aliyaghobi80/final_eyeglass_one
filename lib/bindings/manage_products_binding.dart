import 'package:get/get.dart';
import '../screens/manage_products_screen.dart';

class ManageProductsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ManageProductsScreen>(() => ManageProductsScreen());
  }
}
