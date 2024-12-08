import 'package:flutter/material.dart';
import 'package:frontend/main.dart';
import 'package:frontend/widgets/base/navigation_drawer.dart';

import '../../../theme/theme.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  static const routePath = '/main-page';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(68),
          child: Container(
              decoration: BoxDecoration(boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3.5),
                ),
              ]),
              child: AppBar(
                toolbarHeight: 68,
                centerTitle: true,
                leading: Builder(
                  builder: (context) {
                    return Container(
                        margin: const EdgeInsets.only(left: 5),
                        child: IconButton(
                          icon: const Icon(Icons.menu_rounded),
                          color: appBarTextColor,
                          iconSize: 29,
                          onPressed: () {
                            Scaffold.of(context).openDrawer();
                          },
                        ));
                  },
                ),
                title: const Text(
                  " Gym Partner",
                  style: TextStyle(
                    fontFamily: 'BeautifulPeople',
                    fontSize: 25,
                    letterSpacing: 0.9,
                    wordSpacing: 0.6,
                  ),
                ),
                backgroundColor: appBarColor,
                foregroundColor: appBarTextColor,
              ))),
      drawer: const CustomNavigationDrawer(
        active: 'Home Page',
      ),
      backgroundColor: colorScheme.surface,
      body: Container(
        child: Row(
          children: [
            // CustomElevatedButton(
            //     buttonText: 'Submit', onClick: () {}, active: false),
            // CustomOutlinedButton(
            //   buttonText: 'Submit',
            //   onClick: () {},
            // ),
          ],
        ),
      ),
    );
  }
}
