import 'package:flutter/material.dart';
import 'package:material_kit_flutter/bloc/login-bloc.dart';
import 'package:material_kit_flutter/constants/Theme.dart';
import 'package:material_kit_flutter/widgets/custom-button.dart';
import 'package:material_kit_flutter/widgets/input.dart';

class Login extends StatelessWidget {
  const Login({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    print('Login build');
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: double.infinity,
        padding: EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              MaterialColors.bgPrimary,
              MaterialColors.bgSecondary,
            ],
            tileMode: TileMode.mirror,
          ),
        ),
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
              ]
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset("assets/img/logo-ypsim.jpeg",
                    width: 200,
                    fit: BoxFit.fitWidth
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: Input(
                      placeholder: "Nomor Induk Pegawai",
                      focusedBorderColor: MaterialColors.muted,
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
                          style: TextStyle(
                            color: MaterialColors.info
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: CustomButton(
                      text: "Masuk",
                      onClick: () {},
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: CustomButton(
                      text: "Daftar",
                      bgColor: MaterialColors.defaultButton,
                      textColor: Colors.black,
                      onClick: () {
                        Navigator.pushReplacementNamed(context, '/register');
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
      ),
    );
  }
}
 

class PasswordField extends StatefulWidget {
  static final GlobalKey<_PasswordField> globalKey = GlobalKey();

  PasswordField({Key? key}) : super(key: globalKey);
  @override
  _PasswordField createState() => _PasswordField();
}

class _PasswordField extends State<PasswordField> {
  final LoginBloc _bloc = LoginBloc(true);
  @override

  void dispose() {
    _bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: _bloc.counterObservable,
      builder: (context, snapshot) {
        print('password field build');
        return Padding(
          padding: EdgeInsets.only(top: 12),
          child: Input(
            placeholder: "Kata Sandi",
            obscureText: snapshot.data ?? true,
            focusedBorderColor: MaterialColors.muted,
            suffixIcon:  IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.visibility_outlined),
              color: MaterialColors.muted,
              onPressed: (){
                _bloc.toggle();
              },
            ),
            suffixIconConstraints: BoxConstraints(maxHeight: 16),
          ),
        );
      },
    );
  }
}