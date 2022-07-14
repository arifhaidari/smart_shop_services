import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pos/db/invoice_model.dart';
import '../../components/mixins.dart';
import '../api_response.dart';

class InvoiceModelService {
  Future<APIResponse<List<InvoiceModel>>> getAPIInvoiceModelList(String token) {
    final MAIN_ENDPOINT = BASE_ENDPOINT + "invoice/";
    final headers = {
      // "Content-Type": "application/json",
      "Authorization": "JWT " + token
    };
    var client = http.Client();
    try {
      return client.get(MAIN_ENDPOINT, headers: headers).then((data) {
        if (data.statusCode == 200) {
          final jsonData = json.decode(utf8.decode(data.bodyBytes));
          final variants = <InvoiceModel>[];
          for (var item in jsonData) {
            variants.add(InvoiceModel.fromJson(item));
          }

          return APIResponse<List<InvoiceModel>>(data: variants);
        }
        return APIResponse<List<InvoiceModel>>(
            error: true, errorMessage: "Error Occured in InvoiceModel");
      }).catchError((_) => APIResponse<List<InvoiceModel>>(
          error: true, errorMessage: "Unknow error Occured in InvoiceModel"));
    } finally {
      client.close();
    }
  }

  Future<APIResponse<bool>> createAPIInvoiceModel(
      Map<String, dynamic> categoryObject, String token) {
    final MAIN_ENDPOINT = BASE_ENDPOINT + "invoice/";
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
        return APIResponse<bool>(error: true, errorMessage: "Error Occured in InvoiceModel");
      }).catchError((_) =>
              APIResponse<bool>(error: true, errorMessage: "Unknow error Occured in InvoiceModel"));
    } finally {
      client.close();
    }
  }

  Future<APIResponse<bool>> updateAPIInvoice(
      Map<String, dynamic> invoiceObject, int invoicePk, String token) {
    final MAIN_ENDPOINT = BASE_ENDPOINT + "invoice/$invoicePk/";
    final headers = {"Content-Type": "application/json", "Authorization": "JWT " + token};
    var client = http.Client();
    try {
      return client.put(MAIN_ENDPOINT, headers: headers, body: json.encode(invoiceObject)).then(
          (data) {
        if (data.statusCode == 204 || data.statusCode == 200 || data.statusCode == 404) {
          return APIResponse<bool>(data: true);
        } else if (data.statusCode == 400) {
          return APIResponse<bool>(data: false);
        }
        return APIResponse<bool>(error: true, errorMessage: "Error Occured in Invoice");
      }).catchError(
          (_) => APIResponse<bool>(error: true, errorMessage: "Unknow error Occured in Invoice"));
    } finally {
      client.close();
    }
  }

  Future<APIResponse<bool>> deleteAPIInvoice(int invoicePk, String token) {
    final MAIN_ENDPOINT = BASE_ENDPOINT + "invoice/$invoicePk/";
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
