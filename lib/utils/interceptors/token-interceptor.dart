import 'package:SIMAt/screens/login-register-verification/screens/login/bloc/login-bloc.dart';
import 'package:SIMAt/utils/misc/credential-getter.dart';
import 'package:dio/dio.dart';

import 'dio-interceptor.dart';

class TokenInterceptor extends QueuedInterceptorsWrapper {
  
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if(options.headers.containsKey("RequireToken")) {
      String token = await CredentialGetter.userAccessToken;
      options.headers.remove("RequireToken");
      options.headers['Token'] = token;
      options.headers['Authorization'] = "Bearer $token";
    }
    return handler.next(options);
  }

  @override
  void onError(DioError error, ErrorInterceptorHandler handler) {
    const _statusCodes = [301, 302, 401];
    if(_statusCodes.indexOf(error.response!.statusCode!) != -1) {
      RequestOptions options = error.requestOptions;
      if(DioClient.accessToken != options.headers['Token']) {
        options.headers['Token'] = DioClient.accessToken;
        options.headers['Authorization'] = "Bearer ${DioClient.accessToken}";

        DioClient.dio.fetch(options).then(
          (r) => handler.resolve(r),
          onError: (e) {
            handler.reject(e);
          }
        );
        return;
      }
      DioClient.updateToken(null);

      LoginBloc().relogin().then((value) {
        options.headers['Token'] = DioClient.accessToken;
        options.headers['Authorization'] = "Bearer ${DioClient.accessToken}";
      }).then((value) {
        DioClient.dio.fetch(options).then(
          (r) => handler.resolve(r),
          onError: (e) {
            handler.reject(e);
          }
        );
      });
      return;
    }
    return handler.reject(error);
  }
}