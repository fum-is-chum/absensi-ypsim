import 'package:absensi_ypsim/utils/constants/Theme.dart';
import 'package:flutter/material.dart';

class CardSmall extends StatelessWidget {
  CardSmall(
      {this.title = "Placeholder Title",
      this.cta = "",
      this.img = "https://via.placeholder.com/200",
      this.tap = defaultFunc});

  final String cta;
  final dynamic img;
  final Function tap;
  final String? title;

  static void defaultFunc() {
    print("the function works!");
  }

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.255,
        margin: EdgeInsets.only(top: 10),
        child: GestureDetector(
          onTap: tap as void Function()?,
          child: Stack(clipBehavior: Clip.antiAlias, children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(flex: 2, child: Container()),
                  Flexible(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 8),
                        Text(
                          title!,
                          style: TextStyle(
                            color: MaterialColors.caption,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          cta,
                          style: TextStyle(
                            color: MaterialColors.muted,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            FractionalTranslation(
              translation: Offset(0, -0.15),
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.19,
                  width: MediaQuery.of(context).size.width / 2.5,
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          spreadRadius: 2,
                          blurRadius: 1,
                          offset: Offset(0, 0))
                    ],
                    borderRadius: BorderRadius.all(Radius.circular(4.0)),
                    image: DecorationImage(
                      image: img!.runtimeType.toString() == 'String'? NetworkImage(img!): FileImage(img!) as ImageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
