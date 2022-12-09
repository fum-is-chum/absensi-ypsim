import 'package:SIMAt/env.dart';
import 'package:SIMAt/utils/interceptors/token-interceptor.dart';
import 'package:dio/dio.dart';
import 'package:rxdart/rxdart.dart';

import 'logging-interceptor.dart';

class DioClient {
  DioClient._sharedInstance();
  static final DioClient _shared = DioClient._sharedInstance();
  factory DioClient() => _shared;

  static bool refreshTokenInProgress = false;
  static BehaviorSubject<dynamic> accessTokenSubject = new BehaviorSubject.seeded(null);
  static Stream<dynamic> get accessToken$ => accessTokenSubject.asBroadcastStream();
  
  static void updateToken(dynamic token) {
    accessTokenSubject.sink.add(token);
  }

  static String? get accessToken => accessTokenSubject.value;

  static Dio _dio = Dio(
    BaseOptions(
      baseUrl: "${Environment.baseUrl}/api",
      contentType: 'application/json;charset=utf-8',
      responseType: ResponseType.json,
      headers: {
        'Accept': 'application/json',
      }
    )
  )..interceptors.add(TokenInterceptor())
  ..interceptors.add(LoggingInterceptors());
  
   static Dio _reloginDio = Dio(
      BaseOptions(
        baseUrl: "${Environment.baseUrl}/api",
        contentType: 'application/json;charset=utf-8',
        responseType: ResponseType.json,
        headers: {
          'Accept': 'application/json',
        }
      )
  )..interceptors.add(LoggingInterceptors());

  static Dio get dio {
    if (_dio.options.responseType != ResponseType.json)
    _dio.options.responseType = ResponseType.json;
    return _dio;
  }

  static Dio get reloginDio => _reloginDio;

  static Dio dioWithResponseType(ResponseType r, {String? baseUrl}) => createDio(responseType: r, baseUrl: baseUrl);

  static Dio createDio({ResponseType responseType = ResponseType.json, String? baseUrl}) {
    _dio.options.responseType = responseType;
    return _dio;
  }
}