import 'package:flutter/material.dart';
import 'package:frontend/data/secure_storage.dart';
import 'package:frontend/main.dart';
import 'package:frontend/widgets/base/app_bar.dart';
import 'package:frontend/widgets/base/navigation_drawer.dart';

import '../../../../theme/theme.dart';

class ClientHomePage extends StatefulWidget {
  const ClientHomePage({super.key});

  static const routePath = '/client/home';

  @override
  State<ClientHomePage> createState() => _ClientHomePageState();
}

class _ClientHomePageState extends State<ClientHomePage> {
  late Map userData;

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  void getUserData() async {
    userData = await SecureStorage().getItem('userData');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar(
            title: "Gym Partner",
            backgroundColor: appBarColor,
            foregroundColor: appBarTextColor),
        drawer: const CustomNavigationDrawer(
          active: 'Home',
          accType: "Client",
        ),
        backgroundColor: colorScheme.surface,
        body: const SizedBox());
  }
}
