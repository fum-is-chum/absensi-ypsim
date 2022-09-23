import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
// screens
import 'package:material_kit_flutter/screens/home.dart';
import 'package:material_kit_flutter/screens/login-register-verification/screen.dart';
import 'package:material_kit_flutter/screens/pengajuan-izin/pengajuan-izin.dart';
import 'package:material_kit_flutter/screens/profile.dart';
import 'package:material_kit_flutter/screens/riwayat-izin/riwayat-izin.dart';
import 'package:material_kit_flutter/screens/riwayat-presensi/riwayat-presensi-detail.dart';
import 'package:material_kit_flutter/screens/riwayat-presensi/riwayat-presensi.dart';
import 'package:material_kit_flutter/screens/verification.dart';
import 'package:material_kit_flutter/services/hide_keyboard.dart';
import 'package:material_kit_flutter/widgets/spinner.dart';

import 'misc/credential-getter.dart';

void main() {
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
    Map<String, dynamic> data = {
      "id": 39,
      "employee_id": 1,
      "start_date": "2022-09-30",
      "end_date": "2022-09-30",
      "file": "/storage/permission/1_23-09-2022-22-41-54.png",
      "remark": "Urusan pribadi",
      "status": "Menunggu",
      "reason": null,
      "created_at": "2022-09-23T15:41:55.000000Z",
      "updated_at": "2022-09-23T15:41:55.000000Z"
    };
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
              "/pengajuan-izin": (BuildContext context) => PengajuanIzin(),
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
