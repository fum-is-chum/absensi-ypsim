import 'package:SIMAt/env.dart';
import 'package:flutter/material.dart';
import 'package:SIMAt/screens/login-register-verification/screens/login/bloc/login-bloc.dart';
import 'package:SIMAt/utils/constants/Theme.dart';
import 'package:SIMAt/widgets/custom-button.dart';

late LoginBloc _bloc;
void onSaved(String? val, String field) {
  _bloc.model[field] = val;
}

class LoginView extends StatefulWidget {
  final AnimationController animationController;
  const LoginView({Key? key, required this.animationController})
      : super(key: key);

  @override
  _LoginView createState() => _LoginView();
}

class _LoginView extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _bloc = LoginBloc();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    // _bloc.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final _introductionanimation =
        Tween<Offset>(begin: Offset(0, 0), end: Offset(-1, 0))
            .animate(CurvedAnimation(
      parent: widget.animationController,
      curve: Interval(
        0.0,
        0.2,
        curve: Curves.fastOutSlowIn,
      ),
    ));

    return SlideTransition(
      position: _introductionanimation,
      child: Container(
          height: MediaQuery.of(context).size.height,
          width: double.infinity,
          padding: EdgeInsets.all(20.0),
          child: Center(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 25, horizontal: 25),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(12.0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      spreadRadius: 0,
                      blurRadius: 4,
                      offset: Offset(0, 4), // changes position of shadow
                    ),
                  ]),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        "assets/img/logo-ypsim.jpeg",
                        width: 150, 
                        fit: BoxFit.fitWidth,
                      ),
                      Padding(
                        padding: EdgeInsets.only(top:12),
                        child: Text(
                          "SIMAt" , 
                          style: TextStyle(
                            fontSize: 20.0, 
                            fontWeight: FontWeight.bold,
                            letterSpacing: 5.0,
                          ),
                        )
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: TextFormField(
                          initialValue: Environment.flavor == BuildFlavor.staging ? 'alvinchrist' : '',
                          decoration: InputDecoration(
                            labelText: "Username",
                            isDense: true,
                          ),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return 'Username tidak boleh kosong';
                            }
                            return null;
                          },
                          onSaved: (String? value) =>
                              onSaved(value, 'username'),
                        ),
                      ),
                      PasswordField(),
                      Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            child: Text(
                              "Lupa Kata Sandi?",
                              style: TextStyle(color: MaterialColors.info),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 40),
                        child: CustomButton(
                          text: "Masuk",
                          onClick: () async {
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();
                              if (await _bloc.loginUser())
                                // _formKey.currentState!.reset();
                                Navigator.pushNamedAndRemoveUntil(
                                  context, '/home', (Route<dynamic> route) => false
                                );
                            }
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: CustomButton(
                          text: "Daftar",
                          bgColor: MaterialColors.defaultButton,
                          textColor: Colors.black,
                          onClick: () {
                            widget.animationController.animateTo(0.2);
                            // Navigator.pushReplacementNamed(context, '/register');
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )),
    );
  }
}

class PasswordField extends StatefulWidget {
  // bool initValue;
  PasswordField({Key? key}) : super(key: key);
  @override
  _PasswordField createState() => _PasswordField();
}

class _PasswordField extends State<PasswordField> {

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: _bloc.counterObservable,
      builder: (context, snapshot) {
        // print('password field build');
        return Padding(
          padding: EdgeInsets.only(top: 12),
          child: TextFormField(
            initialValue: Environment.flavor == BuildFlavor.staging ? '12345678' : '',
            decoration: InputDecoration(
              labelText: "Kata Sandi",
              isDense: true,
              suffixIcon: IconButton(
                padding: EdgeInsets.zero,
                icon: snapshot.data ?? true
                    ? const Icon(Icons.visibility_outlined)
                    : const Icon(Icons.visibility_off_outlined),
                color: MaterialColors.muted,
                iconSize: 24,
                onPressed: () {
                  _bloc.toggle();
                },
              )),
            obscureText: snapshot.data ?? true,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (String? value) {
              if (value == null || value.isEmpty)
                return 'Password tidak boleh kosong';
              if (value.length < 8) return 'Password minimal 8 karakter';
              return null;
            },
            onSaved: (String? value) => onSaved(value, 'password'),
          ),
        );
      },
    );
  }
}
