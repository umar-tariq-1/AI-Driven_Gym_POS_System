// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:frontend/main.dart';
import 'package:frontend/widgets/base/list_tile.dart';
import 'package:frontend/widgets/pages/attempt_quiz.dart';
import 'package:frontend/widgets/pages/edit_quiz.dart';
import 'package:frontend/widgets/pages/new_quiz.dart';
import 'package:frontend/widgets/pages/welcome.dart';

class CustomNavigationDrawer extends StatelessWidget {
  final String active;
  final void Function(String) changePage;
  const CustomNavigationDrawer(
      {super.key, this.active = "", this.changePage = _defaultChangePage});

  static void _defaultChangePage(String page) {}

  @override
  Widget build(BuildContext context) => SizedBox(
      width: 250,
      child: Drawer(
        child: SingleChildScrollView(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                buildHeader(context),
                buildMenuItems(context, active, changePage)
              ]),
        ),
      ));
}

Widget buildHeader(BuildContext context) => Column(
      children: [
        Container(
          height: MediaQuery.of(context).padding.top,
          color: const Color.fromARGB(255, 13, 13, 13),
        ),
        Container(
          alignment: Alignment.center,
          margin: const EdgeInsets.only(bottom: 20),
          height: 68,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).colorScheme.secondary,
                width: 1,
              ),
              top: BorderSide(
                color: Theme.of(context).colorScheme.secondary,
                width: 1,
              ),
              right: BorderSide(
                color: Theme.of(context).colorScheme.secondary,
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
                color: Theme.of(context).colorScheme.secondary,
                fontSize: 23.5,
                letterSpacing: 1.8,
                wordSpacing: 1,
              ),
            ),
          ),
        ),
      ],
    );

Widget buildMenuItems(BuildContext context, active, changePage) => Column(
      children: [
        CustomListTile(
            active: active == "Welcome",
            text: "Welcome Page",
            iconData: Icons.device_unknown_rounded,
            onTap: () {
              if (ModalRoute.of(context)?.settings.name !=
                  WelcomeScreen.routePath) {
                if (ModalRoute.of(context)?.settings.name != MyApp.routePath) {
                  Navigator.of(context).pop();
                }
                Navigator.of(context).popAndPushNamed(WelcomeScreen.routePath);
              }
            }),
        CustomListTile(
            active: active == "New Quiz",
            text: "New Quiz",
            iconData: Icons.add_comment_outlined,
            onTap: () {
              if (ModalRoute.of(context)?.settings.name != NewQuiz.routePath) {
                if (ModalRoute.of(context)?.settings.name != MyApp.routePath) {
                  Navigator.of(context).pop();
                }
                Navigator.of(context).popAndPushNamed(NewQuiz.routePath);
              }
            }),
        CustomListTile(
            active: active == "Attempt Quiz",
            text: "Attempt Quiz",
            iconData: Icons.content_paste_go_sharp,
            onTap: () {
              if (ModalRoute.of(context)?.settings.name !=
                  AttemptQuiz.routePath) {
                Navigator.of(context).popAndPushNamed(AttemptQuiz.routePath);
              }
            }),
        CustomListTile(
            active: active == "Edit Quiz",
            text: "Edit Quiz",
            iconData: Icons.edit_calendar_outlined,
            onTap: () {
              if (ModalRoute.of(context)?.settings.name != EditQuiz.routePath) {
                if (ModalRoute.of(context)?.settings.name != MyApp.routePath) {
                  Navigator.of(context).pop();
                }
                Navigator.of(context).popAndPushNamed(EditQuiz.routePath);
              }
            }),
        const Divider(
          color: Color.fromARGB(255, 10, 10, 10),
        ),
        CustomListTile(
            active: active == "Home Page",
            text: "Home Page",
            iconData: Icons.home_outlined,
            iconSize: 28,
            onTap: () {
              if (ModalRoute.of(context)?.settings.name != MyApp.routePath) {
                Navigator.of(context).pop();
                Navigator.of(context).popAndPushNamed(MyApp.routePath);
              }
            }),
      ],
    );
