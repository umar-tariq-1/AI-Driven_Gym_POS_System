import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_live_streaming/zego_uikit_prebuilt_live_streaming.dart';

const appId = 242112313;
const appSign =
    '6a70670df1768cabfc6a2b8877687b26a37ec62a8ab4d41349d9baa2354ebca7';

class Audience extends StatelessWidget {
  String userId;
  String userName;
  String liveId;
  Audience(
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
        appID: appId,
        appSign: appSign,
        userID: userId,
        userName: userName,
        liveID: liveId,
        config: ZegoUIKitPrebuiltLiveStreamingConfig.audience(),
      ),
    );
  }
}
