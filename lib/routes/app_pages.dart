import 'package:get/get.dart';
import '../bindings/orders_binding.dart';
import '../screens/home_screen.dart';
import '../screens/login_screen.dart';
import '../screens/orders_screen.dart';
import '../screens/register_screen.dart';
import '../screens/user_profile_screen.dart';
import '../screens/cart_screen.dart';
import '../screens/manage_categories_screen.dart';
import '../screens/manage_products_screen.dart';
import '../screens/add_product_screen.dart';
import '../screens/edit_product_screen.dart';
import '../screens/setting_screen.dart';
import '../screens/about_us_screen.dart';
import '../screens/product_details_screen.dart';
import '../screens/manage_users_screen.dart';
import '../screens/change_password_screen.dart';
import '../bindings/home_binding.dart';
import '../bindings/login_binding.dart';
import '../bindings/register_binding.dart';
import '../bindings/user_profile_binding.dart';
import '../bindings/cart_binding.dart';
import '../bindings/manage_categories_binding.dart';
import '../bindings/manage_products_binding.dart';
import '../bindings/add_product_binding.dart';
import '../bindings/edit_product_binding.dart';
import '../bindings/setting_binding.dart';
import '../bindings/about_us_binding.dart';
import '../bindings/product_details_binding.dart';
import '../bindings/manage_users_binding.dart';

part 'app_routes.dart';

class AppPages {
  static const initial = Routes.LOGIN;

  static final routes = [
    GetPage(
      name: Routes.HOME,
      page: () => HomeScreen(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: Routes.LOGIN,
      page: () => LoginScreen(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: Routes.REGISTER,
      page: () => RegisterScreen(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: Routes.USER_PROFILE,
      page: () => UserProfileScreen(),
      binding: UserProfileBinding(),
    ),
    GetPage(
      name: Routes.CART,
      page: () => CartScreen(),
      binding: CartBinding(),
    ),
    GetPage(
      name: Routes.MANAGE_CATEGORIES,
      page: () => ManageCategoriesScreen(),
      binding: ManageCategoriesBinding(),
    ),
    GetPage(
      name: Routes.MANAGE_PRODUCTS,
      page: () => ManageProductsScreen(),
      binding: ManageProductsBinding(),
    ),
    GetPage(
      name: Routes.ADD_PRODUCT,
      page: () => AddProductScreen(),
      binding: AddProductBinding(),
    ),
    GetPage(
      name: Routes.EDIT_PRODUCT,
      page: () => EditProductScreen(),
      binding: EditProductBinding(),
    ),
    GetPage(
      name: Routes.SETTINGS,
      page: () => SettingScreen(),
      binding: SettingBinding(),
    ),
    GetPage(
      name: Routes.ABOUT_US,
      page: () => AboutUsScreen(),
      binding: AboutUsBinding(),
    ),
    GetPage(
      name: Routes.PRODUCT_DETAILS,
      page: () => ProductDetailsScreen(),
      binding: ProductDetailsBinding(),
    ),
    GetPage(
      name: Routes.MANAGE_USERS,
      page: () => ManageUsersScreen(),
      binding: ManageUsersBinding(),
    ),
    GetPage(
      name: Routes.CHANGE_PASSWORD,
      page: () => const ChangePasswordScreen(),
    ),

    GetPage(
      name: Routes.ORDERS,
      page: () => const OrdersScreen(),
      binding: OrdersBinding(),
    ),
  ];
}
