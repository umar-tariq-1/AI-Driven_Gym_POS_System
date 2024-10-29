import 'package:flutter/material.dart';

class CustomOutlinedButton extends StatelessWidget {
  final String buttonText;
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

  const CustomOutlinedButton({
    super.key,
    required this.buttonText,
    required this.onClick,
    this.fontSize = 17.125,
    this.height = 11,
    this.minWidth = 115,
    this.margin = const EdgeInsets.all(0),
    this.maxWidthScreenFactor = 0.5,
    this.borderRadius = 9,
    this.disabled = false,
    this.leadingIcon,
    this.transitionColor = true,
    this.border = true,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double maxWidth = screenWidth * maxWidthScreenFactor;

    return Container(
      margin: margin,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: minWidth,
          maxWidth: maxWidth,
        ),
        child: OutlinedButton(
          style: ButtonStyle(
            padding: WidgetStateProperty.all(
              EdgeInsets.symmetric(horizontal: 18.885, vertical: height),
            ),
            shape: WidgetStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius),
              ),
            ),
            side: WidgetStateProperty.resolveWith<BorderSide?>(
              (Set<WidgetState> states) {
                if (states.contains(WidgetState.hovered) ||
                    states.contains(WidgetState.pressed)) {
                  return const BorderSide(color: Colors.transparent);
                }
                return BorderSide(
                  color: border
                      ? Theme.of(context).primaryColor
                      : Colors.transparent,
                );
              },
            ),
            foregroundColor: WidgetStateProperty.resolveWith<Color?>(
              (Set<WidgetState> states) {
                if (states.contains(WidgetState.hovered) ||
                    states.contains(WidgetState.pressed)) {
                  return transitionColor
                      ? Theme.of(context).colorScheme.secondary
                      : Theme.of(context).primaryColor;
                }
                return Theme.of(context).primaryColor;
              },
            ),
            backgroundColor: WidgetStateProperty.resolveWith<Color?>(
              (Set<WidgetState> states) {
                if (states.contains(WidgetState.hovered) ||
                    states.contains(WidgetState.pressed)) {
                  return transitionColor
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).colorScheme.secondary;
                }
                return Theme.of(context).colorScheme.secondary;
              },
            ),
            overlayColor: WidgetStateProperty.resolveWith<Color?>(
              (Set<WidgetState> states) {
                if (states.contains(WidgetState.hovered)) {
                  return Theme.of(context).primaryColor.withOpacity(0.04);
                }
                if (states.contains(WidgetState.focused) ||
                    states.contains(WidgetState.pressed)) {
                  return Theme.of(context).primaryColor.withOpacity(0.12);
                }
                return Theme.of(context).primaryColor;
              },
            ),
          ),
          onPressed: disabled ? null : onClick,
          child: leadingIcon == null
              ? Text(
                  buttonText,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.6,
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
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.6,
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
