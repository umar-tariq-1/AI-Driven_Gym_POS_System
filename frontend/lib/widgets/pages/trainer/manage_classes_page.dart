import 'package:flutter/material.dart';
import 'package:frontend/main.dart';
import 'package:frontend/theme/theme.dart';
import 'package:frontend/widgets/base/app_bar.dart';
import 'package:frontend/widgets/base/navigation_drawer.dart';
import 'package:frontend/widgets/pages/trainer/create_class.dart';

class ManageClassesPage extends StatefulWidget {
  static const routePath = '/trainer/manage-classes';

  const ManageClassesPage({super.key});
  @override
  _ManageClassesPageState createState() => _ManageClassesPageState();
}

class _ManageClassesPageState extends State<ManageClassesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar(
            title: "Manage Classes",
            backgroundColor: appBarColor,
            foregroundColor: appBarTextColor),
        drawer: const CustomNavigationDrawer(
          active: 'Manage Classes',
          accType: "Trainer",
        ),
        backgroundColor: colorScheme.surface,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).pushNamed(CreateClassPage.routePath);
          },
          backgroundColor: const Color.fromARGB(
              255, 17, 43, 78), // You can change the background color
          child: const Icon(Icons.add_rounded),
        ),
        body: const SizedBox());
  }
}
