import 'package:dio/dio.dart';
import 'package:material_kit_flutter/interceptors/logging-interceptor.dart';
import 'package:material_kit_flutter/interceptors/token-interceptor.dart';

class DioClient {
  DioClient._sharedInstance();
  static final DioClient _shared = DioClient._sharedInstance();
  factory DioClient() => _shared;
  Dio get dio => createDio();

  Dio createDio() {
    Dio dio = Dio(
      BaseOptions(
        baseUrl: "https://presensi.ypsimlibrary.com/api",
        contentType: 'application/json;charset=utf-8',
        headers: {
          'Accept': 'application/json'
        }
      )
    );

    dio..interceptors.add(TokenInterceptor());
    dio..interceptors.add(LoggingInterceptors());
    return dio;
  } 
}