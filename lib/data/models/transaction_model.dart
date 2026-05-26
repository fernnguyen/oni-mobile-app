import '../../domain/entities/transaction_entity.dart';
import 'ordered_product_model.dart';
import 'user_model.dart';

import '../../core/utilities/stable_hash.dart';

class TransactionModel {
  int id;
  String paymentMethod;
  String? customerName;
  String? description;
  String createdById;
  UserModel? createdBy;
  List<OrderedProductModel>? orderedProducts;
  int receivedAmount;
  int returnAmount;
  int totalAmount;
  int totalOrderedProduct;
  String? createdAt;
  String? updatedAt;
  String? orderNo;
  String? remoteId;

  TransactionModel({
    required this.id,
    required this.paymentMethod,
    this.customerName,
    this.description,
    required this.createdById,
    this.createdBy,
    this.orderedProducts,
    required this.receivedAmount,
    required this.returnAmount,
    required this.totalAmount,
    required this.totalOrderedProduct,
    this.createdAt,
    this.updatedAt,
    this.orderNo,
    this.remoteId,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      paymentMethod: json['paymentMethod'],
      customerName: json['customerName'],
      description: json['description'],
      createdById: json['createdById'],
      createdBy: json['createdBy'],
      orderedProducts: json['orderedProducts'] != null
          ? (json['orderedProducts'] as List).map((e) => OrderedProductModel.fromJson(e)).toList()
          : null,
      receivedAmount: json['receivedAmount'],
      returnAmount: json['returnAmount'],
      totalAmount: json['totalAmount'],
      totalOrderedProduct: json['totalOrderedProduct'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      orderNo: json['orderNo'],
      remoteId: json['remoteId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'paymentMethod': paymentMethod,
      'customerName': customerName,
      'description': description,
      'createdById': createdById,
      'createdBy': createdBy,
      'orderedProducts': orderedProducts?.map((e) => e.toJson()).toList(),
      'receivedAmount': receivedAmount,
      'returnAmount': returnAmount,
      'totalAmount': totalAmount,
      'totalOrderedProduct': totalOrderedProduct,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'orderNo': orderNo,
      'remoteId': remoteId,
    };
  }

  factory TransactionModel.fromEntity(TransactionEntity entity) {
    return TransactionModel(
      id: entity.id ?? DateTime.now().millisecondsSinceEpoch,
      paymentMethod: entity.paymentMethod,
      customerName: entity.customerName,
      description: entity.description,
      createdById: entity.createdById,
      createdBy: entity.createdBy != null ? UserModel.fromEntity(entity.createdBy!) : null,
      orderedProducts: entity.orderedProducts?.map((e) => OrderedProductModel.fromEntity(e)).toList(),
      receivedAmount: entity.receivedAmount,
      returnAmount: entity.returnAmount,
      totalAmount: entity.totalAmount,
      totalOrderedProduct: entity.totalOrderedProduct,
      createdAt: entity.createdAt ?? DateTime.now().toIso8601String(),
      updatedAt: entity.updatedAt ?? DateTime.now().toIso8601String(),
      orderNo: entity.orderNo,
      remoteId: entity.remoteId,
    );
  }

  TransactionEntity toEntity() {
    return TransactionEntity(
      id: id,
      paymentMethod: paymentMethod,
      customerName: customerName,
      description: description,
      createdBy: createdBy?.toEntity(),
      createdById: createdById,
      orderedProducts: orderedProducts?.map((e) => e.toEntity()).toList(),
      receivedAmount: receivedAmount,
      returnAmount: returnAmount,
      totalAmount: totalAmount,
      totalOrderedProduct: totalOrderedProduct,
      createdAt: createdAt,
      updatedAt: updatedAt,
      orderNo: orderNo,
      remoteId: remoteId,
    );
  }

  /// Khởi tạo TransactionModel từ JSON của Backend NextJS ERP
  factory TransactionModel.fromBackendJson(
    Map<String, dynamic> json,
    UserModel user,
    List<OrderedProductModel> items,
  ) {
    final String rawId = json['id']?.toString() ?? '';
    return TransactionModel(
      id: int.tryParse(rawId) ?? getStableHashCode(rawId),
      paymentMethod: json['payment_method'] == 'cash' ? 'Cash' : 'Bank Transfer',
      customerName: json['customer_name']?.toString(),
      description: json['note']?.toString(),
      createdById: user.id,
      createdBy: user,
      orderedProducts: items,
      receivedAmount: double.tryParse(json['paid_amount']?.toString() ?? '')?.toInt() ?? 0,
      returnAmount: double.tryParse(json['debt_amount']?.toString() ?? '')?.toInt() ?? 0,
      totalAmount: double.tryParse(json['total_amount']?.toString() ?? '')?.toInt() ?? 0,
      totalOrderedProduct: items.length,
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      orderNo: json['order_id']?.toString() ?? json['id']?.toString(),
      remoteId: rawId,
    );
  }

  /// Chuyển đổi sang định dạng JSON phù hợp với NextJS ERP Backend
  Map<String, dynamic> toBackendJson(String branchId, String employeeId) {
    final items = orderedProducts?.map((e) => e.toBackendJson(id.toString(), branchId)).toList() ?? [];

    return {
      'order_no': 'ORD-$id',
      'status': 'completed',
      'customer_id': '', // let server auto-generate/resolve
      'customer_name': customerName ?? 'Khách lẻ',
      'branch_id': branchId,
      'employee_id': employeeId,
      'channel': 'pos',
      'subtotal': totalAmount.toString(),
      'discount_amount': '0',
      'shipping_fee': '0',
      'tax_amount': '0',
      'total_amount': totalAmount.toString(),
      'paid_amount': receivedAmount.toString(),
      'debt_amount': (totalAmount - receivedAmount).clamp(0, 999999999).toString(),
      'is_return': 'FALSE',
      'payment_method': paymentMethod == 'Cash' ? 'cash' : 'bank_transfer',
      'note': description ?? '',
      'items': items,
    };
  }
}
