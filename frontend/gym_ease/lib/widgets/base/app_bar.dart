import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Color backgroundColor;
  final Color foregroundColor;
  final bool showBackButton;
  final List<Widget>? actions;

  const CustomAppBar(
      {super.key,
      required this.title,
      required this.backgroundColor,
      required this.foregroundColor,
      this.showBackButton = false,
      this.actions});

  @override
  Size get preferredSize => const Size.fromHeight(68);

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: preferredSize,
      child: Container(
        decoration: BoxDecoration(boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3.5),
          ),
        ]),
        child: AppBar(
          toolbarHeight: 68,
          centerTitle: true,
          leading: Builder(
            builder: (context) {
              return Container(
                margin: const EdgeInsets.only(left: 5),
                child: showBackButton
                    ? IconButton(
                        icon: const Icon(Icons.arrow_back_rounded),
                        color: foregroundColor,
                        iconSize: 29,
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      )
                    : IconButton(
                        icon: const Icon(Icons.menu_rounded),
                        color: foregroundColor,
                        iconSize: 29,
                        onPressed: () {
                          Scaffold.of(context).openDrawer();
                        },
                      ),
              );
            },
          ),
          actions: actions,
          title: Text(
            ' $title',
            style: const TextStyle(
              fontFamily: 'BeautifulPeople',
              fontSize: 24,
              letterSpacing: 0.9,
              wordSpacing: 0.6,
            ),
          ),
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
        ),
      ),
    );
  }
}
