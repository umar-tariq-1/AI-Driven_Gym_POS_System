import 'package:flutter/material.dart';
import 'package:frontend/main.dart';
import 'package:frontend/widgets/base/app_bar.dart';
import 'package:frontend/widgets/base/navigation_drawer.dart';
import 'package:frontend/widgets/compound/audience.dart';

class ClientLiveClassesPage extends StatefulWidget {
  const ClientLiveClassesPage({super.key});

  static const String routePath = '/client/live_classes';

  @override
  State<ClientLiveClassesPage> createState() => _ClientLiveClassesPageState();
}

class _ClientLiveClassesPageState extends State<ClientLiveClassesPage> {
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
          accType: "Client",
        ),
        backgroundColor: Colors.grey.shade100,
        body: Audience(
          liveId: '',
          userId: '',
          userName: '',
        ));
  }
}
