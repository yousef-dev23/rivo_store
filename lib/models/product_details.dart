import 'package:rivo_store/models/product.dart';
import 'package:rivo_store/models/review.dart';

class ProductDetailsResponse {
  bool? success;
  String? message;
  Product? product;
  List<Product>? related;
  ReviewsSummary? reviewsSummary;

  ProductDetailsResponse({
    this.success,
    this.message,
    this.product,
    this.related,
    this.reviewsSummary,
  });

  ProductDetailsResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    final data = json['data'];
    if (data == null) return;
    product = data['product'] != null
        ? Product.fromJson(data['product'])
        : null;
    if (data['related'] != null) {
      related = <Product>[];
      data['related'].forEach((v) {
        related!.add(Product.fromJson(v));
      });
    }
    reviewsSummary = data['reviews_summary'] != null
        ? ReviewsSummary.fromJson(data['reviews_summary'])
        : null;
  }
}
