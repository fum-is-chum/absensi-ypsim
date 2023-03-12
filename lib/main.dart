// screens
import 'package:SIMAt/env.dart';
import 'package:SIMAt/screens/ganti-password/ganti-password.dart';
import 'package:SIMAt/screens/home/home.dart';
import 'package:SIMAt/screens/login-register-verification/screen.dart';
import 'package:SIMAt/screens/pengajuan-izin/pengajuan-izin.dart';
import 'package:SIMAt/screens/riwayat-izin/riwayat-izin.dart';
import 'package:SIMAt/screens/riwayat-presensi/riwayat-presensi.dart';
import 'package:SIMAt/screens/verification.dart';
import 'package:SIMAt/utils/services/hide-keyboard.dart';
import 'package:SIMAt/widgets/spinner.dart';
import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:intl/date_symbol_data_local.dart';

import '/utils/misc/credential-getter.dart';
import 'register_web_webview_stub.dart'
    if (dart.library.html) 'register_web_webview.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Environment.init(
    flavor: BuildFlavor.staging,
  );
  registerWebViewWebImplementation();
  // if (!kIsWeb)
  //   checkForUpdates(); // comment line ini jika sedang di test di live server flutter
  initializeDateFormatting('id_ID', null).then((_) => runApp(AbsensiYPSIM()));
}

Future<String> initialize() async {
  await CredentialGetter.init();
  String token = await CredentialGetter.userAccessToken;
  // await new Future.delayed(Duration(seconds: 3));
  // if(kIsWeb) await LocationBloc.init_web();
  return token;
}

Future<void> checkForUpdates() async {
  var updateInfo = await InAppUpdate.checkForUpdate();
  if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
    if (updateInfo.immediateUpdateAllowed) {
      // Perform immediate update
      InAppUpdate.performImmediateUpdate().then((appUpdateResult) {
        if (appUpdateResult == AppUpdateResult.success) {
          //App Update successful
        }
      });
    } else if (updateInfo.flexibleUpdateAllowed) {
      //Perform flexible update
      InAppUpdate.startFlexibleUpdate().then((appUpdateResult) {
        if (appUpdateResult == AppUpdateResult.success) {
          //App Update successful
          InAppUpdate.completeFlexibleUpdate();
        }
      });
    }
  }
}

class AbsensiYPSIM extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          hideKeyboard(context);
        },
        child: MaterialApp(
            title: "SIMAt",
            debugShowCheckedModeBanner: false,
            navigatorKey: navigatorKey,
            // home: TestPage()
            routes: <String, WidgetBuilder>{
              "/login": (BuildContext context) => LoginAnimation(),
              "/verification": (BuildContext context) => Verification(),
              "/home": (BuildContext context) => Home(),
              "/riwayat-presensi": (BuildContext context) => RiwayatPresensi(),
              "/riwayat-izin": (BuildContext context) => RiwayatIzin(),
              "/pengajuan-izin": (BuildContext context) => PengajuanIzin(),
              "/ganti-password": (BuildContext context) => GantiPassword()
            },
            home: FutureBuilder<String>(
                future: initialize(),
                builder:
                    (BuildContext context, AsyncSnapshot<String> snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data!.isNotEmpty) return Home();
                    return LoginAnimation();
                  }
                  return splashScreen(context);
                })));
  }
}
