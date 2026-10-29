import 'package:flutter/material.dart';

import 'package:rivo_store/utils/helpers.dart';

class StoreInfoResponse {
  bool? success;
  String? message;
  StoreInfo? data;

  StoreInfoResponse({this.success, this.message, this.data});

  StoreInfoResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? StoreInfo.fromJson(json['data']) : null;
  }
}

class StoreInfo {
  int id = 0;
  String name = '';
  String slug = '';
  String? tagline;
  String? description;
  String? logo;
  String? cover;
  Color primaryColor = const Color(0xFFF59E0B);
  String? phone;
  String? whatsapp;
  String? address;
  double deliveryFee = 0;
  double minOrder = 0;
  String currencySymbol = '₪';

  StoreInfo({
    this.id = 0,
    this.name = '',
    this.slug = '',
    this.tagline,
    this.description,
    this.logo,
    this.cover,
    this.primaryColor = const Color(0xFFF59E0B),
    this.phone,
    this.whatsapp,
    this.address,
    this.deliveryFee = 0,
    this.minOrder = 0,
    this.currencySymbol = '₪',
  });

  StoreInfo.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'] ?? '';
    slug = json['slug'] ?? '';
    tagline = json['tagline'];
    description = json['description'];
    logo = json['logo'];
    cover = json['cover'];
    if (json['theme'] != null) {
      primaryColor = Fmt.hex(json['theme']['primary_color']);
    }
    if (json['contact'] != null) {
      phone = json['contact']['phone'];
      whatsapp = json['contact']['whatsapp'];
      address = json['contact']['address'];
    }
    if (json['delivery'] != null) {
      deliveryFee = (json['delivery']['fee'] as num? ?? 0).toDouble();
      minOrder = (json['delivery']['min_order'] as num? ?? 0).toDouble();
    }
    currencySymbol = json['currency_symbol'] ?? '₪';
  }
}
