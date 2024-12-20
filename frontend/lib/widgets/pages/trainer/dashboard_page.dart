import 'package:flutter/material.dart';
import 'package:frontend/data/secure_storage.dart';
import 'package:frontend/main.dart';
import 'package:frontend/widgets/base/app_bar.dart';
import 'package:frontend/widgets/base/navigation_drawer.dart';

import '../../../../theme/theme.dart';

class TrainerDashboardPage extends StatefulWidget {
  const TrainerDashboardPage({super.key});

  static const routePath = '/trainer/dashboard';

  @override
  State<TrainerDashboardPage> createState() => _TrainerDashboardPageState();
}

class _TrainerDashboardPageState extends State<TrainerDashboardPage> {
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
          active: 'Dashboard',
          accType: "Trainer",
        ),
        backgroundColor: colorScheme.surface,
        body: const SizedBox());
  }
}
