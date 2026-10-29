class OrdersResponse {
  bool? success;
  String? message;
  List<Order>? data;

  OrdersResponse({this.success, this.message, this.data});

  OrdersResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    if (json['data'] != null) {
      data = <Order>[];
      json['data'].forEach((v) {
        data!.add(Order.fromJson(v));
      });
    }
  }
}

class OrderResponse {
  bool? success;
  String? message;
  Order? data;

  OrderResponse({this.success, this.message, this.data});

  OrderResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? Order.fromJson(json['data']) : null;
  }
}

class TimelineStep {
  String status = '';
  String label = '';
  bool done = false;
  String? at;
  String? note;

  TimelineStep({
    this.status = '',
    this.label = '',
    this.done = false,
    this.at,
    this.note,
  });

  TimelineStep.fromJson(Map<String, dynamic> json) {
    status = json['status'] ?? '';
    label = json['label'] ?? '';
    done = json['done'] ?? false;
    at = json['at'];
    note = json['note'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['label'] = label;
    data['done'] = done;
    data['at'] = at;
    data['note'] = note;
    return data;
  }
}

class OrderLine {
  int? productId;
  String name = '';
  String? image;
  double price = 0;
  int quantity = 0;
  double total = 0;
  Map<String, String> options = {};

  OrderLine({
    this.productId,
    this.name = '',
    this.image,
    this.price = 0,
    this.quantity = 0,
    this.total = 0,
    this.options = const {},
  });

  OrderLine.fromJson(Map<String, dynamic> json) {
    productId = json['product_id'];
    name = json['name'] ?? '';
    image = json['image'];
    price = (json['price'] as num? ?? 0).toDouble();
    quantity = json['quantity'] ?? 0;
    total = (json['total'] as num? ?? 0).toDouble();
    if (json['options'] is Map) {
      options = <String, String>{};
      json['options'].forEach((k, v) {
        options[k] = v.toString();
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['product_id'] = productId;
    data['name'] = name;
    data['image'] = image;
    data['price'] = price;
    data['quantity'] = quantity;
    data['total'] = total;
    data['options'] = options;
    return data;
  }
}

class Order {
  int id = 0;
  String number = '';
  String status = '';
  String statusLabel = '';
  double subtotal = 0;
  double discount = 0;
  double deliveryFee = 0;
  double total = 0;
  String? couponCode;
  String paymentLabel = '';
  String customerName = '';
  String phone = '';
  String address = '';
  String? notes;
  bool canCancel = false;
  int itemsCount = 0;
  List<OrderLine> items = [];
  List<TimelineStep> timeline = [];
  String createdAt = '';

  Order({
    this.id = 0,
    this.number = '',
    this.status = '',
    this.statusLabel = '',
    this.subtotal = 0,
    this.discount = 0,
    this.deliveryFee = 0,
    this.total = 0,
    this.couponCode,
    this.paymentLabel = '',
    this.customerName = '',
    this.phone = '',
    this.address = '',
    this.notes,
    this.canCancel = false,
    this.itemsCount = 0,
    this.items = const [],
    this.timeline = const [],
    this.createdAt = '',
  });

  Order.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    number = json['number'] ?? '';
    status = json['status'] ?? '';
    statusLabel = json['status_label'] ?? '';
    subtotal = (json['subtotal'] as num? ?? 0).toDouble();
    discount = (json['discount'] as num? ?? 0).toDouble();
    deliveryFee = (json['delivery_fee'] as num? ?? 0).toDouble();
    total = (json['total'] as num? ?? 0).toDouble();
    couponCode = json['coupon_code'];
    paymentLabel = json['payment_method_label'] ?? '';
    customerName = json['customer_name'] ?? '';
    phone = json['phone'] ?? '';
    address = json['address'] ?? '';
    notes = json['notes'];
    canCancel = json['can_cancel'] ?? false;
    itemsCount = json['items_count'] ?? 0;
    if (json['items'] != null) {
      items = <OrderLine>[];
      json['items'].forEach((v) {
        items.add(OrderLine.fromJson(v));
      });
    }
    if (json['timeline'] != null) {
      timeline = <TimelineStep>[];
      json['timeline'].forEach((v) {
        timeline.add(TimelineStep.fromJson(v));
      });
    }
    createdAt = json['created_at'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['number'] = number;
    data['status'] = status;
    data['status_label'] = statusLabel;
    data['subtotal'] = subtotal;
    data['discount'] = discount;
    data['delivery_fee'] = deliveryFee;
    data['total'] = total;
    data['coupon_code'] = couponCode;
    data['payment_method_label'] = paymentLabel;
    data['customer_name'] = customerName;
    data['phone'] = phone;
    data['address'] = address;
    data['notes'] = notes;
    data['can_cancel'] = canCancel;
    data['items_count'] = itemsCount;
    data['items'] = items.map((v) => v.toJson()).toList();
    data['timeline'] = timeline.map((v) => v.toJson()).toList();
    data['created_at'] = createdAt;
    return data;
  }
}
