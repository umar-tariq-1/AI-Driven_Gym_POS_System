import 'package:flutter/material.dart';
import '../../theme/theme.dart';

class CustomElevatedButton extends StatelessWidget {
  final String buttonText;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double fontSize;
  final double height;
  final double minWidth;
  final double maxWidthScreenFactor;
  final double borderRadius;
  final bool disabled;
  final bool active;
  final Icon? leadingIcon;
  final void Function() onClick;

  const CustomElevatedButton(
      {super.key,
      required this.buttonText,
      required this.onClick,
      this.fontSize = 18.125,
      this.height = 11.75,
      this.minWidth = 140,
      this.maxWidthScreenFactor = 0.95,
      this.active = false,
      this.disabled = false,
      this.leadingIcon,
      this.borderRadius = 10,
      this.backgroundColor,
      this.foregroundColor});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
      padding: const EdgeInsets.all(1.8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius + 2),
        border: Border.all(
          color: active ? Theme.of(context).primaryColor : Colors.transparent,
          width: 2,
        ),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: minWidth,
          maxWidth: screenWidth * maxWidthScreenFactor,
        ),
        child: ElevatedButton(
          style: TextButton.styleFrom(
            backgroundColor: backgroundColor ?? colorScheme.primary,
            foregroundColor: foregroundColor ?? colorScheme.onPrimary,
            padding: EdgeInsets.symmetric(horizontal: 25, vertical: height),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
          onPressed: disabled ? null : () => onClick(),
          child: leadingIcon == null
              ? Text(
                  buttonText,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: "RalewayMedium",
                    fontSize: fontSize,
                    // fontWeight: FontWeight.bold,
                    letterSpacing: 0.25,
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
                        fontFamily: "RalewayMedium",
                        fontSize: fontSize,
                        // fontWeight: FontWeight.bold,
                        letterSpacing: 0.25,
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
