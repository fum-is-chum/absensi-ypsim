import 'package:absensi_ypsim/main.dart';
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
    // inspect(options);
    handler.next(options);
  }

  @override
  void onError(DioError dioError, ErrorInterceptorHandler handler) async {
    if(dioError.response != null && dioError.response!.statusCode == 401) { // unauthenticated
      SharedPreferences sharedPref = await SharedPreferences.getInstance();
      sharedPref.remove('user');
      CredentialGetter().reset();
      navigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (route) => false);
      navigatorKey.currentState?.pushNamed('/login');
    }
    super.onError(dioError, handler);
  }
}