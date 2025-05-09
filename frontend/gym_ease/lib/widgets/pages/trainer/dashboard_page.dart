import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:gym_ease/data/secure_storage.dart';
import 'package:gym_ease/main.dart';
import 'package:gym_ease/widgets/base/app_bar.dart';
import 'package:gym_ease/widgets/base/data_box.dart';
import 'package:gym_ease/widgets/base/navigation_drawer.dart';
import 'package:get/get.dart';
import 'package:gym_ease/states/server_address.dart';
import 'package:gym_ease/widgets/pages/trainer/live_classes/live_classes.dart';
import 'package:gym_ease/widgets/pages/trainer/manage%20classes/manage_classes_page.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../../theme/theme.dart';

class TrainerDashboardPage extends StatefulWidget {
  const TrainerDashboardPage({super.key});

  static const routePath = '/trainer/dashboard';

  @override
  State<TrainerDashboardPage> createState() => _TrainerDashboardPageState();
}

class _TrainerDashboardPageState extends State<TrainerDashboardPage> {
  Map userData = {};
  String classesToday = '';
  String registeredClasses = '';
  String upcomingClass = '';
  bool isLoading = false;
  final serverAddressController = Get.find<ServerAddressController>();
  List classesData = [];
  num totalStudents = 0;
  List<Color> colors = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    const Color.fromARGB(255, 180, 51, 202)
  ];
  final PageController _controller = PageController();
  int _currentIndex = 0;

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
    setState(() {
      isLoading = true;
    });
    Map userDataCopy = await SecureStorage().getItem('userData');
    String authToken = await SecureStorage().getItem('authToken');
    setState(() {
      userData = userDataCopy;
    });
    final response = await http.get(
        Uri.parse(
            'http://${serverAddressController.IP}:3001/trainer/classes/dashboard'),
        headers: {
          'auth-token': authToken,
        });
    if (response.statusCode == 200) {
      Map dashboardData = jsonDecode(response.body);
      setState(() {
        classesData = dashboardData['data'];
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
        totalStudents = classesData.fold(
            0, (sum, classData) => sum + (classData['totalStudents'] ?? 0));
      });
    }
    setState(() {
      isLoading = false;
    });
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
        backgroundColor: Colors.grey.shade200,
        body: RefreshIndicator(
          triggerMode: RefreshIndicatorTriggerMode.onEdge,
          displacement: 60,
          onRefresh: () async {
            HapticFeedback.mediumImpact();
            getData();
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
                              Navigator.of(context)
                                  .pushNamed(ManageClassesPage.routePath);
                            },
                            child: DataBox(
                              color: const Color.fromARGB(255, 23, 100, 163),
                              title: 'Total Classes',
                              subtitle: classesData.length.toString(),
                            ),
                          ),
                          const SizedBox(height: 17.5),
                          DataBox(
                            color: Colors.brown,
                            title: 'My Students',
                            subtitle: totalStudents.toString(),
                          ),
                          const SizedBox(height: 17.5),
                          GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              Navigator.of(context)
                                  .pushNamed(TrainerLiveClassesPage.routePath);
                            },
                            child: DataBox(
                              color: const Color.fromARGB(255, 51, 131, 54),
                              title: 'Classes Today',
                              subtitle: classesToday,
                            ),
                          ),
                          const SizedBox(height: 17.5),
                          GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              Navigator.of(context)
                                  .pushNamed(TrainerLiveClassesPage.routePath);
                            },
                            child: DataBox(
                              color: Colors.purple,
                              title:
                                  'Upcoming Class ${upcomingClass == 'No class' ? '' : 'In'}',
                              subtitle: upcomingClass,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                    child: Container(
                        height: 390,
                        padding: const EdgeInsets.fromLTRB(0, 15, 12.5, 7.5),
                        child: isLoading
                            ? Column(
                                children: [
                                  Container(
                                    margin:
                                        const EdgeInsets.only(top: 4, left: 12.5),
                                    child: const Text(
                                      'Past Week Attendances',
                                      style: TextStyle(
                                        fontSize: 22,
                                        letterSpacing: 0.3,
                                        fontFamily: 'RalewaySemiBold',
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const SizedBox(
                                            height: 35,
                                            width: 35,
                                            child: CircularProgressIndicator(
                                                strokeWidth: 3),
                                          ),
                                          Container(
                                            margin: const EdgeInsets.only(top: 9),
                                            child: const Text(
                                              'Loading data...',
                                              style: TextStyle(
                                                color: Color.fromARGB(
                                                    255, 63, 63, 63),
                                                fontSize: 14,
                                                fontFamily: 'RalewayMedium',
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : classesData.isNotEmpty
                                ? Column(
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.only(
                                            top: 4, bottom: 12, left: 12.5),
                                        child: const Text(
                                          'Past week Attendances',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              // wordSpacing: 1.25,
                                              fontSize: 22,
                                              letterSpacing: 0.3,
                                              fontFamily: 'RalewaySemiBold',
                                              color: Color.fromARGB(
                                                  255, 80, 80, 80)),
                                        ),
                                      ),
                                      Expanded(
                                        child: PageView.builder(
                                          controller: _controller,
                                          itemCount: classesData.length,
                                          onPageChanged: (index) => setState(
                                              () => _currentIndex = index),
                                          itemBuilder: (context, index) {
                                            final classData = classesData[index];
                                            return SfCartesianChart(
                                              legend: const Legend(
                                                isVisible: true,
                                                position: LegendPosition.bottom,
                                                overflowMode:
                                                    LegendItemOverflowMode.wrap,
                                              ),
                                              trackballBehavior:
                                                  TrackballBehavior(
                                                enable: true,
                                                activationMode:
                                                    ActivationMode.singleTap,
                                                tooltipSettings:
                                                    const InteractiveTooltip(
                                                  enable: true,
                                                  format:
                                                      'point.y Students Attended',
                                                ),
                                              ),
                                              primaryXAxis: const CategoryAxis(
                                                title: AxisTitle(text: 'Days'),
                                                majorGridLines:
                                                    MajorGridLines(width: 0),
                                                labelRotation: 15,
                                                labelPlacement:
                                                    LabelPlacement.onTicks,
                                              ),
                                              primaryYAxis: NumericAxis(
                                                maximum:
                                                    classData['totalStudents'] +
                                                        0.0,
                                                title: const AxisTitle(
                                                    text: 'Students Attended'),
                                                axisLine:
                                                    const AxisLine(width: 0),
                                                labelFormat: '{value}',
                                                majorGridLines:
                                                    const MajorGridLines(
                                                        width: 0),
                                              ),
                                              series: <CartesianSeries>[
                                                LineSeries<GraphData, String>(
                                                  name: classData['className'],
                                                  dataSource: classData[
                                                          'lastSevenDaysAtt']
                                                      .map<GraphData>((dayData) =>
                                                          GraphData(
                                                              dayData['day'],
                                                              dayData['value'] +
                                                                  0.0))
                                                      .toList(),
                                                  xValueMapper:
                                                      (GraphData sales, _) =>
                                                          sales.month,
                                                  yValueMapper:
                                                      (GraphData sales, _) =>
                                                          sales.sales,
                                                  color: colorScheme.primary,
                                                  width: 2,
                                                  dataLabelSettings:
                                                      const DataLabelSettings(
                                                          isVisible: false),
                                                  markerSettings:
                                                      const MarkerSettings(
                                                    isVisible: true,
                                                    shape: DataMarkerType.circle,
                                                    height: 8,
                                                    width: 8,
                                                  ),
                                                  animationDuration: 1500,
                                                  enableTooltip: true,
                                                ),
                                              ],
                                            );
                                          },
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      SmoothPageIndicator(
                                        controller: _controller,
                                        count: classesData.length,
                                        effect: WormEffect(
                                          dotHeight: 10,
                                          dotWidth: 10,
                                          spacing: 8,
                                          activeDotColor:
                                              colorScheme.inversePrimary,
                                          dotColor: Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                    ],
                                  )
                                : Column(
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.only(top: 12),
                                        child: const Text(
                                          'Attendance Status',
                                          style: TextStyle(
                                            fontSize: 22,
                                            letterSpacing: 0.3,
                                            fontFamily: 'RalewaySemiBold',
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Center(
                                          child: Container(
                                            margin: const EdgeInsets.only(top: 9),
                                            child: const Text(
                                              'No data to display',
                                              style: TextStyle(
                                                color: Color.fromARGB(
                                                    255, 63, 63, 63),
                                                fontSize: 15,
                                                fontFamily: 'RalewayMedium',
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )),
                  ),
                  // const SizedBox(height: 10),
                  // Card(
                  //   shape: RoundedRectangleBorder(
                  //       borderRadius: BorderRadius.circular(16)),
                  //   elevation: 4,
                  //   child: Container(
                  //       height: 380,
                  //       padding: const EdgeInsets.symmetric(vertical: 10),
                  //       child: isLoading
                  //           ? Column(
                  //               children: [
                  //                 Container(
                  //                   margin: const EdgeInsets.only(top: 12),
                  //                   child: const Text(
                  //                     'Attendance Status',
                  //                     style: TextStyle(
                  //                       fontSize: 22,
                  //                       letterSpacing: 0.3,
                  //                       fontFamily: 'RalewaySemiBold',
                  //                     ),
                  //                   ),
                  //                 ),
                  //                 Expanded(
                  //                   child: Center(
                  //                     child: Column(
                  //                       mainAxisSize: MainAxisSize.min,
                  //                       mainAxisAlignment:
                  //                           MainAxisAlignment.center,
                  //                       children: [
                  //                         const SizedBox(
                  //                           height: 35,
                  //                           width: 35,
                  //                           child: CircularProgressIndicator(
                  //                               strokeWidth: 3),
                  //                         ),
                  //                         Container(
                  //                           margin: const EdgeInsets.only(top: 9),
                  //                           child: const Text(
                  //                             'Loading data...',
                  //                             style: TextStyle(
                  //                               color: Color.fromARGB(
                  //                                   255, 63, 63, 63),
                  //                               fontSize: 14,
                  //                               fontFamily: 'RalewayMedium',
                  //                             ),
                  //                           ),
                  //                         ),
                  //                       ],
                  //                     ),
                  //                   ),
                  //                 ),
                  //               ],
                  //             )
                  //           : classesData.isNotEmpty
                  //               ? SfCircularChart(
                  //                   title: const ChartTitle(
                  //                     text: 'Attendance Status',
                  //                     textStyle: TextStyle(
                  //                       fontSize: 17,
                  //                       fontFamily: 'RalewaySemiBold',
                  //                     ),
                  //                   ),
                  //                   legend: const Legend(
                  //                     isVisible: true,
                  //                     overflowMode: LegendItemOverflowMode.wrap,
                  //                     orientation: LegendItemOrientation.auto,
                  //                     shouldAlwaysShowScrollbar: true,
                  //                     alignment: ChartAlignment.center,
                  //                     position: LegendPosition.bottom,
                  //                     isResponsive: true,
                  //                   ),
                  //                   series: <DoughnutSeries<ChartData, String>>[
                  //                     DoughnutSeries<ChartData, String>(
                  //                       dataSource: [
                  //                         ChartData('Presents', totalPresent,
                  //                             Colors.green),
                  //                         ChartData(
                  //                             'Lates', totalLate, Colors.orange),
                  //                         ChartData(
                  //                             'Absents',
                  //                             (totalHeldClasses -
                  //                                 totalPresent -
                  //                                 totalLate),
                  //                             Colors.red),
                  //                       ],
                  //                       xValueMapper: (ChartData data, _) =>
                  //                           data.category,
                  //                       yValueMapper: (ChartData data, _) =>
                  //                           data.value,
                  //                       pointColorMapper: (ChartData data, _) =>
                  //                           data.color,
                  //                       innerRadius: '65%',
                  //                       radius: '72.5%',
                  //                       dataLabelSettings:
                  //                           const DataLabelSettings(
                  //                         isVisible: true,
                  //                         labelPosition:
                  //                             ChartDataLabelPosition.outside,
                  //                         useSeriesColor: true,
                  //                         labelIntersectAction:
                  //                             LabelIntersectAction.shift,
                  //                       ),
                  //                       explode: true,
                  //                       explodeIndex: 0,
                  //                       explodeOffset: '7%',
                  //                       enableTooltip: true,
                  //                     ),
                  //                   ],
                  //                   tooltipBehavior: TooltipBehavior(
                  //                     enable: true,
                  //                     format: 'point.x\npoint.y',
                  //                   ),
                  //                 )
                  //               : Column(
                  //                   children: [
                  //                     Container(
                  //                       margin: const EdgeInsets.only(top: 12),
                  //                       child: const Text(
                  //                         'Attendance Status',
                  //                         style: TextStyle(
                  //                           fontSize: 22,
                  //                           letterSpacing: 0.3,
                  //                           fontFamily: 'RalewaySemiBold',
                  //                         ),
                  //                       ),
                  //                     ),
                  //                     Expanded(
                  //                       child: Center(
                  //                         child: Container(
                  //                           margin: const EdgeInsets.only(top: 9),
                  //                           child: const Text(
                  //                             'No data to display',
                  //                             style: TextStyle(
                  //                               color: Color.fromARGB(
                  //                                   255, 63, 63, 63),
                  //                               fontSize: 15,
                  //                               fontFamily: 'RalewayMedium',
                  //                             ),
                  //                           ),
                  //                         ),
                  //                       ),
                  //                     ),
                  //                   ],
                  //                 )),
                  // ),
                  const SizedBox(height: 10),
                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                    child: Container(
                      height: 380,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: isLoading
                          ? Column(
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(top: 12),
                                  child: const Text(
                                    'Classes Completion Status',
                                    style: TextStyle(
                                      fontSize: 22,
                                      letterSpacing: 0.3,
                                      fontFamily: 'RalewaySemiBold',
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const SizedBox(
                                          height: 35,
                                          width: 35,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 3),
                                        ),
                                        Container(
                                          margin: const EdgeInsets.only(top: 9),
                                          child: const Text(
                                            'Loading data...',
                                            style: TextStyle(
                                              color:
                                                  Color.fromARGB(255, 63, 63, 63),
                                              fontSize: 14,
                                              fontFamily: 'RalewayMedium',
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : classesData.isNotEmpty
                              ? SfCircularChart(
                                  title: const ChartTitle(
                                    text: 'Classes Completion Status',
                                    textStyle: TextStyle(
                                      fontSize: 17,
                                      fontFamily: 'RalewaySemiBold',
                                    ),
                                  ),
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
                                          classesData[index]['totalHeldClasses'] *
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
                                      innerRadius: '38%',
                                      radius: '95%',
                                    ),
                                  ],
                                  annotations: const <CircularChartAnnotation>[
                                    CircularChartAnnotation(
                                      widget: Text(
                                        'Classes\nCompleted',
                                        style: TextStyle(
                                          color: Color.fromARGB(255, 56, 56, 56),
                                          fontSize: 13,
                                          letterSpacing: 0.125,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                  tooltipBehavior: TooltipBehavior(enable: true),
                                )
                              : Column(
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(top: 12),
                                      child: const Text(
                                        'Classes Completion Status',
                                        style: TextStyle(
                                          fontSize: 22,
                                          letterSpacing: 0.3,
                                          fontFamily: 'RalewaySemiBold',
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Center(
                                        child: Container(
                                          margin: const EdgeInsets.only(top: 9),
                                          child: const Text(
                                            'No data to display',
                                            style: TextStyle(
                                              color:
                                                  Color.fromARGB(255, 63, 63, 63),
                                              fontSize: 15,
                                              fontFamily: 'RalewayMedium',
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                    ),
                  )
                ],
              ),
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

class GraphData {
  GraphData(this.month, this.sales);
  final String month;
  final double sales;
}
