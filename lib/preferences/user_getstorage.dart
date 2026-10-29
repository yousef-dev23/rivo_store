import 'package:get_storage/get_storage.dart';
import 'package:rivo_store/models/customer.dart';

class UserGetStorage {
  static final UserGetStorage _instance = UserGetStorage._();
  final box = GetStorage();

  factory UserGetStorage() => _instance;
  UserGetStorage._();

  Future<void> initPreferences() async {
    await GetStorage.init();
  }

  Future<void> save(Customer user, {String? token}) async {
    await box.write('logged_in', true);
    if (token != null) await box.write('token', token);
    await box.write('user', user.toJson());
  }

  Customer? getUser() {
    final data = box.read('user');
    if (data != null) {
      return Customer.fromJson(Map<String, dynamic>.from(data));
    }
    return null;
  }

  bool get isLoggedIn => getToken().isNotEmpty;

  Future<void> logout() async {
    await box.remove('logged_in');
    await box.remove('token');
    await box.remove('user');
  }

  String getToken() => "${box.read("token") ?? ""}";

  String getEmail() => getUser()?.email ?? "";
  String getPhone() => getUser()?.phone ?? "";
  String getFullName() => getUser()?.name ?? "";
  int? getUserId() => getUser()?.id;

  List<String> getRecentSearches() =>
      List<String>.from(box.read('recent_searches') ?? const []);

  Future<void> saveRecentSearches(List<String> list) async {
    await box.write('recent_searches', list);
  }
}
