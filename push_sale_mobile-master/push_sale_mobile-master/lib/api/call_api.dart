import 'dart:io';
import 'package:dio/dio.dart';
import 'package:push_sale/const/globals.dart' as global;
import 'package:shared_preferences/shared_preferences.dart';

class CallApi {
  //
  static String? _token;

  static Future<ResponseHttpRequest> RequestHttp(
    String route, {
    Map<String, dynamic>? data,
    ProgressCallback? onsend,
    ProgressCallback? onreceive,
  }) async {
    final dio = Dio(BaseOptions(
      connectTimeout: global.timeOut,
      sendTimeout: global.timeOut,
      receiveTimeout: global.timeOut,
      baseUrl: "${global.urlAPI}/api", // localhost server
      responseType: ResponseType.json,
      contentType: ContentType.json.toString(),
    ));
    print("=====> Call API : $route args($data)");
    try {
      await _useSavedToken();
      if (_token != null) {
        // print(_token);
        dio.options.headers["Authorization"] = "Bearer $_token";
      }
      var response = await dio.post("/$route",
          data: data, onSendProgress: onsend, onReceiveProgress: onreceive);
      print("=====> Response API $route ${response.data}");
      if (response.statusCode == 200) {
        ResponseHttpRequest ret = ResponseHttpRequest.fromMap(response.data);
        if (ret.status == "SUCCESS") {
          return ret;
        } else {
          return ResponseHttpRequest(
            code: "403",
            status: "error",
            message: ret.message,
            data: ret.data ?? null,
          );
        }
      } else {
        return ResponseHttpRequest.fromMap({
          "status": "error",
          "code": response.statusCode,
          "message": response.statusMessage,
        });
      }
    } catch (e) {
      if (e is DioException) {
        print("=====> Response API $route ERROR :  ${e.message}");
        return ResponseHttpRequest.fromMap({
          "status": "error",
          "code": "${e.response?.statusCode}",
          "message": e.message
        });
      } else {
        print("=====> Response API $route ERROR :  ${e}");
        return ResponseHttpRequest.fromMap(
            {"status": "error", "code": "IE", "message": "$e"});
      }
    }
    // on DioError catch (e) {
    //   print("=====> Response API $route ${response.data}");
    //   return ResponseHttpRequest.fromMap({
    //     "status": "error",
    //     "code": e.response != null ? e.response!.statusCode : 500,
    //     "message": e.message
    //   });
    // }
  }

  static _useSavedToken() async {
    SharedPreferences Prefs = await SharedPreferences.getInstance();

    if (Prefs.getString("userToken") != null)
      _token = await Prefs.getString("userToken");
    // _token =
    //     "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiIxIiwianRpIjoiODNmYWRjMjQ0NTIxYjQ0NWQwMDllZGIwNmRmZjk5YjM5N2JiM2Q4ZGJlYmYzOTA3OThkYTFlZmIwYjE2NjQ1ZDA2M2Q1Y2Y3NDhjMDNlMjgiLCJpYXQiOjE3MTA3NzAwMTQuOTQ4OTMyLCJuYmYiOjE3MTA3NzAwMTQuOTQ4OTM0LCJleHAiOjE3NDIzMDYwMTQuOTQ1MDI2LCJzdWIiOiIxNiIsInNjb3BlcyI6W119.wKXYhX2sDbVRlYUIhccWx264s9NwcHw5TklXMj27UWE-GZfpd6mXQtZPC22DxqyyNjBmJO7XEDWmIsOyp8lvm4dRiC79BELHrjscQ94VP37nRrzcfnopnhwaJyFYhOciEeXqCujlQ6V-85mZCs0LZIzYNPhJ5Env3OGgcGTg92_0sL9nCkefpPSLHSGyjq7ENzt1S5RGvgaEF3Wg_bjypsegKJuH1oXRyM-P8hM2WWBTBsMaY41AI5UJ6L65ohrCSfJZ-I1STMKW5wbofjjr3HAij1gC9IPjAaMjLWSullGTTAEeYrOvDIkGftW8d_Z-ku2FeBPhtFU2croqy_8NPXn9iz3G8XiCyvEQyRJE0AAAR5IgTs1Zslz7IGPzVNuw-txhrrhyuGGz1APb1X93u02febakoLOFPBHVgCQ6Fmyy4pB-3xLitCEb66bode_1TSR74CZY_7aQDp20V-5-RPpPHhp4JTX-e646Xd9hZqUcVv2TuszFpMfFLGh4-a54bncwLwIHRjJz0gpgahN_h83Dk5A-ReQ0SMf5P2msDqz1PCl9vp-6zaR2VTvNnnJS20qMaeuwoIz41DJbMnX8pvMooGLzYc-TZMETLjQ-H2ICvE_zHyYeTmXKR7G5PlCkS-wMQmP4tUSwGRNdIlVq8F1BnEWL5r55Kjy4ol6sEE8";
  }
}

class ResponseHttpRequest {
  final String code;
  final String status;
  final dynamic message;
  final dynamic data;
  // ignore: prefer_typing_uninitialized_variables, non_constant_identifier_names
  ResponseHttpRequest(
      {required this.code,
      required this.status,
      required this.message,
      this.data});

  static ResponseHttpRequest fromMap(Map<String, dynamic> value) {
    return ResponseHttpRequest(
      code: value["code"] != null ? value["code"].toString() : "",
      status: value["status"],
      message: value["message"] ?? "",
      data: value["data"],
    );
  }
}
