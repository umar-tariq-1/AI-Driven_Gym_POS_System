import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:gym_ease/data/secure_storage.dart';
import 'package:gym_ease/main.dart';
import 'package:gym_ease/states/client.dart';
import 'package:gym_ease/states/server_address.dart';
import 'package:gym_ease/theme/theme.dart';
import 'package:gym_ease/widgets/base/app_bar.dart';
import 'package:gym_ease/widgets/base/custom_elevated_button.dart';
import 'package:gym_ease/widgets/base/navigation_drawer.dart';
import 'package:gym_ease/widgets/base/question_card.dart';
import 'package:gym_ease/widgets/base/snackbar.dart';
import 'package:http/http.dart' as http;

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  static const String routePath = '/client/notifications';

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  Map userData = {};
  final serverAddressController = Get.find<ServerAddressController>();
  final clientClassesController = Get.find<ClientController>();
  String? gymNear;
  String? hasPartner;
  bool isLoading = false;
  List clientClassesData = [];
  Map<String, Map<String, String?>> questionnaireResponses = {};

  @override
  void initState() {
    super.initState();
    getUserData();
    fetchData();
  }

  void getUserData() async {
    userData = await SecureStorage().getItem('userData');
  }

  void fetchData() async {
    try {
      setState(() {
        isLoading = true;
      });
      String authToken = await SecureStorage().getItem('authToken');
      final response = await http.get(
          Uri.parse(
              'http://${serverAddressController.IP}:3001/client/classes/registered-classes'),
          headers: {
            'auth-token': authToken,
          });
      if (response.statusCode == 200) {
        setState(() {
          clientClassesData = jsonDecode(response.body)['data'];
        });
        clientClassesController
            .setClassesData(jsonDecode(response.body)['data']);
        SecureStorage()
            .setItem('clientClassesData', jsonDecode(response.body)['data']);
        SecureStorage().setItem('clientClassesDataUserId', userData['id']);
        // print(jsonDecode(response.body)['data'][0]);
      } else {
        CustomSnackbar.showFailureSnackbar(
            context, "Oops!", json.decode(response.body)['message']);
      }
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print(e);
      CustomSnackbar.showFailureSnackbar(
          context, "Oops!", "Sorry, couldn't request to server");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
          title: "Notifications",
          backgroundColor: appBarColor,
          foregroundColor: appBarTextColor),
      drawer: const CustomNavigationDrawer(
        active: 'Notifications',
        accType: "Client",
      ),
      backgroundColor: Colors.grey.shade200,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.info_outline,
                      color: colorScheme.primary, size: 30),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Answer the following questions to help us improve your experience.",
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: 'RalewaySemiBold',
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 12,
              ),
              ...List.generate(clientClassesData.length, (index) {
                final classData = clientClassesData[index];
                final gymName = classData['gymName'];

                questionnaireResponses.putIfAbsent(
                    gymName,
                    () => {
                          'nearLocation': null,
                          'partner': null,
                        });

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    QuestionCard(
                      question: '1. Do you find this gym, $gymName near?',
                      options: const ['Yes', 'No'],
                      groupValue:
                          questionnaireResponses[gymName]!['nearLocation'],
                      onChanged: (val) {
                        setState(() {
                          questionnaireResponses[gymName]!['nearLocation'] =
                              val;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    QuestionCard(
                      question: '2. Do you have a gym partner for $gymName?',
                      options: const ['Yes', 'No'],
                      groupValue: questionnaireResponses[gymName]!['partner'],
                      onChanged: (val) {
                        setState(() {
                          questionnaireResponses[gymName]!['partner'] = val;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    const Divider(thickness: 1),
                    const SizedBox(height: 10),
                  ],
                );
              }),
              const SizedBox(height: 5),
              CustomElevatedButton(
                minWidth: MediaQuery.of(context).size.width - 28,
                buttonText: 'Submit',
                onClick: questionnaireResponses.values.every((resp) =>
                        resp['nearLocation'] != null && resp['partner'] != null)
                    ? () async {
                        final updatedResponses =
                            questionnaireResponses.map((key, value) {
                          return MapEntry(
                            key,
                            value.map((k, v) => MapEntry(
                                k,
                                v == 'Yes'
                                    ? 1
                                    : v == 'No'
                                        ? 0
                                        : v)),
                          );
                        });
                        HapticFeedback.lightImpact();
                        String authToken =
                            await SecureStorage().getItem('authToken');
                        final response = await http.post(
                          Uri.parse(
                              'http://${serverAddressController.IP}:3001/client/client-retention/update-data'),
                          headers: {
                            'auth-token': authToken,
                            'Content-Type': 'application/json',
                          },
                          body: jsonEncode(updatedResponses),
                        );

                        print(response.body);
                      }
                    : () {
                        CustomSnackbar.showFailureSnackbar(context, "Oops!",
                            "Couldn't submit. All answers are required.");
                      },
              ),
              const SizedBox(height: 5),
            ],
          ),
        ),
      ),
    );
  }
}
