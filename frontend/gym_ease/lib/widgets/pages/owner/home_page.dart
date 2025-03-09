import 'package:flutter/material.dart';
import 'package:gym_ease/main.dart';
import 'package:gym_ease/theme/theme.dart';
import 'package:gym_ease/widgets/base/app_bar.dart';
import 'package:gym_ease/widgets/base/navigation_drawer.dart';

class OwnerHomePage extends StatefulWidget {
  const OwnerHomePage({super.key});

  static const String routePath = '/owner/home';

  @override
  State<OwnerHomePage> createState() => _OwnerHomePageState();
}

class _OwnerHomePageState extends State<OwnerHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar(
            title: "Gym Partner",
            backgroundColor: appBarColor,
            foregroundColor: appBarTextColor),
        drawer: const CustomNavigationDrawer(
          active: 'Home',
          accType: "Owner",
        ),
        backgroundColor: colorScheme.surface,
        body: const SizedBox());
  }
}
