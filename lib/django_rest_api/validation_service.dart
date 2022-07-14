import 'dart:convert';
import 'package:pos/db/user_model.dart';
import 'api_response.dart';
import 'package:http/http.dart' as http;
import '../components/mixins.dart';

class ValidationService {
  final VALIDATION_ENDPOINT = BASE_ENDPOINT + "auth/validation/";
  static const validation_header = {
    "Content-Type": "application/json",
  };

  Future<APIResponse<UserModel>> validatePosUser(Map<String, dynamic> mapList) {
    return http
        .post(VALIDATION_ENDPOINT, headers: validation_header, body: json.encode(mapList))
        .then((data) {
      if (data.statusCode == 200) {
        final jsonData = json.decode(data.body);
        return APIResponse<UserModel>(data: UserModel.fromJson(jsonData), error: false);
      } else if (data.statusCode == 401) {
        final jsonData = json.decode(data.body);
        return APIResponse<UserModel>(data: UserModel(name: jsonData['detail']), error: true);
      }
      return APIResponse<UserModel>(
          error: true, errorMessage: "Error occured in user authentication");
    }).catchError((_) => APIResponse<UserModel>(
            error: true, errorMessage: "Unknown Error occured in user authentication"));
  }
}
