import 'package:flutter/material.dart';
import 'package:material_kit_flutter/constants/Theme.dart';
import 'package:material_kit_flutter/widgets/custom-button.dart';
import 'package:material_kit_flutter/widgets/input.dart';

class Login extends StatelessWidget {
  const Login({Key? key}) : super(key: key);

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
            padding: EdgeInsets.symmetric(vertical: 50, horizontal: 25),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(12.0)),
            ),
            child: Wrap(
              alignment: WrapAlignment.center,
              children: [
                Image.asset(
                  "assets/img/logo-ypsim.jpeg",
                  scale: 1.8,
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
                    placeholder: "Kata Sandi",
                    obscureText: true,
                    focusedBorderColor: MaterialColors.muted,
                    suffixIcon: GestureDetector(
                      onTap: () {},
                      child: Icon(
                        Icons.visibility_outlined,
                        color: MaterialColors.muted,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      child: Text(
                        "Lupa Kata Sandi?",
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
      ),
    );
  }
}
