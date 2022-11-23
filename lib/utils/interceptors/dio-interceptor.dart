import 'package:absensi_ypsim/env.dart';
import 'package:absensi_ypsim/utils/interceptors/token-interceptor.dart';
import 'package:dio/dio.dart';

import 'logging-interceptor.dart';

class DioClient {
  DioClient._sharedInstance();
  static final DioClient _shared = DioClient._sharedInstance();
  factory DioClient() => _shared;

  static Dio get dio => createDio();
  static Dio dioWithResponseType(ResponseType r, {String? baseUrl}) => createDio(responseType: r, baseUrl: baseUrl);

  static Dio createDio({ResponseType responseType = ResponseType.json, String? baseUrl}) {
    Dio dio = Dio(
      BaseOptions(
        baseUrl: baseUrl != null ? baseUrl : "${Environment.baseUrl}/api",
        contentType: 'application/json;charset=utf-8',
        responseType: responseType,
        headers: {
          'Accept': 'application/json',
        }
      )
    );

    dio..interceptors.add(TokenInterceptor());
    dio..interceptors.add(LoggingInterceptors());
    return dio;
  }
}