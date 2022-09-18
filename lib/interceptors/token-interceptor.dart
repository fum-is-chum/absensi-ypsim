import 'package:dio/dio.dart';
import 'package:material_kit_flutter/token-getter.dart';
import '../token-getter.dart';

class TokenInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if(options.headers.containsKey("RequireToken")) {
      options.headers.remove("RequireToken");
      String token = await TokenGetter().userAccessToken;
      options.headers['Authorization'] = token;
    }
    handler.next(options);
  }
}