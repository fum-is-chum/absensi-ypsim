import 'package:flutter/material.dart';

import 'package:material_kit_flutter/constants/Theme.dart';

class HistoryIzinItem extends StatelessWidget {
  HistoryIzinItem(
      {this.date = "Sabtu, 14 Mei 2022",
      this.mulai = "07:30",
      this.selesai = "16:30",
      this.status = "Tepat Waktu",
      this.tap = defaultFunc});

  final String date;
  final String mulai;
  final String selesai;
  final String status;
  final Function tap;

  static void defaultFunc() {
    print("the function works!");
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => tap(),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        color: MaterialColors.bgCard,
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(date),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Mulai",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(mulai),
                        ],
                      ),
                      SizedBox(width: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Selesai",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(selesai),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(width: 24),
              Card(
                elevation: 1,
                // shape: RoundedRectangleBorder(
                //
                // ),
                child: Container(
                    width: 90,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                      color: (() {
                        if (status == "Menunggu") {
                          return MaterialColors.bgPrimary;
                        } else if (status == "Ditolak") {
                          return MaterialColors.error;
                        } else if (status == "Diterima") {
                          return MaterialColors.bgSecondary;
                        }
                      }()),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      runAlignment: WrapAlignment.center,
                      children: [
                        Text(
                          status,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 10,
                            color: status == "Menunggu"
                                ? Colors.black87
                                : Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    )),
              ),
              // Container(
              //   width: MediaQuery.of(context).size.width / 4.5,
              //   padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              //   decoration: BoxDecoration(
              //     boxShadow: [
              //       BoxShadow(
              //         offset: Offset(0,1),
              //         blurRadius: 3,
              //         color: Color.fromRGBO(0, 0, 0, 0.2),
              //       ),
              //       BoxShadow(
              //         offset: Offset(0,2),
              //         blurRadius: 1,
              //         color: Color.fromRGBO(0, 0, 0, 0.12)
              //       ),
              //       BoxShadow(
              //         offset: Offset(0,1),
              //         blurRadius: 1,
              //         color: Color.fromRGBO(0, 0, 0, 0.14)
              //       )
              //     ],
              //     color: (() {
              //       if (status == "Telat") {
              //         return MaterialColors.bgPrimary;
              //       } else if (status == "Absen") {
              //         return MaterialColors.error;
              //       } else if (status == "Cepat Pulang") {
              //         return MaterialColors.info;
              //       } else {
              //         return MaterialColors.bgSecondary;
              //       }
              //     }()),
              //     borderRadius: BorderRadius.circular(4),
              //   ),
              //   child: Text(
              //     status,
              //     textAlign: TextAlign.center,
              //     style: TextStyle(
              //       fontSize: 10,
              //       color: status == "Telat" ? Colors.black87 : Colors.white,
              //       fontWeight: FontWeight.bold,
              //     ),
              //   ),
              // )
            ],
          ),
        ),
      ),
    );
  }
}
