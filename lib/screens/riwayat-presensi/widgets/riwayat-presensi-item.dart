import 'package:SIMAt/screens/riwayat-presensi/models/riwayat-presensi-model.dart';
import 'package:SIMAt/utils/services/shared-service.dart';
import 'package:flutter/material.dart';

import 'package:SIMAt/utils/constants/Theme.dart';

class HistoryPresensiItem extends StatelessWidget {

  final RiwayatPresensiModel item;
  final Function tap;

  HistoryPresensiItem({required this.item, this.tap = defaultFunc});

  static void defaultFunc() {
    print("the function works!");
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
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
                    Text(formatDateOnly(item.date,format: 'EEEE, d MMMM yyyy')),
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
                            Text(item.check_in),
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
                            Text(item.check_out),
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
                              Color color;
                              switch(item.status) {
                                case "Absen": {
                                  color = MaterialColors.error;
                                } break;

                                case "Izin": {
                                  color = MaterialColors.warning;
                                } break;

                                case "Libur": {
                                  color = MaterialColors.muted;
                                } break;
                                  
                                default: {
                                  color = MaterialColors.bgSecondary;
                                } break;
                              }
                              return color;
                            }()),
                            blurRadius: 2.0
                          )
                        ],
                        color: (() {
                          Color color;
                          switch(item.status) {
                            case "Absen": {
                              color = MaterialColors.error;
                            } break;

                            case "Izin": {
                              color = MaterialColors.warning;
                            } break;

                            case "Libur": {
                              color = MaterialColors.muted;
                            } break;
                              
                            default: {
                              color = MaterialColors.bgSecondary;
                            } break;
                          }
                          return color;
                        }()),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        runAlignment: WrapAlignment.center,
                        children: [
                          Text(
                            item.status,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white,
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
