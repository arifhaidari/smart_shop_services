import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pos/db/barcode_model.dart';
import '../../components/mixins.dart';
import '../api_response.dart';

class BarcodeModelService {
  Future<APIResponse<List<BarcodeModel>>> getAPIBarcodeModelList(String token) {
    final MAIN_ENDPOINT = BASE_ENDPOINT + "barcode/";
    final headers = {
      // "Content-Type": "application/json",
      "Authorization": "JWT " + token
    };
    var client = http.Client();
    try {
      return client.get(MAIN_ENDPOINT, headers: headers).then((data) {
        if (data.statusCode == 200) {
          final jsonData = json.decode(utf8.decode(data.bodyBytes));
          final variants = <BarcodeModel>[];
          for (var item in jsonData) {
            variants.add(BarcodeModel.fromJson(item));
          }

          return APIResponse<List<BarcodeModel>>(data: variants);
        }
        return APIResponse<List<BarcodeModel>>(
            error: true, errorMessage: "Error Occured in BarcodeModel");
      }).catchError((_) => APIResponse<List<BarcodeModel>>(
          error: true, errorMessage: "Unknow error Occured in BarcodeModel"));
    } finally {
      client.close();
    }
  }

  Future<APIResponse<bool>> createAPIBarcodeModel(
      Map<String, dynamic> categoryObject, String token) {
    final MAIN_ENDPOINT = BASE_ENDPOINT + "barcode/";
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
        return APIResponse<bool>(error: true, errorMessage: "Error Occured in BarcodeModel");
      }).catchError((_) =>
              APIResponse<bool>(error: true, errorMessage: "Unknow error Occured in BarcodeModel"));
    } finally {
      client.close();
    }
  }

  Future<APIResponse<bool>> updateAPIBarcode(
      Map<String, dynamic> barcodeObject, int barcodePk, String token) {
    final MAIN_ENDPOINT = BASE_ENDPOINT + "barcode/$barcodePk/";
    final headers = {"Content-Type": "application/json", "Authorization": "JWT " + token};
    var client = http.Client();
    try {
      return client.put(MAIN_ENDPOINT, headers: headers, body: json.encode(barcodeObject)).then(
          (data) {
        if (data.statusCode == 204 || data.statusCode == 200 || data.statusCode == 404) {
          return APIResponse<bool>(data: true);
        } else if (data.statusCode == 400) {
          return APIResponse<bool>(data: false);
        }
        return APIResponse<bool>(error: true, errorMessage: "Error Occured in Barcode");
      }).catchError(
          (_) => APIResponse<bool>(error: true, errorMessage: "Unknow error Occured in Barcode"));
    } finally {
      client.close();
    }
  }

  Future<APIResponse<bool>> deleteAPIBarcode(int barcodePk, String token) {
    final MAIN_ENDPOINT = BASE_ENDPOINT + "barcode/$barcodePk/";
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
