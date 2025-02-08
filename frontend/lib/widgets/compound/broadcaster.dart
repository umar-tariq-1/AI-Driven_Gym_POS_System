import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_live_streaming/zego_uikit_prebuilt_live_streaming.dart';
import '../../data/constants.dart';

class Broadcaster extends StatelessWidget {
  String userId;
  String userName;
  String liveId;
  Broadcaster(
      {super.key,
      required this.userId,
      required this.userName,
      required this.liveId});

  // void initState() {
  //   setup();
  // }

  // void setup() {}

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ZegoUIKitPrebuiltLiveStreaming(
        appID: ZegoCloud_LiveStreaming_AppId,
        appSign: ZegoCloud_LiveStreaming_AppSign,
        userID: userId,
        userName: userName,
        liveID: liveId,
        config: ZegoUIKitPrebuiltLiveStreamingConfig.host(),
      ),
    );
  }
}
