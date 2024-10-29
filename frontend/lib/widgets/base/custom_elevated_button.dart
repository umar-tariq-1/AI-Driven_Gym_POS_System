import 'package:flutter/material.dart';

class CustomElevatedButton extends StatelessWidget {
  final String buttonText;
  final double fontSize;
  final double height;
  final double minWidth;
  final double maxWidthScreenFactor;
  final double borderRadius;
  final bool disabled;
  final bool active;
  final Icon? leadingIcon;
  final EdgeInsets margin;
  final void Function(dynamic) onClick;

  const CustomElevatedButton(
      {super.key,
      required this.buttonText,
      required this.onClick,
      this.fontSize = 18.125,
      this.height = 12.75,
      this.minWidth = 140,
      this.maxWidthScreenFactor = 0.95,
      this.active = false,
      this.disabled = false,
      this.margin = const EdgeInsets.all(0),
      this.leadingIcon,
      this.borderRadius = 15});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius + 2),
        border: Border.all(
          color: active ? Theme.of(context).primaryColor : Colors.transparent,
          width: 2,
        ),
      ),
      padding: const EdgeInsets.all(1.8),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: minWidth,
          maxWidth: screenWidth * maxWidthScreenFactor,
        ),
        child: ElevatedButton(
          style: TextButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Theme.of(context).colorScheme.secondary,
            padding: EdgeInsets.symmetric(horizontal: 25, vertical: height),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            overlayColor:
                Theme.of(context).colorScheme.secondary.withOpacity(0.12),
          ),
          onPressed: disabled ? null : () => onClick(buttonText),
          child: leadingIcon == null
              ? Text(
                  buttonText,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                  softWrap: true, // This ensures text wraps within maxWidth
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: leadingIcon,
                    ),
                    Text(
                      buttonText,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                      softWrap: true,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
