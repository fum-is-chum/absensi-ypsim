import 'package:rxdart/rxdart.dart';

class ErrorBloc {
  ErrorBloc._sharedInstance();
  static final ErrorBloc _shared = ErrorBloc._sharedInstance();
  factory ErrorBloc() => _shared;

  static BehaviorSubject<bool> _tokenExpired = BehaviorSubject.seeded(false);

  static void updateState(bool value) {
    _tokenExpired.sink.add(value);
  }

  static bool get isTokenExpired => _tokenExpired.value;
}