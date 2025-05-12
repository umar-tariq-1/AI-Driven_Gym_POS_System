import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:gym_ease/data/secure_storage.dart';
import 'package:gym_ease/main.dart';
import 'package:gym_ease/states/server_address.dart';
import 'package:gym_ease/theme/theme.dart';
import 'package:gym_ease/widgets/base/app_bar.dart';
import 'package:gym_ease/widgets/base/custom_elevated_button.dart';
import 'package:gym_ease/widgets/base/navigation_drawer.dart';
import 'package:gym_ease/widgets/base/snackbar.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:http/http.dart' as http;

class OwnerRegisterGymPage extends StatefulWidget {
  final bool redirectedAfterRegistration;
  const OwnerRegisterGymPage(
      {super.key, this.redirectedAfterRegistration = false});
  static const String routePath = '/owner/register-gym';

  @override
  State<OwnerRegisterGymPage> createState() => _OwnerRegisterGymPageState();
}

class _OwnerRegisterGymPageState extends State<OwnerRegisterGymPage> {
  Map userData = {};
  List<int> _trainerIds = [];
  List _trainersData = [];
  final serverAddressController = Get.find<ServerAddressController>();
  bool isLoading = false;
  Map controllers = {
    'gymName': TextEditingController(),
    'gymLocation': TextEditingController(),
  };
  final _formKey = GlobalKey<FormState>();

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
          Uri.parse('http://${serverAddressController.IP}:3001/users/trainers'),
          headers: {
            'auth-token': authToken,
          });
      if (response.statusCode == 200) {
        setState(() {
          _trainersData = json.decode(response.body);
        });
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
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: CustomAppBar(
          title: "Gym Registration",
          backgroundColor: appBarColor,
          foregroundColor: appBarTextColor,
          isFixedPage: widget.redirectedAfterRegistration,
        ),
        drawer: const CustomNavigationDrawer(
          active: 'Manage Gym',
          accType: "Owner",
        ),
        backgroundColor: colorScheme.surface,
        body: Container(
            height: double.infinity,
            padding: EdgeInsets.fromLTRB(
                screenWidth * 0.065, 0.0, screenWidth * 0.065, 0.0),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40.0),
                topRight: Radius.circular(40.0),
              ),
            ),
            child: GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                },
                child: SingleChildScrollView(
                    child: Form(
                        key: _formKey,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(height: 30.0),
                              TextFormField(
                                keyboardType: TextInputType.emailAddress,
                                controller: controllers['gymName'],
                                autofillHints: const [AutofillHints.email],
                                decoration: InputDecoration(
                                  label: const Text('Gym Name'),
                                  labelStyle: const TextStyle(
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  hintText: 'Gym Name',
                                  hintStyle: const TextStyle(
                                    color: Colors.black26,
                                  ),
                                  border: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Colors.black12,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Colors.black12,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.email_rounded,
                                    color: Colors.black54,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 16, horizontal: 16),
                                ),
                                validator: (value) {
                                  if (value == null ||
                                      value.isEmpty ||
                                      value.trim() == "") {
                                    return 'Gym name is required';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20.0),
                              TextFormField(
                                keyboardType: TextInputType.emailAddress,
                                controller: controllers['gymLocation'],
                                autofillHints: const [AutofillHints.email],
                                decoration: InputDecoration(
                                  label: const Text('Gym Location'),
                                  labelStyle: const TextStyle(
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  hintText: 'Gym Location',
                                  hintStyle: const TextStyle(
                                    color: Colors.black26,
                                  ),
                                  border: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Colors.black12,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Colors.black12,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.email_rounded,
                                    color: Colors.black54,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 16, horizontal: 16),
                                ),
                                validator: (value) {
                                  if (value == null ||
                                      value.isEmpty ||
                                      value.trim() == "") {
                                    return 'Gym location is required';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20.0),
                              DropdownSearch<
                                  Map<String, dynamic>>.multiSelection(
                                items:
                                    _trainersData.cast<Map<String, dynamic>>(),
                                itemAsString: (trainer) =>
                                    '${trainer['firstName']} ${trainer['lastName']}',
                                selectedItems: _trainersData
                                    .cast<Map<String, dynamic>>()
                                    .where((trainer) =>
                                        _trainerIds.contains(trainer['id']))
                                    .toList(),
                                onChanged: (selectedList) {
                                  setState(() {
                                    _trainerIds = selectedList
                                        .map((e) => e['id'] as int)
                                        .toList();
                                  });
                                },
                                dropdownDecoratorProps: DropDownDecoratorProps(
                                  dropdownSearchDecoration: InputDecoration(
                                    label: const Text('Select Trainer/s'),
                                    labelStyle: const TextStyle(
                                        overflow: TextOverflow.ellipsis),
                                    hintText: 'Select Trainer/s',
                                    hintStyle:
                                        const TextStyle(color: Colors.black26),
                                    border: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: Colors.black12),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: Colors.black12),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    prefixIcon: const Icon(Icons.group,
                                        color: Colors.black54),
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 16, horizontal: 16),
                                  ),
                                ),
                                popupProps: const PopupPropsMultiSelection.menu(
                                  showSearchBox: true,
                                  searchFieldProps: TextFieldProps(
                                    decoration: InputDecoration(
                                      hintText: 'Search trainer...',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                                // validator: (value) =>
                                //     value == null || value.isEmpty
                                //         ? 'At least one trainer is required'
                                //         : null,
                              ),
                              const SizedBox(height: 27.5),
                              SizedBox(
                                  width: double.infinity,
                                  child: CustomElevatedButton(
                                      buttonText: "Register",
                                      disabled: isLoading,
                                      onClick: () {
                                        HapticFeedback.lightImpact();
                                        if (_formKey.currentState?.validate() ??
                                            false) {}
                                      }))
                            ]))))));
  }
}
