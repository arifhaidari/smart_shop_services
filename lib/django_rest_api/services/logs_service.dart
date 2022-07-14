import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pos/db/logs/all_logs.dart';
import '../../components/mixins.dart';
import '../api_response.dart';

class LogsModelService {
  Future<APIResponse<List<Logs>>> getAPILogsList(String token) {
    var client = http.Client();
    final MAIN_ENDPOINT = BASE_ENDPOINT + "log/";
    final headers = {
      // "Content-Type": "application/json",
      "Authorization": "JWT " + token
    };
    try {
      return client.get(MAIN_ENDPOINT, headers: headers).then((data) {
        if (data.statusCode == 200) {
          final jsonData = json.decode(utf8.decode(data.bodyBytes));
          final logs = <Logs>[];
          for (var item in jsonData) {
            logs.add(Logs.fromJson(item));
          }

          return APIResponse<List<Logs>>(data: logs);
        }
        return APIResponse<List<Logs>>(error: true, errorMessage: "Error Occured in Logs");
      }).catchError((_) =>
          APIResponse<List<Logs>>(error: true, errorMessage: "Unknow error Occured in Logs"));
    } finally {
      client.close();
    }
  }

  Future<APIResponse<bool>> createAPILogs(Map<String, dynamic> logsObject, String token) {
    final MAIN_ENDPOINT = BASE_ENDPOINT + "log/";
    final headers = {"Content-Type": "application/json", "Authorization": "JWT " + token};
    var client = http.Client();
    try {
      return client
          .post(MAIN_ENDPOINT, headers: headers, body: json.encode(logsObject))
          .then((data) {
        if (data.statusCode == 201) {
          return APIResponse<bool>(data: true);
        } else if (data.statusCode == 400) {
          return APIResponse<bool>(data: false);
        }
        return APIResponse<bool>(error: true, errorMessage: "Error Occured in  Logs");
      }).catchError(
              (_) => APIResponse<bool>(error: true, errorMessage: "Unknow error Occured in Logs"));
    } finally {
      client.close();
    }
  }

  Future<APIResponse<bool>> updateAPILogs(Map<String, dynamic> logObject, int logPk, String token) {
    final MAIN_ENDPOINT = BASE_ENDPOINT + "log/$logPk/";
    final headers = {"Content-Type": "application/json", "Authorization": "JWT " + token};
    var client = http.Client();
    try {
      return client.put(MAIN_ENDPOINT, headers: headers, body: json.encode(logObject)).then((data) {
        if (data.statusCode == 204 || data.statusCode == 200 || data.statusCode == 404) {
          return APIResponse<bool>(data: true);
        } else if (data.statusCode == 400) {
          return APIResponse<bool>(data: false);
        }
        return APIResponse<bool>(error: true, errorMessage: "Error Occured in Logs");
      }).catchError(
          (_) => APIResponse<bool>(error: true, errorMessage: "Unknow error Occured in Logs"));
    } finally {
      client.close();
    }
  }

  Future<APIResponse<bool>> deleteAPILogs(int logPk, String token) {
    final MAIN_ENDPOINT = BASE_ENDPOINT + "log/$logPk/";
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
