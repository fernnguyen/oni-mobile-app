import '../../domain/entities/ordered_product_entity.dart';

import '../../core/utilities/stable_hash.dart';

class OrderedProductModel {
  int id;
  int transactionId;
  int productId;
  int quantity;
  int stock;
  String name;
  String imageUrl;
  int price;
  String? createdAt;
  String? updatedAt;

  OrderedProductModel({
    required this.id,
    required this.transactionId,
    required this.productId,
    required this.quantity,
    required this.stock,
    required this.name,
    required this.imageUrl,
    required this.price,
    this.createdAt,
    this.updatedAt,
  });

  factory OrderedProductModel.fromJson(Map<String, dynamic> json) {
    return OrderedProductModel(
      id: json['id'],
      transactionId: json['transactionId'],
      productId: json['productId'],
      quantity: json['quantity'],
      stock: json['stock'],
      name: json['name'],
      imageUrl: json['imageUrl'],
      price: json['price'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transactionId': transactionId,
      'productId': productId,
      'quantity': quantity,
      'stock': stock,
      'name': name,
      'imageUrl': imageUrl,
      'price': price,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory OrderedProductModel.fromEntity(OrderedProductEntity entity) {
    return OrderedProductModel(
      id: entity.id ?? DateTime.now().millisecondsSinceEpoch,
      transactionId: entity.transactionId ?? DateTime.now().millisecondsSinceEpoch,
      productId: entity.productId,
      quantity: entity.quantity,
      stock: entity.stock,
      name: entity.name,
      imageUrl: entity.imageUrl,
      price: entity.price,
      createdAt: entity.createdAt ?? DateTime.now().toIso8601String(),
      updatedAt: entity.updatedAt ?? DateTime.now().toIso8601String(),
    );
  }

  OrderedProductEntity toEntity() {
    return OrderedProductEntity(
      id: id,
      transactionId: transactionId,
      productId: productId,
      quantity: quantity,
      stock: stock,
      name: name,
      imageUrl: imageUrl,
      price: price,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Khởi tạo OrderedProductModel từ JSON của Backend NextJS ERP
  factory OrderedProductModel.fromBackendJson(Map<String, dynamic> json) {
    final String rawId = json['id']?.toString() ?? '';
    final String rawOrderId = json['order_id']?.toString() ?? '';
    final String rawProductId = json['product_id']?.toString() ?? '';

    return OrderedProductModel(
      id: int.tryParse(rawId) ?? getStableHashCode(rawId),
      transactionId: int.tryParse(rawOrderId) ?? getStableHashCode(rawOrderId),
      productId: int.tryParse(rawProductId) ?? getStableHashCode(rawProductId),
      quantity: double.tryParse(json['qty']?.toString() ?? '')?.toInt() ?? 0,
      stock: 0,
      name: json['product_name']?.toString() ?? '',
      imageUrl: '',
      price: double.tryParse(json['unit_price']?.toString() ?? '')?.toInt() ?? 0,
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  /// Chuyển đổi sang định dạng JSON phù hợp với NextJS ERP Backend
  Map<String, dynamic> toBackendJson(String orderId, String branchId) {
    return {
      'order_id': orderId,
      'line_no': id.toString(),
      'product_id': productId.toString(),
      'product_name': name,
      'qty': quantity.toString(),
      'unit_price': price.toString(),
      'line_total': (quantity * price).toString(),
      'branch_id': branchId,
    };
  }
}
