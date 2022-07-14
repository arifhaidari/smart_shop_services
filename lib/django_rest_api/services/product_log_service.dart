import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pos/db/logs/product_log.dart';
import '../../components/mixins.dart';
import '../api_response.dart';

class ProductLogModelService {
  Future<APIResponse<List<ProductLog>>> getAPIProductLogList(String token) {
    var client = http.Client();
    final MAIN_ENDPOINT = BASE_ENDPOINT + "product_log/";
    final headers = {"Authorization": "JWT " + token};
    try {
      return client.get(MAIN_ENDPOINT, headers: headers).then((data) {
        if (data.statusCode == 200) {
          final jsonData = json.decode(utf8.decode(data.bodyBytes));
          final logs = <ProductLog>[];
          for (var item in jsonData) {
            logs.add(ProductLog.fromJson(item));
          }

          return APIResponse<List<ProductLog>>(data: logs);
        }
        return APIResponse<List<ProductLog>>(
            error: true, errorMessage: "Error Occured in ProductLog");
      }).catchError((_) => APIResponse<List<ProductLog>>(
          error: true, errorMessage: "Unknow error Occured in ProductLog"));
    } finally {
      client.close();
    }
  }

  Future<APIResponse<bool>> createAPIProductLog(Map<String, dynamic> logsObject, String token) {
    final MAIN_ENDPOINT = BASE_ENDPOINT + "product_log/";
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
        return APIResponse<bool>(error: true, errorMessage: "Error Occured in  ProductLog");
      }).catchError((_) =>
              APIResponse<bool>(error: true, errorMessage: "Unknow error Occured in ProductLog"));
    } finally {
      client.close();
    }
  }

  Future<APIResponse<bool>> updateAPIProductLog(Map<String, dynamic> object, int pk, String token) {
    final MAIN_ENDPOINT = BASE_ENDPOINT + "product_log/$pk/";
    final headers = {"Content-Type": "application/json", "Authorization": "JWT " + token};
    var client = http.Client();
    try {
      return client.put(MAIN_ENDPOINT, headers: headers, body: json.encode(object)).then((data) {
        if (data.statusCode == 204 || data.statusCode == 200 || data.statusCode == 404) {
          return APIResponse<bool>(data: true);
        } else if (data.statusCode == 400) {
          return APIResponse<bool>(data: false);
        }
        return APIResponse<bool>(error: true, errorMessage: "Error Occured in ProductLog");
      }).catchError((_) =>
          APIResponse<bool>(error: true, errorMessage: "Unknow error Occured in ProductLog"));
    } finally {
      client.close();
    }
  }

  Future<APIResponse<bool>> deleteAPIProductLog(int pk, String token) {
    final MAIN_ENDPOINT = BASE_ENDPOINT + "product_log/$pk/";
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
