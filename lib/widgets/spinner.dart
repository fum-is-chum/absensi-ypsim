import 'package:flutter/cupertino.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../constants/Theme.dart';

SpinKitCircle loadingSpinner() {
  return SpinKitCircle(
    color: MaterialColors.bgSecondary,
    size: 64,
  );
}


class Spinner {
  BuildContext? dialogContext;
  
  Future<dynamic> show({ required BuildContext context }) {
    dialogContext = context;
    return showGeneralDialog(
      context: context,
      pageBuilder: (BuildContext buildContext, Animation<double> animation,
          Animation<double> secondaryAnimation) {
        return loadingSpinner();
      },
      barrierDismissible: false,
      barrierColor: const Color.fromRGBO(0, 0, 0, 0),
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
    while(dialogContext == null) {}
    Navigator.pop(dialogContext!);
  }
}