import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gym_ease/states/client.dart';
import 'package:gym_ease/states/server_address.dart';
import 'package:gym_ease/widgets/base/snackbar.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:gym_ease/data/secure_storage.dart';
import 'package:gym_ease/main.dart';
import 'package:gym_ease/widgets/base/app_bar.dart';
import 'package:gym_ease/widgets/compound/card.dart';
import 'package:gym_ease/widgets/base/navigation_drawer.dart';

class BookClassesPage extends StatefulWidget {
  const BookClassesPage({super.key});

  static const routePath = '/client/book-classes';

  @override
  State<BookClassesPage> createState() => _BookClassesPageState();
}

class _BookClassesPageState extends State<BookClassesPage> {
  final Random _random = Random();
  String _generateRandomString(int minLength, int maxLength) {
    int length = _random.nextInt(maxLength - minLength + 1) + minLength;
    const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz ';
    return String.fromCharCodes(Iterable.generate(length,
        (_) => characters.codeUnitAt(_random.nextInt(characters.length))));
  }

  late Map userData;
  bool showRedacted = false;
  String authToken = '';
  List<Widget> dummyCards = [];

  final serverAddressController = Get.find<ServerAddressController>();
  final clientClassesController = Get.find<ClientController>();

  @override
  void initState() {
    super.initState();
    dummyCards = List.generate(12, (index) {
      return ClassesCard(
        imageUrl:
            "https://storage.googleapis.com/cms-storage-bucket/a9d6ce81aee44ae017ee.png",
        cost: '00.00',
        location: _generateRandomString(12, 16),
        className: _generateRandomString(10, 16),
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
          Uri.parse('http://${serverAddressController.IP}:3001/client/classes'),
          headers: {'auth-token': authToken});
      if (response.statusCode == 200) {
        clientClassesController
            .setClassesData(jsonDecode(response.body)['data']);
        SecureStorage()
            .setItem('clientClassesData', jsonDecode(response.body)['data']);
        SecureStorage().setItem('clientClassesDataUserId', userData['id']);
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
            title: "Book Classes",
            backgroundColor: appBarColor,
            foregroundColor: appBarTextColor),
        drawer: const CustomNavigationDrawer(
          active: 'Book Classes',
          accType: "Client",
        ),
        backgroundColor: Colors.grey.shade100,
        body: GetBuilder<ClientController>(
          builder: (controller) {
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
          },
        ));
  }
}
