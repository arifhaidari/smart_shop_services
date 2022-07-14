import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pos/db/product_model.dart';
import '../../components/mixins.dart';
import '../api_response.dart';

class ProductService {
  Future<APIResponse<List<Product>>> getAPIProductList(String token) {
    final MAIN_ENDPOINT = BASE_ENDPOINT + "product/";
    final headers = {
      // "Content-Type": "application/json",
      "Authorization": "JWT " + token
    };
    var client = http.Client();
    try {
      return client.get(MAIN_ENDPOINT, headers: headers).then((data) {
        if (data.statusCode == 200) {
          final jsonData = json.decode(utf8.decode(data.bodyBytes));
          final products = <Product>[];
          for (var item in jsonData) {
            products.add(Product.fromJson(item));
          }

          return APIResponse<List<Product>>(data: products);
        }
        return APIResponse<List<Product>>(error: true, errorMessage: "Error Occured in Product");
      }).catchError((_) =>
          APIResponse<List<Product>>(error: true, errorMessage: "Unknow error Occured in Product"));
    } finally {
      client.close();
    }
  }

  Future<APIResponse<bool>> createAPIProduct(Map<String, dynamic> productObject, String token) {
    final MAIN_ENDPOINT = BASE_ENDPOINT + "product/";
    final headers = {"Content-Type": "application/json", "Authorization": "JWT " + token};
    var client = http.Client();
    try {
      return client.post(MAIN_ENDPOINT, headers: headers, body: json.encode(productObject)).then(
          (data) {
        if (data.statusCode == 201) {
          return APIResponse<bool>(data: true);
        } else if (data.statusCode == 400) {
          return APIResponse<bool>(data: false);
        }
        return APIResponse<bool>(error: true, errorMessage: "Error Occured in Product");
      }).catchError(
          (_) => APIResponse<bool>(error: true, errorMessage: "Unknow error Occured in Product"));
    } finally {
      client.close();
    }
  }

  Future<APIResponse<bool>> updateAPIProduct(
      Map<String, dynamic> productObject, int productPk, String token) {
    final MAIN_ENDPOINT = BASE_ENDPOINT + "product/$productPk/";
    final headers = {"Content-Type": "application/json", "Authorization": "JWT " + token};
    var client = http.Client();
    try {
      return client.put(MAIN_ENDPOINT, headers: headers, body: json.encode(productObject)).then(
          (data) {
        if (data.statusCode == 204 || data.statusCode == 200 || data.statusCode == 404) {
          return APIResponse<bool>(data: true, error: false);
        } else if (data.statusCode == 400) {
          return APIResponse<bool>(data: false, error: true);
        }
        return APIResponse<bool>(error: true, errorMessage: "Error Occured in Product");
      }).catchError(
          (_) => APIResponse<bool>(error: true, errorMessage: "Unknow error Occured in Product"));
    } finally {
      client.close();
    }
  }

  Future<APIResponse<bool>> deleteAPIProduct(int productPk, String token) {
    final MAIN_ENDPOINT = BASE_ENDPOINT + "product/$productPk/";
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
