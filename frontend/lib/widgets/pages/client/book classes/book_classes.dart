import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/states/client.dart';
import 'package:frontend/states/server_address.dart';
import 'package:frontend/widgets/base/snackbar.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/data/secure_storage.dart';
import 'package:frontend/main.dart';
import 'package:frontend/widgets/base/app_bar.dart';
import 'package:frontend/widgets/base/card.dart';
import 'package:frontend/widgets/base/navigation_drawer.dart';

import '../../../../../theme/theme.dart';

class BookClassesPage extends StatefulWidget {
  const BookClassesPage({super.key});

  static const routePath = '/client/book-classes';

  @override
  State<BookClassesPage> createState() => _BookClassesPageState();
}

class _BookClassesPageState extends State<BookClassesPage> {
  late Map userData;
  String authToken = '';
  final serverAddressController = Get.find<ServerAddressController>();
  final clientClassesController = Get.find<ClientController>();

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
        backgroundColor: colorScheme.surface,
        body: GetBuilder<ClientController>(
          builder: (controller) {
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
                  );
                }).toList(),
              ),
            );
          },
        ));
  }
}
