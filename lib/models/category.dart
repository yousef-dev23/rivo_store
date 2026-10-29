class Category {
  int id = 0;
  String name = '';
  String? icon;
  String? image;
  int productsCount = 0;

  Category({
    this.id = 0,
    this.name = '',
    this.icon,
    this.image,
    this.productsCount = 0,
  });

  Category.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'] ?? '';
    icon = json['icon'];
    image = json['image'];
    productsCount = json['products_count'] ?? 0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['icon'] = icon;
    data['image'] = image;
    data['products_count'] = productsCount;
    return data;
  }
}
