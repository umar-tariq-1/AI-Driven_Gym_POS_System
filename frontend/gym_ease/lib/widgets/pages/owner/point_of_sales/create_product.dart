import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:gym_ease/data/secure_storage.dart';
import 'package:gym_ease/main.dart';
import 'package:gym_ease/states/server_address.dart';
import 'package:gym_ease/theme/theme.dart';
import 'package:gym_ease/widgets/base/app_bar.dart';
import 'package:gym_ease/widgets/base/custom_elevated_button.dart';
import 'package:gym_ease/widgets/base/custom_outlined_button.dart';
import 'package:gym_ease/widgets/base/form_elements.dart';
import 'package:gym_ease/widgets/base/loader.dart';
import 'package:gym_ease/widgets/base/navigation_drawer.dart';
import 'package:gym_ease/widgets/base/snackbar.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:pinput/pinput.dart';

class CreatePOSProductPage extends StatefulWidget {
  const CreatePOSProductPage({super.key});

  static const String routePath = '/owner/create-pos-product';

  @override
  State<CreatePOSProductPage> createState() => _CreatePOSProductPageState();
}

class _CreatePOSProductPageState extends State<CreatePOSProductPage> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  XFile? _selectedImage;
  String? condition;

  final Map<String, TextEditingController> controllers = {
    'productName': TextEditingController(),
    'location': TextEditingController(),
    'sellerName': TextEditingController(),
    'quantity': TextEditingController(),
    'description': TextEditingController(),
    'price': TextEditingController(),
  };

  final ImagePicker _picker = ImagePicker();
  final serverAddressController = Get.find<ServerAddressController>();

  Future<void> sendCreateRequest() async {
    final String authToken = await SecureStorage().getItem('authToken');
    final uri = Uri.parse(
        'http://${serverAddressController.IP}:3001/owner/pos/create-product');
    final request = http.MultipartRequest('POST', uri);
    request.headers['auth-token'] = authToken;

    controllers.forEach((key, controller) {
      request.fields[key] = controller.text.trim();
    });

    request.fields['condition'] = condition!;

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

    try {
      setState(() {
        isLoading = true;
      });
      final response = await request.send();

      final responseBody = await response.stream.bytesToString();
      final Map<String, dynamic> responseJson = jsonDecode(responseBody);
      if (response.statusCode == 200) {
        // final trainerClassesController = Get.find<TrainerController>();

        // trainerClassesController.addClassData(responseJson['data']);
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
  }

  void getUserData() async {
    Map userData = await SecureStorage().getItem("userData");
    controllers['sellerName']!
        .setText("${userData['firstName']} ${userData['lastName']}");
  }

  @override
  void dispose() {
    controllers.forEach((key, controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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

    return Scaffold(
      appBar: CustomAppBar(
        title: "Create POS Product",
        backgroundColor: appBarColor,
        foregroundColor: appBarTextColor,
        showBackButton: true,
      ),
      drawer: const CustomNavigationDrawer(
        active: 'Point of Sales',
        accType: "Owner",
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
                      controller: controllers['productName']!,
                      label: 'Name',
                      hint: 'Enter product\'s name',
                    ),
                    const SizedBox(height: 15),
                    CustomTextFormField(
                      controller: controllers['description']!,
                      multiline: true,
                      keyboardType: TextInputType.multiline,
                      label: 'Description',
                      hint: 'Enter description',
                    ),
                    const SizedBox(height: 15),
                    CustomTextFormField(
                      controller: controllers['sellerName']!,
                      readOnly: true,
                      label: 'Seller\'s Name',
                      hint: 'Enter seller\'s name',
                    ),
                    const SizedBox(height: 15),
                    CustomTextFormField(
                      controller: controllers['location']!,
                      label: 'Location',
                      hint: 'Enter location',
                    ),
                    const SizedBox(height: 15),
                    CustomDropdownField(
                      label: 'Condition',
                      items: ['New', 'Used', 'Refurbished', 'Damaged'],
                      value: condition,
                      onChanged: (value) => setState(() => condition = value),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: CustomTextFormField(
                            controller: controllers['quantity']!,
                            label: 'Stock Quantity',
                            hint: 'Enter stock quantity',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 1,
                          child: CustomTextFormField(
                            controller: controllers['price']!,
                            label: 'Price (USD)',
                            hint: 'Enter price',
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
                    const SizedBox(height: 20),
                    CustomElevatedButton(
                      onClick: () {
                        FocusScope.of(context).unfocus();
                        HapticFeedback.lightImpact();
                        if (_formKey.currentState?.validate() == true) {
                          sendCreateRequest();
                        }
                      },
                      buttonText: 'Create Product',
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
