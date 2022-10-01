import 'package:flutter/material.dart';
import 'package:absensi_ypsim/constants/Theme.dart';
import 'package:absensi_ypsim/screens/riwayat-izin/models/riwayat-izin.dart';
import 'package:absensi_ypsim/services/shared-service.dart';

class RiwayatIzinItem extends StatelessWidget {

  final RiwayatIzinModel item;
  final Function tap;
  
  RiwayatIzinItem({
    required this.item,
    this.tap = defaultFunc
  });

  static void defaultFunc() {
    print("the function works!");
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => tap(),
      child: Card(
        margin: EdgeInsets.only(bottom: 16),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        color: MaterialColors.bgCard,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: Text(
                  formatDateOnly(item.created_at, format: 'EEEE, d MMMM yyyy'),
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 16,),
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
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
                            Text(formatDateOnly(item.start_date, format: 'dd MMM yyyy')),
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
                            Text(formatDateOnly(item.end_date, format: 'dd MMM yyyy')),
                          ],
                        ),
                      ],
                    ),
                    Spacer(),
                    Card(
                      elevation: 1,
                      child: Container(
                        width: 90,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                          boxShadow: [
                            BoxShadow(
                              color: (() {
                                if (item.status == "Ditolak") return MaterialColors.error;
                                if (item.status == "Disetujui") return MaterialColors.bgSecondary;
                                return MaterialColors.bgPrimary;
                              }()),
                              blurRadius: 2.0
                            )
                          ],
                          color: (() {
                            if (item.status == "Menunggu") {
                              return MaterialColors.bgPrimary;
                            } else if (item.status == "Ditolak") {
                              return MaterialColors.error;
                            } else if (item.status == "Disetujui") {
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
                              item.status,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 10,
                                color: item.status == "Pending"
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
              )
            ],
          ),
        ),
      ),
    );
  }
}
