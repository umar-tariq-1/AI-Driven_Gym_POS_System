import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gym_ease/data/secure_storage.dart';
import 'package:gym_ease/main.dart';
import 'package:gym_ease/states/server_address.dart';
import 'package:gym_ease/states/trainer.dart';
import 'package:gym_ease/theme/theme.dart';
import 'package:gym_ease/widgets/base/app_bar.dart';
import 'package:gym_ease/widgets/compound/card.dart';
import 'package:gym_ease/widgets/base/navigation_drawer.dart';
import 'package:gym_ease/widgets/base/snackbar.dart';
import 'package:gym_ease/widgets/pages/trainer/manage%20classes/create_class.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';

class ManageClassesPage extends StatefulWidget {
  static const routePath = '/trainer/manage-classes';

  const ManageClassesPage({super.key});
  @override
  _ManageClassesPageState createState() => _ManageClassesPageState();
}

class _ManageClassesPageState extends State<ManageClassesPage> {
  final Random _random = Random();
  String _generateRandomString(int minLength, int maxLength) {
    int length = _random.nextInt(maxLength - minLength + 1) + minLength;
    const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz ';
    return String.fromCharCodes(Iterable.generate(length,
        (_) => characters.codeUnitAt(_random.nextInt(characters.length))));
  }

  late Map userData;
  String authToken = '';
  bool showRedacted = false;
  List<Widget> dummyCards = [];

  final serverAddressController = Get.find<ServerAddressController>();
  final trainerClassesController = Get.find<TrainerController>();

  @override
  void initState() {
    super.initState();
    dummyCards = List.generate(12, (index) {
      return ClassesCard(
        imageUrl:
            "https://storage.googleapis.com/cms-storage-bucket/a9d6ce81aee44ae017ee.png",
        cost: '00.00',
        location: _generateRandomString(10, 13),
        className: _generateRandomString(10, 13),
        classGender: index % 2 == 0 ? 'Female' : 'Male',
        classData: const {},
      );
    });
    getUserData();
    fetchClassesData();
  }

  void getUserData() async {
    userData = await SecureStorage().getItem('userData');
  }

  Future<void> fetchClassesData() async {
    try {
      setState(() {
        showRedacted = true;
      });
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
        SecureStorage().setItem('trainerClassesDataUserId', userData['id']);
      } else {
        CustomSnackbar.showFailureSnackbar(
            context, "Oops!", json.decode(response.body)['message']);
      }
      setState(() {
        showRedacted = false;
      });
    } catch (e) {
      CustomSnackbar.showFailureSnackbar(
          context, "Oops!", "Sorry, couldn't request to server");
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar(
            title: "My Classes",
            backgroundColor: appBarColor,
            foregroundColor: appBarTextColor),
        drawer: const CustomNavigationDrawer(
          active: 'My Classes',
          accType: "Trainer",
        ),
        backgroundColor: Colors.grey.shade100,
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
            triggerMode: RefreshIndicatorTriggerMode.onEdge,
            displacement: 60,
            onRefresh: () async {
              HapticFeedback.mediumImpact();
              fetchClassesData();
            },
            backgroundColor: Colors.white,
            child: !showRedacted
                ? ListView.builder(
                    itemCount: controller.classesData.length,
                    itemBuilder: (context, index) {
                      final classData = controller.classesData[index];
                      return ClassesCard(
                        imageUrl:
                            "https://ik.imagekit.io/umartariq/trainerClassImages/${classData['imageData']['name'] ?? ''}",
                        cost: classData['classFee'] ?? '',
                        location: classData['gymLocation'] ?? '',
                        className: classData['className'] ?? '',
                        classGender: classData['classGender'] ?? '',
                        classData: classData,
                        isTrainer: true,
                      );
                    },
                  )
                : ListView.builder(
                    itemCount: dummyCards.length,
                    itemBuilder: (context, index) {
                      return dummyCards[index];
                    },
                  ),
          );
        }));
  }
}
