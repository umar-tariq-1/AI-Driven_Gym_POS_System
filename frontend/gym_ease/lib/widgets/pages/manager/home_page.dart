import 'package:flutter/material.dart';
import 'package:gym_ease/main.dart';
import 'package:gym_ease/theme/theme.dart';
import 'package:gym_ease/widgets/base/app_bar.dart';
import 'package:gym_ease/widgets/base/navigation_drawer.dart';

class ManagerHomePage extends StatefulWidget {
  const ManagerHomePage({super.key});

  static const String routePath = '/manager/home';

  @override
  State<ManagerHomePage> createState() => _ManagerHomePageState();
}

class _ManagerHomePageState extends State<ManagerHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar(
            title: "Gym Partner",
            backgroundColor: appBarColor,
            foregroundColor: appBarTextColor),
        drawer: const CustomNavigationDrawer(
          active: 'Home',
          accType: "Manager",
        ),
        backgroundColor: colorScheme.surface,
        body: const SizedBox());
  }
}
