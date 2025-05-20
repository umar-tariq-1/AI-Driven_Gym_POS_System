import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:gym_ease/data/secure_storage.dart';
import 'package:gym_ease/main.dart';
import 'package:gym_ease/states/server_address.dart';
import 'package:gym_ease/theme/theme.dart';
import 'package:gym_ease/widgets/base/app_bar.dart';
import 'package:gym_ease/widgets/base/data_box.dart';
import 'package:gym_ease/widgets/base/navigation_drawer.dart';
import 'package:gym_ease/widgets/base/snackbar.dart';
import 'package:http/http.dart' as http;

class OwnerHomePage extends StatefulWidget {
  const OwnerHomePage({super.key});

  static const String routePath = '/owner/home';

  @override
  State<OwnerHomePage> createState() => _OwnerHomePageState();
}

class _OwnerHomePageState extends State<OwnerHomePage> {
  Map userData = {};
  Map responseData = {};
  final serverAddressController = Get.find<ServerAddressController>();
  bool isLoading = false;
  String authToken = '';
  List<Color> colors = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    const Color.fromARGB(255, 180, 51, 202)
  ];
  final PageController _controller = PageController();

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
    authToken = await SecureStorage().getItem('authToken');
    try {
      setState(() {
        isLoading = true;
      });
      final response = await http.get(
          Uri.parse(
              'http://${serverAddressController.IP}:3001/owner/client-retention/'),
          headers: {
            'auth-token': authToken,
          });
      if (response.statusCode == 200) {
        setState(() {
          responseData = json.decode(response.body);
        });
      } else {
        CustomSnackbar.showFailureSnackbar(
            context, "Oops!", json.decode(response.body)['message']);
      }
    } catch (e) {
      print(e);
      CustomSnackbar.showFailureSnackbar(
          context, "Oops!", "Sorry, couldn't request to server");
    }
    setState(() {
      isLoading = false;
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar(
            title: "Gym Partner",
            backgroundColor: appBarColor,
            foregroundColor: appBarTextColor),
        drawer: const CustomNavigationDrawer(
          active: 'Home',
          accType: "Owner",
        ),
        backgroundColor: colorScheme.surface,
        body: RefreshIndicator(
            triggerMode: RefreshIndicatorTriggerMode.onEdge,
            displacement: 60,
            onRefresh: () async {
              HapticFeedback.mediumImpact();
              fetchData();
            },
            backgroundColor: Colors.white,
            // child: const SizedBox()
            child: SingleChildScrollView(
                child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 10, 8, 15),
                    child: Column(
                        // crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                              margin: const EdgeInsets.fromLTRB(0, 15, 0, 22),
                              child: Text(
                                "Hi 👋, ${userData.isNotEmpty ? userData['firstName'] : ''} ${userData.isNotEmpty ? userData['lastName'] : ''}!",
                                style: TextStyle(
                                    color: Colors.grey.shade800,
                                    fontSize: 22.5,
                                    fontFamily: 'RalewaySemiBold'),
                              )),
                          Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            elevation: 4,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 17, horizontal: 10),
                              child: Column(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      HapticFeedback.lightImpact();
                                    },
                                    child: const DataBox(
                                      color: const Color.fromARGB(
                                          255, 23, 100, 163),
                                      title: 'My Gyms',
                                      subtitle: '2',
                                    ),
                                  ),
                                  const SizedBox(height: 17.5),
                                  DataBox(
                                      color: Colors.brown,
                                      title: 'Total Clients',
                                      subtitle:
                                          '3' /* responseData.isNotEmpty
                                          ? responseData['gymData']
                                              .fold<int>(
                                                0,
                                                (sum, item) =>
                                                    sum +
                                                    (item["totalStudents"]
                                                        as int),
                                              )
                                              .toString()
                                          : '0'*/
                                      ),
                                  const SizedBox(height: 17.5),
                                  GestureDetector(
                                    onTap: () {
                                      HapticFeedback.lightImpact();
                                    },
                                    child: const DataBox(
                                      color: const Color.fromARGB(
                                          255, 51, 131, 54),
                                      title: 'Total Classes',
                                      subtitle: '12',
                                    ),
                                  ),
                                  const SizedBox(height: 17.5),
                                  GestureDetector(
                                    onTap: () {
                                      HapticFeedback.lightImpact();
                                      // Navigator.of(context)
                                      //     .pushNamed(TrainerLiveClassesPage.routePath);
                                    },
                                    child: const DataBox(
                                      color: Colors.purple,
                                      title: 'Classes Revenue',
                                      subtitle: '\$4321.5',
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                        ])))));
  }
}
