import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:gym_ease/data/secure_storage.dart';
import 'package:gym_ease/main.dart';
import 'package:gym_ease/states/owner.dart';
import 'package:gym_ease/states/server_address.dart';
import 'package:gym_ease/theme/theme.dart';
import 'package:gym_ease/widgets/base/app_bar.dart';
import 'package:gym_ease/widgets/base/custom_elevated_button.dart';
import 'package:gym_ease/widgets/base/custom_outlined_button.dart';
import 'package:gym_ease/widgets/base/form_elements.dart';
import 'package:gym_ease/widgets/base/loader.dart';
import 'package:gym_ease/widgets/base/navigation_drawer.dart';
import 'package:gym_ease/widgets/base/snackbar.dart';
import 'package:gym_ease/widgets/compound/card.dart';
import 'package:gym_ease/widgets/pages/owner/point_of_sales/create_product.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class OwnerPointOfSalesPage extends StatefulWidget {
  const OwnerPointOfSalesPage({super.key});

  static const String routePath = '/owner/point-of-sales';

  @override
  State<OwnerPointOfSalesPage> createState() => _OwnerPointOfSalesPageState();
}

class _OwnerPointOfSalesPageState extends State<OwnerPointOfSalesPage> {
  final Random _random = Random();
  String _generateRandomString(int minLength, int maxLength) {
    int length = _random.nextInt(maxLength - minLength + 1) + minLength;
    const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz ';
    return String.fromCharCodes(Iterable.generate(length,
        (_) => characters.codeUnitAt(_random.nextInt(characters.length))));
  }

  late Map userData;
  String authToken = '';
  bool showRedacted = false;
  List<Widget> dummyCards = [];

  final serverAddressController = Get.find<ServerAddressController>();
  final ownerController = Get.find<OwnerController>();

  @override
  void initState() {
    super.initState();
    dummyCards = List.generate(12, (index) {
      return ClassesCard(
        imageUrl:
            "https://storage.googleapis.com/cms-storage-bucket/a9d6ce81aee44ae017ee.png",
        cost: '00.00',
        location: _generateRandomString(10, 13),
        className: _generateRandomString(10, 13),
        classGender: index % 2 == 0 ? 'Female' : 'Male',
        classData: const {},
      );
    });
    getUserData();
    fetchData();
  }

  void getUserData() async {
    userData = await SecureStorage().getItem('userData');
  }

  Future<void> fetchData() async {
    try {
      setState(() {
        showRedacted = true;
      });
      authToken = await SecureStorage().getItem('authToken');
      final response = await http.get(
          Uri.parse('http://${serverAddressController.IP}:3001/owner/pos/'),
          headers: {
            'auth-token': authToken,
          });
      if (response.statusCode == 200) {
        ownerController.setPosProductsData(jsonDecode(response.body)['data']);
        SecureStorage()
            .setItem('posProductsData', jsonDecode(response.body)['data']);
        SecureStorage().setItem('posProductsDataUserId', userData['id']);
      } else {
        CustomSnackbar.showFailureSnackbar(
            context, "Oops!", json.decode(response.body)['message']);
      }
      setState(() {
        showRedacted = false;
      });
    } catch (e) {
      CustomSnackbar.showFailureSnackbar(
          context, "Oops!", "Sorry, couldn't request to server");
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar(
            title: "POS",
            backgroundColor: appBarColor,
            foregroundColor: appBarTextColor),
        drawer: const CustomNavigationDrawer(
          active: 'Point of Sales',
          accType: "Owner",
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.of(context).pushNamed(CreatePOSProductPage.routePath);
          },
          backgroundColor: colorScheme.inversePrimary,
          child: const Icon(Icons.add_rounded),
        ),
        backgroundColor: colorScheme.surface,
        body: GetBuilder<OwnerController>(builder: (controller) {
          return RefreshIndicator(
            triggerMode: RefreshIndicatorTriggerMode.onEdge,
            displacement: 60,
            onRefresh: () async {
              HapticFeedback.mediumImpact();
              fetchData();
            },
            backgroundColor: Colors.white,
            // child: const SizedBox()
            child: !showRedacted
                ? ListView.builder(
                    itemCount: controller.posProductsData.length,
                    itemBuilder: (context, index) {
                      final posProductsData = controller.posProductsData[index];
                      return POSProductCard(
                        imageUrl:
                            "https://ik.imagekit.io/umartariq/posProductImages/${posProductsData['imageData']['name'] ?? ''}",
                        cost: posProductsData['price'] != null
                            ? posProductsData['price'].toString()
                            : '',
                        location: posProductsData['location'] ?? '',
                        productName: posProductsData['productName'] ?? '',
                        quantity: posProductsData['quantity'] != null
                            ? posProductsData['quantity'].toString()
                            : '',
                        productData: posProductsData,
                        isSeller: true,
                      );
                    },
                  )
                : ListView.builder(
                    itemCount: dummyCards.length,
                    itemBuilder: (context, index) {
                      return dummyCards[index];
                    },
                  ),
          );
        }));
  }
}
