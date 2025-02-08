import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/data/secure_storage.dart';
import 'package:frontend/main.dart';
import 'package:frontend/states/server_address.dart';
import 'package:frontend/states/trainer.dart';
import 'package:frontend/widgets/base/app_bar.dart';
import 'package:frontend/widgets/base/navigation_drawer.dart';
import 'package:frontend/widgets/base/snackbar.dart';
import 'package:frontend/widgets/compound/broadcaster.dart';
import 'package:frontend/widgets/compound/card.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';

class TrainerLiveClassesPage extends StatefulWidget {
  const TrainerLiveClassesPage({super.key});
  static const routePath = '/trainer/live_classes';
  @override
  State<TrainerLiveClassesPage> createState() => _TrainerLiveClassesPageState();
}

class _TrainerLiveClassesPageState extends State<TrainerLiveClassesPage> {
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
      return /* ClassesCard(
        imageUrl:
            "https://storage.googleapis.com/cms-storage-bucket/a9d6ce81aee44ae017ee.png",
        cost: '00.00',
        location: _generateRandomString(10, 13),
        className: _generateRandomString(10, 13),
        classGender: index % 2 == 0 ? 'Female' : 'Male',
        classData: const {},
      ); */
          LiveStreamingCard(
        imageUrl:
            "https://storage.googleapis.com/cms-storage-bucket/a9d6ce81aee44ae017ee.png",
        className: _generateRandomString(10, 13),
        classData: const {},
        endTime: '12:00',
        startTime: '12:00',
        selectedDays: const [true, true, true, true, true, true, true],
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
        SecureStorage().setItem('clientClassesDataUserId', userData['id']);
        print(jsonDecode(response.body)['data']);
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
    }
  }

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
                      return LiveStreamingCard(
                        selectedDays:
                            jsonDecode(classData['selectedDays']) ?? [],
                        startTime: classData['startTime'] ?? '12:00',
                        endTime: classData['endTime'] ?? '12:00',
                        imageUrl:
                            "https://ik.imagekit.io/umartariq/trainerClassImages/${classData['imageData']['name'] ?? ''}",
                        className: classData['className'] ?? '',
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
