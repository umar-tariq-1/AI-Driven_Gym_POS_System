import 'package:get/get.dart';

class ServerAddressController extends GetxController {
  String IP = '192.168.100.8';

  void setIP(String newIP) {
    IP = newIP;
  }
}
