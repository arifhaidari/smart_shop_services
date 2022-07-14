import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pos/db/variant_option_model.dart';
import '../../components/mixins.dart';

import '../api_response.dart';

class VariantOptionService {
  Future<APIResponse<List<VariantOption>>> getAPIVariantOptionList(String token) {
    final MAIN_ENDPOINT = BASE_ENDPOINT + "variant_option/";
    final headers = {
      // "Content-Type": "application/json",
      "Authorization": "JWT " + token
    };
    var client = http.Client();
    try {
      return client.get(MAIN_ENDPOINT, headers: headers).then((data) {
        if (data.statusCode == 200) {
          final jsonData = json.decode(utf8.decode(data.bodyBytes));
          final variants = <VariantOption>[];
          for (var item in jsonData) {
            variants.add(VariantOption.fromJson(item));
          }

          return APIResponse<List<VariantOption>>(data: variants);
        }
        return APIResponse<List<VariantOption>>(
            error: true, errorMessage: "Error Occured in VariantOption");
      }).catchError((_) => APIResponse<List<VariantOption>>(
          error: true, errorMessage: "Unknow error Occured in VariantOption"));
    } finally {
      client.close();
    }
  }

  Future<APIResponse<bool>> createAPIVariantOption(
      Map<String, dynamic> categoryObject, String token) {
    final MAIN_ENDPOINT = BASE_ENDPOINT + "variant_option/";
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
        return APIResponse<bool>(error: true, errorMessage: "Error Occured in VariantOption");
      }).catchError((_) =>
          APIResponse<bool>(error: true, errorMessage: "Unknow error Occured in VariantOption"));
    } finally {
      client.close();
    }
  }

  Future<APIResponse<bool>> updateAPIVariantOption(
      Map<String, dynamic> object, int pk, String token) {
    final MAIN_ENDPOINT = BASE_ENDPOINT + "variant_option/$pk/";
    final headers = {"Content-Type": "application/json", "Authorization": "JWT " + token};
    var client = http.Client();
    try {
      return client.put(MAIN_ENDPOINT, headers: headers, body: json.encode(object)).then((data) {
        if (data.statusCode == 204 || data.statusCode == 200 || data.statusCode == 404) {
          return APIResponse<bool>(data: true);
        } else if (data.statusCode == 400) {
          return APIResponse<bool>(data: false);
        }
        return APIResponse<bool>(error: true, errorMessage: "Error Occured in VariantOption");
      }).catchError((_) =>
          APIResponse<bool>(error: true, errorMessage: "Unknow error Occured in VariantOption"));
    } finally {
      client.close();
    }
  }

  Future<APIResponse<bool>> deleteAPIVariantOption(int pk, String token) {
    final MAIN_ENDPOINT = BASE_ENDPOINT + "variant_option/$pk/";
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
