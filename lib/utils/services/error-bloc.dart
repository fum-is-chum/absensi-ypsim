import 'package:rxdart/rxdart.dart';

class ErrorBloc {
  ErrorBloc._sharedInstance();
  static final ErrorBloc _shared = ErrorBloc._sharedInstance();
  factory ErrorBloc() => _shared;

  BehaviorSubject<bool> _tokenExpired = BehaviorSubject.seeded(false);

  void updateState(bool value) {
    _tokenExpired.sink.add(value);
  }

  bool get isTokenExpired => _tokenExpired.value;
}