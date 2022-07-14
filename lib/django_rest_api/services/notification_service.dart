import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pos/db/notification_model.dart';
import '../../components/mixins.dart';
import '../api_response.dart';

class NotificationModelService {
  Future<APIResponse<List<NotificationModel>>> getAPINotificationModelList(String token) {
    final MAIN_ENDPOINT = BASE_ENDPOINT + "notification/";
    final headers = {
      // "Content-Type": "application/json",
      "Authorization": "JWT " + token
    };
    var client = http.Client();
    try {
      return client.get(MAIN_ENDPOINT, headers: headers).then((data) {
        if (data.statusCode == 200) {
          final jsonData = json.decode(utf8.decode(data.bodyBytes));
          final variants = <NotificationModel>[];
          for (var item in jsonData) {
            variants.add(NotificationModel.fromJson(item));
          }

          return APIResponse<List<NotificationModel>>(data: variants);
        }
        return APIResponse<List<NotificationModel>>(
            error: true, errorMessage: "Error Occured in NotificationModel");
      }).catchError((_) => APIResponse<List<NotificationModel>>(
          error: true, errorMessage: "Unknow error Occured in NotificationModel"));
    } finally {
      client.close();
    }
  }

  Future<APIResponse<bool>> createAPINotificationModel(
      Map<String, dynamic> categoryObject, String token) {
    final MAIN_ENDPOINT = BASE_ENDPOINT + "notification/";
    final headers = {"Content-Type": "application/json", "Authorization": "JWT " + token};
    var client = http.Client();
    try {
      return client
          .post(MAIN_ENDPOINT, headers: headers, body: json.encode(categoryObject))
          .then((data) {
        if (data.statusCode == 201) {
          return APIResponse<bool>(data: true);
        } else if (data.statusCode == 400) {
          return APIResponse<bool>(data: false);
        }
        return APIResponse<bool>(error: true, errorMessage: "Error Occured in NotificationModel");
      }).catchError((_) => APIResponse<bool>(
              error: true, errorMessage: "Unknow error Occured in NotificationModel"));
    } finally {
      client.close();
    }
  }

  Future<APIResponse<bool>> updateAPINote(
      Map<String, dynamic> noteObject, int notePk, String token) {
    final MAIN_ENDPOINT = BASE_ENDPOINT + "notification/$notePk/";
    final headers = {"Content-Type": "application/json", "Authorization": "JWT " + token};
    var client = http.Client();
    try {
      return client
          .put(MAIN_ENDPOINT, headers: headers, body: json.encode(noteObject))
          .then((data) {
        if (data.statusCode == 204 || data.statusCode == 200 || data.statusCode == 404) {
          return APIResponse<bool>(data: true);
        } else if (data.statusCode == 400) {
          return APIResponse<bool>(data: false);
        }
        return APIResponse<bool>(error: true, errorMessage: "Error Occured in Notification");
      }).catchError((_) =>
              APIResponse<bool>(error: true, errorMessage: "Unknow error Occured in Notification"));
    } finally {
      client.close();
    }
  }

  Future<APIResponse<bool>> deleteAPINote(int notePk, String token) {
    final MAIN_ENDPOINT = BASE_ENDPOINT + "notification/$notePk/";
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
