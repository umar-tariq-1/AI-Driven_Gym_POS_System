import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/data/secure_storage.dart';
import 'package:frontend/main.dart';
import 'package:frontend/states/server_address.dart';
import 'package:frontend/theme/theme.dart';
import 'package:frontend/widgets/base/app_bar.dart';
import 'package:frontend/widgets/base/custom_elevated_button.dart';
import 'package:frontend/widgets/base/custom_outlined_button.dart';
import 'package:frontend/widgets/base/form_elements.dart';
import 'package:frontend/widgets/base/loader.dart';
import 'package:frontend/widgets/base/navigation_drawer.dart';
import 'package:frontend/widgets/base/snackbar.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class CreateClassPage extends StatefulWidget {
  static const routePath = '/trainer/create-class';

  const CreateClassPage({super.key});
  @override
  _CreateClassPageState createState() => _CreateClassPageState();
}

class _CreateClassPageState extends State<CreateClassPage> {
  final _formKey = GlobalKey<FormState>();

  final Map<String, TextEditingController> controllers = {
    'className': TextEditingController(),
    'gymName': TextEditingController(),
    'gymLocation': TextEditingController(),
    'trainerName': TextEditingController(),
    'classDescription': TextEditingController(),
    'maxParticipants': TextEditingController(),
    'classFee': TextEditingController(),
    'specialRequirements': TextEditingController(),
  };

  String? classType;
  String? fitnessLevel;
  String? classGender;
  String? classCategory;
  List<bool> selectedDays = List.generate(7, (_) => false);
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  DateTime? startDate;
  DateTime? endDate;
  XFile? _selectedImage;
  bool isLoading = false;

  final ImagePicker _picker = ImagePicker();
  final serverAddressController = Get.find<ServerAddressController>();

  String selectedDaysText = "Select Class Days";
  final List weekDaysList = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday"
  ];

  String getMonthAbbreviation(int month) {
    return [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec"
    ][month - 1];
  }

  Future<void> sendCreateRequest() async {
    final String authToken = await SecureStorage().getItem('authToken');
    final uri = Uri.parse(
        'http://${serverAddressController.IP}:3001/trainer/classes/create');
    final request = http.MultipartRequest('POST', uri);
    request.headers['auth-token'] = authToken;
    // Add text fields
    controllers.forEach((key, controller) {
      request.fields[key] = controller.text.trim();
    });

    // Add dropdown selections
    if (classType != null) request.fields['classType'] = classType!;
    if (fitnessLevel != null) request.fields['fitnessLevel'] = fitnessLevel!;
    if (classGender != null) request.fields['classGender'] = classGender!;
    if (classCategory != null) request.fields['classCategory'] = classCategory!;

    // Add selected days
    request.fields['selectedDays'] = jsonEncode(selectedDays);

    // Add times and dates
    if (startTime != null) {
      request.fields['startTime'] =
          '${startTime!.hour}:${startTime!.minute.toString().padLeft(2, '0')}';
    }
    if (endTime != null) {
      request.fields['endTime'] =
          '${endTime!.hour}:${endTime!.minute.toString().padLeft(2, '0')}';
    }
    if (startDate != null) {
      request.fields['startDate'] = DateFormat('yyyy-MM-dd').format(startDate!);
    }
    if (endDate != null) {
      request.fields['endDate'] = DateFormat('yyyy-MM-dd').format(endDate!);
    }

    if (_selectedImage != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        _selectedImage!.path,
      ));
    }

    try {
      setState(() {
        isLoading = true;
      });
      final response = await request.send();

      final responseBody = await response.stream.bytesToString();
      final Map<String, dynamic> responseJson = jsonDecode(responseBody);
      if (response.statusCode == 200) {
        CustomSnackbar.showSuccessSnackbar(
            context, "Success", responseJson['message']);
        Navigator.of(context).pop();
      } else {
        CustomSnackbar.showFailureSnackbar(
            context, "Oops!", responseJson['message']);
      }
    } catch (e) {
      CustomSnackbar.showFailureSnackbar(
          context, "Oops!", "Sorry, couldn't request to server");
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  void getUserData() async {
    Map userData = await SecureStorage().getItem("userData");
    controllers['trainerName']!
        .setText("${userData['firstName']} ${userData['lastName']}");
  }

  Future<void> _pickImageFromGallery() async {
    try {
      HapticFeedback.lightImpact();
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        // maxWidth: 1800,
        // maxHeight: 1800,
        imageQuality: 100,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = XFile(pickedFile.path);
        });
        CustomSnackbar.showSuccessSnackbar(
            context, "Success!", "Image picked successfully");
      }
    } catch (e) {
      print('Error picking image: $e');
      CustomSnackbar.showFailureSnackbar(
          context, "Oops!", "Sorry, couldn't pick image. Try again");
    }
  }

  @override
  void dispose() {
    controllers.forEach((key, controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Create Class",
        backgroundColor: appBarColor,
        foregroundColor: appBarTextColor,
        showBackButton: true,
      ),
      drawer: const CustomNavigationDrawer(
        active: 'Manage Classes',
        accType: "Trainer",
      ),
      backgroundColor: colorScheme.surface,
      body: Stack(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    const SizedBox(height: 30),
                    CustomTextFormField(
                      controller: controllers['className']!,
                      label: 'Class Title',
                      hint: 'Enter class title',
                    ),
                    const SizedBox(height: 15),
                    CustomTextFormField(
                      controller: controllers['trainerName']!,
                      readOnly: true,
                      label: 'Trainer\'s Name',
                      hint: 'Enter trainer\'s name',
                    ),
                    const SizedBox(height: 15),
                    CustomTextFormField(
                      controller: controllers['gymName']!,
                      label: 'Gym Name',
                      hint: 'Enter gym name',
                    ),
                    const SizedBox(height: 15),
                    CustomTextFormField(
                      controller: controllers['gymLocation']!,
                      label: 'Gym Location',
                      hint: 'Enter gym location',
                    ),
                    const SizedBox(height: 15),
                    CustomTextFormField(
                      controller: controllers['classDescription']!,
                      label: 'Class Description',
                      hint: 'Enter description',
                      multiline: true,
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: CustomDropdownField(
                            label: 'Class Type',
                            items: ['Group Class', 'Personal Training'],
                            value: classType,
                            onChanged: (value) =>
                                setState(() => classType = value),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 1,
                          child: CustomDropdownField(
                            label: 'Class Gender',
                            items: [
                              'Male only',
                              'Female only',
                              'Male and Female'
                            ],
                            value: classGender,
                            onChanged: (value) =>
                                setState(() => classGender = value),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: CustomDropdownField(
                            label: 'Fitness Level',
                            items: ['Beginner', 'Intermediate', 'Advanced'],
                            value: fitnessLevel,
                            onChanged: (value) =>
                                setState(() => fitnessLevel = value),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 6,
                          child: CustomDropdownField(
                            label: 'Class Category',
                            items: [
                              'Strength Training',
                              'Yoga',
                              'Cardio',
                              'Zumba',
                              "Other"
                            ],
                            value: classCategory,
                            onChanged: (value) =>
                                setState(() => classCategory = value),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: CustomTextFormField(
                            controller: controllers['maxParticipants']!,
                            label: 'Max Participants',
                            hint: 'Enter class capacity',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 1,
                          child: CustomTextFormField(
                            controller: controllers['classFee']!,
                            label: 'Class Fee (USD)',
                            hint: 'Enter class fee',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    GestureDetector(
                      onLongPress: _pickImageFromGallery,
                      child: CustomOutlinedButton(
                          fontSize: 16.5,
                          buttonText: _selectedImage == null
                              ? 'Select Image'
                              : 'Tap to View, Hold to Change Image',
                          onClick: _selectedImage == null
                              ? _pickImageFromGallery
                              : () {
                                  if (_selectedImage == null) return;

                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return Dialog(
                                        backgroundColor: Colors.transparent,
                                        insetPadding: const EdgeInsets.all(0),
                                        child: GestureDetector(
                                          onTap: () =>
                                              Navigator.of(context).pop(),
                                          child: Container(
                                            width: double.infinity,
                                            height: double.infinity,
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.black.withOpacity(0.8),
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                            ),
                                            child: Center(
                                              child: InteractiveViewer(
                                                panEnabled: true,
                                                scaleEnabled: true,
                                                child: Image.file(
                                                  File(_selectedImage!.path),
                                                  fit: BoxFit.contain,
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      1,
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      1,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                }),
                    ),
                    const SizedBox(height: 14),
                    CustomOutlinedButton(
                        onClick: () {
                          HapticFeedback.lightImpact();
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return StatefulBuilder(
                                builder: (BuildContext context,
                                    StateSetter setState) {
                                  return AlertDialog(
                                    backgroundColor: colorScheme.surface,
                                    title: const Text(
                                      "Select Class Days",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    content: SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.8,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: List.generate(7, (index) {
                                          return CheckboxListTile(
                                            title: Text(
                                              weekDaysList[index],
                                              style:
                                                  const TextStyle(fontSize: 15),
                                            ),
                                            value: selectedDays[index],
                                            onChanged: (bool? value) {
                                              setState(() {
                                                selectedDays[index] =
                                                    value ?? false;
                                              });
                                            },
                                          );
                                        }),
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text(
                                          "Save",
                                          style: TextStyle(fontSize: 18),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ).then((_) => setState(() {
                                selectedDaysText = selectedDays.contains(true)
                                    ? selectedDays
                                        .asMap()
                                        .entries
                                        .where((entry) => entry.value)
                                        .map((entry) => weekDaysList[entry.key]
                                            .substring(0, 3))
                                        .join(", ")
                                    : "Select Class Days";
                              }));
                        },
                        fontSize: 16.5,
                        buttonText: selectedDaysText),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: CustomOutlinedButton(
                            onClick: () async {
                              HapticFeedback.lightImpact();
                              final pickedDate = await pickDate(context);
                              if (pickedDate != null) {
                                setState(() => startDate = pickedDate);
                              }
                            },
                            fontSize: 16.5,
                            buttonText: startDate == null
                                ? 'Start Date'
                                : startDate != null
                                    ? '${getMonthAbbreviation(startDate!.month)} ${startDate!.day}, ${startDate!.year}'
                                    : 'Start Date',
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
                              onClick: () async {
                                if (startDate != null) {
                                  HapticFeedback.lightImpact();
                                  final pickedDate = await pickDate(context,
                                      initialDate: startDate,
                                      firstDate: startDate);
                                  if (pickedDate != null) {
                                    setState(() => endDate = pickedDate);
                                  }
                                }
                              },
                              fontSize: 16.5,
                              buttonText: endDate == null
                                  ? 'End Date'
                                  : '${getMonthAbbreviation(endDate!.month)} ${endDate!.day}, ${endDate!.year}'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: CustomOutlinedButton(
                              onClick: () async {
                                HapticFeedback.lightImpact();
                                final pickedTime = await pickTime(context);
                                if (pickedTime != null) {
                                  setState(() => startTime = pickedTime);
                                }
                              },
                              fontSize: 16.5,
                              buttonText: startTime == null
                                  ? 'Start Time'
                                  : startTime != null
                                      ? startTime!.format(context)
                                      : 'Start Time'),
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
                              onClick: () async {
                                if (startTime != null) {
                                  HapticFeedback.lightImpact();
                                  final pickedTime = await pickTime(context,
                                      initialTime: startTime);
                                  if (pickedTime != null) {
                                    setState(() => endTime = pickedTime);
                                  }
                                }
                              },
                              fontSize: 16.5,
                              buttonText: endTime == null
                                  ? 'End Time'
                                  : endTime != null
                                      ? endTime!.format(context)
                                      : 'End Time'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    CustomElevatedButton(
                      onClick: () {
                        HapticFeedback.lightImpact();
                        if (_formKey.currentState?.validate() == true) {
                          sendCreateRequest();
                        }
                      },
                      buttonText: 'Create Class',
                    ),
                    const SizedBox(height: 25),
                  ],
                ),
              ),
            ),
          ),
          Loader(
            isLoading: isLoading,
          )
        ],
      ),
    );
  }
}
