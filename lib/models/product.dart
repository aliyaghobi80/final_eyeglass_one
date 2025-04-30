import 'dart:convert';

class Product {
  final int id;
  final String name;
  final String description;
  final int price;
  final bool isSale;
  final int salePrice;
  final bool isAvailable;
  final int category;
  final String image;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.isSale,
    required this.salePrice,
    required this.isAvailable,
    required this.category,
    required this.image,
  });

  // محاسبه درصد تخفیف
  int getDiscountPercentage() {
    if (!isSale || price == 0) return 0;
    return ((price - salePrice) / price * 100).round();
  }

  // دریافت قیمت نهایی
  int getFinalPrice() {
    return isSale ? salePrice : price;
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    String decodeString(String? value) {
      if (value == null) return '';
      try {
        // اگر رشته به صورت بایت‌های UTF-8 است
        if (value.contains('\\u')) {
          return utf8.decode(value.codeUnits);
        }
        return value;
      } catch (e) {
        print('Error decoding string: $e');
        return value;
      }
    }

    return Product(
      id: json['id'] != null ? int.parse(json['id'].toString()) : 0,
      name: decodeString(json['name']),
      description: decodeString(json['description']),
      price: json['price'] != null ? int.parse(json['price'].toString()) : 0,
      isSale: json['is_sale'] ?? false,
      salePrice:
      json['sale_price'] != null
          ? int.parse(json['sale_price'].toString())
          : 0,
      isAvailable: json['is_available'] ?? true,
      category:
      json['category'] != null ? int.parse(json['category'].toString()) : 1,
      image: json['image'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'is_sale': isSale,
      'sale_price': salePrice,
      'is_available': isAvailable,
      'category': category,
      'image': image,
    };
  }
}
