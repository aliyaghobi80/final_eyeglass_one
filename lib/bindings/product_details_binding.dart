import 'package:get/get.dart';
import '../screens/product_details_screen.dart';

class ProductDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProductDetailsScreen>(() => ProductDetailsScreen());
  }
}
