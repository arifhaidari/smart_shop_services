import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pos/db/expense_model.dart';
import '../../components/mixins.dart';
import '../api_response.dart';

class ExpenseModelService {
  Future<APIResponse<List<ExpenseModel>>> getAPIExpenseModelList(String token) {
    final MAIN_ENDPOINT = BASE_ENDPOINT + "expense/";
    final headers = {
      // "Content-Type": "application/json",
      "Authorization": "JWT " + token
    };
    var client = http.Client();
    try {
      return client.get(MAIN_ENDPOINT, headers: headers).then((data) {
        if (data.statusCode == 200) {
          final jsonData = json.decode(utf8.decode(data.bodyBytes));
          final variants = <ExpenseModel>[];
          for (var item in jsonData) {
            variants.add(ExpenseModel.fromJson(item));
          }

          return APIResponse<List<ExpenseModel>>(data: variants);
        }
        return APIResponse<List<ExpenseModel>>(
            error: true, errorMessage: "Error Occured in ExpenseModel");
      }).catchError((_) => APIResponse<List<ExpenseModel>>(
          error: true, errorMessage: "Unknow error Occured in ExpenseModel"));
    } finally {
      client.close();
    }
  }

  Future<APIResponse<bool>> createAPIExpenseModel(
      Map<String, dynamic> categoryObject, String token) {
    final MAIN_ENDPOINT = BASE_ENDPOINT + "expense/";
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
        return APIResponse<bool>(error: true, errorMessage: "Error Occured in ExpenseModel");
      }).catchError((_) =>
              APIResponse<bool>(error: true, errorMessage: "Unknow error Occured in ExpenseModel"));
    } finally {
      client.close();
    }
  }

  Future<APIResponse<bool>> updateAPIExpense(
      Map<String, dynamic> expenseObject, int expensePk, String token) {
    final MAIN_ENDPOINT = BASE_ENDPOINT + "expense/$expensePk/";
    final headers = {"Content-Type": "application/json", "Authorization": "JWT " + token};
    var client = http.Client();
    try {
      return client.put(MAIN_ENDPOINT, headers: headers, body: json.encode(expenseObject)).then(
          (data) {
        if (data.statusCode == 204 || data.statusCode == 200 || data.statusCode == 404) {
          return APIResponse<bool>(data: true);
        } else if (data.statusCode == 400) {
          return APIResponse<bool>(data: false);
        }
        return APIResponse<bool>(error: true, errorMessage: "Error Occured in Expense");
      }).catchError(
          (_) => APIResponse<bool>(error: true, errorMessage: "Unknow error Occured in Expense"));
    } finally {
      client.close();
    }
  }

  Future<APIResponse<bool>> deleteAPIExpense(int expensePk, String token) {
    final MAIN_ENDPOINT = BASE_ENDPOINT + "expense/$expensePk/";
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
