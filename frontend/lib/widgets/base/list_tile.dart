import 'package:flutter/material.dart';

class CustomListTile extends StatelessWidget {
  final bool active;
  final String text;
  final IconData iconData;
  final VoidCallback onTap;
  final double iconSize;

  const CustomListTile(
      {super.key,
      required this.active,
      required this.text,
      required this.iconData,
      required this.onTap,
      this.iconSize = 26});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 6),
      decoration: active
          ? BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(9999),
                bottomRight: Radius.circular(9999),
              ),
              // boxShadow: [
              //   BoxShadow(
              //     color: Colors.black.withOpacity(0.25),
              //     spreadRadius: 3,
              //     blurRadius: 3,
              //     offset: const Offset(3, 3),
              //   ),
              // ],
            )
          : null,
      child: ListTile(
        leading: Icon(
          iconData,
          color: active
              ? Theme.of(context).colorScheme.secondary
              : Theme.of(context).primaryColor,
          size: iconSize,
        ),
        title: Padding(
            padding: const EdgeInsets.only(left: 7),
            child: Text(
              text,
              style: TextStyle(
                fontFamily: 'RalewayLight',
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: active
                    ? Theme.of(context).colorScheme.secondary
                    : Theme.of(context).primaryColor,
              ),
            )),
        onTap: onTap,
      ),
    );
  }
}
