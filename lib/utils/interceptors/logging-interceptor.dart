import 'dart:developer';

import 'package:dio/dio.dart';

class LoggingInterceptors extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    print("--> ${options.method.toUpperCase()}");
    print("${options.baseUrl}${options.path}");
    print("Headers:");
    options.headers.forEach((k, v) => print(' $k: $v'));
    if (options.queryParameters.isNotEmpty) {
      print("queryParameters:");
      options.queryParameters.forEach((k, v) => print('$k: $v'));
    }
    if (options.data != null) {
      if(options.data is FormData) {
        inspect((options.data as FormData).fields);
        print("Body: ${(options.data as FormData).fields}");
      } else {
        print("Body: ${options.data}");
      }
    }
    print(
        "--> END ${options.method.toUpperCase()}");

    super.onRequest(options, handler);
  }

  @override
  void onError(DioError dioError, ErrorInterceptorHandler handler) async {
    print(
        "--> ERROR \n${dioError.message} ${(dioError.response != null ? (dioError.response!.realUri.toString() + dioError.response!.realUri.path) : 'URL')}");
    print(
        "${dioError.response != null ? dioError.response!.data : 'Unknown Error'}");
    print("--> END ERROR");
    super.onError(dioError, handler);

  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    print(
      "<-- ${response.statusCode} ${response.realUri.toString()}"
    );
    // print("Headers:");
    // response.headers.forEach((k, v) => print('$k: $v'));
    print("Response: ${response.data}");
    print("<-- END HTTP");
    super.onResponse(response, handler);
  }
}