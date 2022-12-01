import 'package:SIMAt/utils/constants/Theme.dart';
import 'package:flutter/material.dart';

class CardSmall extends StatelessWidget {
  CardSmall(
      {this.title = "Placeholder Title",
      this.cta = "",
      this.img = "assets/img/no-image.jpg",
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
      // fit: FlexFit.tight,
      child: Container(
        constraints: BoxConstraints(
          minHeight: 200
        ),
        height: MediaQuery.of(context).size.width * 0.5,
        margin: EdgeInsets.only(top: 10),
        child: GestureDetector(
          onTap: tap as void Function()?,
          child: Stack(clipBehavior: Clip.antiAlias, children: [
            Card(
              elevation: 1.5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    flex: 3,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(4.0),
                          topRight: Radius.circular(4.0)
                        ),
                        image: DecorationImage(
                          image: (img! as String).substring(0,4) == 'http' ? NetworkImage(img!) : Image.asset(img!).image,
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // SizedBox(height: 8),
                        Text(
                          title!,
                          style: TextStyle(
                            color: MaterialColors.caption,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          cta,
                          style: TextStyle(
                            color: MaterialColors.muted,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 8),
                      ],
                    ),
                  )
                ],
              ),
            ),
            // FractionalTranslation(
            //   translation: Offset(0, -0.3),
            //   child: Align(
            //     alignment: Alignment.topCenter,
            //     child: Container(
            //       height: 360,
            //       width: MediaQuery.of(context).size.width / 2.8,
            //       // padding: EdgeInsets.all(16.0),
            //       decoration: BoxDecoration(
            //         boxShadow: [
            //           BoxShadow(
            //               color: Colors.black.withOpacity(0.06),
            //               spreadRadius: 2,
            //               blurRadius: 1,
            //               offset: Offset(0, 0))
            //         ],
            //         borderRadius: BorderRadius.all(Radius.circular(4.0)),
            //         image: DecorationImage(
            //           image: (img! as String).substring(0,4) == 'http' ? NetworkImage(img!) : Image.asset(img!).image,
            //           fit: BoxFit.fitHeight,
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
          ]),
        ),
      ),
    );
  }
}
