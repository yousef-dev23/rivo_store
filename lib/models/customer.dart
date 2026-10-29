class AuthResponse {
  bool? success;
  String? message;
  String? token;
  Customer? user;

  AuthResponse({this.success, this.message, this.token, this.user});

  AuthResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    if (json['data'] != null) {
      token = json['data']['token'];
      user = json['data']['user'] != null
          ? Customer.fromJson(json['data']['user'])
          : null;
    }
  }
}

class CustomerResponse {
  bool? success;
  String? message;
  Customer? data;

  CustomerResponse({this.success, this.message, this.data});

  CustomerResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? Customer.fromJson(json['data']) : null;
  }
}

class Customer {
  int id = 0;
  String name = '';
  String email = '';
  String? phone;
  String initials = '';

  Customer({
    this.id = 0,
    this.name = '',
    this.email = '',
    this.phone,
    this.initials = '',
  });

  Customer.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'] ?? '';
    email = json['email'] ?? '';
    phone = json['phone'];
    initials = json['initials'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['email'] = email;
    data['phone'] = phone;
    data['initials'] = initials;
    return data;
  }
}
