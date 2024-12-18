import 'package:flutter/material.dart';
import 'package:frontend/data/secure_storage.dart';
import 'package:frontend/main.dart';
import 'package:frontend/states/server_address.dart';
import 'package:frontend/widgets/base/app_bar.dart';
import 'package:frontend/widgets/base/custom_elevated_button.dart';
import 'package:frontend/widgets/base/navigation_drawer.dart';
import 'package:get/get.dart';

import '../../../../theme/theme.dart';

class TrainerDashboardPage extends StatefulWidget {
  const TrainerDashboardPage({super.key});

  static const routePath = '/trainer/dashboard';

  @override
  State<TrainerDashboardPage> createState() => _TrainerDashboardPageState();
}

class _TrainerDashboardPageState extends State<TrainerDashboardPage> {
  late Map userData;
  TextEditingController controller = TextEditingController();
  final serverAddressController = Get.find<ServerAddressController>();

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
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  controller: controller,
                  decoration: InputDecoration(
                    label: const Text('IP'),
                    labelStyle: const TextStyle(
                      overflow: TextOverflow.ellipsis,
                    ),
                    hintText: 'Enter IP',
                    hintStyle: const TextStyle(
                      color: Colors.black26,
                    ),
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.black12,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.black12,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(
                      Icons.email_rounded,
                      color: Colors.black54,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 16),
                  ),
                ),
                const SizedBox(height: 30),
                CustomElevatedButton(
                    buttonText: 'Update IP',
                    onClick: () {
                      serverAddressController.setIP(controller.text);
                      controller.clear();
                    }),
              ],
            ),
          ),
        ));
  }
}
