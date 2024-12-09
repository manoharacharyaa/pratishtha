import 'package:flutter/material.dart';
import 'package:pratishtha/constants/colors.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    this.hintText,
    this.labelText,
    @required this.controller,
    this.prefixIcon,
    this.validator,
    this.isEnabled,
    this.keyboardType,
    this.labelStyle,
    this.onChanged,
    this.obscureText = false,
  });

  final String? hintText;
  final String? labelText;
  final TextEditingController? controller;
  final Widget? prefixIcon;
  final FormFieldValidator? validator;
  final bool? isEnabled;
  final TextInputType? keyboardType;
  final TextStyle? labelStyle;
  final bool? obscureText;
  final Function? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      //margin: EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 3,
          horizontal: 3,
        ),
        child: TextFormField(
          controller: controller,
          validator: validator,
          enabled: isEnabled,
          keyboardType: keyboardType,
          obscureText: obscureText!,
          obscuringCharacter: "*",
          onChanged: onChanged as void Function(String)?,
          decoration: InputDecoration(
            prefixIcon: prefixIcon,
            labelText: labelText,
            hintText: hintText,
            enabled: isEnabled ?? true,
            labelStyle: labelStyle ??
                TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                ),
            hintStyle: TextStyle(color: headline2Color, fontSize: 16),
            border: InputBorder.none,
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(
                color: Colors.black,
                style: BorderStyle.solid,
                width: 1.5,
              ),
            ),
            errorMaxLines: 2,

            // enabledBorder: OutlineInputBorder(
            //   borderRadius: BorderRadius.circular(15),
            //   borderSide: BorderSide(
            //     color: Colors.black.withOpacity(0.2),
            //     style: BorderStyle.solid,
            //     width: 1.5,
            //   ),
            // ),
            /*disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(
                color: Colors.grey.shade200,
                style: BorderStyle.solid,
                width: 1.5,
              ),
            ),*/
          ),
        ),
      ),
    );
  }
}

class CustomTextField1 extends StatelessWidget {
  const CustomTextField1(
      {super.key,
      this.hintText,
      this.labelText,
      @required this.controller,
      this.prefixIcon,
      this.validator,
      this.isEnabled,
      this.keyboardType,
      this.labelStyle,
      this.obscureText = false,
      this.suffix,
      this.onChanged});

  final String? hintText;
  final String? labelText;
  final TextEditingController? controller;
  final Widget? prefixIcon;
  final FormFieldValidator? validator;
  final bool? isEnabled;
  final TextInputType? keyboardType;
  final TextStyle? labelStyle;
  final bool obscureText;
  final Widget? suffix;
  final void Function(String)? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 0,
          horizontal: 20,
        ),
        child: TextFormField(
          controller: controller,
          validator: validator,
          enabled: isEnabled,
          keyboardType: keyboardType,
          obscureText: obscureText,
          onChanged: onChanged,
          decoration: InputDecoration(
            prefixIcon: prefixIcon,
            suffix: suffix,
            labelText: labelText,
            hintText: hintText,
            enabled: isEnabled ?? true,
            labelStyle: labelStyle ??
                TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(
                color: Colors.black.withOpacity(0.2),
                style: BorderStyle.solid,
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(
                color: Colors.black,
                style: BorderStyle.solid,
                width: 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(
                color: Colors.black.withOpacity(0.2),
                style: BorderStyle.solid,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(
                color: Colors.red,
                style: BorderStyle.solid,
                width: 1.5,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(
                color: Colors.grey.shade200,
                style: BorderStyle.solid,
                width: 1.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
