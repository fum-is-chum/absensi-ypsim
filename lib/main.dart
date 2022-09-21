import 'package:flutter/material.dart';
import 'package:material_kit_flutter/screens/Pengajuan-Izin/pengajuan-izin.dart';
import 'package:material_kit_flutter/screens/history-izin/history-izin-detail.dart';
import 'package:material_kit_flutter/screens/history-izin/history-izin.dart';
import 'package:material_kit_flutter/screens/history-presensi/history-presensi-detail.dart';
import 'package:material_kit_flutter/screens/history-presensi/history-presensi.dart';

// screens
import 'package:material_kit_flutter/screens/home.dart';
import 'package:material_kit_flutter/screens/login-register-verification/screen.dart';
import 'package:material_kit_flutter/screens/profile.dart';
import 'package:material_kit_flutter/screens/verification.dart';
import 'package:material_kit_flutter/services/hide_keyboard.dart';
import 'package:material_kit_flutter/widgets/spinner.dart';

import 'misc/credential-getter.dart';

void main() {
  runApp(MaterialKitPROFlutter());
}

Future<String> initialize() async {
  String token = await CredentialGetter().userAccessToken;
  await new Future.delayed(Duration(seconds: 3));
  return token;
}
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MaterialKitPROFlutter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          hideKeyboard(context);
        },
        child: MaterialApp(
            title: "SimLog",
            debugShowCheckedModeBanner: false,
            navigatorKey: navigatorKey,
            routes: <String, WidgetBuilder>{
              "/login": (BuildContext context) => LoginAnimation(),
              "/verification": (BuildContext context) => Verification(),
              "/home": (BuildContext context) => Home(),
              "/history-presensi": (BuildContext context) => History(),
              "/history-presensi-detail": (BuildContext context) => HistoryDetail(),
              "/history-izin": (BuildContext context) => HistoryIzin(),
              "/history-izin-detail": (BuildContext context) =>
                  HistoryIzinDetail(),
              "/request": (BuildContext context) => Request(),
              "/profile": (BuildContext context) => Profile(),
            },
            home: FutureBuilder<String>(
              future: initialize(),
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                if(snapshot.hasData) {
                  if(snapshot.data!.isNotEmpty) 
                    return Home();
                  return LoginAnimation();
                }
                return splashScreen(context);
              }
            ) 
          ));
  }
}
