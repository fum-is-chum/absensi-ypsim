import 'package:flutter/material.dart';
import 'package:material_kit_flutter/constants/Theme.dart';

class CustomButton extends StatelessWidget {
  CustomButton({
    required this.text,
    this.textColor = Colors.white,
    this.bgColor = MaterialColors.success,
    required this.onClick,
  });

  final String text;
  final Color textColor;
  final Color bgColor;
  final Function onClick;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ButtonStyle(
            backgroundColor:
                MaterialStateProperty.resolveWith((states) => bgColor),
            shape: MaterialStateProperty.resolveWith(
                (states) => RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.0),
                    ))),
        onPressed: () {
          onClick();
        },
        child: Padding(
          padding:
              EdgeInsets.only(left: 16.0, right: 16.0, top: 12, bottom: 12),
          child: Text(
            text,
            style: TextStyle(
                color: textColor, fontWeight: FontWeight.w600, fontSize: 16.0),
          ),
        ),
      ),
    );
  }
}
