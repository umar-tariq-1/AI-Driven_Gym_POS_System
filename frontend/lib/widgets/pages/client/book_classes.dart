import 'package:flutter/material.dart';
import 'package:frontend/data/secure_storage.dart';
import 'package:frontend/main.dart';
import 'package:frontend/widgets/base/app_bar.dart';
import 'package:frontend/widgets/base/card.dart';
import 'package:frontend/widgets/base/navigation_drawer.dart';

import '../../../../theme/theme.dart';

class BookClassesPage extends StatefulWidget {
  const BookClassesPage({super.key});

  static const routePath = '/client/book-classes';

  @override
  State<BookClassesPage> createState() => _TrainerDashboardPageState();
}

class _TrainerDashboardPageState extends State<BookClassesPage> {
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
          title: "Book Classes",
          backgroundColor: appBarColor,
          foregroundColor: appBarTextColor),
      drawer: const CustomNavigationDrawer(
        active: 'Book Classes',
        accType: "Client",
      ),
      backgroundColor: colorScheme.surface,
      // body: Container(
      //   child: Row(
      //     children: [
      //       // CustomElevatedButton(
      //       //     buttonText: 'Submit', onClick: () {}, active: false),
      //       // CustomOutlinedButton(
      //       //   buttonText: 'Submit',
      //       //   onClick: () {},
      //       // ),
      //     ],
      //   ),
      // ),
      body: const CustomCard(
          imageUrl:
              "https://ik.imagekit.io/umartariq/birdImages/232039681?updatedAt=1721632039855",
          text1: 'Trainer: Umar',
          text2: 'Location: NUST, H-12',
          text3: 'Yoga',
          text4: 'Male only'),
    );
  }
}
