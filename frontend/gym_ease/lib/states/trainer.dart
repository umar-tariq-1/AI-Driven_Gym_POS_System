import 'package:get/get.dart';

class TrainerController extends GetxController {
  //Classes Data
  List<dynamic> classesData = [];

  void setClassesData(List<dynamic> newData) {
    classesData = newData;
    update();
  }

  void addClassData(Map newData) {
    classesData.add(newData);
    update();
  }

  //Products Data
  List<dynamic> shopProductsData = [];

  void setShopProductsData(List<dynamic> newData) {
    shopProductsData = newData;
    update();
  }

  void addShopProductsData(Map newData) {
    shopProductsData.add(newData);
    update();
  }
}
