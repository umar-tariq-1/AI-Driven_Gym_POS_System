// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:frontend/data/local_storage.dart';
import 'package:frontend/data/secure_storage.dart';
import 'package:frontend/widgets/base/list_tile.dart';
import 'package:frontend/widgets/pages/welcome_page.dart';
import 'package:frontend/widgets/pages/home_page.dart';
import '../../theme/theme.dart';

class CustomNavigationDrawer extends StatelessWidget {
  final String active;
  const CustomNavigationDrawer({super.key, this.active = ""});

  @override
  Widget build(BuildContext context) => SizedBox(
      width: 250,
      child: Drawer(
        child: SingleChildScrollView(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                buildHeader(context),
                buildMenuItems(context, active)
              ]),
        ),
      ));
}

Widget buildHeader(BuildContext context) => Column(
      children: [
        Container(
          height: MediaQuery.of(context).padding.top,
          color: const Color.fromARGB(255, 17, 17, 17),
        ),
        Container(
          alignment: Alignment.center,
          margin: const EdgeInsets.only(bottom: 20),
          height: 68,
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 38, 38, 38),
            border: Border(
              bottom: BorderSide(
                color: colorScheme.onPrimary,
                width: 1,
              ),
              top: BorderSide(
                color: colorScheme.onPrimary,
                width: 1,
              ),
              right: BorderSide(
                color: colorScheme.onPrimary,
                width: 1,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3.5),
              ),
            ],
            borderRadius: const BorderRadius.only(
              bottomRight: Radius.circular(10),
            ),
          ),
          child: Container(
            margin: const EdgeInsets.only(top: 7),
            child: Text(
              "Menu",
              style: TextStyle(
                fontFamily: 'BeautifulPeople',
                color: colorScheme.onPrimary,
                fontSize: 23.25,
                letterSpacing: 1.8,
                wordSpacing: 1,
              ),
            ),
          ),
        ),
      ],
    );

Widget buildMenuItems(BuildContext context, active) => Column(
      children: [
        CustomListTile(
            active: active == "Home Page",
            text: "Home Page",
            iconData: Icons.home_outlined,
            iconSize: 26.75,
            onTap: () {
              if (ModalRoute.of(context)?.settings.name != HomePage.routePath) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                    HomePage.routePath, (route) => false);
              }
            }),
        const Divider(
          color: Color.fromARGB(255, 10, 10, 10),
        ),
        CustomListTile(
            active: active == "Logout",
            text: "Logout",
            iconData: Icons.logout_outlined,
            onTap: () {
              final secureStorage = SecureStorage();
              secureStorage.setItems(
                  ["isLoggedIn", "tokenExpirationTime", "authToken"],
                  [false, 0, ""]);
              Navigator.of(context).pushNamedAndRemoveUntil(
                  WelcomePage.routePath, (route) => false);
            }),
      ],
    );
