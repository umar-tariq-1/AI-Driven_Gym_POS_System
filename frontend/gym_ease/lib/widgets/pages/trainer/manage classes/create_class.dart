import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gym_ease/data/secure_storage.dart';
import 'package:gym_ease/main.dart';
import 'package:gym_ease/states/server_address.dart';
import 'package:gym_ease/states/trainer.dart';
import 'package:gym_ease/theme/theme.dart';
import 'package:gym_ease/widgets/base/app_bar.dart';
import 'package:gym_ease/widgets/base/custom_elevated_button.dart';
import 'package:gym_ease/widgets/base/custom_outlined_button.dart';
import 'package:gym_ease/widgets/base/form_elements.dart';
import 'package:gym_ease/widgets/base/loader.dart';
import 'package:gym_ease/widgets/base/navigation_drawer.dart';
import 'package:gym_ease/widgets/base/snackbar.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:dropdown_search/dropdown_search.dart';
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
  List gymData = [];
  int? _selectedGymId;

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

    // Add image
    if (_selectedImage != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        _selectedImage!.path,
      ));
    } else {
      CustomSnackbar.showFailureSnackbar(
          context, "Oops!", "Please select an image");
      return;
    }

    // Add selected days
    if (selectedDays.contains(true)) {
      request.fields['selectedDays'] = jsonEncode(selectedDays);
    } else {
      CustomSnackbar.showFailureSnackbar(
          context, "Oops!", "Please select class day/s");
      return;
    }

    // Add times and dates
    if (startDate != null) {
      request.fields['startDate'] = DateFormat('yyyy-MM-dd').format(startDate!);
    } else {
      CustomSnackbar.showFailureSnackbar(
          context, "Oops!", "Please select a start date");
      return;
    }
    if (endDate != null) {
      request.fields['endDate'] = DateFormat('yyyy-MM-dd').format(endDate!);
    } else {
      CustomSnackbar.showFailureSnackbar(
          context, "Oops!", "Please select an end date");
      return;
    }
    if (startTime != null) {
      request.fields['startTime'] =
          '${startTime!.hour}:${startTime!.minute.toString().padLeft(2, '0')}';
    } else {
      CustomSnackbar.showFailureSnackbar(
          context, "Oops!", "Please select a start time");
      return;
    }
    if (endTime != null) {
      request.fields['endTime'] =
          '${endTime!.hour}:${endTime!.minute.toString().padLeft(2, '0')}';
    } else {
      CustomSnackbar.showFailureSnackbar(
          context, "Oops!", "Please select an end time");
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });
      final response = await request.send();

      final responseBody = await response.stream.bytesToString();
      final Map<String, dynamic> responseJson = jsonDecode(responseBody);
      if (response.statusCode == 200) {
        final trainerClassesController = Get.find<TrainerController>();

        trainerClassesController.addClassData(responseJson['data']);

        CustomSnackbar.showSuccessSnackbar(
            context, "Success", responseJson['message']);
        Navigator.of(context).pop();
      } else {
        CustomSnackbar.showFailureSnackbar(
            context, "Oops!", responseJson['message']);
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

  @override
  void initState() {
    super.initState();
    getUserData();
    fetchData();
  }

  void getUserData() async {
    Map userData = await SecureStorage().getItem("userData");
    controllers['trainerName']!
        .setText("${userData['firstName']} ${userData['lastName']}");
  }

  Future<void> fetchData() async {
    try {
      String authToken = await SecureStorage().getItem('authToken');
      final response = await http.get(
          Uri.parse(
              'http://${serverAddressController.IP}:3001/trainer/register-gym/gyms'),
          headers: {
            'auth-token': authToken,
          });
      if (response.statusCode == 200) {
        setState(() {
          gymData = jsonDecode(response.body)['gyms'];
        });
      } else {
        CustomSnackbar.showFailureSnackbar(
            context, "Oops!", json.decode(response.body)['message']);
      }
    } catch (e) {
      CustomSnackbar.showFailureSnackbar(
          context, "Oops!", "Sorry, couldn't request to server");
      print(e);
    }
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
                    DropdownSearch<Map<String, dynamic>>(
                      items: gymData.cast<Map<String, dynamic>>(),
                      itemAsString: (gym) => gym['gymName'],
                      selectedItem: _selectedGymId == null
                          ? null
                          : gymData
                              .cast<Map<String, dynamic>>()
                              .firstWhere((gym) => gym['id'] == _selectedGymId),
                      onChanged: (selectedGym) {
                        setState(() {
                          _selectedGymId = selectedGym?['id'];
                          controllers['gymLocation']!
                              .setText(selectedGym?['gymLocation'] ?? '');
                        });
                      },
                      dropdownDecoratorProps: DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                          label: const Text('Select Gym'),
                          labelStyle:
                              const TextStyle(overflow: TextOverflow.ellipsis),
                          hintText: 'Select Gym',
                          hintStyle: const TextStyle(color: Colors.black26),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          // prefixIcon: const Icon(Icons.fitness_center,
                          //     color: Colors.black54),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 16),
                        ),
                      ),
                      popupProps: const PopupProps.menu(
                        showSearchBox: true,
                        searchFieldProps: TextFieldProps(
                          decoration: InputDecoration(
                            hintText: 'Search gym...',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ),
                    // CustomTextFormField(
                    //   controller: controllers['gymName']!,
                    //   label: 'Gym Name',
                    //   hint: 'Enter gym name',
                    // ),
                    const SizedBox(height: 15),
                    // CustomTextFormField(
                    //     controller: controllers['gymLocation']!,
                    //     label: 'Gym Location',
                    //     hint: 'Enter gym location',
                    //     readOnly: true),
                    DropdownSearch<Map<String, dynamic>>(
                      items: gymData.cast<Map<String, dynamic>>(),
                      itemAsString: (gym) => gym['gymLocation'],
                      selectedItem: _selectedGymId == null
                          ? null
                          : gymData
                              .cast<Map<String, dynamic>>()
                              .firstWhere((gym) => gym['id'] == _selectedGymId),
                      onChanged: (selectedGym) {
                        setState(() {
                          _selectedGymId = selectedGym?['id'];
                          controllers['gymLocation']!
                              .setText(selectedGym?['gymLocation'] ?? '');
                        });
                      },
                      dropdownDecoratorProps: DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                          label: const Text('Select Gym Location'),
                          labelStyle:
                              const TextStyle(overflow: TextOverflow.ellipsis),
                          hintText: 'Select Gym Location',
                          hintStyle: const TextStyle(color: Colors.black26),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          // prefixIcon: const Icon(Icons.fitness_center,
                          //     color: Colors.black54),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 16),
                        ),
                      ),
                      popupProps: const PopupProps.menu(
                        showSearchBox: true,
                        searchFieldProps: TextFieldProps(
                          decoration: InputDecoration(
                            hintText: 'Search gym location...',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    CustomTextFormField(
                      controller: controllers['classDescription']!,
                      label: 'Class Description',
                      hint: 'Enter description',
                      multiline: true,
                      keyboardType: TextInputType.multiline,
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
                                      final screenProps =
                                          MediaQuery.of(context);
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
                                              child: GestureDetector(
                                                onTap: () {},
                                                child: Stack(
                                                  children: [
                                                    InteractiveViewer(
                                                      panEnabled: true,
                                                      scaleEnabled: true,
                                                      child: Image.file(
                                                        File(_selectedImage!
                                                            .path),
                                                        fit: BoxFit.contain,
                                                        width: screenProps
                                                                .size.width *
                                                            1,
                                                        height: screenProps
                                                                .size.height *
                                                            1,
                                                      ),
                                                    ),
                                                    Positioned(
                                                      top: screenProps
                                                              .viewPadding.top +
                                                          17,
                                                      right: 10,
                                                      child: GestureDetector(
                                                        onTap: () =>
                                                            Navigator.pop(
                                                                context),
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(6),
                                                          decoration:
                                                              BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            color: Colors.black
                                                                .withOpacity(
                                                                    0.6),
                                                          ),
                                                          child: const Icon(
                                                              Icons.close,
                                                              color:
                                                                  Colors.white,
                                                              size: 24),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
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
                          FocusScope.of(context).unfocus();
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
                              FocusScope.of(context).unfocus();
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
                                FocusScope.of(context).unfocus();
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
                                FocusScope.of(context).unfocus();
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
                                FocusScope.of(context).unfocus();
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
                        FocusScope.of(context).unfocus();
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
