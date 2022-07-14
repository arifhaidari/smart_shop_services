import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pos/db/category_product_model.dart';
import '../../components/mixins.dart';
import '../api_response.dart';

class CategoryProductJoinService {
  Future<APIResponse<List<CategoryProductJoin>>> getAPICategoryProductJoinList(String token) {
    final MAIN_ENDPOINT = BASE_ENDPOINT + "category_product/";
    final headers = {
      // "Content-Type": "application/json",
      "Authorization": "JWT " + token
    };
    var client = http.Client();
    try {
      return client.get(MAIN_ENDPOINT, headers: headers).then((data) {
        if (data.statusCode == 200) {
          final jsonData = json.decode(utf8.decode(data.bodyBytes));
          final variants = <CategoryProductJoin>[];
          for (var item in jsonData) {
            variants.add(CategoryProductJoin.fromJson(item));
          }

          return APIResponse<List<CategoryProductJoin>>(data: variants);
        }
        return APIResponse<List<CategoryProductJoin>>(
            error: true, errorMessage: "Error Occured in CategoryProductJoin");
      }).catchError((_) => APIResponse<List<CategoryProductJoin>>(
          error: true, errorMessage: "Unknow error Occured in CategoryProductJoin"));
    } finally {
      client.close();
    }
  }

  Future<APIResponse<bool>> createAPICategoryProductJoin(
      Map<String, dynamic> categoryObject, String token) {
    final MAIN_ENDPOINT = BASE_ENDPOINT + "category_product/";
    final headers = {"Content-Type": "application/json", "Authorization": "JWT " + token};
    var client = http.Client();
    try {
      return http
          .post(MAIN_ENDPOINT, headers: headers, body: json.encode(categoryObject))
          .then((data) {
        if (data.statusCode == 201) {
          return APIResponse<bool>(data: true);
        } else if (data.statusCode == 400) {
          return APIResponse<bool>(data: false);
        }
        return APIResponse<bool>(error: true, errorMessage: "Error Occured in CategoryProductJoin");
      }).catchError((_) => APIResponse<bool>(
              error: true, errorMessage: "Unknow error Occured in CategoryProductJoin"));
    } finally {
      client.close();
    }
  }

  Future<APIResponse<bool>> updateAPICategoryProduct(
      Map<String, dynamic> categoryProductObject, int categoryProductPk, String token) {
    final MAIN_ENDPOINT = BASE_ENDPOINT + "category_product/$categoryProductPk/";
    final headers = {"Content-Type": "application/json", "Authorization": "JWT " + token};
    var client = http.Client();
    try {
      return client
          .put(MAIN_ENDPOINT, headers: headers, body: json.encode(categoryProductObject))
          .then((data) {
        if (data.statusCode == 204 || data.statusCode == 200 || data.statusCode == 404) {
          return APIResponse<bool>(data: true);
        } else if (data.statusCode == 400) {
          return APIResponse<bool>(data: false);
        }
        return APIResponse<bool>(error: true, errorMessage: "Error Occured in CategoryProduct");
      }).catchError((_) => APIResponse<bool>(
              error: true, errorMessage: "Unknow error Occured in CategoryProduct"));
    } finally {
      client.close();
    }
  }

  Future<APIResponse<bool>> deleteAPICategoryProduct(int categoryProductPk, String token) {
    final MAIN_ENDPOINT = BASE_ENDPOINT + "category_product/$categoryProductPk/";
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
