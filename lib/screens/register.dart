import 'package:flutter/material.dart';
import 'package:material_kit_flutter/bloc/register_bloc.dart';
import 'package:material_kit_flutter/constants/Theme.dart';
import 'package:material_kit_flutter/widgets/custom-button.dart';
import 'package:material_kit_flutter/widgets/input.dart';

class Register extends StatelessWidget {
  const Register({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        padding: EdgeInsets.all(20.0),
        decoration: const BoxDecoration(
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
                  Image.asset(
                    "assets/img/logo-ypsim.jpeg",
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
                  Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: Input(
                      placeholder: "Username",
                      focusedBorderColor: MaterialColors.muted,
                    ),
                  ),
                  PasswordField(),
                  Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: CustomButton(
                      text: "Daftar",
                      onClick: () {},
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: CustomButton(
                      text: "Kembali",
                      bgColor: MaterialColors.defaultButton,
                      textColor: Colors.black,
                      onClick: () {
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                    ),
                  ),
                ],
              )
            )

            // Wrap(
            //   alignment: WrapAlignment.center,
            //   children: [
            //     Image.asset(
            //       "assets/img/logo-ypsim.jpeg",
            //       scale: 1.8,
            //     ),
            //     Padding(
            //       padding: EdgeInsets.only(top: 12),
            //       child: Input(
            //         placeholder: "Nomor Induk Pegawai",
            //         focusedBorderColor: MaterialColors.muted,
            //       ),
            //     ),
            //     Padding(
            //       padding: EdgeInsets.only(top: 12),
            //       child: Input(
            //         placeholder: "Username",
            //         focusedBorderColor: MaterialColors.muted,
            //       ),
            //     ),
            //     Padding(
            //       padding: EdgeInsets.only(top: 12),
            //       child: Input(
            //         placeholder: "Kata Sandi",
            //         obscureText: true,
            //         focusedBorderColor: MaterialColors.muted,
            //         suffixIcon: GestureDetector(
            //           onTap: () {},
            //           child: Icon(
            //             Icons.visibility_outlined,
            //             color: MaterialColors.muted,
            //           ),
            //         ),
            //       ),
            //     ),
            //     Padding(
            //       padding: EdgeInsets.only(top: 40),
            //       child: CustomButton(
            //         text: "Daftar",
            //         onClick: () {},
            //       ),
            //     ),
            //     Padding(
            //       padding: EdgeInsets.only(top: 12),
            //       child: CustomButton(
            //         text: "Kembali",
            //         bgColor: MaterialColors.defaultButton,
            //         textColor: Colors.black,
            //         onClick: () {
            //           Navigator.pushReplacementNamed(context, '/login');
            //         },
            //       ),
            //     ),
            //   ],
            // ),
          ),
        ),
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
  final RegisterBloc _bloc = RegisterBloc(true);
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