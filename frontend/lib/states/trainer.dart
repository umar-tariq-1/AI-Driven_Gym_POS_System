import 'package:frontend/data/secure_storage.dart';
import 'package:get/get.dart';

class TrainerController extends GetxController {
  List<dynamic> classesData = [];

  @override
  void onInit() async {
    super.onInit();
    final storedData = await SecureStorage().getItem('trainerClassesData');
    final userData = await SecureStorage().getItem('userData');
    final trainerDataId =
        await SecureStorage().getItem('trainerClassesDataUserId');
    if (storedData != null && userData['id'] == trainerDataId) {
      classesData = storedData;
      update();
    }
  }

  void setClassesData(List<dynamic> newData) {
    classesData = newData;
    update();
  }
}
