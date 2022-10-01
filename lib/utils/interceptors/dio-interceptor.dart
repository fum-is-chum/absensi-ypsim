import 'package:absensi_ypsim/utils/interceptors/logging-interceptor.dart';
import 'package:absensi_ypsim/utils/interceptors/token-interceptor.dart';
import 'package:dio/dio.dart';

class DioClient {
  DioClient._sharedInstance();
  static final DioClient _shared = DioClient._sharedInstance();
  factory DioClient() => _shared;

  Dio get dio => createDio();
  Dio dioWithResponseType(ResponseType r, {String? baseUrl}) => createDio(responseType: r, baseUrl: baseUrl);

  Dio createDio({ResponseType responseType = ResponseType.json, String? baseUrl}) {
    Dio dio = Dio(
      BaseOptions(
        baseUrl: baseUrl != null ? baseUrl : "https://presensi.ypsimlibrary.com/api",
        contentType: 'application/json;charset=utf-8',
        responseType: responseType,
        headers: {
          'Accept': '*/*',
        }
      )
    );

    dio..interceptors.add(TokenInterceptor());
    dio..interceptors.add(LoggingInterceptors());
    return dio;
  }
}