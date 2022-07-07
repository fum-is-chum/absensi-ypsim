import 'package:flutter/material.dart';

// import '../../fitness_app/fitness_app_theme.dart';

class SplashView extends StatefulWidget {
  final AnimationController animationController;

  const SplashView({Key? key, required this.animationController})
      : super(key: key);

  @override
  _SplashViewState createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  Widget build(BuildContext context) {
    final _introductionanimation =
        Tween<Offset>(begin: Offset(0, 0), end: Offset(0.0, -2.0))
            .animate(CurvedAnimation(
      parent: widget.animationController,
      curve: Interval(
        0.0,
        0.2,
        curve: Curves.fastOutSlowIn,
      ),
    ));
    return SlideTransition(
      position: _introductionanimation,
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            // child:Image.asset('assets/images/background.png',fit: BoxFit.fill,),
          ),
          // SvgPicture.asset('assets/images/background.svg', fit: BoxFit.cover),
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: (MediaQuery.of(context).size.height / 2) - 160,
                  ),
                  SizedBox(
                    width: 120.0,
                    // child: Image.asset(
                    //   'assets/fitness_app/soccer_ball.png',
                    //   fit: BoxFit.fitWidth,
                    // ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 16.0, bottom: 8.0),
                    child: Text(
                      "CariLawan.id",
                      // style: FitnessAppTheme.display1
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 64, right: 64),
                    child: Text(
                      "Cari lawan kamu disini",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                        // letterSpacing: -0.05,
                        // color: FitnessAppTheme.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(
                    height: 48,
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 16),
                    child: InkWell(
                      onTap: () {
                        widget.animationController.animateTo(0.2);
                      },
                      child: Container(
                        height: 58,
                        padding: EdgeInsets.only(
                          left: 56.0,
                          right: 56.0,
                          top: 16,
                          bottom: 16,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(38.0),
                          // color: FitnessAppTheme.lightGreen,
                          boxShadow: [
                            BoxShadow(
                              color: Color.fromRGBO(0, 0, 0, .25),
                              blurRadius: 24,
                              spreadRadius: 0,
                              offset: Offset(0, 8)
                            )
                          ]
                        ),
                        child: Text(
                          "Mulai",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            // color: FitnessAppTheme.nearlyWhite,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      )
    );
  }
}
