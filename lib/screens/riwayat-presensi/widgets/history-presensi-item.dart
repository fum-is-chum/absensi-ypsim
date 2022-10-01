import 'package:flutter/material.dart';

import 'package:material_kit_flutter/utils/constants/Theme.dart';

class HistoryPresensiItem extends StatelessWidget {
  HistoryPresensiItem(
      {this.date = "Sabtu, 14 Mei 2022",
      this.checkIn = "07:30",
      this.checkOut = "16:30",
      this.status = "Tepat Waktu",
      this.tap = defaultFunc});

  final String date;
  final String checkIn;
  final String checkOut;
  final String status;
  final Function tap;

  static void defaultFunc() {
    print("the function works!");
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => tap(),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          color: MaterialColors.bgCard,
          child: Container(
            padding: EdgeInsets.all(16),
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
                              "Check In",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(checkIn),
                          ],
                        ),
                        SizedBox(width: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Check Out",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(checkOut),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                Spacer(),
                Card(
                  elevation: 1,
                  // shape: RoundedRectangleBorder(
                  //
                  // ),
                  child: Container(
                      width: 90,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                        boxShadow: [
                          BoxShadow(
                            color: (() {
                              if(status == "Absen") return MaterialColors.error;
                              if(status == "Cepat Pulang") return MaterialColors.info;
                              return MaterialColors.bgSecondary;
                            }()),
                            blurRadius: 2.0
                          )
                        ],
                        color: (() {
                          if (status == "Telat") {
                            return MaterialColors.bgPrimary;
                          } else if (status == "Absen") {
                            return MaterialColors.error;
                          } else if (status == "Cepat Pulang") {
                            return MaterialColors.info;
                          } else {
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
                              color: status == "Telat"
                                  ? Colors.black87
                                  : Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
