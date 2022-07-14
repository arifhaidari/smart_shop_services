import 'dart:convert';
import 'package:pos/db/category_model.dart';
import '../api_response.dart';
import 'package:http/http.dart' as http;
import '../../components/mixins.dart';

class CategoryService {
  Future<APIResponse<List<Category>>> getAPICategoryList(String token) {
    final MAIN_ENDPOINT = BASE_ENDPOINT + "category/";
    final headers = {
      // "Content-Type": "application/json",
      "Authorization": "JWT " + token
    };
    var client = http.Client();
    try {
      return client.get(MAIN_ENDPOINT, headers: headers).then((data) {
        if (data.statusCode == 200) {
          final jsonData = json.decode(utf8.decode(data.bodyBytes));
          final categories = <Category>[];
          for (var item in jsonData) {
            categories.add(Category.fromJson(item));
          }

          return APIResponse<List<Category>>(data: categories);
        }
        return APIResponse<List<Category>>(error: true, errorMessage: "Error Occured in Category");
      }).catchError((_) => APIResponse<List<Category>>(
          error: true, errorMessage: "Unknow error Occured in Category"));
    } finally {
      client.close();
    }
  }

  Future<APIResponse<bool>> createAPICategory(Map<String, dynamic> categoryObject, String token) {
    final MAIN_ENDPOINT = BASE_ENDPOINT + "category/";
    final headers = {"Content-Type": "application/json", "Authorization": "JWT " + token};
    var client = http.Client();
    try {
      return client.post(MAIN_ENDPOINT, headers: headers, body: json.encode(categoryObject)).then(
          (data) {
        if (data.statusCode == 201) {
          return APIResponse<bool>(data: true);
        } else if (data.statusCode == 400) {
          return APIResponse<bool>(data: false);
        }
        return APIResponse<bool>(error: true, errorMessage: "Error Occured in Category");
      }).catchError(
          (_) => APIResponse<bool>(error: true, errorMessage: "Unknow error Occured in Category"));
    } finally {
      client.close();
    }
  }

  Future<APIResponse<bool>> updateAPICategory(
      Map<String, dynamic> categoryObject, int categoryPk, String token) {
    final MAIN_ENDPOINT = BASE_ENDPOINT + "category/$categoryPk/";
    final headers = {"Content-Type": "application/json", "Authorization": "JWT " + token};
    var client = http.Client();
    try {
      return client.put(MAIN_ENDPOINT, headers: headers, body: json.encode(categoryObject)).then(
          (data) {
        if (data.statusCode == 204 || data.statusCode == 200 || data.statusCode == 404) {
          return APIResponse<bool>(data: true);
        } else if (data.statusCode == 400) {
          return APIResponse<bool>(data: false);
        }
        return APIResponse<bool>(error: true, errorMessage: "Error Occured in Category");
      }).catchError(
          (_) => APIResponse<bool>(error: true, errorMessage: "Unknow error Occured in Category"));
    } finally {
      client.close();
    }
  }

  Future<APIResponse<bool>> deleteAPICategory(int categoryPk, String token) {
    final MAIN_ENDPOINT = BASE_ENDPOINT + "category/$categoryPk/";
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
