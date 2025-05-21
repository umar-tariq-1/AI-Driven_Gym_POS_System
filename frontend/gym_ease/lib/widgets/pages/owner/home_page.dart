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
import 'package:gym_ease/widgets/compound/checkout.dart';
import 'package:http/http.dart' as http;
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

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

  List<Widget> _buildChurnCharts() {
    final churnStats = responseData['churnStats'] ?? {};
    if (churnStats.isEmpty) return [];

    List<Widget> chartWidgets = [];

    churnStats.forEach((gymId, gymData) {
      final classStats = gymData['classes'] ?? {};
      if (classStats.isEmpty) return;

      final gymName = '${gymData['gymName']} Churn Prediction';
      final classList = classStats.entries.toList();
      final PageController _controller = PageController();
      int _currentIndex = 0;

      chartWidgets.add(StatefulBuilder(
        builder: (context, setState) {
          return Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            child: Container(
              height: 415,
              padding: const EdgeInsets.fromLTRB(0, 15, 12.5, 7.5),
              child: Column(
                children: [
                  Container(
                    margin:
                        const EdgeInsets.only(top: 4, bottom: 12, left: 12.5),
                    child: Text(
                      gymName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 21,
                        letterSpacing: 0.3,
                        fontFamily: 'RalewaySemiBold',
                      ),
                    ),
                  ),
                  Expanded(
                    child: PageView.builder(
                      controller: _controller,
                      itemCount: classList.length,
                      onPageChanged: (index) =>
                          setState(() => _currentIndex = index),
                      itemBuilder: (context, index) {
                        final classId = classList[index].key;
                        final classInfo = classList[index].value;
                        final className =
                            classInfo['className'] ?? 'Class $classId';
                        final churn0 = classInfo['churn0'] ?? 0;
                        final churn1 = classInfo['churn1'] ?? 0;

                        return Column(
                          children: [
                            Text(
                              className,
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontFamily: 'RalewaySemiBold',
                                  color: Color.fromARGB(255, 73, 73, 73)),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 250,
                              child: SfCircularChart(
                                series: <DoughnutSeries<ChartData, String>>[
                                  DoughnutSeries<ChartData, String>(
                                    dataSource: [
                                      ChartData(
                                          'Retained', churn0, Colors.green),
                                      ChartData('Churned', churn1, Colors.red),
                                    ],
                                    xValueMapper: (ChartData data, _) =>
                                        data.category,
                                    yValueMapper: (ChartData data, _) =>
                                        data.value,
                                    pointColorMapper: (ChartData data, _) =>
                                        data.color,
                                    innerRadius: '65%',
                                    radius: '75%',
                                    dataLabelSettings: const DataLabelSettings(
                                      isVisible: true,
                                      labelPosition:
                                          ChartDataLabelPosition.outside,
                                      useSeriesColor: true,
                                      labelIntersectAction:
                                          LabelIntersectAction.shift,
                                    ),
                                    explode: true,
                                    explodeIndex: 1,
                                    explodeOffset: '7%',
                                    enableTooltip: true,
                                  ),
                                ],
                                tooltipBehavior: TooltipBehavior(enable: true),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  SmoothPageIndicator(
                    controller: _controller,
                    count: classList.length,
                    effect: ExpandingDotsEffect(
                      dotHeight: 6,
                      dotWidth: 6,
                      spacing: 6,
                      activeDotColor: colorScheme.inversePrimary,
                      dotColor: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 6)
                ],
              ),
            ),
          );
        },
      ));
    });

    return chartWidgets;
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
        backgroundColor: Colors.grey.shade200,
        body: RefreshIndicator(
          triggerMode: RefreshIndicatorTriggerMode.onEdge,
          displacement: 60,
          onRefresh: () async {
            HapticFeedback.mediumImpact();
            fetchData();
          },
          backgroundColor: Colors.white,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(8, 10, 8, 15),
            children: [
              Center(
                  child: Container(
                margin: const EdgeInsets.fromLTRB(0, 15, 0, 22),
                child: Text(
                  "Hi 👋, ${userData.isNotEmpty ? userData['firstName'] : ''} ${userData.isNotEmpty ? userData['lastName'] : ''}!",
                  style: TextStyle(
                    color: Colors.grey.shade800,
                    fontSize: 22.5,
                    fontFamily: 'RalewaySemiBold',
                  ),
                ),
              )),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 17, horizontal: 10),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                        },
                        child: DataBox(
                          color: const Color.fromARGB(255, 23, 100, 163),
                          title: 'My Gyms',
                          subtitle: responseData.isNotEmpty
                              ? responseData['totalGyms'].toString()
                              : '0',
                        ),
                      ),
                      const SizedBox(height: 17.5),
                      DataBox(
                        color: Colors.brown,
                        title: 'Total Clients',
                        subtitle: responseData.isNotEmpty
                            ? responseData['totalClients'].toString()
                            : '0',
                      ),
                      const SizedBox(height: 17.5),
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                        },
                        child: DataBox(
                          color: const Color.fromARGB(255, 51, 131, 54),
                          title: 'Total Classes',
                          subtitle: responseData.isNotEmpty
                              ? responseData['totalClasses'].toString()
                              : '0',
                        ),
                      ),
                      const SizedBox(height: 17.5),
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                        },
                        child: DataBox(
                          color: Colors.purple,
                          title: 'Classes Revenue',
                          subtitle:
                              '\$${responseData.isNotEmpty ? responseData['totalRevenue'].toStringAsFixed(2) : '0'}',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              ..._buildChurnCharts(),
            ],
          ),
        ));
  }
}

class ChartData {
  final String category;
  final num value;
  final Color color;

  ChartData(this.category, this.value, this.color);
}
