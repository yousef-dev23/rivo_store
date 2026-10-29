class CartResponse {
  bool? success;
  String? message;
  CartSummary? data;

  CartResponse({this.success, this.message, this.data});

  CartResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? CartSummary.fromJson(json['data']) : null;
  }
}

class CartItem {
  int id = 0;
  int productId = 0;
  String name = '';
  String? image;
  double unitPrice = 0;
  double originalPrice = 0;
  int quantity = 1;
  Map<String, String> options = {};
  double lineTotal = 0;
  int stock = 0;
  bool isAvailable = true;

  CartItem({
    this.id = 0,
    this.productId = 0,
    this.name = '',
    this.image,
    this.unitPrice = 0,
    this.originalPrice = 0,
    this.quantity = 1,
    this.options = const {},
    this.lineTotal = 0,
    this.stock = 0,
    this.isAvailable = true,
  });

  CartItem.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    productId = json['product_id'];
    name = json['name'] ?? '';
    image = json['image'];
    unitPrice = (json['unit_price'] as double? ?? 0);
    originalPrice = (json['original_price'] as num? ?? 0).toDouble();
    quantity = json['quantity'] ?? 1;
    if (json['options'] is Map) {
      options = <String, String>{};
      json['options'].forEach((k, v) {
        options[k] = v.toString();
      });
    }
    lineTotal = (json['line_total'] as num? ?? 0).toDouble();
    stock = json['stock'] ?? 0;
    isAvailable = json['is_available'] ?? true;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['product_id'] = productId;
    data['name'] = name;
    data['image'] = image;
    data['unit_price'] = unitPrice;
    data['original_price'] = originalPrice;
    data['quantity'] = quantity;
    data['options'] = options;
    data['line_total'] = lineTotal;
    data['stock'] = stock;
    data['is_available'] = isAvailable;
    return data;
  }
}

/// الملخص الكامل الذي يعيده الخادم مع كل عملية على السلة.
class CartSummary {
  List<CartItem> items = [];
  int itemsCount = 0;
  double subtotal = 0;
  double discount = 0;
  double deliveryFee = 0;
  double total = 0;
  String? couponCode;
  String? couponError;
  double minOrder = 0;
  bool meetsMinOrder = true;

  CartSummary({
    this.items = const [],
    this.itemsCount = 0,
    this.subtotal = 0,
    this.discount = 0,
    this.deliveryFee = 0,
    this.total = 0,
    this.couponCode,
    this.couponError,
    this.minOrder = 0,
    this.meetsMinOrder = true,
  });

  bool get isEmpty => items.isEmpty;

  CartSummary.fromJson(Map<String, dynamic> json) {
    if (json['items'] != null) {
      items = <CartItem>[];
      json['items'].forEach((v) {
        items.add(CartItem.fromJson(v));
      });
    }
    itemsCount = json['items_count'] ?? 0;
    subtotal = (json['subtotal'] as num? ?? 0).toDouble();
    discount = (json['discount'] as num? ?? 0).toDouble();
    deliveryFee = (json['delivery_fee'] as num? ?? 0).toDouble();
    total = (json['total'] as num? ?? 0).toDouble();
    couponCode = json['coupon_code'];
    couponError = json['coupon_error'];
    minOrder = (json['min_order'] as num? ?? 0).toDouble();
    meetsMinOrder = json['meets_min_order'] ?? true;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['items'] = items.map((v) => v.toJson()).toList();
    data['items_count'] = itemsCount;
    data['subtotal'] = subtotal;
    data['discount'] = discount;
    data['delivery_fee'] = deliveryFee;
    data['total'] = total;
    data['coupon_code'] = couponCode;
    data['coupon_error'] = couponError;
    data['min_order'] = minOrder;
    data['meets_min_order'] = meetsMinOrder;
    return data;
  }
}
