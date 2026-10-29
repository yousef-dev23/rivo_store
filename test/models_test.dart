import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:rivo_store/utils/helpers.dart';
import 'package:rivo_store/models/banner_item.dart';
import 'package:rivo_store/models/cart.dart';
import 'package:rivo_store/models/category.dart';
import 'package:rivo_store/models/order.dart';
import 'package:rivo_store/models/product.dart';
import 'package:rivo_store/models/review.dart';
import 'package:rivo_store/models/store_info.dart';

/// الملفات في test/fixtures ردود حقيقية من https://souqna.toldpath.com لمتجر «karam».
Map<String, dynamic> fixture(String name) =>
    jsonDecode(File('test/fixtures/$name.json').readAsStringSync())
        as Map<String, dynamic>;

void main() {
  test('store info parses theme, contact and delivery', () {
    final body = fixture('store');
    expect(body['success'], isTrue);
    final store = StoreInfo.fromJson(body['data']);
    expect(store.slug, 'karam');
    expect(store.name, isNotEmpty);
    expect(store.logo, startsWith('https://'));
    expect(store.currencySymbol, '₪');
  });

  test('home parses banners, categories and product lists', () {
    final data = fixture('home')['data'] as Map<String, dynamic>;
    final banners = (data['banners'] as List)
        .map((e) => BannerItem.fromJson(e))
        .toList();
    final categories = (data['categories'] as List)
        .map((e) => Category.fromJson(e))
        .toList();
    final featured = (data['featured'] as List)
        .map((e) => Product.fromJson(e))
        .toList();
    expect(banners, isNotEmpty);
    expect(
      banners.every(
        (b) => ['product', 'category', 'none'].contains(b.linkType),
      ),
      isTrue,
    );
    expect(categories, isNotEmpty);
    expect(featured, isNotEmpty);
    expect(featured.first.images, isNotEmpty);
  });

  test(
    'product details parse attributes, sizes, colors and reviews summary',
    () {
      final data = fixture('product')['data'] as Map<String, dynamic>;
      final product = Product.fromJson(data['product']);
      expect(product.sizes, isNotEmpty);
      expect(product.colors.every((c) => c.startsWith('#')), isTrue);
      expect(product.attributesDisplay.map((a) => a.key), contains('sizes'));
      expect(product.finalPrice <= product.price, isTrue);
      final related = (data['related'] as List)
          .map((e) => Product.fromJson(e))
          .toList();
      expect(related.every((p) => p.id != product.id), isTrue);
      final reviews = ReviewsSummary.fromJson(data['reviews_summary']);
      expect(reviews.distribution.keys, containsAll([1, 2, 3, 4, 5]));
    },
  );

  test(
    'products list carries pagination meta and is sorted by effective price',
    () {
      final body = fixture('products');
      final list = (body['data'] as List)
          .map((e) => Product.fromJson(e))
          .toList();
      expect(body['meta']['per_page'], 4);
      for (var i = 1; i < list.length; i++) {
        expect(list[i].finalPrice >= list[i - 1].finalPrice, isTrue);
      }
    },
  );

  test('order details parse items, options and a 5-step timeline', () {
    final order = Order.fromJson(fixture('order')['data']);
    expect(order.number, startsWith('SQ-'));
    expect(order.items, isNotEmpty);
    expect(order.timeline.first.status, 'pending');
    expect(order.timeline.first.done, isTrue);
    expect(
      order.total,
      closeTo(order.subtotal - order.discount + order.deliveryFee, 0.01),
    );
  });

  test('cart summary parses the empty cart and a cart with items', () {
    final empty = CartSummary.fromJson(fixture('cart')['data']);
    expect(empty.isEmpty, isTrue);

    final full = CartSummary.fromJson({
      'items': [
        {
          'id': 7,
          'product_id': 2,
          'name': 'فستان',
          'image': null,
          'unit_price': 159.0,
          'original_price': 159.0,
          'quantity': 2,
          'options': {'size': 'M'},
          'line_total': 318.0,
          'stock': 20,
          'is_available': true,
        },
      ],
      'items_count': 2,
      'subtotal': 318.0,
      'discount': 31.8,
      'delivery_fee': 4.0,
      'total': 290.2,
      'coupon_code': 'WELCOME10',
      'coupon_error': null,
      'min_order': 0.0,
      'meets_min_order': true,
      'currency': 'ILS',
    });
    expect(full.items.single.options['size'], 'M');
    expect(full.total, 290.2);
  });

  test('error envelope keeps the Arabic message and code', () {
    final body = fixture('not_found');
    expect(body['success'], isFalse);
    expect(body['error']['code'], 'NOT_FOUND');
    expect(body['message'], isNotEmpty);
  });

  test('money and colors format correctly', () {
    expect(Fmt.money(1250), '1,250 ₪');
    expect(Fmt.money(99.5), '99.50 ₪');
    expect(Fmt.hex('#E11D48').toARGB32(), 0xFFE11D48);
  });
}
