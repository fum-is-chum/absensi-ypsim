import 'dart:developer';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthenticatedHttpClient extends http.BaseClient {
  AuthenticatedHttpClient._sharedInstance();
  static final AuthenticatedHttpClient _shared = AuthenticatedHttpClient._sharedInstance();
  factory AuthenticatedHttpClient() => _shared;
  SharedPreferences? sharedPref;

  // Use a memory cache to avoid local storage access in each call
  String _inMemoryToken = '';
  Future<String> get userAccessToken async {
    // use in memory token if available
    if (_inMemoryToken.isNotEmpty) return _inMemoryToken;

    // otherwise load it from local storage
    _inMemoryToken = await _loadTokenFromSharedPreference();

    return _inMemoryToken;
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    // intercept each call and add the Authorization header if token is available
    String token = await userAccessToken;
    if (token.isNotEmpty){
      request.headers.putIfAbsent('Authorization', () => token);
    }
    request.headers.putIfAbsent('Content-Type', () => 'application/json; charset=UTF-8');
    return request.send();
  }

  Future<String> _loadTokenFromSharedPreference() async {
    var accessToken = '';
    if(sharedPref == null) {
      sharedPref = await SharedPreferences.getInstance();
    }
    final dynamic user = sharedPref!.getString('token');

    // If user is already authenticated, we can load his token from cache
    if (user != null) {
      accessToken = user.accessToken;
    }
    return accessToken;
  }

  // Don't forget to reset the cache when logging out the user
  void reset() {
    _inMemoryToken = '';
  }
}