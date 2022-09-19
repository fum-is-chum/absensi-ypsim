import 'package:flutter/material.dart';
import 'package:material_kit_flutter/screens/Login_Register_Verification/screens/login.dart';
import 'package:material_kit_flutter/screens/Login_Register_Verification/screens/register.dart';
import 'package:material_kit_flutter/screens/home.dart';

import '../../constants/Theme.dart';
import '../../token-getter.dart';

class LoginAnimation extends StatefulWidget{
  const LoginAnimation({Key? key}): super(key: key);

  @override
  _LoginAnimation createState() => _LoginAnimation();
}

class _LoginAnimation extends State<LoginAnimation> with TickerProviderStateMixin{
  AnimationController? _animationController;
  @override 
  void initState() {
    _animationController = AnimationController(vsync: this, duration: Duration(seconds: 2));
    _animationController?.animateTo(0.0);
    TokenGetter().userAccessToken.then((value) {
      print('TOKEN: $value');
      if(value.isNotEmpty)
        Navigator.pushNamedAndRemoveUntil(
          context, '/home', (Route<dynamic> route) => false
        );
    });
    super.initState();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Container(
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
          ),
          LoginView(animationController: _animationController!),
          RegisterView(animationController: _animationController!)
        ],
      ),
    );
  }

  void home() {
    Navigator.of(context).push(
      MaterialPageRoute(fullscreenDialog: true,
        builder: (context) => Home(),
      ),
    );
  }
}