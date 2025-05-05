import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gym_ease/data/secure_storage.dart';
import 'package:gym_ease/main.dart';
import 'package:gym_ease/states/server_address.dart';
import 'package:gym_ease/widgets/base/app_bar.dart';
import 'package:gym_ease/widgets/base/data_box.dart';
import 'package:gym_ease/widgets/base/navigation_drawer.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_charts/charts.dart';

class ClientHomePage extends StatefulWidget {
  const ClientHomePage({super.key});

  static const routePath = '/client/home';

  @override
  State<ClientHomePage> createState() => _ClientHomePageState();
}

class _ClientHomePageState extends State<ClientHomePage> {
  Map userData = {};
  String classesToday = '';
  String registeredClasses = '';
  String upcomingClass = '';
  bool isLoading = false;
  final serverAddressController = Get.find<ServerAddressController>();
  List classesData = [];
  double totalHeldClasses = 0;
  double totalPresent = 0;
  double totalLate = 0;
  List<Color> colors = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple
  ];

  String getTimeUntilNextClass(List<dynamic> data) {
    final now = DateTime.now();

    Duration? minDiff;
    for (var classMap in data) {
      final selectedDays =
          List<bool>.from(jsonDecode(classMap['selectedDays']));
      final startTimeParts = classMap['startTime'].split(':');
      final startDate = DateTime.parse(classMap['startDate']);

      for (int i = 0; i < 7; i++) {
        if (!selectedDays[i]) continue;

        final weekday = i + 1;
        final daysUntil = (weekday - now.weekday + 7) % 7;
        final classDate = DateTime(
          now.year,
          now.month,
          now.day + daysUntil,
          int.parse(startTimeParts[0]),
          int.parse(startTimeParts[1]),
        );

        if (classDate.isBefore(startDate) || classDate.isBefore(now)) continue;

        final diff = classDate.difference(now);
        if (minDiff == null || diff < minDiff) minDiff = diff;
      }
    }

    if (minDiff == null) return 'No class';

    if (minDiff.inDays > 0) return '${minDiff.inDays}d';
    if (minDiff.inHours > 0) return '${minDiff.inHours}h';
    return '${minDiff.inMinutes}m';
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  void getData() async {
    Map userDataCopy = await SecureStorage().getItem('userData');
    String authToken = await SecureStorage().getItem('authToken');
    setState(() {
      userData = userDataCopy;
    });
    final response = await http.get(
        Uri.parse(
            'http://${serverAddressController.IP}:3001/client/classes/home'),
        headers: {
          'auth-token': authToken,
        });
    if (response.statusCode == 200) {
      Map homeData = jsonDecode(response.body);
      setState(() {
        classesData = homeData['data'];
        upcomingClass = getTimeUntilNextClass(classesData);
        registeredClasses = classesData.length.toString();
        classesToday = classesData
            .where((classMap) {
              final selectedDays =
                  List<bool>.from(jsonDecode(classMap['selectedDays']));
              return selectedDays[DateTime.now().weekday - 1];
            })
            .length
            .toString();
        totalHeldClasses = homeData['totalHeldClasses'] + 0.0;
        totalPresent = homeData['totalPresent'] + 0.0;
        totalLate = homeData['totalLate'] + 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar(
            title: "Gym Partner",
            backgroundColor: appBarColor,
            foregroundColor: appBarTextColor),
        drawer: const CustomNavigationDrawer(
          active: 'Home',
          accType: "Client",
        ),
        backgroundColor: Colors.grey.shade200,
        body: SingleChildScrollView(
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
                          fontSize: 22,
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
                        DataBox(
                          color: const Color.fromARGB(255, 23, 100, 163),
                          title: 'Registered Classes',
                          subtitle: registeredClasses,
                        ),
                        const SizedBox(height: 17.5),
                        DataBox(
                          color: const Color.fromARGB(255, 51, 131, 54),
                          title: 'Classes Today',
                          subtitle: classesToday,
                        ),
                        const SizedBox(height: 17.5),
                        DataBox(
                          color: Colors.purple,
                          title:
                              'Upcoming Class ${upcomingClass == 'No class' ? '' : 'In'}',
                          subtitle: upcomingClass,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                  child: Center(
                    child: Container(
                      height: 420,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: SfCircularChart(
                        title: const ChartTitle(
                            text: 'Attendance Status',
                            textStyle: TextStyle(
                                fontSize: 18.5, fontWeight: FontWeight.w700)),
                        legend: const Legend(
                            isVisible: true,
                            overflowMode: LegendItemOverflowMode.wrap,
                            orientation: LegendItemOrientation.auto,
                            shouldAlwaysShowScrollbar: true,
                            alignment: ChartAlignment.center,
                            position: LegendPosition.bottom,
                            isResponsive: true),
                        series: <PieSeries<ChartData, String>>[
                          PieSeries<ChartData, String>(
                            dataSource: [
                              ChartData('Presents', totalPresent, Colors.green),
                              ChartData('Lates', totalLate, Colors.orange),
                              ChartData(
                                  'Absents',
                                  (totalHeldClasses - totalPresent - totalLate),
                                  Colors.red),
                            ],
                            xValueMapper: (ChartData data, _) => data.category,
                            yValueMapper: (ChartData data, _) => data.value,
                            pointColorMapper: (ChartData data, _) => data.color,
                            dataLabelSettings: const DataLabelSettings(
                              isVisible: true,
                              labelPosition: ChartDataLabelPosition.outside,
                              useSeriesColor: true,
                              labelIntersectAction: LabelIntersectAction.shift,
                            ),
                            explode: true,
                            explodeIndex: 0,
                            explodeOffset: '7%',
                            enableTooltip: true,
                          ),
                        ],
                        tooltipBehavior: TooltipBehavior(
                          enable: true,
                          format: 'point.x\npoint.y',
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                classesData.isNotEmpty
                    ? Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        elevation: 4,
                        child: Center(
                          child: Container(
                            height: 430,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: SfCircularChart(
                              title: const ChartTitle(
                                  text: 'Classes Completion Status',
                                  textStyle: TextStyle(
                                      fontSize: 18.5,
                                      fontWeight: FontWeight.w700)),
                              legend: const Legend(
                                  isVisible: true,
                                  overflowMode: LegendItemOverflowMode.wrap,
                                  orientation: LegendItemOrientation.auto,
                                  shouldAlwaysShowScrollbar: true,
                                  position: LegendPosition.bottom,
                                  isResponsive: true),
                              series: <RadialBarSeries<ChartData, String>>[
                                RadialBarSeries<ChartData, String>(
                                  dataSource: List.generate(
                                    classesData.length > 4
                                        ? 4
                                        : classesData.length,
                                    (index) => ChartData(
                                      classesData[index]['className'],
                                      classesData[index]['heldClasses'] *
                                          100 /
                                          classesData[index]['totalClasses'],
                                      colors[index],
                                    ),
                                  ),
                                  xValueMapper: (ChartData data, _) =>
                                      data.category,
                                  yValueMapper: (ChartData data, _) =>
                                      data.value,
                                  cornerStyle: CornerStyle.bothCurve,
                                  gap: '11.5%',
                                  maximumValue: 100,
                                  pointColorMapper: (ChartData data, _) =>
                                      data.color,
                                  dataLabelSettings: const DataLabelSettings(
                                    isVisible: true,
                                    labelPosition:
                                        ChartDataLabelPosition.outside,
                                    textStyle: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  innerRadius: '35%',
                                  radius: '100%',
                                ),
                              ],
                              annotations: const <CircularChartAnnotation>[
                                CircularChartAnnotation(
                                  widget: Text(
                                    'Classes\nCompleted',
                                    style: TextStyle(
                                      color: Color.fromARGB(255, 56, 56, 56),
                                      fontSize: 14,
                                      letterSpacing: 0.125,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                              tooltipBehavior: TooltipBehavior(enable: true),
                            ),
                          ),
                        ),
                      )
                    : const SizedBox(),
              ],
            ),
          ),
        ));
  }
}

class ChartData {
  ChartData(this.category, this.value, this.color);
  final String category;
  final double value;
  final Color color;
}
