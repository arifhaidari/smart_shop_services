import 'dart:convert';
import 'package:pos/db/authentication_model.dart';
import 'package:pos/db/db_helper.dart';
import 'api_response.dart';
import 'package:http/http.dart' as http;
import '../components/mixins.dart';

class AuthenticationService {
  final AUTH_ENDPOINT = BASE_ENDPOINT + "auth/";
  static const credential_header = {
    "Content-Type": "application/json",
  };

  final PosDatabase dbmanager = new PosDatabase();

  // static const credential = {
  //   // "phone": "0778989270",
  //   // "password": "123",
  //   "phone": "0778989259",
  //   "password": "351",
  // };

  Future<APIResponse<UserAuthentication>> userLogin() async {
    Map<String, dynamic> credential = Map();
    await dbmanager.getSingleUser().then((onValue) async {
      if (onValue != null) {
        credential = {
          "phone": onValue.phone,
          "password": onValue.password,
        };
      }
    });
    return http
        .post(AUTH_ENDPOINT, headers: credential_header, body: json.encode(credential))
        .then((data) {
      if (data.statusCode == 200) {
        final jsonData = json.decode(data.body);
        final auth_detail =
            UserAuthentication(status: data.statusCode.toString(), token: jsonData['token']);
        return APIResponse<UserAuthentication>(data: auth_detail, error: false);
      } else if (data.statusCode == 401) {
        final jsonData = json.decode(data.body);
        final auth_detail =
            UserAuthentication(status: data.statusCode.toString(), token: jsonData['detail']);
        return APIResponse<UserAuthentication>(data: auth_detail, error: true);
      }
      return APIResponse<UserAuthentication>(
          error: true, errorMessage: "Error occured in user authentication");
    }).catchError((_) => APIResponse<UserAuthentication>(
            error: true, errorMessage: "Unknown Error occured in user authentication"));
  }

  //

  // Future<APIResponse<List<PosBackupModel>>> getAPIPosBackupList(String token) {
  //   final POS_BACKUP_ENDPOINT = BASE_ENDPOINT + "pos/";
  //   final headers = {
  //     // "Content-Type": "application/json",
  //     "Authorization": "JWT " + token
  //   };
  //   return http.get(POS_BACKUP_ENDPOINT, headers: headers).then((data) {
  //     if (data.statusCode == 200) {
  //       final jsonData = json.decode(data.body);
  //       final pos_backup_list = <PosBackupModel>[];
  //       for (var item in jsonData) {
  //         pos_backup_list.add(PosBackupModel.fromJson(item));
  //       }
  //       return APIResponse<List<PosBackupModel>>(data: pos_backup_list);
  //     }
  //     return APIResponse<List<PosBackupModel>>(
  //         error: true, errorMessage: "Error occured in Backup List");
  //   }).catchError((_) => APIResponse<List<PosBackupModel>>(
  //       error: true, errorMessage: "Unknown Error occured in Backup List"));
  // }

  //

  // Future<APIResponse<PosBackupModel>> getAPIPosBackup(String token) {
  //   final POS_BACKUP_ENDPOINT = BASE_ENDPOINT + "pos/";
  //   final headers = {
  //     // "Content-Type": "application/json",
  //     "Authorization": "JWT " + token
  //   };
  //   return http.get(POS_BACKUP_ENDPOINT, headers: headers).then((data) {
  //     if (data.statusCode == 200) {
  //       final jsonData = json.decode(data.body);
  //       return APIResponse<PosBackupModel>(data: PosBackupModel.fromJson(jsonData));
  //     }
  //     return APIResponse<PosBackupModel>(
  //         error: true, errorMessage: "Error occured in this backup version");
  //   }).catchError((_) => APIResponse<PosBackupModel>(
  //       error: true, errorMessage: "Unknown Error occured in this backup version"));
  // }

  //

  // Future<APIResponse<PosBackupModel>> createAPIPosBackup(
  //     Map<String, dynamic> posBackupObject, String token) {
  //   final POS_BACKUP_ENDPOINT = BASE_ENDPOINT + "pos/";
  //   final headers = {"Content-Type": "application/json", "Authorization": "JWT " + token};

  //   return http
  //       .post(POS_BACKUP_ENDPOINT, headers: headers, body: json.encode(posBackupObject))
  //       .then((data) {
  //     if (data.statusCode == 201) {
  //       final jsonData = json.decode(data.body);
  //       return APIResponse<PosBackupModel>(data: PosBackupModel.fromJson(jsonData), error: false);
  //     }
  //     return APIResponse<PosBackupModel>(error: true, errorMessage: "Error Occured in PosBackup");
  //   }).catchError((_) => APIResponse<PosBackupModel>(
  //           error: true, errorMessage: "Unknow error Occured in PosBackup"));
  // }

  // Future<APIResponse<bool>> deleteAPIDbVersion(String dbVersionId, String token) {
  //   final MAIN_ENDPOINT = BASE_ENDPOINT + "pos/$dbVersionId/";
  //   final headers = {
  //     "Content-Type": "application/json",
  //     // "Accept": "application/json",
  //     "Authorization": "JWT " + token
  //   };
  //   print("inside the deleteAPIDbVersion");
  //   return http.delete(MAIN_ENDPOINT, headers: headers).then((data) {
  //     print("vlaue of data");
  //     print(data);
  //     print(data.statusCode);
  //     print(data.body);
  //     print(data.body);
  //     if (data.statusCode == 204) {
  //       return APIResponse<bool>(data: true, error: false);
  //     }
  //     return APIResponse<bool>(error: true, errorMessage: "Error Occured due to request");
  //   }).catchError(
  //       (_) => APIResponse<bool>(error: true, errorMessage: "Error Occured due to catch"));
  // }
}
