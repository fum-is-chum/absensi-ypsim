import 'package:SIMAt/main.dart';
import 'package:SIMAt/screens/login-register-verification/screens/login/bloc/login-bloc.dart';
import 'package:SIMAt/utils/misc/credential-getter.dart';
import 'package:SIMAt/utils/services/error-bloc.dart';
import 'package:dio/dio.dart';

import 'dio-interceptor.dart';

class TokenInterceptor extends QueuedInterceptorsWrapper {

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if(options.headers.containsKey("RequireToken")) {
      options.headers.remove("RequireToken");
      String token = await CredentialGetter.userAccessToken;
      options.headers['Authorization'] = "Bearer $token";
    }
    return handler.next(options);
  }

  @override
  void onError(DioError dioError, ErrorInterceptorHandler handler) async {
    const _statusCodes = [301, 302, 401];
    if(!ErrorBloc.isTokenExpired && dioError.response != null && _statusCodes.indexOf(dioError.response!.statusCode!) != -1) { // unauthenticated
      ErrorBloc.updateState(true);
      RequestOptions options = dioError.response!.requestOptions;

      CredentialGetter.reset();
      bool status = await LoginBloc().relogin();
      if(!(status)) {
        navigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (route) => false);
        navigatorKey.currentState?.pushNamed('/login');
      }
      await DioClient.dio.fetch(options).then(
        (r) => handler.resolve(r),
        onError: (e) {
          handler.reject(e);
        },
      );
      ErrorBloc.updateState(false);
      return;
    }
    return handler.next(dioError);
  }
}