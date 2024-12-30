import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/main.dart';
import 'package:frontend/theme/theme.dart';
import 'package:frontend/widgets/base/app_bar.dart';
import 'package:frontend/widgets/base/custom_elevated_button.dart';
import 'package:frontend/widgets/base/custom_outlined_button.dart';
import 'package:frontend/widgets/base/form_elements.dart';

class ShowMyClassPage extends StatefulWidget {
  Map<String, dynamic> classData = {};
  ShowMyClassPage({super.key, required this.classData});

  @override
  State<ShowMyClassPage> createState() => _ShowMyClassPageState();
}

class _ShowMyClassPageState extends State<ShowMyClassPage> {
  String formatDate(String date) {
    final months = {
      '01': 'Jan',
      '02': 'Feb',
      '03': 'Mar',
      '04': 'Apr',
      '05': 'May',
      '06': 'Jun',
      '07': 'Jul',
      '08': 'Aug',
      '09': 'Sep',
      '10': 'Oct',
      '11': 'Nov',
      '12': 'Dec',
    };
    final parts = date.split('-');
    final day = parts[0];
    final month = months[parts[1]] ?? '';
    final year = parts[2];
    return '$month $day, $year';
  }

  String getSelectedDays(String selectedDaysString) {
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final selectedDaysArray = jsonDecode(selectedDaysString).cast<bool>();
    List<String> activeDays = [];
    for (int i = 0; i < selectedDaysArray.length; i++) {
      if (selectedDaysArray[i]) {
        activeDays.add(dayNames[i]);
      }
    }
    return activeDays.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Class Details",
        backgroundColor: appBarColor,
        foregroundColor: appBarTextColor,
        showBackButton: true,
      ),
      backgroundColor: colorScheme.surface,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(15)),
                  child: Image.network(
                    "https://ik.imagekit.io/umartariq/trainerClassImages/${widget.classData['imageData']['name'] ?? ''}",
                    width: double.infinity,
                    // height: 300,
                    fit: BoxFit.scaleDown,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return SizedBox(
                        width: MediaQuery.of(context).size.width * 0.4,
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    (loadingProgress.expectedTotalBytes ?? 1)
                                : null,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: MediaQuery.of(context).size.width * 0.4,
                      height: double.infinity,
                      color: Colors.grey[300],
                      child: Center(
                          child: Icon(
                        Icons.error,
                        color: colorScheme.error,
                        size: 50,
                      )),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomDataDisplayTextField(
                        value: widget.classData['className'].toString(),
                        label: "Class Title"),
                    const SizedBox(height: 15),
                    CustomDataDisplayTextField(
                        value: widget.classData['trainerName'].toString(),
                        label: "Trainer's Name"),
                    const SizedBox(height: 15),
                    CustomDataDisplayTextField(
                        value: widget.classData['gymName'].toString(),
                        label: "Gym Name"),
                    const SizedBox(height: 15),
                    CustomDataDisplayTextField(
                        value: widget.classData['gymLocation'].toString(),
                        label: "Gym Location"),
                    const SizedBox(height: 15),
                    CustomDataDisplayTextField(
                        value: widget.classData['classDescription'].toString(),
                        label: "Class Description"),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                            flex: 1,
                            child: CustomDataDisplayTextField(
                                value: widget.classData['classType'].toString(),
                                label: "Class Type")),
                        const SizedBox(width: 10),
                        Expanded(
                            flex: 1,
                            child: CustomDataDisplayTextField(
                                value:
                                    widget.classData['classGender'].toString(),
                                label: "Class Gender")),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                            flex: 5,
                            child: CustomDataDisplayTextField(
                                value:
                                    widget.classData['fitnessLevel'].toString(),
                                label: "Fitness Level")),
                        const SizedBox(width: 10),
                        Expanded(
                            flex: 6,
                            child: CustomDataDisplayTextField(
                                value: widget.classData['classCategory']
                                    .toString(),
                                label: "Class Category")),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                            flex: 1,
                            child: CustomDataDisplayTextField(
                                value:
                                    '${widget.classData['maxParticipants'] - widget.classData['remainingSeats']}/${widget.classData['maxParticipants']}',
                                label: "Registered/Max Members")),
                        const SizedBox(width: 10),
                        Expanded(
                            flex: 1,
                            child: CustomDataDisplayTextField(
                                value: widget.classData['classFee'].toString(),
                                label: "Class Fee (USD)")),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Center(
                      child: CustomOutlinedButton(
                          onClick: () {},
                          minWidth: MediaQuery.of(context).size.width - 32,
                          fontSize: 16.5,
                          buttonText: getSelectedDays(
                              widget.classData['selectedDays'])),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: CustomOutlinedButton(
                            onClick: () {},
                            fontSize: 16.5,
                            buttonText: formatDate(
                              widget.classData['startDate']
                                  .toString()
                                  .substring(0, 10),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 20,
                          child: Text(
                            '-',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.grey.shade600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: CustomOutlinedButton(
                            onClick: () {},
                            fontSize: 16.5,
                            buttonText: formatDate(
                              widget.classData['startDate']
                                  .toString()
                                  .substring(0, 10),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: CustomOutlinedButton(
                              onClick: () {},
                              fontSize: 16.5,
                              buttonText: widget.classData['startTime']
                                  .toString()
                                  .substring(0, 5)),
                        ),
                        SizedBox(
                          width: 20,
                          child: Text(
                            '-',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.grey.shade600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: CustomOutlinedButton(
                              onClick: () {},
                              fontSize: 16.5,
                              buttonText: widget.classData['endTime']
                                  .toString()
                                  .substring(0, 5)),
                        ),
                      ],
                    ),
                    // const SizedBox(height: 32),
                    // Center(
                    //   child: CustomElevatedButton(
                    //       onClick: () {
                    //         HapticFeedback.lightImpact();
                    //       },
                    //       minWidth: MediaQuery.of(context).size.width - 32,
                    //       fontSize: 16.5,
                    //       buttonText: ('Register for Class')),
                    // ),
                    const SizedBox(height: 5),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
