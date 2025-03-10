import 'package:get/get.dart';

class ClientController extends GetxController {
  List<dynamic> classesData = [];

  void setClassesData(List<dynamic> newData) {
    classesData = newData;
    update();
  }
}
