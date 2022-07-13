import 'package:flutter/material.dart';

import 'package:material_kit_flutter/constants/Theme.dart';

class HistoryItem extends StatelessWidget {
  HistoryItem(
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
    return Card(
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
            SizedBox(width: 24),
            Container(
              width: MediaQuery.of(context).size.width / 4.5,
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
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
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                status,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  color: status == "Telat" ? Colors.black87 : Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
