import 'package:flutter/material.dart';
import 'package:material_kit_flutter/constants/Theme.dart';

class Input extends StatelessWidget {
  final String? placeholder;
  final bool obscureText;
  final Widget? suffixIcon;
  final BoxConstraints? suffixIconConstraints;
  final Widget? prefixIcon;
  final Function? onTap;
  final Function? onChanged;
  final TextEditingController? controller;
  final bool autofocus;
  final Color borderColor;
  final bool? filled;
  final Color? fillColor;
  final Color textColor;
  final Color enabledBorderColor;
  final Color focusedBorderColor;
  final bool outlineBorder;
  final Color cursorColor;
  final Color hintTextColor;

  Input(
      {this.placeholder,
      this.obscureText = false,
      this.suffixIcon,
      this.prefixIcon,
      this.suffixIconConstraints,
      this.onTap,
      this.filled,
      this.fillColor,
      this.textColor = Colors.black,
      this.enabledBorderColor = MaterialColors.muted,
      this.focusedBorderColor = MaterialColors.primary,
      this.cursorColor = MaterialColors.muted,
      this.hintTextColor = MaterialColors.muted,
      this.onChanged,
      this.outlineBorder = false,
      this.autofocus = false,
      this.borderColor = MaterialColors.border,
      this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
        cursorColor: cursorColor,
        cursorHeight: 14,
        onTap: onTap as void Function()?,
        onChanged: onChanged as void Function(String)?,
        controller: controller,
        autofocus: autofocus,
        obscureText: obscureText,
        style: TextStyle(
          height: 1.0,
          fontSize: 14.0,
          color: textColor,
        ),
        textAlignVertical: TextAlignVertical(y: 0.5),
        decoration: InputDecoration(
            contentPadding: EdgeInsets.only(left: 0, bottom: outlineBorder ? 20 : 16),
            filled: filled,
            fillColor: fillColor,
            hintStyle: TextStyle(
              color: hintTextColor,
            ),
            suffixIcon: suffixIcon,
            suffixIconConstraints: suffixIconConstraints ,
            prefixIcon: prefixIcon,
            enabledBorder: outlineBorder
                ? OutlineInputBorder(
                    borderSide: BorderSide(color: enabledBorderColor))
                : UnderlineInputBorder(
                    borderSide: BorderSide(color: enabledBorderColor)),
            focusedBorder: outlineBorder
                ? OutlineInputBorder(
                    borderSide: BorderSide(color: focusedBorderColor))
                : UnderlineInputBorder(
                    borderSide: BorderSide(color: focusedBorderColor)),
            hintText: placeholder));
  }
}
