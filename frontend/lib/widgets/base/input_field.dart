import 'package:flutter/material.dart';

class CustomInputField extends StatelessWidget {
  final bool password;
  final String label;
  final String placeholder;
  final TextEditingController controller;
  final EdgeInsets margin;
  final Color color;
  final Color textColor;

  const CustomInputField({
    super.key,
    this.password = false,
    this.margin = const EdgeInsets.symmetric(vertical: 4.5, horizontal: 10),
    this.label = '',
    this.placeholder = '',
    required this.controller,
    this.color = const Color.fromARGB(255, 90, 90, 90),
    this.textColor = const Color.fromARGB(255, 10, 10, 10),
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: color,
          selectionColor: textColor.withOpacity(0.3),
          selectionHandleColor: color,
        ),
      ),
      child: Container(
        margin: margin,
        child: SizedBox(
          width: double.infinity,
          height: 56.5,
          child: TextField(
            cursorColor: color,
            obscureText: password,
            cursorWidth: 1.3,
            controller: controller,
            textCapitalization: TextCapitalization.sentences,
            style: TextStyle(
                fontFamily: 'RalewayMedium',
                color: textColor,
                fontSize: 18,
                letterSpacing: 0.1),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderSide: BorderSide(color: color, width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: color, width: 1.2),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: color, width: 2),
              ),
              hintText: placeholder,
              labelText: label,
              labelStyle: TextStyle(
                fontFamily: 'RalewayMedium',
                color: color,
                fontSize: 16.75,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
