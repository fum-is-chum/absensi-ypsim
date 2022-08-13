import 'package:flutter/material.dart';
import 'package:material_kit_flutter/bloc/register-bloc.dart';
import 'package:material_kit_flutter/constants/Theme.dart';
import 'package:material_kit_flutter/widgets/custom-button.dart';
import 'package:material_kit_flutter/widgets/input.dart';

import '../../home.dart';

class LoginView extends StatefulWidget {
  final AnimationController animationController;
  const LoginView({Key? key, required this.animationController}): super(key: key);

  @override
  _LoginView createState() => _LoginView();
}

class _LoginView extends State<LoginView> {
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
                      onClick: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(fullscreenDialog: true,
                            builder: (context) => Home(),
                          ),
                        );
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
        // print('password field build');
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