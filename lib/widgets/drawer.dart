import 'package:SIMAt/screens/login-register-verification/screens/login/bloc/login-bloc.dart';
import 'package:SIMAt/screens/login-register-verification/screens/login/models/login-result.dart';
import 'package:SIMAt/utils/misc/credential-getter.dart';
// import 'package:url_launcher/url_launcher.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:SIMAt/widgets/drawer-tile.dart';
import 'package:flutter/material.dart';

class MaterialDrawer extends StatelessWidget {
  final String? currentPage;

  MaterialDrawer({this.currentPage});

  @override
  Widget build(BuildContext context) {
    return PointerInterceptor(
        child: Drawer(
      child: Container(
        child: Column(children: [
          SizedBox(
            height: 270,
            child: DrawerHeader(
              child: Container(
                // padding: EdgeInsets.symmetric(horizontal: 28.0),
                child: UserInfo(),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 8),
              children: [
                // Divider(),
                SizedBox(height: 8),
                DrawerTile(
                    icon: Icons.home,
                    onTap: () {
                      if (currentPage != "Home")
                        Navigator.pushReplacementNamed(context, '/home');
                    },
                    iconColor: Colors.black,
                    title: "Home",
                    isSelected: currentPage == "Home" ? true : false),
                DrawerTile(
                    icon: Icons.post_add,
                    onTap: () {
                      if (currentPage != "Pengajuan-Izin")
                        Navigator.pushReplacementNamed(
                            context, '/pengajuan-izin');
                    },
                    iconColor: Colors.black,
                    title: "Pengajuan Izin",
                    isSelected: currentPage == "Pengajuan Izin" ? true : false),
                DrawerTile(
                    icon: Icons.timelapse,
                    onTap: () {
                      if (currentPage != "Riwayat Presensi")
                        Navigator.pushReplacementNamed(
                            context, '/riwayat-presensi');
                    },
                    iconColor: Colors.black,
                    title: "Riwayat Presensi",
                    isSelected:
                        currentPage == "Riwayat Presensi" ? true : false),
                SizedBox(height: 8),
                DrawerTile(
                    icon: Icons.timelapse,
                    onTap: () {
                      if (currentPage != "Riwayat Izin")
                        Navigator.pushReplacementNamed(
                            context, '/riwayat-izin');
                    },
                    iconColor: Colors.black,
                    title: "Riwayat Izin",
                    isSelected: currentPage == "Riwayat Izin" ? true : false),
                SizedBox(height: 8),
                Divider(),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: DrawerTile(
                icon: Icons.logout,
                onTap: () async {
                  if (currentPage != "logout") {
                    await LoginBloc().logoutUser();
                    CredentialGetter.reset();
                    Navigator.pushNamedAndRemoveUntil(
                        context, '/login', (Route<dynamic> route) => false);
                  }
                },
                iconColor: Colors.black,
                title: "Keluar",
                isSelected: currentPage == "logout" ? true : false),
          ),
        ]),
      ),
    ));
  }
}

class UserInfo extends StatefulWidget {
  const UserInfo({Key? key}) : super(key: key);
  @override
  State<UserInfo> createState() => _UserInfo();
}

class _UserInfo extends State<UserInfo> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: CircleAvatar(
            radius: 70,
            backgroundImage: AssetImage("assets/img/logo-ypsim.jpeg"),
          ),
        ),
        FutureBuilder<LoginData>(
            future: CredentialGetter().userData,
            builder: (BuildContext context, AsyncSnapshot<LoginData> snapshot) {
              if (!snapshot.hasData) {
                return Container();
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0, top: 16.0),
                    child: Text(snapshot.data!.nama!,
                        style: TextStyle(color: Colors.black87, fontSize: 21)),
                  ),
                  Row(
                    children: [
                      Text(
                        snapshot.data!.nik!,
                        style: TextStyle(color: Colors.black54, fontSize: 16),
                      ),
                    ],
                  )
                ],
              );
            }),
      ],
    );
  }
}
