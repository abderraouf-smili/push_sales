import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:push_sale/config/app_config.dart';
import 'package:push_sale/const/globals.dart' as global;
import 'package:shared_preferences/shared_preferences.dart';

class CallApi {
  //
  static String? _token;

  static Future<ResponseHttpRequest> RequestHttp(
    String route, {
    Map<String, dynamic>? data,
    String method = "POST",
    ProgressCallback? onsend,
    ProgressCallback? onreceive,
  }) async {
    final dio = Dio(BaseOptions(
      connectTimeout: global.timeOut,
      sendTimeout: global.timeOut,
      receiveTimeout: global.timeOut,
      baseUrl: AppConfig.apiRootUrl,
      responseType: ResponseType.json,
      contentType: ContentType.json.toString(),
    ));
    if (kDebugMode) {
      debugPrint("=====> Call API : $method $route");
    }
    try {
      await _useSavedToken();
      if (_token != null) {
        // print(_token);
        dio.options.headers["Authorization"] = "Bearer $_token";
      }
      final normalizedMethod = method.toUpperCase();
      var response = normalizedMethod == "GET"
          ? await dio.get("/$route",
              queryParameters: data, onReceiveProgress: onreceive)
          : await dio.post("/$route",
              data: data, onSendProgress: onsend, onReceiveProgress: onreceive);
      if (kDebugMode) {
        debugPrint("=====> Response API $route status ${response.statusCode}");
      }
      if (response.statusCode == 200) {
        ResponseHttpRequest ret = ResponseHttpRequest.fromMap(response.data);
        if (ret.status == "SUCCESS") {
          return ret;
        } else {
          return ResponseHttpRequest(
            code: "403",
            status: "error",
            message: ret.message,
            data: ret.data,
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
        if (kDebugMode) {
          debugPrint("=====> Response API $route ERROR : ${e.message}");
        }
        return ResponseHttpRequest.fromMap({
          "status": "error",
          "code": "${e.response?.statusCode}",
          "message": e.message
        });
      } else {
        if (kDebugMode) {
          debugPrint("=====> Response API $route ERROR");
        }
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

  static Future<void> _useSavedToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.getString("userToken") != null) {
      _token = prefs.getString("userToken");
    }
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
