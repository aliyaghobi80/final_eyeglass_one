import 'dart:convert';

class Order {
  final int id;
  final String status;
  final String createdAt;
  final double totalAmount;
  final String address;
  final String phone;
  final String customerName;
  final List<OrderItem> items;

  Order({
    required this.id,
    required this.status,
    required this.createdAt,
    required this.totalAmount,
    required this.address,
    required this.phone,
    required this.customerName,
    required this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      status: json['status'] == 'pending' ? 'در انتظار پرداخت' : 'پرداخت شده',
      createdAt: json['created_at'],
      totalAmount: double.parse(json['total_amount']),
      address: utf8.decode(json['address'].codeUnits),
      phone: json['phone'],
      customerName: utf8.decode(json['customer_name'].codeUnits),
      items:
          (json['items'] as List<dynamic>?)
              ?.map((item) => OrderItem.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class OrderItem {
  final Map<String, dynamic> product;
  final int quantity;
  final double price;

  OrderItem({
    required this.product,
    required this.quantity,
    required this.price,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> decodedProduct = Map.from(json['product']);
    decodedProduct['name'] = utf8.decode(json['product']['name'].codeUnits);
    decodedProduct['description'] = utf8.decode(
      json['product']['description'].codeUnits,
    );

    return OrderItem(
      product: decodedProduct,
      quantity: json['quantity'],
      price: double.parse(json['price']),
    );
  }

  double getTotalPrice() {
    return price * quantity;
  }
}
