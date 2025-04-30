import 'package:get/get.dart';
import '../screens/manage_categories_screen.dart';

class ManageCategoriesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ManageCategoriesScreen>(() => ManageCategoriesScreen());
  }
}
