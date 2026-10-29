import 'package:rivo_store/models/product.dart';

class Review {
  int id = 0;
  int rating = 0;
  String? comment;
  String customerName = 'عميل';
  String initials = '';
  String createdAt = '';

  Review({
    this.id = 0,
    this.rating = 0,
    this.comment,
    this.customerName = 'عميل',
    this.initials = '',
    this.createdAt = '',
  });

  Review.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    rating = json['rating'] ?? 0;
    comment = json['comment'];
    if (json['customer'] != null) {
      customerName = json['customer']['name'] ?? 'عميل';
      initials = json['customer']['initials'] ?? '';
    }
    createdAt = json['created_at'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['rating'] = rating;
    data['comment'] = comment;
    data['customer'] = {'name': customerName, 'initials': initials};
    data['created_at'] = createdAt;
    return data;
  }
}

class ReviewsSummary {
  double average = 0;
  int count = 0;
  Map<int, int> distribution = {};
  List<Review> latest = [];

  ReviewsSummary({
    this.average = 0,
    this.count = 0,
    this.distribution = const {},
    this.latest = const [],
  });

  ReviewsSummary.fromJson(Map<String, dynamic> json) {
    average = (json['average'] as num? ?? 0).toDouble();
    count = json['count'] ?? 0;
    if (json['distribution'] is Map) {
      distribution = <int, int>{};
      json['distribution'].forEach((k, v) {
        distribution[int.parse(k.toString())] = v;
      });
    }
    if (json['latest'] != null) {
      latest = <Review>[];
      json['latest'].forEach((v) {
        latest.add(Review.fromJson(v));
      });
    }
  }
}

/// صفحة من «كل التقييمات» مع الترقيم.
class ReviewsResponse {
  bool? success;
  String? message;
  List<Review>? data;
  Meta? meta;

  ReviewsResponse({this.success, this.message, this.data, this.meta});

  ReviewsResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    if (json['data'] != null) {
      data = <Review>[];
      json['data'].forEach((v) {
        data!.add(Review.fromJson(v));
      });
    }
    meta = json['meta'] != null ? Meta.fromJson(json['meta']) : null;
  }
}
