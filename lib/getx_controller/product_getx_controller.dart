import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:rivo_store/api/api_settings.dart';
import 'package:rivo_store/models/product.dart';
import 'package:rivo_store/preferences/user_getstorage.dart';

/// قائمة منتجات مع بحث وفلترة وترتيب وتحميل لا نهائي.
class ProductGetxController extends GetxController {
  ProductGetxController({
    this.categoryId,
    this.query = '',
    this.featuredOnly = false,
  });

  final int? categoryId;
  final bool featuredOnly;
  String query;

  var isLoading = true.obs;
  var isLoadingMore = false.obs;
  var productsList = <Product>[].obs;
  final RxString errorMessage = ''.obs;

  // الفلاتر
  var sort = 'newest'.obs; // newest | price | best_selling | rating
  var order = 'desc'.obs;
  var inStockOnly = false.obs;
  var minPrice = RxnDouble();
  var maxPrice = RxnDouble();

  int _page = 1;
  bool _hasMore = true;
  int _request = 0;

  @override
  void onInit() {
    fetchProducts();
    super.onInit();
  }

  int get activeFilters =>
      (inStockOnly.value ? 1 : 0) +
      (minPrice.value != null || maxPrice.value != null ? 1 : 0);

  Future<void> fetchProducts({bool more = false}) async {
    if (more && (!_hasMore || isLoadingMore.value || isLoading.value)) return;
    final request = ++_request;
    if (more) {
      isLoadingMore.value = true;
    } else {
      isLoading.value = true;
      errorMessage.value = '';
      _page = 1;
    }

    final params = <String, String>{
      'page': '${more ? _page + 1 : 1}',
      'per_page': '16',
      'sort': sort.value,
      'order': order.value,
      if (query.isNotEmpty) 'q': query,
      if (categoryId != null) 'category_id': '$categoryId',
      if (featuredOnly) 'featured': '1',
      if (inStockOnly.value) 'in_stock': '1',
      if (minPrice.value != null) 'min_price': '${minPrice.value}',
      if (maxPrice.value != null) 'max_price': '${maxPrice.value}',
    };
    final url = Uri.parse(
      ApiSettings.products,
    ).replace(queryParameters: params);
    final token = UserGetStorage().getToken();

    try {
      final response = await http
          .get(
            url,
            headers: {
              'Accept': 'application/json',
              'Accept-Language': 'ar',
              if (token.isNotEmpty) 'Authorization': 'Bearer $token',
            },
          )
          .timeout(ApiSettings.timeout);

      if (request != _request) return; // وصل رد أحدث

      final body = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200 && body['success'] == true) {
        final productsData = ProductsResponse.fromJson(body);
        final list = productsData.data ?? [];
        if (more) {
          productsList.addAll(list);
        } else {
          productsList.value = list;
        }
        _page = productsData.meta?.page ?? 1;
        _hasMore = productsData.meta?.hasMore ?? false;
      } else if (!more) {
        errorMessage.value = body['message'] ?? 'فشل في جلب المنتجات';
      }
    } catch (e) {
      if (!more) errorMessage.value = 'تعذر الاتصال بالخادم، تحقق من الإنترنت';
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  void search(String value) {
    query = value;
    fetchProducts();
  }

  void setSort(String value, String direction) {
    sort.value = value;
    order.value = direction;
    fetchProducts();
  }
}
