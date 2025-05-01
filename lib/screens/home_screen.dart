import 'package:eyewear/controllers/cart_controller.dart';
import 'package:eyewear/controllers/product_controller.dart';
import 'package:eyewear/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:persian_number_utility/persian_number_utility.dart';
import '../controllers/auth_controller.dart';
import '../widgets/cart_Icon_Badge.dart';
import '../widgets/custom_drawer.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthController authController = Get.find<AuthController>();
  final ProductController productController = Get.find<ProductController>();
  final CartController cartController = Get.put(CartController());
  final searchController = TextEditingController();
  final _isSearching = false.obs;
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    searchController.dispose();
    super.dispose();
  }

  void _startSearch() {
    _isSearching.value = true;
  }

  void _stopSearch() {
    _isSearching.value = false;
    searchController.clear();
    _debounce?.cancel();
    productController.fetchProducts(); // Reset to original products list
  }

  void _handleSearch(String value) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();

    if (value.isEmpty) {
      productController.fetchProducts();
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 800), () {
      productController.searchProducts(value);
    });
  }

  void _filterByCategory(String category) {
    productController.filterProductsByCategory(category);
    setState(() {}); // Force UI update
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            Obx(
              () => SliverAppBar(
                floating: true,
                snap: true,
                title:
                    _isSearching.value
                        ? TextField(
                          controller: searchController,
                          textAlign: TextAlign.right,
                          textDirection: TextDirection.rtl,
                          decoration: InputDecoration(
                            hintText: 'جستجوی محصول...',
                            hintStyle: const TextStyle(color: Colors.white70),
                            border: InputBorder.none,
                            suffixIcon: IconButton(
                              icon: const Icon(
                                Icons.clear,
                                color: Colors.white,
                              ),
                              onPressed: _stopSearch,
                            ),
                          ),
                          style: const TextStyle(color: Colors.white),
                          onChanged: _handleSearch,
                        )
                        : const Text('فروشگاه عینک'),
                centerTitle: true,
                elevation: 2,
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                actions: [
                  IconButton(
                    icon: Icon(
                      _isSearching.value ? Icons.search : Icons.search,
                    ),
                    onPressed: _startSearch,
                  ),
                  if (!_isSearching.value)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Obx(
                        () => CartIconWithBadge(
                          itemCount: cartController.cartItems.length,
                          onTap: () => Get.toNamed('cart'),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Category Filter Bar
            SliverToBoxAdapter(
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  color: Get.isDarkMode ? Colors.grey[900] : Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Obx(
                  () => ListView.builder(
                    scrollDirection: Axis.horizontal,
                    reverse: true,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: productController.categories.length + 1,
                    itemBuilder: (context, index) {
                      final category =
                          index == 0
                              ? 'همه'
                              : productController.categories[index - 1]['name'];
                      final isSelected =
                          productController.selectedCategory.value == category;

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 8,
                        ),
                        child: InkWell(
                          onTap: () {
                            _filterByCategory(category);
                            // Scroll to selected category
                            final controller = ScrollController();
                            controller.animateTo(
                              index *
                                  100.0, // Adjust this value based on your item width
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? Theme.of(context).primaryColor
                                      : Get.isDarkMode
                                      ? Colors.grey[800]
                                      : Colors.grey[100],
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color:
                                    isSelected
                                        ? Theme.of(context).primaryColor
                                        : (Get.isDarkMode
                                            ? Colors.grey[700]!
                                            : Colors.grey[300]!),
                                width: 1,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                category,
                                style: TextStyle(
                                  color:
                                      isSelected
                                          ? Colors.white
                                          : Get.isDarkMode
                                          ? Colors.white
                                          : Colors.black87,
                                  fontWeight:
                                      isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ];
        },
        body: Obx(() {
          if (productController.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (productController.products.isEmpty) {
            return _buildEmptyState();
          }

          // گروه‌بندی محصولات بر اساس دسته‌بندی
          final productsByCategory = <String, List<Map<String, dynamic>>>{};

          // ایجاد نگاشت برای دسته‌بندی‌ها
          final categoryMap = {
            for (var category in productController.categories)
              category['id'].toString(): category['name'].toString(),
          };

          // اضافه کردن محصولات تخفیف‌دار به دسته‌بندی مخصوص
          final discountedProducts =
              productController.products
                  .where((product) => product['is_sale'] == true)
                  .toList();

          if (discountedProducts.isNotEmpty) {
            productsByCategory['محصولات تخفیف‌دار'] = discountedProducts;
          }

          // اضافه کردن محصولات به دسته‌بندی‌های مربوطه
          for (var product in productController.products) {
            final categoryId = product['category']?.toString() ?? '0';
            final categoryName = categoryMap[categoryId] ?? 'سایر';

            if (!productsByCategory.containsKey(categoryName)) {
              productsByCategory[categoryName] = [];
            }
            productsByCategory[categoryName]!.add(product);
          }

          // مرتب‌سازی دسته‌بندی‌ها
          final sortedCategories =
              productsByCategory.keys.toList()..sort((a, b) {
                if (a == 'محصولات تخفیف‌دار') return -1;
                if (b == 'محصولات تخفیف‌دار') return 1;
                if (a == 'سایر') return 1;
                if (b == 'سایر') return -1;
                return a.compareTo(b);
              });

          // اگر دسته‌بندی انتخاب شده است، فقط آن دسته‌بندی را نمایش بده
          if (productController.selectedCategory.value != 'همه') {
            final selectedProducts =
                productsByCategory[productController.selectedCategory.value] ??
                [];
            if (selectedProducts.isEmpty) {
              return _buildEmptyState();
            }

            // جدا کردن محصولات تخفیف‌دار و معمولی
            final discountedProducts =
                selectedProducts
                    .where((product) => product['is_sale'] == true)
                    .toList();
            final regularProducts =
                selectedProducts
                    .where((product) => product['is_sale'] != true)
                    .toList();

            return RefreshIndicator(
              onRefresh: () async {
                await productController.fetchCategories();
                return productController.fetchProducts();
              },
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 16),
                children: [
                  if (discountedProducts.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Text(
                        'محصولات تخفیف‌دار ${productController.selectedCategory.value}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Get.isDarkMode ? Colors.white : Colors.black87,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                    SizedBox(
                      height: 380,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        reverse: true,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        itemCount: discountedProducts.length,
                        itemBuilder: (context, index) {
                          return SizedBox(
                            width: 220,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              child: _buildProductCard(
                                discountedProducts[index],
                                context,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                  if (regularProducts.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Text(
                        productController.selectedCategory.value,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                    SizedBox(
                      height: 380,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        reverse: true,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        itemCount: regularProducts.length,
                        itemBuilder: (context, index) {
                          return SizedBox(
                            width: 220,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              child: _buildProductCard(
                                regularProducts[index],
                                context,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await productController.fetchCategories();
              return productController.fetchProducts();
            },
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: sortedCategories.length,
              itemBuilder: (context, index) {
                final category = sortedCategories[index];
                final products = productsByCategory[category]!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Text(
                        category,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                    SizedBox(
                      height: 380,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        reverse: true,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          return SizedBox(
                            width: 220,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              child: _buildProductCard(
                                products[index],
                                context,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        }),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'هیچ کالایی برای نمایش وجود ندارد',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => productController.fetchProducts(),
            icon: const Icon(Icons.refresh),
            label: const Text('بارگذاری مجدد'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product, BuildContext context) {
    final bool isOnSale = product['is_sale'] == true;
    final bool isAvailable = product['is_available'] == true;
    final double discount =
        isOnSale
            ? ((double.parse(product['price']) -
                        double.parse(product['sale_price'])) /
                    double.parse(product['price']) *
                    100)
                .round()
                .toDouble()
            : 0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth;
        final imageHeight = cardWidth * 0.8;

        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () => Get.toNamed('/product-details', arguments: product),
            borderRadius: BorderRadius.circular(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      child: Image.network(
                        '${Constants.baseUrl}${product['image']}',
                        height: imageHeight,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) => Container(
                              height: imageHeight,
                              color:
                                  Get.isDarkMode
                                      ? Colors.grey[800]
                                      : Colors.grey[200],
                              child: Icon(
                                Icons.image_not_supported,
                                size: imageHeight * 0.3,
                                color:
                                    Get.isDarkMode
                                        ? Colors.grey[600]
                                        : Colors.grey[400],
                              ),
                            ),
                      ),
                    ),
                    if (isOnSale)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '%${discount.toInt()} تخفیف',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    if (!isAvailable)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 25),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12),
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              'ناموجود',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.end, // راست چین کردن محتوا
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          product['name']?.toString() ?? '',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color:
                                Get.isDarkMode ? Colors.white : Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right, // راست چین کردن متن
                        ),
                        const SizedBox(height: 4),
                        Text(
                          product['description']?.toString() ?? '',
                          style: TextStyle(
                            fontSize: 11,
                            height: 1.5,
                            color:
                                Get.isDarkMode
                                    ? Colors.grey[400]
                                    : Colors.black87,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                        ),
                        const Spacer(),
                        if (isOnSale)
                          Text(
                            '${double.parse(product['price']).toInt().toString().seRagham()} تومان',
                            style: TextStyle(
                              fontSize: 10,
                              color:
                                  Get.isDarkMode
                                      ? Colors.grey[500]
                                      : Colors.grey[600],
                              decoration: TextDecoration.lineThrough,
                            ),
                            textAlign: TextAlign.right, // راست چین کردن متن
                          ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (isAvailable)
                              SizedBox(
                                width: 28,
                                height: 28,
                                child: IconButton(
                                  onPressed:
                                      () => cartController.addToCart(
                                        product['id'],
                                        1,
                                      ),
                                  icon: const Icon(
                                    Icons.add_shopping_cart,
                                    size: 16,
                                  ),
                                  padding: EdgeInsets.zero,
                                  color:
                                      Get.isDarkMode
                                          ? Colors.white
                                          : Theme.of(context).primaryColor,
                                  tooltip: 'افزودن به سبد خرید',
                                ),
                              ),
                            Expanded(
                              child: Text(
                                '${double.parse(isOnSale ? product['sale_price'] : product['price']).toInt().toString().seRagham()} تومان',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      isOnSale
                                          ? Colors.green[700]
                                          : (Get.isDarkMode
                                              ? Colors.white
                                              : Theme.of(context).primaryColor),
                                ),
                                textAlign: TextAlign.right, // راست چین کردن متن
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
