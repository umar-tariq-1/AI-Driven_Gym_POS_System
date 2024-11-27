import 'package:flutter/material.dart';
import 'package:frontend/theme/theme.dart';

class CustomOutlinedButton extends StatelessWidget {
  final String buttonText;
  final Color? color;
  final double fontSize;
  final double height;
  final double minWidth;
  final EdgeInsets margin;
  final double maxWidthScreenFactor;
  final double borderRadius;
  final bool disabled;
  final Icon? leadingIcon;
  final bool transitionColor;
  final bool border;
  final void Function() onClick;

  const CustomOutlinedButton(
      {super.key,
      required this.buttonText,
      required this.onClick,
      this.fontSize = 18.125,
      this.height = 11.75,
      this.minWidth = 140,
      this.margin = const EdgeInsets.all(0),
      this.maxWidthScreenFactor = 0.95,
      this.borderRadius = 10,
      this.disabled = false,
      this.leadingIcon,
      this.transitionColor = false,
      this.border = true,
      this.color});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double maxWidth = screenWidth * maxWidthScreenFactor;

    return Container(
      margin: margin,
      padding: const EdgeInsets.all(3.8),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: minWidth,
          maxWidth: maxWidth,
        ),
        child: OutlinedButton(
          style: ButtonStyle(
            padding: WidgetStateProperty.all(
              EdgeInsets.symmetric(horizontal: 25, vertical: height),
            ),
            shape: WidgetStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius),
              ),
            ),
            side: WidgetStateProperty.resolveWith<BorderSide?>(
              (Set<WidgetState> states) {
                // if (states.contains(WidgetState.hovered) ||
                //     states.contains(WidgetState.pressed)) {
                //   return const BorderSide(color: Colors.transparent);
                // }
                return BorderSide(
                  color: border
                      ? color ?? colorScheme.primary
                      : Colors.transparent,
                );
              },
            ),
            foregroundColor: WidgetStateProperty.resolveWith<Color?>(
              (Set<WidgetState> states) {
                if (states.contains(WidgetState.hovered) ||
                    states.contains(WidgetState.pressed)) {
                  return transitionColor
                      ? colorScheme.surface
                      : color ?? colorScheme.primary;
                }
                return color ?? colorScheme.primary;
              },
            ),
            backgroundColor: WidgetStateProperty.resolveWith<Color?>(
              (Set<WidgetState> states) {
                if (states.contains(WidgetState.hovered) ||
                    states.contains(WidgetState.pressed)) {
                  return transitionColor
                      ? color ?? colorScheme.primary
                      : Colors.transparent;
                }
                return Colors.transparent;
              },
            ),
            overlayColor: WidgetStateProperty.resolveWith<Color?>(
              (Set<WidgetState> states) {
                if (states.contains(WidgetState.hovered)) {
                  return color != null
                      ? color!.withOpacity(0.05)
                      : colorScheme.primary.withOpacity(0.05);
                }
                if (states.contains(WidgetState.focused) ||
                    states.contains(WidgetState.pressed)) {
                  return color != null
                      ? color!.withOpacity(0.15)
                      : colorScheme.primary.withOpacity(0.15);
                }
                return color ?? colorScheme.primary;
              },
            ),
          ),
          onPressed: disabled ? null : onClick,
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
                  softWrap: true,
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
