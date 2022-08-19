import 'package:flutter/material.dart';
import 'package:material_kit_flutter/screens/Login_Register_Verification/screen.dart';
import 'package:material_kit_flutter/screens/history.dart';
import 'package:material_kit_flutter/screens/history_detail.dart';
import 'package:material_kit_flutter/screens/history_izin.dart';
import 'package:material_kit_flutter/screens/history_izin_detail.dart';
// screens
import 'package:material_kit_flutter/screens/home.dart';
import 'package:material_kit_flutter/screens/profile.dart';
import 'package:material_kit_flutter/screens/register.dart';
import 'package:material_kit_flutter/screens/request.dart';
import 'package:material_kit_flutter/screens/verification.dart';
import 'package:material_kit_flutter/services/hide_keyboard.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialKitPROFlutter());
}

class MaterialKitPROFlutter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          hideKeyboard(context);
        },
        child: MaterialApp(
            title: "Material Kit PRO Flutter",
            debugShowCheckedModeBanner: false,
            initialRoute: "/login",
            routes: <String, WidgetBuilder>{
              "/login": (BuildContext context) => LoginAnimation(),
              "/register": (BuildContext context) => Register(),
              "/verification": (BuildContext context) => Verification(),
              "/home": (BuildContext context) => Home(),
              "/history": (BuildContext context) => History(),
              "/history_detail": (BuildContext context) => HistoryDetail(),
              "/history_izin": (BuildContext context) => HistoryIzin(),
              "/history_izin_detail": (BuildContext context) =>
                  HistoryIzinDetail(),
              "/request": (BuildContext context) => Request(),
              "/profile": (BuildContext context) => Profile(),
              // "/onboarding": (BuildContext context) => Onboarding(),
              // "/pro": (BuildContext context) => Pro(),
              // "/components": (BuildContext context) => Components(),
              // "/settings": (BuildContext context) => Settings(),
            }));
    // return MaterialApp(
    //     title: "Material Kit PRO Flutter",
    //     debugShowCheckedModeBanner: false,
    //     initialRoute: "/request",
    //     routes: <String, WidgetBuilder>{
    //       "/login": (BuildContext context) => LoginAnimation(),
    //       "/register": (BuildContext context) => Register(),
    //       "/verification": (BuildContext context) => Verification(),
    //       "/home": (BuildContext context) => Home(),
    //       "/history": (BuildContext context) => History(),
    //       "/request": (BuildContext context) => Request(),
    //       "/profile": (BuildContext context) => Profile(),
    //       // "/onboarding": (BuildContext context) => Onboarding(),
    //       // "/pro": (BuildContext context) => Pro(),
    //       // "/components": (BuildContext context) => Components(),
    //       // "/settings": (BuildContext context) => Settings(),
    //     });
  }
}
