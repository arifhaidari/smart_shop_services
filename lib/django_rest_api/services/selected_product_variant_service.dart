import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pos/db/selected_product_variant.dart';
import '../../components/mixins.dart';
import '../api_response.dart';

class SelectedProductVariantModelService {
  Future<APIResponse<List<SelectedProductVariantModel>>> getAPISelectedProductVariantModelList(
      String token) {
    final MAIN_ENDPOINT = BASE_ENDPOINT + "selected_product_variant/";
    final headers = {
      // "Content-Type": "application/json",
      "Authorization": "JWT " + token
    };
    var client = http.Client();
    try {
      return client.get(MAIN_ENDPOINT, headers: headers).then((data) {
        if (data.statusCode == 200) {
          final jsonData = json.decode(utf8.decode(data.bodyBytes));
          final variants = <SelectedProductVariantModel>[];
          for (var item in jsonData) {
            variants.add(SelectedProductVariantModel.fromJson(item));
          }

          return APIResponse<List<SelectedProductVariantModel>>(data: variants);
        }
        return APIResponse<List<SelectedProductVariantModel>>(
            error: true, errorMessage: "Error Occured in SelectedProductVariantModel");
      }).catchError((_) => APIResponse<List<SelectedProductVariantModel>>(
          error: true, errorMessage: "Unknow error Occured in SelectedProductVariantModel"));
    } finally {
      client.close();
    }
  }

  Future<APIResponse<bool>> createAPISelectedProductVariantModel(
      Map<String, dynamic> categoryObject, String token) {
    final MAIN_ENDPOINT = BASE_ENDPOINT + "selected_product_variant/";
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
            error: true, errorMessage: "Error Occured in SelectedProductVariantModel");
      }).catchError((_) => APIResponse<bool>(
              error: true, errorMessage: "Unknow error Occured in SelectedProductVariantModel"));
    } finally {
      client.close();
    }
  }

  Future<APIResponse<bool>> updateAPISelectedProductVariant(
      Map<String, dynamic> object, int pk, String token) {
    final MAIN_ENDPOINT = BASE_ENDPOINT + "selected_product_variant/$pk/";
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
            error: true, errorMessage: "Error Occured in SelectedProductVariant");
      }).catchError((_) => APIResponse<bool>(
          error: true, errorMessage: "Unknow error Occured in SelectedProductVariant"));
    } finally {
      client.close();
    }
  }

  Future<APIResponse<bool>> deleteAPISelectedProductVariant(int pk, String token) {
    final MAIN_ENDPOINT = BASE_ENDPOINT + "selected_product_variant/$pk/";
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
