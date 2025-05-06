import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gym_ease/data/secure_storage.dart';
import 'package:gym_ease/main.dart';
import 'package:gym_ease/states/server_address.dart';
import 'package:gym_ease/widgets/base/app_bar.dart';
import 'package:gym_ease/widgets/base/data_box.dart';
import 'package:gym_ease/widgets/base/navigation_drawer.dart';

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
    getData();
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
