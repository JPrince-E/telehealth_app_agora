import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class VideoCallPage extends StatefulWidget {
  final String username;
  final String role;

  VideoCallPage({required this.username, required this.role});

  @override
  _VideoCallPageState createState() => _VideoCallPageState();
}

class _VideoCallPageState extends State<VideoCallPage> {
  late RtcEngine _engine;
  int? _remoteUid;

  final String APP_ID = '5edabab50c05485c87c3f0cdccba838e';
  final String TOKEN = '007eJxSYPCrkN2+cUW8pH1H2jLlreJq+481LNY4NC82cMdOE/03ij8VGExTUxKTEpNMDZINTE0sTJMtzJON0wySU5KTkxItjC1S397cl2bDwMBguEGHlZGBkYGFgZEBxGcCk8xgkgVKlqQWl3AwlBanFuUl5qYCAgAA//9n5SNY';
  final String CHANNEL_NAME = 'test';

  @override
  void initState() {
    super.initState();
    _initAgora();
  }

  Future<void> _initAgora() async {
    await [Permission.microphone, Permission.camera].request();

    _engine = createAgoraRtcEngine();
    await _engine.initialize(RtcEngineContext(appId: APP_ID));

    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          print('onJoinChannelSuccess: ${connection.localUid}');
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          setState(() {
            _remoteUid = remoteUid;
          });
        },
        onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
          setState(() {
            _remoteUid = null;
          });
        },
        onError: (ErrorCodeType errorCode, String errorMessage) {
          print('Error: $errorCode, Message: $errorMessage');
        },
      ),
    );

    await _engine.enableVideo();
    await _engine.startPreview();

    final token = await fetchTokenFromDatabase(); // Fetch token from database

    ChannelMediaOptions options = ChannelMediaOptions(
      channelProfile: ChannelProfileType.channelProfileCommunication,
      clientRoleType: widget.role == 'doctor' ? ClientRoleType.clientRoleBroadcaster : ClientRoleType.clientRoleAudience,
    );

    await _engine.joinChannel(
      token: token, // Use the fetched token
      channelId: CHANNEL_NAME,
      uid: 0,
      options: options,
    );
  }


  @override
  void dispose() {
    _engine.leaveChannel();
    _engine.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Video Call with ${widget.username}'),
      ),
      body: Stack(
        children: [
          Center(child: _renderLocalPreview()),
          if (_remoteUid != null)
            Align(
              alignment: Alignment.topRight,
              child: Container(
                width: 120,
                height: 160,
                child: AgoraVideoView(
                  controller: VideoViewController.remote(
                    rtcEngine: _engine,
                    canvas: VideoCanvas(uid: _remoteUid!),
                    connection: RtcConnection(channelId: CHANNEL_NAME),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _renderLocalPreview() {
    return AgoraVideoView(
      controller: VideoViewController(
        rtcEngine: _engine,
        canvas: const VideoCanvas(uid: 0),
      ),
    );
  }
}


Future<String> fetchTokenFromDatabase() async {
  final doc = await FirebaseFirestore.instance.collection('tokens').doc('your_token_doc_id').get();
  return doc['token'];
}
