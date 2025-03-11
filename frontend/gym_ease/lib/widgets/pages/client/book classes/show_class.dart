import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gym_ease/data/secure_storage.dart';
import 'package:gym_ease/main.dart';
import 'package:gym_ease/states/client.dart';
import 'package:gym_ease/states/server_address.dart';
import 'package:gym_ease/theme/theme.dart';
import 'package:gym_ease/widgets/base/app_bar.dart';
import 'package:gym_ease/widgets/base/confirmation_dialog.dart';
import 'package:gym_ease/widgets/base/custom_elevated_button.dart';
import 'package:gym_ease/widgets/base/custom_outlined_button.dart';
import 'package:gym_ease/widgets/base/form_elements.dart';
import 'package:gym_ease/widgets/base/snackbar.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_downloader/image_downloader.dart';

class ShowClassPage extends StatefulWidget {
  Map<String, dynamic> classData = {};
  ShowClassPage({super.key, required this.classData});

  @override
  State<ShowClassPage> createState() => _ShowClassPageState();
}

class _ShowClassPageState extends State<ShowClassPage> {
  final serverAddressController = Get.find<ServerAddressController>();
  final clientClassesController = Get.find<ClientController>();
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

  void showImageDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          final screenProps = MediaQuery.of(context);
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.all(0),
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Center(
                  child: GestureDetector(
                      onTap: () {},
                      child: Stack(
                        children: [
                          InteractiveViewer(
                            panEnabled: true,
                            scaleEnabled: true,
                            child: Image(
                              image: CachedNetworkImageProvider(
                                  "https://ik.imagekit.io/umartariq/trainerClassImages/${widget.classData['imageData']['name'] ?? ''}"),
                              fit: BoxFit.contain,
                              width: screenProps.size.width,
                              height: screenProps.size.height,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) {
                                  return child;
                                }
                                return Container(
                                  height: 230,
                                  color: Colors.transparent,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      value:
                                          loadingProgress.expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  (loadingProgress
                                                          .expectedTotalBytes ??
                                                      1)
                                              : null,
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                height: 230,
                                color: Colors.transparent,
                                child: Center(
                                    child: Icon(
                                  Icons.error,
                                  color: Theme.of(context).colorScheme.error,
                                  size: 60,
                                )),
                              ),
                            ),
                          ),
                          Positioned(
                            top: screenProps.viewPadding.top + 17,
                            right: 10,
                            child: GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.black.withOpacity(0.6),
                                ),
                                child: const Icon(Icons.close,
                                    color: Colors.white, size: 24),
                              ),
                            ),
                          ),
                        ],
                      )),
                ),
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar(
          title: "Class Details",
          backgroundColor: appBarColor,
          foregroundColor: appBarTextColor,
          showBackButton: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.more_vert_rounded),
              iconSize: 28.5,
              onPressed: () {
                showMenu(
                  context: context,
                  position: const RelativeRect.fromLTRB(1, /* 95 */ 75, 0, 0),
                  items: [
                    PopupMenuItem(
                      child: ListTile(
                        leading: Icon(Icons.image_rounded, color: appBarColor),
                        title: Text(
                          'View Image',
                          style: TextStyle(color: appBarColor),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          showImageDialog();
                        },
                      ),
                    ),
                    PopupMenuItem(
                      child: ListTile(
                        leading:
                            Icon(Icons.download_rounded, color: appBarColor),
                        title: Text(
                          'Download Image',
                          style: TextStyle(color: appBarColor),
                        ),
                        onTap: () async {
                          Navigator.pop(context);
                          CustomConfirmationDialog.show(
                            context,
                            title: "Confirm Download?",
                            message:
                                "Are you sure you want to download this class image?",
                            yesText: "Download",
                            noText: "Cancel",
                            noCallback: () {
                              Navigator.pop(context);
                            },
                            yesCallback: () async {
                              Navigator.pop(context);
                              final imageUrl =
                                  "https://ik.imagekit.io/umartariq/trainerClassImages/${widget.classData['imageData']['name'] ?? ''}";

                              try {
                                var imageId =
                                    await ImageDownloader.downloadImage(
                                        imageUrl);

                                if (imageId == null) {
                                  CustomSnackbar.showHelpSnackbar(
                                      context,
                                      "Info!",
                                      "Couldn't get storage permission");
                                  return;
                                }
                                CustomSnackbar.showSuccessSnackbar(
                                  context,
                                  "Success!",
                                  "Image downloaded successfully",
                                );
                              } catch (e) {
                                CustomSnackbar.showFailureSnackbar(context,
                                    "Oops!", "Sorry! Failed to download image");
                              }
                            },
                          );
                        },
                      ),
                    ),
                    PopupMenuItem(
                      child: ListTile(
                        leading: const Icon(Icons.favorite_rounded,
                            color: Colors.pink),
                        title: const Text(
                          'Add to Favourites',
                          style: TextStyle(color: Colors.pink),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          // Add favourite action here
                        },
                      ),
                    ),
                  ],
                );
              },
            )
          ],
        ),
        backgroundColor: colorScheme.surface,
        body: GetBuilder<ClientController>(builder: (controller) {
          return GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(15)),
                      child: GestureDetector(
                        onTap: () {
                          showImageDialog();
                        },
                        child: Image(
                          image: CachedNetworkImageProvider(
                              "https://ik.imagekit.io/umartariq/trainerClassImages/${widget.classData['imageData']['name'] ?? ''}"),
                          width: double.infinity,
                          // height: 300,
                          fit: BoxFit.scaleDown,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              // width: screenProps.size.width * 0.4,
                              height: 230,
                              color: Colors.grey[200],
                              child: Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          (loadingProgress.expectedTotalBytes ??
                                              1)
                                      : null,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            // width: screenProps.size.width * 0.4,
                            height: 230,
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
                            value:
                                widget.classData['classDescription'].toString(),
                            multiline: true,
                            label: "Class Description"),
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            Expanded(
                                flex: 1,
                                child: CustomDataDisplayTextField(
                                    value: widget.classData['classType']
                                        .toString(),
                                    label: "Class Type")),
                            const SizedBox(width: 10),
                            Expanded(
                                flex: 1,
                                child: CustomDataDisplayTextField(
                                    value: widget.classData['classGender']
                                        .toString(),
                                    label: "Class Gender")),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            Expanded(
                                flex: 5,
                                child: CustomDataDisplayTextField(
                                    value: widget.classData['fitnessLevel']
                                        .toString(),
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
                                    value: widget.classData['remainingSeats']
                                        .toString(),
                                    controller: TextEditingController(
                                        text: controller.classesData
                                            .firstWhere(
                                              (map) =>
                                                  map['id'] ==
                                                  widget.classData['id'],
                                            )['remainingSeats']
                                            .toString()),
                                    label: "Seats Available")),
                            const SizedBox(width: 10),
                            Expanded(
                                flex: 1,
                                child: CustomDataDisplayTextField(
                                    value:
                                        widget.classData['classFee'].toString(),
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
                        const SizedBox(height: 15),
                        CustomDataDisplayTextField(
                            value: DateFormat("MMM dd, yyyy  HH:mm").format(
                                DateTime.parse(widget.classData['createdAt'])
                                    .toLocal()),
                            label: "Created On"),
                        const SizedBox(height: 32),
                        Center(
                          child: CustomElevatedButton(
                              onClick: () async {
                                HapticFeedback.lightImpact();
                                if (widget.classData['remainingSeats'] <= 0) {
                                  CustomSnackbar.showFailureSnackbar(
                                      context,
                                      "Oops!",
                                      "Sorry! No seats available in this class");
                                  return;
                                }
                                try {
                                  String authToken = await SecureStorage()
                                      .getItem('authToken');
                                  final response = await http.post(
                                    Uri.parse(
                                        'http://${serverAddressController.IP}:3001/client/classes/register'),
                                    headers: {
                                      'Content-Type': 'application/json',
                                      'auth-token': authToken
                                    },
                                    body: jsonEncode({
                                      'classId': widget.classData['id'],
                                    }),
                                  );
                                  if (response.statusCode == 200) {
                                    CustomSnackbar.showSuccessSnackbar(
                                        context,
                                        "Success!",
                                        "You registered for this class, successfully");
                                    controller.setClassesData(
                                        controller.classesData.map((map) {
                                      if (map['id'] == widget.classData['id']) {
                                        map['isAlreadyRegistered'] = 1;
                                        map['remainingSeats'] =
                                            map['remainingSeats'] - 1;
                                      }
                                      return map;
                                    }).toList());
                                  } else {
                                    CustomSnackbar.showFailureSnackbar(
                                        context,
                                        "Oops!",
                                        jsonDecode(response.body)['message']);
                                  }
                                } catch (e) {
                                  print(e);
                                  CustomSnackbar.showFailureSnackbar(
                                      context,
                                      "Oops!",
                                      "Sorry, couldn't request to server");
                                }
                              },
                              minWidth: MediaQuery.of(context).size.width - 32,
                              fontSize: 16.5,
                              disabled: controller.classesData.firstWhere(
                                    (map) =>
                                        map['id'] == widget.classData['id'],
                                  )['isAlreadyRegistered'] ==
                                  1,
                              buttonText: ('Register for Class')),
                        ),
                        const SizedBox(height: 15),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }));
  }
}
