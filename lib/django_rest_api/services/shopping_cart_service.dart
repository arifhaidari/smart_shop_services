import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pos/db/shopping_cart_model.dart';
import '../../components/mixins.dart';
import '../api_response.dart';

class ShoppingCartModelService {
  Future<APIResponse<List<ShoppingCartModel>>> getAPIShoppingCartModelList(String token) {
    final MAIN_ENDPOINT = BASE_ENDPOINT + "shopping_cart/";
    final headers = {
      // "Content-Type": "application/json",
      "Authorization": "JWT " + token
    };
    var client = http.Client();
    try {
      return client.get(MAIN_ENDPOINT, headers: headers).then((data) {
        if (data.statusCode == 200) {
          final jsonData = json.decode(utf8.decode(data.bodyBytes));
          final variants = <ShoppingCartModel>[];
          for (var item in jsonData) {
            variants.add(ShoppingCartModel.fromJson(item));
          }

          return APIResponse<List<ShoppingCartModel>>(data: variants);
        }
        return APIResponse<List<ShoppingCartModel>>(
            error: true, errorMessage: "Error Occured in ShoppingCartModel");
      }).catchError((_) => APIResponse<List<ShoppingCartModel>>(
          error: true, errorMessage: "Unknow error Occured in ShoppingCartModel"));
    } finally {
      client.close();
    }
  }

  Future<APIResponse<bool>> createAPIShoppingCartModel(
      Map<String, dynamic> shoppingCartObject, String token) {
    final MAIN_ENDPOINT = BASE_ENDPOINT + "shopping_cart/";
    final headers = {"Content-Type": "application/json", "Authorization": "JWT " + token};
    var client = http.Client();
    try {
      return client
          .post(MAIN_ENDPOINT, headers: headers, body: json.encode(shoppingCartObject))
          .then((data) {
        if (data.statusCode == 201) {
          return APIResponse<bool>(data: true);
        } else if (data.statusCode == 400) {
          return APIResponse<bool>(data: false);
        }
        return APIResponse<bool>(error: true, errorMessage: "Error Occured in ShoppingCartModel");
      }).catchError((_) => APIResponse<bool>(
              error: true, errorMessage: "Unknow error Occured in ShoppingCartModel"));
    } finally {
      client.close();
    }
  }

  Future<APIResponse<bool>> updateAPIShoppingCart(
      Map<String, dynamic> object, int pk, String token) {
    final MAIN_ENDPOINT = BASE_ENDPOINT + "shopping_cart/$pk/";
    final headers = {"Content-Type": "application/json", "Authorization": "JWT " + token};
    var client = http.Client();
    try {
      return client.put(MAIN_ENDPOINT, headers: headers, body: json.encode(object)).then((data) {
        if (data.statusCode == 204 || data.statusCode == 200 || data.statusCode == 404) {
          return APIResponse<bool>(data: true);
        } else if (data.statusCode == 400) {
          return APIResponse<bool>(data: false);
        }
        return APIResponse<bool>(error: true, errorMessage: "Error Occured in ShoppingCart");
      }).catchError((_) =>
          APIResponse<bool>(error: true, errorMessage: "Unknow error Occured in ShoppingCart"));
    } finally {
      client.close();
    }
  }

  Future<APIResponse<bool>> deleteAPIShoppingCart(int pk, String token) {
    final MAIN_ENDPOINT = BASE_ENDPOINT + "shopping_cart/$pk/";
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
