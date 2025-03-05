import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gym_ease/data/secure_storage.dart';
import 'package:gym_ease/main.dart';
import 'package:gym_ease/states/server_address.dart';
import 'package:gym_ease/widgets/base/confirmation_dialog.dart';
import 'package:zego_uikit_prebuilt_live_streaming/zego_uikit_prebuilt_live_streaming.dart';
import '../../data/constants.dart';
import 'package:http/http.dart' as http;

class Broadcaster extends StatelessWidget {
  String userId;
  String userName;
  String liveId;
  Broadcaster({
    super.key,
    required this.userId,
    required this.userName,
    required this.liveId,
  });

  // void initState() {
  //   setup();
  // }

  // void setup() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: statusBarColor,
      body: SafeArea(
        child: ZegoUIKitPrebuiltLiveStreaming(
          appID: ZegoCloud_LiveStreaming_AppId,
          appSign: ZegoCloud_LiveStreaming_AppSign,
          userID: userId,
          userName: userName,
          liveID: liveId,
          config: ZegoUIKitPrebuiltLiveStreamingConfig.host(),
          events: ZegoUIKitPrebuiltLiveStreamingEvents(
            onStateUpdated: (state) async {
              String authToken = await SecureStorage().getItem('authToken');
              if (state == ZegoLiveStreamingState.living) {
                final response = await http.put(
                    Uri.parse(
                        'http://${ServerAddressController().IP}:3001/trainer/classes/update-streaming'),
                    headers: {
                      'auth-token': authToken,
                      'Content-Type': 'application/json',
                    },
                    body: jsonEncode({
                      'classId': int.parse(liveId.split('_').last),
                      'isStreaming': true,
                    }));
                if (response.statusCode != 200) {}
              }
              if (state == ZegoLiveStreamingState.ended) {
                final response = await http.put(
                    Uri.parse(
                        'http://${ServerAddressController().IP}:3001/trainer/classes/update-streaming'),
                    headers: {
                      'auth-token': authToken,
                      'Content-Type': 'application/json',
                    },
                    body: jsonEncode({
                      'classId': int.parse(liveId.split('_').last),
                      'isStreaming': false,
                    }));
                if (response.statusCode != 200) {}
              }
            },
          ),
        ),
      ),
    );
  }
}
