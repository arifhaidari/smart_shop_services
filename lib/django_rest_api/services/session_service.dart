import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pos/db/session_model.dart';
import '../../components/mixins.dart';
import '../api_response.dart';

class SessionModelService {
  Future<APIResponse<List<SessionModel>>> getAPISessionModelList(String token) {
    final MAIN_ENDPOINT = BASE_ENDPOINT + "session/";
    final headers = {
      // "Content-Type": "application/json",
      "Authorization": "JWT " + token
    };
    var client = http.Client();
    try {
      return client.get(MAIN_ENDPOINT, headers: headers).then((data) {
        if (data.statusCode == 200) {
          final jsonData = json.decode(utf8.decode(data.bodyBytes));
          final variants = <SessionModel>[];
          for (var item in jsonData) {
            variants.add(SessionModel.fromJson(item));
          }

          return APIResponse<List<SessionModel>>(data: variants);
        }
        return APIResponse<List<SessionModel>>(
            error: true, errorMessage: "Error Occured in SessionModel");
      }).catchError((_) => APIResponse<List<SessionModel>>(
          error: true, errorMessage: "Unknow error Occured in SessionModel"));
    } finally {
      client.close();
    }
  }

  Future<APIResponse<bool>> createAPISessionModel(
      Map<String, dynamic> sessionObject, String token) {
    final MAIN_ENDPOINT = BASE_ENDPOINT + "session/";
    final headers = {"Content-Type": "application/json", "Authorization": "JWT " + token};
    var client = http.Client();
    try {
      return client
          .post(MAIN_ENDPOINT, headers: headers, body: json.encode(sessionObject))
          .then((data) {
        if (data.statusCode == 201) {
          return APIResponse<bool>(data: true);
        } else if (data.statusCode == 400) {
          return APIResponse<bool>(data: false);
        }
        return APIResponse<bool>(error: true, errorMessage: "Error Occured in SessionModel");
      }).catchError((_) =>
              APIResponse<bool>(error: true, errorMessage: "Unknow error Occured in SessionModel"));
    } finally {
      client.close();
    }
  }

  Future<APIResponse<bool>> updateAPISession(Map<String, dynamic> object, int pk, String token) {
    final MAIN_ENDPOINT = BASE_ENDPOINT + "session/$pk/";
    final headers = {"Content-Type": "application/json", "Authorization": "JWT " + token};
    var client = http.Client();
    try {
      return client.put(MAIN_ENDPOINT, headers: headers, body: json.encode(object)).then((data) {
        if (data.statusCode == 204 || data.statusCode == 200 || data.statusCode == 404) {
          return APIResponse<bool>(data: true);
        } else if (data.statusCode == 400) {
          return APIResponse<bool>(data: false);
        }
        return APIResponse<bool>(error: true, errorMessage: "Error Occured in Session");
      }).catchError(
          (_) => APIResponse<bool>(error: true, errorMessage: "Unknow error Occured in Session"));
    } finally {
      client.close();
    }
  }

  Future<APIResponse<bool>> deleteAPISession(int pk, String token) {
    final MAIN_ENDPOINT = BASE_ENDPOINT + "session/$pk/";
    final headers = {"Content-Type": "application/json", "Authorization": "JWT " + token};
    return http.delete(MAIN_ENDPOINT, headers: headers).then((data) {
      if (data.statusCode == 204 || data.statusCode == 404) {
        return APIResponse<bool>(data: true, error: false);
      }
      return APIResponse<bool>(error: true, errorMessage: "Error Occured due to request");
    }).catchError(
        (_) => APIResponse<bool>(error: true, errorMessage: "Error Occured due to catch"));
  }
}
