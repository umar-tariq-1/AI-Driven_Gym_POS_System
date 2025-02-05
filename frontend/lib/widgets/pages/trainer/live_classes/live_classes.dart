import 'package:flutter/material.dart';
import 'package:frontend/main.dart';
import 'package:frontend/widgets/base/app_bar.dart';
import 'package:frontend/widgets/base/navigation_drawer.dart';
import 'package:frontend/widgets/compound/broadcaster.dart';

class TrainerLiveClassesPage extends StatefulWidget {
  const TrainerLiveClassesPage({super.key});
  static const routePath = '/trainer/live_classes';
  @override
  State<TrainerLiveClassesPage> createState() => _TrainerLiveClassesPageState();
}

class _TrainerLiveClassesPageState extends State<TrainerLiveClassesPage> {
  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar(
            title: "Live Classes",
            backgroundColor: appBarColor,
            foregroundColor: appBarTextColor),
        drawer: const CustomNavigationDrawer(
          active: 'Live Classes',
          accType: "Trainer",
        ),
        backgroundColor: Colors.grey.shade100,
        body: BroadcasterPage());
  }
}
