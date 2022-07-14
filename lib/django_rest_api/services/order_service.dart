import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pos/db/order_model.dart';
import '../../components/mixins.dart';
import '../api_response.dart';

class OrderModelService {
  Future<APIResponse<List<OrderModel>>> getAPIOrderModelList(String token) {
    final MAIN_ENDPOINT = BASE_ENDPOINT + "order/";
    final headers = {
      // "Content-Type": "application/json",
      "Authorization": "JWT " + token
    };
    var client = http.Client();
    try {
      return client.get(MAIN_ENDPOINT, headers: headers).then((data) {
        if (data.statusCode == 200) {
          final jsonData = json.decode(utf8.decode(data.bodyBytes));
          final orders = <OrderModel>[];
          for (var item in jsonData) {
            orders.add(OrderModel.fromJson(item));
          }

          return APIResponse<List<OrderModel>>(data: orders);
        }
        return APIResponse<List<OrderModel>>(
            error: true, errorMessage: "Error Occured in OrderModel");
      }).catchError((_) => APIResponse<List<OrderModel>>(
          error: true, errorMessage: "Unknow error Occured in OrderModel"));
    } finally {
      client.close();
    }
  }

  Future<APIResponse<bool>> createAPIOrderModel(Map<String, dynamic> categoryObject, String token) {
    final MAIN_ENDPOINT = BASE_ENDPOINT + "order/";
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
        return APIResponse<bool>(error: true, errorMessage: "Error Occured in OrderModel");
      }).catchError((_) =>
              APIResponse<bool>(error: true, errorMessage: "Unknow error Occured in OrderModel"));
    } finally {
      client.close();
    }
  }

  Future<APIResponse<bool>> updateAPIOrder(
      Map<String, dynamic> orderObject, int orderPk, String token) {
    final MAIN_ENDPOINT = BASE_ENDPOINT + "order/$orderPk/";
    final headers = {"Content-Type": "application/json", "Authorization": "JWT " + token};
    var client = http.Client();
    try {
      return client
          .put(MAIN_ENDPOINT, headers: headers, body: json.encode(orderObject))
          .then((data) {
        if (data.statusCode == 204 || data.statusCode == 200 || data.statusCode == 404) {
          return APIResponse<bool>(data: true);
        } else if (data.statusCode == 400) {
          return APIResponse<bool>(data: false);
        }
        return APIResponse<bool>(error: true, errorMessage: "Error Occured in Order");
      }).catchError(
              (_) => APIResponse<bool>(error: true, errorMessage: "Unknow error Occured in Order"));
    } finally {
      client.close();
    }
  }

  Future<APIResponse<bool>> deleteAPIOrder(int orderPk, String token) {
    final MAIN_ENDPOINT = BASE_ENDPOINT + "order/$orderPk/";
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
