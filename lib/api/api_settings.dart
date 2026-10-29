class ApiSettings {
  static const baseUrl = "https://souqna.toldpath.com/api/v1/";
  static const storeSlug = "rivo-store";
  static const storeUrl = "${baseUrl}stores/$storeSlug";

  /// أقصى انتظار لأي طلب: بعده يظهر «تعذر الاتصال بالخادم» بدل تحميل لا ينتهي.
  static const timeout = Duration(seconds: 20);

  static const store = storeUrl;
  static const home = "$storeUrl/home";
  static const products = "$storeUrl/products";
  static const categories = "$storeUrl/categories";
  static const login = "$storeUrl/auth/login";
  static const register = "$storeUrl/auth/register";
  static const logout = "$storeUrl/auth/logout";
  static const profile = "$storeUrl/auth/me";
  static const updateProfile = "$storeUrl/auth/profile";
  static const cart = "$storeUrl/cart";
  static const cartItems = "$storeUrl/cart/items";
  static const cartCoupon = "$storeUrl/cart/coupon";
  static const favorites = "$storeUrl/favorites";
  static const checkout = "$storeUrl/checkout";
  static const orders = "$storeUrl/orders";
}
