import 'dart:convert';

class CartItem {
  final int id;
  final int productId;
  final String productName;
  final double price;
  final int quantity;
  final String? imageUrl;
  final bool isSale;
  final double salePrice;
  final String description;
  final bool isAvailable;
  final int categoryId;

  CartItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    this.imageUrl,
    required this.isSale,
    required this.salePrice,
    required this.description,
    required this.isAvailable,
    required this.categoryId,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    final product = json['product'] as Map<String, dynamic>;
    return CartItem(
      id: json['id'],
      productId: product['id'],
      productName: utf8.decode(product['name'].toString().codeUnits),
      price: double.parse(product['price']),
      quantity: json['quantity'],
      imageUrl: product['image'],
      isSale: product['is_sale'] ?? false,
      salePrice: double.parse(product['sale_price'] ?? '0'),
      description: utf8.decode(
        (product['description'] ?? '').toString().codeUnits,
      ),
      isAvailable: product['is_available'] ?? true,
      categoryId: product['category'],
    );
  }

  double getFinalPrice() {
    return isSale ? salePrice : price;
  }

  double getTotalPrice() {
    return getFinalPrice() * quantity;
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'product_id': productId, 'quantity': quantity};
  }
}
