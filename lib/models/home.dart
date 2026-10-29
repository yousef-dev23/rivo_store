import 'package:rivo_store/models/banner_item.dart';
import 'package:rivo_store/models/category.dart';
import 'package:rivo_store/models/product.dart';

class HomeResponse {
  bool? success;
  String? message;
  List<BannerItem>? banners;
  List<Category>? categories;
  List<Product>? featured;
  List<Product>? newest;
  List<Product>? bestSellers;

  HomeResponse({
    this.success,
    this.message,
    this.banners,
    this.categories,
    this.featured,
    this.newest,
    this.bestSellers,
  });

  HomeResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    final data = json['data'];
    if (data == null) return;
    if (data['banners'] != null) {
      banners = <BannerItem>[];
      data['banners'].forEach((v) {
        banners!.add(BannerItem.fromJson(v));
      });
    }
    if (data['categories'] != null) {
      categories = <Category>[];
      data['categories'].forEach((v) {
        categories!.add(Category.fromJson(v));
      });
    }
    if (data['featured'] != null) {
      featured = <Product>[];
      data['featured'].forEach((v) {
        featured!.add(Product.fromJson(v));
      });
    }
    if (data['newest'] != null) {
      newest = <Product>[];
      data['newest'].forEach((v) {
        newest!.add(Product.fromJson(v));
      });
    }
    if (data['best_sellers'] != null) {
      bestSellers = <Product>[];
      data['best_sellers'].forEach((v) {
        bestSellers!.add(Product.fromJson(v));
      });
    }
  }
}
