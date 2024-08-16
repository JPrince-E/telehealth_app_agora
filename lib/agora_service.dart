import 'package:agora_rtc_engine/agora_rtc_engine.dart';

class AgoraService {
  static late RtcEngine _engine;

  static Future<void> initializeAgora(String appId) async {
    _engine = createAgoraRtcEngine();
    await _engine.initialize(RtcEngineContext(appId: appId));
  }

  static Future<void> joinChannel(String token, String channelId, String role) async {
    ChannelMediaOptions options = ChannelMediaOptions(
      channelProfile: ChannelProfileType.channelProfileCommunication,
      clientRoleType: role == 'doctor' ? ClientRoleType.clientRoleBroadcaster : ClientRoleType.clientRoleAudience,
    );
    await _engine.joinChannel(
      token: token,
      channelId: channelId,
      uid: 0,
      options: options,
    );
  }

  static Future<void> leaveChannel() async {
    await _engine.leaveChannel();
  }

  static void dispose() {
    _engine.release();
  }
}
