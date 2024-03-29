import 'package:SIMAt/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:SIMAt/utils/constants/Theme.dart';

SpinKitCircle loadingSpinner() {
  return SpinKitCircle(
    color: MaterialColors.newPrimary,
    size: 64,
  );
}

Widget splashScreen(BuildContext context) {
  return Container(
    height: MediaQuery.of(context).size.height,
    width: double.infinity,
    padding: EdgeInsets.all(20.0),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[
          MaterialColors.bgPrimary,
          MaterialColors.bgSecondary,
        ],
        tileMode: TileMode.mirror,
      ),
    ),
    child: Center(
      child: SpinKitCircle(
        color: MaterialColors.bgPrimary,
        size: 64,
      ),
    ),
  );
}

class Spinner {
  BuildContext? dialogContext;
  
  Future<dynamic> show() {
    dialogContext = navigatorKey.currentContext;
    return showGeneralDialog(
      context: dialogContext!,
      pageBuilder: (BuildContext buildContext, Animation<double> animation,
          Animation<double> secondaryAnimation) {
        return loadingSpinner();
      },
      barrierDismissible: false,
      barrierColor: const Color.fromRGBO(0, 0, 0, 0.2),
      transitionDuration: const Duration(milliseconds: 600),
      transitionBuilder: (BuildContext context, Animation<double> animation,
          Animation<double> secondaryAnimation, Widget child) {
        return ScaleTransition(
          alignment: Alignment.center,
          scale: CurvedAnimation(
            parent: animation,
            curve: Interval(
              0.00,
              1.0,
              curve: Curves.easeInOutBack,
            ),
          ),
          child: FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.linear,
            ),
            child: child,
          ),
        );
      },
      // barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    );
  }

  hide() {
    if(dialogContext == null) return;
    Navigator.pop(dialogContext!);
  }
}