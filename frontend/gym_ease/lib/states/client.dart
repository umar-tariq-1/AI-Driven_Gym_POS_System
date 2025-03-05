import 'package:gym_ease/data/secure_storage.dart';
import 'package:get/get.dart';

class ClientController extends GetxController {
  List<dynamic> classesData = [];

  // @override
  // void onInit() async {
  //   super.onInit();
  //   final storedData = await SecureStorage().getItem('clientClassesData');
  //   final userData = await SecureStorage().getItem('userData');
  //   final clientDataId =
  //       await SecureStorage().getItem('clientClassesDataUserId');
  //   if (storedData != null && userData['id'] == clientDataId) {
  //     classesData = storedData;
  //     update();
  //   }
  // }

  void setClassesData(List<dynamic> newData) {
    classesData = newData;
    update();
  }
}
