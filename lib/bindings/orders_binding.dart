import 'package:get/get.dart';
import '../screens/orders_screen.dart';

class OrdersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OrdersScreen>(() => const OrdersScreen());
  }
}
