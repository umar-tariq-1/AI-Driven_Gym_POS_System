import 'package:flutter/material.dart';

class RoundIconButton extends StatelessWidget {
  final bool disabled;
  final EdgeInsets margin;
  final Widget icon;
  final double size;
  final void Function() onClick;

  const RoundIconButton(
      {super.key,
      required this.onClick,
      this.disabled = false,
      this.margin = const EdgeInsets.all(0),
      required this.icon,
      this.size = 26});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3.5),
          ),
        ],
        color: disabled
            ? const Color.fromARGB(255, 208, 208, 208)
            : Theme.of(context).primaryColor,
      ),
      child: IconButton(
        icon: icon,
        onPressed: disabled ? null : onClick,
        color: disabled
            ? const Color.fromARGB(255, 148, 148, 148)
            : Theme.of(context).colorScheme.secondary,
        iconSize: size,
        padding: const EdgeInsets.all(13),
      ),
    );
  }
}
