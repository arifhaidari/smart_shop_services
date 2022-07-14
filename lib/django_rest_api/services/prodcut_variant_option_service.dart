import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pos/db/product_variant_option.dart';
import '../../components/mixins.dart';
import '../api_response.dart';

class ProductVariantOptionService {
  Future<APIResponse<List<ProductVariantOption>>> getAPIProductVariantOptionList(String token) {
    final MAIN_ENDPOINT = BASE_ENDPOINT + "product_variant_option/";
    final headers = {
      // "Content-Type": "application/json",
      "Authorization": "JWT " + token
    };
    var client = http.Client();
    try {
      return client.get(MAIN_ENDPOINT, headers: headers).then((data) {
        if (data.statusCode == 200) {
          final jsonData = json.decode(utf8.decode(data.bodyBytes));
          final variants = <ProductVariantOption>[];
          for (var item in jsonData) {
            variants.add(ProductVariantOption.fromJson(item));
          }

          return APIResponse<List<ProductVariantOption>>(data: variants);
        }
        return APIResponse<List<ProductVariantOption>>(
            error: true, errorMessage: "Error Occured in ProductVariantOption");
      }).catchError((_) => APIResponse<List<ProductVariantOption>>(
          error: true, errorMessage: "Unknow error Occured in ProductVariantOption"));
    } finally {
      client.close();
    }
  }

  Future<APIResponse<bool>> createAPIProductVariantOption(
      Map<String, dynamic> categoryObject, String token) {
    final MAIN_ENDPOINT = BASE_ENDPOINT + "product_variant_option/";
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
        return APIResponse<bool>(
            error: true, errorMessage: "Error Occured in ProductVariantOption");
      }).catchError((_) => APIResponse<bool>(
              error: true, errorMessage: "Unknow error Occured in ProductVariantOption"));
    } finally {
      client.close();
    }
  }

  Future<APIResponse<bool>> updateAPIProductVariantOption(
      Map<String, dynamic> object, int pk, String token) {
    final MAIN_ENDPOINT = BASE_ENDPOINT + "product_variant_option/$pk/";
    final headers = {"Content-Type": "application/json", "Authorization": "JWT " + token};
    var client = http.Client();
    try {
      return client.put(MAIN_ENDPOINT, headers: headers, body: json.encode(object)).then((data) {
        if (data.statusCode == 204 || data.statusCode == 200 || data.statusCode == 404) {
          return APIResponse<bool>(data: true);
        } else if (data.statusCode == 400) {
          return APIResponse<bool>(data: false);
        }
        return APIResponse<bool>(
            error: true, errorMessage: "Error Occured in ProductVariantOption");
      }).catchError((_) => APIResponse<bool>(
          error: true, errorMessage: "Unknow error Occured in ProductVariantOption"));
    } finally {
      client.close();
    }
  }

  Future<APIResponse<bool>> deleteAPIProductVariantOption(int pk, String token) {
    final MAIN_ENDPOINT = BASE_ENDPOINT + "product_variant_option/$pk/";
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
