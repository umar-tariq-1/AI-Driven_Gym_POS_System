import 'package:get/get.dart';

class TrainerController extends GetxController {
  List<dynamic> classesData = [];

  void setClassesData(List<dynamic> newData) {
    classesData = newData;
    update();
  }

  void addClassData(Map newData) {
    classesData.add(newData);
    update();
  }
}
