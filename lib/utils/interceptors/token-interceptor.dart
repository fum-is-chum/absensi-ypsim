import 'package:absensi_ypsim/main.dart';
import 'package:absensi_ypsim/screens/login-register-verification/screens/login/bloc/login-bloc.dart';
import 'package:absensi_ypsim/utils/misc/credential-getter.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TokenInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if(options.headers.containsKey("RequireToken")) {
      options.headers.remove("RequireToken");
      String token = await CredentialGetter().userAccessToken;
      options.headers['Authorization'] = "Bearer $token";
    }
    handler.next(options);
  }

  @override
  void onError(DioError dioError, ErrorInterceptorHandler handler) async {
    if(dioError.response != null && dioError.response!.statusCode == 301 || dioError.response!.statusCode == 401) { // unauthenticated
      SharedPreferences sharedPref = await SharedPreferences.getInstance();
      sharedPref.remove('user');
      CredentialGetter().reset();
      if(!(await LoginBloc().relogin())) {
        navigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (route) => false);
        navigatorKey.currentState?.pushNamed('/login');
      }
    }
    super.onError(dioError, handler);
  }
}