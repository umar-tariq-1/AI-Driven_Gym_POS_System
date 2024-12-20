import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/states/server_address.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/data/secure_storage.dart';
import 'package:frontend/main.dart';
import 'package:frontend/widgets/base/app_bar.dart';
import 'package:frontend/widgets/base/card.dart';
import 'package:frontend/widgets/base/navigation_drawer.dart';

import '../../../../theme/theme.dart';

class BookClassesPage extends StatefulWidget {
  const BookClassesPage({super.key});

  static const routePath = '/client/book-classes';

  @override
  State<BookClassesPage> createState() => _BookClassesPageState();
}

class _BookClassesPageState extends State<BookClassesPage> {
  late Map userData;
  List<Map<String, dynamic>> classesData = [];
  final serverAddressController = Get.find<ServerAddressController>();

  @override
  void initState() {
    super.initState();
    getUserData();
    fetchClassesData();
  }

  void getUserData() async {
    userData = await SecureStorage().getItem('userData');
  }

  Future<void> fetchClassesData() async {
    try {
      final response = await http.get(
        Uri.parse('http://${serverAddressController.IP}:3001/client/classes'),
      );
      if (response.statusCode == 200) {
        setState(() {
          classesData = List<Map<String, dynamic>>.from(
            json.decode(response.body)['data'],
          );
        });
      } else {
        throw Exception('Failed to load classes');
      }
    } catch (e) {
      print('Error fetching classes data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
          title: "Book Classes",
          backgroundColor: appBarColor,
          foregroundColor: appBarTextColor),
      drawer: const CustomNavigationDrawer(
        active: 'Book Classes',
        accType: "Client",
      ),
      backgroundColor: colorScheme.surface,
      body: ListView(
        children: classesData.map((classData) {
          return CustomCard(
            imageUrl:
                "https://ik.imagekit.io/umartariq/trainerClassImages/${classData['imageData']['name'] ?? ''}",
            cost: classData['classFee'] ?? '',
            location: classData['gymLocation'] ?? '',
            className: classData['className'] ?? '',
            classGender: classData['classGender'] ?? '',
            classData: classData,
          );
        }).toList(),
      ),
    );
  }
}
