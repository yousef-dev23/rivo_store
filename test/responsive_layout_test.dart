// اختبار التخطيط المتجاوب: يشغّل الشاشات الحقيقية على بيانات test/fixtures
// بعروض وارتفاعات مختلفة وبخط مكبّر، ويفشل عند أي خطأ تخطيط (RenderFlex overflow وغيره).
//
// لحفظ لقطات PNG للمراجعة البصرية:
//   SHOTS_DIR=/tmp/shots flutter test test/responsive_layout_test.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:rivo_store/getx_controller/app_getx_controller.dart';
import 'package:rivo_store/main.dart';
import 'package:rivo_store/models/order.dart';
import 'package:rivo_store/screen/auth/create_new_account_screen.dart';
import 'package:rivo_store/screen/auth/login_screen.dart';
import 'package:rivo_store/screen/bottom_nav_bar/main_screen.dart';
import 'package:rivo_store/screen/home/product_details_screen.dart';
import 'package:rivo_store/screen/home/product_screen.dart';
import 'package:rivo_store/screen/home/reviews_screen.dart';
import 'package:rivo_store/screen/home/store_details_screen.dart';
import 'package:rivo_store/screen/lunch/lunch_screen.dart';
import 'package:rivo_store/screen/setting/more/edit_profile_screen.dart';
import 'package:rivo_store/screen/setting/order_details_screen.dart';
import 'package:rivo_store/screen/setting/order_screen.dart';
import 'package:rivo_store/screen/setting/order_success_screen.dart';
import 'package:rivo_store/screen/setting/payment_screen.dart';

Map<String, dynamic> fixture(String name) =>
    jsonDecode(File('test/fixtures/$name.json').readAsStringSync())
        as Map<String, dynamic>;

/// عروض منطقية تمثيلية + ارتفاعات مختلفة + وضع أفقي.
const sizes = <String, Size>{
  '320x568': Size(320, 568),
  '360x640': Size(360, 640),
  '390x844': Size(390, 844),
  '430x932': Size(430, 932),
  '600x960': Size(600, 960),
  '768x1024': Size(768, 1024),
  '1024x768': Size(1024, 768),
  '1440x900': Size(1440, 900),
  'land-568x320': Size(568, 320),
  'land-844x390': Size(844, 390),
};

/// الخط المكبّر + نصوص طويلة على مجموعة أصغر من المقاسات.
const stressSizes = [
  '320x568',
  '390x844',
  '768x1024',
  '1440x900',
  'land-844x390',
];

const longName =
    'فستان سهرة طويل من الساتان الفاخر بأكمام دانتيل وتطريز يدوي ناعم';
const longStore = 'متجر الأناقة للأزياء النسائية والرجالية وملابس الأطفال';

/// يطيل الأسماء في الردود لاختبار النصوص العربية الطويلة.
dynamic _stretch(dynamic v) {
  if (v is Map) {
    return v.map((k, e) {
      if (k == 'name' && e is String) {
        return MapEntry(k, e == 'متجر الاناقة' ? longStore : longName);
      }
      return MapEntry(k, _stretch(e));
    });
  }
  if (v is List) return v.map(_stretch).toList();
  return v;
}

Map<String, dynamic> cartWithItems() {
  final products = fixture('products')['data'] as List;
  final items = [
    for (var i = 0; i < 3; i++)
      {
        'id': 900 + i,
        'product_id': products[i]['id'],
        'name': products[i]['name'],
        'image': products[i]['image'],
        'unit_price': 159,
        'original_price': 189,
        'quantity': i + 1,
        'options': {'size': 'Free Size', 'color': '#8B4513'},
        'line_total': 159 * (i + 1),
        'stock': 5,
        'is_available': i != 2,
      },
  ];
  return {
    'success': true,
    'message': 'تم بنجاح',
    'data': {
      'items': items,
      'items_count': 6,
      'subtotal': 954,
      'discount': 0,
      'delivery_fee': 4,
      'total': 958,
      'coupon_code': null,
      'coupon_error': null,
      'min_order': 20,
      'meets_min_order': true,
    },
  };
}

MockClient mockApi({required bool longText}) {
  return MockClient((request) async {
    final path = request.url.path;
    Map<String, dynamic> body;
    if (path.endsWith('/home')) {
      body = fixture('home');
    } else if (path.endsWith('/stores/karam')) {
      body = fixture('store');
    } else if (path.endsWith('/reviews')) {
      body = fixture('reviews');
    } else if (RegExp(r'/products/\d+$').hasMatch(path)) {
      body = fixture('product');
    } else if (path.endsWith('/products') || path.endsWith('/favorites')) {
      body = fixture('products');
    } else if (path.endsWith('/cart')) {
      body = cartWithItems();
    } else if (RegExp(r'/orders/\d+$').hasMatch(path)) {
      body = fixture('order');
    } else if (path.endsWith('/orders')) {
      body = fixture('orders');
    } else if (path.endsWith('/auth/me')) {
      body = {'success': true, 'data': _customer};
    } else {
      // الصور وغيرها: لا شبكة في الاختبار، فتظهر الصورة البديلة.
      return http.Response('', 404);
    }
    final json = longText ? _stretch(body) : body;
    return http.Response.bytes(
      utf8.encode(jsonEncode(json)),
      200,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );
  });
}

const _customer = {
  'id': 1,
  'name': 'سلمى الأحمد',
  'email': 'salma.ahmad.long.address@example.com',
  'phone': '0597300100',
  'initials': 'سا',
};

class Case {
  const Case(
    this.name,
    this.build, {
    this.tab,
    this.loggedIn = true,
    this.mustSee,
  });

  final String name;
  final Widget Function() build;
  final int? tab;
  final bool loggedIn;

  /// نص يجب أن يكون ظاهرًا وقابلًا للمس (غير مغطّى بشريط أو ورقة سفلية).
  final String Function(bool longText)? mustSee;
}

String _firstProductName(bool long) =>
    long ? longName : (fixture('products')['data'] as List)[0]['name'];

final cases = <Case>[
  Case('splash', () => const LunchScreen()),
  Case('home', () => const MainScreen(), tab: 0),
  Case('categories', () => const MainScreen(), tab: 1),
  Case('cart', () => const MainScreen(), tab: 2, mustSee: _firstProductName),
  Case('favorites', () => const MainScreen(), tab: 3),
  Case('account', () => const MainScreen(), tab: 4),
  Case('account-guest', () => const MainScreen(), tab: 4, loggedIn: false),
  Case('cart-guest', () => const MainScreen(), tab: 2, loggedIn: false),
  Case('products', () => const ProductScreen(title: 'فساتين', categoryId: 23)),
  Case('search', () => const ProductScreen(title: 'البحث', search: true)),
  Case(
    'product-details',
    () => const ProductDetailsScreen(id: 75),
    mustSee: (long) => long ? longName : 'حقيبة كتف جلدية',
  ),
  Case('reviews', () => const ReviewsScreen(productId: 75)),
  Case('store', () => const StoreDetailsScreen()),
  Case('login', () => const LoginScreen(), loggedIn: false),
  Case('register', () => const CreateNewAccountScreen(), loggedIn: false),
  Case('edit-profile', () => const EditProfileScreen()),
  Case(
    'checkout',
    () => const PaymentScreen(),
    mustSee: (_) => 'بيانات التوصيل',
  ),
  Case('orders', () => const OrderScreen()),
  Case('order-details', () => const OrderDetailsScreen(id: 163)),
  Case(
    'order-success',
    () => OrderSuccessScreen(
      order: Order.fromJson(fixture('order')['data'] as Map<String, dynamic>),
    ),
  ),
];

Future<void> loadFonts() async {
  Future<void> load(String family, List<String> files) async {
    final loader = FontLoader(family);
    for (final f in files) {
      final bytes = File(f).readAsBytesSync();
      loader.addFont(Future.value(ByteData.sublistView(bytes)));
    }
    await loader.load();
  }

  await load('Plex', [
    for (final w in ['Regular', 'Medium', 'SemiBold', 'Bold'])
      'assets/fonts/IBMPlexSansArabic-$w.ttf',
  ]);
  final root = Platform.environment['FLUTTER_ROOT'];
  if (root != null) {
    await load('MaterialIcons', [
      '$root/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
    ]);
  }
}

final _shotKey = GlobalKey();

Future<void> runCase(
  WidgetTester tester,
  Case c,
  String sizeName, {
  double textScale = 1,
  bool longText = false,
}) async {
  final size = sizes[sizeName]!;
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

  Get.reset();
  final box = GetStorage();
  await box.erase();
  if (c.loggedIn) {
    await box.write('token', 'test-token');
    await box.write('user', _customer);
  }

  final problems = <String>[];
  final original = FlutterError.onError;
  FlutterError.onError = (details) {
    final text = details.exceptionAsString();
    // فشل تحميل الصور متوقع (لا شبكة)، ويظهر بدله الـ placeholder.
    if (text.contains('HTTP request failed') ||
        text.contains('Invalid image data') ||
        text.contains('NetworkImageLoadException') ||
        // كاش الصور يستخدم sqflite، وإضافاته غير مسجلة في بيئة flutter test.
        text.contains('databaseFactory not initialized')) {
      return;
    }
    problems.add(text.split('\n').take(3).join(' | '));
  };

  try {
    await http.runWithClient(() async {
      InitialBinding().dependencies();
      await Get.find<AppGetxController>().fetchStore();
      await tester.pumpWidget(
        RepaintBoundary(
          key: _shotKey,
          child: RivoApp(home: c.build()),
        ),
      );
      for (var i = 0; i < 4; i++) {
        await tester.pump(const Duration(milliseconds: 200));
      }
      if (c.tab != null) {
        MainScreenController.to.go(c.tab!);
        for (var i = 0; i < 4; i++) {
          await tester.pump(const Duration(milliseconds: 200));
        }
      }

      if (c.mustSee != null) {
        final text = c.mustSee!(longText);
        if (find.text(text).hitTestable().evaluate().isEmpty) {
          problems.add('"$text" is covered or not visible');
        }
      }

      final dir = Platform.environment['SHOTS_DIR'];
      if (dir != null) {
        final suffix = longText ? '-x${textScale}long' : '';
        final boundary = tester.renderObject<RenderRepaintBoundary>(
          find.byKey(_shotKey),
        );
        await tester.runAsync(() async {
          final image = await boundary.toImage();
          final png = await image.toByteData(format: ui.ImageByteFormat.png);
          File('$dir/${c.name}-$sizeName$suffix.png')
            ..createSync(recursive: true)
            ..writeAsBytesSync(png!.buffer.asUint8List());
        });
      }

      // ننتظر أي تنقل مؤجل (شاشة البداية تنتقل للرئيسية بعد 1.4 ثانية)،
      // ثم نفكك الشجرة لإيقاف المؤقتات (سلايدر البانر، السكيليتون).
      await tester.pump(const Duration(seconds: 2));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 2));
    }, () => mockApi(longText: longText));
  } finally {
    FlutterError.onError = original;
    Get.reset();
  }

  expect(problems, isEmpty, reason: '${c.name} @ $sizeName x$textScale');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    final dir = Directory.systemTemp.createTempSync('anaqa_test');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (_) async => dir.path,
        );
    // كاش الصور يستخدم sqflite وإضافاته غير مسجلة في flutter test: نُفشل فتح
    // قاعدته مرة هنا بصمت، فتصل أخطاء الصور لاحقًا عبر FlutterError فقط (وتُتجاهل).
    final warmUp = Completer<void>();
    runZonedGuarded(
      () async {
        try {
          await CachedNetworkImageProvider.defaultCacheManager.getFileFromCache(
            'warm-up',
          );
        } catch (_) {}
        warmUp.complete();
      },
      (_, _) {
        if (!warmUp.isCompleted) warmUp.complete();
      },
    );
    await warmUp.future;
    await GetStorage.init();
    await initializeDateFormatting('ar');
    await loadFonts();
  });

  for (final c in cases) {
    group(c.name, () {
      for (final s in sizes.keys) {
        testWidgets(
          s,
          (tester) => runCase(tester, c, s),
          timeout: const Timeout(Duration(seconds: 60)),
        );
      }
      for (final s in stressSizes) {
        testWidgets(
          '$s large text + long names',
          (tester) => runCase(tester, c, s, textScale: 1.6, longText: true),
          timeout: const Timeout(Duration(seconds: 60)),
        );
      }
    });
  }
}
