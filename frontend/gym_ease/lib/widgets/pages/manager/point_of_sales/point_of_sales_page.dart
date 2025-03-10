import 'package:flutter/material.dart';
import 'package:gym_ease/main.dart';
import 'package:gym_ease/theme/theme.dart';
import 'package:gym_ease/widgets/base/app_bar.dart';
import 'package:gym_ease/widgets/base/navigation_drawer.dart';

class ManagerPointOfSalesPage extends StatefulWidget {
  const ManagerPointOfSalesPage({super.key});

  static const String routePath = '/manager/point-of-sales';

  @override
  State<ManagerPointOfSalesPage> createState() =>
      _ManagerPointOfSalesPageState();
}

class _ManagerPointOfSalesPageState extends State<ManagerPointOfSalesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar(
            title: "POS",
            backgroundColor: appBarColor,
            foregroundColor: appBarTextColor),
        drawer: const CustomNavigationDrawer(
          active: 'Point of Sales',
          accType: "Manager",
        ),
        backgroundColor: colorScheme.surface,
        body: const SizedBox());
  }
}
