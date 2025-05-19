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
import 'package:gym_ease/widgets/base/form_elements.dart';
import 'package:gym_ease/widgets/base/loader.dart';
import 'package:gym_ease/widgets/base/navigation_drawer.dart';
import 'package:gym_ease/widgets/base/snackbar.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:http/http.dart' as http;

class OwnerRegisterGymPage extends StatefulWidget {
  const OwnerRegisterGymPage(
      {super.key});
  static const String routePath = '/owner/register-gym';

  @override
  State<OwnerRegisterGymPage> createState() => _OwnerRegisterGymPageState();
}

class _OwnerRegisterGymPageState extends State<OwnerRegisterGymPage> {
  Map userData = {};
  Map responseData = {};
  List<int> _trainerIds = [];
  List _trainersData = [];
  final serverAddressController = Get.find<ServerAddressController>();
  bool isLoading = false;
  String authToken = '';
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
    authToken = await SecureStorage().getItem('authToken');
    try {
      setState(() {
        isLoading = true;
      });
      final response = await http.get(
          Uri.parse(
              'http://${serverAddressController.IP}:3001/owner/register-gym/'),
          headers: {
            'auth-token': authToken,
          });
      if (response.statusCode == 200) {
        setState(() {
          // print(jsonDecode(response.body));
          responseData = json.decode(response.body);
          _trainersData = json.decode(response.body)['trainersData'];
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

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: CustomAppBar(
          title: "My Gyms",
          backgroundColor: appBarColor,
          foregroundColor: appBarTextColor,
        ),
        drawer: const CustomNavigationDrawer(
          active: 'Manage Gyms',
          accType: "Owner",
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            showDialog(
                context: context,
                builder: (context) {
                  return StatefulBuilder(builder: (context, setState) {
                    return Dialog(
                        insetPadding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 25),
                        backgroundColor: Colors.white,
                        child: Container(
                            width: MediaQuery.of(context).size.width,
                            padding:
                                const EdgeInsets.fromLTRB(18, 25, 18, 17.5),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'Add New Gym',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 30),
                                Form(
                                    key: _formKey,
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          TextFormField(
                                            keyboardType: TextInputType.text,
                                            controller: controllers['gymName'],
                                            autofillHints: const [
                                              AutofillHints.email
                                            ],
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
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                  color: Colors.black12,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              prefixIcon: const Icon(
                                                Icons.fitness_center_rounded,
                                                color: Colors.black54,
                                              ),
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 16,
                                                      horizontal: 16),
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
                                            keyboardType:
                                                TextInputType.streetAddress,
                                            controller:
                                                controllers['gymLocation'],
                                            autofillHints: const [
                                              AutofillHints.email
                                            ],
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
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                  color: Colors.black12,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              prefixIcon: const Icon(
                                                Icons.location_on_rounded,
                                                color: Colors.black54,
                                              ),
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 16,
                                                      horizontal: 16),
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
                                              Map<String,
                                                  dynamic>>.multiSelection(
                                            items: _trainersData
                                                .cast<Map<String, dynamic>>(),
                                            itemAsString: (trainer) =>
                                                '${trainer['firstName']} ${trainer['lastName']}',
                                            selectedItems: _trainersData
                                                .cast<Map<String, dynamic>>()
                                                .where((trainer) => _trainerIds
                                                    .contains(trainer['id']))
                                                .toList(),
                                            onChanged: (selectedList) {
                                              setState(() {
                                                _trainerIds = selectedList
                                                    .map((e) => e['id'] as int)
                                                    .toList();
                                              });
                                            },
                                            dropdownDecoratorProps:
                                                DropDownDecoratorProps(
                                              dropdownSearchDecoration:
                                                  InputDecoration(
                                                label: const Text(
                                                    'Select Trainer/s'),
                                                labelStyle: const TextStyle(
                                                    overflow:
                                                        TextOverflow.ellipsis),
                                                hintText: 'Select Trainer/s',
                                                hintStyle: const TextStyle(
                                                    color: Colors.black26),
                                                border: OutlineInputBorder(
                                                  borderSide: const BorderSide(
                                                      color: Colors.black12),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderSide: const BorderSide(
                                                      color: Colors.black12),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                prefixIcon: const Icon(
                                                    Icons.group,
                                                    color: Colors.black54),
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 16,
                                                        horizontal: 16),
                                              ),
                                            ),
                                            popupProps:
                                                const PopupPropsMultiSelection
                                                    .menu(
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
                                                  onClick: () async {
                                                    HapticFeedback
                                                        .lightImpact();
                                                    if (_formKey.currentState
                                                            ?.validate() ??
                                                        false) {
                                                      try {
                                                        setState(() {
                                                          isLoading = true;
                                                        });
                                                        final response =
                                                            await http.post(
                                                          Uri.parse(
                                                              'http://${serverAddressController.IP}:3001/owner/register-gym'),
                                                          headers: {
                                                            'auth-token':
                                                                authToken,
                                                            'Content-Type':
                                                                'application/json',
                                                          },
                                                          body: jsonEncode({
                                                            'gymName':
                                                                controllers[
                                                                        'gymName']
                                                                    .text
                                                                    .trim(),
                                                            'gymLocation':
                                                                controllers[
                                                                        'gymLocation']
                                                                    .text
                                                                    .trim(),
                                                            'trainerIds':
                                                                _trainerIds
                                                          }),
                                                        );
                                                        if (response
                                                                .statusCode ==
                                                            200) {
                                                          controllers['gymName']
                                                              .text = '';

                                                          controllers[
                                                                  'gymLocation']
                                                              .text = '';
                                                          _trainerIds = [];
                                                          Navigator.of(context)
                                                              .pop();
                                                          fetchData();
                                                          CustomSnackbar
                                                              .showSuccessSnackbar(
                                                                  context,
                                                                  'Success',
                                                                  jsonDecode(response
                                                                          .body)[
                                                                      'message']);
                                                        } else {
                                                          Navigator.of(context)
                                                              .pop();
                                                          CustomSnackbar
                                                              .showFailureSnackbar(
                                                                  context,
                                                                  "Oops!",
                                                                  json.decode(response
                                                                          .body)[
                                                                      'message']);
                                                        }
                                                      } catch (e) {
                                                        print(e);
                                                        Navigator.of(context)
                                                            .pop();
                                                        CustomSnackbar
                                                            .showFailureSnackbar(
                                                                context,
                                                                "Oops!",
                                                                "Sorry, couldn't request to server");
                                                      }
                                                      setState(() {
                                                        isLoading = false;
                                                      });
                                                    }
                                                  })),
                                        ])),
                              ],
                            )));
                  });
                });
          },
          backgroundColor: colorScheme.inversePrimary,
          child: const Icon(Icons.add_rounded),
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
            child: Container(
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
                    child: Stack(
                      children: [
                        ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              const SizedBox(height: 20.0),
                              responseData.isNotEmpty
                                  ? Column(
                                      children: List.generate(
                                        responseData['gymData'].length,
                                        (index) {
                                          final gym =
                                              responseData['gymData'][index];
                                          final List<Map<String, dynamic>>
                                              trainers =
                                              List<Map<String, dynamic>>.from(
                                                  gym['trainers']);

                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const SizedBox(height: 20),
                                              CustomDataDisplayTextField(
                                                value: gym['gymName'],
                                                label: 'Gym Name',
                                              ),
                                              const SizedBox(height: 20),
                                              CustomDataDisplayTextField(
                                                value: gym['gymLocation'],
                                                label: 'Gym Location',
                                              ),
                                              const SizedBox(height: 20),
                                              gym['trainers'].length > 0
                                                  ? AbsorbPointer(
                                                      absorbing: true,
                                                      child: DropdownSearch<
                                                          Map<String,
                                                              dynamic>>.multiSelection(
                                                        items: trainers,
                                                        itemAsString: (trainer) =>
                                                            '${trainer['firstName']} ${trainer['lastName']}',
                                                        selectedItems: trainers,
                                                        dropdownDecoratorProps:
                                                            DropDownDecoratorProps(
                                                          dropdownSearchDecoration:
                                                              InputDecoration(
                                                            label: const Text(
                                                                'Assigned Trainer/s'),
                                                            labelStyle:
                                                                const TextStyle(
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                            filled: true,
                                                            fillColor: Colors
                                                                .grey[200],
                                                            border:
                                                                OutlineInputBorder(
                                                              borderSide:
                                                                  const BorderSide(
                                                                      color: Colors
                                                                          .black12),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                            ),
                                                            enabledBorder:
                                                                OutlineInputBorder(
                                                              borderSide:
                                                                  const BorderSide(
                                                                      color: Colors
                                                                          .black12),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                            ),
                                                            contentPadding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    vertical:
                                                                        16,
                                                                    horizontal:
                                                                        16),
                                                          ),
                                                        ),
                                                        popupProps:
                                                            const PopupPropsMultiSelection
                                                                .menu(
                                                          showSearchBox: false,
                                                        ),
                                                      ),
                                                    )
                                                  : const CustomDataDisplayTextField(
                                                      value:
                                                          '[No Trainer Assigned]',
                                                      label:
                                                          'Assigned Trainer/s',
                                                    ),
                                              const SizedBox(height: 20),
                                              if (index !=
                                                  responseData['gymData']
                                                          .length -
                                                      1)
                                                const Divider(),
                                            ],
                                          );
                                        },
                                      ),
                                    )
                                  : const SizedBox()
                            ]),
                        Loader(isLoading: isLoading)
                      ],
                    )))));
  }
}
