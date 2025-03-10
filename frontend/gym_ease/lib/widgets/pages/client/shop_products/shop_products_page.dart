import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:gym_ease/data/secure_storage.dart';
import 'package:gym_ease/main.dart';
import 'package:gym_ease/states/client.dart';
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

class ShopProductsPage extends StatefulWidget {
  const ShopProductsPage({super.key});

  static const String routePath = '/client/shop-products';

  @override
  State<ShopProductsPage> createState() => _OwnerPointOfSalesPageState();
}

class _OwnerPointOfSalesPageState extends State<ShopProductsPage> {
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
  final clientController = Get.find<ClientController>();

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
          Uri.parse(
              'http://${serverAddressController.IP}:3001/client/shop-products/'),
          headers: {
            'auth-token': authToken,
          });
      if (response.statusCode == 200) {
        clientController.setShopProductsData(jsonDecode(response.body)['data']);
        SecureStorage()
            .setItem('shopProductsData', jsonDecode(response.body)['data']);
        SecureStorage().setItem('shopProductsDataUserId', userData['id']);
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
            title: "Shop Products",
            backgroundColor: appBarColor,
            foregroundColor: appBarTextColor),
        drawer: const CustomNavigationDrawer(
          active: 'Shop Products',
          accType: "Client",
        ),
        backgroundColor: colorScheme.surface,
        body: GetBuilder<ClientController>(builder: (controller) {
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
                    itemCount: controller.shopProductsData.length,
                    itemBuilder: (context, index) {
                      final shopProductData =
                          controller.shopProductsData[index];
                      return POSProductCard(
                        imageUrl:
                            "https://ik.imagekit.io/umartariq/posProductImages/${shopProductData['imageData']['name'] ?? ''}",
                        cost: shopProductData['price'] != null
                            ? shopProductData['price'].toString()
                            : '',
                        location: shopProductData['location'] ?? '',
                        productName: shopProductData['productName'] ?? '',
                        quantity: shopProductData['quantity'] != null
                            ? shopProductData['quantity'].toString()
                            : '',
                        productData: shopProductData,
                        isSeller: false,
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
