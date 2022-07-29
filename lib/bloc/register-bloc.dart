import 'package:rxdart/rxdart.dart';

class LoginBloc {
  bool state = true;
  late BehaviorSubject<bool> _obscureText$;

  LoginBloc(this.state){
    _obscureText$ = BehaviorSubject<bool>.seeded(state);
  }

  Stream<bool> get counterObservable {
    return _obscureText$.stream;
  }

  toggle() {
    state = !state;
    _obscureText$.sink.add(state);
  }

  void dispose() {
    _obscureText$.close();
  }
}