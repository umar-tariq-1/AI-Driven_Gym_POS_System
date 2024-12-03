import 'package:flutter/material.dart';

class WelcomeButton extends StatefulWidget {
  const WelcomeButton(
      {super.key,
      this.buttonText,
      required this.onTapRoute,
      this.color,
      this.textColor});
  final String? buttonText;
  final String onTapRoute;
  final Color? color;
  final Color? textColor;

  @override
  State<WelcomeButton> createState() => _WelcomeButtonState();
}

class _WelcomeButtonState extends State<WelcomeButton> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(widget.onTapRoute);
      },
      child: Container(
        padding: const EdgeInsets.all(29.0),
        decoration: BoxDecoration(
          // border: Border.all(width: 1, color: colorScheme.primary),
          color: widget.color!,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(50),
          ),
        ),
        child: Text(
          widget.buttonText!,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 21.0,
            // fontWeight: FontWeight.bold,
            color: widget.textColor!,
          ),
        ),
      ),
    );
  }
}
