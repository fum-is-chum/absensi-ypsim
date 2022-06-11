import 'package:rxdart/rxdart.dart';

class RegisterBloc {
  bool state = true;
  late BehaviorSubject<bool> _obscureText$;

  RegisterBloc(this.state){
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