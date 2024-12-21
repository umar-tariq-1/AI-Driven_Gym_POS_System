// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:frontend/data/secure_storage.dart';
import 'package:frontend/widgets/base/list_tile.dart';
import 'package:frontend/widgets/base/snackbar.dart';
import 'package:frontend/widgets/pages/client/book_classes.dart';
import 'package:frontend/widgets/pages/trainer/create_class.dart';
import 'package:frontend/widgets/pages/trainer/dashboard_page.dart';
import 'package:frontend/widgets/pages/trainer/manage_classes_page.dart';
import 'package:frontend/widgets/pages/welcome_page.dart';
import 'package:frontend/widgets/pages/client/home_page.dart';
import '../../theme/theme.dart';

class CustomNavigationDrawer extends StatelessWidget {
  final String active;
  final String accType;
  const CustomNavigationDrawer(
      {super.key, required this.active, required this.accType});

  @override
  Widget build(BuildContext context) => SizedBox(
      width: 240,
      child: Drawer(
        child: SingleChildScrollView(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                buildHeader(context),
                accType == "Client"
                    ? buildClientMenuItems(context, active)
                    : accType == "Trainer"
                        ? buildTrainerMenuItems(context, active)
                        : (accType == "Owner" || accType == "Manager")
                            ? buildOwnerMenuItems(context, active)
                            : accType == "Admin"
                                ? buildAdminMenuItems(context, active)
                                : const SizedBox()
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

Widget buildClientMenuItems(BuildContext context, active) => Column(
      children: [
        CustomListTile(
            active: active == "Home",
            text: "Home",
            iconData: Icons.home_outlined,
            iconSize: 26.75,
            onTap: () {
              if (ModalRoute.of(context)?.settings.name !=
                  ClientHomePage.routePath) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                    ClientHomePage.routePath, (route) => false);
              }
            }),
        CustomListTile(
            active: active == "Book Classes",
            text: "Book Classes",
            iconData: Icons.receipt_outlined,
            iconSize: 26.75,
            onTap: () {
              if (ModalRoute.of(context)?.settings.name !=
                  CreateClassPage.routePath) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                    ClientHomePage.routePath, (route) => false);
              }
              Navigator.of(context).pushNamed(BookClassesPage.routePath);
            }),
        CustomListTile(
            active: active == "Fitness Plans",
            text: "Fitness Plans",
            iconData: Icons.settings_accessibility_rounded,
            iconSize: 26.75,
            onTap: () {
              if (ModalRoute.of(context)?.settings.name !=
                  ClientHomePage.routePath) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                    ClientHomePage.routePath, (route) => false);
              }
            }),
        CustomListTile(
            active: active == "Live Classes",
            text: "Live Classes",
            iconData: Icons.live_tv_rounded,
            iconSize: 26.75,
            onTap: () {
              if (ModalRoute.of(context)?.settings.name !=
                  ClientHomePage.routePath) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                    ClientHomePage.routePath, (route) => false);
              }
            }),
        CustomListTile(
            active: active == "Payment History",
            text: "Payment History",
            iconData: Icons.payments_outlined,
            iconSize: 26.75,
            onTap: () {
              if (ModalRoute.of(context)?.settings.name !=
                  ClientHomePage.routePath) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                    ClientHomePage.routePath, (route) => false);
              }
            }),
        CustomListTile(
            active: active == "Notifications",
            text: "Notifications",
            iconData: Icons.notifications_rounded,
            iconSize: 26.75,
            onTap: () {
              if (ModalRoute.of(context)?.settings.name !=
                  ClientHomePage.routePath) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                    ClientHomePage.routePath, (route) => false);
              }
            }),
        CustomListTile(
            active: active == "Profile",
            text: "Profile",
            iconData: Icons.account_circle_outlined,
            iconSize: 26.75,
            onTap: () {
              if (ModalRoute.of(context)?.settings.name !=
                  ClientHomePage.routePath) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                    ClientHomePage.routePath, (route) => false);
              }
            }),
        Divider(
          color: Colors.grey.shade700,
        ),
        CustomListTile(
            active: active == "Settings",
            text: "Settings",
            iconData: Icons.settings_sharp,
            iconSize: 26.75,
            onTap: () {
              if (ModalRoute.of(context)?.settings.name !=
                  ClientHomePage.routePath) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                    ClientHomePage.routePath, (route) => false);
              }
            }),
        CustomListTile(
            active: active == "Logout",
            text: "Logout",
            iconData: Icons.logout_outlined,
            onTap: () {
              final secureStorage = SecureStorage();
              secureStorage.setItems(
                  ["isLoggedIn", "tokenExpirationTime", "authToken"],
                  [false, 0, ""]);
              CustomSnackbar.showSuccessSnackbar(
                  context, "Success!", "Logged out Successfully");
              Navigator.of(context).pushNamedAndRemoveUntil(
                  WelcomePage.routePath, (route) => false);
            }),
      ],
    );

Widget buildTrainerMenuItems(BuildContext context, active) => Column(
      children: [
        CustomListTile(
            active: active == "Dashboard",
            text: "Dashboard",
            iconData: Icons.dashboard_rounded,
            iconSize: 26.75,
            onTap: () {
              if (ModalRoute.of(context)?.settings.name !=
                  TrainerDashboardPage.routePath) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                    TrainerDashboardPage.routePath, (route) => false);
              }
            }),
        CustomListTile(
            active: active == "Manage Classes",
            text: "Manage Classes",
            iconData: Icons.class_rounded,
            iconSize: 26.75,
            onTap: () {
              if (ModalRoute.of(context)?.settings.name !=
                  CreateClassPage.routePath) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                    TrainerDashboardPage.routePath, (route) => false);
              }
              Navigator.of(context).pushNamed(ManageClassesPage.routePath);
            }),
        CustomListTile(
            active: active == "Client Progress",
            text: "Client Progress",
            iconData: Icons.settings_accessibility_rounded,
            iconSize: 26.75,
            onTap: () {
              if (ModalRoute.of(context)?.settings.name !=
                  TrainerDashboardPage.routePath) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                    TrainerDashboardPage.routePath, (route) => false);
              }
            }),
        CustomListTile(
            active: active == "Schedule",
            text: "Schedule",
            iconData: Icons.schedule_rounded,
            iconSize: 26.75,
            onTap: () {
              if (ModalRoute.of(context)?.settings.name !=
                  TrainerDashboardPage.routePath) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                    TrainerDashboardPage.routePath, (route) => false);
              }
            }),
        CustomListTile(
            active: active == "Task Manager",
            text: "Task Manager",
            iconData: Icons.task_alt_rounded,
            iconSize: 26.75,
            onTap: () {
              if (ModalRoute.of(context)?.settings.name !=
                  TrainerDashboardPage.routePath) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                    TrainerDashboardPage.routePath, (route) => false);
              }
            }),
        CustomListTile(
            active: active == "Messaging",
            text: "Messaging",
            iconData: Icons.message_rounded,
            iconSize: 26.75,
            onTap: () {
              if (ModalRoute.of(context)?.settings.name !=
                  TrainerDashboardPage.routePath) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                    TrainerDashboardPage.routePath, (route) => false);
              }
            }),
        CustomListTile(
            active: active == "Profile",
            text: "Profile",
            iconData: Icons.account_circle_outlined,
            iconSize: 26.75,
            onTap: () {
              if (ModalRoute.of(context)?.settings.name !=
                  TrainerDashboardPage.routePath) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                    TrainerDashboardPage.routePath, (route) => false);
              }
            }),
        Divider(
          color: Colors.grey.shade700,
        ),
        CustomListTile(
            active: active == "Settings",
            text: "Settings",
            iconData: Icons.settings_sharp,
            iconSize: 26.75,
            onTap: () {
              if (ModalRoute.of(context)?.settings.name !=
                  TrainerDashboardPage.routePath) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                    TrainerDashboardPage.routePath, (route) => false);
              }
            }),
        CustomListTile(
            active: active == "Logout",
            text: "Logout",
            iconData: Icons.logout_outlined,
            onTap: () {
              final secureStorage = SecureStorage();
              secureStorage.setItems(
                  ["isLoggedIn", "tokenExpirationTime", "authToken"],
                  [false, 0, ""]);
              CustomSnackbar.showSuccessSnackbar(
                  context, "Success!", "Logged out Successfully");
              Navigator.of(context).pushNamedAndRemoveUntil(
                  WelcomePage.routePath, (route) => false);
            }),
      ],
    );

Widget buildOwnerMenuItems(BuildContext context, active) => Column(
      children: [
        CustomListTile(
            active: active == "Home",
            text: "Home",
            iconData: Icons.home_outlined,
            iconSize: 26.75,
            onTap: () {
              if (ModalRoute.of(context)?.settings.name !=
                  ClientHomePage.routePath) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                    ClientHomePage.routePath, (route) => false);
              }
            }),
        CustomListTile(
            active: active == "Book Classes",
            text: "Book Classes",
            iconData: Icons.receipt_outlined,
            iconSize: 26.75,
            onTap: () {
              if (ModalRoute.of(context)?.settings.name !=
                  ClientHomePage.routePath) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                    ClientHomePage.routePath, (route) => false);
              }
            }),
        CustomListTile(
            active: active == "Fitness Plans",
            text: "Fitness Plans",
            iconData: Icons.settings_accessibility_rounded,
            iconSize: 26.75,
            onTap: () {
              if (ModalRoute.of(context)?.settings.name !=
                  ClientHomePage.routePath) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                    ClientHomePage.routePath, (route) => false);
              }
            }),
        CustomListTile(
            active: active == "Live Classes",
            text: "Live Classes",
            iconData: Icons.live_tv_rounded,
            iconSize: 26.75,
            onTap: () {
              if (ModalRoute.of(context)?.settings.name !=
                  ClientHomePage.routePath) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                    ClientHomePage.routePath, (route) => false);
              }
            }),
        CustomListTile(
            active: active == "Payment History",
            text: "Payment History",
            iconData: Icons.payments_outlined,
            iconSize: 26.75,
            onTap: () {
              if (ModalRoute.of(context)?.settings.name !=
                  ClientHomePage.routePath) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                    ClientHomePage.routePath, (route) => false);
              }
            }),
        CustomListTile(
            active: active == "Notifications",
            text: "Notifications",
            iconData: Icons.notifications_rounded,
            iconSize: 26.75,
            onTap: () {
              if (ModalRoute.of(context)?.settings.name !=
                  ClientHomePage.routePath) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                    ClientHomePage.routePath, (route) => false);
              }
            }),
        CustomListTile(
            active: active == "Profile",
            text: "Profile",
            iconData: Icons.account_circle_outlined,
            iconSize: 26.75,
            onTap: () {
              if (ModalRoute.of(context)?.settings.name !=
                  ClientHomePage.routePath) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                    ClientHomePage.routePath, (route) => false);
              }
            }),
        Divider(
          color: Colors.grey.shade700,
        ),
        CustomListTile(
            active: active == "Settings",
            text: "Settings",
            iconData: Icons.settings_sharp,
            iconSize: 26.75,
            onTap: () {
              if (ModalRoute.of(context)?.settings.name !=
                  ClientHomePage.routePath) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                    ClientHomePage.routePath, (route) => false);
              }
            }),
        CustomListTile(
            active: active == "Logout",
            text: "Logout",
            iconData: Icons.logout_outlined,
            onTap: () {
              final secureStorage = SecureStorage();
              secureStorage.setItems(
                  ["isLoggedIn", "tokenExpirationTime", "authToken"],
                  [false, 0, ""]);
              CustomSnackbar.showSuccessSnackbar(
                  context, "Success!", "Logged out Successfully");
              Navigator.of(context).pushNamedAndRemoveUntil(
                  WelcomePage.routePath, (route) => false);
            }),
      ],
    );

Widget buildAdminMenuItems(BuildContext context, active) => Column(
      children: [
        CustomListTile(
            active: active == "Home",
            text: "Home",
            iconData: Icons.home_outlined,
            iconSize: 26.75,
            onTap: () {
              if (ModalRoute.of(context)?.settings.name !=
                  ClientHomePage.routePath) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                    ClientHomePage.routePath, (route) => false);
              }
            }),
        CustomListTile(
            active: active == "Book Classes",
            text: "Book Classes",
            iconData: Icons.receipt_outlined,
            iconSize: 26.75,
            onTap: () {
              if (ModalRoute.of(context)?.settings.name !=
                  ClientHomePage.routePath) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                    ClientHomePage.routePath, (route) => false);
              }
            }),
        CustomListTile(
            active: active == "Fitness Plans",
            text: "Fitness Plans",
            iconData: Icons.settings_accessibility_rounded,
            iconSize: 26.75,
            onTap: () {
              if (ModalRoute.of(context)?.settings.name !=
                  ClientHomePage.routePath) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                    ClientHomePage.routePath, (route) => false);
              }
            }),
        CustomListTile(
            active: active == "Live Classes",
            text: "Live Classes",
            iconData: Icons.live_tv_rounded,
            iconSize: 26.75,
            onTap: () {
              if (ModalRoute.of(context)?.settings.name !=
                  ClientHomePage.routePath) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                    ClientHomePage.routePath, (route) => false);
              }
            }),
        CustomListTile(
            active: active == "Payment History",
            text: "Payment History",
            iconData: Icons.payments_outlined,
            iconSize: 26.75,
            onTap: () {
              if (ModalRoute.of(context)?.settings.name !=
                  ClientHomePage.routePath) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                    ClientHomePage.routePath, (route) => false);
              }
            }),
        CustomListTile(
            active: active == "Notifications",
            text: "Notifications",
            iconData: Icons.notifications_rounded,
            iconSize: 26.75,
            onTap: () {
              if (ModalRoute.of(context)?.settings.name !=
                  ClientHomePage.routePath) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                    ClientHomePage.routePath, (route) => false);
              }
            }),
        CustomListTile(
            active: active == "Profile",
            text: "Profile",
            iconData: Icons.account_circle_outlined,
            iconSize: 26.75,
            onTap: () {
              if (ModalRoute.of(context)?.settings.name !=
                  ClientHomePage.routePath) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                    ClientHomePage.routePath, (route) => false);
              }
            }),
        Divider(
          color: Colors.grey.shade700,
        ),
        CustomListTile(
            active: active == "Settings",
            text: "Settings",
            iconData: Icons.settings_sharp,
            iconSize: 26.75,
            onTap: () {
              if (ModalRoute.of(context)?.settings.name !=
                  ClientHomePage.routePath) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                    ClientHomePage.routePath, (route) => false);
              }
            }),
        CustomListTile(
            active: active == "Logout",
            text: "Logout",
            iconData: Icons.logout_outlined,
            onTap: () {
              final secureStorage = SecureStorage();
              secureStorage.setItems(
                  ["isLoggedIn", "tokenExpirationTime", "authToken"],
                  [false, 0, ""]);
              CustomSnackbar.showSuccessSnackbar(
                  context, "Success!", "Logged out Successfully");
              Navigator.of(context).pushNamedAndRemoveUntil(
                  WelcomePage.routePath, (route) => false);
            }),
      ],
    );
