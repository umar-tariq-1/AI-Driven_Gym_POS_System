import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/data/secure_storage.dart';
import 'package:frontend/main.dart';
import 'package:frontend/states/server_address.dart';
import 'package:frontend/states/trainer.dart';
import 'package:frontend/theme/theme.dart';
import 'package:frontend/widgets/base/app_bar.dart';
import 'package:frontend/widgets/base/card.dart';
import 'package:frontend/widgets/base/navigation_drawer.dart';
import 'package:frontend/widgets/base/snackbar.dart';
import 'package:frontend/widgets/pages/trainer/manage%20classes/create_class.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';

class ManageClassesPage extends StatefulWidget {
  static const routePath = '/trainer/manage-classes';

  const ManageClassesPage({super.key});
  @override
  _ManageClassesPageState createState() => _ManageClassesPageState();
}

class _ManageClassesPageState extends State<ManageClassesPage> {
  late Map userData;
  String authToken = '';

  final serverAddressController = Get.find<ServerAddressController>();
  final trainerClassesController = Get.find<TrainerController>();

  @override
  void initState() {
    super.initState();
    getUserData();
    fetchClassesData();
  }

  void getUserData() async {
    userData = await SecureStorage().getItem('userData');
  }

  Future<void> fetchClassesData() async {
    try {
      authToken = await SecureStorage().getItem('authToken');
      final response = await http.get(
          Uri.parse(
              'http://${serverAddressController.IP}:3001/trainer/classes'),
          headers: {
            'auth-token': authToken,
          });
      if (response.statusCode == 200) {
        trainerClassesController
            .setClassesData(jsonDecode(response.body)['data']);
        SecureStorage()
            .setItem('trainerClassesData', jsonDecode(response.body)['data']);
        SecureStorage().setItem('clientClassesDataUserId', userData['id']);
      } else {
        CustomSnackbar.showFailureSnackbar(
            context, "Oops!", json.decode(response.body)['message']);
      }
    } catch (e) {
      CustomSnackbar.showFailureSnackbar(
          context, "Oops!", "Sorry, couldn't request to server");
    }
  }

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
            HapticFeedback.lightImpact();
            Navigator.of(context).pushNamed(CreateClassPage.routePath);
          },
          backgroundColor: colorScheme.inversePrimary,
          child: const Icon(Icons.add_rounded),
        ),
        body: GetBuilder<TrainerController>(builder: (controller) {
          return RefreshIndicator(
            onRefresh: () async {
              HapticFeedback.mediumImpact();
              fetchClassesData();
            },
            backgroundColor: Colors.white,
            child: ListView(
              children: controller.classesData.map((classData) {
                return CustomCard(
                  imageUrl:
                      "https://ik.imagekit.io/umartariq/trainerClassImages/${classData['imageData']['name'] ?? ''}",
                  cost: classData['classFee'] ?? '',
                  location: classData['gymLocation'] ?? '',
                  className: classData['className'] ?? '',
                  classGender: classData['classGender'] ?? '',
                  classData: classData,
                  isTrainer: true,
                );
              }).toList(),
            ),
          );
        }));
  }
}
