import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
// screens
import 'package:absensi_ypsim/screens/home.dart';
import 'package:absensi_ypsim/screens/login-register-verification/screen.dart';
import 'package:absensi_ypsim/screens/pengajuan-izin/pengajuan-izin.dart';
import 'package:absensi_ypsim/screens/riwayat-izin/riwayat-izin.dart';
import 'package:absensi_ypsim/screens/riwayat-presensi/riwayat-presensi-detail.dart';
import 'package:absensi_ypsim/screens/riwayat-presensi/riwayat-presensi.dart';
import 'package:absensi_ypsim/screens/verification.dart';
import 'package:absensi_ypsim/services/hide_keyboard.dart';
import 'package:absensi_ypsim/widgets/spinner.dart';

import 'misc/credential-getter.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  initializeDateFormatting('id_ID', null).then((_) => runApp(MaterialKitPROFlutter()));
}

Future<String> initialize() async {
  await CredentialGetter().init();
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
              "/riwayat-presensi": (BuildContext context) => RiwayatPresensi(),
              "/riwayat-presensi-detail": (BuildContext context) => RiwayatPresensiDetail(),
              "/riwayat-izin": (BuildContext context) => RiwayatIzin(),
              "/pengajuan-izin": (BuildContext context) => PengajuanIzin()
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
