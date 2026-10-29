class ProductsResponse {
  bool? success;
  String? message;
  List<Product>? data;
  Meta? meta;

  ProductsResponse({this.success, this.message, this.data, this.meta});

  ProductsResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    if (json['data'] != null) {
      data = <Product>[];
      json['data'].forEach((v) {
        data!.add(Product.fromJson(v));
      });
    }
    meta = json['meta'] != null ? Meta.fromJson(json['meta']) : null;
  }
}

class Meta {
  int page = 1;
  int lastPage = 1;
  int total = 0;

  Meta({this.page = 1, this.lastPage = 1, this.total = 0});

  bool get hasMore => page < lastPage;

  Meta.fromJson(Map<String, dynamic> json) {
    page = json['page'] ?? 1;
    lastPage = json['last_page'] ?? 1;
    total = json['total'] ?? 0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['page'] = page;
    data['last_page'] = lastPage;
    data['total'] = total;
    return data;
  }
}

/// صف جاهز للعرض من attributes_display، مثل: المقاسات ← S، M، L
class AttributeRow {
  String key = '';
  String label = '';
  String type = '';
  dynamic value;
  String display = '';

  AttributeRow({
    this.key = '',
    this.label = '',
    this.type = '',
    this.value,
    this.display = '',
  });

  AttributeRow.fromJson(Map<String, dynamic> json) {
    key = json['key'] ?? '';
    label = json['label'] ?? '';
    type = json['type'] ?? '';
    value = json['value'];
    display = json['display'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['key'] = key;
    data['label'] = label;
    data['type'] = type;
    data['value'] = value;
    data['display'] = display;
    return data;
  }
}

class Product {
  int id = 0;
  String name = '';
  String? description;
  double price = 0;
  double? salePrice;
  double finalPrice = 0;
  int? discountPercent;
  int stock = 0;
  String? image;
  String? thumb;
  List<String> images = [];
  Map<String, dynamic> attributes = {};
  List<AttributeRow> attributesDisplay = [];
  int? categoryId;
  String? categoryName;
  double ratingAverage = 0;
  int ratingCount = 0;
  bool isFavorite = false;
  bool isFeatured = false;

  Product({
    this.id = 0,
    this.name = '',
    this.description,
    this.price = 0,
    this.salePrice,
    this.finalPrice = 0,
    this.discountPercent,
    this.stock = 0,
    this.image,
    this.thumb,
    this.images = const [],
    this.attributes = const {},
    this.attributesDisplay = const [],
    this.categoryId,
    this.categoryName,
    this.ratingAverage = 0,
    this.ratingCount = 0,
    this.isFavorite = false,
    this.isFeatured = false,
  });

  bool get inStock => stock >0 ;
  bool get hasDiscount => finalPrice < price;

  /// المقاسات المتاحة للاختيار (ملابس).
  List<String> get sizes => List<String>.from(attributes['sizes'] ?? const []);

  /// الألوان المتاحة بصيغة #RRGGBB.
  List<String> get colors =>
      List<String>.from(attributes['colors'] ?? const []);

  Product.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'] ?? '';
    description = json['description'];
    price = (json['price'] as num? ?? 0).toDouble();
    salePrice = (json['sale_price'] as num?)?.toDouble();
    finalPrice = (json['final_price'] as num? ?? 0).toDouble();
    discountPercent = json['discount_percent'];
    stock = json['stock'] ?? 0;
    image = json['image'];
    thumb = json['thumb'];
    if (json['images'] != null) {
      images = <String>[];
      json['images'].forEach((v) {
        images.add(v['url']);
      });
    }
    if (json['attributes'] is Map) {
      attributes = Map<String, dynamic>.from(json['attributes']);
    }
    if (json['attributes_display'] != null) {
      attributesDisplay = <AttributeRow>[];
      json['attributes_display'].forEach((v) {
        attributesDisplay.add(AttributeRow.fromJson(v));
      });
    }
    categoryId = json['category_id'];
    if (json['category'] is Map) {
      categoryName = json['category']['name'];
    }
    if (json['rating'] != null) {
      ratingAverage = (json['rating']['average'] as num? ?? 0).toDouble();
      ratingCount = json['rating']['count'] ?? 0;
    }
    isFavorite = json['is_favorite'] ?? false;
    isFeatured = json['is_featured'] ?? false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['description'] = description;
    data['price'] = price;
    data['sale_price'] = salePrice;
    data['final_price'] = finalPrice;
    data['discount_percent'] = discountPercent;
    data['stock'] = stock;
    data['image'] = image;
    data['thumb'] = thumb;
    data['images'] = images.map((v) => {'url': v}).toList();
    data['attributes'] = attributes;
    data['attributes_display'] = attributesDisplay
        .map((v) => v.toJson())
        .toList();
    data['category_id'] = categoryId;
    data['category'] = categoryName != null ? {'name': categoryName} : null;
    data['rating'] = {'average': ratingAverage, 'count': ratingCount};
    data['is_favorite'] = isFavorite;
    data['is_featured'] = isFeatured;
    return data;
  }
}
