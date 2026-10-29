import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:rivo_store/api/api_settings.dart';
import 'package:rivo_store/getx_controller/reviews_getx_controller.dart';
import 'package:rivo_store/models/review.dart';
import 'package:rivo_store/screen/home/reviews_screen.dart';
import 'package:rivo_store/utils/responsive.dart';
import 'package:rivo_store/widget/review_card.dart';

/// test/fixtures/reviews.json: رد حقيقي من https://souqna.toldpath.com (المنتج 75، صفحة 1 من 2).
Map<String, dynamic> fixture(String name) =>
    jsonDecode(File('test/fixtures/$name.json').readAsStringSync())
        as Map<String, dynamic>;

/// صفحة تقييمات مصنوعة بنفس شكل رد الخادم.
String reviewsPage(int page, int lastPage, List<int> ids) => jsonEncode({
  'success': true,
  'message': 'تم بنجاح',
  'data': [
    for (final id in ids)
      {
        'id': id,
        'rating': 4,
        'comment': 'تعليق $id',
        'customer': {'name': 'عميلة $id', 'initials': 'ع'},
        'created_at': '2026-10-02T15:23:00+00:00',
      },
  ],
  'meta': {'page': page, 'per_page': 2, 'total': 3, 'last_page': lastPage},
});

http.Response json(String body) => http.Response.bytes(
  utf8.encode(body),
  200,
  headers: {'content-type': 'application/json; charset=utf-8'},
);

void main() {
  tearDown(Get.reset);

  test('reviews page parses the live response with pagination', () {
    final page = ReviewsResponse.fromJson(fixture('reviews'));
    expect(page.success, isTrue);
    expect(page.data, hasLength(2));
    expect(page.data!.first.customerName, isNotEmpty);
    expect(page.data!.first.rating, inInclusiveRange(1, 5));
    expect(page.meta!.total, 3);
    expect(page.meta!.hasMore, isTrue);
  });

  test('loads the next page on demand and stops at the last one', () async {
    final requested = <String>[];
    final client = MockClient((request) async {
      requested.add(request.url.query);
      return request.url.queryParameters['page'] == '1'
          ? json(reviewsPage(1, 2, [1, 2]))
          : json(reviewsPage(2, 2, [3]));
    });

    await http.runWithClient(() async {
      final c = ReviewsGetxController(productId: 75);
      await c.fetchReviews();
      expect(c.reviewsList.map((r) => r.id), [1, 2]);
      expect(c.total.value, 3);

      await c.fetchReviews(more: true);
      expect(c.reviewsList.map((r) => r.id), [1, 2, 3]);

      await c.fetchReviews(more: true); // no more pages: no request
    }, () => client);

    expect(requested, ['page=1&per_page=15', 'page=2&per_page=15']);
  });

  testWidgets('a request that never answers ends with the connection error', (
    tester,
  ) async {
    final client = MockClient((_) => Completer<http.Response>().future);

    await http.runWithClient(() async {
      final c = ReviewsGetxController(productId: 75);
      unawaited(c.fetchReviews());
      expect(c.isLoading.value, isTrue);

      // Without the timeout the request would still be loading here.
      await tester.pump(ApiSettings.timeout + const Duration(seconds: 1));
      await tester.pump();

      expect(c.isLoading.value, isFalse);
      expect(c.errorMessage.value, 'تعذر الاتصال بالخادم، تحقق من الإنترنت');
    }, () => client);
  });

  testWidgets('the screen shows every review with the total in the title', (
    tester,
  ) async {
    final client = MockClient(
      (request) async => request.url.queryParameters['page'] == '1'
          ? json(reviewsPage(1, 2, [1, 2]))
          : json(reviewsPage(2, 2, [3])),
    );

    await http.runWithClient(() async {
      // الشاشات تستخدم .sp فتحتاج ScreenUtilInit كما في main.dart.
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: Responsive.designSize,
          builder: (_, _) =>
              const GetMaterialApp(home: ReviewsScreen(productId: 75)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('كل التقييمات (3)'), findsOneWidget);
      expect(find.byType(ReviewCard), findsNWidgets(2));
      expect(find.text('تعليق 1'), findsOneWidget);
    }, () => client);
  });
}
