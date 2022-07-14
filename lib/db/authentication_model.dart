// import 'package:meta/meta.dart';

class UserAuthentication {
  String status;
  String token;

  UserAuthentication({
    this.status,
    this.token,
  });

// toMap() function is same to toJson() function
  Map<String, dynamic> toMap() {
    return {'status': status, 'token': token};
  }

  UserAuthentication.fromDb(Map map)
      : status = map["status"],
        token = map["token"];

  factory UserAuthentication.fromJson(Map<String, dynamic> item) {
    return UserAuthentication(
      status: item['status'],
      token: item['token'],
    );
  }
}
